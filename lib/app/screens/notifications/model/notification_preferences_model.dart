import 'package:flutter/material.dart';

/// Single notification channel toggle state for an individual notification kind
class ChannelPreferenceModel {
  final bool mail;
  final bool bell; // In-app notification bell. Server rule: Cannot be switched off (always true)
  final bool push;

  const ChannelPreferenceModel({
    required this.mail,
    required this.bell,
    required this.push,
  });

  factory ChannelPreferenceModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ChannelPreferenceModel(
        mail: true,
        bell: true,
        push: true,
      );
    }
    return ChannelPreferenceModel(
      mail: json['mail'] == true,
      bell: json['bell'] != false, // Default true, locked
      push: json['push'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'mail': mail,
        'bell': bell,
        'push': push,
      };

  ChannelPreferenceModel copyWith({
    bool? mail,
    bool? bell,
    bool? push,
  }) {
    return ChannelPreferenceModel(
      mail: mail ?? this.mail,
      bell: bell ?? this.bell,
      push: push ?? this.push,
    );
  }
}

/// Dynamic preferences grid mapping notification kinds to channel toggles (GET /me/notification-preferences)
class NotificationPreferencesModel {
  final Map<String, ChannelPreferenceModel> categories;

  const NotificationPreferencesModel({
    required this.categories,
  });

  factory NotificationPreferencesModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> source = json;
    if (json.containsKey('data') && json['data'] is Map<String, dynamic>) {
      source = json['data'] as Map<String, dynamic>;
    } else if (json.containsKey('data') && json['data'] is Map) {
      source = Map<String, dynamic>.from(json['data'] as Map);
    }

    final map = <String, ChannelPreferenceModel>{};
    for (final entry in source.entries) {
      if (entry.value is Map) {
        map[entry.key] = ChannelPreferenceModel.fromJson(
          Map<String, dynamic>.from(entry.value as Map),
        );
      }
    }

    return NotificationPreferencesModel(categories: map);
  }

  Map<String, dynamic> toJson() {
    return categories.map((k, v) => MapEntry(k, v.toJson()));
  }

  /// Helper to get channel preferences for a given kind
  ChannelPreferenceModel getForKind(String kind) {
    return categories[kind] ??
        const ChannelPreferenceModel(mail: true, bell: true, push: true);
  }

  /// Updates a single kind and returns a new immutable instance
  NotificationPreferencesModel copyWithCategory(
    String kind,
    ChannelPreferenceModel updated,
  ) {
    final newMap = Map<String, ChannelPreferenceModel>.from(categories);
    newMap[kind] = updated;
    return NotificationPreferencesModel(categories: newMap);
  }

  // Backwards compatibility getters
  ChannelPreferenceModel get approvalNeeded => getForKind('approval_needed');
  ChannelPreferenceModel get requestApproved => getForKind('request_approved');
  ChannelPreferenceModel get requestRejected => getForKind('request_rejected');
  ChannelPreferenceModel get approvalReminder => getForKind('approval_reminder');

  /// Official localized label from doc/api.md & server response specifications
  static String getKindLabel(String kind) {
    switch (kind) {
      case 'approval_needed':
        return 'A request needs my approval';
      case 'request_approved':
        return 'My request was approved';
      case 'request_rejected':
        return 'My request was rejected';
      case 'approval_reminder':
        return 'Daily reminder of requests still waiting for me';
      case 'schedule_changed':
        return 'Schedule Changed';
      case 'missing_check_out':
        return 'Missing Check-Out Alert';
      case 'device_silent':
        return 'Device Silent / Offline';
      case 'leave_recorded':
        return 'Leave Recorded';
      case 'leave_cancelled':
        return 'Leave Cancelled';
      case 'leave_expiring':
        return 'Leave Balance Expiring';
      case 'payslip_ready':
        return 'Payslip Ready';
      default:
        return kind
            .split('_')
            .map((word) => word.isNotEmpty
                ? '${word[0].toUpperCase()}${word.substring(1)}'
                : '')
            .join(' ');
    }
  }

  /// Subtitle description for each category
  static String getKindDescription(String kind) {
    switch (kind) {
      case 'approval_needed':
        return 'When an employee submits a request awaiting your decision.';
      case 'request_approved':
        return 'When your submitted leave or attendance request is granted.';
      case 'request_rejected':
        return 'When your submitted request is declined with reason.';
      case 'approval_reminder':
        return 'Daily digest for pending team requests awaiting review.';
      case 'schedule_changed':
        return 'When your assigned shift timings or rosters are updated.';
      case 'missing_check_out':
        return 'Reminders when a shift end checkout has not been logged.';
      case 'device_silent':
        return 'Alerts when attendance biometric terminal goes silent.';
      case 'leave_recorded':
        return 'When approved leave is logged to your company calendar.';
      case 'leave_cancelled':
        return 'When a scheduled leave booking is withdrawn or cancelled.';
      case 'leave_expiring':
        return 'Reminders when annual leave quota is nearing cycle expiry.';
      case 'payslip_ready':
        return 'When your monthly salary payslip is available to download.';
      default:
        return 'Workflow updates and system notifications for this category.';
    }
  }

  /// Associated icon for each category
  static IconData getKindIcon(String kind) {
    switch (kind) {
      case 'approval_needed':
        return Icons.assignment_turned_in_outlined;
      case 'request_approved':
        return Icons.verified_outlined;
      case 'request_rejected':
        return Icons.highlight_off_rounded;
      case 'approval_reminder':
        return Icons.schedule_rounded;
      case 'schedule_changed':
        return Icons.calendar_month_outlined;
      case 'missing_check_out':
        return Icons.timer_off_outlined;
      case 'device_silent':
        return Icons.phonelink_erase_rounded;
      case 'leave_recorded':
        return Icons.event_available_outlined;
      case 'leave_cancelled':
        return Icons.event_busy_outlined;
      case 'leave_expiring':
        return Icons.hourglass_bottom_rounded;
      case 'payslip_ready':
        return Icons.receipt_long_outlined;
      default:
        return Icons.notifications_active_outlined;
    }
  }
}
