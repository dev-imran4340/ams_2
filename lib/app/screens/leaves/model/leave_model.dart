import 'package:flutter/material.dart';
import '../../../core/utils/app_colors.dart';

/// Represents leave quota entitlement and usage for a specific category
class LeaveBalanceModel {
  final String leaveType;
  final int totalQuota;
  final int usedCount;
  final int remainingCount;
  final String colorHex;

  const LeaveBalanceModel({
    required this.leaveType,
    required this.totalQuota,
    required this.usedCount,
    required this.remainingCount,
    required this.colorHex,
  });

  /// Ratio of quota utilized (0.0 to 1.0)
  double get utilizationRatio =>
      totalQuota > 0 ? (usedCount / totalQuota).clamp(0.0, 1.0) : 0.0;

  /// Ratio of quota remaining (0.0 to 1.0)
  double get remainingRatio =>
      totalQuota > 0 ? (remainingCount / totalQuota).clamp(0.0, 1.0) : 0.0;

  /// Resolved brand accent color strictly from AppColors tokens
  Color get accentColor {
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
    return LeaveBalanceModel(
      leaveType: json['leave_type'] as String? ?? 'General Leave',
      totalQuota: json['total_quota'] as int? ?? 0,
      usedCount: json['used_count'] as int? ?? 0,
      remainingCount: json['remaining_count'] as int? ?? 0,
      colorHex: json['color_hex'] as String? ?? '0xFF012B43',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'leave_type': leaveType,
      'total_quota': totalQuota,
      'used_count': usedCount,
      'remaining_count': remainingCount,
      'color_hex': colorHex,
    };
  }

  LeaveBalanceModel copyWith({
    String? leaveType,
    int? totalQuota,
    int? usedCount,
    int? remainingCount,
    String? colorHex,
  }) {
    return LeaveBalanceModel(
      leaveType: leaveType ?? this.leaveType,
      totalQuota: totalQuota ?? this.totalQuota,
      usedCount: usedCount ?? this.usedCount,
      remainingCount: remainingCount ?? this.remainingCount,
      colorHex: colorHex ?? this.colorHex,
    );
  }
}

/// Represents an individual leave application and its approval workflow status
class LeaveRequestItemModel {
  final String id;
  final String leaveType;
  final String startDate;
  final String endDate;
  final int totalDays;
  final String reason;
  final String status; // 'Pending', 'Approved', 'Rejected'
  final String appliedAt;
  final String? managerNotes;
  final String? attachmentName;

  const LeaveRequestItemModel({
    required this.id,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.reason,
    required this.status,
    required this.appliedAt,
    this.managerNotes,
    this.attachmentName,
  });

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isApproved => status.toLowerCase() == 'approved';
  bool get isRejected => status.toLowerCase() == 'rejected';

  factory LeaveRequestItemModel.fromJson(Map<String, dynamic> json) {
    return LeaveRequestItemModel(
      id: json['id'] as String? ?? '',
      leaveType: json['leave_type'] as String? ?? 'Casual Leave',
      startDate: json['start_date'] as String? ?? '',
      endDate: json['end_date'] as String? ?? '',
      totalDays: json['total_days'] as int? ?? 1,
      reason: json['reason'] as String? ?? '',
      status: json['status'] as String? ?? 'Pending',
      appliedAt: json['applied_at'] as String? ?? '',
      managerNotes: json['manager_notes'] as String?,
      attachmentName: json['attachment_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'leave_type': leaveType,
      'start_date': startDate,
      'end_date': endDate,
      'total_days': totalDays,
      'reason': reason,
      'status': status,
      'applied_at': appliedAt,
      if (managerNotes != null) 'manager_notes': managerNotes,
      if (attachmentName != null) 'attachment_name': attachmentName,
    };
  }

  LeaveRequestItemModel copyWith({
    String? id,
    String? leaveType,
    String? startDate,
    String? endDate,
    int? totalDays,
    String? reason,
    String? status,
    String? appliedAt,
    String? managerNotes,
    String? attachmentName,
  }) {
    return LeaveRequestItemModel(
      id: id ?? this.id,
      leaveType: leaveType ?? this.leaveType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalDays: totalDays ?? this.totalDays,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      appliedAt: appliedAt ?? this.appliedAt,
      managerNotes: managerNotes ?? this.managerNotes,
      attachmentName: attachmentName ?? this.attachmentName,
    );
  }
}
