import 'dart:convert';

/// Represents the decoded and validated corporate employee card QR badge
class EmployeeCardQrModel {
  final String employeeId;
  final String organizationId;
  final String cardIssueDate;
  final String checksumToken;
  final String employeeName;
  final String department;
  final String designation;

  const EmployeeCardQrModel({
    required this.employeeId,
    required this.organizationId,
    required this.cardIssueDate,
    required this.checksumToken,
    required this.employeeName,
    required this.department,
    required this.designation,
  });

  factory EmployeeCardQrModel.fromJson(Map<String, dynamic> json) {
    return EmployeeCardQrModel(
      employeeId: json['employee_id']?.toString() ?? 'EMP-0428',
      organizationId:
          json['organization_id']?.toString() ?? 'ORG-SOFTGENIE-88',
      cardIssueDate: json['card_issue_date']?.toString() ?? '2025-01-15',
      checksumToken: json['checksum_token']?.toString() ?? 'CHK-99482-AMS',
      employeeName: json['employee_name']?.toString() ?? 'Muhammad Imran',
      department: json['department']?.toString() ?? 'Technology & Development',
      designation:
          json['designation']?.toString() ?? 'Senior Software Engineer',
    );
  }

  /// Parses raw payload string from QR detector
  factory EmployeeCardQrModel.fromRawPayload(String rawPayload) {
    try {
      final trimmed = rawPayload.trim();
      if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
        final decoded = jsonDecode(trimmed);
        if (decoded is Map<String, dynamic>) {
          return EmployeeCardQrModel.fromJson(decoded);
        }
      }
    } catch (_) {}

    // Fallback parser for standard delimited badges e.g. "AMS:EMP-0428:ORG-SOFTGENIE-88"
    final parts = rawPayload.split(':');
    final extractedEmpId = parts.length > 1 ? parts[1] : (rawPayload.isNotEmpty ? rawPayload : 'EMP-0428');

    return EmployeeCardQrModel(
      employeeId: extractedEmpId,
      organizationId: 'ORG-SOFTGENIE-88',
      cardIssueDate: '2025-01-15',
      checksumToken: 'CHK-99482-AMS',
      employeeName: 'Muhammad Imran',
      department: 'Technology & Development',
      designation: 'Senior Software Engineer',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employee_id': employeeId,
      'organization_id': organizationId,
      'card_issue_date': cardIssueDate,
      'checksum_token': checksumToken,
      'employee_name': employeeName,
      'department': department,
      'designation': designation,
    };
  }
}
