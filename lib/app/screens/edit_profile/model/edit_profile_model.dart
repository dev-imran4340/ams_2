/// Request payload for updating employee contact & personal details
/// API Contract: POST /me/details-change with kind: "details"
class PersonalDetailsChangeRequest {
  final String? preferredName;
  final String? personalPhone;
  final String? personalEmail;
  final String? maritalStatus;
  final String? addressLine1;
  final String? addressLine2;
  final String? cityName;
  final String? postcode;
  final String? countryCode;

  /// Tracks which fields were actually touched/changed by the user
  final Set<String> changedFields;

  const PersonalDetailsChangeRequest({
    this.preferredName,
    this.personalPhone,
    this.personalEmail,
    this.maritalStatus,
    this.addressLine1,
    this.addressLine2,
    this.cityName,
    this.postcode,
    this.countryCode,
    this.changedFields = const {},
  });

  bool get hasChanges => changedFields.isNotEmpty;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> payload = {
      'kind': 'details',
    };

    if (changedFields.contains('preferred_name')) {
      payload['preferred_name'] = preferredName?.trim();
    }
    if (changedFields.contains('personal_phone')) {
      payload['personal_phone'] = personalPhone?.trim();
    }
    if (changedFields.contains('personal_email')) {
      payload['personal_email'] = personalEmail?.trim();
    }
    if (changedFields.contains('marital_status')) {
      payload['marital_status'] = maritalStatus?.trim();
    }
    if (changedFields.contains('address_line1')) {
      payload['address_line1'] = addressLine1?.trim();
    }
    if (changedFields.contains('address_line2')) {
      payload['address_line2'] = addressLine2?.trim();
    }
    if (changedFields.contains('city_name')) {
      payload['city_name'] = cityName?.trim();
    }
    if (changedFields.contains('postcode')) {
      payload['postcode'] = postcode?.trim();
    }
    if (changedFields.contains('country_code')) {
      payload['country_code'] = countryCode?.trim();
    }

    return payload;
  }
}

/// Request payload for adding or updating an emergency contact
/// API Contract: POST /me/details-change with kind: "emergency_contact"
class EmergencyContactChangeRequest {
  /// ULID of existing contact if updating, null if creating new
  final String? contactId;
  final String name;
  final String relationship;
  final String phone;
  final String? alternativePhone;
  final String? address;
  final bool isPrimary;

  const EmergencyContactChangeRequest({
    this.contactId,
    required this.name,
    required this.relationship,
    required this.phone,
    this.alternativePhone,
    this.address,
    this.isPrimary = true,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> payload = {
      'kind': 'emergency_contact',
      if (contactId != null && contactId!.trim().isNotEmpty)
        'contact': contactId!.trim(),
      'name': name.trim(),
      'relationship': relationship.trim(),
      'phone': phone.trim(),
      'alternative_phone': alternativePhone?.trim().isNotEmpty == true
          ? alternativePhone!.trim()
          : null,
      'address': address?.trim().isNotEmpty == true ? address!.trim() : null,
      'is_primary': isPrimary,
    };
    return payload;
  }
}

/// Response returned from POST /me/details-change (HTTP 201 Created)
/// Shares the same response shape as GET /approvals/{id}
class DetailsChangeResponse {
  final String id;
  final String type;
  final String typeLabel;
  final String title;
  final String status; // 'pending' or 'approved'
  final String statusLabel;
  final String statusTone;

  const DetailsChangeResponse({
    required this.id,
    required this.type,
    required this.typeLabel,
    required this.title,
    required this.status,
    required this.statusLabel,
    required this.statusTone,
  });

  factory DetailsChangeResponse.fromJson(Map<String, dynamic> json) {
    return DetailsChangeResponse(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'employee_details_change',
      typeLabel: json['type_label']?.toString() ?? 'Change of my details',
      title: json['title']?.toString() ?? 'Change of my details',
      status: json['status']?.toString() ?? 'pending',
      statusLabel: json['status_label']?.toString() ?? 'Waiting for approval',
      statusTone: json['status_tone']?.toString() ?? 'amber',
    );
  }

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isApproved => status.toLowerCase() == 'approved';

  /// Standard user-facing message conforming to API docs
  String get userMessage => isApproved
      ? 'Saved. Your changes have been applied immediately.'
      : 'Sent for approval. Your request is waiting for company decision.';
}
