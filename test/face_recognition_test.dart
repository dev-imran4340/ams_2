import 'package:ams_2/app/screens/verification/face_recognition/model/face_recognition_model.dart';
import 'package:ams_2/app/screens/verification/face_recognition/repo/face_recognition_repo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FaceBiometricMatchModel Tests', () {
    test('constructs and converts to JSON correctly', () {
      final now = DateTime.now();
      final model = FaceBiometricMatchModel(
        matched: true,
        confidenceScore: 99.4,
        employeeId: 'SFT-094',
        employeeName: 'Muhammad Imran',
        livenessVerified: true,
        verificationTimestamp: now,
      );

      expect(model.matched, true);
      expect(model.confidenceScore, 99.4);
      expect(model.employeeId, 'SFT-094');
      expect(model.employeeName, 'Muhammad Imran');
      expect(model.livenessVerified, true);
      expect(model.verificationTimestamp, now);

      final json = model.toJson();
      expect(json['matched'], true);
      expect(json['confidence_score'], 99.4);
      expect(json['employee_id'], 'SFT-094');
      expect(json['liveness_verified'], true);
    });

    test('parses from JSON correctly', () {
      final json = {
        'matched': true,
        'confidence_score': 98.7,
        'employee_id': 'SFT-094',
        'employee_name': 'Muhammad Imran',
        'liveness_verified': true,
        'verification_timestamp': '2026-10-14T10:00:00.000',
      };

      final model = FaceBiometricMatchModel.fromJson(json);

      expect(model.matched, true);
      expect(model.confidenceScore, 98.7);
      expect(model.employeeId, 'SFT-094');
      expect(model.livenessVerified, true);
      expect(model.verificationTimestamp.year, 2026);
    });
  });

  group('FaceRecognitionRepo Tests', () {
    final repo = FaceRecognitionRepo();

    test('successfully verifies facial match', () async {
      final result =
          await repo.verifyFacialMatch(employeeCode: 'SFT-094');

      expect(result, isNotNull);
      expect(result?.matched, true);
      expect(result?.confidenceScore, 99.4);
      expect(result?.employeeId, 'SFT-094');
      expect(result?.livenessVerified, true);
    });
  });
}
