import '../../../core/utils/app_colors.dart';
import 'package:flutter/material.dart';

/// Progress model for checklist completion
class ChecklistProgressModel {
  final int done;
  final int total;

  const ChecklistProgressModel({
    this.done = 0,
    this.total = 0,
  });

  factory ChecklistProgressModel.fromJson(Map<String, dynamic> json) {
    return ChecklistProgressModel(
      done: json['done'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'done': done,
        'total': total,
      };

  double get ratio => total > 0 ? (done / total).clamp(0.0, 1.0) : 0.0;
  int get percentage => (ratio * 100).round();
  bool get isComplete => total > 0 && done >= total;
}

/// Task item belonging to a checklist
class ChecklistTaskModel {
  final String id;
  final String title;
  final String priority;
  final String priorityLabel;
  final String? dueOn;
  final bool isOverdue;
  final String status;
  final String statusLabel;
  final String? assigneeName;
  final String? assigneeId;
  final String? linked;
  final String? completedAt;

  const ChecklistTaskModel({
    required this.id,
    required this.title,
    this.priority = 'normal',
    this.priorityLabel = 'Normal',
    this.dueOn,
    this.isOverdue = false,
    this.status = 'open',
    this.statusLabel = 'To do',
    this.assigneeName,
    this.assigneeId,
    this.linked,
    this.completedAt,
  });

  factory ChecklistTaskModel.fromJson(Map<String, dynamic> json) {
    final assignee = json['assignee'] is Map<String, dynamic>
        ? json['assignee'] as Map<String, dynamic>
        : null;

    return ChecklistTaskModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled Task',
      priority: json['priority']?.toString() ?? 'normal',
      priorityLabel: json['priority_label']?.toString() ?? 'Normal',
      dueOn: json['due_on']?.toString(),
      isOverdue: json['is_overdue'] == true,
      status: json['status']?.toString() ?? 'open',
      statusLabel: json['status_label']?.toString() ?? 'To do',
      assigneeName: assignee?['name']?.toString(),
      assigneeId: assignee?['id']?.toString(),
      linked: json['linked']?.toString(),
      completedAt: json['completed_at']?.toString(),
    );
  }

  bool get isCompleted => status.toLowerCase() == 'finished' || completedAt != null;
  bool get isOpen => !isCompleted && status.toLowerCase() != 'cancelled';
}

/// Comprehensive Checklist Model (Onboarding / Offboarding)
class ChecklistModel {
  final String id;
  final String name;
  final String kind; // 'onboarding' | 'offboarding'
  final String kindLabel;
  final String status; // 'open' | 'completed' | 'cancelled'
  final String statusLabel;
  final String? anchorOn;
  final String? anchorLabel;
  final String? employeeName;
  final String? employeeId;
  final ChecklistProgressModel progress;
  final List<ChecklistTaskModel> tasks;

  const ChecklistModel({
    required this.id,
    required this.name,
    this.kind = 'onboarding',
    this.kindLabel = 'Onboarding',
    this.status = 'open',
    this.statusLabel = 'In Progress',
    this.anchorOn,
    this.anchorLabel,
    this.employeeName,
    this.employeeId,
    this.progress = const ChecklistProgressModel(),
    this.tasks = const [],
  });

  factory ChecklistModel.fromJson(Map<String, dynamic> json) {
    final progressMap = json['progress'] is Map<String, dynamic>
        ? json['progress'] as Map<String, dynamic>
        : <String, dynamic>{};

    final emp = json['employee'] is Map<String, dynamic>
        ? json['employee'] as Map<String, dynamic>
        : null;

    final rawTasks = json['tasks'];
    final List<ChecklistTaskModel> taskList = [];
    if (rawTasks is List) {
      for (final t in rawTasks) {
        if (t is Map<String, dynamic>) {
          taskList.add(ChecklistTaskModel.fromJson(t));
        }
      }
    }

    return ChecklistModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Checklist',
      kind: json['kind']?.toString() ?? 'onboarding',
      kindLabel: json['kind_label']?.toString() ?? 'Onboarding',
      status: json['status']?.toString() ?? 'open',
      statusLabel: json['status_label']?.toString() ?? 'In Progress',
      anchorOn: json['anchor_on']?.toString(),
      anchorLabel: json['anchor_label']?.toString(),
      employeeName: emp?['name']?.toString(),
      employeeId: emp?['id']?.toString(),
      progress: ChecklistProgressModel.fromJson(progressMap),
      tasks: taskList,
    );
  }

  bool get isOnboarding => kind.toLowerCase() == 'onboarding';
  bool get isOffboarding => kind.toLowerCase() == 'offboarding';
  bool get isOpen => status.toLowerCase() == 'open';
  bool get isCompleted => status.toLowerCase() == 'completed' || progress.isComplete;

  Color get statusTone {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.subTextColor;
      case 'open':
      default:
        return AppColors.secondary;
    }
  }
}
