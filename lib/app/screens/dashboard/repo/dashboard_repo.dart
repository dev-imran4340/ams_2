import 'dart:async';
import '../../../api/app_preferences.dart';
import '../model/dashboard_model.dart';

class DashboardRepo {
  /// Fetches UI mock attendance and monthly summary metrics
  Future<DashboardDataModel?> fetchDashboardData() async {
    // Brief delay to simulate smooth UI state transition
    await Future.delayed(const Duration(milliseconds: 200));

    TodayAttendanceModel today;
    final savedAttendance = AppPreferences.todayAttendance;
    if (savedAttendance != null) {
      try {
        today = TodayAttendanceModel.fromJson(savedAttendance);
      } catch (_) {
        today = _defaultUncheckedAttendance();
      }
    } else {
      today = _defaultUncheckedAttendance();
    }

    return DashboardDataModel(
      todayAttendance: today,
      monthlySummary: MonthlySummaryModel(
        totalDays: 30,
        presentDays: today.isCheckedIn || today.checkOutTime != '--:--' ? 22 : 21,
        lateDays: 2,
        absentDays: 0,
        attendanceRate: 94.5,
        monthName: 'October 2026',
      ),
    );
  }

  TodayAttendanceModel _defaultUncheckedAttendance() {
    return TodayAttendanceModel(
      checkInTime: '--:--',
      checkOutTime: '--:--',
      workingHours: '00h 00m',
      shiftRemaining: '09h 00m',
      overtime: '+00h 00m',
      isCheckedIn: false,
      status: 'Not Checked In',
      officeRadiusStatus: 'Inside Office Perimeter (25m)',
      shiftTiming: '00:00',
      shiftName: 'General Shift',
      checkInDateTime: null,
    );
  }

  /// Toggles punch in/out attendance state with real-time timestamps
  Future<TodayAttendanceModel?> togglePunch(bool isCheckIn) async {
    await Future.delayed(const Duration(milliseconds: 250));

    final now = DateTime.now();
    final formattedTime = _formatTime(now);

    final savedAttendance = AppPreferences.todayAttendance;
    TodayAttendanceModel prev;
    if (savedAttendance != null) {
      try {
        prev = TodayAttendanceModel.fromJson(savedAttendance);
      } catch (_) {
        prev = _defaultUncheckedAttendance();
      }
    } else {
      prev = _defaultUncheckedAttendance();
    }

    TodayAttendanceModel updated;

    if (isCheckIn) {
      // User checks in: record real-time timestamp, set timer from 0
      updated = TodayAttendanceModel(
        checkInTime: formattedTime,
        checkOutTime: '--:--',
        workingHours: '00h 00m',
        shiftRemaining: '09h 00m',
        overtime: '+00h 00m',
        isCheckedIn: true,
        status: 'On Time',
        officeRadiusStatus: 'Inside Office Perimeter (25m)',
        shiftTiming: '$formattedTime - In Progress',
        shiftName: 'General Shift',
        checkInDateTime: now,
      );
    } else {
      // User checks out: record real-time check-out, calculate total time between check-in and check-out
      final checkInDt = prev.checkInDateTime ?? now;
      final diff = now.difference(checkInDt);
      final hours = diff.inHours.toString().padLeft(2, '0');
      final mins = (diff.inMinutes % 60).toString().padLeft(2, '0');
      final workingHoursStr = '${hours}h ${mins}m';

      final effectiveCheckIn =
          prev.checkInTime == '--:--' ? formattedTime : prev.checkInTime;

      updated = TodayAttendanceModel(
        checkInTime: effectiveCheckIn,
        checkOutTime: formattedTime,
        workingHours: workingHoursStr,
        shiftRemaining: '00h 00m',
        overtime: diff.inHours >= 9 ? '+0${diff.inHours - 9}h 00m' : '+00h 00m',
        isCheckedIn: false,
        status: 'Completed',
        officeRadiusStatus: 'Inside Office Perimeter (25m)',
        shiftTiming: '$effectiveCheckIn - $formattedTime',
        shiftName: 'General Shift',
        checkInDateTime: null, // Timer stops!
      );
    }

    // Persist today's attendance in AppPreferences
    await AppPreferences.setTodayAttendance(updated.toJson());

    return updated;
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final minuteStr = dt.minute.toString().padLeft(2, '0');
    final hourStr = hour.toString().padLeft(2, '0');
    return '$hourStr:$minuteStr $period';
  }
}
