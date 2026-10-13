class TodayAttendanceModel {
  final String checkInTime;
  final String checkOutTime;
  final String workingHours;
  final String shiftRemaining;
  final String overtime;
  final bool isCheckedIn;
  final String status; // 'On Time', 'Late', 'Not Checked In'
  final String officeRadiusStatus; // 'Inside Office Perimeter (25m)', 'Outside'
  final String shiftTiming; // '09:00 AM - 06:00 PM'
  final String shiftName; // 'General Shift'
  final DateTime? checkInDateTime;

  TodayAttendanceModel({
    required this.checkInTime,
    required this.checkOutTime,
    required this.workingHours,
    required this.shiftRemaining,
    required this.overtime,
    required this.isCheckedIn,
    required this.status,
    required this.officeRadiusStatus,
    required this.shiftTiming,
    required this.shiftName,
    this.checkInDateTime,
  });

  TodayAttendanceModel copyWith({
    String? checkInTime,
    String? checkOutTime,
    String? workingHours,
    String? shiftRemaining,
    String? overtime,
    bool? isCheckedIn,
    String? status,
    String? officeRadiusStatus,
    String? shiftTiming,
    String? shiftName,
    DateTime? checkInDateTime,
  }) {
    return TodayAttendanceModel(
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      workingHours: workingHours ?? this.workingHours,
      shiftRemaining: shiftRemaining ?? this.shiftRemaining,
      overtime: overtime ?? this.overtime,
      isCheckedIn: isCheckedIn ?? this.isCheckedIn,
      status: status ?? this.status,
      officeRadiusStatus: officeRadiusStatus ?? this.officeRadiusStatus,
      shiftTiming: shiftTiming ?? this.shiftTiming,
      shiftName: shiftName ?? this.shiftName,
      checkInDateTime: checkInDateTime ?? this.checkInDateTime,
    );
  }

  factory TodayAttendanceModel.fromJson(Map<String, dynamic> json) {
    return TodayAttendanceModel(
      checkInTime: json['check_in_time']?.toString() ?? '--:--',
      checkOutTime: json['check_out_time']?.toString() ?? '--:--',
      workingHours: json['working_hours']?.toString() ?? '00h 00m',
      shiftRemaining: json['shift_remaining']?.toString() ?? '09h 00m',
      overtime: json['overtime']?.toString() ?? '+00h 00m',
      isCheckedIn: json['is_checked_in'] as bool? ?? false,
      status: json['status']?.toString() ?? 'Not Checked In',
      officeRadiusStatus: json['office_radius_status']?.toString() ??
          'Inside Office Perimeter (25m)',
      shiftTiming: json['shift_timing']?.toString() ?? '09:00 AM - 06:00 PM',
      shiftName: json['shift_name']?.toString() ?? 'General Shift',
      checkInDateTime: json['check_in_timestamp'] != null
          ? DateTime.tryParse(json['check_in_timestamp'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'check_in_time': checkInTime,
      'check_out_time': checkOutTime,
      'working_hours': workingHours,
      'shift_remaining': shiftRemaining,
      'overtime': overtime,
      'is_checked_in': isCheckedIn,
      'status': status,
      'office_radius_status': officeRadiusStatus,
      'shift_timing': shiftTiming,
      'shift_name': shiftName,
      'check_in_timestamp': checkInDateTime?.toIso8601String(),
    };
  }
}

class MonthlySummaryModel {
  final int totalDays;
  final int presentDays;
  final int lateDays;
  final int absentDays;
  final double attendanceRate;
  final String monthName;

  MonthlySummaryModel({
    required this.totalDays,
    required this.presentDays,
    required this.lateDays,
    required this.absentDays,
    required this.attendanceRate,
    required this.monthName,
  });

  factory MonthlySummaryModel.fromJson(Map<String, dynamic> json) {
    return MonthlySummaryModel(
      totalDays: json['total_days'] as int? ?? 30,
      presentDays: json['present_days'] as int? ?? 21,
      lateDays: json['late_days'] as int? ?? 2,
      absentDays: json['absent_days'] as int? ?? 0,
      attendanceRate: (json['attendance_rate'] as num?)?.toDouble() ?? 94.5,
      monthName: json['month_name']?.toString() ?? 'October 2026',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_days': totalDays,
      'present_days': presentDays,
      'late_days': lateDays,
      'absent_days': absentDays,
      'attendance_rate': attendanceRate,
      'month_name': monthName,
    };
  }
}

class DashboardDataModel {
  final TodayAttendanceModel todayAttendance;
  final MonthlySummaryModel monthlySummary;

  DashboardDataModel({
    required this.todayAttendance,
    required this.monthlySummary,
  });

  factory DashboardDataModel.fromJson(Map<String, dynamic> json) {
    return DashboardDataModel(
      todayAttendance: json['today_attendance'] is Map<String, dynamic>
          ? TodayAttendanceModel.fromJson(
              json['today_attendance'] as Map<String, dynamic>)
          : TodayAttendanceModel(
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
      monthlySummary: json['monthly_summary'] is Map<String, dynamic>
          ? MonthlySummaryModel.fromJson(
              json['monthly_summary'] as Map<String, dynamic>)
          : MonthlySummaryModel(
              totalDays: 30,
              presentDays: 21,
              lateDays: 2,
              absentDays: 0,
              attendanceRate: 94.5,
              monthName: 'October 2026',
            ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'today_attendance': todayAttendance.toJson(),
      'monthly_summary': monthlySummary.toJson(),
    };
  }
}
