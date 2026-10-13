import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../model/attendance_history_model.dart';
import '../repo/attendance_history_repo.dart';

class AttendanceHistoryController extends GetxController {
  final AttendanceHistoryRepo repo;

  AttendanceHistoryController({required this.repo});

  // Observables
  final RxBool isLoading = false.obs;
  final RxBool isExporting = false.obs;
  final Rx<DateTime> selectedMonth = DateTime(2026, 10).obs;
  final Rxn<DateTime> selectedDate = Rxn<DateTime>();
  final RxList<AttendanceDayLog> logs = <AttendanceDayLog>[].obs;
  final Rxn<MonthlyTelemetrySummary> summary = Rxn<MonthlyTelemetrySummary>();
  final Rxn<AttendanceDayLog> selectedDayLog = Rxn<AttendanceDayLog>();

  @override
  void onInit() {
    super.onInit();
    loadMonthlyLogs(selectedMonth.value);
  }

  /// Loads attendance logs and monthly telemetry for the given month
  Future<void> loadMonthlyLogs(DateTime month) async {
    try {
      isLoading.value = true;
      selectedMonth.value = month;

      final result = await repo.fetchMonthlyHistory(month);
      if (result != null) {
        logs.assignAll(result.logs);
        summary.value = result.summary;

        // Auto-select today (Oct 13, 2026) or first available non-empty log
        final todayTarget = DateTime(2026, 10, 13);
        final defaultLog = logs.firstWhereOrNull(
              (l) =>
                  l.date.year == todayTarget.year &&
                  l.date.month == todayTarget.month &&
                  l.date.day == todayTarget.day,
            ) ??
            (logs.isNotEmpty ? logs.first : null);

        if (defaultLog != null) {
          selectedDate.value = defaultLog.date;
          selectedDayLog.value = defaultLog;
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Selects a specific date with light haptic feedback and updates breakdown view
  void selectDate(DateTime date) {
    if (selectedDate.value == date) return;

    HapticFeedback.lightImpact();
    selectedDate.value = date;
    selectedDayLog.value = logs.firstWhereOrNull(
      (log) =>
          log.date.year == date.year &&
          log.date.month == date.month &&
          log.date.day == date.day,
    );
  }

  /// Shifts active month forward or backward by the given offset
  void changeMonth(int offset) {
    HapticFeedback.lightImpact();
    final current = selectedMonth.value;
    final newMonth = DateTime(current.year, current.month + offset);
    loadMonthlyLogs(newMonth);
  }

  /// Triggers simulated PDF report download
  Future<void> exportReport() async {
    if (isExporting.value || isLoading.value) return;

    try {
      isExporting.value = true;
      HapticFeedback.mediumImpact();

      final success = await repo.exportMonthlyReport(selectedMonth.value);
      if (success) {
        const months = [
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December'
        ];
        final monthStr = months[selectedMonth.value.month - 1];
        CustomSnackbar.showSuccess(
          message: '$monthStr ${selectedMonth.value.year} report exported to PDF.',
        );
      } else {
        CustomSnackbar.showError(
          message: 'Failed to generate report. Please try again.',
        );
      }
    } finally {
      isExporting.value = false;
    }
  }
}
