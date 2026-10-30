import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../api/app_preferences.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../routes/app_routes.dart';
import '../model/dashboard_model.dart';
import '../repo/dashboard_repo.dart';
import '../view/components/selfie_punch_sheet.dart';
import '../../main_shell/controller/session_me_controller.dart';

class DashboardController extends GetxController {
  final DashboardRepo repo;

  DashboardController({required this.repo});

  // Observables
  final RxBool isLoading = false.obs;
  final RxBool isPunching = false.obs;
  final RxBool isBreakLoading = false.obs;
  final Rxn<DashboardDataModel> dashboardData = Rxn<DashboardDataModel>();

  final RxString liveClock = ''.obs;
  final RxString liveDate = ''.obs;
  final RxString elapsedShiftTimer = '00:00:00'.obs;
  final RxString elapsedHoursMinutes = '00:00'.obs;
  final RxString elapsedSeconds = '00'.obs;

  // Active Live Running Clock Timer
  Timer? _clockTimer;
  Worker? _permissionWorker;

  @override
  void onInit() {
    super.onInit();
    _startLiveClock();
    loadDashboard();

    // Reactively trigger loadDashboard when /me session arrives or updates permissions
    if (Get.isRegistered<SessionMeController>()) {
      final session = Get.find<SessionMeController>();
      _permissionWorker = ever(session.permissions, (_) {
        if (dashboardData.value == null && !isLoading.value) {
          loadDashboard();
        }
      });
    }
  }

  /// Starts 1-second periodic timer for real-time clock & running shift duration
  void _startLiveClock() {
    _updateClock();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateClock();
      _updateRunningShiftTimer();
    });
  }

  /// Formats and updates the real-time clock and date natively
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
    if (today == null) {
      elapsedShiftTimer.value = '00:00:00';
      elapsedHoursMinutes.value = '00:00';
      elapsedSeconds.value = '00';
      return;
    }

    // Base worked seconds from server (completed work segments)
    final int baseWorkedSeconds = today.workedMinutes * 60;

    // Case 1: Employee is NOT checked in
    if (!today.isCheckedIn) {
      final String doneHours = today.workingHours.isNotEmpty && today.workingHours != '0:00'
          ? today.workingHours
          : (baseWorkedSeconds > 0
              ? '${(baseWorkedSeconds ~/ 3600)}h ${((baseWorkedSeconds % 3600) ~/ 60).toString().padLeft(2, '0')}m'
              : '0h 00m');

      final String timeDisplay = baseWorkedSeconds > 0
          ? '${(baseWorkedSeconds ~/ 3600).toString().padLeft(2, '0')}:${((baseWorkedSeconds % 3600) ~/ 60).toString().padLeft(2, '0')}'
          : '00:00';

      final bool hasEnded = (today.checkOutTime != '--:--') || (today.latestCheckOutTime != null);
      elapsedShiftTimer.value = hasEnded ? '$doneHours (Done)' : '00:00:00';
      elapsedHoursMinutes.value = hasEnded ? timeDisplay : '00:00';
      elapsedSeconds.value = '00';
      return;
    }

    // Case 2: Employee is ON BREAK (shift timer paused at completed worked hours)
    if (today.isOnBreak) {
      final h = (baseWorkedSeconds ~/ 3600).toString().padLeft(2, '0');
      final m = ((baseWorkedSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
      final s = (baseWorkedSeconds % 60).toString().padLeft(2, '0');

      elapsedShiftTimer.value = '${h}h ${m}m (Paused)';
      elapsedHoursMinutes.value = '$h:$m';
      elapsedSeconds.value = s;
      return;
    }

    // Case 3: Employee is actively CHECKED IN
    // When checked in, total worked time = base worked seconds (completed segments)
    // + time elapsed in current active session (since_at)
    int activeSegmentSeconds = 0;
    if (today.checkInDateTime != null) {
      final now = DateTime.now();
      final difference = now.difference(today.checkInDateTime!);
      if (!difference.isNegative) {
        activeSegmentSeconds = difference.inSeconds;
      }
    }

    final int totalSeconds = baseWorkedSeconds + activeSegmentSeconds;
    final String hours = (totalSeconds ~/ 3600).toString().padLeft(2, '0');
    final String minutes = ((totalSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final String seconds = (totalSeconds % 60).toString().padLeft(2, '0');

    elapsedShiftTimer.value = '${hours}h ${minutes}m ${seconds}s';
    elapsedHoursMinutes.value = '$hours:$minutes';
    elapsedSeconds.value = seconds;

    // Reactively sync workingHours so card metrics show live elapsed progression
    final currentHours = '${int.parse(hours)}h ${minutes}m';
    if (today.workingHours != currentHours && dashboardData.value != null) {
      dashboardData.value = DashboardDataModel(
        todayAttendance: today.copyWith(workingHours: currentHours),
        monthlySummary: dashboardData.value!.monthlySummary,
      );
    }
  }

  /// Loads live dashboard telemetry from server with Zero Dummy Fallback Policy.
  /// If permissions are already cached and attendance is explicitly absent, skips fetch.
  /// On initial login (before /me arrives), does NOT block; triggers server fetch immediately.
  Future<void> loadDashboard() async {
    final cachedPerms = AppPreferences.permissions;
    if (cachedPerms != null && cachedPerms.isNotEmpty) {
      final bool hasAttendance = AppPreferences.hasModule('attendance') &&
          AppPreferences.hasPermission('attendance.view');
      if (!hasAttendance) {
        dashboardData.value = null;
        return;
      }
    }

    try {
      isLoading.value = true;
      final result = await repo.fetchDashboardData();
      dashboardData.value = result;
      _updateRunningShiftTimer();
    } finally {
      isLoading.value = false;
    }
  }

  /// Action method to trigger check-in / check-out based strictly on server state.allowed
  Future<void> handlePunchAction() async {
    if (isPunching.value || isLoading.value) return;

    final currentAttendance = dashboardData.value?.todayAttendance;
    if (currentAttendance == null) {
      CustomSnackbar.showError(message: 'Attendance data is unavailable.');
      return;
    }

    // Server Decides Access: Determine punch action from state.allowed
    final allowed = currentAttendance.allowed;
    String? punchKind;

    if (!currentAttendance.isCheckedIn) {
      if (allowed.contains('in')) {
        punchKind = 'in';
      } else {
        final refusal = currentAttendance.refusals['in']?.message ??
            'Check-in is not allowed right now.';
        CustomSnackbar.showError(message: refusal);
        return;
      }
    } else {
      if (allowed.contains('out')) {
        punchKind = 'out';
      } else {
        final refusal = currentAttendance.refusals['out']?.message ??
            'Check-out is not allowed right now.';
        CustomSnackbar.showError(message: refusal);
        return;
      }
    }

    final requires = currentAttendance.requires;

    // 1. Requirement Check: AI Face Recognition Biometric
    if (requires != null && requires.face != 'off') {
      final punchCompleted = await Get.toNamed(
        Routes.FACE_RECOGNITION,
        arguments: {
          'isPunchMode': true,
          'punchKind': punchKind,
          'requires': requires,
        },
      );
      if (punchCompleted == true) {
        await loadDashboard();
      }
      return;
    }

    // 2. Requirement Check: Front Camera Selfie Photo Verification
    File? selfiePhoto;
    if (requires?.photo == true) {
      selfiePhoto = await _openSelfieCaptureModal(punchKind);
      if (selfiePhoto == null) {
        // User cancelled selfie capture
        return;
      }
    }

    try {
      isPunching.value = true;
      await HapticFeedback.mediumImpact();

      final updatedAttendance = await repo.submitPunch(
        kind: punchKind,
        photoFile: selfiePhoto,
      );

      if (updatedAttendance != null) {
        if (dashboardData.value != null) {
          dashboardData.value = DashboardDataModel(
            todayAttendance: updatedAttendance,
            monthlySummary: dashboardData.value!.monthlySummary,
          );
        }

        _updateRunningShiftTimer();

        CustomSnackbar.showSuccess(
          message: punchKind == 'in'
              ? 'Checked in successfully! Shift started.'
              : 'Checked out successfully! Shift logged.',
        );
      } else {
        // If punch call failed or rejected by server rule, refresh today state
        await loadDashboard();
      }
    } finally {
      isPunching.value = false;
    }
  }

  /// Action method to trigger start_break / end_break based on state.allowed and state.on_break
  Future<void> handleBreakAction() async {
    if (isBreakLoading.value || isPunching.value || isLoading.value) return;

    final currentAttendance = dashboardData.value?.todayAttendance;
    if (currentAttendance == null) {
      CustomSnackbar.showError(message: 'Attendance data is unavailable.');
      return;
    }

    final isOnBreak = currentAttendance.isOnBreak;
    final allowed = currentAttendance.allowed;
    final String punchKind = isOnBreak ? 'break_end' : 'break_start';

    if (!allowed.contains(punchKind)) {
      final refusal = currentAttendance.refusals[punchKind]?.message ??
          (isOnBreak
              ? 'Ending break is not allowed right now.'
              : 'Starting break is not allowed right now.');
      CustomSnackbar.showError(message: refusal);
      return;
    }

    final requires = currentAttendance.requires;

    // 1. Requirement Check: AI Face Recognition Biometric
    if (requires != null && requires.face != 'off') {
      final punchCompleted = await Get.toNamed(
        Routes.FACE_RECOGNITION,
        arguments: {
          'isPunchMode': true,
          'punchKind': punchKind,
          'requires': requires,
        },
      );
      if (punchCompleted == true) {
        await loadDashboard();
      }
      return;
    }

    // 2. Requirement Check: Front Camera Selfie Photo Verification
    File? selfiePhoto;
    if (requires?.photo == true) {
      selfiePhoto = await _openSelfieCaptureModal(punchKind);
      if (selfiePhoto == null) {
        return;
      }
    }

    try {
      isBreakLoading.value = true;
      await HapticFeedback.mediumImpact();

      final updatedAttendance = await repo.submitPunch(
        kind: punchKind,
        photoFile: selfiePhoto,
      );

      if (updatedAttendance != null) {
        if (dashboardData.value != null) {
          dashboardData.value = DashboardDataModel(
            todayAttendance: updatedAttendance,
            monthlySummary: dashboardData.value!.monthlySummary,
          );
        }

        _updateRunningShiftTimer();

        CustomSnackbar.showSuccess(
          message: isOnBreak
              ? 'Break ended! Welcome back to your shift.'
              : 'Break started! Enjoy your break.',
        );
      } else {
        await loadDashboard();
      }
    } finally {
      isBreakLoading.value = false;
    }
  }

  /// Opens the front-camera selfie capture bottom sheet for photo attendance verification
  Future<File?> _openSelfieCaptureModal(String punchKind) async {
    return await Get.bottomSheet<File?>(
      SelfiePunchSheet(punchKind: punchKind),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
    );
  }

  @override
  void onClose() {
    _clockTimer?.cancel();
    _clockTimer = null;
    _permissionWorker?.dispose();
    _permissionWorker = null;
    super.onClose();
  }
}
