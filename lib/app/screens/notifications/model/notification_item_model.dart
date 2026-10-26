import 'package:flutter/material.dart';
import '../../../core/utils/app_colors.dart';

/// Target payload indicating in-app navigation destination
class NotificationTargetModel {
  final String? screen;
  final String? id;

  const NotificationTargetModel({
    this.screen,
    this.id,
  });

  factory NotificationTargetModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const NotificationTargetModel();
    return NotificationTargetModel(
      screen: json['screen']?.toString(),
      id: json['id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (screen != null) 'screen': screen,
        if (id != null) 'id': id,
      };
}

/// Single in-app notification item received from GET /notifications
class NotificationItemModel {
  final String id;
  final String kind;
  final String title;
  final String body;
  final String? link;
  final NotificationTargetModel target;
  final bool read;
  final String? createdAt;
  final String? createdAgo;

  const NotificationItemModel({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    this.link,
    required this.target,
    required this.read,
    this.createdAt,
    this.createdAgo,
  });

  factory NotificationItemModel.fromJson(Map<String, dynamic> json) {
    return NotificationItemModel(
      id: json['id']?.toString() ?? '',
      kind: json['kind']?.toString() ?? 'approval_reminder',
      title: json['title']?.toString() ?? 'Notification',
      body: json['body']?.toString() ?? '',
      link: json['link']?.toString(),
      target: NotificationTargetModel.fromJson(
        json['target'] is Map<String, dynamic> ? json['target'] as Map<String, dynamic> : null,
      ),
      read: json['read'] == true,
      createdAt: json['created_at']?.toString(),
      createdAgo: json['created_ago']?.toString() ?? 'Just now',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind,
        'title': title,
        'body': body,
        if (link != null) 'link': link,
        'target': target.toJson(),
        'read': read,
        if (createdAt != null) 'created_at': createdAt,
        if (createdAgo != null) 'created_ago': createdAgo,
      };

  NotificationItemModel copyWith({
    String? id,
    String? kind,
    String? title,
    String? body,
    String? link,
    NotificationTargetModel? target,
    bool? read,
    String? createdAt,
    String? createdAgo,
  }) {
    return NotificationItemModel(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      body: body ?? this.body,
      link: link ?? this.link,
      target: target ?? this.target,
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
      createdAgo: createdAgo ?? this.createdAgo,
    );
  }

  /// Human-friendly kind badge text
  String get kindLabel {
    switch (kind) {
      case 'approval_needed':
        return 'Approval Needed';
      case 'request_approved':
        return 'Approved';
      case 'request_rejected':
        return 'Rejected';
      case 'approval_reminder':
        return 'Reminder';
      default:
        return 'Notice';
    }
  }

  /// Semantic icon based on kind
  IconData get kindIcon {
    switch (kind) {
      case 'approval_needed':
        return Icons.assignment_late_outlined;
      case 'request_approved':
        return Icons.check_circle_outline_rounded;
      case 'request_rejected':
        return Icons.cancel_outlined;
      case 'approval_reminder':
        return Icons.alarm_rounded;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  /// Theme tone color matching AMS 2 corporate rules
  Color get kindToneColor {
    switch (kind) {
      case 'approval_needed':
        return const Color(0xFFD97706); // Amber
      case 'request_approved':
        return const Color(0xFF059669); // Emerald
      case 'request_rejected':
        return const Color(0xFFE11D48); // Rose
      case 'approval_reminder':
        return AppColors.secondary; // Modern Teal
      default:
        return AppColors.primary;
    }
  }

  Color get kindBackgroundColor {
    switch (kind) {
      case 'approval_needed':
        return const Color(0xFFFEF3C7); // Lite Amber
      case 'request_approved':
        return const Color(0xFFD1FAE5); // Lite Emerald
      case 'request_rejected':
        return const Color(0xFFFFE4E6); // Lite Rose
      case 'approval_reminder':
        return AppColors.liteSecondary.withValues(alpha: 0.35);
      default:
        return AppColors.litePrimary.withValues(alpha: 0.25);
    }
  }
}

/// Metadata payload from notifications pagination
class NotificationMetaModel {
  final int page;
  final int perPage;
  final int total;
  final int lastPage;
  final int unread;

  const NotificationMetaModel({
    required this.page,
    required this.perPage,
    required this.total,
    required this.lastPage,
    required this.unread,
  });

  factory NotificationMetaModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const NotificationMetaModel(
        page: 1,
        perPage: 25,
        total: 0,
        lastPage: 1,
        unread: 0,
      );
    }
    return NotificationMetaModel(
      page: (json['page'] as num?)?.toInt() ?? 1,
      perPage: (json['per_page'] as num?)?.toInt() ?? 25,
      total: (json['total'] as num?)?.toInt() ?? 0,
      lastPage: (json['last_page'] as num?)?.toInt() ?? 1,
      unread: (json['unread'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Standard response envelope for GET /notifications
class NotificationsResponseModel {
  final List<NotificationItemModel> data;
  final NotificationMetaModel meta;

  const NotificationsResponseModel({
    required this.data,
    required this.meta,
  });

  factory NotificationsResponseModel.fromJson(Map<String, dynamic> json) {
    final list = <NotificationItemModel>[];
    if (json['data'] is List) {
      for (final item in json['data']) {
        if (item is Map<String, dynamic>) {
          list.add(NotificationItemModel.fromJson(item));
        } else if (item is Map) {
          list.add(NotificationItemModel.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    return NotificationsResponseModel(
      data: list,
      meta: NotificationMetaModel.fromJson(
        json['meta'] is Map<String, dynamic>
            ? json['meta'] as Map<String, dynamic>
            : (json['meta'] is Map ? Map<String, dynamic>.from(json['meta'] as Map) : null),
      ),
    );
  }
}
