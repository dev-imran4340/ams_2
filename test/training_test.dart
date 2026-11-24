import 'package:ams_2/app/api/app_preferences.dart';
import 'package:ams_2/app/core/services/permission_service.dart';
import 'package:ams_2/app/screens/training/controller/training_controller.dart';
import 'package:ams_2/app/screens/training/model/training_model.dart';
import 'package:ams_2/app/screens/training/repo/training_repo.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class MockTrainingRepo extends TrainingRepo {
  final TrainingDataModel mockData = const TrainingDataModel(
    required: [
      TrainingRequiredModel(
        course: TrainingCourseModel(
          id: '01req1',
          name: 'Fire Safety & Evacuation',
          provider: 'Civil Defense Academy',
          description: 'Mandatory fire warden and workplace safety protocols.',
          validityMonths: 12,
          isRequired: true,
          isActive: true,
        ),
        valid: true,
      ),
      TrainingRequiredModel(
        course: TrainingCourseModel(
          id: '01req2',
          name: 'Information Security & GDPR',
          provider: 'InfoSec Compliance Ltd',
          description: 'Data protection and cyber hygiene standard.',
          validityMonths: 6,
          isRequired: true,
          isActive: true,
        ),
        valid: false,
      ),
    ],
    records: [
      TrainingRecordModel(
        id: '01rec1',
        employeeId: '01emp1',
        employeeName: 'Ayesha Khan',
        course: TrainingCourseModel(
          id: '01req1',
          name: 'Fire Safety & Evacuation',
          provider: 'Civil Defense Academy',
          validityMonths: 12,
        ),
        trainer: 'Capt. Tariq',
        startedOn: '2026-05-10',
        completedOn: '2026-05-12',
        durationMinutes: 240,
        result: 'passed',
        resultLabel: 'Passed',
        expiresOn: '2027-05-12',
        isValid: true,
        certificateUrl: 'https://cdn.example.com/certs/fs-001.pdf',
      ),
      TrainingRecordModel(
        id: '01rec2',
        employeeId: '01emp1',
        employeeName: 'Ayesha Khan',
        course: TrainingCourseModel(
          id: '01recCourse2',
          name: 'Executive Leadership Seminar',
          provider: 'Global Management Institute',
          validityMonths: 24,
        ),
        trainer: 'Dr. Bilal',
        startedOn: '2026-08-01',
        completedOn: '2026-08-03',
        durationMinutes: 360,
        result: 'attended',
        resultLabel: 'Attended',
        isValid: true,
      ),
      TrainingRecordModel(
        id: '01rec3',
        employeeId: '01emp1',
        employeeName: 'Ayesha Khan',
        course: TrainingCourseModel(
          id: '01recCourse3',
          name: 'Advanced Flutter & Dart Architecture',
          provider: 'Google Developer Group',
          validityMonths: 12,
        ),
        trainer: 'Alex Rivers',
        startedOn: '2026-09-10',
        completedOn: '2026-09-11',
        durationMinutes: 180,
        result: 'failed',
        resultLabel: 'Failed',
        isValid: false,
      ),
    ],
  );

  @override
  Future<TrainingDataModel?> fetchTraining() async {
    return mockData;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    const MethodChannel channel =
        MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return '.';
    });
    await GetStorage.init();
  });

  group('Phase 18 (Part 3) Training Model & Schema Tests', () {
    test('TrainingDataModel parses live API structure correctly', () {
      final json = {
        'required': [
          {
            'course': {
              'id': '01req1',
              'name': 'Fire Safety & Evacuation',
              'provider': 'Civil Defense Academy',
              'description': 'Mandatory fire warden protocols.',
              'validity_months': 12,
              'is_required': true,
              'is_active': true,
            },
            'valid': true,
          }
        ],
        'records': [
          {
            'id': '01rec1',
            'employee': {'id': '01emp1', 'name': 'Ayesha Khan'},
            'course': {
              'id': '01req1',
              'name': 'Fire Safety & Evacuation',
              'provider': 'Civil Defense Academy',
            },
            'trainer': 'Capt. Tariq',
            'started_on': '2026-05-10',
            'completed_on': '2026-05-12',
            'duration_minutes': 240,
            'result': 'passed',
            'result_label': 'Passed',
            'expires_on': '2027-05-12',
            'is_valid': true,
            'certificate_url': 'https://cdn.example.com/certs/fs-001.pdf',
          }
        ],
      };

      final data = TrainingDataModel.fromJson(json);

      expect(data.required.length, 1);
      expect(data.required.first.course.name, 'Fire Safety & Evacuation');
      expect(data.required.first.valid, true);

      expect(data.records.length, 1);
      final rec = data.records.first;
      expect(rec.id, '01rec1');
      expect(rec.trainer, 'Capt. Tariq');
      expect(rec.result, 'passed');
      expect(rec.isPassed, true);
      expect(rec.hasCertificate, true);
    });
  });

  group('TrainingController Lifecycle & Filtering Tests', () {
    late MockTrainingRepo mockRepo;
    late TrainingController controller;

    setUp(() async {
      Get.testMode = true;
      await AppPreferences.setPermissions({
        AppPermissions.trainingView: ['own'],
      });
      mockRepo = MockTrainingRepo();
      controller = TrainingController(repo: mockRepo);
    });

    tearDown(() {
      controller.onClose();
      Get.reset();
    });

    test('Loads training data and computes telemetry correctly', () async {
      await controller.loadTraining();

      expect(controller.totalRequired, 2);
      expect(controller.validCompliantCount, 1);
      expect(controller.pendingRequiredCount, 1);
      expect(controller.totalRecordsCount, 3);
      expect(controller.passedCount, 1);
      expect(controller.isLoading.value, false);
    });

    test('Switches view tabs between Required and Records', () {
      expect(controller.selectedViewTab.value, 'Required');
      expect(controller.selectedTelemetryId.value, 'required');

      controller.setViewTab('Records');
      expect(controller.selectedViewTab.value, 'Records');
      expect(controller.selectedTelemetryId.value, 'records');

      controller.setViewTab('Required');
      expect(controller.selectedViewTab.value, 'Required');
      expect(controller.selectedTelemetryId.value, 'required');
    });

    test('Telemetry item selection isolates single active state and filters courses', () async {
      await controller.loadTraining();

      // Default: 'required' shows all 2
      expect(controller.selectedTelemetryId.value, 'required');
      expect(controller.filteredRequiredCourses.length, 2);

      // Select 'compliant': only compliant (1)
      controller.selectTelemetry('compliant');
      expect(controller.selectedTelemetryId.value, 'compliant');
      expect(controller.selectedViewTab.value, 'Required');
      expect(controller.filteredRequiredCourses.length, 1);
      expect(controller.filteredRequiredCourses.first.valid, true);

      // Select 'pending': only non-compliant (1)
      controller.selectTelemetry('pending');
      expect(controller.selectedTelemetryId.value, 'pending');
      expect(controller.selectedViewTab.value, 'Required');
      expect(controller.filteredRequiredCourses.length, 1);
      expect(controller.filteredRequiredCourses.first.valid, false);

      // Select 'records': switches view tab to 'Records'
      controller.selectTelemetry('records');
      expect(controller.selectedTelemetryId.value, 'records');
      expect(controller.selectedViewTab.value, 'Records');
    });

    test('Filters completed records by result status', () async {
      await controller.loadTraining();

      // All
      controller.setRecordFilter('All');
      expect(controller.filteredRecords.length, 3);

      // Passed
      controller.setRecordFilter('Passed');
      expect(controller.filteredRecords.length, 1);
      expect(controller.filteredRecords.first.result, 'passed');

      // Attended
      controller.setRecordFilter('Attended');
      expect(controller.filteredRecords.length, 1);
      expect(controller.filteredRecords.first.result, 'attended');

      // Failed
      controller.setRecordFilter('Failed');
      expect(controller.filteredRecords.length, 1);
      expect(controller.filteredRecords.first.result, 'failed');
    });
  });
}
