import '../../profile/model/profile_model.dart';

/// Request model representing the editable fields of the employee profile
class EditProfileRequestModel {
  final String name;
  final String email;
  final String phone;
  final String cnic;
  final String dob;
  final String gender;
  final String bloodGroup;
  final String address;
  final String city;
  final String postalCode;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final String emergencyContactRelation;
  final String? avatarPath;

  const EditProfileRequestModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.cnic,
    required this.dob,
    required this.gender,
    required this.bloodGroup,
    required this.address,
    required this.city,
    required this.postalCode,
    required this.emergencyContactName,
    required this.emergencyContactPhone,
    required this.emergencyContactRelation,
    this.avatarPath,
  });

  /// Applies editable updates to an existing [EmployeeProfileModel]
  EmployeeProfileModel applyTo(EmployeeProfileModel existing) {
    return existing.copyWith(
      name: name,
      email: email,
      phone: phone,
      cnic: cnic,
      dob: dob,
      gender: gender,
      bloodGroup: bloodGroup,
      address: address,
      city: city,
      postalCode: postalCode,
      emergencyContactName: emergencyContactName,
      emergencyContactPhone: emergencyContactPhone,
      emergencyContactRelation: emergencyContactRelation,
      avatarPath: avatarPath ?? existing.avatarPath,
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
      'address': address,
      'city': city,
      'postal_code': postalCode,
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_phone': emergencyContactPhone,
      'emergency_contact_relation': emergencyContactRelation,
      if (avatarPath != null) 'avatar_path': avatarPath,
    };
  }
}
