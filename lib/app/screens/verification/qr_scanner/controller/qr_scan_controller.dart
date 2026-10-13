import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../routes/app_routes.dart';
import '../model/qr_scan_model.dart';
import '../repo/qr_scan_repo.dart';

class QRScanController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final QRScanRepo repo;

  QRScanController({required this.repo});

  // Observables
  final RxBool isScanning = true.obs;
  final RxBool isVerifying = false.obs;
  final RxBool torchEnabled = false.obs;
  final RxBool scanSuccess = false.obs;
  final RxBool cameraFacingFront = false.obs;
  final Rxn<EmployeeCardQrModel> verifiedCard = Rxn<EmployeeCardQrModel>();
  final RxString statusMessage =
      'Align the QR code on your employee badge within the frame'.obs;

  // Scanning laser animation
  late final AnimationController laserAnimationController;
  late final Animation<double> laserAnimation;

  // Manual entry controllers
  late final TextEditingController manualCodeController;
  late final FocusNode manualCodeFocusNode;

  // Auto-scan demo timer for seamless developer testing
  Timer? _autoDetectionDemoTimer;

  @override
  void onInit() {
    super.onInit();

    manualCodeController = TextEditingController();
    manualCodeFocusNode = FocusNode();

    // Laser sweep animation setup (sweeps from top to bottom continuously)
    laserAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    laserAnimation = Tween<double>(begin: 0.05, end: 0.95).animate(
      CurvedAnimation(
        parent: laserAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    laserAnimationController.repeat(reverse: true);
  }

  @override
  void onClose() {
    _autoDetectionDemoTimer?.cancel();
    laserAnimationController.dispose();
    manualCodeController.dispose();
    manualCodeFocusNode.dispose();
    super.onClose();
  }

  /// Toggles flashlight torch state
  void toggleTorch() {
    HapticFeedback.selectionClick();
    torchEnabled.toggle();
    CustomSnackbar.showInfo(
      message: torchEnabled.value ? 'Torch turned ON' : 'Torch turned OFF',
    );
  }

  /// Toggles camera lens between back and front
  void toggleCamera() {
    HapticFeedback.selectionClick();
    cameraFacingFront.toggle();
    CustomSnackbar.showInfo(
      message: cameraFacingFront.value
          ? 'Switched to Front Lens'
          : 'Switched to Rear Lens',
    );
  }

  /// Simulates instant scan detection for testing
  void simulateSampleScan() {
    handleBarcodeDetection(
      'AMS:EMP-0428:ORG-SOFTGENIE-88:SEC_VERIFIED',
    );
  }

  /// Primary barcode detection handler
  Future<void> handleBarcodeDetection(String rawCode) async {
    if (isVerifying.value || scanSuccess.value) return;

    try {
      isVerifying.value = true;
      isScanning.value = false;
      HapticFeedback.mediumImpact();
      statusMessage.value = 'Verifying cryptographic badge signature...';

      final result = await repo.verifyScannedCard(rawCode);

      if (result != null) {
        verifiedCard.value = result;
        scanSuccess.value = true;
        statusMessage.value = 'Identity Confirmed • ${result.employeeName}';
        HapticFeedback.heavyImpact();

        // Pause laser sweep on success
        laserAnimationController.stop();

        CustomSnackbar.showSuccess(
          title: 'Card Verified',
          message:
              'Badge #${result.employeeId} authenticated. Proceeding to facial biometrics.',
        );

        // Smooth transition to Step 2: Facial Biometric Recognition
        await Future.delayed(const Duration(milliseconds: 700));
        Get.toNamed(
          Routes.FACE_RECOGNITION,
          arguments: {'card': result},
        );
      } else {
        // Verification failed, resume scanning
        isScanning.value = true;
        statusMessage.value =
            'Verification failed. Re-align your employee badge.';
      }
    } finally {
      isVerifying.value = false;
    }
  }

  /// Submits manually entered card code
  void submitManualCode() {
    final code = manualCodeController.text.trim();
    if (code.isEmpty) {
      CustomSnackbar.showError(
        title: 'Badge ID Required',
        message: 'Please enter your Employee ID (e.g., EMP-0428).',
      );
      manualCodeFocusNode.requestFocus();
      return;
    }

    Get.back(); // Close bottom sheet
    handleBarcodeDetection(code);
  }
}
