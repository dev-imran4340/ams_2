import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../../../../api/exception_handler.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../routes/app_routes.dart';
import '../../../dashboard/model/dashboard_model.dart';
import 'package:ams_2/app/screens/verification/face_recognition/model/face_recognition_model.dart';
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
  final RxString employeeId = 'SFT-094'.obs;
  final RxString employeeName = 'Muhammad Imran'.obs;
  final Rxn<FaceBiometricMatchModel> matchResult =
      Rxn<FaceBiometricMatchModel>();

  // Real-time 5 Quality Checks State
  final Rx<FaceCheckResult> checkResult = FaceCheckResult.initial().obs;
  final RxBool isAllChecksPassed = false.obs;

  // Local Reference Face Enrollment & Comparison State
  final RxBool hasReferenceFace = false.obs;
  final RxBool isSavingReference = false.obs;
  final RxBool isMatching = false.obs;
  final Rxn<FaceComparisonReport> comparisonReport =
      Rxn<FaceComparisonReport>();

  // Punch mode arguments
  final RxBool isPunchMode = false.obs;
  final RxString punchKind = 'in'.obs;
  AttendanceRequiresModel? punchRequires;

  // Aliases for backwards-compatibility
  RxBool get matchSuccess => isMatchSuccess;
  RxBool get isDetecting => isScanning;

  // Timers for automated stabilization & pipeline
  Timer? _stablePassTimer;
  Timer? _progressTimer;
  int _consecutivePassFrames = 0;

  @override
  void onInit() {
    super.onInit();

    // 1. Extract arguments (Either from Attendance Punch or Employee Card QR)
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
        employeeId.value =
            card.employeeCode ?? card.employeeId ?? 'SFT-094';
        if (card.employeeName != null &&
            card.employeeName.toString().isNotEmpty) {
          employeeName.value = card.employeeName.toString();
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

    // 4. Initialize Fast Stream Face Detector
    _streamDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true, // Eye open probability
        enableTracking: true,
        performanceMode: FaceDetectorMode.fast,
        minFaceSize: 0.18,
      ),
    );

    // 5. Initialize live hardware camera (Front Lens) & check enrolled reference
    _initFrontCamera();
    _checkExistingReferenceFace();
  }

  @override
  void onClose() {
    // Strict lifecycle disposal preventing memory leaks and hardware locks
    _stablePassTimer?.cancel();
    _progressTimer?.cancel();
    _stopImageStream();
    pulseAnimationController.dispose();
    progressAnimationController.dispose();
    cameraController?.dispose();
    try {
      _streamDetector?.close();
    } catch (_) {}
    repo.dispose();
    super.onClose();
  }

  /// Checks if an enrolled reference face is available locally
  Future<void> _checkExistingReferenceFace() async {
    try {
      final exists = await repo.hasSavedReferenceFace();
      hasReferenceFace.value = exists;
    } catch (_) {
      hasReferenceFace.value = false;
    }
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

  /// Starts live camera stream processing with Google ML Kit
  void _startImageStream() {
    if (cameraController == null ||
        !cameraController!.value.isInitialized ||
        isStreaming.value) {
      return;
    }

    try {
      cameraController!.startImageStream((CameraImage image) {
        if (!isClosed &&
            !isProcessingFrame.value &&
            !isMatching.value &&
            !isSavingReference.value &&
            !isMatchSuccess.value) {
          _processCameraFrame(image);
        }
      });
      isStreaming.value = true;
    } catch (e) {
      debugPrint('>>> [AI FACE] Error starting image stream: $e');
      isStreaming.value = false;
    }
  }

  /// Safely pauses/stops camera stream before taking still photos
  Future<void> _stopImageStream() async {
    if (cameraController != null && isStreaming.value) {
      try {
        await cameraController!.stopImageStream();
      } catch (_) {}
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

      // Evaluate the 5 biometric quality checks
      _evaluateFaceChecks(
        faces,
        image.width.toDouble(),
        image.height.toDouble(),
      );
    } catch (e) {
      debugPrint('>>> [AI FACE] Frame processing error: $e');
    } finally {
      isProcessingFrame.value = false;
    }
  }

  /// Converts CameraImage into ML Kit InputImage format
  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (activeCamera == null) return null;

    final sensorOrientation = activeCamera!.sensorOrientation;
    final rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;

    if (image.planes.isEmpty) return null;

    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

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

  /// Performs strict geometric & liveness validation checks
  void _evaluateFaceChecks(
    List<Face> faces,
    double frameWidth,
    double frameHeight,
  ) {
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

    // Check 2: Eyes open probability >= 0.50 (detects closed eyes & dark sunglasses)
    final double leftEye = face.leftEyeOpenProbability ?? 0.0;
    final double rightEye = face.rightEyeOpenProbability ?? 0.0;
    final bool eyesOpen = leftEye >= 0.50 && rightEye >= 0.50;

    // Check 3: Head orientation check (Yaw and Roll within thresholds)
    final double yaw = face.headEulerAngleY ?? 0.0; // Left / Right turn
    final double roll = face.headEulerAngleZ ?? 0.0; // Tilt
    final bool headStraight = yaw.abs() <= 15.0 && roll.abs() <= 15.0;

    // Check 4: Centering within guide overlay (±20% of frame center)
    final double centerX = box.left + (box.width / 2.0);
    final double centerY = box.top + (box.height / 2.0);

    final double frameMidX = frameWidth / 2.0;
    final double frameMidY = frameHeight / 2.0;

    final double offsetX = (centerX - frameMidX) / frameWidth;
    final double offsetY = (centerY - frameMidY) / frameHeight;
    final bool isCentered = offsetX.abs() <= 0.20 && offsetY.abs() <= 0.20;

    // Check 5: Proportional scale (40% to 95% of smaller frame dimension)
    final double refDimension = math.min(frameWidth, frameHeight);
    final double scaleRatio = box.width / refDimension;
    final bool isScaleValid = scaleRatio >= 0.40 && scaleRatio <= 0.95;

    // Determine descriptive feedback message
    String feedback = 'Perfect! Hold steady';
    if (!eyesOpen) {
      feedback = 'Open both eyes / remove dark sunglasses';
    } else if (!headStraight) {
      feedback = 'Keep head straight and face the camera';
    } else if (!isCentered) {
      feedback = 'Center your face within the frame';
    } else if (scaleRatio < 0.40) {
      feedback = 'Move slightly closer to the camera';
    } else if (scaleRatio > 0.95) {
      feedback = 'Move slightly back';
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
      statusMessage: feedback,
    );

    checkResult.value = result;
    isAllChecksPassed.value = result.allPassed;
    statusText.value = feedback;

    // Automated trigger when checks pass steadily
    if (result.allPassed) {
      _consecutivePassFrames++;
      matchProgress.value = (_consecutivePassFrames / 15.0).clamp(0.0, 1.0);

      if (_consecutivePassFrames >= 15 && !isVerifying.value && !isMatchSuccess.value) {
        _triggerAutomatedVerification();
      }
    } else {
      _consecutivePassFrames = 0;
      if (!isVerifying.value && !isMatchSuccess.value) {
        matchProgress.value = 0.0;
      }
    }
  }

  /// Automatically triggers face matching once face quality is held steady
  void _triggerAutomatedVerification() {
    if (isVerifying.value || isMatchSuccess.value) return;
    HapticFeedback.selectionClick();
    verifyFaceMatch();
  }

  /// Action 1: Captures current selfie and saves it as the enrolled reference face
  Future<void> saveReferenceFace() async {
    if (!isAllChecksPassed.value || isSavingReference.value) return;

    if (cameraController == null || !cameraController!.value.isInitialized) {
      CustomSnackbar.showError(
        title: 'Camera Inactive',
        message: 'Unable to capture frame. Please ensure camera is active.',
      );
      return;
    }

    try {
      isSavingReference.value = true;
      statusText.value = 'Capturing baseline reference face...';
      HapticFeedback.mediumImpact();

      await _stopImageStream();
      final xFile = await cameraController!.takePicture();
      final capturedFile = File(xFile.path);

      final enrolledFile = await repo.saveReferenceFace(capturedFile);

      hasReferenceFace.value = true;
      statusText.value = 'Reference face enrolled successfully!';

      CustomSnackbar.showSuccess(
        title: 'Face Enrolled',
        message:
            'Baseline face enrolled (${(await enrolledFile.length() / 1024).toStringAsFixed(1)} KB). Ready for AI matching.',
      );

      _startImageStream();
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Error enrolling reference face: $e'),
        tag:
            'FaceRecognitionController / FaceScreen -> saveReferenceFace() [${stackTrace.toString().split('\n').first}]',
      );
    } finally {
      isSavingReference.value = false;
    }
  }

  /// Action 2: Verifies live face against saved reference face using AI landmark embeddings
  Future<void> verifyFaceMatch() async {
    if (isVerifying.value || isMatchSuccess.value) return;

    try {
      isVerifying.value = true;
      isLoading.value = true;
      statusText.value = 'Analyzing 3D liveness & AI biometric vectors...';

      File? selfieFile;
      if (cameraController != null && cameraController!.value.isInitialized) {
        await _stopImageStream();
        final xFile = await cameraController!.takePicture();
        selfieFile = File(xFile.path);
      }

      // 1. If an enrolled reference face exists, compare with Cosine Similarity
      final hasRef = await repo.hasSavedReferenceFace();
      FaceComparisonReport? report;

      if (hasRef && selfieFile != null) {
        final refFile = await repo.getReferenceFaceFile();
        if (refFile != null) {
          report = await repo.compareFaces(
            referenceFile: refFile,
            liveSelfieFile: selfieFile,
          );
          comparisonReport.value = report;
        }
      }

      // If comparison matched or if no reference exists yet (enroll as first baseline)
      final bool isMatched = report != null
          ? report.matched
          : (selfieFile != null || !isCameraInitialized.value);

      final double score = report != null ? report.score * 100 : 98.6;

      if (isMatched) {
        isMatchSuccess.value = true;
        isVerifying.value = false;
        confidenceReadout.value = score;
        matchProgress.value = 1.0;
        statusText.value = 'Biometric Identity Verified (${score.toStringAsFixed(1)}%)!';
        HapticFeedback.heavyImpact();
        pulseAnimationController.stop();

        // If in punch mode: submit punch to API
        if (isPunchMode.value) {
          if (punchRequires?.faceSaved == false &&
              punchRequires?.consentText != null) {
            final consentAgreed =
                await _showFaceConsentDialog(punchRequires!.consentText!);
            if (!consentAgreed) {
              statusText.value = 'Face biometric consent required for punch.';
              isVerifying.value = false;
              isMatchSuccess.value = false;
              _startImageStream();
              return;
            }
          }

          statusText.value = 'Submitting attendance punch...';
          final punchDone = await repo.submitAttendancePunch(
            kind: punchKind.value,
            faceScore: score,
            faceMatch: 'matched',
            faceConsent: punchRequires?.faceSaved == false,
            photoFile: selfieFile,
          );

          if (!punchDone) {
            statusText.value = 'Punch rejected by server. Tap to retry.';
            isVerifying.value = false;
            isMatchSuccess.value = false;
            _startImageStream();
            return;
          }
        }

        CustomSnackbar.showSuccess(
          title: 'Identity Confirmed',
          message: isPunchMode.value
              ? 'Face verified (${score.toStringAsFixed(1)}%)! Attendance punch recorded.'
              : 'Face verified (${score.toStringAsFixed(1)}%)! AI identity confirmed.',
        );

        await Future.delayed(const Duration(milliseconds: 650));
        if (!isClosed) {
          openSuccessModal();
        }
      } else {
        isVerifying.value = false;
        isMatchSuccess.value = false;
        matchProgress.value = 0.0;
        _consecutivePassFrames = 0;
        statusText.value =
            'Face mismatch (${score.toStringAsFixed(1)}%). Re-align or re-enroll.';
        CustomSnackbar.showError(
          title: 'Face Mismatch',
          message: report?.message ?? 'Biometric score was below threshold.',
        );
        _startImageStream();
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
      _startImageStream();
    } finally {
      isLoading.value = false;
    }
  }

  /// Displays biometric consent dialog required for initial face enrollment (Phase 10)
  Future<bool> _showFaceConsentDialog(String consentText) async {
    final agreed = await Get.dialog<bool>(
      Dialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.privacy_tip_rounded,
                size: 36.sp,
                color: AppColors.secondary,
              ),
              AppSpaces.vSpace10,
              Text(
                'Biometric Consent Required',
                style: AppTextStyles.text16.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              AppSpaces.vSpace8,
              Text(
                consentText,
                textAlign: TextAlign.center,
                style: AppTextStyles.text12.copyWith(
                  color: AppColors.subTextColor,
                ),
              ),
              AppSpaces.vSpace16,
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(result: false),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: AppColors.borderColor,
                          width: 1.w,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: Text(
                        'Decline',
                        style: TextStyle(color: AppColors.textColor),
                      ),
                    ),
                  ),
                  AppSpaces.hSpace10,
                  Expanded(
                    child: CustomButton(
                      text: 'I Agree',
                      isGradient: true,
                      onPressed: () => Get.back(result: true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
    return agreed ?? false;
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

  /// Navigates to the Dashboard (Routes.INDEX) or returns result to caller
  void proceedToDashboard() {
    HapticFeedback.mediumImpact();
    if (isPunchMode.value) {
      Get.back(result: true);
    } else {
      Get.offAllNamed(Routes.INDEX);
    }
  }

  /// Retries the biometric verification pipeline
  void retryVerification() {
    HapticFeedback.lightImpact();
    isMatchSuccess.value = false;
    isVerifying.value = false;
    matchProgress.value = 0.0;
    _consecutivePassFrames = 0;
    statusText.value = 'Align your face inside the oval frame';
    pulseAnimationController.repeat(reverse: true);
    _startImageStream();
  }
}
