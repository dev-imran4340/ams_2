class AddEmployeeRequestModel {
  final String fullName;
  final String email;
  final String phoneCountryCode;
  final String phoneNumber;
  final String gender;
  final String cnic;
  final String dob;
  final String houseNo;
  final String street;
  final String city;
  final String postcode;
  final String department;
  final String designation;
  final String shift;
  final String joiningDate;
  final String emergencyContactName;
  final String emergencyPhone;
  final String relationship;
  final String? photoPath;
  final bool isFaceEnrolled;

  const AddEmployeeRequestModel({
    required this.fullName,
    required this.email,
    required this.phoneCountryCode,
    required this.phoneNumber,
    required this.gender,
    required this.cnic,
    required this.dob,
    required this.houseNo,
    required this.street,
    required this.city,
    required this.postcode,
    required this.department,
    required this.designation,
    required this.shift,
    required this.joiningDate,
    required this.emergencyContactName,
    required this.emergencyPhone,
    required this.relationship,
    this.photoPath,
    this.isFaceEnrolled = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'email': email,
      'phone_country_code': phoneCountryCode,
      'phone_number': phoneNumber,
      'gender': gender,
      'cnic': cnic,
      'dob': dob,
      'house_no': houseNo,
      'street': street,
      'city': city,
      'postcode': postcode,
      'department': department,
      'designation': designation,
      'shift': shift,
      'joining_date': joiningDate,
      'emergency_contact_name': emergencyContactName,
      'emergency_phone': emergencyPhone,
      'relationship': relationship,
      'photo_path': photoPath,
      'is_face_enrolled': isFaceEnrolled,
    };
  }
}

class AddEmployeeLookupModel {
  final List<String> departments;
  final List<String> designations;
  final List<String> shifts;
  final List<String> cities;
  final List<String> genders;
  final List<String> relationships;
  final List<CountryModel> countries;

  const AddEmployeeLookupModel({
    required this.departments,
    required this.designations,
    required this.shifts,
    required this.cities,
    required this.genders,
    required this.relationships,
    this.countries = const [],
  });

  factory AddEmployeeLookupModel.fallback() {
    return const AddEmployeeLookupModel(
      departments: [
        'Software Engineering',
        'Quality Assurance',
        'Product Design & UI/UX',
        'Human Resources',
        'Operations & Logistics',
        'Sales & Marketing',
      ],
      designations: [
        'Associate Software Engineer',
        'Senior Flutter Developer',
        'Lead Backend Architect',
        'QA Automation Engineer',
        'HR Specialist',
        'Operations Manager',
      ],
      shifts: [
        'Morning General (09:00 AM - 06:00 PM)',
        'Mid Shift (12:00 PM - 09:00 PM)',
        'Night Shift (08:00 PM - 05:00 AM)',
        'Flexible 8 Hours Shift',
      ],
      cities: [
        'Islamabad',
        'Rawalpindi',
        'Lahore',
        'Karachi',
        'Peshawar',
        'Faisalabad',
        'Dubai, UAE',
      ],
      genders: ['Male', 'Female', 'Other'],
      relationships: ['Father', 'Mother', 'Spouse', 'Brother', 'Sister', 'Guardian'],
      countries: [
        CountryModel(
          id: '1',
          countryName: 'Pakistan',
          dialCode: '+92',
          countryCode: 'PK',
          flag: '🇵🇰',
          cities: [
            CityModel(id: '101', name: 'Islamabad'),
            CityModel(id: '102', name: 'Rawalpindi'),
            CityModel(id: '103', name: 'Lahore'),
            CityModel(id: '104', name: 'Karachi'),
            CityModel(id: '105', name: 'Peshawar'),
            CityModel(id: '106', name: 'Quetta'),
            CityModel(id: '107', name: 'Faisalabad'),
            CityModel(id: '108', name: 'Multan'),
            CityModel(id: '109', name: 'Sialkot'),
            CityModel(id: '110', name: 'Gujranwala'),
            CityModel(id: '111', name: 'Abbottabad'),
          ],
        ),
        CountryModel(
          id: '2',
          countryName: 'United Arab Emirates',
          dialCode: '+971',
          countryCode: 'AE',
          flag: '🇦🇪',
          cities: [
            CityModel(id: '201', name: 'Dubai'),
            CityModel(id: '202', name: 'Abu Dhabi'),
            CityModel(id: '203', name: 'Sharjah'),
            CityModel(id: '204', name: 'Ajman'),
            CityModel(id: '205', name: 'Ras Al Khaimah'),
            CityModel(id: '206', name: 'Al Ain'),
          ],
        ),
        CountryModel(
          id: '3',
          countryName: 'Saudi Arabia',
          dialCode: '+966',
          countryCode: 'SA',
          flag: '🇸🇦',
          cities: [
            CityModel(id: '301', name: 'Riyadh'),
            CityModel(id: '302', name: 'Jeddah'),
            CityModel(id: '303', name: 'Dammam'),
            CityModel(id: '304', name: 'Mecca'),
            CityModel(id: '305', name: 'Medina'),
            CityModel(id: '306', name: 'Khobar'),
          ],
        ),
        CountryModel(
          id: '4',
          countryName: 'United Kingdom',
          dialCode: '+44',
          countryCode: 'GB',
          flag: '🇬🇧',
          cities: [
            CityModel(id: '401', name: 'London'),
            CityModel(id: '402', name: 'Manchester'),
            CityModel(id: '403', name: 'Birmingham'),
            CityModel(id: '404', name: 'Leeds'),
            CityModel(id: '405', name: 'Glasgow'),
          ],
        ),
        CountryModel(
          id: '5',
          countryName: 'United States',
          dialCode: '+1',
          countryCode: 'US',
          flag: '🇺🇸',
          cities: [
            CityModel(id: '501', name: 'New York'),
            CityModel(id: '502', name: 'Los Angeles'),
            CityModel(id: '503', name: 'Chicago'),
            CityModel(id: '504', name: 'Houston'),
            CityModel(id: '505', name: 'San Francisco'),
          ],
        ),
        CountryModel(
          id: '6',
          countryName: 'Canada',
          dialCode: '+1',
          countryCode: 'CA',
          flag: '🇨🇦',
          cities: [
            CityModel(id: '601', name: 'Toronto'),
            CityModel(id: '602', name: 'Vancouver'),
            CityModel(id: '603', name: 'Montreal'),
            CityModel(id: '604', name: 'Calgary'),
          ],
        ),
        CountryModel(
          id: '7',
          countryName: 'Australia',
          dialCode: '+61',
          countryCode: 'AU',
          flag: '🇦🇺',
          cities: [
            CityModel(id: '701', name: 'Sydney'),
            CityModel(id: '702', name: 'Melbourne'),
            CityModel(id: '703', name: 'Brisbane'),
            CityModel(id: '704', name: 'Perth'),
          ],
        ),
        CountryModel(
          id: '8',
          countryName: 'Qatar',
          dialCode: '+974',
          countryCode: 'QA',
          flag: '🇶🇦',
          cities: [
            CityModel(id: '801', name: 'Doha'),
            CityModel(id: '802', name: 'Al Rayyan'),
            CityModel(id: '803', name: 'Al Wakrah'),
          ],
        ),
        CountryModel(
          id: '9',
          countryName: 'Oman',
          dialCode: '+968',
          countryCode: 'OM',
          flag: '🇴🇲',
          cities: [
            CityModel(id: '901', name: 'Muscat'),
            CityModel(id: '902', name: 'Salalah'),
            CityModel(id: '903', name: 'Sohar'),
          ],
        ),
      ],
    );
  }
}

class CountryModel {
  final String id;
  final String countryName;
  final String dialCode;
  final String countryCode;
  final String flag;
  final List<CityModel> cities;

  const CountryModel({
    required this.id,
    required this.countryName,
    required this.dialCode,
    required this.countryCode,
    this.flag = '',
    this.cities = const [],
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      id: json['id']?.toString() ?? '',
      countryName: json['country_name']?.toString() ?? json['countryName']?.toString() ?? '',
      dialCode: json['dial_code']?.toString() ?? json['phone_code']?.toString() ?? json['dialCode']?.toString() ?? '',
      countryCode: json['country_code']?.toString() ?? json['countryCode']?.toString() ?? '',
      flag: json['flag']?.toString() ?? '',
      cities: (json['cities'] as List<dynamic>?)
              ?.map((c) => CityModel.fromJson(c as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'country_name': countryName,
    'dial_code': dialCode,
    'country_code': countryCode,
    'flag': flag,
    'cities': cities.map((c) => c.toJson()).toList(),
  };
}

class CityModel {
  final String id;
  final String name;

  const CityModel({required this.id, required this.name});

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}

class AddEmployeeResponseModel {
  final bool success;
  final String message;
  final String? employeeId;

  const AddEmployeeResponseModel({
    required this.success,
    required this.message,
    this.employeeId,
  });

  factory AddEmployeeResponseModel.fromJson(Map<String, dynamic> json) {
    return AddEmployeeResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? 'Operation completed.',
      employeeId: json['employee_id']?.toString(),
    );
  }
}
