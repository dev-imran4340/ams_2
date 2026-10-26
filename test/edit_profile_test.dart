import 'package:flutter_test/flutter_test.dart';
import 'package:ams_2/app/api/exception_handler.dart';
import 'package:ams_2/app/screens/edit_profile/controller/edit_profile_controller.dart';
import 'package:ams_2/app/screens/edit_profile/model/edit_profile_model.dart';
import 'package:ams_2/app/screens/edit_profile/repo/edit_profile_repo.dart';

void main() {
  group('POST /me/details-change Models Test Suite', () {
    test('PersonalDetailsChangeRequest sends kind: details and only changed fields', () {
      final request = PersonalDetailsChangeRequest(
        personalPhone: '0300 2222222',
        cityName: 'Lahore',
        changedFields: {'personal_phone', 'city_name'},
      );

      final json = request.toJson();

      expect(json['kind'], 'details');
      expect(json['personal_phone'], '0300 2222222');
      expect(json['city_name'], 'Lahore');
      expect(json.containsKey('preferred_name'), isFalse);
      expect(json.containsKey('personal_email'), isFalse);
      expect(json.containsKey('marital_status'), isFalse);
      expect(json.containsKey('address_line1'), isFalse);
    });

    test('EmergencyContactChangeRequest serializes required fields accurately', () {
      const request = EmergencyContactChangeRequest(
        name: 'Bilal Khan',
        relationship: 'Brother',
        phone: '0300 3333333',
        isPrimary: true,
      );

      final json = request.toJson();

      expect(json['kind'], 'emergency_contact');
      expect(json['name'], 'Bilal Khan');
      expect(json['relationship'], 'Brother');
      expect(json['phone'], '0300 3333333');
      expect(json['is_primary'], isTrue);
      expect(json.containsKey('contact'), isFalse);
    });

    test('EmergencyContactChangeRequest with existing contact ID serializes contact key', () {
      const request = EmergencyContactChangeRequest(
        contactId: '01jb2x9k4m7q8r3t5v6w8y0z1a',
        name: 'Tariq Mehmood',
        relationship: 'Father',
        phone: '0321 7654321',
        alternativePhone: '0300 1111111',
        isPrimary: false,
      );

      final json = request.toJson();

      expect(json['kind'], 'emergency_contact');
      expect(json['contact'], '01jb2x9k4m7q8r3t5v6w8y0z1a');
      expect(json['name'], 'Tariq Mehmood');
      expect(json['relationship'], 'Father');
      expect(json['alternative_phone'], '0300 1111111');
      expect(json['is_primary'], isFalse);
    });

    test('DetailsChangeResponse parses 201 response payload correctly', () {
      final json = {
        'id': '01jb2x9k4m7q8r3t5v6w8y0z1a',
        'type': 'employee_details_change',
        'type_label': 'Change of my details',
        'title': 'Change of my details: personal phone',
        'status': 'pending',
        'status_label': 'Waiting for approval',
        'status_tone': 'amber',
      };

      final response = DetailsChangeResponse.fromJson(json);

      expect(response.id, '01jb2x9k4m7q8r3t5v6w8y0z1a');
      expect(response.isPending, isTrue);
      expect(response.isApproved, isFalse);
      expect(response.statusTone, 'amber');
      expect(response.userMessage, contains('waiting for company decision'));
    });

    test('DetailsChangeResponse with approved status returns saved message', () {
      final json = {
        'id': '01jb2x9k4m7q8r3t5v6w8y0z1a',
        'type': 'employee_details_change',
        'type_label': 'Change of my details',
        'title': 'Change of my details: personal phone',
        'status': 'approved',
        'status_label': 'Approved',
        'status_tone': 'emerald',
      };

      final response = DetailsChangeResponse.fromJson(json);

      expect(response.isApproved, isTrue);
      expect(response.isPending, isFalse);
      expect(response.userMessage, contains('Saved'));
    });

    test('409 Conflict ApiException identification and error handling', () {
      final conflictException = ApiException(
        statusCode: 409,
        errorCode: 'conflict',
        message: 'There is already a request waiting for approval. Wait for its answer or withdraw it first.',
      );

      expect(conflictException.isConflict, isTrue);
      expect(conflictException.statusCode, 409);
      expect(conflictException.errorCode, 'conflict');
      expect(conflictException.message, contains('already a request waiting'));
    });
  });

  group('Edit Profile Form Validators (Empty is valid; format validated on typing)', () {
    late EditProfileController controller;

    setUp(() {
      controller = EditProfileController(repo: EditProfileRepo());
    });

    tearDown(() {
      controller.onClose();
    });

    test('Empty fields are completely valid (no validation errors)', () {
      expect(controller.validatePersonalEmail(''), isNull);
      expect(controller.validatePersonalEmail(null), isNull);
      expect(controller.validatePersonalPhone(''), isNull);
      expect(controller.validatePersonalPhone(null), isNull);
      expect(controller.validatePreferredName(''), isNull);
      expect(controller.validateCity(''), isNull);
      expect(controller.validatePostcode(''), isNull);
      expect(controller.validateCountryCode(''), isNull);
      expect(controller.validateAddressLine1(''), isNull);
      expect(controller.validateAddressLine2(''), isNull);
      expect(controller.validateEmergencyAltPhone(''), isNull);
    });

    test('Email validator enforces valid email format when entered', () {
      expect(controller.validatePersonalEmail('invalid-email'), isNotNull);
      expect(controller.validatePersonalEmail('test@'), isNotNull);
      expect(controller.validatePersonalEmail('test@domain'), isNotNull);
      expect(controller.validatePersonalEmail('employee@company.com'), isNull);
      expect(controller.validatePersonalEmail('alex.smith@mail.co.uk'), isNull);
    });

    test('Phone validator enforces at least 10 digits and valid format when entered', () {
      expect(controller.validatePersonalPhone('123'), isNotNull);
      expect(controller.validatePersonalPhone('0300'), isNotNull);
      expect(controller.validatePersonalPhone('abc03001234567'), isNotNull);
      expect(controller.validatePersonalPhone('0300 2222222'), isNull);
      expect(controller.validatePersonalPhone('+92 300 1234567'), isNull);
      expect(controller.validatePersonalPhone('+44 20 7946 0991'), isNull);
    });

    test('Country code validator enforces 2-letter ISO code', () {
      expect(controller.validateCountryCode('PAK'), isNotNull);
      expect(controller.validateCountryCode('12'), isNotNull);
      expect(controller.validateCountryCode('PK'), isNull);
      expect(controller.validateCountryCode('GB'), isNull);
      expect(controller.validateCountryCode('US'), isNull);
    });

    test('Preferred name validator enforces max 80 characters and letters/spaces', () {
      expect(controller.validatePreferredName('Valid Name'), isNull);
      expect(controller.validatePreferredName("O'Connor"), isNull);
      expect(controller.validatePreferredName('Name123'), isNotNull);
    });
  });
}
