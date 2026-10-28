import 'package:flutter/material.dart';
import '../../../core/utils/app_colors.dart';

/// Shift specifications associated with a scheduled working day
class ShiftModel {
  final String id;
  final String name;
  final String code;
  final String colour;
  final String kind;
  final String starts;
  final String ends;
  final bool overnight;
  final int breakMinutes;

  const ShiftModel({
    required this.id,
    required this.name,
    required this.code,
    required this.colour,
    required this.kind,
    required this.starts,
    required this.ends,
    required this.overnight,
    required this.breakMinutes,
  });

  factory ShiftModel.fromJson(Map<String, dynamic> json) {
    return ShiftModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Standard Shift',
      code: json['code']?.toString() ?? 'STD',
      colour: json['colour']?.toString() ?? 'sky',
      kind: json['kind']?.toString() ?? 'fixed',
      starts: json['starts']?.toString() ?? '09:00',
      ends: json['ends']?.toString() ?? '17:00',
      overnight: json['overnight'] == true,
      breakMinutes: (json['break_minutes'] as num?)?.toInt() ?? 60,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'code': code,
        'colour': colour,
        'kind': kind,
        'starts': starts,
        'ends': ends,
        'overnight': overnight,
        'break_minutes': breakMinutes,
      };

  /// UI Color mapped directly to Corporate Design System & Shift Tones
  Color get themeColor {
    switch (colour.toLowerCase()) {
      case 'emerald':
      case 'green':
        return AppColors.success;
      case 'amber':
      case 'orange':
      case 'yellow':
        return AppColors.warning;
      case 'rose':
      case 'red':
        return AppColors.error;
      case 'purple':
      case 'indigo':
        return const Color(0xFF6366F1);
      case 'sky':
      case 'blue':
      case 'teal':
      default:
        return AppColors.secondary;
    }
  }

  String get timeRangeLabel => '$starts – $ends';
}

/// Official public or company-designated holiday
class HolidayModel {
  final String id;
  final String name;
  final String kind;
  final String startsOn;
  final String endsOn;
  final bool isPaid;

  const HolidayModel({
    required this.id,
    required this.name,
    required this.kind,
    required this.startsOn,
    required this.endsOn,
    required this.isPaid,
  });

  factory HolidayModel.fromJson(Map<String, dynamic> json) {
    return HolidayModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Holiday',
      kind: json['kind']?.toString() ?? 'public',
      startsOn: json['starts_on']?.toString() ?? '',
      endsOn: json['ends_on']?.toString() ?? '',
      isPaid: json['is_paid'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'kind': kind,
        'starts_on': startsOn,
        'ends_on': endsOn,
        'is_paid': isPaid,
      };

  bool get isPublicHoliday => kind.toLowerCase() == 'public';
}

/// Single scheduled day rota log returned by GET /me/schedule
class ScheduleDayModel {
  final String date;
  final String type; // 'working', 'rest', 'holiday'
  final String label;
  final String source; // 'pattern', 'override'
  final String? timezone;
  final ShiftModel? shift;
  final String? startsAt;
  final String? endsAt;
  final int plannedMinutes;
  final String planned;
  final HolidayModel? holiday;
  final bool holidayWorked;
  final String? pattern;

  const ScheduleDayModel({
    required this.date,
    required this.type,
    required this.label,
    required this.source,
    this.timezone,
    this.shift,
    this.startsAt,
    this.endsAt,
    required this.plannedMinutes,
    required this.planned,
    this.holiday,
    required this.holidayWorked,
    this.pattern,
  });

  factory ScheduleDayModel.fromJson(Map<String, dynamic> json) {
    return ScheduleDayModel(
      date: json['date']?.toString() ?? '',
      type: json['type']?.toString() ?? 'working',
      label: json['label']?.toString() ?? '',
      source: json['source']?.toString() ?? 'pattern',
      timezone: json['timezone']?.toString(),
      shift: json['shift'] is Map<String, dynamic>
          ? ShiftModel.fromJson(json['shift'] as Map<String, dynamic>)
          : null,
      startsAt: json['starts_at']?.toString(),
      endsAt: json['ends_at']?.toString(),
      plannedMinutes: (json['planned_minutes'] as num?)?.toInt() ?? 0,
      planned: json['planned']?.toString() ?? '0:00',
      holiday: json['holiday'] is Map<String, dynamic>
          ? HolidayModel.fromJson(json['holiday'] as Map<String, dynamic>)
          : null,
      holidayWorked: json['holiday_worked'] == true,
      pattern: json['pattern']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'type': type,
        'label': label,
        'source': source,
        'timezone': timezone,
        'shift': shift?.toJson(),
        'starts_at': startsAt,
        'ends_at': endsAt,
        'planned_minutes': plannedMinutes,
        'planned': planned,
        'holiday': holiday?.toJson(),
        'holiday_worked': holidayWorked,
        'pattern': pattern,
      };

  bool get isWorkingDay => type.toLowerCase() == 'working';
  bool get isRestDay => type.toLowerCase() == 'rest';
  bool get isHoliday => type.toLowerCase() == 'holiday' || holiday != null;

  DateTime? get parsedDate => DateTime.tryParse(date);

  String get dayOfWeek {
    final dt = parsedDate;
    if (dt == null) return '';
    const days = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];
    return days[dt.weekday - 1];
  }

  String get fullDayOfWeek {
    final dt = parsedDate;
    if (dt == null) return '';
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[dt.weekday - 1];
  }

  String get dayNumber {
    final dt = parsedDate;
    if (dt == null) return '';
    return dt.day.toString().padLeft(2, '0');
  }

  String get monthName {
    final dt = parsedDate;
    if (dt == null) return '';
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
      'Dec',
    ];
    return months[dt.month - 1];
  }

  bool get isToday {
    final dt = parsedDate;
    if (dt == null) return false;
    final now = DateTime.now();
    return dt.year == now.year && dt.month == now.month && dt.day == now.day;
  }
}

/// Metadata envelope for schedule responses
class ScheduleMetaModel {
  final String? employee;
  final String? from;
  final String? to;

  const ScheduleMetaModel({this.employee, this.from, this.to});

  factory ScheduleMetaModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ScheduleMetaModel();
    return ScheduleMetaModel(
      employee: json['employee']?.toString(),
      from: json['from']?.toString(),
      to: json['to']?.toString(),
    );
  }
}

/// Complete response model from GET /me/schedule
class ScheduleResponseModel {
  final List<ScheduleDayModel> data;
  final ScheduleMetaModel meta;

  const ScheduleResponseModel({
    required this.data,
    required this.meta,
  });

  factory ScheduleResponseModel.fromJson(Map<String, dynamic> json) {
    final list = <ScheduleDayModel>[];
    if (json['data'] is List) {
      for (final item in json['data'] as List) {
        if (item is Map<String, dynamic>) {
          list.add(ScheduleDayModel.fromJson(item));
        }
      }
    }
    return ScheduleResponseModel(
      data: list,
      meta: ScheduleMetaModel.fromJson(json['meta'] as Map<String, dynamic>?),
    );
  }
}

/// Response model from GET /holidays
class HolidaysResponseModel {
  final List<HolidayModel> data;
  final int year;

  const HolidaysResponseModel({
    required this.data,
    required this.year,
  });

  factory HolidaysResponseModel.fromJson(Map<String, dynamic> json) {
    final list = <HolidayModel>[];
    if (json['data'] is List) {
      for (final item in json['data'] as List) {
        if (item is Map<String, dynamic>) {
          list.add(HolidayModel.fromJson(item));
        }
      }
    }
    final metaYear = json['meta'] is Map
        ? (json['meta']['year'] as num?)?.toInt() ?? DateTime.now().year
        : DateTime.now().year;

    return HolidaysResponseModel(
      data: list,
      year: metaYear,
    );
  }
}
