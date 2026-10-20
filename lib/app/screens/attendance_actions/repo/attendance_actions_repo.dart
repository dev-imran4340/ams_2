import 'dart:async';
import '../model/attendance_actions_model.dart';

class AttendanceActionsRepo {
  /// Fetches real-time employee shift telemetry and break status
  Future<EmployeeShiftTelemetry> fetchShiftTelemetry() async {
    await Future.delayed(const Duration(milliseconds: 250));

    return EmployeeShiftTelemetry(
      employeeName: 'Malik Muhammad Imran',
      employeeId: 'EMP-0428',
      designation: 'Senior Software Engineer',
      department: 'Mobile & Cloud Engineering',
      avatarUrl: null,
      isRemote: false,
      workMode: 'On-Site',
      officeRadiusStatus: 'Inside Office Perimeter (25m)',
      isInsidePerimeter: true,
      shiftName: 'General Morning Shift',
      shiftTiming: '09:00 AM - 06:00 PM',
      checkInTime: '09:12 AM',
      checkOutTime: '--:--',
      isCheckedIn: true,
      isOnBreak: false,
      breakStartTime: null,
      totalBreakDuration: '00h 15m',
      allowedBreakLimit: '45 mins',
      todayWorkingHours: '04h 38m',
      checkInDateTime: DateTime.now().subtract(
        const Duration(hours: 4, minutes: 38),
      ),
    );
  }

  /// Check-in punch
  Future<EmployeeShiftTelemetry> punchCheckIn(
    EmployeeShiftTelemetry current,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();
    final timeStr = _formatTime(now);

    return current.copyWith(
      isCheckedIn: true,
      checkInTime: timeStr,
      checkOutTime: '--:--',
      isOnBreak: false,
      checkInDateTime: now,
      todayWorkingHours: '00h 01m',
    );
  }

  /// Check-out punch
  Future<EmployeeShiftTelemetry> punchCheckOut(
    EmployeeShiftTelemetry current,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();
    final timeStr = _formatTime(now);

    return current.copyWith(
      isCheckedIn: false,
      checkOutTime: timeStr,
      isOnBreak: false,
      breakStartTime: null,
    );
  }

  /// Start break
  Future<EmployeeShiftTelemetry> startBreak(
    EmployeeShiftTelemetry current,
  ) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final now = DateTime.now();
    final timeStr = _formatTime(now);

    return current.copyWith(
      isOnBreak: true,
      breakStartTime: timeStr,
    );
  }

  /// End break
  Future<EmployeeShiftTelemetry> endBreak(
    EmployeeShiftTelemetry current,
  ) async {
    await Future.delayed(const Duration(milliseconds: 250));

    return current.copyWith(
      isOnBreak: false,
      breakStartTime: null,
      totalBreakDuration: '00h 30m',
    );
  }

  /// Fetches historical and active money/loan requests
  Future<List<MoneyRequestItem>> fetchMoneyRequests() async {
    await Future.delayed(const Duration(milliseconds: 250));

    return [
      const MoneyRequestItem(
        id: 'REQ-9081',
        type: 'Salary Advance',
        amount: 35000.0,
        currency: 'PKR',
        tenureMonths: 2,
        reason: 'Urgent family medical expenses and healthcare consultation.',
        requestDate: '12 Oct 2026',
        status: 'Approved',
        approvedDate: '13 Oct 2026',
        monthlyDeduction: 17500.0,
      ),
      const MoneyRequestItem(
        id: 'REQ-8842',
        type: 'Personal Loan',
        amount: 75000.0,
        currency: 'PKR',
        tenureMonths: 6,
        reason: 'Home renovation and essential appliance replacement.',
        requestDate: '28 Sep 2026',
        status: 'Disbursed',
        approvedDate: '30 Sep 2026',
        monthlyDeduction: 12500.0,
      ),
      const MoneyRequestItem(
        id: 'REQ-7910',
        type: 'Medical Emergency',
        amount: 25000.0,
        currency: 'PKR',
        tenureMonths: 1,
        reason: 'Hospital laboratory diagnostic tests reimbursement.',
        requestDate: '15 Aug 2026',
        status: 'Approved',
        approvedDate: '16 Aug 2026',
        monthlyDeduction: 25000.0,
      ),
    ];
  }

  /// Submit a new money request
  Future<MoneyRequestItem> submitMoneyRequest({
    required String type,
    required double amount,
    required int tenureMonths,
    required String reason,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final now = DateTime.now();
    final months = [
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
    final dateStr =
        '${now.day.toString().padLeft(2, '0')} ${months[now.month - 1]} ${now.year}';

    return MoneyRequestItem(
      id: 'REQ-${1000 + now.millisecond}',
      type: type,
      amount: amount,
      currency: 'PKR',
      tenureMonths: tenureMonths,
      reason: reason,
      requestDate: dateStr,
      status: 'Pending',
      monthlyDeduction: amount / tenureMonths,
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final minuteStr = dt.minute.toString().padLeft(2, '0');
    final hourStr = hour.toString().padLeft(2, '0');
    return '$hourStr:$minuteStr $period';
  }
}
