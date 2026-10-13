import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../model/regularization_model.dart';
import '../repo/regularization_repo.dart';

class RegularizationController extends GetxController {
  final RegularizationRepo repo;

  RegularizationController({required this.repo});

  // Navigation & Screen Observables
  final RxInt selectedSegmentIndex = 0.obs; // 0: Missed Punch, 1: Overtime Claim
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final Rxn<RegularizationTelemetry> telemetry = Rxn<RegularizationTelemetry>();
  final RxList<AdjustmentRequestItem> requests = <AdjustmentRequestItem>[].obs;

  // Missed Punch Form Observables
  final Rxn<DateTime> selectedDate = Rxn<DateTime>();
  final RxString punchType = 'Check-In'.obs; // 'Check-In', 'Check-Out'
  final Rx<TimeOfDay> selectedTime = const TimeOfDay(hour: 9, minute: 5).obs;
  final RxString reasonCategory = 'Biometric Glitch'.obs;

  // Overtime Form Observables
  final Rxn<DateTime> otDate = Rxn<DateTime>();
  final RxDouble overtimeHours = 1.5.obs;
  final RxString projectTag = 'Mobile App Release'.obs;

  // Form Controllers
  late final TextEditingController remarksController;
  late final FocusNode remarksFocusNode;

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

  /// Format TimeOfDay into readable 12-hour string
  static String formatTime(TimeOfDay t) {
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

    if (Get.arguments is Map && Get.arguments['segmentIndex'] != null) {
      selectedSegmentIndex.value = Get.arguments['segmentIndex'] as int;
    }

    // Default dates to yesterday for missed punch, today for overtime
    final now = DateTime.now();
    selectedDate.value = now.subtract(const Duration(days: 1));
    otDate.value = now;

    loadData();
  }

  @override
  void onClose() {
    remarksController.dispose();
    remarksFocusNode.dispose();
    super.onClose();
  }

  /// Loads telemetry and recent adjustment request history
  Future<void> loadData() async {
    try {
      isLoading.value = true;
      final result = await repo.fetchRegularizationData();
      if (result != null) {
        telemetry.value = result.telemetry;
        requests.assignAll(result.requests);
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Switches between Missed Punch and Overtime tabs
  void switchSegment(int index) {
    if (selectedSegmentIndex.value == index) return;
    HapticFeedback.selectionClick();
    selectedSegmentIndex.value = index;
    remarksController.clear();
  }

  /// Date selection picker
  Future<void> pickDate(BuildContext context, bool isOvertime) async {
    HapticFeedback.selectionClick();
    final now = DateTime.now();
    final initial = isOvertime
        ? (otDate.value ?? now)
        : (selectedDate.value ?? now.subtract(const Duration(days: 1)));

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now,
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
      if (isOvertime) {
        otDate.value = picked;
      } else {
        selectedDate.value = picked;
      }
    }
  }

  /// Time picker for missed punch
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

  /// Stepper controls for overtime hours
  void incrementHours() {
    if (overtimeHours.value < 8.0) {
      HapticFeedback.selectionClick();
      overtimeHours.value += 0.5;
    }
  }

  void decrementHours() {
    if (overtimeHours.value > 0.5) {
      HapticFeedback.selectionClick();
      overtimeHours.value -= 0.5;
    }
  }

  /// Submits the active form (Missed Punch or Overtime Claim)
  Future<void> submitForm([BuildContext? context]) async {
    if (isSubmitting.value) return;

    final remarks = remarksController.text.trim();
    if (remarks.isEmpty) {
      CustomSnackbar.showError(
        title: 'Remarks Required',
        message: 'Please provide context or justification for this adjustment.',
      );
      remarksFocusNode.requestFocus();
      return;
    }

    try {
      isSubmitting.value = true;
      HapticFeedback.mediumImpact();

      if (selectedSegmentIndex.value == 0) {
        // --- Submit Missed Punch ---
        final dateStr = formatDate(selectedDate.value ?? DateTime.now());
        final timeStr = formatTime(selectedTime.value);
        final payload = {
          'date': dateStr,
          'punch_type': punchType.value,
          'time': timeStr,
          'category': reasonCategory.value,
          'remarks': remarks,
        };

        final success = await repo.submitMissedPunch(payload);
        if (success) {
          final newReq = AdjustmentRequestItem(
            id: 'REG-${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}',
            type: 'Missed Punch',
            date: dateStr,
            details: '${punchType.value}: $timeStr (${reasonCategory.value})',
            status: 'Pending',
            appliedAt: formatDate(DateTime.now()),
            remarks: remarks,
            reviewerNotes: 'Submitted for managerial verification.',
          );

          requests.insert(0, newReq);

          // Update remaining adjustments count locally
          if (telemetry.value != null &&
              telemetry.value!.adjustmentsRemaining > 0) {
            telemetry.value = telemetry.value!.copyWith(
              adjustmentsRemaining: telemetry.value!.adjustmentsRemaining - 1,
              pendingApprovalsCount:
                  telemetry.value!.pendingApprovalsCount + 1,
            );
          }

          remarksController.clear();
          CustomSnackbar.showSuccess(
            title: 'Regularization Requested',
            message:
                'Missed punch request (#${newReq.id}) submitted successfully!',
          );
        }
      } else {
        // --- Submit Overtime Claim ---
        final otDateStr = formatDate(otDate.value ?? DateTime.now());
        final hoursVal = overtimeHours.value;
        final payload = {
          'date': otDateStr,
          'hours': hoursVal,
          'project': projectTag.value,
          'remarks': remarks,
        };

        final success = await repo.submitOvertimeClaim(payload);
        if (success) {
          final newReq = AdjustmentRequestItem(
            id: 'OT-${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}',
            type: 'Overtime Claim',
            date: otDateStr,
            details: 'Overtime: $hoursVal Hours (${projectTag.value})',
            status: 'Pending',
            appliedAt: formatDate(DateTime.now()),
            remarks: remarks,
            reviewerNotes: 'Claim under review by Project Tech Lead.',
          );

          requests.insert(0, newReq);

          // Update pending count
          if (telemetry.value != null) {
            telemetry.value = telemetry.value!.copyWith(
              pendingApprovalsCount:
                  telemetry.value!.pendingApprovalsCount + 1,
            );
          }

          remarksController.clear();
          CustomSnackbar.showSuccess(
            title: 'Overtime Claimed',
            message: 'Overtime claim (#${newReq.id}) submitted for $hoursVal hrs!',
          );
        }
      }
    } finally {
      isSubmitting.value = false;
    }
  }
}
