import 'package:flutter/material.dart';
import '../../../core/utils/app_colors.dart';

/// Support ticket list item from GET /api/v1/support/tickets
class SupportTicketItemModel {
  final String id;
  final int number;
  final String subject;
  final String status;
  final String statusTone;
  final String? statusValue;
  final String? raisedBy;
  final String? updatedAt;
  final String? priority;
  final String? category;

  SupportTicketItemModel({
    required this.id,
    required this.number,
    required this.subject,
    required this.status,
    required this.statusTone,
    this.statusValue,
    this.raisedBy,
    this.updatedAt,
    this.priority,
    this.category,
  });

  factory SupportTicketItemModel.fromJson(Map<String, dynamic> json) {
    return SupportTicketItemModel(
      id: json['id']?.toString() ?? '',
      number: int.tryParse(json['number']?.toString() ?? '0') ?? 0,
      subject: json['subject']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Open',
      statusTone: json['status_tone']?.toString().toLowerCase().trim() ?? 'amber',
      statusValue: json['status_value']?.toString(),
      raisedBy: json['raised_by']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      priority: json['priority']?.toString(),
      category: json['category']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'subject': subject,
      'status': status,
      'status_tone': statusTone,
      'status_value': statusValue,
      'raised_by': raisedBy,
      'updated_at': updatedAt,
      'priority': priority,
      'category': category,
    };
  }

  /// Color mapping adhering to .agents/rules/ams.md status tones
  Color get statusColor {
    switch (statusTone) {
      case 'emerald':
      case 'green':
        return AppColors.success;
      case 'rose':
      case 'red':
        return AppColors.error;
      case 'amber':
      case 'yellow':
      case 'orange':
        return AppColors.warning;
      case 'blue':
      case 'sky':
        return AppColors.secondary;
      case 'slate':
      case 'grey':
      case 'gray':
      default:
        return AppColors.subTextColor;
    }
  }

  String get formattedCategory {
    final cat = (category ?? 'general').toLowerCase();
    switch (cat) {
      case 'technical':
        return 'Technical';
      case 'billing':
        return 'Billing';
      case 'account':
        return 'Account';
      case 'feature_request':
        return 'Feature Request';
      case 'other':
      default:
        return 'General';
    }
  }

  String get formattedPriority {
    final prio = (priority ?? 'normal').toLowerCase();
    switch (prio) {
      case 'urgent':
        return 'Urgent';
      case 'high':
        return 'High';
      case 'low':
        return 'Low';
      case 'normal':
      default:
        return 'Normal';
    }
  }

  String get formattedDate {
    if (updatedAt == null || updatedAt!.isEmpty) return '';
    try {
      final parsed = DateTime.parse(updatedAt!).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final month = months[parsed.month - 1];
      final hour = parsed.hour.toString().padLeft(2, '0');
      final minute = parsed.minute.toString().padLeft(2, '0');
      return '$month ${parsed.day}, ${parsed.year} at $hour:$minute';
    } catch (_) {
      return updatedAt!;
    }
  }
}

/// Detailed Support Ticket thread from GET /api/v1/support/tickets/{id}
class SupportTicketDetailsModel {
  final String id;
  final int number;
  final String subject;
  final String status;
  final String statusValue; // open, waiting_on_customer, resolved, closed
  final String priority;    // low, normal, high, urgent
  final String category;    // technical, billing, account, feature_request, other
  final String openedAt;
  final List<SupportMessageModel> messages;

  SupportTicketDetailsModel({
    required this.id,
    required this.number,
    required this.subject,
    required this.status,
    required this.statusValue,
    required this.priority,
    required this.category,
    required this.openedAt,
    required this.messages,
  });

  factory SupportTicketDetailsModel.fromJson(Map<String, dynamic> json) {
    var msgs = <SupportMessageModel>[];
    if (json['messages'] is List) {
      msgs = (json['messages'] as List)
          .map((m) => SupportMessageModel.fromJson(m as Map<String, dynamic>))
          .toList();
    }

    return SupportTicketDetailsModel(
      id: json['id']?.toString() ?? '',
      number: int.tryParse(json['number']?.toString() ?? '0') ?? 0,
      subject: json['subject']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Open',
      statusValue: json['status_value']?.toString().toLowerCase().trim() ?? 'open',
      priority: json['priority']?.toString().toLowerCase().trim() ?? 'normal',
      category: json['category']?.toString().toLowerCase().trim() ?? 'other',
      openedAt: json['opened_at']?.toString() ?? '',
      messages: msgs,
    );
  }

  bool get isOpen => statusValue == 'open' || statusValue == 'waiting_on_customer';
  bool get isResolved => statusValue == 'resolved';
  bool get isClosed => statusValue == 'closed';
  bool get canReopen => statusValue == 'resolved';

  Color get statusColor {
    switch (statusValue) {
      case 'resolved':
        return AppColors.success;
      case 'open':
        return AppColors.warning;
      case 'waiting_on_customer':
        return AppColors.secondary;
      case 'closed':
      default:
        return AppColors.subTextColor;
    }
  }
}

/// Individual Message inside a Support Ticket discussion thread
class SupportMessageModel {
  final String id;
  final bool fromUs; // true: AMS support team response, false: user message
  final String author;
  final String body;
  final String at;
  final List<SupportAttachmentModel> attachments;

  SupportMessageModel({
    required this.id,
    required this.fromUs,
    required this.author,
    required this.body,
    required this.at,
    required this.attachments,
  });

  factory SupportMessageModel.fromJson(Map<String, dynamic> json) {
    var atts = <SupportAttachmentModel>[];
    if (json['attachments'] is List) {
      atts = (json['attachments'] as List)
          .map((a) => SupportAttachmentModel.fromJson(a as Map<String, dynamic>))
          .toList();
    }

    return SupportMessageModel(
      id: json['id']?.toString() ?? '',
      fromUs: json['from_us'] == true,
      author: json['author']?.toString() ?? (json['from_us'] == true ? 'Support Agent' : 'You'),
      body: json['body']?.toString() ?? '',
      at: json['at']?.toString() ?? '',
      attachments: atts,
    );
  }

  String get formattedTime {
    if (at.isEmpty) return '';
    try {
      final parsed = DateTime.parse(at).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final month = months[parsed.month - 1];
      final hour = parsed.hour.toString().padLeft(2, '0');
      final minute = parsed.minute.toString().padLeft(2, '0');
      return '$month ${parsed.day}, $hour:$minute';
    } catch (_) {
      return at;
    }
  }
}

/// Attachment model for Support Ticket files
class SupportAttachmentModel {
  final String id;
  final String name;
  final int sizeKb;

  SupportAttachmentModel({
    required this.id,
    required this.name,
    required this.sizeKb,
  });

  factory SupportAttachmentModel.fromJson(Map<String, dynamic> json) {
    return SupportAttachmentModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'attachment',
      sizeKb: int.tryParse(json['size_kb']?.toString() ?? '0') ?? 0,
    );
  }

  String get formattedSize {
    if (sizeKb >= 1024) {
      final mb = sizeKb / 1024.0;
      return '${mb.toStringAsFixed(1)} MB';
    }
    return '$sizeKb KB';
  }
}
