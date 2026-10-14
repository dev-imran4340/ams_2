import 'package:ams_2/app/screens/verification/qr_scanner/model/qr_scan_model.dart';
import 'package:ams_2/app/screens/verification/qr_scanner/repo/qr_scan_repo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EmployeeCardQrModel Tests', () {
    test('parses delimited string payload correctly', () {
      const raw = 'AMS:SFT-094:ORG-102:SEC-TOKEN-8849';
      final model = EmployeeCardQrModel.fromRawPayload(raw);

      expect(model.employeeCode, 'SFT-094');
      expect(model.employeeId, 'SFT-094');
      expect(model.organizationId, 'ORG-102');
      expect(model.cardToken, 'SEC-TOKEN-8849');
      expect(model.isValid, true);
    });

    test('parses JSON payload correctly', () {
      const jsonStr =
          '{"employee_code":"SFT-101","organization_id":"ORG-200","card_token":"TOKEN-XYZ","is_valid":true}';
      final model = EmployeeCardQrModel.fromRawPayload(jsonStr);

      expect(model.employeeCode, 'SFT-101');
      expect(model.organizationId, 'ORG-200');
      expect(model.cardToken, 'TOKEN-XYZ');
      expect(model.isValid, true);
    });

    test('handles empty payload safely', () {
      final model = EmployeeCardQrModel.fromRawPayload('');
      expect(model.isValid, false);
      expect(model.employeeCode, isEmpty);
    });
  });

  group('QRScanRepo Tests', () {
    final repo = QRScanRepo();

    test('successfully verifies valid payload', () async {
      const raw = 'AMS:SFT-094:ORG-102:SEC-TOKEN-8849';
      final card = await repo.verifyCardPayload(raw);

      expect(card, isNotNull);
      expect(card?.employeeCode, 'SFT-094');
      expect(card?.isValid, true);
    });

    test('returns null for empty payload', () async {
      final card = await repo.verifyCardPayload('   ');
      expect(card, isNull);
    });
  });
}
