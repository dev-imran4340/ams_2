// Phase 18 Tasks & Deliverables Models
// Strictly matches doc/api.md schema and preserves UI backwards compatibility

class TaskAssigneeModel {
  final String id;
  final String name;
  final String? number;
  final String? avatar;

  const TaskAssigneeModel({
    required this.id,
    required this.name,
    this.number,
    this.avatar,
  });

  factory TaskAssigneeModel.fromJson(Map<String, dynamic> json) {
    return TaskAssigneeModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Assignee',
      number: json['number']?.toString(),
      avatar: json['avatar']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'number': number,
      'avatar': avatar,
    };
  }
}

class TaskChecklistRefModel {
  final String id;
  final String name;

  const TaskChecklistRefModel({
    required this.id,
    required this.name,
  });

  factory TaskChecklistRefModel.fromJson(Map<String, dynamic> json) {
    return TaskChecklistRefModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class TaskFileModel {
  final String id;
  final String name;
  final String size;
  final String? url;

  const TaskFileModel({
    required this.id,
    required this.name,
    required this.size,
    this.url,
  });

  factory TaskFileModel.fromJson(Map<String, dynamic> json) {
    return TaskFileModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Attachment',
      size: json['size']?.toString() ?? '',
      url: json['url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'size': size,
      'url': url,
    };
  }
}

class TaskCommentModel {
  final String id;
  final TaskAssigneeModel? author;
  final String body;
  final String createdAt;
  final List<TaskFileModel> files;

  const TaskCommentModel({
    required this.id,
    this.author,
    required this.body,
    required this.createdAt,
    this.files = const [],
  });

  factory TaskCommentModel.fromJson(Map<String, dynamic> json) {
    final authorRaw = json['author'];
    final filesRaw = json['files'];

    return TaskCommentModel(
      id: json['id']?.toString() ?? '',
      author: authorRaw is Map<String, dynamic>
          ? TaskAssigneeModel.fromJson(authorRaw)
          : null,
      body: json['body']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      files: filesRaw is List
          ? filesRaw
              .whereType<Map<String, dynamic>>()
              .map((f) => TaskFileModel.fromJson(f))
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author?.toJson(),
      'body': body,
      'created_at': createdAt,
      'files': files.map((f) => f.toJson()).toList(),
    };
  }
}

class TaskPermissionsModel {
  final bool work; // can tick complete / reopen
  final bool edit; // can change details

  const TaskPermissionsModel({
    this.work = true,
    this.edit = true,
  });

  factory TaskPermissionsModel.fromJson(Map<String, dynamic> json) {
    return TaskPermissionsModel(
      work: json['work'] != false,
      edit: json['edit'] != false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'work': work,
      'edit': edit,
    };
  }
}

class TaskGroupModel {
  final int total;
  final int done;

  const TaskGroupModel({
    required this.total,
    required this.done,
  });

  factory TaskGroupModel.fromJson(Map<String, dynamic> json) {
    return TaskGroupModel(
      total: (json['total'] as num?)?.toInt() ?? 0,
      done: (json['done'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'done': done,
    };
  }
}

/// Live Task Row & Details Entity matching GET /tasks and GET /tasks/{id}
class TaskModel {
  final String id;
  final String title;
  final String description;
  final String priority; // 'low', 'normal', 'high', 'urgent'
  final String priorityLabel;
  final String? dueOn; // YYYY-MM-DD
  final bool isOverdue;
  final String status; // 'open', 'finished', 'To Do', 'Completed'
  final String statusLabel;
  final TaskAssigneeModel? assignee;
  final TaskAssigneeModel? about;
  final TaskChecklistRefModel? checklist;
  final String? linked;
  final String? completedAt;
  final String? completedBy;
  final String? completionNote;
  final String? linkHelp;
  final TaskAssigneeModel? createdBy;
  final String? createdAt;
  final TaskGroupModel? group;
  final List<TaskFileModel> files;
  final List<TaskCommentModel> comments;
  final TaskPermissionsModel? can;

  // UI Backwards-compatibility field
  final String? customProjectTag;

  const TaskModel({
    required this.id,
    required this.title,
    this.description = '',
    this.priority = 'normal',
    this.priorityLabel = 'Normal',
    this.dueOn,
    this.isOverdue = false,
    this.status = 'open',
    this.statusLabel = 'To do',
    this.assignee,
    this.about,
    this.checklist,
    this.linked,
    this.completedAt,
    this.completedBy,
    this.completionNote,
    this.linkHelp,
    this.createdBy,
    this.createdAt,
    this.group,
    this.files = const [],
    this.comments = const [],
    this.can,
    this.customProjectTag,
  });

  /// Evaluates whether the task is in finished / completed state
  bool get isCompleted =>
      status == 'finished' ||
      status == 'Completed' ||
      completedAt != null;

  /// Fallback due date as DateTime for existing date calculation widgets
  DateTime get dueDate {
    if (dueOn != null && dueOn!.isNotEmpty) {
      final parsed = DateTime.tryParse(dueOn!);
      if (parsed != null) return parsed;
    }
    return DateTime.now();
  }

  /// UI Project Tag label for cards & headers
  String get projectTag {
    if (customProjectTag != null && customProjectTag!.isNotEmpty) {
      return customProjectTag!;
    }
    if (checklist != null && checklist!.name.isNotEmpty) {
      return checklist!.name;
    }
    if (linked != null && linked!.isNotEmpty) {
      return linked!;
    }
    return 'General Task';
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? priority,
    String? priorityLabel,
    String? dueOn,
    bool? isOverdue,
    String? status,
    String? statusLabel,
    TaskAssigneeModel? assignee,
    TaskAssigneeModel? about,
    TaskChecklistRefModel? checklist,
    String? linked,
    String? completedAt,
    String? completedBy,
    String? completionNote,
    String? linkHelp,
    TaskAssigneeModel? createdBy,
    String? createdAt,
    TaskGroupModel? group,
    List<TaskFileModel>? files,
    List<TaskCommentModel>? comments,
    TaskPermissionsModel? can,
    bool? isCompleted,
    DateTime? dueDate,
    String? projectTag,
  }) {
    final nextStatus = isCompleted != null
        ? (isCompleted ? 'finished' : 'open')
        : (status ?? this.status);

    final nextStatusLabel = isCompleted != null
        ? (isCompleted ? 'Finished' : 'To do')
        : (statusLabel ?? this.statusLabel);

    final nextDueOn = dueDate != null
        ? '${dueDate.year}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')}'
        : (dueOn ?? this.dueOn);

    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      priorityLabel: priorityLabel ?? this.priorityLabel,
      dueOn: nextDueOn,
      isOverdue: isOverdue ?? this.isOverdue,
      status: nextStatus,
      statusLabel: nextStatusLabel,
      assignee: assignee ?? this.assignee,
      about: about ?? this.about,
      checklist: checklist ?? this.checklist,
      linked: linked ?? this.linked,
      completedAt: completedAt ?? this.completedAt,
      completedBy: completedBy ?? this.completedBy,
      completionNote: completionNote ?? this.completionNote,
      linkHelp: linkHelp ?? this.linkHelp,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      group: group ?? this.group,
      files: files ?? this.files,
      comments: comments ?? this.comments,
      can: can ?? this.can,
      customProjectTag: projectTag ?? customProjectTag,
    );
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final assigneeRaw = json['assignee'];
    final aboutRaw = json['about'];
    final checklistRaw = json['checklist'];
    final createdByRaw = json['created_by'];
    final groupRaw = json['group'];
    final filesRaw = json['files'];
    final commentsRaw = json['comments'];
    final canRaw = json['can'];

    // Map due date string
    String? rawDue = json['due_on']?.toString();
    if (rawDue == null && json['due_date'] != null) {
      final dt = DateTime.tryParse(json['due_date'].toString());
      if (dt != null) {
        rawDue =
            '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      }
    }

    final rawStatus = json['status']?.toString() ?? 'open';
    final isDone = json['is_completed'] == true ||
        rawStatus == 'finished' ||
        rawStatus == 'Completed' ||
        json['completed_at'] != null;

    return TaskModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled Task',
      description: json['description']?.toString() ?? '',
      priority: json['priority']?.toString() ?? 'normal',
      priorityLabel: json['priority_label']?.toString() ??
          (json['priority']?.toString().toUpperCase() ?? 'NORMAL'),
      dueOn: rawDue,
      isOverdue: json['is_overdue'] == true,
      status: isDone ? 'finished' : (rawStatus == 'Completed' ? 'finished' : rawStatus),
      statusLabel: json['status_label']?.toString() ??
          (isDone ? 'Finished' : 'To do'),
      assignee: assigneeRaw is Map<String, dynamic>
          ? TaskAssigneeModel.fromJson(assigneeRaw)
          : null,
      about: aboutRaw is Map<String, dynamic>
          ? TaskAssigneeModel.fromJson(aboutRaw)
          : null,
      checklist: checklistRaw is Map<String, dynamic>
          ? TaskChecklistRefModel.fromJson(checklistRaw)
          : null,
      linked: json['linked']?.toString(),
      completedAt: json['completed_at']?.toString(),
      completedBy: json['completed_by']?.toString(),
      completionNote: json['completion_note']?.toString(),
      linkHelp: json['link_help']?.toString(),
      createdBy: createdByRaw is Map<String, dynamic>
          ? TaskAssigneeModel.fromJson(createdByRaw)
          : null,
      createdAt: json['created_at']?.toString(),
      group: groupRaw is Map<String, dynamic>
          ? TaskGroupModel.fromJson(groupRaw)
          : null,
      files: filesRaw is List
          ? filesRaw
              .whereType<Map<String, dynamic>>()
              .map((f) => TaskFileModel.fromJson(f))
              .toList()
          : const [],
      comments: commentsRaw is List
          ? commentsRaw
              .whereType<Map<String, dynamic>>()
              .map((c) => TaskCommentModel.fromJson(c))
              .toList()
          : const [],
      can: canRaw is Map<String, dynamic>
          ? TaskPermissionsModel.fromJson(canRaw)
          : null,
      customProjectTag: json['project_tag']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority,
      'priority_label': priorityLabel,
      'due_on': dueOn,
      'is_overdue': isOverdue,
      'status': status,
      'status_label': statusLabel,
      'assignee': assignee?.toJson(),
      'about': about?.toJson(),
      'checklist': checklist?.toJson(),
      'linked': linked,
      'completed_at': completedAt,
      'completed_by': completedBy,
      'completion_note': completionNote,
      'link_help': linkHelp,
      'created_by': createdBy?.toJson(),
      'created_at': createdAt,
      'group': group?.toJson(),
      'files': files.map((f) => f.toJson()).toList(),
      'comments': comments.map((c) => c.toJson()).toList(),
      'can': can?.toJson(),
      'is_completed': isCompleted,
      'project_tag': projectTag,
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
