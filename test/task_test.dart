import 'package:ams_2/app/screens/tasks/controller/task_controller.dart';
import 'package:ams_2/app/screens/tasks/model/task_model.dart';
import 'package:ams_2/app/screens/tasks/repo/task_repo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TaskModel & TaskTelemetryModel Tests', () {
    test('TaskModel serializes and deserializes correctly', () {
      final dueDate = DateTime(2026, 10, 16, 18, 0);
      final model = TaskModel(
        id: 'TSK-101',
        title: 'Refactor Face Recognition Stream',
        description: 'Anti-spoofing telemetry integration',
        priority: 'Urgent',
        status: 'In Progress',
        dueDate: dueDate,
        projectTag: 'AMS 2 Mobile',
        isCompleted: false,
      );

      final json = model.toJson();
      expect(json['id'], 'TSK-101');
      expect(json['title'], 'Refactor Face Recognition Stream');
      expect(json['priority'], 'Urgent');
      expect(json['status'], 'In Progress');
      expect(json['project_tag'], 'AMS 2 Mobile');
      expect(json['is_completed'], false);

      final parsed = TaskModel.fromJson(json);
      expect(parsed.id, model.id);
      expect(parsed.title, model.title);
      expect(parsed.priority, model.priority);
      expect(parsed.status, model.status);
      expect(parsed.dueDate.year, 2026);
      expect(parsed.isCompleted, false);
    });

    test('TaskModel copyWith updates state accurately', () {
      final task = TaskModel(
        id: 'TSK-102',
        title: 'Audit Logs',
        description: 'Audit logs',
        priority: 'High',
        status: 'To Do',
        dueDate: DateTime.now(),
        projectTag: 'HR Operations',
        isCompleted: false,
      );

      final updated = task.copyWith(
        isCompleted: true,
        status: 'Completed',
      );

      expect(updated.id, 'TSK-102');
      expect(updated.isCompleted, true);
      expect(updated.status, 'Completed');
      expect(task.isCompleted, false);
    });

    test('TaskTelemetryModel parses from JSON correctly', () {
      final json = {
        'total_tasks': 12,
        'pending_count': 4,
        'in_progress_count': 5,
        'completed_count': 3,
      };

      final telemetry = TaskTelemetryModel.fromJson(json);
      expect(telemetry.totalTasks, 12);
      expect(telemetry.pendingCount, 4);
      expect(telemetry.inProgressCount, 5);
      expect(telemetry.completedCount, 3);

      final out = telemetry.toJson();
      expect(out['total_tasks'], 12);
      expect(out['completed_count'], 3);
    });
  });

  group('TaskRepo Tests', () {
    late TaskRepo repo;

    setUp(() {
      repo = TaskRepo();
    });

    test('fetchTasks returns list of tasks and telemetry', () async {
      final result = await repo.fetchTasks();
      expect(result, isNotNull);
      expect(result!.tasks.isNotEmpty, true);
      expect(result.telemetry.totalTasks, result.tasks.length);
      expect(result.telemetry.completedCount >= 1, true);
    });

    test('createTask inserts new task deliverable', () async {
      final body = {
        'title': 'Unit Test Deliverable',
        'description': 'Testing repository creation',
        'priority': 'Urgent',
        'project_tag': 'Core Engine',
        'due_date': DateTime.now().add(const Duration(days: 1)),
      };

      final created = await repo.createTask(body);
      expect(created, isNotNull);
      expect(created!.title, 'Unit Test Deliverable');
      expect(created.priority, 'Urgent');
      expect(created.status, 'To Do');
      expect(created.isCompleted, false);

      final fetchResult = await repo.fetchTasks();
      expect(fetchResult!.tasks.first.title, 'Unit Test Deliverable');
    });

    test('toggleTaskCompletion toggles task state', () async {
      final success = await repo.toggleTaskCompletion('TSK-101', true);
      expect(success, true);

      final fetchResult = await repo.fetchTasks();
      final toggled = fetchResult!.tasks.firstWhere((t) => t.id == 'TSK-101');
      expect(toggled.isCompleted, true);
      expect(toggled.status, 'Completed');
    });
  });

  group('TaskController Logic Tests', () {
    late TaskRepo repo;
    late TaskController controller;

    setUp(() {
      repo = TaskRepo();
      controller = TaskController(repo: repo);
      controller.onInit();
    });

    tearDown(() {
      controller.onClose();
    });

    test('loadTasks populates tasks and telemetry', () async {
      await controller.loadTasks();

      expect(controller.tasks.isNotEmpty, true);
      expect(controller.telemetry.value, isNotNull);
      expect(controller.isLoading.value, false);
    });

    test('filterTabs filters deliverables correctly', () async {
      await controller.loadTasks();

      controller.setFilter('All');
      expect(controller.filteredTasks.length, controller.tasks.length);

      controller.setFilter('Completed');
      for (final t in controller.filteredTasks) {
        expect(t.isCompleted || t.status == 'Completed', true);
      }

      controller.setFilter('In Progress');
      for (final t in controller.filteredTasks) {
        expect(!t.isCompleted && t.status == 'In Progress', true);
      }

      controller.setFilter('To Do');
      for (final t in controller.filteredTasks) {
        expect(!t.isCompleted && t.status == 'To Do', true);
      }
    });

    test('toggleComplete updates task state optimistically', () async {
      await controller.loadTasks();
      final initialTask = controller.tasks.firstWhere((t) => !t.isCompleted);

      await controller.toggleComplete(initialTask);

      final updatedTask =
          controller.tasks.firstWhere((t) => t.id == initialTask.id);
      expect(updatedTask.isCompleted, true);
      expect(updatedTask.status, 'Completed');
    });
  });
}
