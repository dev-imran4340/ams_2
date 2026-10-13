import 'dart:async';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../model/dashboard_model.dart';
import '../repo/dashboard_repo.dart';

class DashboardController extends GetxController {
  final DashboardRepo repo;

  DashboardController({required this.repo});

  // Observables
  final RxBool isLoading = false.obs;
  final RxBool isPunching = false.obs;
  final Rxn<DashboardDataModel> dashboardData = Rxn<DashboardDataModel>();

  final RxString liveClock = ''.obs;
  final RxString liveDate = ''.obs;
  final RxString elapsedShiftTimer = '00h 00m 00s'.obs;

  // Active Live Running Clock Timer
  Timer? _clockTimer;

  @override
  void onInit() {
    super.onInit();
    _startLiveClock();
    loadDashboard();
  }

  /// Starts 1-second periodic timer for live clock & running shift duration
  void _startLiveClock() {
    _updateClock();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateClock();
      _updateRunningShiftTimer();
    });
  }

  /// Formats and updates the real-time clock and date
  void _updateClock() {
    final now = DateTime.now();
    final hour = now.hour > 12
        ? now.hour - 12
        : (now.hour == 0 ? 12 : now.hour);
    final period = now.hour >= 12 ? 'PM' : 'AM';
    final minute = now.minute.toString().padLeft(2, '0');
    final second = now.second.toString().padLeft(2, '0');
    final hourStr = hour.toString().padLeft(2, '0');

    liveClock.value = '$hourStr:$minute:$second $period';

    // Format readable date (e.g. "Tuesday, 13 Oct 2026")
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
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
    final dayName = weekdays[now.weekday - 1];
    final monthName = months[now.month - 1];
    liveDate.value = '$dayName, ${now.day} $monthName ${now.year}';
  }

  /// Calculates and updates active shift elapsed time if checked in
  void _updateRunningShiftTimer() {
    final today = dashboardData.value?.todayAttendance;
    if (today == null || !today.isCheckedIn || today.checkInDateTime == null) {
      if (today?.isCheckedIn == false) {
        elapsedShiftTimer.value = '00h 00m 00s';
      }
      return;
    }

    final now = DateTime.now();
    final difference = now.difference(today.checkInDateTime!);
    if (difference.isNegative) {
      elapsedShiftTimer.value = '00h 00m 00s';
      return;
    }

    final hours = difference.inHours.toString().padLeft(2, '0');
    final minutes = (difference.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (difference.inSeconds % 60).toString().padLeft(2, '0');

    elapsedShiftTimer.value = '${hours}h ${minutes}m ${seconds}s';
  }

  /// Loads initial dashboard state
  Future<void> loadDashboard() async {
    try {
      isLoading.value = true;
      final result = await repo.fetchDashboardData();
      if (result != null) {
        dashboardData.value = result;
        _updateRunningShiftTimer();
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Action method to trigger check-in / check-out with confirmation & haptics
  Future<void> handlePunchAction() async {
    if (isPunching.value || isLoading.value) return;

    final currentAttendance = dashboardData.value?.todayAttendance;
    final bool isCheckingIn = !(currentAttendance?.isCheckedIn ?? false);

    try {
      isPunching.value = true;
      await HapticFeedback.mediumImpact();

      final updatedAttendance = await repo.togglePunch(isCheckingIn);

      if (updatedAttendance != null) {
        if (dashboardData.value != null) {
          dashboardData.value = DashboardDataModel(
            todayAttendance: updatedAttendance,
            monthlySummary: dashboardData.value!.monthlySummary,
          );
        }

        _updateRunningShiftTimer();

        CustomSnackbar.showSuccess(
          message: isCheckingIn
              ? 'Checked in successfully! Shift started.'
              : 'Checked out successfully! Shift logged.',
        );
      } else {
        CustomSnackbar.showError(
          message: 'Unable to record punch. Please try again.',
        );
      }
    } finally {
      isPunching.value = false;
    }
  }

  @override
  void onClose() {
    _clockTimer?.cancel();
    _clockTimer = null;
    super.onClose();
  }
}
