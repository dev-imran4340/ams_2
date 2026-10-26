/// Represents an employee record from GET /employees
/// Conforms with doc/api.md and supports permission-gated sensitive attributes.
class DepartmentEmployeeModel {
  final String id;
  final String employeeCode;
  final String name;
  final String designation;
  final String department;
  final String? workLocation;
  final String email;
  final String status;
  final String joiningDate;

  // Sensitive fields - strictly gated by 'employees.sensitive.view' permission
  final String? personalPhone;
  final String? residentialAddress;
  final String? emergencyContact;
  final String? passportOrCnicExpiry;

  const DepartmentEmployeeModel({
    required this.id,
    required this.employeeCode,
    required this.name,
    required this.designation,
    required this.department,
    this.workLocation,
    required this.email,
    required this.status,
    required this.joiningDate,
    this.personalPhone,
    this.residentialAddress,
    this.emergencyContact,
    this.passportOrCnicExpiry,
  });

  String get employeeNumber => employeeCode;

  /// Formatted status label for UI chips
  String get statusLabel {
    if (status.isEmpty) return 'Active';
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }

  bool get isActive =>
      status.toLowerCase() == 'active' || status.toLowerCase() == 'joining';

  factory DepartmentEmployeeModel.fromJson(Map<String, dynamic> json) {
    final empCode = json['employee_number']?.toString() ??
        json['employee_code']?.toString() ??
        '';

    final resolvedStatus = json['stage']?.toString() ??
        json['status']?.toString() ??
        'Active';

    return DepartmentEmployeeModel(
      id: json['id']?.toString() ?? '',
      employeeCode: empCode,
      name: json['name']?.toString() ?? '',
      designation: json['designation']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
      workLocation: json['work_location']?.toString(),
      email: json['email']?.toString() ?? '',
      status: resolvedStatus,
      joiningDate: json['joining_date']?.toString() ?? '',
      personalPhone: json['personal_phone']?.toString(),
      residentialAddress: json['residential_address']?.toString(),
      emergencyContact: json['emergency_contact']?.toString(),
      passportOrCnicExpiry: json['passport_expiry']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_number': employeeCode,
      'employee_code': employeeCode,
      'name': name,
      'designation': designation,
      'department': department,
      'work_location': workLocation,
      'email': email,
      'stage': status,
      'status': status,
      'joining_date': joiningDate,
      'personal_phone': personalPhone,
      'residential_address': residentialAddress,
      'emergency_contact': emergencyContact,
      'passport_expiry': passportOrCnicExpiry,
    };
  }
}
