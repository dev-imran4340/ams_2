import 'dart:async';
import '../model/dashboard_model.dart';

class DashboardRepo {
  /// Fetches UI mock attendance and monthly summary metrics
  Future<DashboardDataModel?> fetchDashboardData() async {
    // Brief delay to simulate smooth UI state transition
    await Future.delayed(const Duration(milliseconds: 300));

    return DashboardDataModel(
      todayAttendance: TodayAttendanceModel(
        checkInTime: '09:12 AM',
        checkOutTime: '--:--',
        workingHours: '04h 25m',
        shiftRemaining: '03h 35m',
        overtime: '+00h 25m',
        isCheckedIn: true,
        status: 'On Time',
        officeRadiusStatus: 'Inside Office Perimeter (25m)',
        shiftTiming: '09:00 AM - 06:00 PM',
        shiftName: 'General Shift',
        checkInDateTime: DateTime.now().subtract(
          const Duration(hours: 4, minutes: 25),
        ),
      ),
      monthlySummary: MonthlySummaryModel(
        totalDays: 30,
        presentDays: 21,
        lateDays: 2,
        absentDays: 0,
        attendanceRate: 94.5,
        monthName: 'October 2026',
      ),
    );
  }

  /// Toggles punch in/out attendance state locally for UI demonstration
  Future<TodayAttendanceModel?> togglePunch(bool isCheckIn) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final now = DateTime.now();
    final formattedTime = _formatTime(now);

    if (isCheckIn) {
      return TodayAttendanceModel(
        checkInTime: formattedTime,
        checkOutTime: '--:--',
        workingHours: '00h 01m',
        shiftRemaining: '08h 59m',
        overtime: '+00h 00m',
        isCheckedIn: true,
        status: 'On Time',
        officeRadiusStatus: 'Inside Office Perimeter (25m)',
        shiftTiming: '09:00 AM - 06:00 PM',
        shiftName: 'General Shift',
        checkInDateTime: now,
      );
    } else {
      return TodayAttendanceModel(
        checkInTime: '09:12 AM',
        checkOutTime: formattedTime,
        workingHours: '08h 48m',
        shiftRemaining: '00h 00m',
        overtime: '+00h 48m',
        isCheckedIn: false,
        status: 'On Time',
        officeRadiusStatus: 'Inside Office Perimeter (25m)',
        shiftTiming: '09:00 AM - 06:00 PM',
        shiftName: 'General Shift',
        checkInDateTime: null,
      );
    }
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final minuteStr = dt.minute.toString().padLeft(2, '0');
    final hourStr = hour.toString().padLeft(2, '0');
    return '$hourStr:$minuteStr $period';
  }
}
