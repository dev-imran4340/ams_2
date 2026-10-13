class AttendanceDayLog {
  final DateTime date;
  final String formattedDate;
  final String dayName;
  final String checkInTime;
  final String checkOutTime;
  final String workingHours;
  final String breakDuration;
  final String status; // 'On-Time', 'Late', 'Absent', 'Leave', 'Holiday'
  final String workLocation; // 'HQ Office', 'Remote'
  final bool isSynced;

  AttendanceDayLog({
    required this.date,
    required this.formattedDate,
    required this.dayName,
    required this.checkInTime,
    required this.checkOutTime,
    required this.workingHours,
    required this.breakDuration,
    required this.status,
    required this.workLocation,
    this.isSynced = true,
  });

  factory AttendanceDayLog.fromJson(Map<String, dynamic> json) {
    return AttendanceDayLog(
      date: json['date'] != null
          ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      formattedDate: json['formatted_date']?.toString() ?? '',
      dayName: json['day_name']?.toString() ?? '',
      checkInTime: json['check_in_time']?.toString() ?? '--:--',
      checkOutTime: json['check_out_time']?.toString() ?? '--:--',
      workingHours: json['working_hours']?.toString() ?? '00h 00m',
      breakDuration: json['break_duration']?.toString() ?? '00m',
      status: json['status']?.toString() ?? 'Absent',
      workLocation: json['work_location']?.toString() ?? 'HQ Office',
      isSynced: json['is_synced'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'formatted_date': formattedDate,
      'day_name': dayName,
      'check_in_time': checkInTime,
      'check_out_time': checkOutTime,
      'working_hours': workingHours,
      'break_duration': breakDuration,
      'status': status,
      'work_location': workLocation,
      'is_synced': isSynced,
    };
  }

  AttendanceDayLog copyWith({
    DateTime? date,
    String? formattedDate,
    String? dayName,
    String? checkInTime,
    String? checkOutTime,
    String? workingHours,
    String? breakDuration,
    String? status,
    String? workLocation,
    bool? isSynced,
  }) {
    return AttendanceDayLog(
      date: date ?? this.date,
      formattedDate: formattedDate ?? this.formattedDate,
      dayName: dayName ?? this.dayName,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      workingHours: workingHours ?? this.workingHours,
      breakDuration: breakDuration ?? this.breakDuration,
      status: status ?? this.status,
      workLocation: workLocation ?? this.workLocation,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}

class MonthlyTelemetrySummary {
  final int totalDays;
  final int presentCount;
  final int lateCount;
  final int absentCount;
  final int leaveCount;
  final double attendanceRate;

  MonthlyTelemetrySummary({
    required this.totalDays,
    required this.presentCount,
    required this.lateCount,
    required this.absentCount,
    required this.leaveCount,
    required this.attendanceRate,
  });

  factory MonthlyTelemetrySummary.fromJson(Map<String, dynamic> json) {
    return MonthlyTelemetrySummary(
      totalDays: json['total_days'] as int? ?? 31,
      presentCount: json['present_count'] as int? ?? 21,
      lateCount: json['late_count'] as int? ?? 2,
      absentCount: json['absent_count'] as int? ?? 0,
      leaveCount: json['leave_count'] as int? ?? 1,
      attendanceRate: (json['attendance_rate'] as num?)?.toDouble() ?? 94.5,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_days': totalDays,
      'present_count': presentCount,
      'late_count': lateCount,
      'absent_count': absentCount,
      'leave_count': leaveCount,
      'attendance_rate': attendanceRate,
    };
  }
}

class AttendanceHistoryResponse {
  final List<AttendanceDayLog> logs;
  final MonthlyTelemetrySummary summary;

  AttendanceHistoryResponse({
    required this.logs,
    required this.summary,
  });

  factory AttendanceHistoryResponse.fromJson(Map<String, dynamic> json) {
    final rawLogs = json['logs'] as List<dynamic>? ?? [];
    final parsedLogs = rawLogs
        .map((e) => AttendanceDayLog.fromJson(e as Map<String, dynamic>))
        .toList();

    return AttendanceHistoryResponse(
      logs: parsedLogs,
      summary: json['summary'] is Map<String, dynamic>
          ? MonthlyTelemetrySummary.fromJson(
              json['summary'] as Map<String, dynamic>,
            )
          : MonthlyTelemetrySummary(
              totalDays: 31,
              presentCount: 21,
              lateCount: 2,
              absentCount: 0,
              leaveCount: 1,
              attendanceRate: 94.5,
            ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'logs': logs.map((e) => e.toJson()).toList(),
      'summary': summary.toJson(),
    };
  }
}
