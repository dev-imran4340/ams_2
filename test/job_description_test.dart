import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ams_2/app/screens/job_description/model/job_description_model.dart';
import 'package:ams_2/app/screens/job_description/repo/job_description_repo.dart';
import 'package:ams_2/app/screens/job_description/controller/job_description_controller.dart';

class MockJobDescriptionRepo extends JobDescriptionRepo {
  final JobDescriptionModel? mockData;
  final bool shouldThrow;

  MockJobDescriptionRepo({this.mockData, this.shouldThrow = false});

  @override
  Future<JobDescriptionModel?> fetchJobDescription() async {
    if (shouldThrow) {
      throw Exception('Simulated Network Error');
    }
    return mockData;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('JobDescriptionModel Tests', () {
    test('Correctly deserializes valid JSON envelope', () {
      final json = {
        'designation': 'Principal Software Engineer',
        'version': '2.1',
        'body': '<h3>Key Responsibilities</h3><p>Architecture design and code reviews.</p>',
        'file_url': 'https://ams-hrpayroll.com/documents/jd_principal_eng.pdf',
        'updated_at': '2026-10-15T10:00:00Z',
      };

      final model = JobDescriptionModel.fromJson(json);

      expect(model.designation, 'Principal Software Engineer');
      expect(model.version, '2.1');
      expect(model.body, contains('Key Responsibilities'));
      expect(model.fileUrl, contains('.pdf'));
      expect(model.updatedAt, '2026-10-15T10:00:00Z');
    });

    test('Handles null fields gracefully', () {
      final json = <String, dynamic>{};
      final model = JobDescriptionModel.fromJson(json);

      expect(model.designation, isNull);
      expect(model.version, isNull);
      expect(model.body, isNull);
      expect(model.fileUrl, isNull);
      expect(model.updatedAt, isNull);
    });
  });

  group('JobDescriptionController Tests', () {
    tearDown(() {
      Get.reset();
    });

    test('Loads job description successfully', () async {
      final mockData = JobDescriptionModel(
        designation: 'Senior Mobile Engineer',
        version: '1.0',
        body: '<p>Lead mobile development in Flutter.</p>',
        fileUrl: 'https://example.com/jd.pdf',
        updatedAt: '2026-11-01',
      );

      final repo = MockJobDescriptionRepo(mockData: mockData);
      final controller = JobDescriptionController(repo: repo);

      await controller.loadJobDescription();

      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, isEmpty);
      expect(controller.jobDescription.value, isNotNull);
      expect(controller.jobDescription.value?.designation, 'Senior Mobile Engineer');
    });

    test('Handles null job description (unassigned role) with zero dummy data', () async {
      final repo = MockJobDescriptionRepo(mockData: null);
      final controller = JobDescriptionController(repo: repo);

      await controller.loadJobDescription();

      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, isEmpty);
      expect(controller.jobDescription.value, isNull);
    });

    test('Handles exceptions gracefully and sets error message', () async {
      final repo = MockJobDescriptionRepo(shouldThrow: true);
      final controller = JobDescriptionController(repo: repo);

      await controller.loadJobDescription();

      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, isNotEmpty);
      expect(controller.jobDescription.value, isNull);
    });
  });
}
