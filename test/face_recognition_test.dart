import 'package:ams_2/app/screens/verification/face_recognition/controller/face_recognition_controller.dart';
import 'package:ams_2/app/screens/verification/face_recognition/model/face_recognition_model.dart';
import 'package:ams_2/app/screens/verification/face_recognition/repo/face_recognition_repo.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    const MethodChannel channel =
        MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return '.';
    });

    const MethodChannel mlkitChannel =
        MethodChannel('google_mlkit_face_detector');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(mlkitChannel, (MethodCall methodCall) async {
      return null;
    });

    await GetStorage.init();
  });

  group('AI Face Recognition (Phase 10) Unit Tests', () {
    test('FaceCheckResult evaluates multi-check criteria accurately', () {
      final initial = FaceCheckResult.initial();
      expect(initial.allPassed, isFalse);

      final noFace = FaceCheckResult.noFace();
      expect(noFace.hasExactlyOneFace, isFalse);
      expect(noFace.allPassed, isFalse);

      final multiFace = FaceCheckResult.multipleFaces(3);
      expect(multiFace.faceCount, equals(3));
      expect(multiFace.hasExactlyOneFace, isFalse);
      expect(multiFace.allPassed, isFalse);

      // Check: Eyes closed or sunglasses (< 0.50 probability)
      const closedEyes = FaceCheckResult(
        hasExactlyOneFace: true,
        faceCount: 1,
        eyesOpen: false,
        leftEyeProbability: 0.2,
        rightEyeProbability: 0.1,
        headStraight: true,
        isCentered: true,
        isScaleValid: true,
        statusMessage: 'Please open both eyes / remove dark sunglasses',
      );
      expect(closedEyes.allPassed, isFalse);

      // Check: Head tilted (> 15 degrees)
      const tiltedHead = FaceCheckResult(
        hasExactlyOneFace: true,
        faceCount: 1,
        eyesOpen: true,
        headStraight: false,
        headEulerAngleY: 25.0,
        headEulerAngleZ: 5.0,
        isCentered: true,
        isScaleValid: true,
        statusMessage: 'Keep head straight and look directly at camera',
      );
      expect(tiltedHead.allPassed, isFalse);

      // Check: All 5 validation checks pass
      const perfectFace = FaceCheckResult(
        hasExactlyOneFace: true,
        faceCount: 1,
        eyesOpen: true,
        leftEyeProbability: 0.95,
        rightEyeProbability: 0.92,
        headStraight: true,
        headEulerAngleY: 2.0,
        headEulerAngleZ: -1.0,
        isCentered: true,
        isScaleValid: true,
        scaleRatio: 0.65,
        statusMessage: 'Perfect! Hold steady',
      );
      expect(perfectFace.allPassed, isTrue);
    });

    test('FaceRecognitionRepo computes Cosine Similarity accurately', () {
      final repo = FaceRecognitionRepo();

      // Identical vectors should have similarity ~1.0
      final v1 = [0.2, 0.5, 0.8, 0.4, 0.9];
      final v2 = [0.2, 0.5, 0.8, 0.4, 0.9];
      final double simIdentical = repo.computeCosineSimilarity(v1, v2);
      expect(simIdentical, closeTo(1.0, 0.001));

      // Orthogonal vectors should have similarity 0.0
      final vOrthogonal1 = [1.0, 0.0, 0.0];
      final vOrthogonal2 = [0.0, 1.0, 0.0];
      final double simOrthogonal =
          repo.computeCosineSimilarity(vOrthogonal1, vOrthogonal2);
      expect(simOrthogonal, equals(0.0));

      // Slightly perturbed vectors (same face slightly shifted)
      final vShifted = [0.21, 0.49, 0.82, 0.39, 0.88];
      final double simShifted = repo.computeCosineSimilarity(v1, vShifted);
      expect(simShifted, greaterThan(0.95));

      repo.dispose();
    });

    test('FaceComparisonReport formats percentage and verdict properly', () {
      final report = FaceComparisonReport(
        matched: true,
        score: 0.9654,
        statusLog: 'OK',
        message: 'Face matched with high confidence.',
        timestamp: DateTime.now(),
      );

      expect(report.matched, isTrue);
      expect(report.scorePercentage, equals('96.5%'));
      expect(report.statusLog, equals('OK'));
    });

    test('FaceRecognitionController initializes and disposes cleanly', () {
      final repo = FaceRecognitionRepo();
      final controller = FaceRecognitionController(repo: repo);
      controller.onInit();

      expect(controller.isAllChecksPassed.value, isFalse);
      expect(controller.isSavingReference.value, isFalse);
      expect(controller.isMatching.value, isFalse);
      expect(controller.checkResult.value.hasExactlyOneFace, isFalse);

      // Clean disposal test
      controller.onClose();
    });
  });
}
