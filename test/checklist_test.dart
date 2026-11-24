import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ams_2/app/api/app_preferences.dart';
import 'package:ams_2/app/core/services/permission_service.dart';
import 'package:ams_2/app/screens/checklists/model/checklist_model.dart';
import 'package:ams_2/app/screens/checklists/repo/checklist_repo.dart';
import 'package:ams_2/app/screens/checklists/controller/checklist_controller.dart';

class MockChecklistRepo extends ChecklistRepo {
  final List<ChecklistModel>? mockResponse;
  final bool shouldThrow;

  MockChecklistRepo({this.mockResponse, this.shouldThrow = false});

  @override
  Future<List<ChecklistModel>?> fetchChecklists() async {
    if (shouldThrow) {
      return null;
    }
    return mockResponse ?? [];
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

  group('ChecklistModel & Task Model JSON Deserialization', () {
    test('correctly parses full ChecklistModel and tasks', () {
      final json = {
        'id': '01m7chk1234567890abcdefghi',
        'name': 'New Joiner Onboarding Checklist',
        'kind': 'onboarding',
        'kind_label': 'Onboarding',
        'status': 'open',
        'status_label': 'In Progress',
        'anchor_on': '2026-11-20',
        'anchor_label': 'Joining date',
        'employee': {
          'id': '01m7emp1234567890abcdefghi',
          'name': 'Rashid Mahmood',
        },
        'progress': {
          'done': 2,
          'total': 4,
        },
        'tasks': [
          {
            'id': '01m7tsk1',
            'title': 'Sign Employment Contract',
            'priority': 'high',
            'priority_label': 'High',
            'due_on': '2026-11-21',
            'is_overdue': false,
            'status': 'finished',
            'status_label': 'Completed',
            'completed_at': '2026-11-19T10:00:00Z',
          },
          {
            'id': '01m7tsk2',
            'title': 'IT Hardware Handover',
            'priority': 'normal',
            'priority_label': 'Normal',
            'due_on': '2026-11-22',
            'is_overdue': false,
            'status': 'open',
            'status_label': 'To do',
            'assignee': {
              'id': '01m7itadmin',
              'name': 'IT Support Team',
            },
          },
        ],
      };

      final checklist = ChecklistModel.fromJson(json);

      expect(checklist.id, '01m7chk1234567890abcdefghi');
      expect(checklist.name, 'New Joiner Onboarding Checklist');
      expect(checklist.kind, 'onboarding');
      expect(checklist.isOnboarding, isTrue);
      expect(checklist.isOffboarding, isFalse);
      expect(checklist.isOpen, isTrue);
      expect(checklist.isCompleted, isFalse);
      expect(checklist.progress.done, 2);
      expect(checklist.progress.total, 4);
      expect(checklist.progress.ratio, 0.5);
      expect(checklist.progress.percentage, 50);
      expect(checklist.tasks.length, 2);

      // Task 1
      expect(checklist.tasks[0].id, '01m7tsk1');
      expect(checklist.tasks[0].isCompleted, isTrue);
      expect(checklist.tasks[0].isOpen, isFalse);

      // Task 2
      expect(checklist.tasks[1].id, '01m7tsk2');
      expect(checklist.tasks[1].isCompleted, isFalse);
      expect(checklist.tasks[1].isOpen, isTrue);
      expect(checklist.tasks[1].assigneeName, 'IT Support Team');
    });

    test('handles empty payload gracefully with default fallbacks without crashing', () {
      final checklist = ChecklistModel.fromJson({});
      expect(checklist.id, '');
      expect(checklist.name, 'Checklist');
      expect(checklist.kind, 'onboarding');
      expect(checklist.progress.total, 0);
      expect(checklist.progress.ratio, 0.0);
      expect(checklist.progress.percentage, 0);
      expect(checklist.tasks, isEmpty);
    });
  });

  group('ChecklistController Filtering & Telemetry', () {
    late ChecklistController controller;

    setUp(() async {
      Get.reset();
      await AppPreferences.setPermissions({
        AppPermissions.onboardingManage: ['department'],
      });
    });

    tearDown(() {
      Get.reset();
    });

    test('telemetry counts and filters compute accurately', () async {
      final mockData = [
        const ChecklistModel(
          id: '1',
          name: 'Onboarding 1',
          kind: 'onboarding',
          status: 'open',
          progress: ChecklistProgressModel(done: 1, total: 3),
        ),
        const ChecklistModel(
          id: '2',
          name: 'Offboarding 1',
          kind: 'offboarding',
          status: 'open',
          progress: ChecklistProgressModel(done: 0, total: 2),
        ),
        const ChecklistModel(
          id: '3',
          name: 'Completed Onboarding',
          kind: 'onboarding',
          status: 'completed',
          progress: ChecklistProgressModel(done: 5, total: 5),
        ),
      ];

      final repo = MockChecklistRepo(mockResponse: mockData);
      controller = ChecklistController(repo: repo);
      await controller.loadChecklists();

      expect(controller.totalCount, 3);
      expect(controller.onboardingCount, 2);
      expect(controller.offboardingCount, 1);
      expect(controller.completedCount, 1);

      // Filter: all
      controller.selectedFilter.value = 'all';
      expect(controller.filteredChecklists.length, 3);

      // Filter: onboarding
      controller.selectedFilter.value = 'onboarding';
      expect(controller.filteredChecklists.length, 2);
      expect(controller.filteredChecklists.every((c) => c.isOnboarding), isTrue);

      // Filter: offboarding
      controller.selectedFilter.value = 'offboarding';
      expect(controller.filteredChecklists.length, 1);
      expect(controller.filteredChecklists.first.id, '2');

      // Filter: completed
      controller.selectedFilter.value = 'completed';
      expect(controller.filteredChecklists.length, 1);
      expect(controller.filteredChecklists.first.id, '3');
    });

    test('maintains zero fallback / clean empty state when server returns empty', () async {
      final repo = MockChecklistRepo(mockResponse: []);
      controller = ChecklistController(repo: repo);
      await controller.loadChecklists();

      expect(controller.checklists, isEmpty);
      expect(controller.totalCount, 0);
      expect(controller.filteredChecklists, isEmpty);
    });

    test('initializes and disposes ScrollController properly', () {
      final repo = MockChecklistRepo(mockResponse: []);
      controller = ChecklistController(repo: repo);
      controller.onInit();

      expect(controller.scrollOffset.value, 0.0);
      expect(controller.scrollController.hasClients, isFalse);

      controller.onClose();
    });
  });
}
