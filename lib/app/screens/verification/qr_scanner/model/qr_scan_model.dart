import 'dart:convert';

/// Represents a validated corporate employee card QR badge model
class EmployeeCardQrModel {
  final String employeeCode;
  final String organizationId;
  final String cardToken;
  final String issueDate;
  final bool isValid;
  final String employeeName;
  final String department;
  final String designation;

  // Backwards compatibility alias for biometric screen pipeline
  String get employeeId => employeeCode;

  const EmployeeCardQrModel({
    required this.employeeCode,
    required this.organizationId,
    required this.cardToken,
    required this.issueDate,
    this.isValid = true,
    this.employeeName = 'Muhammad Imran',
    this.department = 'Technology & Development',
    this.designation = 'Senior Software Engineer',
  });

  /// Factory constructor parsing JSON responses or payloads
  factory EmployeeCardQrModel.fromJson(Map<String, dynamic> json) {
    return EmployeeCardQrModel(
      employeeCode: json['employee_code']?.toString() ??
          json['employeeCode']?.toString() ??
          json['employee_id']?.toString() ??
          json['employeeId']?.toString() ??
          'SFT-094',
      organizationId: json['organization_id']?.toString() ??
          json['organizationId']?.toString() ??
          'ORG-102',
      cardToken: json['card_token']?.toString() ??
          json['cardToken']?.toString() ??
          json['checksum_token']?.toString() ??
          'SEC-TOKEN-8849',
      issueDate: json['issue_date']?.toString() ??
          json['issueDate']?.toString() ??
          json['card_issue_date']?.toString() ??
          '2025-01-15',
      isValid: json['is_valid'] == true ||
          json['isValid'] == true ||
          json['is_valid'] == null,
      employeeName: json['employee_name']?.toString() ??
          json['employeeName']?.toString() ??
          'Muhammad Imran',
      department: json['department']?.toString() ?? 'Technology & Development',
      designation:
          json['designation']?.toString() ?? 'Senior Software Engineer',
    );
  }

  /// Parses raw payload string from QR scanner (handles JSON or delimited string format)
  factory EmployeeCardQrModel.fromRawPayload(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return const EmployeeCardQrModel(
        employeeCode: '',
        organizationId: '',
        cardToken: '',
        issueDate: '',
        isValid: false,
      );
    }

    // 1. Attempt JSON parsing
    if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is Map<String, dynamic>) {
          return EmployeeCardQrModel.fromJson(decoded);
        }
      } catch (_) {
        // Fallback to delimited parsing
      }
    }

    // 2. Delimited string format parser:
    // Formats supported:
    // - "AMS:SFT-094:ORG-102:TOKEN-1234"
    // - "ORG-102:SFT-094"
    // - "SFT-094"
    final colonParts = trimmed.split(':');
    String extractedCode = 'SFT-094';
    String extractedOrg = 'ORG-102';
    String extractedToken = 'SEC-TOKEN-8849';

    if (colonParts.length >= 3) {
      // E.g. "AMS:SFT-094:ORG-102:..."
      if (colonParts[0].toUpperCase() == 'AMS') {
        extractedCode = colonParts[1];
        extractedOrg = colonParts[2];
        if (colonParts.length > 3) {
          extractedToken = colonParts[3];
        }
      } else {
        extractedOrg = colonParts[0];
        extractedCode = colonParts[1];
        extractedToken = colonParts[2];
      }
    } else if (colonParts.length == 2) {
      if (colonParts[0].startsWith('ORG')) {
        extractedOrg = colonParts[0];
        extractedCode = colonParts[1];
      } else {
        extractedCode = colonParts[0];
        extractedOrg = colonParts[1];
      }
    } else if (trimmed.isNotEmpty) {
      extractedCode = trimmed;
    }

    return EmployeeCardQrModel(
      employeeCode: extractedCode,
      organizationId: extractedOrg,
      cardToken: extractedToken,
      issueDate: '2025-01-15',
      isValid: extractedCode.isNotEmpty,
      employeeName: 'Muhammad Imran',
      department: 'Technology & Development',
      designation: 'Senior Software Engineer',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employee_code': employeeCode,
      'organization_id': organizationId,
      'card_token': cardToken,
      'issue_date': issueDate,
      'is_valid': isValid,
      'employee_name': employeeName,
      'department': department,
      'designation': designation,
    };
  }
}
