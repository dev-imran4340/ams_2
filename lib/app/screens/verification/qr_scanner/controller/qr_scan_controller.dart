import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../api/exception_handler.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../routes/app_routes.dart';
import '../model/qr_scan_model.dart';
import '../repo/qr_scan_repo.dart';
import '../view/components/manual_code_bottom_sheet.dart';

class QRScanController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final QRScanRepo repo;

  QRScanController({required this.repo});

  // Hardware Scanner Controller
  late final MobileScannerController scannerController;

  // Animation Controller for smooth laser sweep line
  late final AnimationController laserAnimationController;
  late final Animation<double> laserAnimation;

  // Manual code input controllers
  late final TextEditingController manualCodeController;
  late final FocusNode manualCodeFocusNode;

  // Observables
  final RxBool isScanning = true.obs;
  final RxBool isProcessing = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isTorchOn = false.obs;
  final RxBool isFrontCamera = false.obs;
  final RxBool scanSuccess = false.obs;
  final RxString scanFeedbackMessage =
      'Align employee card QR inside the box'.obs;
  final Rxn<EmployeeCardQrModel> verifiedCard = Rxn<EmployeeCardQrModel>();

  // Aliases for component & test compatibility
  RxString get statusMessage => scanFeedbackMessage;
  RxBool get torchEnabled => isTorchOn;
  RxBool get cameraFacingFront => isFrontCamera;
  RxBool get isVerifying => isProcessing;

  @override
  void onInit() {
    super.onInit();

    // 1. Initialize text editing & focus node
    manualCodeController = TextEditingController();
    manualCodeFocusNode = FocusNode();

    // 2. Initialize hardware MobileScannerController
    scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      detectionTimeoutMs: 300,
      facing: CameraFacing.back,
      torchEnabled: false,
    );

    // 3. Initialize laser line sweep animation (sweeps top-to-bottom continuously)
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
    // Strict resource disposal contract to prevent camera & animation memory leaks
    laserAnimationController.dispose();
    manualCodeController.dispose();
    manualCodeFocusNode.dispose();
    scannerController.dispose();
    super.onClose();
  }

  /// Debounced QR Barcode detection callback from MobileScanner
  void onBarcodeDetected(BarcodeCapture capture) {
    if (isProcessing.value || !isScanning.value || scanSuccess.value) {
      return;
    }

    if (capture.barcodes.isEmpty) return;

    final rawPayload = capture.barcodes.first.rawValue?.trim();
    if (rawPayload == null || rawPayload.isEmpty) return;

    _processCardPayload(rawPayload);
  }

  /// Main card payload verification pipeline with lock & loading safety
  Future<void> _processCardPayload(String rawPayload) async {
    if (isProcessing.value || scanSuccess.value) return;

    try {
      // Lock scanner to prevent duplicate triggers
      isProcessing.value = true;
      isLoading.value = true;
      isScanning.value = false;

      HapticFeedback.mediumImpact();
      scanFeedbackMessage.value = 'Verifying card cryptographic signature...';

      final result = await repo.verifyCardPayload(rawPayload);

      if (result != null && result.isValid) {
        verifiedCard.value = result;
        scanSuccess.value = true;
        scanFeedbackMessage.value = 'Identity Confirmed • ${result.employeeCode}';
        HapticFeedback.heavyImpact();

        // Pause laser sweep on success
        laserAnimationController.stop();

        CustomSnackbar.showSuccess(
          title: 'Card Verified',
          message:
              'Badge #${result.employeeCode} verified. Proceeding to face recognition.',
        );

        // Smooth transition to Step 2: Facial Biometric Recognition
        await Future.delayed(const Duration(milliseconds: 650));
        Get.toNamed(
          Routes.FACE_RECOGNITION,
          arguments: {'card': result},
        );
      } else {
        // Verification failed, unlock scanning for retry
        isScanning.value = true;
        scanFeedbackMessage.value =
            'Verification failed. Re-align employee card.';
      }
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Error during card verification: $e'),
        tag:
            'QRScanController / QRScannerScreen -> _processCardPayload() [${stackTrace.toString().split('\n').first}]',
      );
      isScanning.value = true;
      scanFeedbackMessage.value = 'Verification error. Please scan again.';
    } finally {
      isLoading.value = false;
      isProcessing.value = false;
    }
  }

  /// Toggles flashlight torch state on camera
  Future<void> toggleTorch() async {
    try {
      HapticFeedback.selectionClick();
      await scannerController.toggleTorch();
      isTorchOn.toggle();
      CustomSnackbar.showInfo(
        message: isTorchOn.value ? 'Torch turned ON' : 'Torch turned OFF',
      );
    } catch (_) {
      // Toggle state fallback for UI feedback
      isTorchOn.toggle();
    }
  }

  /// Camera is locked to rear lens for card QR badge scanning
  Future<void> switchCamera() async {
    HapticFeedback.lightImpact();
    CustomSnackbar.showInfo(
      message: 'Card QR scanning is optimized for the rear camera.',
    );
  }

  /// Opens the manual code fallback bottom sheet modal
  void openManualCodeModal(BuildContext context) {
    HapticFeedback.lightImpact();
    Get.bottomSheet(
      const ManualCodeBottomSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  /// Submits manually entered card code
  void submitManualCode() {
    final code = manualCodeController.text.trim();
    if (code.isEmpty) {
      CustomSnackbar.showError(
        title: 'Badge ID Required',
        message: 'Please enter your Employee Code (e.g. SFT-094).',
      );
      manualCodeFocusNode.requestFocus();
      return;
    }

    // Dismiss bottom sheet and execute verification
    Get.back();
    _processCardPayload(code);
  }

  /// Simulates instant scan detection for testing in simulator or demo environments
  void simulateSampleScan() {
    _processCardPayload('AMS:SFT-094:ORG-102:SEC-TOKEN-8849');
  }

  /// Backward-compatible alias
  void toggleCamera() => switchCamera();
  void handleBarcodeDetection(String rawCode) => _processCardPayload(rawCode);
}
