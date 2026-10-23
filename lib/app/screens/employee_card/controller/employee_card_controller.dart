import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/widgets/custom_snackbar.dart';
import '../model/employee_card_model.dart';
import '../repo/employee_card_repo.dart';

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

  /// Downloads the official digital ID card PDF document and opens it
  /// directly in the Android or iOS native system PDF viewer.
  Future<void> downloadCardPdf() async {
    HapticFeedback.mediumImpact();
    final card = cardData.value;
    if (card == null) {
      CustomSnackbar.showError(
        title: 'Download Failed',
        message: 'Employee card credentials are not loaded yet.',
      );
      return;
    }

    isPdfLoading.value = true;
    try {
      final file = await repo.prepareCardPdfFile(card);
      if (file != null && await file.exists()) {
        pdfPath.value = file.path;

        // Open directly in Android / iOS native default PDF application
        final openResult = await OpenFilex.open(
          file.path,
          type: 'application/pdf',
        );

        if (openResult.type != ResultType.done &&
            card.pdfDocumentUrl.isNotEmpty &&
            card.pdfDocumentUrl.startsWith('http')) {
          await launchUrl(
            Uri.parse(card.pdfDocumentUrl),
            mode: LaunchMode.externalApplication,
          );
        }

        CustomSnackbar.showSuccess(
          title: 'PDF Downloaded',
          message: 'Official ID Card for ${card.name} saved and opened in PDF viewer.',
        );
      } else {
        if (card.pdfDocumentUrl.isNotEmpty &&
            card.pdfDocumentUrl.startsWith('http')) {
          await launchUrl(
            Uri.parse(card.pdfDocumentUrl),
            mode: LaunchMode.externalApplication,
          );
        }
      }
    } catch (e) {
      CustomSnackbar.showError(
        title: 'Error Opening PDF',
        message: 'Could not launch native PDF viewer: $e',
      );
    } finally {
      isPdfLoading.value = false;
    }
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
