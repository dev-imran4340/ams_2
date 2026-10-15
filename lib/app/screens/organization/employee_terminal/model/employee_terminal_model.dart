/// Represents an employee punch event in the gate terminal
class PunchRecordItem {
  final String id;
  final String employeeId;
  final String employeeName;
  final String department;
  final String punchType; // 'Check-In' or 'Check-Out'
  final DateTime punchTime;
  final String? avatarUrl;
  final double matchConfidence;

  const PunchRecordItem({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.department,
    required this.punchType,
    required this.punchTime,
    this.avatarUrl,
    this.matchConfidence = 99.4,
  });

  bool get isCheckIn =>
      punchType.toLowerCase().contains('in') &&
      !punchType.toLowerCase().contains('out');

  /// Relative elapsed format e.g. "Just now", "2m ago", "45m ago"
  String get relativeTimeString {
    final now = DateTime.now();
    final difference = now.difference(punchTime);

    if (difference.inSeconds < 45) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  /// Formatted punch time e.g. "09:05:12 AM"
  String get formattedTime {
    final hour = punchTime.hour;
    final minute = punchTime.minute.toString().padLeft(2, '0');
    final second = punchTime.second.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final formattedHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$formattedHour:$minute:$second $period';
  }

  PunchRecordItem copyWith({
    String? id,
    String? employeeId,
    String? employeeName,
    String? department,
    String? punchType,
    DateTime? punchTime,
    String? avatarUrl,
    double? matchConfidence,
  }) {
    return PunchRecordItem(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      department: department ?? this.department,
      punchType: punchType ?? this.punchType,
      punchTime: punchTime ?? this.punchTime,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      matchConfidence: matchConfidence ?? this.matchConfidence,
    );
  }

  factory PunchRecordItem.fromJson(Map<String, dynamic> json) {
    return PunchRecordItem(
      id: json['id']?.toString() ?? '',
      employeeId: json['employee_id']?.toString() ?? '',
      employeeName: json['employee_name']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
      punchType: json['punch_type']?.toString() ?? 'Check-In',
      punchTime: json['punch_time'] != null
          ? DateTime.tryParse(json['punch_time'].toString()) ?? DateTime.now()
          : DateTime.now(),
      avatarUrl: json['avatar_url']?.toString(),
      matchConfidence: (json['match_confidence'] as num?)?.toDouble() ?? 99.4,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'employee_name': employeeName,
      'department': department,
      'punch_type': punchType,
      'punch_time': punchTime.toIso8601String(),
      'avatar_url': avatarUrl,
      'match_confidence': matchConfidence,
    };
  }
}

/// Represents real-time live attendance metrics on the station
class TerminalTelemetryModel {
  final int totalStaff;
  final int presentToday;
  final int absentToday;
  final int unmarked;

  const TerminalTelemetryModel({
    required this.totalStaff,
    required this.presentToday,
    required this.absentToday,
    required this.unmarked,
  });

  factory TerminalTelemetryModel.fromJson(Map<String, dynamic> json) {
    return TerminalTelemetryModel(
      totalStaff: json['total_staff'] as int? ?? 160,
      presentToday: json['present_today'] as int? ?? 142,
      absentToday: json['absent_today'] as int? ?? 14,
      unmarked: json['unmarked'] as int? ?? 4,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_staff': totalStaff,
      'present_today': presentToday,
      'absent_today': absentToday,
      'unmarked': unmarked,
    };
  }
}
