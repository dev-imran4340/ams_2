import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../api/app_preferences.dart';
import '../../../api/exception_handler.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../index/controller/index_controller.dart';
import '../model/leave_model.dart';
import '../repo/leave_repo.dart';
import '../view/components/apply_leave_bottom_sheet.dart';

class LeaveController extends GetxController {
  final LeaveRepo repo;

  LeaveController({required this.repo});

  // State Observables
  final RxBool isLoading = false.obs;
  final RxBool isPreviewLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isLeaveModuleActive = true.obs;
  final RxBool isAccessRestricted = false.obs;
  final RxString accessRestrictedMessage = ''.obs;

  // Collections
  final RxList<LeaveTypeModel> leaveTypes = <LeaveTypeModel>[].obs;
  final RxList<LeaveBalanceModel> balances = <LeaveBalanceModel>[].obs;
  final RxList<LeaveRequestItemModel> leaveRequests = <LeaveRequestItemModel>[].obs;
  final RxList<WhosOffItemModel> whosOffList = <WhosOffItemModel>[].obs;

  // Active filter for Leave Applications list ('all', 'pending', 'approved', 'rejected')
  final RxString selectedLeaveFilter = 'all'.obs;

  // Form State for Leave Application Modal
  final Rxn<LeaveTypeModel> selectedLeaveTypeModel = Rxn<LeaveTypeModel>();
  final RxString selectedLeaveType = 'Casual Leave'.obs;
  final Rxn<DateTime> startDate = Rxn<DateTime>();
  final Rxn<DateTime> endDate = Rxn<DateTime>();
  final RxString startPart = 'full'.obs; // 'full', 'first_half', 'second_half'
  final RxString endPart = 'full'.obs; // 'full', 'first_half', 'second_half'
  final Rxn<String> selectedAttachment = Rxn<String>();
  final Rxn<LeavePreviewModel> previewData = Rxn<LeavePreviewModel>();

  // Text and Focus Controllers
  final TextEditingController reasonController = TextEditingController();
  final FocusNode reasonFocusNode = FocusNode();

  // Reactive Validation Observables for Apply Leave Form
  final RxnString leaveTypeError = RxnString();
  final RxnString startDateError = RxnString();
  final RxnString endDateError = RxnString();
  final RxnString reasonError = RxnString();

  /// Lightweight date formatter
  static String formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  /// Formats Date to ISO standard YYYY-MM-DD
  static String formatIsoDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Calculated calendar duration between startDate and endDate
  int get calculatedDays {
    if (startDate.value == null || endDate.value == null) return 0;
    final diff = endDate.value!.difference(startDate.value!).inDays + 1;
    return diff > 0 ? diff : 0;
  }

  @override
  void onInit() {
    super.onInit();
    loadLeaveData();
  }

  /// Returns leave applications matching the currently selected status filter
  List<LeaveRequestItemModel> get filteredLeaveRequests {
    final filter = selectedLeaveFilter.value.toLowerCase().trim();
    if (filter == 'all') return leaveRequests;
    return leaveRequests
        .where((e) => e.status.toLowerCase().trim() == filter)
        .toList();
  }

  void setLeaveFilter(String filter) {
    if (selectedLeaveFilter.value == filter) return;
    HapticFeedback.selectionClick();
    selectedLeaveFilter.value = filter;
  }

  /// Loads leave balances, leave types, and my leave requests (Phase 11)
  Future<void> loadLeaveData() async {
    try {
      isLoading.value = true;
      isAccessRestricted.value = false;
      accessRestrictedMessage.value = '';
      isLeaveModuleActive.value = AppPreferences.hasModule('leave');

      if (!isLeaveModuleActive.value) {
        isAccessRestricted.value = true;
        accessRestrictedMessage.value =
            'Leave module is not included in your company subscription.';
        return;
      }

      try {
          final results = await Future.wait([
            repo.fetchLeaveTypes(),
            repo.fetchLeaveBalances(),
            repo.fetchLeaveRequests(),
          ]);

          final types = results[0] as List<LeaveTypeModel>;
          final bList = results[1] as List<LeaveBalanceModel>;
          final rList = results[2] as List<LeaveRequestItemModel>;

          leaveTypes.assignAll(types);
          balances.assignAll(bList);
          leaveRequests.assignAll(rList);

          if (types.isNotEmpty && selectedLeaveTypeModel.value == null) {
            selectedLeaveTypeModel.value = types.first;
            selectedLeaveType.value = types.first.name;
          }
        } on ApiException catch (e) {
          if (e.statusCode == 403 || e.errorCode == 'forbidden') {
            isAccessRestricted.value = true;
            accessRestrictedMessage.value =
                e.message.isNotEmpty ? e.message : 'This action is not allowed.';
          }
        } catch (_) {}
    } finally {
      isLoading.value = false;
    }
  }

  /// Opens the Apply Leave modal sheet
  void openApplyLeaveModal(BuildContext context) {
    HapticFeedback.lightImpact();
    resetFormErrors();
    reasonController.clear();
    selectedAttachment.value = null;
    startDate.value = null;
    endDate.value = null;
    previewData.value = null;

    if (leaveTypes.isNotEmpty && selectedLeaveTypeModel.value == null) {
      selectedLeaveTypeModel.value = leaveTypes.first;
      selectedLeaveType.value = leaveTypes.first.name;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.primary.withValues(alpha: 0.6),
      builder: (ctx) => const ApplyLeaveBottomSheet(),
    );
  }

  /// Resets all validation errors on apply leave form
  void resetFormErrors() {
    leaveTypeError.value = null;
    startDateError.value = null;
    endDateError.value = null;
    reasonError.value = null;
  }

  /// Client-side validation whitelist before invoking API
  bool validateApplyLeaveForm() {
    resetFormErrors();
    bool isValid = true;

    final type = selectedLeaveTypeModel.value;
    if (type == null && selectedLeaveType.value.trim().isEmpty) {
      leaveTypeError.value = 'Please select a leave category.';
      isValid = false;
    }

    if (startDate.value == null) {
      startDateError.value = 'Start date is required.';
      isValid = false;
    }

    if (endDate.value == null) {
      endDateError.value = 'End date is required.';
      isValid = false;
    }

    if (startDate.value != null &&
        endDate.value != null &&
        startDate.value!.isAfter(endDate.value!)) {
      endDateError.value = 'End date cannot precede start date.';
      isValid = false;
    }

    final reason = reasonController.text.trim();
    if (reason.isEmpty) {
      reasonError.value = 'Reason for leave is mandatory.';
      isValid = false;
    } else if (reason.length < 5) {
      reasonError.value = 'Reason must be at least 5 characters.';
      isValid = false;
    } else if (reason.length > 1000) {
      reasonError.value = 'Reason cannot exceed 1000 characters.';
      isValid = false;
    }

    return isValid;
  }

  /// Date picker for leave start date
  Future<void> pickStartDate(BuildContext context) async {
    HapticFeedback.selectionClick();
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate.value ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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
      }
      checkLeavePreview();
    }
  }

  /// Date picker for leave end date
  Future<void> pickEndDate(BuildContext context) async {
    HapticFeedback.selectionClick();
    final picked = await showDatePicker(
      context: context,
      initialDate: endDate.value ?? startDate.value ?? DateTime.now(),
      firstDate: startDate.value ?? DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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
      endDateError.value = null;
      checkLeavePreview();
    }
  }

  /// Updates selected leave category type and refreshes preview
  void setLeaveType(LeaveTypeModel type) {
    selectedLeaveTypeModel.value = type;
    selectedLeaveType.value = type.name;
    leaveTypeError.value = null;
    checkLeavePreview();
  }

  /// Performs live dry run calculation (POST /me/leave/requests/preview)
  Future<void> checkLeavePreview() async {
    final type = selectedLeaveTypeModel.value;
    final start = startDate.value;
    final end = endDate.value;

    if (type == null || start == null || end == null) return;

    try {
      isPreviewLoading.value = true;
      final payload = {
        'leave_type': type.id,
        'starts_on': formatIsoDate(start),
        'ends_on': formatIsoDate(end),
        'start_part': startPart.value,
        'end_part': endPart.value,
      };

      final result = await repo.previewLeaveRequest(payload);
      if (result != null) {
        previewData.value = result;
      }
    } finally {
      isPreviewLoading.value = false;
    }
  }

  /// Toggles simulated supporting document attachment
  void toggleAttachment() {
    HapticFeedback.selectionClick();
    if (selectedAttachment.value != null) {
      selectedAttachment.value = null;
    } else {
      selectedAttachment.value = 'Medical_Certificate_Proof.pdf';
      CustomSnackbar.showSuccess(
        message: 'Supporting document "Medical_Certificate_Proof.pdf" attached.',
        title: 'Attachment Added',
      );
    }
  }

  /// Validates and submits official leave application (POST /me/leave/requests)
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
    final type = selectedLeaveTypeModel.value;
    final start = startDate.value!;
    final end = endDate.value!;

    try {
      isSubmitting.value = true;
      HapticFeedback.mediumImpact();

      final payload = {
        'leave_type': type?.id ?? selectedLeaveType.value,
        'starts_on': formatIsoDate(start),
        'ends_on': formatIsoDate(end),
        'start_part': startPart.value,
        'end_part': endPart.value,
        'reason': reason,
      };

      final success = await repo.submitLeaveApplication(
        payload,
        filePath: selectedAttachment.value,
      );

      if (success) {
        if (Get.isBottomSheetOpen == true) {
          Get.back();
        }

        resetFormErrors();
        reasonController.clear();
        selectedAttachment.value = null;

        _refreshMeBadge();
        await loadLeaveData();

        CustomSnackbar.showSuccess(
          title: 'Leave Submitted',
          message: 'Your leave application has been submitted for approval.',
        );
      } else {
        CustomSnackbar.showError(
          title: 'Submission Failed',
          message: 'Failed to submit leave application. Please verify details.',
        );
      }
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Cancels an existing leave application (POST /me/leave/requests/{id}/cancel)
  Future<void> cancelLeave(String id, String reason) async {
    try {
      isLoading.value = true;
      final success = await repo.cancelLeaveRequest(id, reason: reason);
      if (success) {
        CustomSnackbar.showSuccess(
          title: 'Leave Cancelled',
          message: 'Your leave application has been cancelled.',
        );
        await loadLeaveData();
      } else {
        CustomSnackbar.showError(
          title: 'Cancellation Failed',
          message: 'Could not cancel leave request.',
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Signals IndexController to re-fetch badges from /me
  void _refreshMeBadge() {
    if (Get.isRegistered<IndexController>()) {
      Get.find<IndexController>().fetchMe();
    }
  }

  @override
  void onClose() {
    reasonController.dispose();
    reasonFocusNode.dispose();
    super.onClose();
  }
}
