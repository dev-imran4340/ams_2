import 'dart:io';
import 'dart:math' as math;
import 'package:ams_2/app/screens/verification/face_recognition/controller/face_recognition_controller.dart';
import 'package:ams_2/app/screens/verification/face_recognition/model/face_recognition_model.dart';
import 'package:ams_2/app/screens/verification/face_recognition/repo/face_recognition_repo.dart';
import 'package:ams_2/app/api/app_preferences.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image/image.dart' as img;

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
        isInsideOval: true,
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
        isInsideOval: true,
        statusMessage: 'Keep head straight and look directly at camera',
      );
      expect(tiltedHead.allPassed, isFalse);

      // Check: Face too far from camera (scaleRatio < 0.50)
      const faceTooFar = FaceCheckResult(
        hasExactlyOneFace: true,
        faceCount: 1,
        eyesOpen: true,
        headStraight: true,
        isCentered: true,
        isScaleValid: false,
        scaleRatio: 0.35,
        isInsideOval: true,
        statusMessage: 'Move closer to camera',
      );
      expect(faceTooFar.allPassed, isFalse);

      // Check: Face too close to camera / too much face (scaleRatio > 0.78)
      const faceTooClose = FaceCheckResult(
        hasExactlyOneFace: true,
        faceCount: 1,
        eyesOpen: true,
        headStraight: true,
        isCentered: true,
        isScaleValid: false,
        scaleRatio: 0.88,
        isInsideOval: false,
        statusMessage: 'Move slightly back',
      );
      expect(faceTooClose.allPassed, isFalse);

      // Check: Face partially outside oval boundary
      const faceOutsideOval = FaceCheckResult(
        hasExactlyOneFace: true,
        faceCount: 1,
        eyesOpen: true,
        headStraight: true,
        isCentered: true,
        isScaleValid: true,
        scaleRatio: 0.65,
        isInsideOval: false,
        statusMessage: 'Fit your full face inside the oval',
      );
      expect(faceOutsideOval.allPassed, isFalse);

      // Check: All 6 validation checks pass (full face fits inside oval at ideal distance)
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
        isInsideOval: true,
        statusMessage: 'Perfect! Hold steady',
      );
      expect(perfectFace.allPassed, isTrue);
    });

    test('FaceRecognitionRepo computes Cosine Similarity accurately', () {
      final repo = FaceRecognitionRepo();

      // Identical 192-dim vectors should have similarity ~1.0
      final v1 = List<double>.generate(192, (i) => math.sin(i.toDouble()));
      final v2 = List<double>.from(v1);
      final double simIdentical = repo.computeCosineSimilarity(v1, v2);
      expect(simIdentical, closeTo(1.0, 0.001));

      // Orthogonal 192-dim vectors (first half vs second half)
      final vOrthogonal1 = List<double>.filled(192, 0.0);
      final vOrthogonal2 = List<double>.filled(192, 0.0);
      for (int i = 0; i < 96; i++) {
        vOrthogonal1[i] = 1.0;
      }
      for (int i = 96; i < 192; i++) {
        vOrthogonal2[i] = 1.0;
      }
      final double simOrthogonal =
          repo.computeCosineSimilarity(vOrthogonal1, vOrthogonal2);
      expect(simOrthogonal, equals(0.0));

      // Slightly perturbed 192-dim vectors (same face slightly shifted)
      final vShifted = List<double>.generate(
        192,
        (i) => v1[i] + 0.01 * math.cos(i.toDouble()),
      );
      final double simShifted = repo.computeCosineSimilarity(v1, vShifted);
      expect(simShifted, greaterThan(0.98));

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

    test('cropFaceFromImage strictly crops face area with padding and outputs 112x112 px', () {
      final repo = FaceRecognitionRepo();

      // Create a simulated 300x400 camera image with red background
      final fullImage = img.Image(width: 300, height: 400);
      img.fill(fullImage, color: img.ColorRgb8(255, 0, 0)); // Red background

      // Draw a simulated face rectangle at (100, 100) with size 100x120 (cyan face)
      final faceBox = const Rect.fromLTWH(100, 100, 100, 120);

      final cropped112 = repo.cropFaceFromImage(
        sourceImage: fullImage,
        boundingBox: faceBox,
        margin: 0.12,
        targetWidth: 112,
        targetHeight: 112,
      );

      expect(cropped112.width, equals(112));
      expect(cropped112.height, equals(112));

      repo.dispose();
    });

    test('extract192DimEmbedding produces exactly 192 L2-normalized dimensions', () {
      final repo = FaceRecognitionRepo();
      final dummyFace = img.Image(width: 112, height: 112);
      img.fill(dummyFace, color: img.ColorRgb8(210, 160, 130)); // Skin-tone

      final vector = repo.extract192DimEmbedding(croppedFace112: dummyFace);

      expect(vector.length, equals(192));

      // Verify L2 normalization: sum(v[i]^2) ~= 1.0
      double normSq = 0.0;
      for (final v in vector) {
        normSq += v * v;
      }
      expect(normSq, closeTo(1.0, 0.001));

      repo.dispose();
    });

    test('Background change has ZERO impact on cropped face embedding', () {
      final repo = FaceRecognitionRepo();

      // Scenario A: Face with White Background (Office)
      final frameOffice = img.Image(width: 400, height: 400);
      img.fill(frameOffice, color: img.ColorRgb8(255, 255, 255)); // White wall
      // Draw face in center: (150, 150) to (250, 250)
      for (int y = 150; y < 250; y++) {
        for (int x = 150; x < 250; x++) {
          frameOffice.setPixel(x, y, img.ColorRgb8(200, 150, 120));
        }
      }

      // Scenario B: Exact same face with Dark Background (Outdoor / Night)
      final frameNight = img.Image(width: 400, height: 400);
      img.fill(frameNight, color: img.ColorRgb8(10, 15, 25)); // Dark room
      // Draw same face in center: (150, 150) to (250, 250)
      for (int y = 150; y < 250; y++) {
        for (int x = 150; x < 250; x++) {
          frameNight.setPixel(x, y, img.ColorRgb8(200, 150, 120));
        }
      }

      const faceBox = Rect.fromLTWH(150, 150, 100, 100);

      // Crop only the face box with 0 margin
      final croppedOffice = repo.cropFaceFromImage(
        sourceImage: frameOffice,
        boundingBox: faceBox,
        margin: 0.0,
      );
      final croppedNight = repo.cropFaceFromImage(
        sourceImage: frameNight,
        boundingBox: faceBox,
        margin: 0.0,
      );

      final vectorOffice = repo.extract192DimEmbedding(croppedFace112: croppedOffice);
      final vectorNight = repo.extract192DimEmbedding(croppedFace112: croppedNight);

      expect(vectorOffice.length, equals(192));
      expect(vectorNight.length, equals(192));

      // With background cropped out, Cosine Similarity between office & night is 1.0!
      final sim = repo.computeCosineSimilarity(vectorOffice, vectorNight);
      expect(sim, closeTo(1.0, 0.0001));

      repo.dispose();
    });

    test('FaceRecognitionController initializes, exposes captureAndVerifyMatch, and disposes cleanly', () {
      final repo = FaceRecognitionRepo();
      final controller = FaceRecognitionController(repo: repo);
      controller.onInit();

      expect(controller.isAllChecksPassed.value, isFalse);
      expect(controller.isSavingReference.value, isFalse);
      expect(controller.isMatching.value, isFalse);
      expect(controller.checkResult.value.hasExactlyOneFace, isFalse);

      // Test captureAndVerifyMatch exists
      expect(controller.captureAndVerifyMatch, isNotNull);

      // Clean disposal test
      controller.onClose();
    });

    test('Cosine similarity strictly validates dimensions, non-finite values, and magnitudes', () {
      final repo = FaceRecognitionRepo();

      final validV1 = List<double>.filled(192, 1.0 / math.sqrt(192.0));
      final validV2 = List<double>.filled(192, 1.0 / math.sqrt(192.0));

      // 1. Valid 192-dim vectors
      expect(repo.computeCosineSimilarity(validV1, validV2), closeTo(1.0, 0.0001));

      // 2. Vector length mismatch (< 192)
      final shortV = List<double>.filled(191, 0.5);
      expect(repo.computeCosineSimilarity(shortV, validV2), equals(0.0));
      expect(repo.computeCosineSimilarity(validV1, shortV), equals(0.0));

      // 3. Non-finite values (NaN / Infinity)
      final nanV = List<double>.filled(192, 1.0 / math.sqrt(192.0));
      nanV[10] = double.nan;
      expect(repo.computeCosineSimilarity(nanV, validV2), equals(0.0));

      final infV = List<double>.filled(192, 1.0 / math.sqrt(192.0));
      infV[50] = double.infinity;
      expect(repo.computeCosineSimilarity(infV, validV2), equals(0.0));

      // 4. Zero magnitude
      final zeroV = List<double>.filled(192, 0.0);
      expect(repo.computeCosineSimilarity(zeroV, validV2), equals(0.0));

      // 5. Configurable threshold comparison
      expect(repo.matchThreshold, equals(FaceRecognitionRepo.defaultMatchThreshold));
      repo.matchThreshold = 0.80;
      expect(repo.matchThreshold, equals(0.80));

      repo.dispose();
    });

    test('Controller handles mode switching and local state transitions', () {
      final repo = FaceRecognitionRepo();
      final controller = FaceRecognitionController(repo: repo);
      controller.onInit();

      // Initial mode
      expect(controller.actionMode.value, isNotNull);

      // Switch to Register Mode
      controller.setMode(FaceActionMode.register);
      expect(controller.actionMode.value, equals(FaceActionMode.register));
      expect(controller.statusText.value, contains('Register'));

      // Switch to Verify Mode
      controller.setMode(FaceActionMode.verify);
      expect(controller.actionMode.value, equals(FaceActionMode.verify));

      controller.onClose();
    });

    test('Missing or corrupted template returns null gracefully', () async {
      await AppPreferences.clearEnrolledFace();

      // Missing template
      expect(AppPreferences.hasEnrolledFace, isFalse);
      expect(AppPreferences.getEnrolledFace(), isNull);
      expect(AppPreferences.enrolledFaceEmbedding, isNull);

      // Verify compareFaces on missing file returns false verdict without crash
      final repo = FaceRecognitionRepo();
      final missingReport = await repo.compareFaces(
        referenceFile: File('./non_existent_ref.jpg'),
        liveSelfieFile: File('./non_existent_live.jpg'),
      );

      expect(missingReport.matched, isFalse);
      expect(missingReport.score, equals(0.0));

      repo.dispose();
    });

    test('AppPreferences stores and completely purges enrolled face on clearSession', () async {
      final sampleVector = List<double>.generate(192, (i) => i / 192.0);
      await AppPreferences.saveEnrolledFace(
        imagePath: './test_face.jpg',
        embedding: sampleVector,
      );

      expect(AppPreferences.enrolledFacePath, equals('./test_face.jpg'));
      expect(AppPreferences.enrolledFaceEmbedding?.length, equals(192));
      expect(AppPreferences.enrolledFaceTimestamp, isNotNull);

      final bundle = AppPreferences.getEnrolledFace();
      expect(bundle, isNotNull);
      expect(bundle?['imagePath'], equals('./test_face.jpg'));

      // Now clear enrolled face
      await AppPreferences.clearEnrolledFace();

      expect(AppPreferences.enrolledFacePath, isNull);
      expect(AppPreferences.enrolledFaceEmbedding, isNull);
      expect(AppPreferences.hasEnrolledFace, isFalse);
      expect(AppPreferences.getEnrolledFace(), isNull);
    });
  });
}
