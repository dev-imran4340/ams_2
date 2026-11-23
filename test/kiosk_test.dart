import 'package:flutter_test/flutter_test.dart';
import 'package:ams_2/app/screens/kiosk/model/kiosk_model.dart';
import 'package:ams_2/app/screens/kiosk/repo/kiosk_repo.dart';
import 'package:ams_2/app/screens/kiosk/controller/kiosk_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Kiosk Model Tests', () {
    test('KioskConfigModel parses JSON correctly', () {
      final json = {
        'kiosk': {
          'id': '01jb2x9k4m7q8r3t5v6w8y0z1a',
          'name': 'Front Desk Kiosk',
          'location': {
            'id': '01jb2x9k4m7q8r3t5v6w8y0z1b',
            'name': 'Head Office',
            'timezone': 'Asia/Karachi',
          },
          'pin_allowed': true,
        },
        'token': 'kiosk_sample_secret_token',
      };

      final model = KioskConfigModel.fromJson(json);
      expect(model.id, '01jb2x9k4m7q8r3t5v6w8y0z1a');
      expect(model.name, 'Front Desk Kiosk');
      expect(model.locationName, 'Head Office');
      expect(model.pinAllowed, true);
      expect(model.token, 'kiosk_sample_secret_token');
    });

    test('KioskIdentifyResponseModel parses identify session', () {
      final json = {
        'person': {
          'id': '01jb2x9k4m7q8r3t5v6w8y0z1c',
          'name': 'Malik Imran',
          'employee_number': 'EMP-001',
        },
        'ticket': 'sample_ticket_jwt',
        'expires_in': 120,
        'state': {
          'allowed': ['in', 'out'],
        },
        'requires': {
          'photo': false,
          'face': 'off',
        },
      };

      final model = KioskIdentifyResponseModel.fromJson(json);
      expect(model.person.name, 'Malik Imran');
      expect(model.ticket, 'sample_ticket_jwt');
      expect(model.allowedActions, contains('in'));
      expect(model.allowedActions, contains('out'));
    });
  });

  group('KioskController Validation Tests', () {
    final controller = KioskController(repo: KioskRepo());

    test('validatePin rejects invalid and sequential PINs', () {
      expect(controller.validatePin(''), isNotNull);
      expect(controller.validatePin('12'), isNotNull); // too short
      expect(controller.validatePin('1234567'), isNotNull); // too long
      expect(controller.validatePin('abcd'), isNotNull); // non-numeric
      expect(controller.validatePin('1111'), isNotNull); // identical digits
      expect(controller.validatePin('1234'), isNotNull); // sequential ascending
      expect(controller.validatePin('4321'), isNotNull); // sequential descending
      expect(controller.validatePin('5829'), isNull); // valid 4-digit
      expect(controller.validatePin('937105'), isNull); // valid 6-digit
    });

    test('validateConfirmPin validates matching PIN', () {
      controller.pinController.text = '5829';
      expect(controller.validateConfirmPin('5820'), isNotNull);
      expect(controller.validateConfirmPin('5829'), isNull);
    });
  });
}
