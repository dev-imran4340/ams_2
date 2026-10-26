import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../index/controller/index_controller.dart';
import '../model/approval_model.dart';
import '../model/leave_model.dart';
import '../repo/leave_repo.dart';
import '../view/components/apply_leave_bottom_sheet.dart';
import '../view/components/approval_details_bottom_sheet.dart';

class LeaveController extends GetxController {
  final LeaveRepo repo;

  LeaveController({required this.repo});

  // Observables
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isActionLoading = false.obs;
  final RxBool isLoadingDetails = false.obs;

  /// Active Approvals Box filter ('waiting', 'mine', 'pending', 'decided')
  final RxString selectedBox = 'waiting'.obs;

  final RxList<LeaveBalanceModel> balances = <LeaveBalanceModel>[].obs;
  final RxList<ApprovalItemModel> approvalsList = <ApprovalItemModel>[].obs;
  final Rxn<ApprovalItemModel> selectedApproval = Rxn<ApprovalItemModel>();

  // Form State for Leave Application Modal
  final RxString selectedLeaveType = 'Casual Leave'.obs;
  final Rxn<DateTime> startDate = Rxn<DateTime>();
  final Rxn<DateTime> endDate = Rxn<DateTime>();
  final Rxn<String> selectedAttachment = Rxn<String>();

  // Text and Focus Controllers
  final TextEditingController reasonController = TextEditingController();
  final FocusNode reasonFocusNode = FocusNode();

  final TextEditingController actionCommentController = TextEditingController();
  final FocusNode actionCommentFocusNode = FocusNode();

  // Reactive Validation Observables for Apply Leave Form
  final RxnString leaveTypeError = RxnString();
  final RxnString startDateError = RxnString();
  final RxnString endDateError = RxnString();
  final RxnString reasonError = RxnString();

  // Reactive Validation Observable for Rejection Dialog
  final RxnString rejectionError = RxnString();

  /// Lightweight date formatter
  static String formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  void onInit() {
    super.onInit();
    // Real-time error clearing listeners
    reasonController.addListener(() {
      if (reasonError.value != null && reasonController.text.trim().length >= 5) {
        reasonError.value = null;
      }
    });
    actionCommentController.addListener(() {
      if (rejectionError.value != null &&
          actionCommentController.text.trim().length >= 5) {
        rejectionError.value = null;
      }
    });

    // Check if a specific box was passed in navigation arguments
    final args = Get.arguments;
    if (args is Map) {
      if (args['box'] is String) {
        selectedBox.value = args['box'] as String;
      }
      if (args['openId'] is String) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          openApprovalDetailsById(args['openId'] as String);
        });
      }
    }

    loadLeaveData();
  }

  @override
  void onClose() {
    reasonController.dispose();
    reasonFocusNode.dispose();
    actionCommentController.dispose();
    actionCommentFocusNode.dispose();
    super.onClose();
  }

  /// Calculates total day duration between selected start and end dates
  int get calculatedDays {
    final start = startDate.value;
    final end = endDate.value;
    if (start == null || end == null) return 1;
    final diff = end.difference(start).inDays + 1;
    return diff > 0 ? diff : 1;
  }

  /// Resets all validation errors across forms
  void resetFormErrors() {
    leaveTypeError.value = null;
    startDateError.value = null;
    endDateError.value = null;
    reasonError.value = null;
    rejectionError.value = null;
  }

  /// Strictly validates the Apply Leave form inputs
  bool validateApplyLeaveForm() {
    bool isValid = true;

    // 1. Leave Type validation
    if (selectedLeaveType.value.trim().isEmpty) {
      leaveTypeError.value = 'Please select a leave category.';
      isValid = false;
    } else {
      leaveTypeError.value = null;
    }

    // 2. Start Date validation
    final start = startDate.value;
    if (start == null) {
      startDateError.value = 'Start date is required.';
      isValid = false;
    } else {
      startDateError.value = null;
    }

    // 3. End Date validation
    final end = endDate.value;
    if (end == null) {
      endDateError.value = 'End date is required.';
      isValid = false;
    } else if (start != null && end.isBefore(start)) {
      endDateError.value = 'End date cannot be earlier than start date.';
      isValid = false;
    } else {
      endDateError.value = null;
    }

    // 4. Reason validation (Mandatory, 5-1000 characters, plain text)
    final reason = reasonController.text.trim();
    if (reason.isEmpty) {
      reasonError.value = 'Reason is mandatory for supervisor review.';
      isValid = false;
    } else if (reason.length < 5) {
      reasonError.value = 'Reason must be at least 5 characters long.';
      isValid = false;
    } else if (reason.length > 1000) {
      reasonError.value = 'Reason cannot exceed 1000 characters.';
      isValid = false;
    } else {
      reasonError.value = null;
    }

    return isValid;
  }

  /// Changes active box ('waiting', 'mine', 'pending', 'decided') with haptic feedback
  Future<void> changeBox(String box) async {
    if (selectedBox.value == box) return;
    HapticFeedback.selectionClick();
    selectedBox.value = box;
    await fetchApprovals();
  }

  /// Loads leave balances and approvals inbox
  Future<void> loadLeaveData() async {
    try {
      isLoading.value = true;
      final results = await Future.wait([
        repo.fetchLeaveBalances(),
        repo.fetchApprovalsBox(box: selectedBox.value),
      ]);

      balances.assignAll(results[0] as List<LeaveBalanceModel>);
      approvalsList.assignAll(results[1] as List<ApprovalItemModel>);
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetches approvals list for the currently selected box
  Future<void> fetchApprovals() async {
    try {
      isLoading.value = true;
      final list = await repo.fetchApprovalsBox(box: selectedBox.value);
      approvalsList.assignAll(list);
    } finally {
      isLoading.value = false;
    }
  }

  /// Opens the detailed audit view bottom sheet for a request (GET /approvals/{id})
  Future<void> openApprovalDetails(BuildContext context, ApprovalItemModel item) async {
    HapticFeedback.lightImpact();
    selectedApproval.value = item;
    isLoadingDetails.value = true;

    // Show modal immediately with current item summary and loading state
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.primary.withValues(alpha: 0.6),
      builder: (ctx) => const ApprovalDetailsBottomSheet(),
    );

    // Fetch full audit details asynchronously
    try {
      final detailed = await repo.fetchApprovalDetails(item.id);
      if (detailed != null) {
        selectedApproval.value = detailed;
      }
    } finally {
      isLoadingDetails.value = false;
    }
  }

  /// Retries fetching full audit details if previous attempt failed
  Future<void> reloadApprovalDetails(String id) async {
    try {
      isLoadingDetails.value = true;
      final detailed = await repo.fetchApprovalDetails(id);
      if (detailed != null) {
        selectedApproval.value = detailed;
      }
    } finally {
      isLoadingDetails.value = false;
    }
  }

  /// Opens the detailed audit view bottom sheet directly by opaque ULID
  Future<void> openApprovalDetailsById(String id) async {
    HapticFeedback.lightImpact();

    // Check if item already exists in local list
    final existing = approvalsList.firstWhereOrNull((e) => e.id == id);
    if (existing != null) {
      selectedApproval.value = existing;
    } else {
      selectedApproval.value = ApprovalItemModel(
        id: id,
        type: 'request',
        typeLabel: 'Request',
        title: 'Review Request',
        requestedBy: 'Employee',
        status: 'pending',
        statusLabel: 'Pending',
        statusTone: 'amber',
        submittedAgo: 'Just now',
      );
    }

    isLoadingDetails.value = true;
    final context = Get.context;
    if (context != null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: AppColors.primary.withValues(alpha: 0.6),
        builder: (ctx) => const ApprovalDetailsBottomSheet(),
      );
    }

    try {
      final detailed = await repo.fetchApprovalDetails(id);
      if (detailed != null) {
        selectedApproval.value = detailed;
      }
    } finally {
      isLoadingDetails.value = false;
    }
  }

  /// Confirms and processes request approval (POST /approvals/{id}/approve)
  Future<void> approveRequest(String id, {String? comment}) async {
    if (isActionLoading.value) return;

    try {
      isActionLoading.value = true;
      HapticFeedback.mediumImpact();

      final updated = await repo.approveRequest(id, comment: comment);
      if (updated != null) {
        // Update item in local list
        final index = approvalsList.indexWhere((e) => e.id == id);
        if (index != -1) {
          approvalsList[index] = updated;
        }
        selectedApproval.value = updated;

        // Refresh system badges via IndexController
        _refreshMeBadge();

        CustomSnackbar.showSuccess(
          title: 'Request Approved',
          message: 'Approval has been registered successfully.',
        );

        // Close bottom sheet if popped
        if (Get.isBottomSheetOpen == true) {
          Get.back();
        }
        await fetchApprovals();
      } else {
        CustomSnackbar.showError(
          title: 'Approval Failed',
          message: 'Unable to approve request. Please check permissions.',
        );
      }
    } finally {
      isActionLoading.value = false;
    }
  }

  /// Confirms and processes request rejection (POST /approvals/{id}/reject)
  Future<void> rejectRequest(String id, {required String comment}) async {
    if (isActionLoading.value) return;

    final trimmed = comment.trim();
    if (trimmed.isEmpty) {
      rejectionError.value = 'Rejection reason is mandatory.';
      actionCommentFocusNode.requestFocus();
      return;
    }
    if (trimmed.length < 5) {
      rejectionError.value = 'Reason must be at least 5 characters long.';
      actionCommentFocusNode.requestFocus();
      return;
    }
    if (trimmed.length > 1000) {
      rejectionError.value = 'Reason cannot exceed 1000 characters.';
      actionCommentFocusNode.requestFocus();
      return;
    }

    try {
      isActionLoading.value = true;
      HapticFeedback.mediumImpact();

      final updated = await repo.rejectRequest(id, comment: trimmed);
      if (updated != null) {
        final index = approvalsList.indexWhere((e) => e.id == id);
        if (index != -1) {
          approvalsList[index] = updated;
        }
        selectedApproval.value = updated;

        _refreshMeBadge();

        CustomSnackbar.showSuccess(
          title: 'Request Rejected',
          message: 'The request has been rejected and the employee has been notified.',
        );

        if (Get.isBottomSheetOpen == true) {
          Get.back();
        }
        await fetchApprovals();
      } else {
        CustomSnackbar.showError(
          title: 'Rejection Failed',
          message: 'Unable to reject request. Please retry.',
        );
      }
    } finally {
      isActionLoading.value = false;
    }
  }

  /// Confirms and cancels / withdraws a waiting request (POST /approvals/{id}/cancel)
  Future<void> cancelRequest(String id) async {
    if (isActionLoading.value) return;

    try {
      isActionLoading.value = true;
      HapticFeedback.mediumImpact();

      final updated = await repo.cancelRequest(id);
      if (updated != null) {
        final index = approvalsList.indexWhere((e) => e.id == id);
        if (index != -1) {
          approvalsList[index] = updated;
        }
        selectedApproval.value = updated;

        _refreshMeBadge();

        CustomSnackbar.showSuccess(
          title: 'Request Withdrawn',
          message: 'Your pending request has been cancelled successfully.',
        );

        if (Get.isBottomSheetOpen == true) {
          Get.back();
        }
        await fetchApprovals();
      } else {
        CustomSnackbar.showError(
          title: 'Withdraw Failed',
          message: 'Unable to cancel this request.',
        );
      }
    } finally {
      isActionLoading.value = false;
    }
  }

  /// Triggers refresh of GET /me for badge updates
  void _refreshMeBadge() {
    if (Get.isRegistered<IndexController>()) {
      Get.find<IndexController>().fetchMe();
    }
  }

  /// Opens the Apply Leave bottom sheet modal
  void openApplyLeaveModal(BuildContext context) {
    HapticFeedback.lightImpact();

    resetFormErrors();
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    startDate.value = tomorrow;
    endDate.value = tomorrow;
    selectedLeaveType.value = 'Casual Leave';
    selectedAttachment.value = null;
    reasonController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.primary.withValues(alpha: 0.6),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: const ApplyLeaveBottomSheet(),
      ),
    );
  }

  /// Selects start date via Flutter's DatePicker
  Future<void> pickStartDate(BuildContext context) async {
    HapticFeedback.selectionClick();
    final now = DateTime.now();
    final initial = startDate.value ?? now.add(const Duration(days: 1));

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now.subtract(const Duration(days: 7)),
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              surface: AppColors.cardBackground,
              onSurface: AppColors.textColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      startDate.value = picked;
      startDateError.value = null;
      if (endDate.value != null && endDate.value!.isBefore(picked)) {
        endDate.value = picked;
        endDateError.value = null;
      } else if (endDate.value != null) {
        endDateError.value = null;
      }
    }
  }

  /// Selects end date via Flutter's DatePicker
  Future<void> pickEndDate(BuildContext context) async {
    HapticFeedback.selectionClick();
    final now = DateTime.now();
    final start = startDate.value ?? now;
    final initial = endDate.value ?? start;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(start) ? start : initial,
      firstDate: start,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              surface: AppColors.cardBackground,
              onSurface: AppColors.textColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      endDate.value = picked;
      if (startDate.value != null && picked.isBefore(startDate.value!)) {
        endDateError.value = 'End date cannot be earlier than start date.';
      } else {
        endDateError.value = null;
      }
    }
  }

  /// Simulates document upload attachment
  void toggleAttachment() {
    HapticFeedback.lightImpact();
    if (selectedAttachment.value != null) {
      selectedAttachment.value = null;
    } else {
      selectedAttachment.value = 'Medical_Slip_Signed.pdf';
      CustomSnackbar.showSuccess(
        message: 'Supporting document "Medical_Slip_Signed.pdf" attached.',
        title: 'Attachment Added',
      );
    }
  }

  /// Validates and submits the leave application
  Future<void> applyLeave([BuildContext? context]) async {
    if (isSubmitting.value) return;

    if (!validateApplyLeaveForm()) {
      HapticFeedback.heavyImpact();
      if (reasonError.value != null) {
        reasonFocusNode.requestFocus();
      }
      return;
    }

    final reason = reasonController.text.trim();

    try {
      isSubmitting.value = true;
      HapticFeedback.mediumImpact();

      final startStr = formatDate(startDate.value!);
      final endStr = formatDate(endDate.value!);
      final payload = {
        'leave_type': selectedLeaveType.value,
        'start_date': startStr,
        'end_date': endStr,
        'total_days': calculatedDays,
        'reason': reason,
        'attachment': selectedAttachment.value,
      };

      final success = await repo.submitLeaveApplication(payload);

      if (success) {
        // Prepend new pending item to active list
        final newApproval = ApprovalItemModel(
          id: '01j${DateTime.now().millisecondsSinceEpoch.toString().padRight(23, '0')}',
          type: 'leave_application',
          typeLabel: '${selectedLeaveType.value} Application',
          title: '${selectedLeaveType.value} ($calculatedDays Days)',
          employee: const ApprovalEmployeeSummary(
            id: '01j00000000000000000000001',
            name: 'Ayesha Khan',
            number: 'EMP-0001',
            department: 'Sales',
          ),
          requestedBy: 'Ayesha Khan',
          status: 'pending',
          statusLabel: 'Waiting',
          statusTone: 'amber',
          waitingOn: 'Department manager',
          submittedAt: DateTime.now().toIso8601String(),
          submittedAgo: 'Just now',
          facts: [
            ApprovalFactModel(label: 'Leave Type', value: selectedLeaveType.value),
            ApprovalFactModel(label: 'Duration', value: '$calculatedDays Days ($startStr - $endStr)'),
            ApprovalFactModel(label: 'Reason', value: reason),
          ],
          steps: const [
            ApprovalStepModel(
              position: 1,
              approver: 'Department manager',
              status: 'current',
              statusLabel: 'Waiting for approval',
              statusTone: 'amber',
            ),
          ],
          can: const ApprovalPermissionsModel(
            approve: false,
            reject: false,
            asOverride: false,
            cancel: true,
          ),
        );

        approvalsList.insert(0, newApproval);

        Get.back();

        CustomSnackbar.showSuccess(
          message: 'Leave request submitted successfully!',
          title: 'Request Submitted',
        );

        _refreshMeBadge();
      } else {
        CustomSnackbar.showError(
          message: 'Failed to submit leave application. Please retry.',
          title: 'Submission Error',
        );
      }
    } finally {
      isSubmitting.value = false;
    }
  }
}
