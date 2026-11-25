import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../api/app_preferences.dart';
import '../../../api/exception_handler.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_spaces.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../core/widgets/custom_state_view.dart';
import '../../../routes/app_routes.dart';
import '../model/dashboard_model.dart';
import '../repo/dashboard_repo.dart';
import '../view/components/selfie_punch_sheet.dart';
import '../../main_shell/controller/session_me_controller.dart';
import '../../verification/face_recognition/repo/face_recognition_repo.dart';
import '../../../services/location_service.dart';

class DashboardController extends GetxController {
  final DashboardRepo repo;

  DashboardController({required this.repo});

  // Observables
  final RxBool isLoading = false.obs;
  final RxBool isPunching = false.obs;
  final RxBool isBreakLoading = false.obs;
  final RxBool isAccessRestricted = false.obs;
  final RxString accessRestrictedMessage = ''.obs;
  final Rxn<DashboardDataModel> dashboardData = Rxn<DashboardDataModel>();

  final RxString liveClock = ''.obs;
  final RxString liveDate = ''.obs;
  final RxString elapsedShiftTimer = '00:00:00'.obs;
  final RxString elapsedHoursMinutes = '00:00'.obs;
  final RxString elapsedSeconds = '00'.obs;

  // Dedicated Break Observables (Work timer pauses & Break timer ticks live / resumes)
  final RxString elapsedBreakTimer = '00:00:00'.obs;
  final RxString elapsedBreakHoursMinutes = '00:00'.obs;
  final RxString elapsedBreakSeconds = '00'.obs;
  final RxString pausedWorkDuration = '0h 00m'.obs;

  // Active Live Running Clock Timer
  Timer? _clockTimer;
  Worker? _permissionWorker;

  @override
  void onInit() {
    super.onInit();
    // Strict Invariant: Company/Organization users do not call individual employee attendance endpoints
    if (AppPreferences.isCompanyMode) {
      return;
    }
    _startLiveClock();
    loadDashboard();

    // Reactively trigger loadDashboard when /me session arrives or updates permissions
    if (Get.isRegistered<SessionMeController>()) {
      final session = Get.find<SessionMeController>();
      _permissionWorker = ever(session.permissions, (_) {
        if (!AppPreferences.isCompanyMode &&
            dashboardData.value == null &&
            !isLoading.value &&
            !isAccessRestricted.value) {
          loadDashboard();
        }
      });
    }
  }

  /// Starts 1-second periodic timer for real-time clock & running shift duration
  void _startLiveClock() {
    _updateClock();
    _clockTimer?.cancel();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      try {
        _updateClock();
        _updateRunningShiftTimer();
      } catch (e) {
        debugPrint('>>> [DASHBOARD TIMER ERROR] $e');
      }
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

  /// Deep, mathematically accurate calculation of total shift worked seconds.
  /// Seamlessly handles all real-world check-in / check-out edge cases:
  /// 1. App killed and reopened hours later (calculates exact seconds from timestamps).
  /// 2. User starts break (shift timer freezes / pauses; break duration is excluded from worked time).
  /// 3. User checks out directly during break (shift ends, timer freezes at total worked time).
  /// 4. User checks out immediately after check-in (few seconds or zero elapsed).
  /// 5. Multiple check-ins & check-outs in a single day (accumulates all completed work sessions + active session).
  /// 6. Shift finished/ended (stops ticking, freezes at total completed time with "(Done)").
  int _calculateShiftWorkedSeconds(TodayAttendanceModel today) {
    final now = DateTime.now();

    // 1. Primary Strategy: Calculate from individual attendance timeline segments (Precision standard)
    if (today.segments.isNotEmpty) {
      // Collect all break intervals for mathematically precise deduction
      final List<_TimeInterval> breakIntervals = [];
      for (final s in today.segments) {
        if (s.kind.toLowerCase() == 'break') {
          final bStart = s.startsAt ?? _parseTimeToday(s.starts ?? '');
          if (bStart != null) {
            final bEnd = s.endsAt ?? _parseTimeToday(s.ends ?? '') ?? (today.isOnBreak ? now : bStart);
            if (bEnd.isAfter(bStart)) {
              breakIntervals.add(_TimeInterval(bStart, bEnd));
            }
          }
        }
      }

      int totalNetWorkSeconds = 0;
      bool hasActiveWorkSegment = false;

      for (final s in today.segments) {
        if (s.kind.toLowerCase() != 'work') continue;

        final wStart = s.startsAt ?? _parseTimeToday(s.starts ?? '');
        if (wStart == null) continue;

        if (s.endsAt == null && (s.ends == null || s.ends == '--:--')) {
          hasActiveWorkSegment = true;
        }
        final wEnd = s.endsAt ?? _parseTimeToday(s.ends ?? '') ?? (today.isCheckedIn ? now : wStart);
        if (!wEnd.isAfter(wStart)) continue;

        final int grossWork = wEnd.difference(wStart).inSeconds;

        // Deduct break intervals that overlap with this work segment
        int breakDeduction = 0;
        for (final b in breakIntervals) {
          final overlapStart = wStart.isAfter(b.start) ? wStart : b.start;
          final overlapEnd = wEnd.isBefore(b.end) ? wEnd : b.end;
          if (overlapEnd.isAfter(overlapStart)) {
            breakDeduction += overlapEnd.difference(overlapStart).inSeconds;
          }
        }

        final netWork = math.max(0, grossWork - breakDeduction);
        totalNetWorkSeconds += netWork;
      }

      // Fallback: If checked in but no open work segment was marked, add elapsed time from checkInDateTime
      if (!hasActiveWorkSegment && today.isCheckedIn) {
        final activeStart = today.checkInDateTime ?? today.firstInDateTime;
        if (activeStart != null && now.isAfter(activeStart)) {
          int activeGross = now.difference(activeStart).inSeconds;
          int activeBreakDeduction = 0;
          for (final b in breakIntervals) {
            final overlapStart = activeStart.isAfter(b.start) ? activeStart : b.start;
            final overlapEnd = now.isBefore(b.end) ? now : b.end;
            if (overlapEnd.isAfter(overlapStart)) {
              activeBreakDeduction += overlapEnd.difference(overlapStart).inSeconds;
            }
          }
          totalNetWorkSeconds += math.max(0, activeGross - activeBreakDeduction);
        }
      }

      // When live total is calculated:
      // If server baseline workedMinutes is significantly higher (e.g. earlier unlisted historical sessions),
      // we maintain the baseline while ensuring the live seconds tick seamlessly!
      if (totalNetWorkSeconds > 0) {
        if (today.workedMinutes * 60 > totalNetWorkSeconds + 120) {
          return (today.workedMinutes * 60) + (totalNetWorkSeconds % 60);
        }
        return totalNetWorkSeconds;
      }
    }

    // 2. Direct Strategy: If server response did not provide segments array or segments calculation yielded 0
    final int baseSeconds = today.workedMinutes * 60;
    final int breakSec = _calculateShiftBreakSeconds(today);

    if (today.isCheckedIn) {
      if (today.isOnBreak) {
        // Paused at worked time before break
        final start = today.firstInDateTime ?? today.checkInDateTime;
        final bStart = today.breakStartDateTime ?? (today.breakSince != null ? _parseTimeToday(today.breakSince!) : null);
        if (start != null && bStart != null && bStart.isAfter(start)) {
          final gross = bStart.difference(start).inSeconds;
          return math.max(baseSeconds, gross - (today.breakMinutes * 60));
        }
        return baseSeconds;
      }

      final start = today.firstInDateTime ?? today.checkInDateTime;
      if (start != null && now.isAfter(start)) {
        final grossDiff = now.difference(start).inSeconds;
        final netDiff = math.max(0, grossDiff - breakSec);
        if (netDiff > 0) {
          if (baseSeconds > netDiff + 120) {
            return baseSeconds + (netDiff % 60);
          }
          return netDiff;
        }
      }
      return baseSeconds;
    }

    // Checked out
    return baseSeconds;
  }

  /// Calculates total break seconds today.
  /// When on break, includes previous completed breaks + real-time elapsed seconds of active break.
  /// When off break, returns exact accumulated completed break seconds.
  /// Resumes seamlessly across multiple breaks in a single day.
  int _calculateShiftBreakSeconds(TodayAttendanceModel today) {
    final now = DateTime.now();

    // 1. Calculate from individual attendance timeline segments (Precision standard)
    if (today.segments.isNotEmpty) {
      int totalBreakSeconds = 0;
      bool hasActiveBreakSegment = false;

      for (final segment in today.segments) {
        final isBreak = segment.kind.toLowerCase() == 'break';
        if (!isBreak) continue;

        final start = segment.startsAt ?? _parseTimeToday(segment.starts ?? '');
        if (start != null) {
          if (segment.endsAt == null && (segment.ends == null || segment.ends == '--:--')) {
            hasActiveBreakSegment = true;
          }
          final end = segment.endsAt ?? _parseTimeToday(segment.ends ?? '') ?? (today.isOnBreak ? now : start);
          final diff = end.difference(start).inSeconds;
          if (diff > 0) {
            totalBreakSeconds += diff;
          }
        }
      }

      if (totalBreakSeconds > 0) {
        if (!hasActiveBreakSegment && today.isOnBreak) {
          final breakStart = today.breakStartDateTime ??
              (today.breakSince != null ? _parseTimeToday(today.breakSince!) : null);
          if (breakStart != null && now.isAfter(breakStart)) {
            totalBreakSeconds += now.difference(breakStart).inSeconds;
          }
        }
        if (today.breakMinutes * 60 > totalBreakSeconds + 120) {
          return (today.breakMinutes * 60) + (totalBreakSeconds % 60);
        }
        return totalBreakSeconds;
      }
    }

    // 2. Direct Fallback Strategy: If segments array is not provided
    final int baseBreakSeconds = today.breakMinutes * 60;
    if (today.isOnBreak) {
      final breakStart = today.breakStartDateTime ??
          (today.breakSince != null ? _parseTimeToday(today.breakSince!) : null) ??
          today.checkInDateTime;
      if (breakStart != null && now.isAfter(breakStart)) {
        final diff = now.difference(breakStart).inSeconds;
        return baseBreakSeconds + diff;
      }
      return baseBreakSeconds;
    }
    return baseBreakSeconds;
  }

  DateTime? _parseTimeToday(String timeStr) {
    return parseFlexibleDateTime(timeStr);
  }

  /// Calculates and updates active shift elapsed time if checked in
  @visibleForTesting
  void updateRunningShiftTimer() => _updateRunningShiftTimer();

  void _updateRunningShiftTimer() {
    final today = dashboardData.value?.todayAttendance;
    if (today == null) {
      elapsedShiftTimer.value = '00:00:00';
      elapsedHoursMinutes.value = '00:00';
      elapsedSeconds.value = '00';
      elapsedBreakTimer.value = '00:00:00';
      elapsedBreakHoursMinutes.value = '00:00';
      elapsedBreakSeconds.value = '00';
      pausedWorkDuration.value = '0h 00m';
      return;
    }

    final int workSeconds = _calculateShiftWorkedSeconds(today);
    final int breakSeconds = _calculateShiftBreakSeconds(today);

    final String wHours = (workSeconds ~/ 3600).toString().padLeft(2, '0');
    final String wMinutes = ((workSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final String wSec = (workSeconds % 60).toString().padLeft(2, '0');

    final String bHours = (breakSeconds ~/ 3600).toString().padLeft(2, '0');
    final String bMinutes = ((breakSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final String bSec = (breakSeconds % 60).toString().padLeft(2, '0');

    elapsedBreakTimer.value = '${bHours}h ${bMinutes}m ${bSec}s';
    elapsedBreakHoursMinutes.value = '$bHours:$bMinutes';
    elapsedBreakSeconds.value = bSec;
    pausedWorkDuration.value = '${int.parse(wHours)}h ${wMinutes}m';

    // Case 1: Employee is NOT checked in
    if (!today.isCheckedIn) {
      final bool hasEnded = workSeconds > 0 ||
          today.workedMinutes > 0 ||
          (today.checkOutTime != '--:--' && today.checkOutTime.isNotEmpty) ||
          (today.latestCheckOutTime != null);

      if (hasEnded) {
        // Shift has ended / completed
        final String formattedDone = '${int.parse(wHours)}h ${wMinutes}m';
        elapsedShiftTimer.value = '$formattedDone (Done)';
        elapsedHoursMinutes.value = '$wHours:$wMinutes';
        elapsedSeconds.value = wSec;
      } else {
        // Not checked in yet today (Shift has not started)
        elapsedShiftTimer.value = '00:00:00';
        elapsedHoursMinutes.value = '00:00';
        elapsedSeconds.value = '00';
      }
      return;
    }

    // Case 2: Employee is ON BREAK
    // Shift/Work timer is PAUSED at completed worked hours.
    // Break timer is LIVE TICKING in foreground display!
    if (today.isOnBreak) {
      elapsedShiftTimer.value = '${wHours}h ${wMinutes}m (Paused)';
      elapsedHoursMinutes.value = '$bHours:$bMinutes';
      elapsedSeconds.value = bSec;
      return;
    }

    // Case 3: Employee is actively CHECKED IN & WORKING
    // Work timer is LIVE TICKING in foreground display!
    elapsedShiftTimer.value = '${wHours}h ${wMinutes}m ${wSec}s';
    elapsedHoursMinutes.value = '$wHours:$wMinutes';
    elapsedSeconds.value = wSec;

    // Reactively sync workingHours so card metrics show live elapsed progression
    final currentHours = '${int.parse(wHours)}h ${wMinutes}m';
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
    // If logged in as Company / Organization, do not call employee personal attendance endpoints
    if (AppPreferences.isCompanyMode) {
      dashboardData.value = null;
      return;
    }

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
      isAccessRestricted.value = false;
      accessRestrictedMessage.value = '';

      final result = await repo.fetchDashboardData();
      dashboardData.value = result;
      _updateRunningShiftTimer();

      // According to api.md Phase 10:
      // When requires specifies face == 'match' and face_saved: true,
      // proactively fetch and sync the enrolled face image via GET /me/face
      final reqs = result?.todayAttendance.requires;
      if (reqs != null && reqs.face == 'match' && reqs.faceSaved) {
        unawaited(_syncServerFaceQuietly());
      }
    } on ApiException catch (e) {
      if (e.isForbidden) {
        dashboardData.value = null;
        isAccessRestricted.value = true;
        accessRestrictedMessage.value = e.message.isNotEmpty
            ? e.message
            : 'Personal attendance is restricted for your current role scope.';
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Quietly downloads enrolled face image from GET /me/face into local memory cache
  Future<void> _syncServerFaceQuietly() async {
    try {
      final faceRepo = FaceRecognitionRepo();
      await faceRepo.fetchAndSyncServerFace();
    } catch (_) {}
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
      } else if (allowed.contains('in')) {
        // Overtime single-button toggle mode on server: accepts 'in' to close open session
        punchKind = 'in';
      } else {
        final refusal = currentAttendance.refusals['out']?.message ??
            'Check-out is not allowed right now.';
        CustomSnackbar.showError(message: refusal);
        return;
      }
    }

    final requires = currentAttendance.requires;

    // 0. Requirement Check: GPS Location Geofencing
    LocationResult? locationResult;
    if (requires?.position == true) {
      try {
        isPunching.value = true;
        locationResult = await _acquireLocationIfRequired(requires);
        if (locationResult == null) {
          return;
        }
      } finally {
        isPunching.value = false;
      }
    }

    // 1. Requirement Check: AI Face Recognition Biometric (when face == 'match')
    if (requires != null && requires.face == 'match') {
      final punchResult = await Get.toNamed(
        Routes.FACE_RECOGNITION,
        arguments: {
          'isPunchMode': true,
          'punchKind': punchKind,
          'requires': requires,
        },
      );

      // If face was captured and returned back, perform punch directly on dashboard with loading
      if (punchResult is Map && punchResult['photoFile'] is File) {
        final File photoFile = punchResult['photoFile'] as File;
        final bool faceConsent = punchResult['faceConsent'] == true;
        final double faceScore = (punchResult['faceScore'] as num?)?.toDouble() ?? 100.0;
        final String faceMatch = punchResult['faceMatch']?.toString() ?? 'matched';

        try {
          isPunching.value = true;
          await HapticFeedback.mediumImpact();

          final updatedAttendance = await repo.submitPunch(
            kind: punchKind,
            latitude: locationResult?.latitude,
            longitude: locationResult?.longitude,
            accuracyMeters: locationResult?.accuracyMeters,
            isMocked: locationResult?.isMocked ?? false,
            photoFile: photoFile,
            faceConsent: faceConsent,
            faceScore: faceScore,
            faceMatch: faceMatch,
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
              message: _getPunchSuccessMessage(updatedAttendance, punchKind),
            );
          } else {
            await loadDashboard();
          }
        } finally {
          isPunching.value = false;
        }
        return;
      }

      if (punchResult == true) {
        await loadDashboard();
      }
      return;
    }

    // 2. Requirement Check: Front Camera Selfie Photo Verification (when photo == true or face == 'photo')
    File? selfiePhoto;
    if (requires?.photo == true || requires?.face == 'photo') {
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
        latitude: locationResult?.latitude,
        longitude: locationResult?.longitude,
        accuracyMeters: locationResult?.accuracyMeters,
        isMocked: locationResult?.isMocked ?? false,
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
          message: _getPunchSuccessMessage(updatedAttendance, punchKind),
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
    if (kDebugMode) {
      debugPrint(
        '>>> [DashboardController -> handleBreakAction()] Triggered. isBreakLoading: ${isBreakLoading.value}, isPunching: ${isPunching.value}, isLoading: ${isLoading.value}',
      );
    }
    if (isBreakLoading.value || isPunching.value || isLoading.value) return;

    final currentAttendance = dashboardData.value?.todayAttendance;
    if (currentAttendance == null) {
      if (kDebugMode) {
        debugPrint(
          '>>> [DashboardController -> handleBreakAction()] Aborted: todayAttendance is null',
        );
      }
      CustomSnackbar.showError(message: 'Attendance data is unavailable.');
      return;
    }

    final isOnBreak = currentAttendance.isOnBreak;
    final allowed = currentAttendance.allowed;
    final String punchKind = isOnBreak ? 'break_end' : 'break_start';

    if (kDebugMode) {
      debugPrint(
        '>>> [DashboardController -> handleBreakAction()] State: isOnBreak=$isOnBreak, punchKind=$punchKind, allowed=$allowed, requires=${currentAttendance.requires?.position}',
      );
    }

    if (!allowed.contains(punchKind)) {
      if (currentAttendance.isCheckedIn && !isOnBreak) {
        CustomSnackbar.showInfo(
          message: 'Breaks are not permitted during overtime hours. Please swipe to check out to pause.',
        );
      } else {
        final refusal = currentAttendance.refusals[punchKind]?.message ??
            (isOnBreak
                ? 'Ending break is not allowed right now.'
                : 'Taking a break is not allowed right now.');
        CustomSnackbar.showError(message: refusal);
      }
      return;
    }

    final requires = currentAttendance.requires;

    // 0. Requirement Check: GPS Location Geofencing
    LocationResult? locationResult;
    if (requires?.position == true) {
      try {
        isBreakLoading.value = true;
        if (kDebugMode) {
          debugPrint(
            '>>> [DashboardController -> handleBreakAction()] GPS required by server. Acquiring location...',
          );
        }
        locationResult = await _acquireLocationIfRequired(requires);
        if (locationResult == null) {
          if (kDebugMode) {
            debugPrint(
              '>>> [DashboardController -> handleBreakAction()] GPS acquisition failed or was cancelled.',
            );
          }
          return;
        }
        if (kDebugMode) {
          debugPrint(
            '>>> [DashboardController -> handleBreakAction()] GPS acquired successfully: (${locationResult.latitude}, ${locationResult.longitude}), acc: ${locationResult.accuracyMeters}m',
          );
        }
      } finally {
        isBreakLoading.value = false;
      }
    }

    // 1. Requirement Check: AI Face Recognition Biometric (when face == 'match')
    if (requires != null && requires.face == 'match') {
      final punchResult = await Get.toNamed(
        Routes.FACE_RECOGNITION,
        arguments: {
          'isPunchMode': true,
          'punchKind': punchKind,
          'requires': requires,
        },
      );

      // If face was captured and returned back, perform punch directly on dashboard with loading
      if (punchResult is Map && punchResult['photoFile'] is File) {
        final File photoFile = punchResult['photoFile'] as File;
        final bool faceConsent = punchResult['faceConsent'] == true;
        final double faceScore = (punchResult['faceScore'] as num?)?.toDouble() ?? 100.0;
        final String faceMatch = punchResult['faceMatch']?.toString() ?? 'matched';

        try {
          isBreakLoading.value = true;
          await HapticFeedback.mediumImpact();

          final updatedAttendance = await repo.submitPunch(
            kind: punchKind,
            latitude: locationResult?.latitude,
            longitude: locationResult?.longitude,
            accuracyMeters: locationResult?.accuracyMeters,
            isMocked: locationResult?.isMocked ?? false,
            photoFile: photoFile,
            faceConsent: faceConsent,
            faceScore: faceScore,
            faceMatch: faceMatch,
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
              message: _getPunchSuccessMessage(updatedAttendance, punchKind),
            );
          } else {
            await loadDashboard();
          }
        } finally {
          isBreakLoading.value = false;
        }
        return;
      }

      if (punchResult == true) {
        await loadDashboard();
      }
      return;
    }

    // 2. Requirement Check: Front Camera Selfie Photo Verification (when photo == true or face == 'photo')
    File? selfiePhoto;
    if (requires?.photo == true || requires?.face == 'photo') {
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
        latitude: locationResult?.latitude,
        longitude: locationResult?.longitude,
        accuracyMeters: locationResult?.accuracyMeters,
        isMocked: locationResult?.isMocked ?? false,
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
          message: _getPunchSuccessMessage(updatedAttendance, punchKind),
        );
      } else {
        await loadDashboard();
      }
    } finally {
      isBreakLoading.value = false;
    }
  }

  /// Derives accurate user-facing success feedback strictly from server-assigned punch role
  String _getPunchSuccessMessage(TodayAttendanceModel attendance, String attemptedKind) {
    final punch = attendance.punch;
    final role = punch?.role.toLowerCase() ?? '';

    if (role == 'check_out') {
      final timeStr = punch?.time.isNotEmpty == true ? ' at ${punch!.time}' : '';
      final otStr = (attendance.overtime.isNotEmpty && attendance.overtime != '0:00')
          ? ' • Overtime: ${attendance.overtime}'
          : '';
      return 'Checked out successfully! Shift logged$timeStr$otStr.';
    } else if (role == 'check_in') {
      final timeStr = punch?.time.isNotEmpty == true ? ' at ${punch!.time}' : '';
      final isResume = attendance.latestCheckOutTime != null;
      final actionLabel = isResume ? 'Session resumed' : 'Shift started';
      return 'Checked in successfully! $actionLabel$timeStr.';
    } else if (role == 'break_start') {
      final timeStr = punch?.time.isNotEmpty == true ? ' at ${punch!.time}' : '';
      return 'Break started$timeStr.';
    } else if (role == 'break_end') {
      final timeStr = punch?.time.isNotEmpty == true ? ' at ${punch!.time}' : '';
      return 'Break ended$timeStr. Welcome back!';
    } else if (role == 'ignored') {
      return punch?.reasonLabel ?? 'Punch was recorded but ignored by attendance rules.';
    }

    if (attendance.isCheckedIn) {
      return 'Checked in successfully! Shift started.';
    } else if (attendance.isOnBreak) {
      return 'Break started.';
    } else if (attemptedKind == 'out') {
      return 'Checked out successfully! Shift logged.';
    } else if (attemptedKind == 'break_end') {
      return 'Break ended. Welcome back!';
    } else {
      return 'Punch registered successfully.';
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

  /// Acquires GPS coordinates if server policy requires position
  Future<LocationResult?> _acquireLocationIfRequired(
    AttendanceRequiresModel? requires,
  ) async {
    if (requires?.position != true) {
      return null;
    }

    try {
      if (kDebugMode) {
        debugPrint(
          '>>> [DashboardController -> _acquireLocationIfRequired()] Requesting LocationService.getCurrentLocation()...',
        );
      }
      final locService = LocationService();
      final result = await locService.getCurrentLocation();

      if (kDebugMode) {
        debugPrint(
          '>>> [DashboardController -> _acquireLocationIfRequired()] Received result: status=${result.status}, isSuccess=${result.isSuccess}, error="${result.errorMessage}"',
        );
      }

      // Case 1: Device Location Services (GPS) are turned off -> Interactive Dialog with Direct Settings link
      if (result.status == LocationResultStatus.serviceDisabled) {
        final confirmed = await _showLocationDialog(
          title: 'Enable Location Services',
          message:
              'Company policy requires GPS to record your attendance. Please turn on Location Services (GPS) on your device.',
          buttonText: 'Open Settings',
          icon: Icons.location_off_rounded,
        );
        if (confirmed) {
          await locService.openLocationSettings();
        }
        return null;
      }

      // Case 2: Location permission is permanently denied -> Interactive Dialog with App Settings link
      if (result.status == LocationResultStatus.permissionDeniedForever) {
        final confirmed = await _showLocationDialog(
          title: 'Location Permission Required',
          message:
              'Location access is permanently disabled for AMS 2. Please allow "While Using App" location permissions in App Settings.',
          buttonText: 'App Settings',
          icon: Icons.security_rounded,
        );
        if (confirmed) {
          await locService.openAppSettings();
        }
        return null;
      }

      // Case 2b: Approximate selected instead of Precise -> Interactive Dialog to enable in App Settings
      if (result.status == LocationResultStatus.preciseRequired) {
        final confirmed = await _showLocationDialog(
          title: 'Precise Location Required',
          message:
              'Company policy requires accurate GPS to verify your attendance within office geofence. Please turn on "Use precise location" in App Settings.',
          buttonText: 'Enable in Settings',
          icon: Icons.my_location_rounded,
        );
        if (confirmed) {
          await locService.openAppSettings();
        }
        return null;
      }

      // Case 3: Permission denied by user on in-app prompt
      if (result.status == LocationResultStatus.permissionDenied) {
        CustomSnackbar.showError(
          title: 'Permission Denied',
          message:
              'Location permission is required to verify your attendance within office geofence.',
        );
        return null;
      }

      // Case 4: Weak accuracy (> 150m), Mock location, or Timeout
      if (!result.isSuccess) {
        final String title;
        switch (result.status) {
          case LocationResultStatus.timeout:
            title = 'GPS Timeout';
            break;
          case LocationResultStatus.accuracyTooLow:
            title = 'Weak GPS Signal';
            break;
          case LocationResultStatus.mocked:
            title = 'Mock Location Detected';
            break;
          case LocationResultStatus.preciseRequired:
            title = 'Precise Location Required';
            break;
          case LocationResultStatus.permissionDenied:
          case LocationResultStatus.permissionDeniedForever:
            title = 'Location Permission Required';
            break;
          default:
            title = 'Location Required';
        }

        CustomSnackbar.showError(
          title: title,
          message: result.errorMessage ??
              'Your position is needed to punch. Allow location access and try again.',
        );
        return null;
      }

      return result;
    } catch (e) {
      CustomSnackbar.showError(
        title: 'Location Error',
        message: 'Failed to acquire device location: $e',
      );
      return null;
    }
  }

  /// Interactive dialog guiding user to enable GPS or grant permissions with a single tap
  Future<bool> _showLocationDialog({
    required String title,
    required String message,
    required String buttonText,
    required IconData icon,
  }) async {
    HapticFeedback.mediumImpact();
    final result = await Get.dialog<bool>(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        backgroundColor: AppColors.cardBackground,
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomStateView(
                icon: icon,
                iconColor: AppColors.secondary,
                iconBackgroundColor: AppColors.secondary.withValues(alpha: 0.12),
                title: title,
                message: message,
                padding: EdgeInsets.zero,
              ),
              AppSpaces.vSpace20,
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Cancel',
                      isOutlined: true,
                      borderColor: AppColors.borderColor,
                      textColor: AppColors.subTextColor,
                      height: 42.h,
                      borderRadius: 12.r,
                      onPressed: () => Get.back(result: false),
                    ),
                  ),
                  AppSpaces.hSpace12,
                  Expanded(
                    child: CustomButton(
                      text: buttonText,
                      isGradient: true,
                      height: 42.h,
                      borderRadius: 12.r,
                      onPressed: () => Get.back(result: true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
    return result == true;
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

class _TimeInterval {
  final DateTime start;
  final DateTime end;
  const _TimeInterval(this.start, this.end);
}
