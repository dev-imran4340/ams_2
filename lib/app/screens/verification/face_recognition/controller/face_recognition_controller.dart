import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:ams_2/app/screens/index/controller/index_controller.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../../../../api/app_preferences.dart';
import '../../../../api/exception_handler.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../dashboard/model/dashboard_model.dart';
import '../model/face_recognition_model.dart';
import '../repo/face_recognition_repo.dart';
import '../view/components/verification_success_sheet.dart';

class FaceRecognitionController extends GetxController
    with GetTickerProviderStateMixin {
  final FaceRecognitionRepo repo;

  FaceRecognitionController({required this.repo});

  // Hardware Camera Controller
  CameraController? cameraController;
  CameraDescription? activeCamera;

  // Real-time ML Kit Stream Face Detector
  FaceDetector? _streamDetector;

  // Animations
  late final AnimationController pulseAnimationController;
  late final Animation<double> pulseAnimation;

  late final AnimationController progressAnimationController;
  late final Animation<double> progressAnimation;

  // Observables
  final RxBool isCameraInitialized = false.obs;
  final RxBool isStreaming = false.obs;
  final RxBool isProcessingFrame = false.obs;

  // Biometric status & results
  final RxBool isScanning = true.obs;
  final RxBool isVerifying = false.obs;
  final RxBool isMatchSuccess = false.obs;
  final RxBool isLoading = false.obs;
  final RxDouble matchProgress = 0.0.obs;
  final RxDouble confidenceReadout = 0.0.obs;
  final RxString statusText = 'Align your face inside the oval frame'.obs;
  final RxString employeeId = ''.obs;
  final RxString employeeName = ''.obs;
  final RxString companyName = ''.obs;
  final RxString verificationTime = ''.obs;
  final Rxn<FaceBiometricMatchModel> matchResult =
      Rxn<FaceBiometricMatchModel>();

  // Real-time 5 Quality Checks State
  final Rx<FaceCheckResult> checkResult = FaceCheckResult.initial().obs;
  final RxBool isAllChecksPassed = false.obs;

  // Local Reference Face Enrollment & Comparison State
  final RxBool hasReferenceFace = false.obs;
  final Rx<FaceActionMode> actionMode = FaceActionMode.verify.obs;
  final RxBool isSavingReference = false.obs;
  final RxBool isMatching = false.obs;
  final Rxn<FaceComparisonReport> comparisonReport =
      Rxn<FaceComparisonReport>();

  // Punch mode arguments
  final RxBool isPunchMode = false.obs;
  final RxString punchKind = 'in'.obs;
  AttendanceRequiresModel? punchRequires;

  // Flag preventing redundant navigation / double-cleanup
  bool _isExiting = false;

  // Aliases for backwards-compatibility
  RxBool get matchSuccess => isMatchSuccess;
  RxBool get isDetecting => isScanning;

  // Timers for automated stabilization & pipeline
  Timer? _stablePassTimer;
  Timer? _progressTimer;
  int _consecutivePassFrames = 0;
  bool _registrationCooldown = false;

  // Cached passing frame & face for instant live enrollment and matching
  CameraImage? _lastPassingFrame;
  Face? _lastPassingFace;

  @override
  void onInit() {
    super.onInit();

    // 1. Hydrate real user profile details from AppPreferences
    final savedName = AppPreferences.userName;
    final savedCode = AppPreferences.selfEmployeeNumber ??
        AppPreferences.employeeNumber ??
        AppPreferences.userId;
    final savedCompany = AppPreferences.companyName;

    if (savedName != null && savedName.isNotEmpty) {
      employeeName.value = savedName;
    }
    if (savedCode != null && savedCode.isNotEmpty) {
      employeeId.value = savedCode;
    }
    if (savedCompany != null && savedCompany.isNotEmpty) {
      companyName.value = savedCompany;
    }

    // 2. Extract arguments (Either from Attendance Punch or Employee Card QR)
    if (Get.arguments is Map) {
      final args = Get.arguments as Map;
      if (args['isPunchMode'] == true) {
        isPunchMode.value = true;
        punchKind.value = args['punchKind']?.toString() ?? 'in';
        if (args['requires'] is AttendanceRequiresModel) {
          punchRequires = args['requires'] as AttendanceRequiresModel;
        }
      }
      if (args['card'] != null) {
        final dynamic card = args['card'];
        final code = card.employeeCode ?? card.employeeId;
        if (code != null && code.toString().isNotEmpty) {
          employeeId.value = code.toString();
        }
        if (card.employeeName != null &&
            card.employeeName.toString().isNotEmpty) {
          employeeName.value = card.employeeName.toString();
        }
        if (card.companyName != null &&
            card.companyName.toString().isNotEmpty) {
          companyName.value = card.companyName.toString();
        }
      }
    }

    // 2. Setup Concentric Radar Pulsing Animation
    pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    pulseAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(
        parent: pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    pulseAnimationController.repeat(reverse: true);

    // 3. Setup Progress Animation Controller
    progressAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: progressAnimationController,
        curve: Curves.easeInOutCubic,
      ),
    );

    // 4. Share single native FaceDetector instance from repo (prevents duplicate CCTClearcutUploader lock contention)
    _streamDetector = repo.detector;

    // 5. Initialize live hardware camera (Front Lens) & check enrolled reference
    _initFrontCamera();
    _checkExistingReferenceFace();
  }

  @override
  void onClose() {
    // Strict lifecycle disposal preventing memory leaks and hardware locks
    _stablePassTimer?.cancel();
    _progressTimer?.cancel();
    pulseAnimationController.dispose();
    progressAnimationController.dispose();
    if (cameraController != null) {
      try {
        if (cameraController!.value.isStreamingImages) {
          cameraController!.stopImageStream();
        }
        cameraController?.dispose();
      } catch (_) {}
      cameraController = null;
    }
    repo.dispose();
    _lastPassingFrame = null;
    _lastPassingFace = null;
    super.onClose();
  }

  /// Checks if an enrolled reference face is available locally
  Future<void> _checkExistingReferenceFace() async {
    try {
      final exists = await repo.hasSavedReferenceFace();
      hasReferenceFace.value = exists;
      if (!exists) {
        actionMode.value = FaceActionMode.register;
        statusText.value = 'No face registered. Align inside oval to Register.';
      } else {
        actionMode.value = FaceActionMode.verify;
        statusText.value = 'Align face inside oval to Verify';
      }
    } catch (_) {
      hasReferenceFace.value = false;
      actionMode.value = FaceActionMode.register;
    }
  }

  /// Sets active operation mode (Register Face vs Verify Face)
  void setMode(FaceActionMode mode) {
    if (isVerifying.value || isSavingReference.value) return;
    _registrationCooldown = false;
    actionMode.value = mode;
    _consecutivePassFrames = 0;
    matchProgress.value = 0.0;
    isAllChecksPassed.value = false;
    isMatchSuccess.value = false;
    checkResult.value = FaceCheckResult.noFace();
    comparisonReport.value = null;
    _lastPassingFrame = null;
    _lastPassingFace = null;

    if (mode == FaceActionMode.register) {
      statusText.value = 'Align face inside oval to Register';
    } else {
      statusText.value = hasReferenceFace.value
          ? 'Align face inside oval to Verify'
          : 'No face registered yet. Switch to Register Face first.';
    }
    _ensureImageStreamRunning();
  }

  /// Initializes hardware camera using the front-facing sensor
  Future<void> _initFrontCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        isCameraInitialized.value = false;
        checkResult.value = const FaceCheckResult(
          hasExactlyOneFace: false,
          faceCount: 0,
          eyesOpen: false,
          headStraight: false,
          isCentered: false,
          isScaleValid: false,
          isInsideOval: false,
          statusMessage: 'No hardware camera detected (Simulator Mode)',
        );
        return;
      }

      final frontCamera = cameras.firstWhereOrNull(
            (c) => c.lensDirection == CameraLensDirection.front,
          ) ??
          cameras.first;

      activeCamera = frontCamera;

      cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      await cameraController!.initialize();

      if (!isClosed) {
        isCameraInitialized.value = true;
        _startImageStream();
      }
    } on CameraException catch (e) {
      isCameraInitialized.value = false;
      if (e.code != 'channel-error') {
        ExceptionHandler.handle(
          ApiException(
            message: 'Camera initialization error: ${e.description ?? e.code}',
          ),
          tag: 'FaceRecognitionController / FaceScreen -> _initFrontCamera()',
          showToast: false,
        );
      }
    } catch (e, stackTrace) {
      isCameraInitialized.value = false;
      ExceptionHandler.handle(
        ApiException(message: 'Camera initialization error: $e'),
        tag:
            'FaceRecognitionController / FaceScreen -> _initFrontCamera() [${stackTrace.toString().split('\n').first}]',
        showToast: false,
      );
    }
  }

  /// Ensures preview is unpaused and image stream is active
  Future<void> _ensureImageStreamRunning() async {
    if (cameraController == null || !cameraController!.value.isInitialized) return;

    try {
      if (cameraController!.value.isPreviewPaused) {
        await cameraController!.resumePreview();
      }
    } catch (_) {}

    if (!cameraController!.value.isStreamingImages) {
      isStreaming.value = false;
      await _startImageStream();
    }
  }

  /// Starts live camera stream processing with Google ML Kit
  Future<void> _startImageStream() async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return;
    }
    if (cameraController!.value.isStreamingImages) {
      isStreaming.value = true;
      return;
    }

    try {
      if (cameraController!.value.isPreviewPaused) {
        await cameraController!.resumePreview();
      }
      isStreaming.value = true;
      await cameraController!.startImageStream((CameraImage image) {
        if (!isClosed &&
            !isProcessingFrame.value &&
            !isSavingReference.value &&
            !isVerifying.value &&
            !isMatchSuccess.value) {
          _processCameraFrame(image);
        }
      });
    } catch (e) {
      debugPrint('>>> [AI FACE] Error starting image stream: $e');
      isStreaming.value = false;
    }
  }

  /// Safely pauses/stops camera stream before taking still photos
  Future<void> _stopImageStream() async {
    if (cameraController != null &&
        cameraController!.value.isInitialized &&
        (cameraController!.value.isStreamingImages || isStreaming.value)) {
      try {
        isStreaming.value = false;
        await cameraController!.stopImageStream();
      } catch (e) {
        debugPrint('>>> [AI FACE] Note on stopping image stream: $e');
      }
      // Allow native AVFoundation/Camera2 buffer queue to drain completely
      await Future.delayed(const Duration(milliseconds: 200));
    } else {
      isStreaming.value = false;
    }
  }

  /// Evaluates each camera frame using Google ML Kit
  Future<void> _processCameraFrame(CameraImage image) async {
    if (isProcessingFrame.value || isClosed) return;
    isProcessingFrame.value = true;

    try {
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage == null || _streamDetector == null) {
        isProcessingFrame.value = false;
        return;
      }

      final faces = await _streamDetector!.processImage(inputImage);

      if (isClosed || isMatchSuccess.value) return;

      // Evaluate the biometric quality checks with current frame caching
      _evaluateFaceChecks(
        faces,
        image.width.toDouble(),
        image.height.toDouble(),
        currentFrame: image,
      );
    } catch (e) {
      debugPrint('>>> [AI FACE] Frame processing error: $e');
    } finally {
      isProcessingFrame.value = false;
    }
  }

  /// Converts CameraImage into ML Kit InputImage format (Zero-copy when planes == 1)
  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (activeCamera == null) return null;

    final sensorOrientation = activeCamera!.sensorOrientation;
    final rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;

    if (image.planes.isEmpty) return null;

    final Uint8List bytes;
    if (image.planes.length == 1) {
      bytes = image.planes.first.bytes;
    } else {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      bytes = allBytes.done().buffer.asUint8List();
    }

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  /// Performs strict geometric & liveness validation checks with responsive thresholds
  void _evaluateFaceChecks(
    List<Face> faces,
    double frameWidth,
    double frameHeight, {
    CameraImage? currentFrame,
  }) {
    // Check 1: Exactly one face
    if (faces.isEmpty) {
      checkResult.value = FaceCheckResult.noFace();
      isAllChecksPassed.value = false;
      _consecutivePassFrames = 0;
      statusText.value = 'Align your face inside the oval frame';
      return;
    }

    if (faces.length > 1) {
      checkResult.value = FaceCheckResult.multipleFaces(faces.length);
      isAllChecksPassed.value = false;
      _consecutivePassFrames = 0;
      statusText.value = '${faces.length} faces detected. 1 person only.';
      return;
    }

    final face = faces.first;
    final box = face.boundingBox;

    // Check 2: Eyes open (probability >= 0.35 if classification available)
    final double? leftEye = face.leftEyeOpenProbability;
    final double? rightEye = face.rightEyeOpenProbability;
    final bool eyesClassificationAvailable = leftEye != null && rightEye != null;
    final bool eyesOpen = !eyesClassificationAvailable || (leftEye >= 0.35 && rightEye >= 0.35);

    // Check 3: Head orientation check (Yaw and Roll within natural thresholds)
    final double yaw = face.headEulerAngleY ?? 0.0;
    final double roll = face.headEulerAngleZ ?? 0.0;
    final bool headStraight = yaw.abs() <= 20.0 && roll.abs() <= 20.0;

    // In portrait orientation, camera sensor portrait dimensions:
    final double camW = math.min(frameWidth, frameHeight);
    final double camH = math.max(frameWidth, frameHeight);
    final bool isFront = activeCamera?.lensDirection == CameraLensDirection.front;

    // Check 4: Centering with front-camera mirroring
    final double camFaceCenterX = box.left + (box.width / 2.0);
    final double camFaceCenterY = box.top + (box.height / 2.0);
    final double previewCenterX = isFront ? (camW - camFaceCenterX) : camFaceCenterX;
    final double previewCenterY = camFaceCenterY;

    final double offsetX = (previewCenterX - (camW / 2.0)) / camW;
    final double offsetY = (previewCenterY - (camH / 2.0)) / camH;
    final bool isCentered = offsetX.abs() <= 0.22 && offsetY.abs() <= 0.22;

    // Check 5: Proportional distance / scale (35% to 85% of portrait width)
    final double scaleRatio = box.width / camW;
    final bool isScaleValid = scaleRatio >= 0.35 && scaleRatio <= 0.85;

    // Check 6: Full face fits inside the biometric oval viewfinder
    final double ovalW = 240.w;
    final double ovalH = 310.h;
    final double ovalA = ovalW / 2.0;
    final double ovalB = ovalH / 2.0;

    final double scale = math.max(ovalW / camW, ovalH / camH);
    final double scaledW = camW * scale;
    final double scaledH = camH * scale;
    final double shiftX = (ovalW - scaledW) / 2.0;
    final double shiftY = (ovalH - scaledH) / 2.0;

    final double fLeft = (isFront ? (camW - box.right) : box.left) * scale + shiftX;
    final double fRight = (isFront ? (camW - box.left) : box.right) * scale + shiftX;
    final double fTop = box.top * scale + shiftY;
    final double fBottom = box.bottom * scale + shiftY;

    final double fMidX = (fLeft + fRight) / 2.0;
    final double fMidY = (fTop + fBottom) / 2.0;

    bool isPointInOval(double px, double py) {
      final double dx = (px - ovalA) / ovalA;
      final double dy = (py - ovalB) / ovalB;
      return (dx * dx + dy * dy) <= 1.05;
    }

    final bool fitsHorizontally = fLeft >= -12.w && fRight <= (ovalW + 12.w);
    final bool fitsVertically = fTop >= -12.h && fBottom <= (ovalH + 12.h);
    final bool isInsideOval = fitsHorizontally &&
        fitsVertically &&
        isPointInOval(fMidX, fMidY) &&
        isPointInOval(fMidX, fTop + 15.h) &&
        isPointInOval(fMidX, fBottom - 15.h);

    // Determine descriptive feedback message in priority order
    String feedback = 'Perfect! Hold steady';
    if (!eyesOpen) {
      feedback = 'Open both eyes / remove dark sunglasses';
    } else if (!headStraight) {
      feedback = 'Keep head straight and face the camera';
    } else if (scaleRatio < 0.35) {
      feedback = 'Move closer to camera';
    } else if (scaleRatio > 0.85) {
      feedback = 'Move slightly back';
    } else if (!isInsideOval || !isCentered) {
      feedback = 'Fit your full face inside the oval';
    }

    final result = FaceCheckResult(
      hasExactlyOneFace: true,
      faceCount: 1,
      eyesOpen: eyesOpen,
      leftEyeProbability: leftEye,
      rightEyeProbability: rightEye,
      headStraight: headStraight,
      headEulerAngleY: yaw,
      headEulerAngleZ: roll,
      isCentered: isCentered,
      centerOffsetX: offsetX,
      centerOffsetY: offsetY,
      isScaleValid: isScaleValid,
      scaleRatio: scaleRatio,
      isInsideOval: isInsideOval,
      statusMessage: feedback,
    );

    checkResult.value = result;
    isAllChecksPassed.value = result.allPassed;
    statusText.value = feedback;

    // Automated trigger when checks pass steadily
    if (result.allPassed) {
      if (currentFrame != null) {
        _lastPassingFrame = currentFrame;
        _lastPassingFace = face;
      }

      if (_registrationCooldown) {
        _consecutivePassFrames = 0;
        matchProgress.value = 0.0;
        return;
      }
      _consecutivePassFrames++;
      // Responsive 5-frame fill (~150ms of steady hold)
      matchProgress.value = (_consecutivePassFrames / 5.0).clamp(0.0, 1.0);

      if (_consecutivePassFrames >= 5 &&
          !isVerifying.value &&
          !isSavingReference.value &&
          !isMatchSuccess.value) {
        _consecutivePassFrames = 0;
        if (actionMode.value == FaceActionMode.register) {
          saveReferenceFace();
        } else {
          if (hasReferenceFace.value) {
            verifyFaceMatch();
          } else {
            statusText.value = 'No face registered. Switch to Register Face.';
          }
        }
      }
    } else {
      _consecutivePassFrames = 0;
      if (!isVerifying.value && !isMatchSuccess.value) {
        matchProgress.value = 0.0;
      }
    }
  }

  /// Action 1: Enrolls 192-dim baseline biometric template instantly from live frame
  Future<void> saveReferenceFace() async {
    if (isSavingReference.value) return;

    try {
      isSavingReference.value = true;
      statusText.value = 'Enrolling 192-dim face template...';
      HapticFeedback.mediumImpact();

      File enrolledFile;

      if (_lastPassingFrame != null && _lastPassingFace != null && activeCamera != null) {
        // Fast in-memory enrollment (< 20ms) directly from the passing camera stream buffer
        final croppedFace = repo.cropFaceFromCameraImage(
          cameraImage: _lastPassingFrame!,
          detectedFace: _lastPassingFace!,
          sensorOrientation: activeCamera!.sensorOrientation,
          isFrontCamera: activeCamera!.lensDirection == CameraLensDirection.front,
        );

        enrolledFile = await repo.saveReferenceFaceFromCroppedFace(
          croppedFace112: croppedFace,
          detectedFace: _lastPassingFace,
        );
      } else {
        // Fallback: take picture if no passing frame was cached
        if (cameraController == null || !cameraController!.value.isInitialized) {
          CustomSnackbar.showError(
            title: 'Camera Inactive',
            message: 'Unable to capture frame. Please ensure camera is active.',
          );
          return;
        }

        await _stopImageStream();
        final xFile = await cameraController!.takePicture();
        final capturedFile = File(xFile.path);

        try {
          if (cameraController!.value.isPreviewPaused) {
            await cameraController!.resumePreview();
          }
        } catch (_) {}

        final inputImage = InputImage.fromFile(capturedFile);
        final faces = await _streamDetector!.processImage(inputImage);
        final Face? detectedFace = faces.isNotEmpty ? faces.first : null;

        enrolledFile = await repo.saveReferenceFace(
          capturedFile,
          detectedFace: detectedFace,
        );
        await _ensureImageStreamRunning();
      }

      hasReferenceFace.value = true;
      actionMode.value = FaceActionMode.verify;
      statusText.value = 'Face Registered Successfully! Ready to Verify.';
      _consecutivePassFrames = 0;
      matchProgress.value = 0.0;
      isAllChecksPassed.value = false;
      _registrationCooldown = true;

      final fileSize = await enrolledFile.length();
      CustomSnackbar.showSuccess(
        title: 'Face Registered',
        message:
            'Baseline face enrolled (112x112 px, ${(fileSize / 1024).toStringAsFixed(1)} KB, 192-dim vector). Background dropped.',
      );

      // Release registration cooldown after 1.5s so user can verify smoothly
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (!isClosed) {
          _registrationCooldown = false;
          statusText.value = 'Align face inside oval to Verify';
        }
      });
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Error enrolling reference face: $e'),
        tag:
            'FaceRecognitionController / FaceScreen -> saveReferenceFace() [${stackTrace.toString().split('\n').first}]',
      );
      await _ensureImageStreamRunning();
    } finally {
      isSavingReference.value = false;
    }
  }

  /// Action 2: Captures live selfie, crops face only, and verifies match against enrolled 192-dim embedding
  Future<FaceComparisonReport?> captureAndVerifyMatch() async {
    await verifyFaceMatch();
    return comparisonReport.value;
  }

  /// Action 2: Verifies live face against saved reference face using cropped 192-dim embeddings
  Future<void> verifyFaceMatch() async {
    if (isVerifying.value || isMatchSuccess.value) return;

    try {
      isVerifying.value = true;
      isLoading.value = true;
      statusText.value = 'Comparing live facial biometrics...';

      // Check if reference face exists
      final hasRef = await repo.hasSavedReferenceFace();
      if (!hasRef) {
        isVerifying.value = false;
        isLoading.value = false;
        statusText.value = 'No registered face found. Switch to "Register Face" first.';
        CustomSnackbar.showInfo(
          message: 'Please switch to Register Face to enroll your biometric template first.',
        );
        await _ensureImageStreamRunning();
        return;
      }

      final refVector = await repo.getSavedFaceEmbedding();
      if (refVector == null || refVector.length != 192) {
        isVerifying.value = false;
        isLoading.value = false;
        statusText.value = 'Registered face embedding missing. Please re-register.';
        await _ensureImageStreamRunning();
        return;
      }

      FaceComparisonReport report;

      if (_lastPassingFrame != null && _lastPassingFace != null && activeCamera != null) {
        // Ultra-fast in-memory live matching (< 15ms)
        final liveCropped = repo.cropFaceFromCameraImage(
          cameraImage: _lastPassingFrame!,
          detectedFace: _lastPassingFace!,
          sensorOrientation: activeCamera!.sensorOrientation,
          isFrontCamera: activeCamera!.lensDirection == CameraLensDirection.front,
        );

        report = repo.compareLiveCroppedFace(
          refVector: refVector,
          liveCroppedFace112: liveCropped,
          detectedFace: _lastPassingFace,
        );
      } else {
        // Fallback: take picture if stream buffer is not cached
        final refFile = await repo.getReferenceFaceFile();
        if (refFile == null) {
          isVerifying.value = false;
          isLoading.value = false;
          statusText.value = 'Registered face image missing. Please re-register.';
          await _ensureImageStreamRunning();
          return;
        }

        File? selfieFile;
        if (cameraController != null && cameraController!.value.isInitialized) {
          await _stopImageStream();
          final xFile = await cameraController!.takePicture();
          selfieFile = File(xFile.path);

          try {
            if (cameraController!.value.isPreviewPaused) {
              await cameraController!.resumePreview();
            }
          } catch (_) {}
        }

        if (selfieFile == null) {
          isVerifying.value = false;
          isLoading.value = false;
          return;
        }

        report = await repo.compareFaces(
          referenceFile: refFile,
          liveSelfieFile: selfieFile,
        );
        await _ensureImageStreamRunning();
      }

      comparisonReport.value = report;
      final bool isMatched = report.matched;
      final double score = report.score * 100;

      confidenceReadout.value = score;
      final now = DateTime.now();
      verificationTime.value =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

      if (isMatched) {
        isMatchSuccess.value = true;
        matchProgress.value = 1.0;
        statusText.value = 'MATCH • Biometric Verified (${score.toStringAsFixed(1)}%)';
        HapticFeedback.heavyImpact();
        pulseAnimationController.stop();

        CustomSnackbar.showSuccess(
          title: 'Biometric MATCH',
          message:
              'Identity confirmed with ${score.toStringAsFixed(1)}% similarity (Threshold: ${(repo.matchThreshold * 100).toStringAsFixed(0)}%).',
        );

        if (isPunchMode.value) {
          await Future.delayed(const Duration(milliseconds: 700));
          await cleanupAndExit(result: true);
        } else {
          await Future.delayed(const Duration(milliseconds: 500));
          if (!isClosed && !_isExiting) {
            openSuccessModal();
          }
        }
      } else {
        isMatchSuccess.value = false;
        matchProgress.value = 0.0;
        _consecutivePassFrames = 0;
        statusText.value =
            'NOT MATCH • Similarity ${score.toStringAsFixed(1)}% below ${(repo.matchThreshold * 100).toStringAsFixed(0)}%';
        HapticFeedback.mediumImpact();

        CustomSnackbar.showError(
          title: 'Biometric NOT MATCH',
          message:
              'Score (${score.toStringAsFixed(1)}%) is below ${(repo.matchThreshold * 100).toStringAsFixed(0)}% threshold. Please retry.',
        );

        await _ensureImageStreamRunning();

        Future.delayed(const Duration(milliseconds: 1500), () {
          if (!isClosed && !isMatchSuccess.value) {
            statusText.value = 'Align face inside oval to Verify';
            _ensureImageStreamRunning();
          }
        });
      }
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Biometric verification error: $e'),
        tag:
            'FaceRecognitionController / FaceScreen -> verifyFaceMatch() [${stackTrace.toString().split('\n').first}]',
      );
      isVerifying.value = false;
      isMatchSuccess.value = false;
      statusText.value = 'Verification error. Please retry.';
      await _ensureImageStreamRunning();
    } finally {
      isLoading.value = false;
      isVerifying.value = false;
    }
  }

  /// Opens the verification success bottom sheet
  void openSuccessModal() {
    Get.bottomSheet(
      const VerificationSuccessSheet(),
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  /// Gracefully tears down hardware camera stream, dismisses modals, and returns to Dashboard
  Future<void> cleanupAndExit({dynamic result}) async {
    if (_isExiting) return;
    _isExiting = true;

    _stablePassTimer?.cancel();
    _progressTimer?.cancel();

    try {
      await _stopImageStream();
    } catch (_) {}

    try {
      await cameraController?.dispose();
    } catch (_) {}
    cameraController = null;

    if (Get.isBottomSheetOpen == true) {
      Get.back();
    }

    if (Get.isSnackbarOpen == true) {
      Get.closeCurrentSnackbar();
    }

    Get.back(result: result);
  }

  /// Navigates to the Dashboard cleanly preserving app state
  Future<void> proceedToDashboard() async {
    HapticFeedback.mediumImpact();
    await cleanupAndExit(result: isPunchMode.value);
    if (Get.isRegistered<IndexController>()) {
      Get.find<IndexController>().changeTab(0);
    } 
  }

  /// Retries the biometric verification pipeline
  void retryVerification() {
    HapticFeedback.lightImpact();
    isMatchSuccess.value = false;
    isVerifying.value = false;
    isAllChecksPassed.value = false;
    checkResult.value = FaceCheckResult.noFace();
    matchProgress.value = 0.0;
    _consecutivePassFrames = 0;
    _registrationCooldown = false;
    statusText.value = 'Align your face inside the oval frame';
    pulseAnimationController.repeat(reverse: true);
    _ensureImageStreamRunning();
  }
}
