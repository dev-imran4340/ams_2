import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/widgets/custom_snackbar.dart';
import '../model/employee_card_model.dart';
import '../repo/employee_card_repo.dart';
import '../view/components/in_app_card_pdf_viewer.dart';

class EmployeeCardController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final EmployeeCardRepo repo;

  EmployeeCardController({required this.repo});

  // Observables
  final RxBool isLoading = false.obs;
  final RxBool isFlipped = false.obs;
  final RxBool isPdfLoading = false.obs;
  final Rxn<EmployeeCardDetails> cardData = Rxn<EmployeeCardDetails>();
  final RxString pdfPath = ''.obs;

  // 3D Flip Animation Controller
  late final AnimationController flipAnimationController;
  late final Animation<double> flipAnimation;

  @override
  void onInit() {
    super.onInit();

    flipAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: flipAnimationController,
        curve: Curves.easeInOutCubic,
      ),
    );

    loadCardData();
  }

  /// Loads official digital ID card credentials from repository
  Future<void> loadCardData() async {
    try {
      isLoading.value = true;
      final result = await repo.fetchCardDetails();
      if (result != null) {
        cardData.value = result;
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Triggers 3D Y-axis card flip animation
  void flipCard() {
    HapticFeedback.selectionClick();
    if (isFlipped.value) {
      flipAnimationController.reverse();
    } else {
      flipAnimationController.forward();
    }
    isFlipped.toggle();
  }

  /// Opens the full-height In-App PDF Viewer modal
  void openPdfViewer(BuildContext context) {
    HapticFeedback.lightImpact();
    Get.bottomSheet(
      const InAppCardPdfViewer(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
    );
  }

  /// Simulates sharing/exporting the verified identity token
  void shareCard() {
    HapticFeedback.mediumImpact();
    final card = cardData.value;
    if (card != null) {
      Clipboard.setData(ClipboardData(text: card.qrPayload));
      CustomSnackbar.showSuccess(
        title: 'Identity Token Copied',
        message: 'Encrypted payload for ${card.employeeId} copied to clipboard.',
      );
    }
  }

  /// Simulates NFC contactless broadcast
  void simulateNfcTap() {
    HapticFeedback.heavyImpact();
    CustomSnackbar.showInfo(
      message: 'NFC Transceiver Ready: Hold phone near reader for instant contactless punch.',
    );
  }

  @override
  void onClose() {
    // Guaranteed zero-memory-leak disposal contract
    flipAnimationController.dispose();
    super.onClose();
  }
}
