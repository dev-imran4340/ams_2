/// Represents a registered visitor record in the Organization Kiosk terminal
class VisitorModel {
  final String id;
  final String fullName;
  final String cnic;
  final String phone;
  final String purpose;
  final String hostEmployee;
  final String? photoPath;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final bool isActive;

  const VisitorModel({
    required this.id,
    required this.fullName,
    required this.cnic,
    required this.phone,
    required this.purpose,
    required this.hostEmployee,
    this.photoPath,
    required this.checkInTime,
    this.checkOutTime,
    this.isActive = true,
  });

  String? get visitorName => fullName;
  DateTime? get startTime => checkInTime;
  String? get visitorImage => photoPath;
  String? get visitorId => id;


  /// Human-friendly elapsed time string e.g. "Checked in 1 hr 25 mins ago"
  String get elapsedTimeString {
    final now = DateTime.now();
    final difference = now.difference(checkInTime);

    if (difference.inMinutes < 1) {
      return 'Just checked in';
    } else if (difference.inMinutes < 60) {
      return 'Checked in ${difference.inMinutes} mins ago';
    } else {
      final hours = difference.inHours;
      final remainingMins = difference.inMinutes % 60;
      if (remainingMins == 0) {
        return 'Checked in $hours ${hours == 1 ? 'hr' : 'hrs'} ago';
      }
      return 'Checked in $hours ${hours == 1 ? 'hr' : 'hrs'} $remainingMins mins ago';
    }
  }

  /// Formatted check-in time e.g. "10:45 AM"
  String get formattedCheckInTime {
    final hour = checkInTime.hour;
    final minute = checkInTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final formattedHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$formattedHour:$minute $period';
  }

  /// Formatted check-in date string e.g. "15 Oct 2026"
  String get formattedCheckInDate {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${checkInTime.day.toString().padLeft(2, '0')} ${months[checkInTime.month - 1]} ${checkInTime.year}';
  }

  VisitorModel copyWith({
    String? id,
    String? fullName,
    String? cnic,
    String? phone,
    String? purpose,
    String? hostEmployee,
    String? photoPath,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    bool? isActive,
  }) {
    return VisitorModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      cnic: cnic ?? this.cnic,
      phone: phone ?? this.phone,
      purpose: purpose ?? this.purpose,
      hostEmployee: hostEmployee ?? this.hostEmployee,
      photoPath: photoPath ?? this.photoPath,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      isActive: isActive ?? this.isActive,
    );
  }

  factory VisitorModel.fromJson(Map<String, dynamic> json) {
    return VisitorModel(
      id: json['id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      cnic: json['cnic']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      purpose: json['purpose']?.toString() ?? 'Meeting',
      hostEmployee: json['host_employee']?.toString() ?? '',
      photoPath: json['photo_path']?.toString(),
      checkInTime: json['check_in_time'] != null
          ? DateTime.tryParse(json['check_in_time'].toString()) ??
              DateTime.now()
          : DateTime.now(),
      checkOutTime: json['check_out_time'] != null
          ? DateTime.tryParse(json['check_out_time'].toString())
          : null,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'cnic': cnic,
      'phone': phone,
      'purpose': purpose,
      'host_employee': hostEmployee,
      'photo_path': photoPath,
      'check_in_time': checkInTime.toIso8601String(),
      'check_out_time': checkOutTime?.toIso8601String(),
      'is_active': isActive,
    };
  }
}

/// Host Employee option for visitor check-in dropdown
class HostEmployeeOption {
  final String id;
  final String name;
  final String department;

  const HostEmployeeOption({
    required this.id,
    required this.name,
    required this.department,
  });

  String get displayName => '$name • $department';

  @override
  String toString() => displayName;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HostEmployeeOption &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  factory HostEmployeeOption.fromJson(Map<String, dynamic> json) {
    return HostEmployeeOption(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'department': department,
    };
  }
}
