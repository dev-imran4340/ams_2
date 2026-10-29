import 'package:flutter/material.dart';
import '../../../core/utils/app_colors.dart';

/// Represents a leave category type configured by the company (GET /leave/types)
class LeaveTypeModel {
  final String id;
  final String name;
  final String code;
  final String colour;
  final String category; // 'annual', 'sick', 'unpaid', 'compensatory', 'other'
  final bool isPaid;
  final String unit; // 'day' or 'hour'
  final bool allowHalfDays;
  final int minNoticeDays;
  final int maxDaysInRow;
  final int attachmentAfterDays;
  final bool allowPastDays;
  final bool hasBalance;

  const LeaveTypeModel({
    required this.id,
    required this.name,
    required this.code,
    required this.colour,
    required this.category,
    required this.isPaid,
    required this.unit,
    required this.allowHalfDays,
    required this.minNoticeDays,
    required this.maxDaysInRow,
    required this.attachmentAfterDays,
    required this.allowPastDays,
    required this.hasBalance,
  });

  Color get resolvedColor {
    switch (colour.toLowerCase().trim()) {
      case 'emerald':
      case 'green':
        return AppColors.success;
      case 'sky':
      case 'blue':
        return AppColors.secondary;
      case 'amber':
      case 'yellow':
      case 'orange':
        return AppColors.warning;
      case 'rose':
      case 'red':
        return AppColors.error;
      case 'slate':
      case 'gray':
      case 'grey':
        return AppColors.subTextColor;
      default:
        return AppColors.primary;
    }
  }

  factory LeaveTypeModel.fromJson(Map<String, dynamic> json) {
    return LeaveTypeModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'General Leave',
      code: json['code']?.toString() ?? 'GL',
      colour: json['colour']?.toString() ?? 'sky',
      category: json['category']?.toString() ?? 'other',
      isPaid: json['is_paid'] == true,
      unit: json['unit']?.toString() ?? 'day',
      allowHalfDays: json['allow_half_days'] == true,
      minNoticeDays: (json['min_notice_days'] as num?)?.toInt() ?? 0,
      maxDaysInRow: (json['max_days_in_row'] as num?)?.toInt() ?? 14,
      attachmentAfterDays: (json['attachment_after_days'] as num?)?.toInt() ?? 0,
      allowPastDays: json['allow_past_days'] == true,
      hasBalance: json['has_balance'] != false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'colour': colour,
      'category': category,
      'is_paid': isPaid,
      'unit': unit,
      'allow_half_days': allowHalfDays,
      'min_notice_days': minNoticeDays,
      'max_days_in_row': maxDaysInRow,
      'attachment_after_days': attachmentAfterDays,
      'allow_past_days': allowPastDays,
      'has_balance': hasBalance,
    };
  }
}

/// Represents leave quota entitlement and usage for a specific category (GET /me/leave/balances)
class LeaveBalanceModel {
  final LeaveTypeModel? typeModel;
  final String leaveType;
  final double entitlement;
  final double earned;
  final double adjusted;
  final double carried;
  final double carriedLeft;
  final double expired;
  final double taken;
  final double booked;
  final double pending;
  final double holidays;
  final double unpaid;
  final double? available;
  final double total;
  final Map<String, dynamic> textMap;
  final String colorHex;

  const LeaveBalanceModel({
    this.typeModel,
    required this.leaveType,
    required this.entitlement,
    this.earned = 0.0,
    this.adjusted = 0.0,
    this.carried = 0.0,
    this.carriedLeft = 0.0,
    this.expired = 0.0,
    required this.taken,
    this.booked = 0.0,
    this.pending = 0.0,
    this.holidays = 0.0,
    this.unpaid = 0.0,
    this.available,
    required this.total,
    this.textMap = const {},
    required this.colorHex,
  });

  // Backward compatibility getters for existing UI
  String get name => leaveType;
  String get categoryName => leaveType;
  double get remaining => (available ?? (totalQuota - usedCount).toDouble());
  double get remainingDays => remaining;
  int get totalQuota => entitlement > 0 ? entitlement.toInt() : total.toInt();
  int get usedCount => taken.toInt();
  int get remainingCount => (available ?? (totalQuota - usedCount).toDouble()).toInt();

  /// Ratio of quota utilized (0.0 to 1.0)
  double get utilizationRatio =>
      totalQuota > 0 ? (usedCount / totalQuota).clamp(0.0, 1.0) : 0.0;

  /// Ratio of quota remaining (0.0 to 1.0)
  double get remainingRatio =>
      totalQuota > 0 ? (remainingCount / totalQuota).clamp(0.0, 1.0) : 0.0;

  /// Resolved brand accent color strictly from AppColors tokens
  Color get accentColor {
    if (typeModel != null) {
      return typeModel!.resolvedColor;
    }
    final type = leaveType.toLowerCase();
    if (type.contains('casual')) {
      return AppColors.secondary;
    } else if (type.contains('annual')) {
      return AppColors.primary;
    } else if (type.contains('medical') || type.contains('sick')) {
      return AppColors.warning;
    }
    return AppColors.primary;
  }

  factory LeaveBalanceModel.fromJson(Map<String, dynamic> json) {
    LeaveTypeModel? parsedType;
    String name = 'General Leave';
    if (json['type'] is Map) {
      parsedType = LeaveTypeModel.fromJson(Map<String, dynamic>.from(json['type'] as Map));
      name = parsedType.name;
    } else if (json['leave_type'] is String) {
      name = json['leave_type'] as String;
    } else if (json['name'] is String) {
      name = json['name'] as String;
    }

    final double ent = (json['entitlement'] as num?)?.toDouble() ??
        (json['total_quota'] as num?)?.toDouble() ??
        (json['allocated_days'] as num?)?.toDouble() ??
        0.0;
    final double tk = (json['taken'] as num?)?.toDouble() ??
        (json['used_count'] as num?)?.toDouble() ??
        (json['used_days'] as num?)?.toDouble() ??
        0.0;
    final double? avail = json.containsKey('available') && json['available'] != null
        ? (json['available'] as num).toDouble()
        : (json.containsKey('remaining_count')
            ? (json['remaining_count'] as num?)?.toDouble()
            : (json.containsKey('remaining_days')
                ? (json['remaining_days'] as num?)?.toDouble()
                : null));

    return LeaveBalanceModel(
      typeModel: parsedType,
      leaveType: name,
      entitlement: ent,
      earned: (json['earned'] as num?)?.toDouble() ?? 0.0,
      adjusted: (json['adjusted'] as num?)?.toDouble() ?? 0.0,
      carried: (json['carried'] as num?)?.toDouble() ?? 0.0,
      carriedLeft: (json['carried_left'] as num?)?.toDouble() ?? 0.0,
      expired: (json['expired'] as num?)?.toDouble() ?? 0.0,
      taken: tk,
      booked: (json['booked'] as num?)?.toDouble() ?? 0.0,
      pending: (json['pending'] as num?)?.toDouble() ?? (json['pending_days'] as num?)?.toDouble() ?? 0.0,
      holidays: (json['holidays'] as num?)?.toDouble() ?? 0.0,
      unpaid: (json['unpaid'] as num?)?.toDouble() ?? 0.0,
      available: avail,
      total: (json['total'] as num?)?.toDouble() ?? ent,
      textMap: json['text'] is Map ? Map<String, dynamic>.from(json['text'] as Map) : {},
      colorHex: (json['color_hex'] as String?) ?? (json['color'] as String?) ?? '0xFF012B43',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (typeModel != null) 'type': typeModel!.toJson(),
      'leave_type': leaveType,
      'entitlement': entitlement,
      'earned': earned,
      'taken': taken,
      'available': available,
      'total': total,
      'text': textMap,
      'color_hex': colorHex,
    };
  }
}

/// Represents dry-run calculation results from POST /me/leave/requests/preview
class LeavePreviewModel {
  final bool ok;
  final String? message;
  final Map<String, dynamic> fields;
  final double days;
  final double amount;
  final String amountText;
  final String availableText;
  final String afterText;

  const LeavePreviewModel({
    required this.ok,
    this.message,
    this.fields = const {},
    required this.days,
    required this.amount,
    required this.amountText,
    required this.availableText,
    required this.afterText,
  });

  factory LeavePreviewModel.fromJson(Map<String, dynamic> json) {
    return LeavePreviewModel(
      ok: json['ok'] == true,
      message: json['message']?.toString(),
      fields: json['fields'] is Map ? Map<String, dynamic>.from(json['fields'] as Map) : {},
      days: (json['days'] as num?)?.toDouble() ?? 0.0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      amountText: json['amount_text']?.toString() ?? '',
      availableText: json['available_text']?.toString() ?? '',
      afterText: json['after_text']?.toString() ?? '',
    );
  }
}

/// Represents colleague leave record from GET /leave/whos-off
class WhosOffItemModel {
  final String date;
  final String employeeId;
  final String employeeName;
  final String? department;
  final String type;
  final String portion; // 'full', 'first_half', 'second_half'

  const WhosOffItemModel({
    required this.date,
    required this.employeeId,
    required this.employeeName,
    this.department,
    required this.type,
    required this.portion,
  });

  factory WhosOffItemModel.fromJson(Map<String, dynamic> json) {
    String empId = '';
    String empName = '';
    String? dept;
    if (json['employee'] is Map) {
      final emp = json['employee'] as Map;
      empId = emp['id']?.toString() ?? '';
      empName = emp['name']?.toString() ?? '';
      dept = emp['department']?.toString();
    }

    return WhosOffItemModel(
      date: json['date']?.toString() ?? '',
      employeeId: empId,
      employeeName: empName,
      department: dept,
      type: json['type']?.toString() ?? '',
      portion: json['portion']?.toString() ?? 'full',
    );
  }
}

/// Breakdown of individual calendar days for a leave application
class LeaveDayBreakdownModel {
  final String date;
  final String portion;
  final String kind; // 'leave' or 'sandwich'
  final double amount;
  final bool isPaid;

  const LeaveDayBreakdownModel({
    required this.date,
    required this.portion,
    required this.kind,
    required this.amount,
    required this.isPaid,
  });

  factory LeaveDayBreakdownModel.fromJson(Map<String, dynamic> json) {
    return LeaveDayBreakdownModel(
      date: json['date']?.toString() ?? '',
      portion: json['portion']?.toString() ?? 'full',
      kind: json['kind']?.toString() ?? 'leave',
      amount: (json['amount'] as num?)?.toDouble() ?? 1.0,
      isPaid: json['is_paid'] == true,
    );
  }
}

/// Represents an individual leave application and its approval workflow status (GET /me/leave/requests)
class LeaveRequestItemModel {
  final String id;
  final LeaveTypeModel? type;
  final String leaveType;
  final String startsOn;
  final String endsOn;
  final String startPart;
  final String endPart;
  final String? startsAt;
  final int? minutes;
  final double amount;
  final String amountText;
  final String summary;
  final String reason;
  final bool hasAttachment;
  final String status; // 'pending', 'approved', 'rejected', 'cancelled'
  final String statusLabel;
  final String statusTone;
  final String source; // 'self' or 'hr'
  final String? cancelReason;
  final List<LeaveDayBreakdownModel> days;

  const LeaveRequestItemModel({
    required this.id,
    this.type,
    required this.leaveType,
    required this.startsOn,
    required this.endsOn,
    this.startPart = 'full',
    this.endPart = 'full',
    this.startsAt,
    this.minutes,
    required this.amount,
    required this.amountText,
    required this.summary,
    required this.reason,
    this.hasAttachment = false,
    required this.status,
    required this.statusLabel,
    this.statusTone = 'amber',
    this.source = 'self',
    this.cancelReason,
    this.days = const [],
    this.managerNotes,
    this.appliedAt,
    this.attachmentName,
  });

  // Backward-compatible getters for legacy components
  String get startDate => startsOn;
  String get endDate => endsOn;
  int get totalDays => amount.toInt();
  final String? managerNotes;
  final String? appliedAt;
  final String? attachmentName;

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isApproved => status.toLowerCase() == 'approved';
  bool get isRejected => status.toLowerCase() == 'rejected';
  bool get isCancelled => status.toLowerCase() == 'cancelled';

  factory LeaveRequestItemModel.fromJson(Map<String, dynamic> json) {
    LeaveTypeModel? parsedType;
    String typeName = 'General Leave';
    if (json['type'] is Map) {
      parsedType = LeaveTypeModel.fromJson(Map<String, dynamic>.from(json['type'] as Map));
      typeName = parsedType.name;
    } else if (json['leave_type'] is String) {
      typeName = json['leave_type'] as String;
    }

    final daysList = <LeaveDayBreakdownModel>[];
    if (json['days'] is List) {
      for (final d in json['days'] as List) {
        if (d is Map) {
          daysList.add(LeaveDayBreakdownModel.fromJson(Map<String, dynamic>.from(d)));
        }
      }
    }

    return LeaveRequestItemModel(
      id: json['id']?.toString() ?? '',
      type: parsedType,
      leaveType: typeName,
      startsOn: json['starts_on']?.toString() ?? json['start_date']?.toString() ?? '',
      endsOn: json['ends_on']?.toString() ?? json['end_date']?.toString() ?? '',
      startPart: json['start_part']?.toString() ?? 'full',
      endPart: json['end_part']?.toString() ?? 'full',
      startsAt: json['starts_at']?.toString(),
      minutes: (json['minutes'] as num?)?.toInt(),
      amount: (json['amount'] as num?)?.toDouble() ?? (json['total_days'] as num?)?.toDouble() ?? 1.0,
      amountText: json['amount_text']?.toString() ?? '${json['total_days'] ?? 1} Days',
      summary: json['summary']?.toString() ?? typeName,
      reason: json['reason']?.toString() ?? '',
      hasAttachment: json['has_attachment'] == true || json['attachment'] != null,
      status: json['status']?.toString() ?? 'pending',
      statusLabel: json['status_label']?.toString() ?? 'Waiting',
      statusTone: json['status_tone']?.toString() ?? 'amber',
      source: json['source']?.toString() ?? 'self',
      cancelReason: json['cancel_reason']?.toString(),
      days: daysList,
    );
  }
}

/// Represents subordinate employee leave audit data for Manager / HR (GET /employees/{id}/leave)
class EmployeeLeaveAuditModel {
  final List<LeaveBalanceModel> balances;
  final List<LeaveRequestItemModel> requests;

  const EmployeeLeaveAuditModel({
    required this.balances,
    required this.requests,
  });

  factory EmployeeLeaveAuditModel.fromJson(Map<String, dynamic> json) {
    final balancesList = <LeaveBalanceModel>[];
    if (json['balances'] is List) {
      for (final item in json['balances'] as List) {
        if (item is Map) {
          balancesList.add(
            LeaveBalanceModel.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    final requestsList = <LeaveRequestItemModel>[];
    if (json['requests'] is List) {
      for (final item in json['requests'] as List) {
        if (item is Map) {
          requestsList.add(
            LeaveRequestItemModel.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    return EmployeeLeaveAuditModel(
      balances: balancesList,
      requests: requestsList,
    );
  }
}
