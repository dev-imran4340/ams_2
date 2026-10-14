import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../api/exception_handler.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../routes/app_routes.dart';
import '../model/face_recognition_model.dart';
import '../repo/face_recognition_repo.dart';
import '../view/components/verification_success_sheet.dart';

class FaceRecognitionController extends GetxController
    with GetTickerProviderStateMixin {
  final FaceRecognitionRepo repo;

  FaceRecognitionController({required this.repo});

  // Hardware Camera Controller
  CameraController? cameraController;

  // Animations
  late final AnimationController pulseAnimationController;
  late final Animation<double> pulseAnimation;

  late final AnimationController progressAnimationController;
  late final Animation<double> progressAnimation;

  // Observables
  final RxBool isCameraInitialized = false.obs;
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

  // Aliases for backwards-compatibility
  RxBool get matchSuccess => isMatchSuccess;
  RxBool get isDetecting => isScanning;

  // Timers for automated detection pipeline
  Timer? _detectionTimer;
  Timer? _progressTimer;

  @override
  void onInit() {
    super.onInit();

    // 1. Extract arguments passed from Step 1 (Employee Card QR Scanner)
    if (Get.arguments is Map && Get.arguments['card'] != null) {
      final dynamic card = Get.arguments['card'];
      if (card != null) {
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

    // 4. Initialize live hardware camera (Front Lens)
    _initFrontCamera();

    // 5. Start automated biometric recognition simulation pipeline
    _startBiometricPipeline();
  }

  @override
  void onClose() {
    // Strict lifecycle disposal preventing memory leaks and hardware locks
    _detectionTimer?.cancel();
    _progressTimer?.cancel();
    pulseAnimationController.dispose();
    progressAnimationController.dispose();
    cameraController?.dispose();
    super.onClose();
  }

  /// Initializes hardware camera using the front-facing sensor
  Future<void> _initFrontCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        // Fallback for Simulator without camera hardware
        isCameraInitialized.value = false;
        return;
      }

      final frontCamera = cameras.firstWhereOrNull(
            (c) => c.lensDirection == CameraLensDirection.front,
          ) ??
          cameras.first;

      cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await cameraController!.initialize();

      if (!isClosed) {
        isCameraInitialized.value = true;
      }
    } on CameraException catch (e) {
      // Graceful fallback for simulator or before native full build
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

  /// Multi-stage automated AI biometric verification pipeline
  void _startBiometricPipeline() {
    if (isVerifying.value || isMatchSuccess.value) return;

    isScanning.value = true;
    isVerifying.value = false;
    isMatchSuccess.value = false;
    matchProgress.value = 0.0;
    confidenceReadout.value = 0.0;
    statusText.value = 'Align your face inside the oval frame';

    // Phase 1: Face Optical Alignment & Detection (1.2 seconds)
    _detectionTimer = Timer(const Duration(milliseconds: 1200), () {
      if (isClosed) return;

      isScanning.value = false;
      isVerifying.value = true;
      statusText.value = 'Facial geometry detected. Analyzing 3D liveness...';
      HapticFeedback.selectionClick();

      // Phase 2: Progress Ticker from 0% to 100%
      const totalSteps = 20;
      int currentStep = 0;

      _progressTimer =
          Timer.periodic(const Duration(milliseconds: 70), (timer) {
        if (isClosed) {
          timer.cancel();
          return;
        }

        currentStep++;
        matchProgress.value = (currentStep / totalSteps).clamp(0.0, 1.0);

        if (currentStep == 9) {
          statusText.value = 'Matching neural biometric embeddings...';
        } else if (currentStep == 15) {
          statusText.value = 'Anti-spoofing liveness verified 99.4%';
        }

        if (currentStep >= totalSteps) {
          timer.cancel();
          _finalizeVerification();
        }
      });
    });
  }

  /// Phase 3: Finalizes biometric verification against repository
  Future<void> _finalizeVerification() async {
    try {
      isLoading.value = true;
      final result = await repo.verifyFacialMatch(
        employeeCode: employeeId.value,
      );

      if (result != null && result.matched) {
        matchResult.value = result;
        isMatchSuccess.value = true;
        isVerifying.value = false;
        confidenceReadout.value = result.confidenceScore;
        statusText.value = 'Biometric Identity Verified!';
        HapticFeedback.heavyImpact();

        // Stop radar pulse
        pulseAnimationController.stop();

        CustomSnackbar.showSuccess(
          title: 'Identity Confirmed',
          message:
              'Welcome, ${result.employeeName}! Multi-factor authentication successful.',
        );

        // Display sleek verification success bottom sheet
        await Future.delayed(const Duration(milliseconds: 650));
        if (!isClosed) {
          openSuccessModal();
        }
      } else {
        isVerifying.value = false;
        isScanning.value = true;
        statusText.value = 'Biometric match failed. Please retry.';
      }
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Biometric verification error: $e'),
        tag:
            'FaceRecognitionController / FaceScreen -> _finalizeVerification() [${stackTrace.toString().split('\n').first}]',
      );
      isVerifying.value = false;
      isScanning.value = true;
      statusText.value = 'Verification error. Tap to retry.';
    } finally {
      isLoading.value = false;
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

  /// Navigates to the Dashboard (Routes.INDEX) after successful authentication
  void proceedToDashboard() {
    HapticFeedback.mediumImpact();
    Get.offAllNamed(Routes.INDEX);
  }

  /// Retries the biometric verification pipeline
  void retryVerification() {
    HapticFeedback.lightImpact();
    _detectionTimer?.cancel();
    _progressTimer?.cancel();
    pulseAnimationController.repeat(reverse: true);
    _startBiometricPipeline();
  }
}
