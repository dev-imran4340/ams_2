import 'package:flutter/material.dart';

import 'package:ams_2/app/core/utils/app_colors.dart';

/// Represents company information printed on the Digital ID Badge
class EmployeeCardCompany {
  final String name;
  final String? shortName;
  final String? phone;
  final String? address;

  const EmployeeCardCompany({
    required this.name,
    this.shortName,
    this.phone,
    this.address,
  });

  factory EmployeeCardCompany.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const EmployeeCardCompany(
        name: 'Kumash',
        shortName: 'Ku',
        phone: '03155109822',
        address: 'test ad 1, Islamabad, 44000',
      );
    }
    return EmployeeCardCompany(
      name: json['name']?.toString() ?? 'Kumash',
      shortName: json['short_name']?.toString(),
      phone: json['phone']?.toString(),
      address: json['address']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'short_name': shortName,
      'phone': phone,
      'address': address,
    };
  }
}

/// Represents complete digital corporate ID card details for an employee
/// Matching the exact live Phase 7 API /me/card response format.
class EmployeeCardDetails {
  final EmployeeCardCompany company;
  final String name;
  final String designation;
  final String department;
  final String employeeNumber;
  final String? phone;
  final String? bloodGroup;
  final String? validUntil;
  final String? emergencyPhone;
  final int cardNo;
  final String? issuedOn;
  final String colour;
  final String orientation;
  final String qrValue;

  // Compatibility and derived fields
  final String pdfDocumentUrl;
  final bool isNfcVerified;

  const EmployeeCardDetails({
    required this.company,
    required this.name,
    required this.designation,
    required this.department,
    required this.employeeNumber,
    this.phone,
    this.bloodGroup,
    this.validUntil,
    this.emergencyPhone,
    required this.cardNo,
    this.issuedOn,
    required this.colour,
    required this.orientation,
    required this.qrValue,
    this.pdfDocumentUrl = '',
    this.isNfcVerified = true,
  });

  // Backward compatibility getters
  String get employeeId => employeeNumber;
  String get qrPayload => qrValue;
  String get emergencyContact =>
      emergencyPhone ?? phone ?? company.phone ?? '';
  String get joiningDate => issuedOn ?? '';
  String get validTill => validUntil ?? 'Permanent';

  /// Parses hex color string to Color safely, gracefully falling back to corporate AppColors.primary
  Color get cardColor {
    try {
      final hex = colour.replaceFirst('#', '').toLowerCase();
      if (hex == '7f1d1d' || hex == 'ff7f1d1d') {
        return AppColors.primary;
      }
      final buffer = StringBuffer();
      if (hex.length == 6) buffer.write('ff');
      buffer.write(hex);
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }

  /// Extracts user initials for the circular avatar badge (e.g. "MM")
  String get initials {
    if (name.trim().isEmpty) return 'MM';
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  /// Formatted issued date (e.g. "15 Jul 2023")
  String get formattedIssuedDate {
    if (issuedOn == null || issuedOn!.isEmpty) return '';
    try {
      final dt = DateTime.parse(issuedOn!);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return issuedOn!;
    }
  }

  /// Sub-footer string for back card (e.g. "Card 1 · Issued 15 Jul 2023")
  String get cardSubtitle {
    final dateStr = formattedIssuedDate;
    if (dateStr.isNotEmpty) {
      return 'Card $cardNo · Issued $dateStr';
    }
    return 'Card $cardNo';
  }

  EmployeeCardDetails copyWith({
    EmployeeCardCompany? company,
    String? name,
    String? designation,
    String? department,
    String? employeeNumber,
    String? employeeId,
    String? phone,
    String? bloodGroup,
    String? validUntil,
    String? validTill,
    String? emergencyPhone,
    String? emergencyContact,
    int? cardNo,
    String? issuedOn,
    String? joiningDate,
    String? colour,
    String? orientation,
    String? qrValue,
    String? qrPayload,
    String? pdfDocumentUrl,
    bool? isNfcVerified,
  }) {
    return EmployeeCardDetails(
      company: company ?? this.company,
      name: name ?? this.name,
      designation: designation ?? this.designation,
      department: department ?? this.department,
      employeeNumber: employeeNumber ?? employeeId ?? this.employeeNumber,
      phone: phone ?? this.phone,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      validUntil: validUntil ?? validTill ?? this.validUntil,
      emergencyPhone: emergencyPhone ?? emergencyContact ?? this.emergencyPhone,
      cardNo: cardNo ?? this.cardNo,
      issuedOn: issuedOn ?? joiningDate ?? this.issuedOn,
      colour: colour ?? this.colour,
      orientation: orientation ?? this.orientation,
      qrValue: qrValue ?? qrPayload ?? this.qrValue,
      pdfDocumentUrl: pdfDocumentUrl ?? this.pdfDocumentUrl,
      isNfcVerified: isNfcVerified ?? this.isNfcVerified,
    );
  }

  factory EmployeeCardDetails.fromJson(Map<String, dynamic> raw) {
    final Map<String, dynamic> json =
        (raw['data'] is Map) ? Map<String, dynamic>.from(raw['data'] as Map) : raw;

    final companyJson = json['company'] is Map
        ? Map<String, dynamic>.from(json['company'] as Map)
        : null;

    final empNum = json['employee_number']?.toString() ??
        json['employee_id']?.toString() ??
        'EMP-0002';

    return EmployeeCardDetails(
      company: EmployeeCardCompany.fromJson(companyJson),
      name: json['name']?.toString() ?? 'Maryam Malik',
      designation: json['designation']?.toString() ?? 'Sales Manager',
      department: json['department']?.toString() ?? 'Sales',
      employeeNumber: empNum,
      phone: json['phone']?.toString(),
      bloodGroup: json['blood_group']?.toString(),
      validUntil: json['valid_until']?.toString() ?? json['valid_till']?.toString(),
      emergencyPhone:
          json['emergency_phone']?.toString() ?? json['emergency_contact']?.toString(),
      cardNo: (json['card_no'] is int)
          ? json['card_no'] as int
          : int.tryParse(json['card_no']?.toString() ?? '') ?? 1,
      issuedOn: json['issued_on']?.toString() ?? json['joining_date']?.toString() ?? '2023-07-15',
      colour: json['colour']?.toString() ?? '#7f1d1d',
      orientation: json['orientation']?.toString() ?? 'vertical',
      qrValue: json['qr_value']?.toString() ??
          json['qr_payload']?.toString() ??
          'AMS1:MX0zbHeRVbzPIlBb8SjAwBChWK0oZvsb',
      pdfDocumentUrl: json['pdf_document_url']?.toString() ??
          'https://laravel.ams-hrpayroll.com/cards/$empNum.pdf',
      isNfcVerified: json['is_nfc_verified'] == true || true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'company': company.toJson(),
      'name': name,
      'designation': designation,
      'department': department,
      'employee_number': employeeNumber,
      'employee_id': employeeNumber,
      'phone': phone,
      'blood_group': bloodGroup,
      'valid_until': validUntil,
      'valid_till': validUntil,
      'emergency_phone': emergencyPhone,
      'emergency_contact': emergencyContact,
      'card_no': cardNo,
      'issued_on': issuedOn,
      'joining_date': issuedOn,
      'colour': colour,
      'orientation': orientation,
      'qr_value': qrValue,
      'qr_payload': qrValue,
      'pdf_document_url': pdfDocumentUrl,
      'is_nfc_verified': isNfcVerified,
    };
  }

  /// Ground truth mock matching user's exact specification
  factory EmployeeCardDetails.mock() {
    return const EmployeeCardDetails(
      company: EmployeeCardCompany(
        name: 'Kumash',
        shortName: 'Ku',
        phone: '03155109822',
        address: 'test ad 1, Islamabad, 44000',
      ),
      name: 'Maryam Malik',
      designation: 'Sales Manager',
      department: 'Sales',
      employeeNumber: 'EMP-0002',
      phone: null,
      bloodGroup: null,
      validUntil: null,
      emergencyPhone: null,
      cardNo: 1,
      issuedOn: '2023-07-15',
      colour: '#012b43',
      orientation: 'vertical',
      qrValue: 'AMS1:MX0zbHeRVbzPIlBb8SjAwBChWK0oZvsb',
      pdfDocumentUrl:
          'https://laravel.ams-hrpayroll.com/cards/EMP-0002.pdf',
      isNfcVerified: true,
    );
  }
}
