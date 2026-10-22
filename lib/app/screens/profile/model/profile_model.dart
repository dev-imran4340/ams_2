/// Represents the executive employee profile and workplace parameters
class EmployeeProfileModel {
  final String name;
  final String email;
  final String phone;
  final String cnic;
  final String dob;
  final String gender;
  final String bloodGroup;
  final String employeeId;
  final String designation;
  final String department;
  final String joiningDate;
  final String reportingManager;
  final String shiftName;
  final String shiftTime;
  final int graceMinutes;
  final String workLocation;
  final String address;
  final String city;
  final String postalCode;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final String emergencyContactRelation;
  final String? avatarUrl;
  final String? avatarPath;
  final bool biometricEnabled;
  final bool remindersEnabled;
  final bool geofenceAutoCheck;
  final String tenureYears;
  final double attendanceScore;

  const EmployeeProfileModel({
    required this.name,
    required this.email,
    this.phone = '+92 300 1234567',
    this.cnic = '37405-1234567-1',
    this.dob = '14 May 1996',
    this.gender = 'Male',
    this.bloodGroup = 'O+',
    required this.employeeId,
    required this.designation,
    required this.department,
    required this.joiningDate,
    required this.reportingManager,
    required this.shiftName,
    required this.shiftTime,
    required this.graceMinutes,
    required this.workLocation,
    this.address = 'House #42, Street 8, Sector G-11/1',
    this.city = 'Islamabad',
    this.postalCode = '44000',
    this.emergencyContactName = 'Tariq Mehmood',
    this.emergencyContactPhone = '+92 321 7654321',
    this.emergencyContactRelation = 'Brother',
    this.avatarUrl,
    this.avatarPath,
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
      name: json['name'] as String? ?? 'Malik Muhammad Imran',
      email:
          json['email'] as String? ?? 'imran@Softech Business Services.com',
      phone: json['phone'] as String? ?? '+92 300 1234567',
      cnic: json['cnic'] as String? ?? '37405-1234567-1',
      dob: json['dob'] as String? ?? '14 May 1996',
      gender: json['gender'] as String? ?? 'Male',
      bloodGroup: json['blood_group'] as String? ?? 'O+',
      employeeId: json['employee_id'] as String? ?? 'EMP-1024',
      designation:
          json['designation'] as String? ?? 'Senior Software Engineer & Tech Lead',
      department:
          json['department'] as String? ?? 'Engineering & Mobility',
      joiningDate: json['joining_date'] as String? ?? '15 Jan 2024',
      reportingManager:
          json['reporting_manager'] as String? ?? 'Hamza Sheikh (Lead Architect)',
      shiftName:
          json['shift_name'] as String? ?? 'General Corporate Shift',
      shiftTime:
          json['shift_time'] as String? ?? '09:00 AM - 06:00 PM',
      graceMinutes: json['grace_minutes'] as int? ?? 15,
      workLocation:
          json['work_location'] as String? ?? 'Softech Business Services HQ • 4th Floor',
      address:
          json['address'] as String? ?? 'House #42, Street 8, Sector G-11/1',
      city: json['city'] as String? ?? 'Islamabad',
      postalCode: json['postal_code'] as String? ?? '44000',
      emergencyContactName:
          json['emergency_contact_name'] as String? ?? 'Tariq Mehmood',
      emergencyContactPhone:
          json['emergency_contact_phone'] as String? ?? '+92 321 7654321',
      emergencyContactRelation:
          json['emergency_contact_relation'] as String? ?? 'Brother',
      avatarUrl: json['avatar_url'] as String?,
      avatarPath: json['avatar_path'] as String?,
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
      'phone': phone,
      'cnic': cnic,
      'dob': dob,
      'gender': gender,
      'blood_group': bloodGroup,
      'employee_id': employeeId,
      'designation': designation,
      'department': department,
      'joining_date': joiningDate,
      'reporting_manager': reportingManager,
      'shift_name': shiftName,
      'shift_time': shiftTime,
      'grace_minutes': graceMinutes,
      'work_location': workLocation,
      'address': address,
      'city': city,
      'postal_code': postalCode,
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_phone': emergencyContactPhone,
      'emergency_contact_relation': emergencyContactRelation,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (avatarPath != null) 'avatar_path': avatarPath,
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
    String? phone,
    String? cnic,
    String? dob,
    String? gender,
    String? bloodGroup,
    String? employeeId,
    String? designation,
    String? department,
    String? joiningDate,
    String? reportingManager,
    String? shiftName,
    String? shiftTime,
    int? graceMinutes,
    String? workLocation,
    String? address,
    String? city,
    String? postalCode,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? emergencyContactRelation,
    String? avatarUrl,
    String? avatarPath,
    bool? biometricEnabled,
    bool? remindersEnabled,
    bool? geofenceAutoCheck,
    String? tenureYears,
    double? attendanceScore,
  }) {
    return EmployeeProfileModel(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      cnic: cnic ?? this.cnic,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      employeeId: employeeId ?? this.employeeId,
      designation: designation ?? this.designation,
      department: department ?? this.department,
      joiningDate: joiningDate ?? this.joiningDate,
      reportingManager: reportingManager ?? this.reportingManager,
      shiftName: shiftName ?? this.shiftName,
      shiftTime: shiftTime ?? this.shiftTime,
      graceMinutes: graceMinutes ?? this.graceMinutes,
      workLocation: workLocation ?? this.workLocation,
      address: address ?? this.address,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone:
          emergencyContactPhone ?? this.emergencyContactPhone,
      emergencyContactRelation:
          emergencyContactRelation ?? this.emergencyContactRelation,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      avatarPath: avatarPath ?? this.avatarPath,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      geofenceAutoCheck: geofenceAutoCheck ?? this.geofenceAutoCheck,
      tenureYears: tenureYears ?? this.tenureYears,
      attendanceScore: attendanceScore ?? this.attendanceScore,
    );
  }
}
