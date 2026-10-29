import 'package:flutter/material.dart';
import '../../../core/utils/app_colors.dart';

/// Employee summary associated with an approval request
class ApprovalEmployeeSummary {
  final String id;
  final String name;
  final String number;
  final String department;

  const ApprovalEmployeeSummary({
    required this.id,
    required this.name,
    required this.number,
    required this.department,
  });

  factory ApprovalEmployeeSummary.fromJson(Map<String, dynamic> json) {
    return ApprovalEmployeeSummary(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      number: json['number']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'number': number,
      'department': department,
    };
  }
}

/// Changes proposed in the request (e.g., contact phone change)
class ApprovalChangeModel {
  final String label;
  final String? before;
  final String? after;

  const ApprovalChangeModel({
    required this.label,
    this.before,
    this.after,
  });

  factory ApprovalChangeModel.fromJson(Map<String, dynamic> json) {
    return ApprovalChangeModel(
      label: json['label']?.toString() ?? '',
      before: json['before']?.toString(),
      after: json['after']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'before': before,
      'after': after,
    };
  }
}

/// Key/Value facts associated with the request (e.g. Duration: 3 Days)
class ApprovalFactModel {
  final String label;
  final String value;

  const ApprovalFactModel({
    required this.label,
    required this.value,
  });

  factory ApprovalFactModel.fromJson(Map<String, dynamic> json) {
    return ApprovalFactModel(
      label: json['label']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'value': value,
    };
  }
}

/// Individual workflow step in the multi-tier approval pipeline
class ApprovalStepModel {
  final int position;
  final String approver;
  final String status; // 'waiting', 'current', 'approved', 'rejected', 'skipped', 'not_reached'
  final String statusLabel;
  final String statusTone; // 'amber', 'emerald', 'rose', 'slate'
  final String? skippedReason;
  final List<String> approvers;

  const ApprovalStepModel({
    required this.position,
    required this.approver,
    required this.status,
    required this.statusLabel,
    required this.statusTone,
    this.skippedReason,
    this.approvers = const [],
  });

  factory ApprovalStepModel.fromJson(Map<String, dynamic> json) {
    final rawApprovers = json['approvers'];
    final approversList = (rawApprovers is List)
        ? rawApprovers.map((e) => e.toString()).toList()
        : <String>[];

    return ApprovalStepModel(
      position: (json['position'] as num?)?.toInt() ?? 1,
      approver: json['approver']?.toString() ?? '',
      status: json['status']?.toString() ?? 'waiting',
      statusLabel: json['status_label']?.toString() ?? '',
      statusTone: json['status_tone']?.toString() ?? 'slate',
      skippedReason: json['skipped_reason']?.toString(),
      approvers: approversList,
    );
  }

  Color get toneColor {
    switch (statusTone.toLowerCase()) {
      case 'emerald':
        return AppColors.success;
      case 'amber':
        return AppColors.warning;
      case 'rose':
        return AppColors.error;
      case 'slate':
      default:
        return AppColors.subTextColor;
    }
  }

  bool get isCurrent => status.toLowerCase() == 'current';
  bool get isApproved => status.toLowerCase() == 'approved';
  bool get isRejected => status.toLowerCase() == 'rejected';
  bool get isSkipped => status.toLowerCase() == 'skipped';

  IconData get stepIcon {
    if (isApproved) return Icons.check_circle_rounded;
    if (isRejected) return Icons.cancel_rounded;
    if (isSkipped) return Icons.fast_forward_rounded;
    if (isCurrent) return Icons.hourglass_top_rounded;
    return Icons.radio_button_unchecked_rounded;
  }
}

/// Audit record of an approved or rejected decision on a step
class ApprovalDecisionModel {
  final int step;
  final String by;
  final String decision; // 'approved', 'rejected'
  final String decisionLabel;
  final String? comment;
  final bool wasOverride;
  final String at;
  final String ago;

  const ApprovalDecisionModel({
    required this.step,
    required this.by,
    required this.decision,
    required this.decisionLabel,
    this.comment,
    this.wasOverride = false,
    required this.at,
    required this.ago,
  });

  factory ApprovalDecisionModel.fromJson(Map<String, dynamic> json) {
    return ApprovalDecisionModel(
      step: (json['step'] as num?)?.toInt() ?? 1,
      by: json['by']?.toString() ?? '',
      decision: json['decision']?.toString() ?? '',
      decisionLabel: json['decision_label']?.toString() ?? '',
      comment: json['comment']?.toString(),
      wasOverride: json['was_override'] == true,
      at: json['at']?.toString() ?? '',
      ago: json['ago']?.toString() ?? '',
    );
  }
}

/// Actionable capabilities granted by the server for the current viewer
class ApprovalPermissionsModel {
  final bool approve;
  final bool reject;
  final bool asOverride;
  final bool cancel;

  const ApprovalPermissionsModel({
    this.approve = false,
    this.reject = false,
    this.asOverride = false,
    this.cancel = false,
  });

  factory ApprovalPermissionsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ApprovalPermissionsModel();
    return ApprovalPermissionsModel(
      approve: json['approve'] == true,
      reject: json['reject'] == true,
      asOverride: json['as_override'] == true,
      cancel: json['cancel'] == true,
    );
  }

  bool get hasAnyAction => approve || reject || cancel;
}

/// Core model representing an Approval Request (both list row and detail view)
class ApprovalItemModel {
  final String id;
  final String type; // e.g. 'employee_details_change', 'leave_application'
  final String typeLabel;
  final String title;
  final ApprovalEmployeeSummary? employee;
  final String requestedBy;
  final String status; // 'pending', 'approved', 'rejected', 'cancelled'
  final String statusLabel;
  final String statusTone; // 'amber', 'emerald', 'rose', 'slate'
  final String? waitingOn;
  final String? submittedAt;
  final String? submittedAgo;
  final String? decidedAt;

  // Extended detail fields (populated from GET /approvals/{id})
  final List<ApprovalChangeModel> changes;
  final List<ApprovalFactModel> facts;
  final List<ApprovalStepModel> steps;
  final List<ApprovalDecisionModel> decisions;
  final ApprovalPermissionsModel can;

  const ApprovalItemModel({
    required this.id,
    required this.type,
    required this.typeLabel,
    required this.title,
    this.employee,
    required this.requestedBy,
    required this.status,
    required this.statusLabel,
    required this.statusTone,
    this.waitingOn,
    this.submittedAt,
    this.submittedAgo,
    this.decidedAt,
    this.changes = const [],
    this.facts = const [],
    this.steps = const [],
    this.decisions = const [],
    this.can = const ApprovalPermissionsModel(),
  });

  factory ApprovalItemModel.fromJson(Map<String, dynamic> json) {
    // 1. Employee
    ApprovalEmployeeSummary? employee;
    if (json['employee'] is Map<String, dynamic>) {
      employee = ApprovalEmployeeSummary.fromJson(json['employee'] as Map<String, dynamic>);
    }

    // 2. Changes
    final changesList = <ApprovalChangeModel>[];
    if (json['changes'] is List) {
      for (final item in json['changes'] as List) {
        if (item is Map<String, dynamic>) {
          changesList.add(ApprovalChangeModel.fromJson(item));
        }
      }
    }

    // 3. Facts
    final factsList = <ApprovalFactModel>[];
    if (json['facts'] is List) {
      for (final item in json['facts'] as List) {
        if (item is Map<String, dynamic>) {
          factsList.add(ApprovalFactModel.fromJson(item));
        }
      }
    }

    // 4. Steps
    final stepsList = <ApprovalStepModel>[];
    if (json['steps'] is List) {
      for (final item in json['steps'] as List) {
        if (item is Map<String, dynamic>) {
          stepsList.add(ApprovalStepModel.fromJson(item));
        }
      }
    }

    // 5. Decisions
    final decisionsList = <ApprovalDecisionModel>[];
    if (json['decisions'] is List) {
      for (final item in json['decisions'] as List) {
        if (item is Map<String, dynamic>) {
          decisionsList.add(ApprovalDecisionModel.fromJson(item));
        }
      }
    }

    // 6. Permissions
    ApprovalPermissionsModel can = const ApprovalPermissionsModel();
    if (json['can'] is Map<String, dynamic>) {
      can = ApprovalPermissionsModel.fromJson(json['can'] as Map<String, dynamic>);
    }

    return ApprovalItemModel(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      typeLabel: json['type_label']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      employee: employee,
      requestedBy: json['requested_by']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      statusLabel: json['status_label']?.toString() ?? 'Waiting',
      statusTone: json['status_tone']?.toString() ?? 'amber',
      waitingOn: json['waiting_on']?.toString(),
      submittedAt: json['submitted_at']?.toString(),
      submittedAgo: json['submitted_ago']?.toString(),
      decidedAt: json['decided_at']?.toString(),
      changes: changesList,
      facts: factsList,
      steps: stepsList,
      decisions: decisionsList,
      can: can,
    );
  }

  /// Resolved brand color based on the server-provided status tone
  Color get toneColor {
    switch (statusTone.toLowerCase()) {
      case 'emerald':
        return AppColors.success;
      case 'amber':
        return AppColors.warning;
      case 'rose':
        return AppColors.error;
      case 'slate':
      default:
        return AppColors.subTextColor;
    }
  }

  Color get toneBackgroundColor => toneColor.withValues(alpha: 0.12);

  IconData get statusIcon {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle_rounded;
      case 'pending':
      case 'waiting':
        return Icons.access_time_filled_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      case 'cancelled':
        return Icons.remove_circle_outline_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isApproved => status.toLowerCase() == 'approved';
  bool get isRejected => status.toLowerCase() == 'rejected';
  bool get isCancelled => status.toLowerCase() == 'cancelled';
}
