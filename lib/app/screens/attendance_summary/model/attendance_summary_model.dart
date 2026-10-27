// Attendance Summary Model mapping strictly to GET /me/attendance/summary response.
// Adhering to Phase 9 & 10 live backend specifications with ZERO dummy data.

class AttendanceSummaryDaysModel {
  final int upcoming;
  final int inProgress;
  final int present;
  final int halfDay;
  final int absent;
  final int incomplete;
  final int off;
  final int holiday;
  final int notEmployed;
  final int leave;

  const AttendanceSummaryDaysModel({
    this.upcoming = 0,
    this.inProgress = 0,
    this.present = 0,
    this.halfDay = 0,
    this.absent = 0,
    this.incomplete = 0,
    this.off = 0,
    this.holiday = 0,
    this.notEmployed = 0,
    this.leave = 0,
  });

  factory AttendanceSummaryDaysModel.fromJson(Map<String, dynamic> json) {
    return AttendanceSummaryDaysModel(
      upcoming: json['upcoming'] as int? ?? 0,
      inProgress: json['in_progress'] as int? ?? 0,
      present: json['present'] as int? ?? 0,
      halfDay: json['half_day'] as int? ?? 0,
      absent: json['absent'] as int? ?? 0,
      incomplete: json['incomplete'] as int? ?? 0,
      off: json['off'] as int? ?? 0,
      holiday: json['holiday'] as int? ?? 0,
      notEmployed: json['not_employed'] as int? ?? 0,
      leave: json['leave'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'upcoming': upcoming,
        'in_progress': inProgress,
        'present': present,
        'half_day': halfDay,
        'absent': absent,
        'incomplete': incomplete,
        'off': off,
        'holiday': holiday,
        'not_employed': notEmployed,
        'leave': leave,
      };
}

class AttendanceSummaryMetricCountModel {
  final int count;
  final int minutes;

  const AttendanceSummaryMetricCountModel({
    this.count = 0,
    this.minutes = 0,
  });

  factory AttendanceSummaryMetricCountModel.fromJson(Map<String, dynamic> json) {
    return AttendanceSummaryMetricCountModel(
      count: json['count'] as int? ?? 0,
      minutes: json['minutes'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {'count': count, 'minutes': minutes};
}

class AttendanceSummaryOvertimeModel {
  final int approvedMinutes;
  final int pendingMinutes;

  const AttendanceSummaryOvertimeModel({
    this.approvedMinutes = 0,
    this.pendingMinutes = 0,
  });

  factory AttendanceSummaryOvertimeModel.fromJson(Map<String, dynamic> json) {
    return AttendanceSummaryOvertimeModel(
      approvedMinutes: json['approved_minutes'] as int? ?? 0,
      pendingMinutes: json['pending_minutes'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'approved_minutes': approvedMinutes,
        'pending_minutes': pendingMinutes,
      };
}

class AttendanceSummaryDataModel {
  final AttendanceSummaryDaysModel days;
  final int scheduledDays;
  final int plannedMinutes;
  final int workedMinutes;
  final int countedMinutes;
  final AttendanceSummaryMetricCountModel late;
  final AttendanceSummaryMetricCountModel earlyOut;
  final int shortMinutes;
  final int missingCheckOuts;
  final AttendanceSummaryOvertimeModel overtime;
  final List<dynamic> penalties;

  const AttendanceSummaryDataModel({
    required this.days,
    required this.scheduledDays,
    required this.plannedMinutes,
    required this.workedMinutes,
    required this.countedMinutes,
    required this.late,
    required this.earlyOut,
    required this.shortMinutes,
    required this.missingCheckOuts,
    required this.overtime,
    this.penalties = const [],
  });

  /// Real calculated attendance rate: (present / scheduled_days) * 100
  double get attendanceRate {
    if (scheduledDays <= 0) return 0.0;
    final rate = (days.present / scheduledDays) * 100;
    return double.parse(rate.clamp(0.0, 100.0).toStringAsFixed(1));
  }

  String formatMinutes(int mins) {
    if (mins <= 0) return '0h 00m';
    final h = mins ~/ 60;
    final m = (mins % 60).toString().padLeft(2, '0');
    return '${h}h ${m}m';
  }

  String get plannedHoursFormatted => formatMinutes(plannedMinutes);
  String get workedHoursFormatted => formatMinutes(workedMinutes);
  String get countedHoursFormatted => formatMinutes(countedMinutes);
  String get shortHoursFormatted => formatMinutes(shortMinutes);
  String get lateHoursFormatted => formatMinutes(late.minutes);
  String get earlyOutHoursFormatted => formatMinutes(earlyOut.minutes);
  String get approvedOvertimeFormatted => formatMinutes(overtime.approvedMinutes);
  String get pendingOvertimeFormatted => formatMinutes(overtime.pendingMinutes);

  factory AttendanceSummaryDataModel.fromJson(Map<String, dynamic> json) {
    final daysMap = json['days'] is Map
        ? Map<String, dynamic>.from(json['days'] as Map)
        : <String, dynamic>{};
    final lateMap = json['late'] is Map
        ? Map<String, dynamic>.from(json['late'] as Map)
        : <String, dynamic>{};
    final earlyOutMap = json['early_out'] is Map
        ? Map<String, dynamic>.from(json['early_out'] as Map)
        : <String, dynamic>{};
    final overtimeMap = json['overtime'] is Map
        ? Map<String, dynamic>.from(json['overtime'] as Map)
        : <String, dynamic>{};

    return AttendanceSummaryDataModel(
      days: AttendanceSummaryDaysModel.fromJson(daysMap),
      scheduledDays: json['scheduled_days'] as int? ?? 0,
      plannedMinutes: json['planned_minutes'] as int? ?? 0,
      workedMinutes: json['worked_minutes'] as int? ?? 0,
      countedMinutes: json['counted_minutes'] as int? ?? 0,
      late: AttendanceSummaryMetricCountModel.fromJson(lateMap),
      earlyOut: AttendanceSummaryMetricCountModel.fromJson(earlyOutMap),
      shortMinutes: json['short_minutes'] as int? ?? 0,
      missingCheckOuts: json['missing_check_outs'] as int? ?? 0,
      overtime: AttendanceSummaryOvertimeModel.fromJson(overtimeMap),
      penalties: json['penalties'] is List ? json['penalties'] as List : const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'days': days.toJson(),
        'scheduled_days': scheduledDays,
        'planned_minutes': plannedMinutes,
        'worked_minutes': workedMinutes,
        'counted_minutes': countedMinutes,
        'late': late.toJson(),
        'early_out': earlyOut.toJson(),
        'short_minutes': shortMinutes,
        'missing_check_outs': missingCheckOuts,
        'overtime': overtime.toJson(),
        'penalties': penalties,
      };
}

class AttendanceSummaryResponseModel {
  final AttendanceSummaryDataModel data;
  final String rawMonth;
  final String monthLabel;

  const AttendanceSummaryResponseModel({
    required this.data,
    required this.rawMonth,
    required this.monthLabel,
  });

  factory AttendanceSummaryResponseModel.fromJson(Map<String, dynamic> json) {
    final dataMap = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : <String, dynamic>{};
    final metaMap = json['meta'] is Map
        ? Map<String, dynamic>.from(json['meta'] as Map)
        : <String, dynamic>{};

    final rawM = metaMap['month']?.toString() ?? '';
    String label = rawM;

    if (rawM.contains('-')) {
      final parts = rawM.split('-');
      if (parts.length >= 2) {
        final year = parts[0];
        final mIdx = int.tryParse(parts[1]) ?? 0;
        const months = [
          '',
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December'
        ];
        if (mIdx >= 1 && mIdx <= 12) {
          label = '${months[mIdx]} $year';
        }
      }
    } else if (rawM.isEmpty) {
      final now = DateTime.now();
      const months = [
        '',
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December'
      ];
      label = '${months[now.month]} ${now.year}';
    }

    return AttendanceSummaryResponseModel(
      data: AttendanceSummaryDataModel.fromJson(dataMap),
      rawMonth: rawM,
      monthLabel: label,
    );
  }

  Map<String, dynamic> toJson() => {
        'data': data.toJson(),
        'meta': {'month': rawMonth},
      };
}
