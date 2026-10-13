import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../model/leave_model.dart';
import '../repo/leave_repo.dart';
import '../view/components/apply_leave_bottom_sheet.dart';

class LeaveController extends GetxController {
  final LeaveRepo repo;

  LeaveController({required this.repo});

  // Observables
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString selectedFilter = 'All'.obs; // 'All', 'Pending', 'Approved', 'Rejected'
  final RxList<LeaveBalanceModel> balances = <LeaveBalanceModel>[].obs;
  final RxList<LeaveRequestItemModel> requests = <LeaveRequestItemModel>[].obs;

  // Form State for Leave Application Modal
  final RxString selectedLeaveType = 'Casual Leave'.obs;
  final Rxn<DateTime> startDate = Rxn<DateTime>();
  final Rxn<DateTime> endDate = Rxn<DateTime>();
  final Rxn<String> selectedAttachment = Rxn<String>();

  // Text and Focus Controllers
  late final TextEditingController reasonController;
  late final FocusNode reasonFocusNode;

  /// Lightweight date formatter without external package dependency
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
    reasonController = TextEditingController();
    reasonFocusNode = FocusNode();
    loadLeaveData();
  }

  @override
  void onClose() {
    reasonController.dispose();
    reasonFocusNode.dispose();
    super.onClose();
  }

  /// Filtered list of leave requests according to active chip
  List<LeaveRequestItemModel> get filteredRequests {
    final filter = selectedFilter.value.toLowerCase();
    if (filter == 'all') {
      return requests;
    }
    return requests.where((item) => item.status.toLowerCase() == filter).toList();
  }

  /// Calculates total day duration between selected start and end dates
  int get calculatedDays {
    final start = startDate.value;
    final end = endDate.value;
    if (start == null || end == null) return 1;
    final diff = end.difference(start).inDays + 1;
    return diff > 0 ? diff : 1;
  }

  /// Sets request status filter with haptic feedback
  void setFilter(String filter) {
    if (selectedFilter.value == filter) return;
    HapticFeedback.selectionClick();
    selectedFilter.value = filter;
  }

  /// Loads leave balances and recent requests
  Future<void> loadLeaveData() async {
    try {
      isLoading.value = true;
      final results = await Future.wait([
        repo.fetchLeaveBalances(),
        repo.fetchRecentRequests(),
      ]);

      balances.assignAll(results[0] as List<LeaveBalanceModel>);
      requests.assignAll(results[1] as List<LeaveRequestItemModel>);
    } finally {
      isLoading.value = false;
    }
  }

  /// Opens the Apply Leave bottom sheet modal
  void openApplyLeaveModal(BuildContext context) {
    HapticFeedback.lightImpact();

    // Initialize defaults: tomorrow as default start and end
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
      firstDate: now.subtract(const Duration(days: 7)), // Allow 7-day retrospective
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
      // If end date is before new start date, shift end date to start date
      if (endDate.value != null && endDate.value!.isBefore(picked)) {
        endDate.value = picked;
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

    final reason = reasonController.text.trim();
    if (startDate.value == null || endDate.value == null) {
      CustomSnackbar.showError(
        message: 'Please choose both start and end dates for your leave.',
        title: 'Missing Dates',
        context: context,
      );
      return;
    }

    if (reason.isEmpty) {
      CustomSnackbar.showError(
        message: 'Please state a brief reason for taking leave.',
        title: 'Reason Required',
        context: context,
      );
      reasonFocusNode.requestFocus();
      return;
    }

    if (reason.length < 5) {
      CustomSnackbar.showError(
        message: 'Reason must be at least 5 characters long.',
        title: 'Reason Too Short',
        context: context,
      );
      reasonFocusNode.requestFocus();
      return;
    }

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
        // Prepend new pending request to reactive list
        final newRequest = LeaveRequestItemModel(
          id: 'LR-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
          leaveType: selectedLeaveType.value,
          startDate: startStr,
          endDate: endStr,
          totalDays: calculatedDays,
          reason: reason,
          status: 'Pending',
          appliedAt: formatDate(DateTime.now()),
          managerNotes: 'Submitted for managerial review.',
          attachmentName: selectedAttachment.value,
        );

        requests.insert(0, newRequest);

        // Safely close bottom sheet modal via GetX navigation
        Get.back();

        // Show success notification
        CustomSnackbar.showSuccess(
          message: 'Leave request (#${newRequest.id}) submitted successfully!',
          title: 'Request Submitted',
        );
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
