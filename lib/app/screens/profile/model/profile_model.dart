/// Models for the AMS 2 Mobile Profile API (/me/profile)
/// Conforms strictly with doc/api.md and doc/backend_api_specifications.md
library;

class ProfileSectionModel {
  final String key;
  final String label;

  const ProfileSectionModel({
    required this.key,
    required this.label,
  });

  factory ProfileSectionModel.fromJson(Map<String, dynamic> json) {
    return ProfileSectionModel(
      key: json['key']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'key': key,
    'label': label,
  };
}

class ProfileJobModel {
  final String? legalEntity;
  final String? workLocation;
  final String? department;
  final String? subDepartment;
  final String? designation;
  final String? grade;
  final String? employmentType;
  final String? contractType;
  final String? contractEndsOn;
  final String? joinedOn;
  final String? probationEndsOn;
  final String? confirmedOn;
  final String? lastWorkingDay;
  final String? leftOn;
  final String? lengthOfService;

  const ProfileJobModel({
    this.legalEntity,
    this.workLocation,
    this.department,
    this.subDepartment,
    this.designation,
    this.grade,
    this.employmentType,
    this.contractType,
    this.contractEndsOn,
    this.joinedOn,
    this.probationEndsOn,
    this.confirmedOn,
    this.lastWorkingDay,
    this.leftOn,
    this.lengthOfService,
  });

  factory ProfileJobModel.fromJson(Map<String, dynamic> json) {
    return ProfileJobModel(
      legalEntity: json['legal_entity']?.toString(),
      workLocation: json['work_location']?.toString(),
      department: json['department']?.toString(),
      subDepartment: json['sub_department']?.toString(),
      designation: json['designation']?.toString(),
      grade: json['grade']?.toString(),
      employmentType: json['employment_type']?.toString(),
      contractType: json['contract_type']?.toString(),
      contractEndsOn: json['contract_ends_on']?.toString(),
      joinedOn: json['joined_on']?.toString(),
      probationEndsOn: json['probation_ends_on']?.toString(),
      confirmedOn: json['confirmed_on']?.toString(),
      lastWorkingDay: json['last_working_day']?.toString(),
      leftOn: json['left_on']?.toString(),
      lengthOfService: json['length_of_service']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'legal_entity': legalEntity,
    'work_location': workLocation,
    'department': department,
    'sub_department': subDepartment,
    'designation': designation,
    'grade': grade,
    'employment_type': employmentType,
    'contract_type': contractType,
    'contract_ends_on': contractEndsOn,
    'joined_on': joinedOn,
    'probation_ends_on': probationEndsOn,
    'confirmed_on': confirmedOn,
    'last_working_day': lastWorkingDay,
    'left_on': leftOn,
    'length_of_service': lengthOfService,
  };
}

class ProfileContactModel {
  final String? workEmail;
  final String? workPhone;

  const ProfileContactModel({
    this.workEmail,
    this.workPhone,
  });

  factory ProfileContactModel.fromJson(Map<String, dynamic> json) {
    return ProfileContactModel(
      workEmail: json['work_email']?.toString(),
      workPhone: json['work_phone']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'work_email': workEmail,
    'work_phone': workPhone,
  };
}

class ProfileAddressModel {
  final String? line1;
  final String? line2;
  final String? city;
  final String? postcode;
  final String? country;

  const ProfileAddressModel({
    this.line1,
    this.line2,
    this.city,
    this.postcode,
    this.country,
  });

  factory ProfileAddressModel.fromJson(Map<String, dynamic> json) {
    return ProfileAddressModel(
      line1: json['line1']?.toString(),
      line2: json['line2']?.toString(),
      city: json['city']?.toString(),
      postcode: json['postcode']?.toString(),
      country: json['country']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'line1': line1,
    'line2': line2,
    'city': city,
    'postcode': postcode,
    'country': country,
  };

  String? get formattedAddress {
    final parts = [line1, line2, city, postcode, country]
        .where((p) => p != null && p.trim().isNotEmpty)
        .toList();
    return parts.isEmpty ? null : parts.join(', ');
  }
}

class ProfilePersonalModel {
  final String? gender;
  final String? dateOfBirth;
  final String? bloodGroup;
  final String? maritalStatus;
  final String? nationality;
  final String? personalEmail;
  final String? personalPhone;
  final ProfileAddressModel? address;

  const ProfilePersonalModel({
    this.gender,
    this.dateOfBirth,
    this.bloodGroup,
    this.maritalStatus,
    this.nationality,
    this.personalEmail,
    this.personalPhone,
    this.address,
  });

  factory ProfilePersonalModel.fromJson(Map<String, dynamic> json) {
    return ProfilePersonalModel(
      gender: json['gender']?.toString(),
      dateOfBirth: json['date_of_birth']?.toString(),
      bloodGroup: json['blood_group']?.toString(),
      maritalStatus: json['marital_status']?.toString(),
      nationality: json['nationality']?.toString(),
      personalEmail: json['personal_email']?.toString(),
      personalPhone: json['personal_phone']?.toString(),
      address: json['address'] is Map<String, dynamic>
          ? ProfileAddressModel.fromJson(json['address'] as Map<String, dynamic>)
          : (json['address'] is Map
              ? ProfileAddressModel.fromJson(
                  Map<String, dynamic>.from(json['address']))
              : null),
    );
  }

  Map<String, dynamic> toJson() => {
    'gender': gender,
    'date_of_birth': dateOfBirth,
    'blood_group': bloodGroup,
    'marital_status': maritalStatus,
    'nationality': nationality,
    'personal_email': personalEmail,
    'personal_phone': personalPhone,
    if (address != null) 'address': address!.toJson(),
  };
}

class ProfileEmergencyContactModel {
  final String? id;
  final String? name;
  final String? relationship;
  final String? phone;
  final String? alternativePhone;
  final bool isPrimary;

  const ProfileEmergencyContactModel({
    this.id,
    this.name,
    this.relationship,
    this.phone,
    this.alternativePhone,
    this.isPrimary = false,
  });

  factory ProfileEmergencyContactModel.fromJson(Map<String, dynamic> json) {
    return ProfileEmergencyContactModel(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      relationship: json['relationship']?.toString(),
      phone: json['phone']?.toString(),
      alternativePhone: json['alternative_phone']?.toString(),
      isPrimary: json['is_primary'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'relationship': relationship,
    'phone': phone,
    'alternative_phone': alternativePhone,
    'is_primary': isPrimary,
  };
}

class ProfileDocumentModel {
  final String? id;
  final String? kind;
  final String? expiresOn;
  final int? daysLeft;

  const ProfileDocumentModel({
    this.id,
    this.kind,
    this.expiresOn,
    this.daysLeft,
  });

  factory ProfileDocumentModel.fromJson(Map<String, dynamic> json) {
    return ProfileDocumentModel(
      id: json['id']?.toString(),
      kind: json['kind']?.toString(),
      expiresOn: json['expires_on']?.toString(),
      daysLeft: (json['days_left'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'kind': kind,
    'expires_on': expiresOn,
    'days_left': daysLeft,
  };
}

/// Represents the executive employee profile returned from GET /api/v1/me/profile
class EmployeeProfileModel {
  final String id;
  final String employeeNumber;
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
  final String? reportingManager;
  final String? shiftName;
  final String? shiftTime;
  final int? graceMinutes;
  final String workLocation;
  final String stage;
  final String firstName;
  final String lastName;
  final String? preferredName;
  final bool hasPhoto;
  final String stageLabel;
  final List<ProfileSectionModel> sections;
  final ProfileJobModel? job;
  final ProfileContactModel? contact;
  final ProfilePersonalModel? personal;
  final List<ProfileEmergencyContactModel> emergencyContacts;
  final List<ProfileDocumentModel> documents;
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
  final double? attendanceScore;

  const EmployeeProfileModel({
    this.id = '',
    this.employeeNumber = '',
    this.name = '',
    this.email = '',
    this.phone = '',
    this.cnic = '',
    this.dob = '',
    this.gender = '',
    this.bloodGroup = '',
    this.employeeId = '',
    this.designation = '',
    this.department = '',
    this.joiningDate = '',
    this.reportingManager,
    this.shiftName,
    this.shiftTime,
    this.graceMinutes,
    this.workLocation = '',
    this.stage = '',
    this.firstName = '',
    this.lastName = '',
    this.preferredName,
    this.hasPhoto = false,
    this.stageLabel = '',
    this.sections = const [],
    this.job,
    this.contact,
    this.personal,
    this.emergencyContacts = const [],
    this.documents = const [],
    this.address = '',
    this.city = '',
    this.postalCode = '',
    this.emergencyContactName = '',
    this.emergencyContactPhone = '',
    this.emergencyContactRelation = '',
    this.avatarUrl,
    this.avatarPath,
    this.biometricEnabled = true,
    this.remindersEnabled = true,
    this.geofenceAutoCheck = true,
    this.tenureYears = '',
    this.attendanceScore,
  });

  /// Initials generated from employee name (e.g. 'MM' for Maryam Malik)
  String get initials {
    if (name.trim().isEmpty) return 'EM';
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  /// Factory parser for /me/profile and /employees/{id} responses
  factory EmployeeProfileModel.fromJson(Map<String, dynamic> json) {
    // Envelope unwrapping
    final payload = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : (json['data'] is Map
            ? Map<String, dynamic>.from(json['data'])
            : json);

    // Parse sections
    final rawSections = payload['sections'];
    final List<ProfileSectionModel> parsedSections = [];
    if (rawSections is List) {
      for (final s in rawSections) {
        if (s is Map) {
          parsedSections.add(ProfileSectionModel.fromJson(
              Map<String, dynamic>.from(s)));
        }
      }
    }

    // Parse emergency contacts
    final rawEmergencies = payload['emergency_contacts'];
    final List<ProfileEmergencyContactModel> parsedEmergencies = [];
    if (rawEmergencies is List) {
      for (final e in rawEmergencies) {
        if (e is Map) {
          parsedEmergencies.add(ProfileEmergencyContactModel.fromJson(
              Map<String, dynamic>.from(e)));
        }
      }
    }

    // Parse documents
    final rawDocs = payload['documents'];
    final List<ProfileDocumentModel> parsedDocs = [];
    if (rawDocs is List) {
      for (final d in rawDocs) {
        if (d is Map) {
          parsedDocs.add(ProfileDocumentModel.fromJson(
              Map<String, dynamic>.from(d)));
        }
      }
    }

    final rawJob = payload['job'];
    final ProfileJobModel? parsedJob = rawJob is Map
        ? ProfileJobModel.fromJson(Map<String, dynamic>.from(rawJob))
        : null;

    final rawContact = payload['contact'];
    final ProfileContactModel? parsedContact = rawContact is Map
        ? ProfileContactModel.fromJson(
            Map<String, dynamic>.from(rawContact))
        : null;

    final rawPersonal = payload['personal'];
    final ProfilePersonalModel? parsedPersonal = rawPersonal is Map
        ? ProfilePersonalModel.fromJson(
            Map<String, dynamic>.from(rawPersonal))
        : null;

    final firstName = payload['first_name']?.toString() ?? '';
    final lastName = payload['last_name']?.toString() ?? '';
    final fullName = '$firstName $lastName'.trim();
    final rawName = payload['name']?.toString() ??
        (fullName.isNotEmpty ? fullName : '');

    final resolvedEmpNum = payload['employee_number']?.toString() ??
        payload['employee_id']?.toString() ??
        '';

    final resolvedEmail = parsedContact?.workEmail ??
        payload['email']?.toString() ??
        '';

    final resolvedPhone = parsedPersonal?.personalPhone ??
        parsedContact?.workPhone ??
        payload['phone']?.toString() ??
        '';

    final resolvedAddress = parsedPersonal?.address?.formattedAddress ??
        (payload['address'] is String ? payload['address'] as String : null) ??
        '';

    final resolvedCity = parsedPersonal?.address?.city ??
        payload['city']?.toString() ??
        '';

    final resolvedPostalCode = parsedPersonal?.address?.postcode ??
        payload['postal_code']?.toString() ??
        '';

    final String resolvedEmergName = parsedEmergencies.isNotEmpty
        ? (parsedEmergencies.first.name ?? '')
        : (payload['emergency_contact_name']?.toString() ?? '');

    final String resolvedEmergPhone = parsedEmergencies.isNotEmpty
        ? (parsedEmergencies.first.phone ?? '')
        : (payload['emergency_contact_phone']?.toString() ?? '');

    final String resolvedEmergRel = parsedEmergencies.isNotEmpty
        ? (parsedEmergencies.first.relationship ?? '')
        : (payload['emergency_contact_relation']?.toString() ?? '');

    return EmployeeProfileModel(
      id: payload['id']?.toString() ?? '',
      employeeNumber: resolvedEmpNum,
      name: rawName,
      email: resolvedEmail,
      phone: resolvedPhone,
      cnic: payload['cnic']?.toString() ?? '',
      dob: parsedPersonal?.dateOfBirth ??
          payload['dob']?.toString() ??
          '',
      gender: parsedPersonal?.gender ??
          payload['gender']?.toString() ??
          '',
      bloodGroup: parsedPersonal?.bloodGroup ??
          payload['blood_group']?.toString() ??
          '',
      employeeId: resolvedEmpNum,
      designation: payload['designation']?.toString() ??
          parsedJob?.designation ??
          '',
      department: payload['department']?.toString() ??
          parsedJob?.department ??
          '',
      joiningDate: parsedJob?.joinedOn ??
          payload['joining_date']?.toString() ??
          '',
      reportingManager: payload['reporting_manager']?.toString(),
      shiftName: payload['shift_name']?.toString(),
      shiftTime: payload['shift_time']?.toString(),
      graceMinutes: (payload['grace_minutes'] as num?)?.toInt(),
      workLocation: payload['work_location']?.toString() ??
          parsedJob?.workLocation ??
          '',
      stage: payload['stage']?.toString() ?? '',
      firstName: payload['first_name']?.toString() ?? '',
      lastName: payload['last_name']?.toString() ?? '',
      preferredName: payload['preferred_name']?.toString(),
      hasPhoto: payload['has_photo'] == true,
      stageLabel: payload['stage_label']?.toString() ?? '',
      sections: parsedSections.isNotEmpty
          ? parsedSections
          : defaultSections,
      job: parsedJob,
      contact: parsedContact ??
          ProfileContactModel(
            workEmail: resolvedEmail.isNotEmpty ? resolvedEmail : null,
            workPhone: resolvedPhone.isNotEmpty ? resolvedPhone : null,
          ),
      personal: parsedPersonal,
      emergencyContacts: parsedEmergencies,
      documents: parsedDocs,
      address: resolvedAddress,
      city: resolvedCity,
      postalCode: resolvedPostalCode,
      emergencyContactName: resolvedEmergName,
      emergencyContactPhone: resolvedEmergPhone,
      emergencyContactRelation: resolvedEmergRel,
      avatarUrl: payload['avatar_url']?.toString(),
      avatarPath: payload['avatar_path']?.toString(),
      biometricEnabled: payload['biometric_enabled'] as bool? ?? true,
      remindersEnabled: payload['reminders_enabled'] as bool? ?? true,
      geofenceAutoCheck: payload['geofence_auto_check'] as bool? ?? true,
      tenureYears: parsedJob?.lengthOfService ??
          payload['tenure_years']?.toString() ??
          '',
      attendanceScore: (payload['attendance_score'] as num?)?.toDouble(),
    );
  }

  /// Default sections if not provided by server
  static List<ProfileSectionModel> get defaultSections => const [
        ProfileSectionModel(key: 'overview', label: 'Overview'),
        ProfileSectionModel(key: 'personal', label: 'Personal'),
        ProfileSectionModel(key: 'job', label: 'Job'),
        ProfileSectionModel(key: 'attendance', label: 'Attendance'),
        ProfileSectionModel(key: 'documents', label: 'Documents'),
        ProfileSectionModel(key: 'pay', label: 'Pay'),
        ProfileSectionModel(key: 'bank', label: 'Bank details'),
        ProfileSectionModel(key: 'account', label: 'Sign-in and card'),
        ProfileSectionModel(key: 'history', label: 'History'),
      ];

  /// Ground truth mock matching the user's exact specification
  factory EmployeeProfileModel.mock() {
    return const EmployeeProfileModel(
      id: '01m5kmp9g8wxp9ssn3aed8awzm',
      employeeNumber: 'EMP-0002',
      name: 'Maryam Malik',
      email: 'maryam@example.com',
      phone: '',
      cnic: '',
      dob: '',
      gender: '',
      bloodGroup: '',
      employeeId: 'EMP-0002',
      designation: 'Sales Manager',
      department: 'Sales',
      joiningDate: '2023-07-15',
      reportingManager: null,
      shiftName: null,
      shiftTime: null,
      graceMinutes: null,
      workLocation: 'Head office',
      stage: 'active',
      firstName: 'Maryam',
      lastName: 'Malik',
      preferredName: null,
      hasPhoto: false,
      stageLabel: 'Active',
      sections: [
        ProfileSectionModel(key: 'overview', label: 'Overview'),
        ProfileSectionModel(key: 'personal', label: 'Personal'),
        ProfileSectionModel(key: 'job', label: 'Job'),
        ProfileSectionModel(key: 'attendance', label: 'Attendance'),
        ProfileSectionModel(key: 'documents', label: 'Documents'),
        ProfileSectionModel(key: 'pay', label: 'Pay'),
        ProfileSectionModel(key: 'bank', label: 'Bank details'),
        ProfileSectionModel(key: 'account', label: 'Sign-in and card'),
        ProfileSectionModel(key: 'history', label: 'History'),
      ],
      job: ProfileJobModel(
        legalEntity: 'Kumash (Pvt) Ltd',
        workLocation: 'Head office',
        department: 'Sales',
        subDepartment: null,
        designation: 'Sales Manager',
        grade: null,
        employmentType: 'full_time',
        contractType: 'permanent',
        contractEndsOn: null,
        joinedOn: '2023-07-15',
        probationEndsOn: null,
        confirmedOn: null,
        lastWorkingDay: null,
        leftOn: null,
        lengthOfService: '3 years 3 months',
      ),
      contact: ProfileContactModel(
        workEmail: 'maryam@example.com',
        workPhone: null,
      ),
      personal: ProfilePersonalModel(
        gender: null,
        dateOfBirth: null,
        bloodGroup: null,
        maritalStatus: null,
        nationality: 'PK',
        personalEmail: null,
        personalPhone: null,
        address: ProfileAddressModel(
          line1: null,
          line2: null,
          city: null,
          postcode: null,
          country: null,
        ),
      ),
      emergencyContacts: [],
      documents: [],
      address: '',
      city: '',
      postalCode: '',
      emergencyContactName: '',
      emergencyContactPhone: '',
      emergencyContactRelation: '',
      biometricEnabled: true,
      remindersEnabled: true,
      geofenceAutoCheck: true,
      tenureYears: '3 years 3 months',
      attendanceScore: null,
    );
  }

  /// Generates a strongly typed mock profile for any specific employee, matching
  /// department staff members (Ayesha Khan, Farhan Ahmed, Zainab Noor) or any dynamic ID.
  factory EmployeeProfileModel.mockForEmployee(
    String empId, {
    String? nameHint,
    String? codeHint,
    String? deptHint,
    String? desigHint,
  }) {
    // 1. Ayesha Khan (EMP-0001)
    if (empId == '01j00000000000000000000001' ||
        codeHint == 'EMP-0001' ||
        nameHint?.toLowerCase().contains('ayesha') == true) {
      return const EmployeeProfileModel(
        id: '01j00000000000000000000001',
        employeeNumber: 'EMP-0001',
        name: 'Ayesha Khan',
        email: 'ayesha@acme.pk',
        phone: '0300 1234567',
        cnic: '42201-8765432-1',
        dob: '1995-04-12',
        gender: 'female',
        bloodGroup: 'B+',
        employeeId: 'EMP-0001',
        designation: 'Officer',
        department: 'Sales',
        joiningDate: '2025-10-22',
        reportingManager: 'Maryam Malik',
        shiftName: 'Morning Standard Shift',
        shiftTime: '08:30 AM - 05:30 PM',
        graceMinutes: 15,
        workLocation: 'Head office',
        stage: 'active',
        firstName: 'Ayesha',
        lastName: 'Khan',
        preferredName: null,
        hasPhoto: false,
        stageLabel: 'Active',
        sections: [
          ProfileSectionModel(key: 'overview', label: 'Overview'),
          ProfileSectionModel(key: 'personal', label: 'Personal'),
          ProfileSectionModel(key: 'job', label: 'Job'),
          ProfileSectionModel(key: 'attendance', label: 'Attendance'),
          ProfileSectionModel(key: 'documents', label: 'Documents'),
          ProfileSectionModel(key: 'bank', label: 'Bank details'),
          ProfileSectionModel(key: 'account', label: 'Sign-in and card'),
          ProfileSectionModel(key: 'history', label: 'History'),
        ],
        job: ProfileJobModel(
          legalEntity: 'Acme Textiles (Pvt) Ltd',
          workLocation: 'Head office',
          department: 'Sales',
          subDepartment: 'Direct Sales',
          designation: 'Officer',
          grade: 'L-2',
          employmentType: 'full_time',
          contractType: 'permanent',
          joinedOn: '2025-10-22',
          lengthOfService: '1 year',
        ),
        contact: ProfileContactModel(
          workEmail: 'ayesha@acme.pk',
          workPhone: '0300 1234567',
        ),
        personal: ProfilePersonalModel(
          gender: 'female',
          dateOfBirth: '1995-04-12',
          bloodGroup: 'B+',
          maritalStatus: 'single',
          nationality: 'PK',
          personalEmail: 'ayesha.personal@gmail.com',
          personalPhone: '0300 1234567',
          address: ProfileAddressModel(
            line1: 'House 12, Street 4',
            city: 'Karachi',
            country: 'PK',
          ),
        ),
        emergencyContacts: [
          ProfileEmergencyContactModel(
            name: 'Bilal Khan',
            relationship: 'Brother',
            phone: '0300 7654321',
          ),
        ],
        documents: [],
        address: 'House 12, Street 4, Karachi',
        city: 'Karachi',
        postalCode: '75500',
        emergencyContactName: 'Bilal Khan',
        emergencyContactPhone: '0300 7654321',
        emergencyContactRelation: 'Brother',
        biometricEnabled: true,
        remindersEnabled: true,
        geofenceAutoCheck: true,
        tenureYears: '1 year',
        attendanceScore: 96.5,
      );
    }

    // 2. Farhan Ahmed (EMP-1042)
    if (empId == '01m5kmp9fmnb75vnt7z1k2pb01' ||
        codeHint == 'EMP-1042' ||
        nameHint?.toLowerCase().contains('farhan') == true) {
      return const EmployeeProfileModel(
        id: '01m5kmp9fmnb75vnt7z1k2pb01',
        employeeNumber: 'EMP-1042',
        name: 'Farhan Ahmed',
        email: 'farhan.ahmed@kumash.com',
        phone: '+92 333 4128976',
        cnic: '35202-9876543-1',
        dob: '1990-08-15',
        gender: 'male',
        bloodGroup: 'O+',
        employeeId: 'EMP-1042',
        designation: 'Senior Systems Analyst',
        department: 'Operations',
        joiningDate: '2023-03-01',
        reportingManager: 'Operations Director',
        shiftName: 'Operations Technical Shift',
        shiftTime: '10:00 AM - 07:00 PM',
        graceMinutes: 10,
        workLocation: 'Regional office',
        stage: 'active',
        firstName: 'Farhan',
        lastName: 'Ahmed',
        stageLabel: 'Active',
        sections: [
          ProfileSectionModel(key: 'overview', label: 'Overview'),
          ProfileSectionModel(key: 'personal', label: 'Personal'),
          ProfileSectionModel(key: 'job', label: 'Job'),
          ProfileSectionModel(key: 'attendance', label: 'Attendance'),
          ProfileSectionModel(key: 'documents', label: 'Documents'),
          ProfileSectionModel(key: 'bank', label: 'Bank details'),
          ProfileSectionModel(key: 'account', label: 'Sign-in and card'),
          ProfileSectionModel(key: 'history', label: 'History'),
        ],
        job: ProfileJobModel(
          legalEntity: 'Kumash (Pvt) Ltd',
          workLocation: 'Regional office',
          department: 'Operations',
          subDepartment: 'Infrastructure & Systems',
          designation: 'Senior Systems Analyst',
          grade: 'L-4',
          employmentType: 'full_time',
          contractType: 'permanent',
          joinedOn: '2023-03-01',
          lengthOfService: '3 years 7 months',
        ),
        contact: ProfileContactModel(
          workEmail: 'farhan.ahmed@kumash.com',
          workPhone: '+92 333 4128976',
        ),
        personal: ProfilePersonalModel(
          gender: 'male',
          dateOfBirth: '1990-08-15',
          bloodGroup: 'O+',
          maritalStatus: 'married',
          nationality: 'PK',
          personalEmail: 'farhan.sys@gmail.com',
          personalPhone: '+92 333 4128976',
          address: ProfileAddressModel(
            line1: 'Apartment 402, Executive Heights, Gulberg III',
            city: 'Lahore',
            country: 'PK',
          ),
        ),
        emergencyContacts: [
          ProfileEmergencyContactModel(
            name: 'Rehana Ahmed',
            relationship: 'Mother',
            phone: '+92 301 2233445',
          ),
        ],
        documents: [],
        address: 'Apartment 402, Executive Heights, Gulberg III, Lahore',
        city: 'Lahore',
        postalCode: '54000',
        emergencyContactName: 'Rehana Ahmed',
        emergencyContactPhone: '+92 301 2233445',
        emergencyContactRelation: 'Mother',
        biometricEnabled: true,
        remindersEnabled: true,
        geofenceAutoCheck: false,
        tenureYears: '3 years 7 months',
        attendanceScore: 98.0,
      );
    }

    // 3. Zainab Noor (EMP-1154)
    if (empId == '01m5kmp9fmnb75vnt7z1k2pb04' ||
        codeHint == 'EMP-1154' ||
        nameHint?.toLowerCase().contains('zainab') == true) {
      return const EmployeeProfileModel(
        id: '01m5kmp9fmnb75vnt7z1k2pb04',
        employeeNumber: 'EMP-1154',
        name: 'Zainab Noor',
        email: 'zainab.noor@kumash.com',
        phone: '+92 321 7766554',
        cnic: '61101-1234567-2',
        dob: '1998-11-20',
        gender: 'female',
        bloodGroup: 'A+',
        employeeId: 'EMP-1154',
        designation: 'Department Associate',
        department: 'Operations',
        joiningDate: '2024-02-01',
        reportingManager: 'Farhan Ahmed',
        shiftName: 'General Corporate Shift',
        shiftTime: '09:00 AM - 06:00 PM',
        graceMinutes: 15,
        workLocation: 'Head office',
        stage: 'probation',
        firstName: 'Zainab',
        lastName: 'Noor',
        stageLabel: 'Probation',
        sections: [
          ProfileSectionModel(key: 'overview', label: 'Overview'),
          ProfileSectionModel(key: 'personal', label: 'Personal'),
          ProfileSectionModel(key: 'job', label: 'Job'),
          ProfileSectionModel(key: 'attendance', label: 'Attendance'),
          ProfileSectionModel(key: 'documents', label: 'Documents'),
          ProfileSectionModel(key: 'bank', label: 'Bank details'),
          ProfileSectionModel(key: 'account', label: 'Sign-in and card'),
          ProfileSectionModel(key: 'history', label: 'History'),
        ],
        job: ProfileJobModel(
          legalEntity: 'Kumash (Pvt) Ltd',
          workLocation: 'Head office',
          department: 'Operations',
          subDepartment: 'Admin Support',
          designation: 'Department Associate',
          grade: 'L-1',
          employmentType: 'full_time',
          contractType: 'probation',
          joinedOn: '2024-02-01',
          probationEndsOn: '2024-08-01',
          lengthOfService: '8 months',
        ),
        contact: ProfileContactModel(
          workEmail: 'zainab.noor@kumash.com',
          workPhone: '+92 321 7766554',
        ),
        personal: ProfilePersonalModel(
          gender: 'female',
          dateOfBirth: '1998-11-20',
          bloodGroup: 'A+',
          maritalStatus: 'single',
          nationality: 'PK',
          personalEmail: 'zainab.noor.personal@gmail.com',
          personalPhone: '+92 321 7766554',
          address: ProfileAddressModel(
            line1: 'Flat 12, Pine Court, Sector G-11',
            city: 'Islamabad',
            country: 'PK',
          ),
        ),
        emergencyContacts: [
          ProfileEmergencyContactModel(
            name: 'Dr. Noor',
            relationship: 'Father',
            phone: '+92 300 4433221',
          ),
        ],
        documents: [],
        address: 'Flat 12, Pine Court, Sector G-11, Islamabad',
        city: 'Islamabad',
        postalCode: '44000',
        emergencyContactName: 'Dr. Noor',
        emergencyContactPhone: '+92 300 4433221',
        emergencyContactRelation: 'Father',
        biometricEnabled: true,
        remindersEnabled: true,
        geofenceAutoCheck: true,
        tenureYears: '8 months',
        attendanceScore: 94.0,
      );
    }

    // 4. Maryam Malik (Self Profile Ground Truth)
    if (empId == '01m5kmp9g8wxp9ssn3aed8awzm' ||
        codeHint == 'EMP-0002' ||
        nameHint?.toLowerCase().contains('maryam') == true) {
      return EmployeeProfileModel.mock();
    }

    // 5. Dynamic fallback for any other employee ID / parameters
    final resolvedName = nameHint ?? 'Staff Member';
    final nameParts = resolvedName.split(' ');
    final fName = nameParts.isNotEmpty ? nameParts.first : 'Staff';
    final lName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : 'Member';
    final resolvedCode = codeHint ??
        (empId.length > 8
            ? 'EMP-${empId.substring(empId.length - 4).toUpperCase()}'
            : 'EMP-0099');
    final resolvedDept = deptHint ?? 'Operations';
    final resolvedDesig = desigHint ?? 'Executive Officer';

    return EmployeeProfileModel(
      id: empId,
      employeeNumber: resolvedCode,
      name: resolvedName,
      email: '${fName.toLowerCase()}.${lName.toLowerCase()}@example.com',
      phone: '+92 300 9876543',
      cnic: '42101-1234567-1',
      dob: '1994-06-18',
      gender: 'male',
      bloodGroup: 'B+',
      employeeId: resolvedCode,
      designation: resolvedDesig,
      department: resolvedDept,
      joiningDate: '2023-09-01',
      reportingManager: 'Executive Management',
      shiftName: 'General Corporate Shift',
      shiftTime: '09:00 AM - 06:00 PM',
      graceMinutes: 15,
      workLocation: 'Head office',
      stage: 'active',
      firstName: fName,
      lastName: lName,
      stageLabel: 'Active',
      sections: EmployeeProfileModel.defaultSections,
      job: ProfileJobModel(
        legalEntity: 'Kumash (Pvt) Ltd',
        workLocation: 'Head office',
        department: resolvedDept,
        designation: resolvedDesig,
        employmentType: 'full_time',
        contractType: 'permanent',
        joinedOn: '2023-09-01',
        lengthOfService: '2 years 2 months',
      ),
      contact: ProfileContactModel(
        workEmail: '${fName.toLowerCase()}.${lName.toLowerCase()}@example.com',
        workPhone: '+92 300 9876543',
      ),
      tenureYears: '2 years 2 months',
      attendanceScore: 97.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_number': employeeNumber,
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
      'stage': stage,
      'first_name': firstName,
      'last_name': lastName,
      'preferred_name': preferredName,
      'has_photo': hasPhoto,
      'stage_label': stageLabel,
      'sections': sections.map((s) => s.toJson()).toList(),
      if (job != null) 'job': job!.toJson(),
      if (contact != null) 'contact': contact!.toJson(),
      if (personal != null) 'personal': personal!.toJson(),
      'emergency_contacts':
          emergencyContacts.map((e) => e.toJson()).toList(),
      'documents': documents.map((d) => d.toJson()).toList(),
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
    String? id,
    String? employeeNumber,
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
    String? stage,
    String? firstName,
    String? lastName,
    String? preferredName,
    bool? hasPhoto,
    String? stageLabel,
    List<ProfileSectionModel>? sections,
    ProfileJobModel? job,
    ProfileContactModel? contact,
    ProfilePersonalModel? personal,
    List<ProfileEmergencyContactModel>? emergencyContacts,
    List<ProfileDocumentModel>? documents,
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
      id: id ?? this.id,
      employeeNumber: employeeNumber ?? this.employeeNumber,
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
      stage: stage ?? this.stage,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      preferredName: preferredName ?? this.preferredName,
      hasPhoto: hasPhoto ?? this.hasPhoto,
      stageLabel: stageLabel ?? this.stageLabel,
      sections: sections ?? this.sections,
      job: job ?? this.job,
      contact: contact ?? this.contact,
      personal: personal ?? this.personal,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
      documents: documents ?? this.documents,
      address: address ?? this.address,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
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
