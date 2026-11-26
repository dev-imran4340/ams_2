import 'package:flutter/material.dart';
import '../../../core/utils/app_colors.dart';

/// Helpdesk Category Model from GET /helpdesk/categories
class HelpdeskCategoryModel {
  final String id;
  final String name;

  const HelpdeskCategoryModel({
    required this.id,
    required this.name,
  });

  factory HelpdeskCategoryModel.fromJson(Map<String, dynamic> json) {
    return HelpdeskCategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'General',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is HelpdeskCategoryModel && other.id == id);

  @override
  int get hashCode => id.hashCode;
}

/// Attachment file for ticket messages
class HelpdeskFileModel {
  final String id;
  final String name;
  final String? url;
  final String? mime;
  final int? size;

  const HelpdeskFileModel({
    required this.id,
    required this.name,
    this.url,
    this.mime,
    this.size,
  });

  factory HelpdeskFileModel.fromJson(Map<String, dynamic> json) {
    return HelpdeskFileModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Attachment',
      url: json['url']?.toString(),
      mime: json['mime']?.toString(),
      size: json['size'] as int?,
    );
  }
}

/// Message / Reply in a ticket thread
class HelpdeskMessageModel {
  final String id;
  final String author;
  final bool fromRaiser;
  final bool isInternal;
  final String body;
  final String createdAt;
  final List<HelpdeskFileModel> files;

  const HelpdeskMessageModel({
    required this.id,
    required this.author,
    this.fromRaiser = false,
    this.isInternal = false,
    required this.body,
    required this.createdAt,
    this.files = const [],
  });

  factory HelpdeskMessageModel.fromJson(Map<String, dynamic> json) {
    final rawFiles = json['files'];
    final List<HelpdeskFileModel> fileList = [];
    if (rawFiles is List) {
      for (final f in rawFiles) {
        if (f is Map<String, dynamic>) {
          fileList.add(HelpdeskFileModel.fromJson(f));
        }
      }
    }

    return HelpdeskMessageModel(
      id: json['id']?.toString() ?? '',
      author: json['author']?.toString() ?? 'User',
      fromRaiser: json['from_raiser'] == true,
      isInternal: json['is_internal'] == true,
      body: json['body']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      files: fileList,
    );
  }
}

/// Primary Helpdesk Ticket Model (GET /helpdesk/tickets & GET /helpdesk/tickets/{id})
class HelpdeskTicketModel {
  final String id;
  final String reference;
  final String subject;
  final String category;
  final bool isConfidential;
  final String status;
  final String statusLabel;
  final String statusTone;
  final String priority;
  final String? raisedByName;
  final String? assigneeName;
  final String createdAt;
  final String? lastActivityAt;
  final String? resolvedAt;
  final List<HelpdeskMessageModel> messages;

  const HelpdeskTicketModel({
    required this.id,
    required this.reference,
    required this.subject,
    required this.category,
    this.isConfidential = false,
    this.status = 'open',
    this.statusLabel = 'Open',
    this.statusTone = 'amber',
    this.priority = 'normal',
    this.raisedByName,
    this.assigneeName,
    required this.createdAt,
    this.lastActivityAt,
    this.resolvedAt,
    this.messages = const [],
  });

  factory HelpdeskTicketModel.fromJson(Map<String, dynamic> json) {
    final raisedBy = json['raised_by'];
    String? raiser;
    if (raisedBy is Map<String, dynamic>) {
      raiser = raisedBy['name']?.toString();
    } else if (raisedBy is String) {
      raiser = raisedBy;
    }

    final assignee = json['assignee'];
    String? assigned;
    if (assignee is Map<String, dynamic>) {
      assigned = assignee['name']?.toString();
    } else if (assignee is String) {
      assigned = assignee;
    }

    final rawMessages = json['messages'];
    final List<HelpdeskMessageModel> messageList = [];
    if (rawMessages is List) {
      for (final m in rawMessages) {
        if (m is Map<String, dynamic>) {
          messageList.add(HelpdeskMessageModel.fromJson(m));
        }
      }
    }

    return HelpdeskTicketModel(
      id: json['id']?.toString() ?? '',
      reference: json['reference']?.toString() ?? 'HD-0000',
      subject: json['subject']?.toString() ?? 'No Subject',
      category: json['category'] is Map
          ? (json['category']['name']?.toString() ?? 'General')
          : (json['category']?.toString() ?? 'General'),
      isConfidential: json['is_confidential'] == true,
      status: json['status']?.toString() ?? 'open',
      statusLabel: json['status_label']?.toString() ?? 'Open',
      statusTone: json['status_tone']?.toString() ?? 'amber',
      priority: json['priority']?.toString() ?? 'normal',
      raisedByName: raiser,
      assigneeName: assigned,
      createdAt: json['created_at']?.toString() ?? '',
      lastActivityAt: json['last_activity_at']?.toString(),
      resolvedAt: json['resolved_at']?.toString(),
      messages: messageList,
    );
  }

  HelpdeskTicketModel copyWith({
    String? id,
    String? reference,
    String? subject,
    String? category,
    bool? isConfidential,
    String? status,
    String? statusLabel,
    String? statusTone,
    String? priority,
    String? raisedByName,
    String? assigneeName,
    String? createdAt,
    String? lastActivityAt,
    String? resolvedAt,
    List<HelpdeskMessageModel>? messages,
  }) {
    return HelpdeskTicketModel(
      id: id ?? this.id,
      reference: reference ?? this.reference,
      subject: subject ?? this.subject,
      category: category ?? this.category,
      isConfidential: isConfidential ?? this.isConfidential,
      status: status ?? this.status,
      statusLabel: statusLabel ?? this.statusLabel,
      statusTone: statusTone ?? this.statusTone,
      priority: priority ?? this.priority,
      raisedByName: raisedByName ?? this.raisedByName,
      assigneeName: assigneeName ?? this.assigneeName,
      createdAt: createdAt ?? this.createdAt,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      messages: messages ?? this.messages,
    );
  }

  bool get isOpen => status.toLowerCase() == 'open';
  bool get isInProgress => status.toLowerCase() == 'in_progress';
  bool get isWaitingOnUser => status.toLowerCase() == 'waiting_on_user' || status.toLowerCase() == 'waiting';
  bool get isResolved => status.toLowerCase() == 'resolved';
  bool get isClosed => status.toLowerCase() == 'closed' || status.toLowerCase() == 'cancelled';

  /// Standard Status Color mapping from status_tone
  Color get statusColor {
    switch (statusTone.toLowerCase()) {
      case 'emerald':
        return AppColors.success;
      case 'amber':
        return AppColors.warning;
      case 'rose':
        return AppColors.error;
      case 'blue':
      case 'brand':
        return AppColors.secondary;
      case 'slate':
      default:
        return AppColors.subTextColor;
    }
  }

  /// Priority Color Badge mapping
  Color get priorityColor {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return AppColors.error;
      case 'high':
        return AppColors.warning;
      case 'normal':
        return AppColors.secondary;
      case 'low':
      default:
        return AppColors.subTextColor;
    }
  }
}
