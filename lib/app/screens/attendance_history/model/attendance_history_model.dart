// Data models for Attendance History (/me/attendance)
// Strictly deserializes live API response with ZERO dummy / fallback data.

class AttendanceHistoryShiftModel {
  final String name;
  final String code;
  final String starts;
  final String ends;
  final bool overnight;

  const AttendanceHistoryShiftModel({
    required this.name,
    required this.code,
    required this.starts,
    required this.ends,
    required this.overnight,
  });

  factory AttendanceHistoryShiftModel.fromJson(Map<String, dynamic> json) {
    return AttendanceHistoryShiftModel(
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

class AttendanceHistorySegmentModel {
  final String kind;
  final String? starts;
  final String? ends;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final bool paid;

  const AttendanceHistorySegmentModel({
    required this.kind,
    this.starts,
    this.ends,
    this.startsAt,
    this.endsAt,
    required this.paid,
  });

  int get durationMinutes {
    if (startsAt != null && endsAt != null) {
      return endsAt!.difference(startsAt!).inMinutes.clamp(0, 24 * 60);
    }
    return AttendanceHistoryBreakModel.calculateMinutes(starts, ends);
  }

  factory AttendanceHistorySegmentModel.fromJson(Map<String, dynamic> json) {
    return AttendanceHistorySegmentModel(
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

class AttendanceHistoryBreakModel {
  final String starts;
  final String? ends;
  final int minutes;
  final String? type;
  final bool paid;

  const AttendanceHistoryBreakModel({
    required this.starts,
    this.ends,
    required this.minutes,
    this.type,
    required this.paid,
  });

  bool get isInProgress => ends == null || ends!.isEmpty || ends == '--:--';
  String get breakInDisplay => starts.isNotEmpty ? starts : '--:--';
  String get breakOutDisplay => isInProgress ? 'In Progress' : ends!;

  String get durationDisplay {
    if (isInProgress) return 'In Progress';
    if (minutes >= 60) {
      final h = minutes ~/ 60;
      final m = minutes % 60;
      return m > 0 ? '${h}h ${m}m' : '${h}h';
    }
    return '${minutes}m';
  }

  static int calculateMinutes(String? starts, String? ends) {
    if (starts == null || ends == null) return 0;
    if (starts.isEmpty || ends.isEmpty || starts == '--:--' || ends == '--:--') {
      return 0;
    }

    try {
      final startParts = starts.split(':');
      final endParts = ends.split(':');
      if (startParts.length >= 2 && endParts.length >= 2) {
        final startH = int.parse(startParts[0].trim());
        final startM = int.parse(startParts[1].trim());
        final endH = int.parse(endParts[0].trim());
        final endM = int.parse(endParts[1].trim());

        int startTotal = startH * 60 + startM;
        int endTotal = endH * 60 + endM;

        if (endTotal < startTotal) {
          endTotal += 24 * 60;
        }
        return (endTotal - startTotal).clamp(0, 24 * 60);
      }
    } catch (_) {}
    return 0;
  }

  factory AttendanceHistoryBreakModel.fromJson(Map<String, dynamic> json) {
    final startsStr = json['starts']?.toString() ?? '--:--';
    final endsStr = json['ends'] != null &&
            json['ends'].toString().isNotEmpty &&
            json['ends'].toString() != '--:--'
        ? json['ends'].toString()
        : null;

    int mins = (json['minutes'] as num?)?.toInt() ?? 0;
    if (mins <= 0 && endsStr != null) {
      mins = calculateMinutes(startsStr, endsStr);
    }

    return AttendanceHistoryBreakModel(
      starts: startsStr,
      ends: endsStr,
      minutes: mins,
      type: json['type']?.toString(),
      paid: json['paid'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'starts': starts,
        'ends': ends,
        'minutes': minutes,
        'type': type,
        'paid': paid,
      };
}

class AttendanceHistoryDayModel {
  final String id;
  final DateTime date;
  final String dateLabel;
  final String status;
  final String statusLabel;
  final String statusCode;
  final String tone;
  final String dayType;
  final String timezone;
  final AttendanceHistoryShiftModel? shift;
  final dynamic holiday;
  final int plannedMinutes;
  final String? firstIn;
  final DateTime? firstInAt;
  final String? lastOut;
  final DateTime? lastOutAt;
  final int workedMinutes;
  final String worked;
  final int countedMinutes;
  final String counted;
  final int breakMinutes;
  final int lateMinutes;
  final int earlyOutMinutes;
  final int shortMinutes;
  final int overtimeMinutes;
  final String overtime;
  final String? overtimeStatus;
  final List<String> flags;
  final bool locked;
  final List<AttendanceHistorySegmentModel> segments;
  final List<AttendanceHistoryBreakModel> breaks;

  const AttendanceHistoryDayModel({
    required this.id,
    required this.date,
    required this.dateLabel,
    required this.status,
    required this.statusLabel,
    required this.statusCode,
    required this.tone,
    required this.dayType,
    this.timezone = 'Asia/Karachi',
    this.shift,
    this.holiday,
    this.plannedMinutes = 0,
    this.firstIn,
    this.firstInAt,
    this.lastOut,
    this.lastOutAt,
    this.workedMinutes = 0,
    this.worked = '0:00',
    this.countedMinutes = 0,
    this.counted = '0:00',
    this.breakMinutes = 0,
    this.lateMinutes = 0,
    this.earlyOutMinutes = 0,
    this.shortMinutes = 0,
    this.overtimeMinutes = 0,
    this.overtime = '0:00',
    this.overtimeStatus,
    this.flags = const [],
    this.locked = false,
    this.segments = const [],
    this.breaks = const [],
  });

  // UI Convenience Getters
  bool get isInProgress => status == 'in_progress';
  bool get isPresent => status == 'present' || status == 'in_progress';
  bool get isAbsent => status == 'absent';
  bool get isDayOff => status == 'off';
  bool get hasLate => lateMinutes > 0 || flags.contains('late');
  bool get hasEarlyOut => earlyOutMinutes > 0 || flags.contains('early_out');

  List<AttendanceHistoryBreakModel> get allBreaks {
    if (breaks.isNotEmpty) return breaks;
    final breakSegments =
        segments.where((s) => s.kind.toLowerCase() == 'break');
    if (breakSegments.isNotEmpty) {
      return breakSegments
          .map((s) => AttendanceHistoryBreakModel(
                starts: s.starts ?? '--:--',
                ends: s.ends,
                minutes: s.durationMinutes,
                type: 'break',
                paid: s.paid,
              ))
          .toList();
    }
    return const [];
  }

  int get totalBreakMinutes {
    if (breakMinutes > 0) return breakMinutes;
    return allBreaks.fold<int>(0, (acc, b) => acc + b.minutes);
  }

  String get totalBreakFormatted {
    final mins = totalBreakMinutes;
    if (mins <= 0) return '0m';
    final h = mins ~/ 60;
    final m = mins % 60;
    if (h > 0) {
      return m > 0 ? '${h}h ${m}m' : '${h}h';
    }
    return '${m}m';
  }

  bool get hasBreaks => allBreaks.isNotEmpty || totalBreakMinutes > 0;

  String get checkInDisplay => (firstIn != null && firstIn!.isNotEmpty) ? firstIn! : '--:--';
  String get checkOutDisplay {
    if (isInProgress) return 'At Work';
    return (lastOut != null && lastOut!.isNotEmpty) ? lastOut! : '--:--';
  }

  String get workedFormatted {
    if (worked.isNotEmpty && worked != '0:00') return worked;
    final h = workedMinutes ~/ 60;
    final m = workedMinutes % 60;
    return '${h}h ${m}m';
  }

  String get countedFormatted {
    if (counted.isNotEmpty && counted != '0:00') return counted;
    final h = countedMinutes ~/ 60;
    final m = countedMinutes % 60;
    return '${h}h ${m}m';
  }

  factory AttendanceHistoryDayModel.fromJson(Map<String, dynamic> json) {
    final parsedDate = json['date'] != null
        ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
        : DateTime.now();

    final shiftJson = json['shift'] is Map<String, dynamic>
        ? json['shift'] as Map<String, dynamic>
        : (json['shift'] is Map ? Map<String, dynamic>.from(json['shift'] as Map) : null);

    final rawSegments = json['segments'] as List<dynamic>? ?? [];
    final parsedSegments = rawSegments
        .whereType<Map>()
        .map((e) => AttendanceHistorySegmentModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    final rawBreaks = json['breaks'] as List<dynamic>? ?? [];
    final parsedBreaks = rawBreaks
        .whereType<Map>()
        .map((e) => AttendanceHistoryBreakModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    final rawFlags = json['flags'] as List<dynamic>? ?? [];
    final parsedFlags = rawFlags.map((e) => e.toString()).toList();

    return AttendanceHistoryDayModel(
      id: json['id']?.toString() ?? '',
      date: parsedDate,
      dateLabel: json['date_label']?.toString() ?? '',
      status: json['status']?.toString() ?? 'absent',
      statusLabel: json['status_label']?.toString() ?? 'Absent',
      statusCode: json['status_code']?.toString() ?? 'A',
      tone: json['tone']?.toString() ?? 'slate',
      dayType: json['day_type']?.toString() ?? 'working',
      timezone: json['timezone']?.toString() ?? 'Asia/Karachi',
      shift: shiftJson != null ? AttendanceHistoryShiftModel.fromJson(shiftJson) : null,
      holiday: json['holiday'],
      plannedMinutes: (json['planned_minutes'] as num?)?.toInt() ?? 0,
      firstIn: json['first_in']?.toString(),
      firstInAt: json['first_in_at'] != null
          ? DateTime.tryParse(json['first_in_at'].toString())?.toLocal()
          : null,
      lastOut: json['last_out']?.toString(),
      lastOutAt: json['last_out_at'] != null
          ? DateTime.tryParse(json['last_out_at'].toString())?.toLocal()
          : null,
      workedMinutes: (json['worked_minutes'] as num?)?.toInt() ?? 0,
      worked: json['worked']?.toString() ?? '0:00',
      countedMinutes: (json['counted_minutes'] as num?)?.toInt() ?? 0,
      counted: json['counted']?.toString() ?? '0:00',
      breakMinutes: (json['break_minutes'] as num?)?.toInt() ?? 0,
      lateMinutes: (json['late_minutes'] as num?)?.toInt() ?? 0,
      earlyOutMinutes: (json['early_out_minutes'] as num?)?.toInt() ?? 0,
      shortMinutes: (json['short_minutes'] as num?)?.toInt() ?? 0,
      overtimeMinutes: (json['overtime_minutes'] as num?)?.toInt() ?? 0,
      overtime: json['overtime']?.toString() ?? '0:00',
      overtimeStatus: json['overtime_status']?.toString(),
      flags: parsedFlags,
      locked: json['locked'] as bool? ?? false,
      segments: parsedSegments,
      breaks: parsedBreaks,
    );
  }
}

class AttendanceHistoryMeta {
  final String? employeeId;
  final String? from;
  final String? to;
  final dynamic employee;

  const AttendanceHistoryMeta({
    this.employeeId,
    this.from,
    this.to,
    this.employee,
  });

  String? get employeeName =>
      employee is Map ? (employee as Map)['name']?.toString() : null;

  factory AttendanceHistoryMeta.fromJson(Map<String, dynamic> json) {
    String? empId;
    if (json['employee'] is String) {
      empId = json['employee'] as String;
    } else if (json['employee'] is Map) {
      empId = (json['employee'] as Map)['id']?.toString();
    } else if (json['employee_id'] != null) {
      empId = json['employee_id']?.toString();
    }
    return AttendanceHistoryMeta(
      employeeId: empId,
      from: json['from']?.toString(),
      to: json['to']?.toString(),
      employee: json['employee'],
    );
  }
}

class AttendanceHistoryResponse {
  final List<AttendanceHistoryDayModel> data;
  final AttendanceHistoryMeta? meta;

  const AttendanceHistoryResponse({
    required this.data,
    this.meta,
  });

  factory AttendanceHistoryResponse.fromJson(Map<String, dynamic> json) {
    final rawList = json['data'] as List<dynamic>? ?? [];
    final list = rawList
        .whereType<Map>()
        .map((e) => AttendanceHistoryDayModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    final metaJson = json['meta'] is Map<String, dynamic>
        ? json['meta'] as Map<String, dynamic>
        : (json['meta'] is Map ? Map<String, dynamic>.from(json['meta'] as Map) : null);

    return AttendanceHistoryResponse(
      data: list,
      meta: metaJson != null ? AttendanceHistoryMeta.fromJson(metaJson) : null,
    );
  }
}

// ============================================================================
// BACKWARD-COMPATIBLE TYPEDEFS (Aliases for Timesheet & Old Action naming)
// ============================================================================
typedef AttendanceTimesheetResponse = AttendanceHistoryResponse;
typedef AttendanceTimesheetDayModel = AttendanceHistoryDayModel;
typedef AttendanceTimesheetMeta = AttendanceHistoryMeta;
typedef TimesheetBreakModel = AttendanceHistoryBreakModel;
typedef TimesheetShiftModel = AttendanceHistoryShiftModel;
typedef TimesheetSegmentModel = AttendanceHistorySegmentModel;
