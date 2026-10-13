/// Represents an individual punch regularization or overtime claim request
class AdjustmentRequestItem {
  final String id;
  final String type; // 'Missed Punch' or 'Overtime Claim'
  final String date;
  final String details;
  final String status; // 'Pending', 'Approved', 'Rejected'
  final String appliedAt;
  final String? remarks;
  final String? reviewerNotes;

  const AdjustmentRequestItem({
    required this.id,
    required this.type,
    required this.date,
    required this.details,
    required this.status,
    required this.appliedAt,
    this.remarks,
    this.reviewerNotes,
  });

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isApproved => status.toLowerCase() == 'approved';
  bool get isRejected => status.toLowerCase() == 'rejected';
  bool get isMissedPunch => type.toLowerCase().contains('missed');
  bool get isOvertime => type.toLowerCase().contains('overtime');

  factory AdjustmentRequestItem.fromJson(Map<String, dynamic> json) {
    return AdjustmentRequestItem(
      id: json['id'] as String? ?? 'REG-0000',
      type: json['type'] as String? ?? 'Missed Punch',
      date: json['date'] as String? ?? '',
      details: json['details'] as String? ?? '',
      status: json['status'] as String? ?? 'Pending',
      appliedAt: json['applied_at'] as String? ?? '',
      remarks: json['remarks'] as String?,
      reviewerNotes: json['reviewer_notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'date': date,
      'details': details,
      'status': status,
      'applied_at': appliedAt,
      if (remarks != null) 'remarks': remarks,
      if (reviewerNotes != null) 'reviewer_notes': reviewerNotes,
    };
  }

  AdjustmentRequestItem copyWith({
    String? id,
    String? type,
    String? date,
    String? details,
    String? status,
    String? appliedAt,
    String? remarks,
    String? reviewerNotes,
  }) {
    return AdjustmentRequestItem(
      id: id ?? this.id,
      type: type ?? this.type,
      date: date ?? this.date,
      details: details ?? this.details,
      status: status ?? this.status,
      appliedAt: appliedAt ?? this.appliedAt,
      remarks: remarks ?? this.remarks,
      reviewerNotes: reviewerNotes ?? this.reviewerNotes,
    );
  }
}

/// Monthly telemetry metrics for regularization limits and accrued overtime
class RegularizationTelemetry {
  final double monthlyOvertimeHours;
  final int adjustmentsRemaining;
  final int maxAdjustments;
  final int pendingApprovalsCount;

  const RegularizationTelemetry({
    required this.monthlyOvertimeHours,
    required this.adjustmentsRemaining,
    this.maxAdjustments = 3,
    required this.pendingApprovalsCount,
  });

  factory RegularizationTelemetry.fromJson(Map<String, dynamic> json) {
    return RegularizationTelemetry(
      monthlyOvertimeHours:
          (json['monthly_overtime_hours'] as num?)?.toDouble() ?? 0.0,
      adjustmentsRemaining: json['adjustments_remaining'] as int? ?? 2,
      maxAdjustments: json['max_adjustments'] as int? ?? 3,
      pendingApprovalsCount: json['pending_approvals_count'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'monthly_overtime_hours': monthlyOvertimeHours,
      'adjustments_remaining': adjustmentsRemaining,
      'max_adjustments': maxAdjustments,
      'pending_approvals_count': pendingApprovalsCount,
    };
  }

  RegularizationTelemetry copyWith({
    double? monthlyOvertimeHours,
    int? adjustmentsRemaining,
    int? maxAdjustments,
    int? pendingApprovalsCount,
  }) {
    return RegularizationTelemetry(
      monthlyOvertimeHours:
          monthlyOvertimeHours ?? this.monthlyOvertimeHours,
      adjustmentsRemaining:
          adjustmentsRemaining ?? this.adjustmentsRemaining,
      maxAdjustments: maxAdjustments ?? this.maxAdjustments,
      pendingApprovalsCount:
          pendingApprovalsCount ?? this.pendingApprovalsCount,
    );
  }
}
