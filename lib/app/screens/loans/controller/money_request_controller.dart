import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../api/exception_handler.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../main_shell/controller/session_me_controller.dart';
import '../model/money_request_model.dart';
import '../repo/money_request_repo.dart';

class MoneyRequestController extends GetxController {
  final MoneyRequestRepo repo;

  MoneyRequestController({required this.repo});

  // Module & Permission State
  final RxBool isLoansModuleActive = true.obs;
  final RxBool isAccessRestricted = false.obs;
  final RxString accessRestrictedMessage = ''.obs;

  // View & Action States
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isDetailsLoading = false.obs;
  final RxBool isCancelling = false.obs;

  // Filter Pill ('all', 'loan', 'advance', 'expense')
  final RxString selectedFilterKind = 'all'.obs;

  // Data Observables
  final RxList<MoneyRequestTypeModel> requestTypes =
      <MoneyRequestTypeModel>[].obs;
  final RxList<ExpenseCategoryModel> expenseCategories =
      <ExpenseCategoryModel>[].obs;
  final RxList<MoneyRequestItemModel> moneyRequests =
      <MoneyRequestItemModel>[].obs;
  final Rxn<MoneyRequestItemModel> selectedRequest =
      Rxn<MoneyRequestItemModel>();

  // Application Form Observables & Controllers
  final Rxn<MoneyRequestTypeModel> selectedFormType =
      Rxn<MoneyRequestTypeModel>();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController instalmentsController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController cancelReasonController = TextEditingController();
  final RxList<ExpenseDraftLine> draftExpenseLines = <ExpenseDraftLine>[].obs;

  // Scroll Controller
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    _checkModuleGate();
    loadLoansData();
  }

  @override
  void onClose() {
    amountController.dispose();
    instalmentsController.dispose();
    reasonController.dispose();
    cancelReasonController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  /// Verifies if 'loans_expenses' module is enabled in active subscription and money.view permission
  void _checkModuleGate() {
    if (Get.isRegistered<SessionMeController>()) {
      final session = Get.find<SessionMeController>();
      final hasModule = session.hasModule('loans_expenses');
      final hasPermission = session.hasPermission('money.view');
      isLoansModuleActive.value = hasModule && hasPermission;
      if (!isLoansModuleActive.value) {
        isAccessRestricted.value = true;
        accessRestrictedMessage.value = !hasModule
            ? 'The Loans & Advances module is not enabled for your company.'
            : 'You do not have permission to access Loans & Advances.';
      }
    }
  }

  /// Loads available types, categories, and historical requests
  Future<void> loadLoansData() async {
    _checkModuleGate();
    if (!isLoansModuleActive.value) return;

    try {
      isLoading.value = true;
      isAccessRestricted.value = false;
      accessRestrictedMessage.value = '';

      final results = await Future.wait([
        repo.fetchMoneyRequestTypes(),
        repo.fetchMoneyRequests(),
      ]);

      final metaResponse = results[0] as MoneyRequestTypesResponse?;
      if (metaResponse != null) {
        requestTypes.assignAll(metaResponse.types);
        expenseCategories.assignAll(metaResponse.categories);
        if (selectedFormType.value == null && metaResponse.types.isNotEmpty) {
          selectedFormType.value = metaResponse.types.first;
        }
      }

      final requests = results[1] as List<MoneyRequestItemModel>;
      moneyRequests.assignAll(requests);
    } on ApiException catch (e) {
      if (e.statusCode == 403) {
        isAccessRestricted.value = true;
        accessRestrictedMessage.value = e.message.isNotEmpty
            ? e.message
            : 'You do not have permission to access Loans & Advances.';
      }
    } catch (_) {
      // Clean fallback handled via CustomStateView
    } finally {
      isLoading.value = false;
    }
  }

  /// Filtered list based on selected kind tab
  List<MoneyRequestItemModel> get filteredRequests {
    if (selectedFilterKind.value == 'all') {
      return moneyRequests;
    }
    return moneyRequests
        .where((r) => r.typeKind.toLowerCase() == selectedFilterKind.value)
        .toList();
  }

  void setFilterKind(String kind) {
    selectedFilterKind.value = kind;
  }

  /// Fetches comprehensive details of a money request for modal audit
  Future<MoneyRequestItemModel?> fetchDetails(String id) async {
    try {
      isDetailsLoading.value = true;
      final details = await repo.fetchMoneyRequestDetails(id);
      selectedRequest.value = details;
      return details;
    } finally {
      isDetailsLoading.value = false;
    }
  }

  /// Adds a draft expense line in the creation modal
  void addExpenseLine({
    required String categoryId,
    required String categoryName,
    required String spentOn,
    required String amount,
    required String note,
    File? receiptFile,
  }) {
    draftExpenseLines.add(
      ExpenseDraftLine(
        categoryId: categoryId,
        categoryName: categoryName,
        spentOn: spentOn,
        amount: amount,
        note: note,
        receiptFile: receiptFile,
      ),
    );
  }

  void removeExpenseLine(int index) {
    if (index >= 0 && index < draftExpenseLines.length) {
      draftExpenseLines.removeAt(index);
    }
  }

  /// Submits new loan, advance or expense claim
  Future<bool> submitRequest() async {
    final type = selectedFormType.value;
    if (type == null) {
      CustomSnackbar.showError(message: 'Please select a request type.');
      return false;
    }

    // Validation for loan / advance amount
    if (!type.hasLines) {
      final amount = amountController.text.trim();
      if (amount.isEmpty || (double.tryParse(amount) ?? 0) <= 0) {
        CustomSnackbar.showError(
            message: 'Please enter a valid requested amount.');
        return false;
      }
    } else {
      if (draftExpenseLines.isEmpty) {
        CustomSnackbar.showError(
            message: 'Please add at least one expense line.');
        return false;
      }
    }

    int? instalments;
    if (type.repayable) {
      instalments = int.tryParse(instalmentsController.text.trim());
      if (instalments == null || instalments <= 0) {
        CustomSnackbar.showError(
            message: 'Please enter valid number of instalments.');
        return false;
      }
      if (type.maxInstalments != null && instalments > type.maxInstalments!) {
        CustomSnackbar.showError(
            message:
                'Instalments cannot exceed ${type.maxInstalments} months.');
        return false;
      }
    }

    try {
      isSubmitting.value = true;
      final result = await repo.submitMoneyRequest(
        typeId: type.id,
        amount: !type.hasLines ? amountController.text.trim() : null,
        instalments: instalments,
        reason: reasonController.text.trim(),
        expenseLines: type.hasLines ? draftExpenseLines.toList() : null,
      );

      if (result != null) {
        moneyRequests.insert(0, result);
        CustomSnackbar.showSuccess(
          message: 'Your money request was submitted for approval.',
        );
        resetForm();
        return true;
      }
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Cancels / withdraws pending request
  Future<bool> cancelRequest(String id) async {
    try {
      isCancelling.value = true;
      final success = await repo.cancelMoneyRequest(
        id,
        reason: cancelReasonController.text.trim(),
      );

      if (success) {
        final index = moneyRequests.indexWhere((r) => r.id == id);
        if (index != -1) {
          final old = moneyRequests[index];
          moneyRequests[index] = MoneyRequestItemModel(
            id: old.id,
            employeeName: old.employeeName,
            typeId: old.typeId,
            typeName: old.typeName,
            typeKind: old.typeKind,
            typeKindLabel: old.typeKindLabel,
            amount: old.amount,
            currency: old.currency,
            amountText: old.amountText,
            status: 'cancelled',
            statusLabel: 'Cancelled',
            tone: 'slate',
            source: old.source,
            sourceLabel: old.sourceLabel,
            reason: old.reason,
            requestedAt: old.requestedAt,
            repayable: old.repayable,
            instalments: old.instalments,
            instalmentAmount: old.instalmentAmount,
            instalmentText: old.instalmentText,
            balance: old.balance,
            balanceText: old.balanceText,
            payout: old.payout,
            closedOn: old.closedOn,
            cancelReason: cancelReasonController.text.trim(),
          );
        }
        cancelReasonController.clear();
        CustomSnackbar.showSuccess(
          message: 'Request was successfully withdrawn.',
        );
        return true;
      }
      return false;
    } finally {
      isCancelling.value = false;
    }
  }

  void resetForm() {
    amountController.clear();
    instalmentsController.clear();
    reasonController.clear();
    draftExpenseLines.clear();
  }
}
