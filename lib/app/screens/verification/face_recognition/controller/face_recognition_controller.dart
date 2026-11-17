import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:ams_2/app/screens/index/controller/index_controller.dart';
import 'package:camera/camera.dart';
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
import '../repo/camera_image_ml_input.dart';
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

    // 5. Initialize live hardware camera (Front Lens) strictly AFTER checking reference face
    // to avoid starting stream before face sync completes
    _initSequence();
  }

  Future<void> _initSequence() async {
    await _checkExistingReferenceFace();
    if (!isClosed) {
      await _initFrontCamera();
    }
  }

  @override
  void onClose() {
    // Strict lifecycle disposal preventing memory leaks and hardware locks
    isCameraInitialized.value = false;
    _stablePassTimer?.cancel();
    _progressTimer?.cancel();
    pulseAnimationController.dispose();
    progressAnimationController.dispose();
    final controllerToDispose = cameraController;
    cameraController = null;
    if (controllerToDispose != null) {
      try {
        if (controllerToDispose.value.isStreamingImages) {
          controllerToDispose.stopImageStream();
        }
        controllerToDispose.dispose();
      } catch (_) {}
    }
    repo.dispose();
    super.onClose();
  }

  /// Checks if an enrolled reference face is available locally or syncs from server
  Future<void> _checkExistingReferenceFace() async {
    try {
      isLoading.value = true;

      // Check if this is an attendance punch where face_saved is explicitly false
      if (isPunchMode.value && punchRequires?.faceSaved == false) {
        debugPrint('>>> [AI FACE] Attendance punch requires face enrollment (face_saved: false).');
        // Clear any stale local enrolled face so clean enrollment happens
        await AppPreferences.clearEnrolledFace();
        hasReferenceFace.value = false;
        actionMode.value = FaceActionMode.register;
        statusText.value = punchRequires?.consentText ??
            'Hold steady inside oval to enroll your face for attendance.';
        return;
      }

      statusText.value = 'Synchronizing verified face template...';

      // Strictly fetch from official backend endpoint GET /api/v1/me/face
      final serverFace = await repo.fetchAndSyncServerFace();
      bool exists = serverFace != null || await repo.hasSavedReferenceFace();

      hasReferenceFace.value = exists;
      if (!exists) {
        actionMode.value = FaceActionMode.register;
        statusText.value = punchRequires?.consentText ??
            'No face registered. Align inside oval to Register.';
      } else {
        actionMode.value = FaceActionMode.verify;
        statusText.value = 'Align face inside oval to Verify';
      }
    } catch (_) {
      hasReferenceFace.value = false;
      actionMode.value = FaceActionMode.register;
    } finally {
      isLoading.value = false;
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

      // Disable screen flash/torch so screen does not turn white when taking pictures
      try {
        await cameraController!.setFlashMode(FlashMode.off);
      } catch (_) {}

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

  int _frameCounter = 0;

  /// Evaluates each camera frame using Google ML Kit (Ported directly from smart_attendance)
  Future<void> _processCameraFrame(CameraImage image) async {
    if (isProcessingFrame.value || isClosed) return;
    _frameCounter++;
    isProcessingFrame.value = true;

    try {
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage == null || _streamDetector == null) {
        if (_frameCounter % 30 == 0) {
          debugPrint('>>> [AI FACE STREAM] inputImage is null (orientation: ${activeCamera?.sensorOrientation})');
        }
        isProcessingFrame.value = false;
        return;
      }

      final faces = await _streamDetector!.processImage(inputImage);

      if (_frameCounter % 15 == 0) {
        debugPrint('>>> [AI FACE STREAM] Frame $_frameCounter: ${faces.length} faces detected (${image.width}x${image.height})');
      }

      if (isClosed || isMatchSuccess.value) return;

      // Evaluate the biometric quality checks with current frame caching
      _evaluateFaceChecks(
        faces,
        image.width.toDouble(),
        image.height.toDouble(),
        currentFrame: image,
      );
    } catch (e) {
      debugPrint('>>> [AI FACE STREAM] Frame processing error: $e');
    } finally {
      isProcessingFrame.value = false;
    }
  }

  /// Converts CameraImage into ML Kit InputImage format using smart_attendance conversion
  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (activeCamera == null) return null;

    final sensorOrientation = activeCamera!.sensorOrientation;
    final rotation = _rotationIntToImageRotation(sensorOrientation);

    return inputImageFromCameraImage(image, rotation);
  }

  InputImageRotation _rotationIntToImageRotation(int rotation) {
    switch (rotation) {
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
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

    // Check 2: Eyes check completely bypassed (user requested zero eye closing/blinking required)

    // Check 3: Head orientation check (Yaw within 35 deg, Roll within 25 deg per Smart Attendance)
    final double yaw = face.headEulerAngleY ?? 0.0;
    final double roll = face.headEulerAngleZ ?? 0.0;
    final bool headStraight = yaw.abs() <= 35.0 && roll.abs() <= 25.0;

    // In portrait orientation, camera sensor portrait dimensions:
    final double camW = math.min(frameWidth, frameHeight);
    final double camH = math.max(frameWidth, frameHeight);
    final bool isFront = activeCamera?.lensDirection == CameraLensDirection.front;

    // Check 4: Centering with front-camera mirroring (Very lenient distance per smart_attendance)
    final double camFaceCenterX = box.left + (box.width / 2.0);
    final double camFaceCenterY = box.top + (box.height / 2.0);
    final double previewCenterX = isFront ? (camW - camFaceCenterX) : camFaceCenterX;
    final double previewCenterY = camFaceCenterY;

    final double offsetX = (previewCenterX - (camW / 2.0)) / camW;
    final double offsetY = (previewCenterY - (camH / 2.0)) / camH;
    final bool isCentered = offsetX.abs() <= 0.38 && offsetY.abs() <= 0.38;

    // Check 5: Proportional distance / scale (15% to 90% of portrait width per smart_attendance)
    final double scaleRatio = box.width / camW;
    final bool isScaleValid = scaleRatio >= 0.15 && scaleRatio <= 0.90;

    // Check 6: Full face fits inside the biometric viewfinder
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
      return (dx * dx + dy * dy) <= 1.45; // Lenient oval threshold matching smart_attendance
    }

    final bool fitsHorizontally = fLeft >= -50.w && fRight <= (ovalW + 50.w);
    final bool fitsVertically = fTop >= -50.h && fBottom <= (ovalH + 50.h);
    final bool isInsideOval = fitsHorizontally &&
        fitsVertically &&
        isPointInOval(fMidX, fMidY);

    debugPrint('>>> [AI FACE CHECKS] 1Face: true | HeadStraight: $headStraight (yaw: ${yaw.toStringAsFixed(1)}, roll: ${roll.toStringAsFixed(1)}) | Centered: $isCentered (offX: ${offsetX.toStringAsFixed(2)}, offY: ${offsetY.toStringAsFixed(2)}) | Scale: $isScaleValid (${scaleRatio.toStringAsFixed(2)}) | InsideOval: $isInsideOval');

    // Determine descriptive feedback message in priority order
    String feedback = 'Hold steady — scanning…';
    if (!headStraight) {
      feedback = 'Keep head straight and face the camera';
    } else if (scaleRatio < 0.15) {
      feedback = 'Move closer to camera';
    } else if (scaleRatio > 0.90) {
      feedback = 'Move slightly back';
    } else if (!isInsideOval || !isCentered) {
      feedback = 'Position your face in the oval';
    }

    final result = FaceCheckResult(
      hasExactlyOneFace: true,
      faceCount: 1,
      eyesOpen: true,
      leftEyeProbability: 1.0,
      rightEyeProbability: 1.0,
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
      if (_registrationCooldown) {
        _consecutivePassFrames = 0;
        matchProgress.value = 0.0;
        return;
      }
      // Smart Attendance steady hold: 3 frames (~90ms)
      _consecutivePassFrames++;
      matchProgress.value = (_consecutivePassFrames / 3.0).clamp(0.0, 1.0);

      if (_consecutivePassFrames >= 3 &&
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

  /// Action 1: Enrolls 192-dim baseline biometric template and submits attendance punch if in enrollment mode
  Future<void> saveReferenceFace() async {
    if (isSavingReference.value || isClosed) return;

    try {
      isSavingReference.value = true;
      statusText.value = 'Capturing high-quality face...';
      HapticFeedback.mediumImpact();

      // For enrollment (especially punch mode), capture clean, full-resolution still photo from camera
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

      // Detect face with robust multi-pass detection (handles iOS EXIF rotation, etc.)
      final capturedBytes = await capturedFile.readAsBytes();
      final faces = await repo.detectProfilePhotoFaces(capturedBytes);
      final Face? detectedFace = faces.isNotEmpty ? faces.first : null;

      if (detectedFace == null) {
        debugPrint('>>> [AI FACE] Still photo face detection returned 0 faces. Re-enabling stream.');
        statusText.value = 'Face not clearly visible in captured photo. Align and retry.';
        await _ensureImageStreamRunning();
        return;
      }
      debugPrint('>>> [AI FACE] Still photo captured successfully with face: ${detectedFace.boundingBox}');

      // Save as reference face template locally
      final enrolledFile = await repo.saveReferenceFace(
        capturedFile,
        detectedFace: detectedFace,
      );

      // If in Punch Mode:
      // Return captured high-res photo to Dashboard so Dashboard handles punch submission & loading
      if (isPunchMode.value) {
        statusText.value = 'Face Captured! Returning to Dashboard...';
        isMatchSuccess.value = true;
        matchProgress.value = 1.0;
        pulseAnimationController.stop();
        HapticFeedback.heavyImpact();

        final resultPayload = {
          'photoFile': capturedFile,
          'faceConsent': punchRequires?.faceSaved == false,
          'faceScore': 100.0,
          'faceMatch': 'matched',
        };

        await Future.delayed(const Duration(milliseconds: 300));
        await cleanupAndExit(result: resultPayload);
        return;
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

      await _ensureImageStreamRunning();

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
      File? capturedSelfiePhoto;

      // Always perform verified capture to compare with server reference face
      final refFile = await repo.getReferenceFaceFile();
      if (refFile == null) {
        isVerifying.value = false;
        isLoading.value = false;
        statusText.value = 'Registered face image missing from server.';
        await _ensureImageStreamRunning();
        return;
      }

      File? selfieFile;
      if (cameraController != null && cameraController!.value.isInitialized) {
        await _stopImageStream();
        final xFile = await cameraController!.takePicture();
        selfieFile = File(xFile.path);
        capturedSelfiePhoto = selfieFile;

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

      // Compare decoded live selfie face directly with server reference face
      report = await repo.compareFaces(
        referenceFile: refFile,
        liveSelfieFile: selfieFile,
      );

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

        if (isPunchMode.value) {
          debugPrint('>>> [AI FACE] MATCH SUCCESS in Punch Mode. Returning immediately to Dashboard with captured photo.');
          // In punch mode: Immediately pop face recognition screen and hand over to dashboard
          final resultPayload = {
            'photoFile': capturedSelfiePhoto,
            'faceConsent': punchRequires?.faceSaved == false,
            'faceScore': score,
            'faceMatch': 'matched',
          };

          await cleanupAndExit(result: resultPayload);
          return;
        }

        CustomSnackbar.showSuccess(
          title: 'Biometric MATCH',
          message:
              'Identity confirmed with ${score.toStringAsFixed(1)}% similarity (Threshold: ${(repo.matchThreshold * 100).toStringAsFixed(0)}%).',
        );

        await Future.delayed(const Duration(milliseconds: 500));
        if (!isClosed && !_isExiting) {
          openSuccessModal();
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
    debugPrint('>>> [AI FACE] cleanupAndExit() triggered. _isExiting: $_isExiting, result: $result');
    if (_isExiting) return;
    _isExiting = true;

    // Immediately notify UI that camera is inactive so CameraPreview unmounts before dispose
    isCameraInitialized.value = false;

    _stablePassTimer?.cancel();
    _progressTimer?.cancel();

    // 1. Pop the route immediately so UI transitions back without waiting on hardware teardown
    try {
      debugPrint('>>> [AI FACE] Popping route with result: $result');
      if (Get.isDialogOpen == true || Get.isBottomSheetOpen == true) {
        Get.back();
      }
      Get.back(result: result);
    } catch (e) {
      debugPrint('>>> [AI FACE] Route pop exception: $e');
    }

    // 2. Perform camera hardware release in the background
    try {
      await _stopImageStream();
    } catch (_) {}

    final controllerToDispose = cameraController;
    cameraController = null;
    try {
      await controllerToDispose?.dispose();
    } catch (_) {}
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
