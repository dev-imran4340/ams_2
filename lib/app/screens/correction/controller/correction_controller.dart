import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../routes/app_routes.dart';
import '../../index/controller/index_controller.dart';
import '../model/correction_model.dart';
import '../repo/correction_repo.dart';

class CorrectionController extends GetxController {
  final CorrectionRepo repo;

  CorrectionController({required this.repo});

  // Global Form Key for strict client-side validation
  final formKey = GlobalKey<FormState>();

  // State Observables
  final RxBool isSubmitting = false.obs;
  final RxnString lastSubmittedRequestId = RxnString();

  // Attendance Correction Form Observables (matching POST /me/attendance/corrections)
  final Rxn<DateTime> selectedDate = Rxn<DateTime>();
  final RxString selectedKind =
      'in'.obs; // 'in', 'out', 'break_start', 'break_end'
  final Rx<TimeOfDay> selectedTime =
      const TimeOfDay(hour: 9, minute: 0).obs;
  final RxBool isNextDay = false.obs;
  final RxInt reasonCharCount = 0.obs;

  // Form Controllers
  late final TextEditingController remarksController;
  late final FocusNode remarksFocusNode;

  // Quick preset reasons to accelerate user submission
  final List<String> quickReasons = const [
    'Biometric Scanner Issue',
    'Forgot to Punch',
    'Client Site / Field Duty',
    'System / Power Outage',
    'Shift Timing Adjusted',
  ];

  static const List<String> _months = [
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

  /// Lightweight date formatter for UI labels
  static String formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')} ${_months[dt.month - 1]} ${dt.year}';
  }

  /// Relative date label (Today, Yesterday, or formatted date)
  static String formatRelativeDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return formatDate(dt);
  }

  /// ISO 8601 date formatter required by backend (YYYY-MM-DD)
  static String formatDateIso(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  /// 24-hour time formatter required by backend (HH:MM, 00:00 to 23:59)
  static String formatTime24h(TimeOfDay t) {
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  /// Format TimeOfDay into readable 12-hour string for display
  static String formatTime12h(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  @override
  void onInit() {
    super.onInit();
    remarksController = TextEditingController();
    remarksFocusNode = FocusNode();

    remarksController.addListener(() {
      reasonCharCount.value = remarksController.text.length;
    });

    // Default incident date to yesterday (cannot be in future per doc/api.md)
    final now = DateTime.now();
    selectedDate.value = now.subtract(const Duration(days: 1));

    // Zero unnecessary pre-fetch API calls for instant loading
  }

  @override
  void onClose() {
    remarksController.dispose();
    remarksFocusNode.dispose();
    super.onClose();
  }

  /// Date selection picker (strictly prevents future dates per doc/api.md)
  Future<void> pickDate(BuildContext context) async {
    HapticFeedback.selectionClick();
    final now = DateTime.now();
    final initial = selectedDate.value ?? now.subtract(const Duration(days: 1));

    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(now) ? now : initial,
      firstDate: now.subtract(const Duration(days: 60)),
      lastDate: now, // Strictly prevents future dates per doc/api.md
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
      selectedDate.value = picked;
    }
  }

  /// Time picker for punch timing
  Future<void> pickTime(BuildContext context) async {
    HapticFeedback.selectionClick();
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime.value,
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
      selectedTime.value = picked;
    }
  }

  /// Sets quick preset reason into text field
  void setQuickReason(String reason) {
    HapticFeedback.selectionClick();
    remarksController.text = reason;
    remarksController.selection = TextSelection.fromPosition(
      TextPosition(offset: reason.length),
    );
  }

  /// Navigates user to Requests & Approvals screen (Tab 2)
  void navigateToApprovals() {
    HapticFeedback.selectionClick();
    if (Get.isRegistered<IndexController>()) {
      Get.find<IndexController>().changeTab(2);
      Get.back();
    } else {
      Get.toNamed(Routes.LEAVE);
    }
  }

  /// Resets the form so user can submit another correction
  void resetForm() {
    HapticFeedback.selectionClick();
    lastSubmittedRequestId.value = null;
    remarksController.clear();
    final now = DateTime.now();
    selectedDate.value = now.subtract(const Duration(days: 1));
    selectedKind.value = 'in';
    selectedTime.value = const TimeOfDay(hour: 9, minute: 0);
    isNextDay.value = false;
  }

  /// Submits the attendance correction form via POST /me/attendance/corrections
  Future<void> submitForm([BuildContext? context]) async {
    if (isSubmitting.value) return;

    // Validate with FormState
    if (formKey.currentState != null && !formKey.currentState!.validate()) {
      return;
    }

    final reason = remarksController.text.trim();
    if (reason.isEmpty) {
      CustomSnackbar.showError(
        title: 'Reason Required',
        message: 'Please provide justification for this adjustment.',
      );
      remarksFocusNode.requestFocus();
      return;
    }

    try {
      isSubmitting.value = true;
      HapticFeedback.mediumImpact();

      final dt = selectedDate.value ?? DateTime.now();
      final dateIso = formatDateIso(dt);
      final time24 = formatTime24h(selectedTime.value);

      final requestModel = AttendanceCorrectionSubmitModel(
        date: dateIso,
        add: [
          AttendanceCorrectionPunchAddModel(
            time: time24,
            kind: selectedKind.value,
            nextDay: isNextDay.value,
          ),
        ],
        reason: reason,
      );

      final response = await repo.submitAttendanceCorrection(requestModel);

      if (response != null) {
        final reqId = response['data']?['id']?.toString() ??
            'REQ-${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}';

        lastSubmittedRequestId.value = reqId;

        remarksController.clear();
        CustomSnackbar.showSuccess(
          title: 'Correction Submitted',
          message:
              'Attendance correction request (#${reqId.length > 8 ? reqId.substring(reqId.length - 8) : reqId}) sent to approvals inbox!',
        );
      } else {
        CustomSnackbar.showError(
          title: 'Submission Conflict',
          message:
              'Could not submit request. A correction for this day may already be waiting approval or payroll is closed.',
        );
      }
    } finally {
      isSubmitting.value = false;
    }
  }
}
