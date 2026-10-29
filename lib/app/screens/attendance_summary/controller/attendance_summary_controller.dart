import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../api/app_preferences.dart';
import '../model/attendance_summary_model.dart';
import '../repo/attendance_summary_repo.dart';

class AttendanceSummaryController extends GetxController {
  final AttendanceSummaryRepo repo;

  AttendanceSummaryController({required this.repo});

  // State Observables
  final RxBool isLoading = false.obs;
  final Rx<DateTime> selectedMonth = DateTime(2026, 10).obs;
  final Rxn<AttendanceSummaryResponseModel> summary = Rxn<AttendanceSummaryResponseModel>();

  @override
  void onInit() {
    super.onInit();
    final now = DateTime.now();
    selectedMonth.value = DateTime(now.year, now.month);
    loadSummary(selectedMonth.value);
  }

  /// Loads attendance summary telemetry for the selected month
  Future<void> loadSummary(DateTime month) async {
    final bool hasAttendance = AppPreferences.hasModule('attendance') &&
        AppPreferences.hasPermission('attendance.view');
    if (!hasAttendance) {
      summary.value = null;
      return;
    }

    try {
      isLoading.value = true;
      selectedMonth.value = month;

      final result = await repo.fetchSummary(month);
      summary.value = result;
    } finally {
      isLoading.value = false;
    }
  }

  /// Changes the month forwards or backwards
  void changeMonth(int offset) {
    HapticFeedback.lightImpact();
    final current = selectedMonth.value;
    final newMonth = DateTime(current.year, current.month + offset);
    loadSummary(newMonth);
  }
}
