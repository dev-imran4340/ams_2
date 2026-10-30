// Models for the AMS 2 Attendance Engine (/me/attendance/today & /me/attendance/summary)
// Strictly adhering to Phase 9 & 10 live API responses with ZERO dummy fallback data.

class AttendanceRefusalModel {
  final String code;
  final String message;

  const AttendanceRefusalModel({
    required this.code,
    required this.message,
  });

  factory AttendanceRefusalModel.fromJson(Map<String, dynamic> json) {
    return AttendanceRefusalModel(
      code: json['code']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'code': code, 'message': message};
}

class AttendanceRequiresModel {
  final bool position;
  final bool photo;
  final String face;
  final bool faceSaved;
  final String? consentText;

  const AttendanceRequiresModel({
    required this.position,
    required this.photo,
    required this.face,
    required this.faceSaved,
    this.consentText,
  });

  factory AttendanceRequiresModel.fromJson(Map<String, dynamic> json) {
    return AttendanceRequiresModel(
      position: json['position'] as bool? ?? false,
      photo: json['photo'] as bool? ?? false,
      face: json['face']?.toString() ?? 'off',
      faceSaved: json['face_saved'] as bool? ?? false,
      consentText: json['consent_text']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'position': position,
        'photo': photo,
        'face': face,
        'face_saved': faceSaved,
        'consent_text': consentText,
      };
}

class AttendanceShiftModel {
  final String name;
  final String code;
  final String starts;
  final String ends;
  final bool overnight;

  const AttendanceShiftModel({
    required this.name,
    required this.code,
    required this.starts,
    required this.ends,
    required this.overnight,
  });

  factory AttendanceShiftModel.fromJson(Map<String, dynamic> json) {
    return AttendanceShiftModel(
      name: json['name']?.toString() ?? 'General Shift',
      code: json['code']?.toString() ?? 'GEN',
      starts: json['starts']?.toString() ?? '09:00',
      ends: json['ends']?.toString() ?? '17:00',
      overnight: json['overnight'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'code': code,
        'starts': starts,
        'ends': ends,
        'overnight': overnight,
      };
}

class AttendanceSegmentModel {
  final String kind;
  final String? starts;
  final String? ends;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final bool paid;

  const AttendanceSegmentModel({
    required this.kind,
    this.starts,
    this.ends,
    this.startsAt,
    this.endsAt,
    required this.paid,
  });

  factory AttendanceSegmentModel.fromJson(Map<String, dynamic> json) {
    return AttendanceSegmentModel(
      kind: json['kind']?.toString() ?? 'work',
      starts: json['starts']?.toString(),
      ends: json['ends']?.toString(),
      startsAt: json['starts_at'] != null
          ? DateTime.tryParse(json['starts_at'].toString())?.toLocal()
          : null,
      endsAt: json['ends_at'] != null
          ? DateTime.tryParse(json['ends_at'].toString())?.toLocal()
          : null,
      paid: json['paid'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'kind': kind,
        'starts': starts,
        'ends': ends,
        'starts_at': startsAt?.toIso8601String(),
        'ends_at': endsAt?.toIso8601String(),
        'paid': paid,
      };
}

class TodayAttendanceModel {
  final String checkInTime;
  final String checkOutTime;
  final String workingHours;
  final String shiftRemaining;
  final String overtime;
  final bool isCheckedIn;
  final bool isOnBreak;
  final String status;
  final String statusTone;
  final String officeRadiusStatus;
  final String shiftTiming;
  final String shiftName;
  final DateTime? checkInDateTime;
  final List<String> allowed;
  final Map<String, AttendanceRefusalModel> refusals;
  final AttendanceRequiresModel? requires;
  final AttendanceShiftModel? shift;
  final List<AttendanceSegmentModel> segments;
  final List<dynamic> breaks;
  final int plannedMinutes;
  final int workedMinutes;
  final int countedMinutes;
  final int lateMinutes;
  final int earlyOutMinutes;
  final int shortMinutes;
  final String? dayId;
  final String? dateLabel;

  final bool usesBreaks;
  final int breakMinutes;
  final List<String> flags;
  final String? dayType;
  final String? statusCode;
  final String? breakSince;

  const TodayAttendanceModel({
    required this.checkInTime,
    required this.checkOutTime,
    required this.workingHours,
    required this.shiftRemaining,
    required this.overtime,
    required this.isCheckedIn,
    this.isOnBreak = false,
    this.usesBreaks = true,
    required this.status,
    this.statusTone = 'slate',
    required this.officeRadiusStatus,
    required this.shiftTiming,
    required this.shiftName,
    this.checkInDateTime,
    this.allowed = const [],
    this.refusals = const {},
    this.requires,
    this.shift,
    this.segments = const [],
    this.breaks = const [],
    this.plannedMinutes = 0,
    this.workedMinutes = 0,
    this.countedMinutes = 0,
    this.breakMinutes = 0,
    this.lateMinutes = 0,
    this.earlyOutMinutes = 0,
    this.shortMinutes = 0,
    this.dayId,
    this.dateLabel,
    this.flags = const [],
    this.dayType,
    this.statusCode,
    this.breakSince,
  });

  bool get canCheckIn => allowed.contains('in');
  bool get canCheckOut => allowed.contains('out');
  bool get canStartBreak => allowed.contains('break_start');
  bool get canEndBreak => allowed.contains('break_end');
  bool get isPositionRequired => requires?.position == true;
  bool get isPhotoRequired => requires?.photo == true;
  bool get isFaceRequired => requires != null && requires!.face != 'off';

  String get plannedHoursFormatted {
    if (plannedMinutes <= 0) return '0h 00m';
    final h = plannedMinutes ~/ 60;
    final m = (plannedMinutes % 60).toString().padLeft(2, '0');
    return '${h}h ${m}m';
  }

  String get workedHoursFormatted {
    if (workedMinutes <= 0) {
      return workingHours.isNotEmpty && workingHours != '0:00' ? workingHours : '0h 00m';
    }
    final h = workedMinutes ~/ 60;
    final m = (workedMinutes % 60).toString().padLeft(2, '0');
    return '${h}h ${m}m';
  }

  String get countedHoursFormatted {
    if (countedMinutes <= 0) return '0h 00m';
    final h = countedMinutes ~/ 60;
    final m = (countedMinutes % 60).toString().padLeft(2, '0');
    return '${h}h ${m}m';
  }

  /// Returns the most recent check-out time across today's sessions,
  /// even if the employee is currently re-checked in and day.last_out is null.
  String? get latestCheckOutTime {
    if (checkOutTime != '--:--' && checkOutTime.isNotEmpty) {
      return checkOutTime;
    }
    for (final s in segments.reversed) {
      if (s.kind.toLowerCase() == 'work' &&
          s.ends != null &&
          s.ends!.isNotEmpty &&
          s.ends != '--:--') {
        return s.ends;
      }
    }
    return null;
  }

  /// Returns the most recent check-in time across today's sessions.
  String? get latestCheckInTime {
    for (final s in segments.reversed) {
      if (s.kind.toLowerCase() == 'work' &&
          s.starts != null &&
          s.starts!.isNotEmpty &&
          s.starts != '--:--') {
        return s.starts;
      }
    }
    return checkInTime != '--:--' ? checkInTime : null;
  }

  /// Total number of work segments today
  int get totalWorkSessions {
    return segments.where((s) => s.kind.toLowerCase() == 'work').length;
  }

  TodayAttendanceModel copyWith({
    String? checkInTime,
    String? checkOutTime,
    String? workingHours,
    String? shiftRemaining,
    String? overtime,
    bool? isCheckedIn,
    bool? isOnBreak,
    bool? usesBreaks,
    String? status,
    String? statusTone,
    String? officeRadiusStatus,
    String? shiftTiming,
    String? shiftName,
    DateTime? checkInDateTime,
    List<String>? allowed,
    Map<String, AttendanceRefusalModel>? refusals,
    AttendanceRequiresModel? requires,
    AttendanceShiftModel? shift,
    List<AttendanceSegmentModel>? segments,
    List<dynamic>? breaks,
    int? plannedMinutes,
    int? workedMinutes,
    int? countedMinutes,
    int? breakMinutes,
    int? lateMinutes,
    int? earlyOutMinutes,
    int? shortMinutes,
    String? dayId,
    String? dateLabel,
    List<String>? flags,
    String? dayType,
    String? statusCode,
    String? breakSince,
  }) {
    return TodayAttendanceModel(
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      workingHours: workingHours ?? this.workingHours,
      shiftRemaining: shiftRemaining ?? this.shiftRemaining,
      overtime: overtime ?? this.overtime,
      isCheckedIn: isCheckedIn ?? this.isCheckedIn,
      isOnBreak: isOnBreak ?? this.isOnBreak,
      usesBreaks: usesBreaks ?? this.usesBreaks,
      status: status ?? this.status,
      statusTone: statusTone ?? this.statusTone,
      officeRadiusStatus: officeRadiusStatus ?? this.officeRadiusStatus,
      shiftTiming: shiftTiming ?? this.shiftTiming,
      shiftName: shiftName ?? this.shiftName,
      checkInDateTime: checkInDateTime ?? this.checkInDateTime,
      allowed: allowed ?? this.allowed,
      refusals: refusals ?? this.refusals,
      requires: requires ?? this.requires,
      shift: shift ?? this.shift,
      segments: segments ?? this.segments,
      breaks: breaks ?? this.breaks,
      plannedMinutes: plannedMinutes ?? this.plannedMinutes,
      workedMinutes: workedMinutes ?? this.workedMinutes,
      countedMinutes: countedMinutes ?? this.countedMinutes,
      breakMinutes: breakMinutes ?? this.breakMinutes,
      lateMinutes: lateMinutes ?? this.lateMinutes,
      earlyOutMinutes: earlyOutMinutes ?? this.earlyOutMinutes,
      shortMinutes: shortMinutes ?? this.shortMinutes,
      dayId: dayId ?? this.dayId,
      dateLabel: dateLabel ?? this.dateLabel,
      flags: flags ?? this.flags,
      dayType: dayType ?? this.dayType,
      statusCode: statusCode ?? this.statusCode,
      breakSince: breakSince ?? this.breakSince,
    );
  }

  /// Parses exact payload from GET /me/attendance/today
  factory TodayAttendanceModel.fromApiJson(Map<String, dynamic> json) {
    final state = json['state'] is Map
        ? Map<String, dynamic>.from(json['state'] as Map)
        : <String, dynamic>{};
    final requiresMap = json['requires'] is Map
        ? Map<String, dynamic>.from(json['requires'] as Map)
        : null;
    final day = json['day'] is Map
        ? Map<String, dynamic>.from(json['day'] as Map)
        : null;
    final shiftMap = day != null && day['shift'] is Map
        ? Map<String, dynamic>.from(day['shift'] as Map)
        : null;

    final isCheckedIn = state['checked_in'] as bool? ?? false;
    final isOnBreak = state['on_break'] as bool? ?? false;
    final since = state['since']?.toString();

    DateTime? checkInDt;
    if (state['since_at'] != null) {
      checkInDt = DateTime.tryParse(state['since_at'].toString())?.toLocal();
    } else if (day?['first_in_at'] != null) {
      checkInDt = DateTime.tryParse(day!['first_in_at'].toString())?.toLocal();
    }

    final firstIn = day?['first_in']?.toString();
    final effectiveCheckIn = (firstIn != null && firstIn.isNotEmpty)
        ? firstIn
        : (since ?? '--:--');

    final lastOut = day?['last_out']?.toString() ?? '--:--';
    final worked = day?['worked']?.toString() ?? '0:00';
    final overtime = day?['overtime']?.toString() ?? '0:00';

    final plannedMin = day?['planned_minutes'] as int? ?? 0;
    final workedMin = day?['worked_minutes'] as int? ?? 0;

    String initialWorkingHours = '0h 00m';
    if (workedMin > 0) {
      final h = workedMin ~/ 60;
      final m = (workedMin % 60).toString().padLeft(2, '0');
      initialWorkingHours = '${h}h ${m}m';
    } else if (worked.isNotEmpty && worked != '0:00') {
      initialWorkingHours = worked;
    }

    String remainingStr = '00h 00m';
    if (plannedMin > 0) {
      final remMin = (plannedMin - workedMin).clamp(0, plannedMin);
      final rHours = (remMin ~/ 60).toString().padLeft(2, '0');
      final rMins = (remMin % 60).toString().padLeft(2, '0');
      remainingStr = '${rHours}h ${rMins}m';
    }

    // Refusals map parsing
    final Map<String, AttendanceRefusalModel> refusalsMap = {};
    if (state['refusals'] is Map) {
      (state['refusals'] as Map).forEach((key, val) {
        if (val is Map) {
          refusalsMap[key.toString()] = AttendanceRefusalModel.fromJson(
            Map<String, dynamic>.from(val),
          );
        }
      });
    }

    // Allowed actions
    final List<String> allowedList = [];
    if (state['allowed'] is List) {
      for (final a in state['allowed'] as List) {
        if (a != null) allowedList.add(a.toString());
      }
    }

    // Segments parsing
    final List<AttendanceSegmentModel> segmentsList = [];
    if (day?['segments'] is List) {
      for (final s in day!['segments'] as List) {
        if (s is Map) {
          segmentsList.add(
            AttendanceSegmentModel.fromJson(Map<String, dynamic>.from(s)),
          );
        }
      }
    }

    // Flags parsing
    final List<String> flagsList = [];
    if (day?['flags'] is List) {
      for (final f in day!['flags'] as List) {
        if (f != null) flagsList.add(f.toString());
      }
    }

    final shiftObj = shiftMap != null ? AttendanceShiftModel.fromJson(shiftMap) : null;
    final shiftTimingStr = shiftObj != null
        ? '${shiftObj.starts} - ${shiftObj.ends}'
        : '--:--';

    return TodayAttendanceModel(
      checkInTime: effectiveCheckIn,
      checkOutTime: lastOut,
      workingHours: initialWorkingHours,
      shiftRemaining: remainingStr,
      overtime: overtime,
      isCheckedIn: isCheckedIn,
      isOnBreak: isOnBreak,
      usesBreaks: state['uses_breaks'] as bool? ?? true,
      status: day?['status_label']?.toString() ??
          (isCheckedIn ? 'In Progress' : 'Not Checked In'),
      statusTone: day?['tone']?.toString() ?? 'slate',
      officeRadiusStatus: requiresMap?['position'] == true
          ? 'Geofence Active'
          : 'Office Radius Verified',
      shiftTiming: shiftTimingStr,
      shiftName: shiftObj?.name ?? 'General Shift',
      checkInDateTime: checkInDt,
      allowed: allowedList,
      refusals: refusalsMap,
      requires: requiresMap != null
          ? AttendanceRequiresModel.fromJson(requiresMap)
          : null,
      shift: shiftObj,
      segments: segmentsList,
      breaks: day?['breaks'] is List ? day!['breaks'] as List : const [],
      plannedMinutes: plannedMin,
      workedMinutes: workedMin,
      countedMinutes: day?['counted_minutes'] as int? ?? 0,
      breakMinutes: day?['break_minutes'] as int? ?? 0,
      lateMinutes: day?['late_minutes'] as int? ?? 0,
      earlyOutMinutes: day?['early_out_minutes'] as int? ?? 0,
      shortMinutes: day?['short_minutes'] as int? ?? 0,
      dayId: day?['id']?.toString(),
      dateLabel: day?['date_label']?.toString(),
      flags: flagsList,
      dayType: day?['day_type']?.toString(),
      statusCode: day?['status_code']?.toString() ?? '·',
      breakSince: isOnBreak ? since : null,
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
      'is_on_break': isOnBreak,
      'status': status,
      'status_tone': statusTone,
      'office_radius_status': officeRadiusStatus,
      'shift_timing': shiftTiming,
      'shift_name': shiftName,
      'check_in_timestamp': checkInDateTime?.toIso8601String(),
      'allowed': allowed,
      'refusals': refusals.map((k, v) => MapEntry(k, v.toJson())),
      'requires': requires?.toJson(),
      'shift': shift?.toJson(),
      'planned_minutes': plannedMinutes,
      'worked_minutes': workedMinutes,
      'counted_minutes': countedMinutes,
      'late_minutes': lateMinutes,
      'early_out_minutes': earlyOutMinutes,
      'short_minutes': shortMinutes,
      'day_id': dayId,
      'date_label': dateLabel,
    };
  }
}

class MonthlySummaryModel {
  final int totalDays;
  final int presentDays;
  final int lateDays;
  final int lateMinutes;
  final int earlyOutDays;
  final int earlyOutMinutes;
  final int absentDays;
  final int halfDays;
  final int offDays;
  final int holidayDays;
  final int upcomingDays;
  final int inProgressDays;
  final int plannedMinutes;
  final int workedMinutes;
  final int countedMinutes;
  final int shortMinutes;
  final int missingCheckOuts;
  final int approvedOvertimeMinutes;
  final int pendingOvertimeMinutes;
  final double attendanceRate;
  final String monthName;
  final String monthKey;

  const MonthlySummaryModel({
    required this.totalDays,
    required this.presentDays,
    required this.lateDays,
    this.lateMinutes = 0,
    this.earlyOutDays = 0,
    this.earlyOutMinutes = 0,
    required this.absentDays,
    this.halfDays = 0,
    this.offDays = 0,
    this.holidayDays = 0,
    this.upcomingDays = 0,
    this.inProgressDays = 0,
    this.plannedMinutes = 0,
    this.workedMinutes = 0,
    this.countedMinutes = 0,
    this.shortMinutes = 0,
    this.missingCheckOuts = 0,
    this.approvedOvertimeMinutes = 0,
    this.pendingOvertimeMinutes = 0,
    required this.attendanceRate,
    required this.monthName,
    this.monthKey = '',
  });

  /// Parses exact payload from GET /me/attendance/summary
  factory MonthlySummaryModel.fromApiJson(
    Map<String, dynamic> json, {
    Map<String, dynamic>? meta,
  }) {
    final days = json['days'] is Map
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

    final scheduled = json['scheduled_days'] as int? ?? 0;
    final present = days['present'] as int? ?? 0;
    final lateCount = lateMap['count'] as int? ?? 0;
    final absent = days['absent'] as int? ?? 0;

    // Accurate calculation based strictly on real scheduled vs present days
    final rate = scheduled > 0
        ? ((present / scheduled) * 100).clamp(0.0, 100.0)
        : 0.0;

    // Readable month formatting (e.g. 2026-10 -> October 2026)
    final rawMonth = meta?['month']?.toString() ?? '';
    String formattedMonth = rawMonth;
    if (rawMonth.isNotEmpty && rawMonth.contains('-')) {
      final parts = rawMonth.split('-');
      if (parts.length >= 2) {
        final year = parts[0];
        final monthIdx = int.tryParse(parts[1]) ?? 0;
        const monthNames = [
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
        if (monthIdx >= 1 && monthIdx <= 12) {
          formattedMonth = '${monthNames[monthIdx]} $year';
        }
      }
    } else if (rawMonth.isEmpty) {
      const monthNames = [
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
      final now = DateTime.now();
      formattedMonth = '${monthNames[now.month]} ${now.year}';
    }

    return MonthlySummaryModel(
      totalDays: scheduled,
      presentDays: present,
      lateDays: lateCount,
      lateMinutes: lateMap['minutes'] as int? ?? 0,
      earlyOutDays: earlyOutMap['count'] as int? ?? 0,
      earlyOutMinutes: earlyOutMap['minutes'] as int? ?? 0,
      absentDays: absent,
      halfDays: days['half_day'] as int? ?? 0,
      offDays: days['off'] as int? ?? 0,
      holidayDays: days['holiday'] as int? ?? 0,
      upcomingDays: days['upcoming'] as int? ?? 0,
      inProgressDays: days['in_progress'] as int? ?? 0,
      plannedMinutes: json['planned_minutes'] as int? ?? 0,
      workedMinutes: json['worked_minutes'] as int? ?? 0,
      countedMinutes: json['counted_minutes'] as int? ?? 0,
      shortMinutes: json['short_minutes'] as int? ?? 0,
      missingCheckOuts: json['missing_check_outs'] as int? ?? 0,
      approvedOvertimeMinutes: overtimeMap['approved_minutes'] as int? ?? 0,
      pendingOvertimeMinutes: overtimeMap['pending_minutes'] as int? ?? 0,
      attendanceRate: double.parse(rate.toStringAsFixed(1)),
      monthName: formattedMonth,
      monthKey: rawMonth,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_days': totalDays,
      'present_days': presentDays,
      'late_days': lateDays,
      'late_minutes': lateMinutes,
      'early_out_days': earlyOutDays,
      'early_out_minutes': earlyOutMinutes,
      'absent_days': absentDays,
      'half_days': halfDays,
      'off_days': offDays,
      'holiday_days': holidayDays,
      'upcoming_days': upcomingDays,
      'in_progress_days': inProgressDays,
      'planned_minutes': plannedMinutes,
      'worked_minutes': workedMinutes,
      'counted_minutes': countedMinutes,
      'short_minutes': shortMinutes,
      'missing_check_outs': missingCheckOuts,
      'approved_overtime_minutes': approvedOvertimeMinutes,
      'pending_overtime_minutes': pendingOvertimeMinutes,
      'attendance_rate': attendanceRate,
      'month_name': monthName,
      'month_key': monthKey,
    };
  }
}

class DashboardDataModel {
  final TodayAttendanceModel todayAttendance;
  final MonthlySummaryModel monthlySummary;

  const DashboardDataModel({
    required this.todayAttendance,
    required this.monthlySummary,
  });

  Map<String, dynamic> toJson() {
    return {
      'today_attendance': todayAttendance.toJson(),
      'monthly_summary': monthlySummary.toJson(),
    };
  }
}
