/// Model representing an employee daily task / deliverable
class TaskModel {
  final String id;
  final String title;
  final String description;
  final String priority; // 'Urgent', 'High', 'Medium', 'Low'
  final String status; // 'To Do', 'In Progress', 'Completed'
  final DateTime dueDate;
  final String projectTag;
  final bool isCompleted;

  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.dueDate,
    required this.projectTag,
    required this.isCompleted,
  });

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? priority,
    String? status,
    DateTime? dueDate,
    String? projectTag,
    bool? isCompleted,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      projectTag: projectTag ?? this.projectTag,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id']?.toString() ?? 'TSK-101',
      title: json['title']?.toString() ?? 'Untitled Task',
      description: json['description']?.toString() ?? '',
      priority: json['priority']?.toString() ?? 'Medium',
      status: json['status']?.toString() ?? 'To Do',
      dueDate: json['due_date'] != null
          ? DateTime.tryParse(json['due_date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      projectTag: json['project_tag']?.toString() ?? 'AMS 2 Mobile',
      isCompleted: json['is_completed'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority,
      'status': status,
      'due_date': dueDate.toIso8601String(),
      'project_tag': projectTag,
      'is_completed': isCompleted,
    };
  }
}

/// Telemetry metrics for task operational health
class TaskTelemetryModel {
  final int totalTasks;
  final int pendingCount;
  final int inProgressCount;
  final int completedCount;

  const TaskTelemetryModel({
    required this.totalTasks,
    required this.pendingCount,
    required this.inProgressCount,
    required this.completedCount,
  });

  factory TaskTelemetryModel.fromJson(Map<String, dynamic> json) {
    return TaskTelemetryModel(
      totalTasks: (json['total_tasks'] as num?)?.toInt() ?? 0,
      pendingCount: (json['pending_count'] as num?)?.toInt() ?? 0,
      inProgressCount: (json['in_progress_count'] as num?)?.toInt() ?? 0,
      completedCount: (json['completed_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_tasks': totalTasks,
      'pending_count': pendingCount,
      'in_progress_count': inProgressCount,
      'completed_count': completedCount,
    };
  }
}
