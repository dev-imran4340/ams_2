/// Represents a department employee record with permission-gated sensitive attributes
class DepartmentEmployeeModel {
  final String id;
  final String employeeCode;
  final String name;
  final String designation;
  final String department;
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
    required this.email,
    required this.status,
    required this.joiningDate,
    this.personalPhone,
    this.residentialAddress,
    this.emergencyContact,
    this.passportOrCnicExpiry,
  });

  factory DepartmentEmployeeModel.fromJson(Map<String, dynamic> json) {
    return DepartmentEmployeeModel(
      id: json['id']?.toString() ?? '',
      employeeCode: json['employee_code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      designation: json['designation']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Active',
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
      'employee_code': employeeCode,
      'name': name,
      'designation': designation,
      'department': department,
      'email': email,
      'status': status,
      'joining_date': joiningDate,
      'personal_phone': personalPhone,
      'residential_address': residentialAddress,
      'emergency_contact': emergencyContact,
      'passport_expiry': passportOrCnicExpiry,
    };
  }
}
