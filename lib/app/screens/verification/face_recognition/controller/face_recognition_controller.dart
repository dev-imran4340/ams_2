import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../routes/app_routes.dart';
import '../model/face_recognition_model.dart';
import '../repo/face_recognition_repo.dart';

class FaceRecognitionController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final FaceRecognitionRepo repo;

  FaceRecognitionController({required this.repo});

  // Observables
  final RxBool isDetecting = true.obs;
  final RxBool isVerifying = false.obs;
  final RxBool matchSuccess = false.obs;
  final RxDouble matchProgress = 0.0.obs;
  final RxString statusText = 'Align your face within the frame'.obs;
  final RxString employeeId = 'EMP-0428'.obs;
  final Rxn<FaceMatchResultModel> matchResult = Rxn<FaceMatchResultModel>();

  // Radar Pulse Animation
  late final AnimationController pulseAnimationController;
  late final Animation<double> pulseAnimation;

  // Pipeline Timers
  Timer? _detectionTimer;
  Timer? _progressTimer;

  @override
  void onInit() {
    super.onInit();

    // Read employeeId from arguments if passed from Step 1 (QR Scanner)
    if (Get.arguments is Map && Get.arguments['card'] != null) {
      final dynamic card = Get.arguments['card'];
      if (card != null) {
        employeeId.value = card.employeeId ?? 'EMP-0428';
      }
    }

    // Concentric radar pulse animation
    pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(
        parent: pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    pulseAnimationController.repeat(reverse: true);

    // Launch automated face recognition simulation pipeline
    _startBiometricPipeline();
  }

  @override
  void onClose() {
    _detectionTimer?.cancel();
    _progressTimer?.cancel();
    pulseAnimationController.dispose();
    super.onClose();
  }

  /// Automated multi-stage biometric matching pipeline
  void _startBiometricPipeline() {
    isDetecting.value = true;
    isVerifying.value = false;
    matchSuccess.value = false;
    matchProgress.value = 0.0;
    statusText.value = 'Align your face within the oval frame';

    // Phase 1: Face Detection (1.2 seconds)
    _detectionTimer = Timer(const Duration(milliseconds: 1200), () {
      if (isClosed) return;

      isDetecting.value = false;
      isVerifying.value = true;
      statusText.value = 'Facial geometry detected. Analyzing liveness...';
      HapticFeedback.selectionClick();

      // Phase 2: Progress ticker from 0% to 100%
      const totalSteps = 20;
      int currentStep = 0;

      _progressTimer = Timer.periodic(const Duration(milliseconds: 70), (timer) {
        if (isClosed) {
          timer.cancel();
          return;
        }

        currentStep++;
        matchProgress.value = (currentStep / totalSteps).clamp(0.0, 1.0);

        if (currentStep == 10) {
          statusText.value = 'Matching biometric embeddings...';
        } else if (currentStep == 16) {
          statusText.value = 'Anti-spoofing liveness verified 99.4%';
        }

        if (currentStep >= totalSteps) {
          timer.cancel();
          _finalizeVerification();
        }
      });
    });
  }

  /// Phase 3: Finalizes biometric verification against repo
  Future<void> _finalizeVerification() async {
    try {
      final result = await repo.verifyFaceBiometric(
        employeeId: employeeId.value,
      );

      if (result != null) {
        matchResult.value = result;
        matchSuccess.value = true;
        isVerifying.value = false;
        statusText.value = 'Biometric Identity Verified!';
        HapticFeedback.heavyImpact();

        CustomSnackbar.showSuccess(
          title: 'Identity Confirmed',
          message:
              'Welcome, ${result.employeeName}! Facial biometric match succeeded.',
        );

        // Success pause before navigating to Main Shell (Routes.INDEX)
        await Future.delayed(const Duration(milliseconds: 1000));
        if (!isClosed) {
          Get.offAllNamed(Routes.INDEX);
        }
      } else {
        isVerifying.value = false;
        statusText.value = 'Biometric match failed. Please retry.';
      }
    } catch (_) {
      isVerifying.value = false;
      statusText.value = 'Biometric verification error. Tap to retry.';
    }
  }

  /// Retries biometric verification pipeline
  void retryVerification() {
    HapticFeedback.lightImpact();
    _detectionTimer?.cancel();
    _progressTimer?.cancel();
    _startBiometricPipeline();
  }
}
