/// Represents the executive employee profile and workplace parameters
class EmployeeProfileModel {
  final String name;
  final String email;
  final String employeeId;
  final String designation;
  final String department;
  final String joiningDate;
  final String reportingManager;
  final String shiftName;
  final String shiftTime;
  final int graceMinutes;
  final String workLocation;
  final String? avatarUrl;
  final bool biometricEnabled;
  final bool remindersEnabled;
  final bool geofenceAutoCheck;
  final String tenureYears;
  final double attendanceScore;

  const EmployeeProfileModel({
    required this.name,
    required this.email,
    required this.employeeId,
    required this.designation,
    required this.department,
    required this.joiningDate,
    required this.reportingManager,
    required this.shiftName,
    required this.shiftTime,
    required this.graceMinutes,
    required this.workLocation,
    this.avatarUrl,
    this.biometricEnabled = true,
    this.remindersEnabled = true,
    this.geofenceAutoCheck = true,
    this.tenureYears = '2.8 Yrs',
    this.attendanceScore = 98.4,
  });

  /// Initials generated from employee name (e.g., 'MI' for Malik Imran)
  String get initials {
    if (name.trim().isEmpty) return 'EM';
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  factory EmployeeProfileModel.fromJson(Map<String, dynamic> json) {
    return EmployeeProfileModel(
      name: json['name'] as String? ?? 'Employee',
      email:
          json['email'] as String? ?? 'employee@Softech Business Services.com',
      employeeId: json['employee_id'] as String? ?? 'EMP-1024',
      designation: json['designation'] as String? ?? 'Staff Member',
      department: json['department'] as String? ?? 'Operations',
      joiningDate: json['joining_date'] as String? ?? '15 Jan 2024',
      reportingManager:
          json['reporting_manager'] as String? ?? 'Operations Lead',
      shiftName: json['shift_name'] as String? ?? 'General Corporate Shift',
      shiftTime: json['shift_time'] as String? ?? '09:00 AM - 06:00 PM',
      graceMinutes: json['grace_minutes'] as int? ?? 15,
      workLocation:
          json['work_location'] as String? ?? 'Softech Business Services HQ',
      avatarUrl: json['avatar_url'] as String?,
      biometricEnabled: json['biometric_enabled'] as bool? ?? true,
      remindersEnabled: json['reminders_enabled'] as bool? ?? true,
      geofenceAutoCheck: json['geofence_auto_check'] as bool? ?? true,
      tenureYears: json['tenure_years'] as String? ?? '2.8 Yrs',
      attendanceScore: (json['attendance_score'] as num?)?.toDouble() ?? 98.4,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'employee_id': employeeId,
      'designation': designation,
      'department': department,
      'joining_date': joiningDate,
      'reporting_manager': reportingManager,
      'shift_name': shiftName,
      'shift_time': shiftTime,
      'grace_minutes': graceMinutes,
      'work_location': workLocation,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      'biometric_enabled': biometricEnabled,
      'reminders_enabled': remindersEnabled,
      'geofence_auto_check': geofenceAutoCheck,
      'tenure_years': tenureYears,
      'attendance_score': attendanceScore,
    };
  }

  EmployeeProfileModel copyWith({
    String? name,
    String? email,
    String? employeeId,
    String? designation,
    String? department,
    String? joiningDate,
    String? reportingManager,
    String? shiftName,
    String? shiftTime,
    int? graceMinutes,
    String? workLocation,
    String? avatarUrl,
    bool? biometricEnabled,
    bool? remindersEnabled,
    bool? geofenceAutoCheck,
    String? tenureYears,
    double? attendanceScore,
  }) {
    return EmployeeProfileModel(
      name: name ?? this.name,
      email: email ?? this.email,
      employeeId: employeeId ?? this.employeeId,
      designation: designation ?? this.designation,
      department: department ?? this.department,
      joiningDate: joiningDate ?? this.joiningDate,
      reportingManager: reportingManager ?? this.reportingManager,
      shiftName: shiftName ?? this.shiftName,
      shiftTime: shiftTime ?? this.shiftTime,
      graceMinutes: graceMinutes ?? this.graceMinutes,
      workLocation: workLocation ?? this.workLocation,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      geofenceAutoCheck: geofenceAutoCheck ?? this.geofenceAutoCheck,
      tenureYears: tenureYears ?? this.tenureYears,
      attendanceScore: attendanceScore ?? this.attendanceScore,
    );
  }
}
