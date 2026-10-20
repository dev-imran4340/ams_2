class EmployeeShiftTelemetry {
  final String employeeName;
  final String employeeId;
  final String designation;
  final String department;
  final String? avatarUrl;
  final bool isRemote;
  final String workMode; // 'On-Site', 'Remote', 'Hybrid'
  final String officeRadiusStatus;
  final bool isInsidePerimeter;
  final String shiftName;
  final String shiftTiming;
  final String checkInTime;
  final String checkOutTime;
  final bool isCheckedIn;
  final bool isOnBreak;
  final String? breakStartTime;
  final String totalBreakDuration;
  final String allowedBreakLimit;
  final String todayWorkingHours;
  final DateTime? checkInDateTime;

  const EmployeeShiftTelemetry({
    required this.employeeName,
    required this.employeeId,
    required this.designation,
    required this.department,
    this.avatarUrl,
    required this.isRemote,
    required this.workMode,
    required this.officeRadiusStatus,
    required this.isInsidePerimeter,
    required this.shiftName,
    required this.shiftTiming,
    required this.checkInTime,
    required this.checkOutTime,
    required this.isCheckedIn,
    required this.isOnBreak,
    this.breakStartTime,
    required this.totalBreakDuration,
    required this.allowedBreakLimit,
    required this.todayWorkingHours,
    this.checkInDateTime,
  });

  EmployeeShiftTelemetry copyWith({
    String? employeeName,
    String? employeeId,
    String? designation,
    String? department,
    String? avatarUrl,
    bool? isRemote,
    String? workMode,
    String? officeRadiusStatus,
    bool? isInsidePerimeter,
    String? shiftName,
    String? shiftTiming,
    String? checkInTime,
    String? checkOutTime,
    bool? isCheckedIn,
    bool? isOnBreak,
    String? breakStartTime,
    String? totalBreakDuration,
    String? allowedBreakLimit,
    String? todayWorkingHours,
    DateTime? checkInDateTime,
  }) {
    return EmployeeShiftTelemetry(
      employeeName: employeeName ?? this.employeeName,
      employeeId: employeeId ?? this.employeeId,
      designation: designation ?? this.designation,
      department: department ?? this.department,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isRemote: isRemote ?? this.isRemote,
      workMode: workMode ?? this.workMode,
      officeRadiusStatus: officeRadiusStatus ?? this.officeRadiusStatus,
      isInsidePerimeter: isInsidePerimeter ?? this.isInsidePerimeter,
      shiftName: shiftName ?? this.shiftName,
      shiftTiming: shiftTiming ?? this.shiftTiming,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      isCheckedIn: isCheckedIn ?? this.isCheckedIn,
      isOnBreak: isOnBreak ?? this.isOnBreak,
      breakStartTime: breakStartTime ?? this.breakStartTime,
      totalBreakDuration: totalBreakDuration ?? this.totalBreakDuration,
      allowedBreakLimit: allowedBreakLimit ?? this.allowedBreakLimit,
      todayWorkingHours: todayWorkingHours ?? this.todayWorkingHours,
      checkInDateTime: checkInDateTime ?? this.checkInDateTime,
    );
  }
}

class MoneyRequestItem {
  final String id;
  final String type; // 'Salary Advance', 'Personal Loan', 'Medical Emergency'
  final double amount;
  final String currency;
  final int tenureMonths;
  final String reason;
  final String requestDate;
  final String status; // 'Approved', 'Pending', 'Rejected', 'Disbursed'
  final String? approvedDate;
  final double? monthlyDeduction;

  const MoneyRequestItem({
    required this.id,
    required this.type,
    required this.amount,
    this.currency = 'PKR',
    required this.tenureMonths,
    required this.reason,
    required this.requestDate,
    required this.status,
    this.approvedDate,
    this.monthlyDeduction,
  });
}

class MoneyRequestTypeOption {
  final String id;
  final String title;
  final String description;
  final double maxLimit;

  const MoneyRequestTypeOption({
    required this.id,
    required this.title,
    required this.description,
    required this.maxLimit,
  });
}
