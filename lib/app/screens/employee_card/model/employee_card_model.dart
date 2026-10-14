/// Represents complete digital corporate ID card details for an employee
class EmployeeCardDetails {
  final String name;
  final String employeeId;
  final String designation;
  final String department;
  final String bloodGroup;
  final String emergencyContact;
  final String joiningDate;
  final String validTill;
  final String qrPayload;
  final String pdfDocumentUrl;
  final bool isNfcVerified;

  const EmployeeCardDetails({
    required this.name,
    required this.employeeId,
    required this.designation,
    required this.department,
    required this.bloodGroup,
    required this.emergencyContact,
    required this.joiningDate,
    required this.validTill,
    required this.qrPayload,
    required this.pdfDocumentUrl,
    required this.isNfcVerified,
  });

  EmployeeCardDetails copyWith({
    String? name,
    String? employeeId,
    String? designation,
    String? department,
    String? bloodGroup,
    String? emergencyContact,
    String? joiningDate,
    String? validTill,
    String? qrPayload,
    String? pdfDocumentUrl,
    bool? isNfcVerified,
  }) {
    return EmployeeCardDetails(
      name: name ?? this.name,
      employeeId: employeeId ?? this.employeeId,
      designation: designation ?? this.designation,
      department: department ?? this.department,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      joiningDate: joiningDate ?? this.joiningDate,
      validTill: validTill ?? this.validTill,
      qrPayload: qrPayload ?? this.qrPayload,
      pdfDocumentUrl: pdfDocumentUrl ?? this.pdfDocumentUrl,
      isNfcVerified: isNfcVerified ?? this.isNfcVerified,
    );
  }

  factory EmployeeCardDetails.fromJson(Map<String, dynamic> json) {
    return EmployeeCardDetails(
      name: json['name']?.toString() ?? 'Muhammad Imran',
      employeeId: json['employee_id']?.toString() ?? 'SFT-1024',
      designation: json['designation']?.toString() ?? 'Senior Flutter Engineer',
      department: json['department']?.toString() ?? 'Mobile & AI Solutions',
      bloodGroup: json['blood_group']?.toString() ?? 'O+',
      emergencyContact: json['emergency_contact']?.toString() ?? '+92 300 1234567',
      joiningDate: json['joining_date']?.toString() ?? '15 Jan 2024',
      validTill: json['valid_till']?.toString() ?? '31 Dec 2027',
      qrPayload: json['qr_payload']?.toString() ?? 'AMS2::SFT-1024::ORG-HQ::SECURE_TOKEN',
      pdfDocumentUrl: json['pdf_document_url']?.toString() ??
          'https://mock.softgenie.com/cards/SFT-1024.pdf',
      isNfcVerified: json['is_nfc_verified'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'employee_id': employeeId,
      'designation': designation,
      'department': department,
      'blood_group': bloodGroup,
      'emergency_contact': emergencyContact,
      'joining_date': joiningDate,
      'valid_till': validTill,
      'qr_payload': qrPayload,
      'pdf_document_url': pdfDocumentUrl,
      'is_nfc_verified': isNfcVerified,
    };
  }
}
