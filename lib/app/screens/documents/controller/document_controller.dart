import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';

import '../../../core/widgets/custom_snackbar.dart';
import '../../../routes/app_routes.dart';
import '../model/document_model.dart';
import '../repo/document_repo.dart';
import '../view/components/letter_details_bottom_sheet.dart';

class DocumentController extends GetxController {
  final DocumentRepo repo;

  DocumentController({required this.repo});

  // State Observables
  final RxBool isLoading = false.obs;
  final RxBool isDetailsLoading = false.obs;
  final RxBool isLetterDetailsLoading = false.obs;
  final RxBool isSubmitting = false.obs;

  /// Selected tab: 0 = Policies, 1 = My Files, 2 = Letters
  final RxInt selectedTabIndex = 0.obs;

  /// Central employee repository model
  final Rxn<MeDocumentsModel> meDocuments = Rxn<MeDocumentsModel>();

  /// Published company documents / handbook list
  final RxList<CompanyDocumentListItemModel> companyDocuments =
      <CompanyDocumentListItemModel>[].obs;

  /// Currently viewed policy details
  final Rxn<CompanyDocumentDetailsModel> selectedDocument =
      Rxn<CompanyDocumentDetailsModel>();

  /// Currently viewed letter details (GET /letters/{id})
  final Rxn<IssuedLetterItemModel> selectedLetter =
      Rxn<IssuedLetterItemModel>();

  /// Tracks active downloading file IDs for inline button loaders
  final RxSet<String> downloadingFileIds = <String>{}.obs;

  // Letter Request Form
  final TextEditingController purposeController = TextEditingController();
  final Rxn<RequestableLetterItemModel> selectedTemplate =
      Rxn<RequestableLetterItemModel>();

  @override
  void onInit() {
    super.onInit();
    _handleArguments();
    loadAllDocuments();
  }

  void _handleArguments() {
    final args = Get.arguments;
    if (args is Map) {
      if (args['tab'] is int) {
        selectedTabIndex.value = args['tab'] as int;
      }
      if (args['policyId'] is String) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          loadPolicyDetails(args['policyId'] as String);
        });
      }
      if (args['letterId'] is String) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          openLetterDetailsById(args['letterId'] as String);
        });
      }
    }
  }

  /// Loads both /me/documents and /company-documents concurrently
  Future<void> loadAllDocuments({bool isRefresh = false}) async {
    try {
      isLoading.value = true;
      final results = await Future.wait([
        repo.fetchMeDocuments(),
        repo.fetchCompanyDocuments(),
      ]);

      meDocuments.value = results[0] as MeDocumentsModel;
      companyDocuments.assignAll(results[1] as List<CompanyDocumentListItemModel>);
    } finally {
      isLoading.value = false;
    }
  }

  /// Switches active tab (0: Policies, 1: My Files, 2: Letters)
  void switchTab(int index) {
    if (selectedTabIndex.value == index) return;
    HapticFeedback.selectionClick();
    selectedTabIndex.value = index;
  }

  /// Fetches single policy details with version notes/content
  Future<void> loadPolicyDetails(String id) async {
    try {
      isDetailsLoading.value = true;
      final details = await repo.fetchCompanyDocumentDetails(id);
      if (details != null) {
        selectedDocument.value = details;
      }
    } finally {
      isDetailsLoading.value = false;
    }
  }

  /// Navigates to Policy Details screen with target policy ID
  void openPolicyDetails(String id) {
    HapticFeedback.lightImpact();
    loadPolicyDetails(id);
    Get.toNamed(
      Routes.POLICY_DETAILS,
      arguments: {'policyId': id},
    );
  }

  /// Submits digital acknowledgment for the policy
  Future<bool> acknowledgePolicy(String id) async {
    if (isSubmitting.value) return false;

    try {
      isSubmitting.value = true;
      HapticFeedback.mediumImpact();
      final updated = await repo.acknowledgePolicy(id);

      if (updated != null) {
        selectedDocument.value = updated;

        // Optimistically update item in companyDocuments list
        final index = companyDocuments.indexWhere((p) => p.id == id);
        if (index != -1) {
          companyDocuments[index] = companyDocuments[index].copyWith(
            acknowledged: true,
          );
        }

        // Optimistically update in policiesToAccept
        final currentMe = meDocuments.value;
        if (currentMe != null) {
          final updatedPolicies = currentMe.policiesToAccept.map((p) {
            if (p.id == id) {
              return p.copyWith(acknowledged: true);
            }
            return p;
          }).toList();

          meDocuments.value = MeDocumentsModel(
            files: currentMe.files,
            expiring: currentMe.expiring,
            policiesToAccept: updatedPolicies,
            letters: currentMe.letters,
            letterRequests: currentMe.letterRequests,
            requestableLetters: currentMe.requestableLetters,
          );
        }

        CustomSnackbar.showSuccess(
          title: 'Policy Acknowledged',
          message: 'You have acknowledged and accepted this policy version.',
        );
        return true;
      }
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Submits a request for an official letter
  Future<bool> submitLetterRequest() async {
    final template = selectedTemplate.value;
    final purpose = purposeController.text.trim();

    if (template == null) {
      CustomSnackbar.showError(
        title: 'Select Letter',
        message: 'Please choose the type of letter you wish to request.',
      );
      return false;
    }

    if (purpose.isEmpty) {
      CustomSnackbar.showError(
        title: 'Provide Purpose',
        message: 'Please specify the reason/purpose for this letter.',
      );
      return false;
    }

    try {
      isSubmitting.value = true;
      HapticFeedback.mediumImpact();
      final result = await repo.requestLetter(
        templateId: template.id,
        purpose: purpose,
      );

      if (result != null) {
        // Clear input form
        purposeController.clear();
        selectedTemplate.value = null;

        // Optimistically append to letterRequests
        final currentMe = meDocuments.value;
        if (currentMe != null) {
          final updatedRequests = [result, ...currentMe.letterRequests];
          meDocuments.value = MeDocumentsModel(
            files: currentMe.files,
            expiring: currentMe.expiring,
            policiesToAccept: currentMe.policiesToAccept,
            letters: currentMe.letters,
            letterRequests: updatedRequests,
            requestableLetters: currentMe.requestableLetters,
          );
        }

        Get.back(); // Dismiss sheet
        CustomSnackbar.showSuccess(
          title: 'Request Submitted',
          message: 'Your letter request has been sent for approval.',
        );
        return true;
      }
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Opens Letter details modal and fetches complete audit & body via GET /letters/{id}
  Future<void> openLetterDetails(IssuedLetterItemModel letter) async {
    await openLetterDetailsById(letter.id, initial: letter);
  }

  /// Fetches single official letter details by ID and shows bottom sheet
  Future<void> openLetterDetailsById(
    String letterId, {
    IssuedLetterItemModel? initial,
  }) async {
    HapticFeedback.lightImpact();

    // Populate initial state if available
    if (initial != null) {
      selectedLetter.value = initial;
    }

    // Open bottom sheet
    Get.bottomSheet(
      LetterDetailsBottomSheet(letter: initial),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );

    // Fetch fresh details with full HTML body from API (GET /letters/{id})
    try {
      isLetterDetailsLoading.value = true;
      final fresh = await repo.fetchLetterDetails(letterId);
      if (fresh != null) {
        selectedLetter.value = fresh;
      }
    } finally {
      isLetterDetailsLoading.value = false;
    }
  }

  /// Downloads and opens an official issued letter PDF
  Future<void> downloadAndOpenLetter(String letterId, String reference) async {
    if (downloadingFileIds.contains(letterId)) return;

    try {
      downloadingFileIds.add(letterId);
      final file = await repo.downloadLetterPdf(letterId, reference: reference);
      if (file != null && await file.exists()) {
        final result = await OpenFilex.open(file.path);
        if (result.type != ResultType.done) {
          CustomSnackbar.showInfo(
            message: 'Letter downloaded to ${file.path}',
          );
        }
      }
    } finally {
      downloadingFileIds.remove(letterId);
    }
  }

  /// Downloads and opens personal document file
  Future<void> downloadAndOpenDocumentFile(String fileId, String fileName) async {
    if (downloadingFileIds.contains(fileId)) return;

    try {
      downloadingFileIds.add(fileId);
      final file = await repo.downloadDocumentFile(fileId, fileName: fileName);
      if (file != null && await file.exists()) {
        final result = await OpenFilex.open(file.path);
        if (result.type != ResultType.done) {
          CustomSnackbar.showInfo(
            message: 'File saved to ${file.path}',
          );
        }
      }
    } finally {
      downloadingFileIds.remove(fileId);
    }
  }

  /// Downloads and opens company document version file
  Future<void> downloadAndOpenPolicyFile(
    String id,
    int version,
    String fileName,
  ) async {
    final key = '$id-$version';
    if (downloadingFileIds.contains(key)) return;

    try {
      downloadingFileIds.add(key);
      final file = await repo.downloadCompanyPolicyFile(
        id,
        version,
        fileName: fileName,
      );
      if (file != null && await file.exists()) {
        final result = await OpenFilex.open(file.path);
        if (result.type != ResultType.done) {
          CustomSnackbar.showInfo(
            message: 'File downloaded to ${file.path}',
          );
        }
      }
    } finally {
      downloadingFileIds.remove(key);
    }
  }

  @override
  void onClose() {
    purposeController.dispose();
    super.onClose();
  }
}
