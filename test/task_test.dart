import 'package:ams_2/app/screens/tasks/controller/task_controller.dart';
import 'package:ams_2/app/screens/tasks/model/task_model.dart';
import 'package:ams_2/app/screens/tasks/repo/task_repo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class MockTaskRepo extends TaskRepo {
  final List<TaskModel> mockTaskList = [
    const TaskModel(
      id: '01jb2x9k4m7q8r3t5v6w8y0z1a',
      title: 'Read and accept company policies',
      description: 'Review updated employee handbook version 2.',
      priority: 'normal',
      priorityLabel: 'Normal',
      dueOn: '2026-11-25',
      isOverdue: false,
      status: 'open',
      statusLabel: 'To do',
      assignee: TaskAssigneeModel(id: '01ja', name: 'Ayesha Khan'),
      linked: 'Policies accepted',
    ),
    const TaskModel(
      id: '01jb2x9k4m7q8r3t5v6w8y0z1b',
      title: 'Audit Weekly Attendance',
      description: 'Examine check-in logs and regularization requests.',
      priority: 'high',
      priorityLabel: 'High',
      dueOn: '2026-11-20',
      isOverdue: true,
      status: 'open',
      statusLabel: 'To do',
      assignee: TaskAssigneeModel(id: '01ja', name: 'Ayesha Khan'),
    ),
    const TaskModel(
      id: '01jb2x9k4m7q8r3t5v6w8y0z1c',
      title: 'Submit Biometric Consent',
      description: 'Face recognition baseline consent.',
      priority: 'low',
      priorityLabel: 'Low',
      dueOn: '2026-11-10',
      isOverdue: false,
      status: 'finished',
      statusLabel: 'Finished',
      completedAt: '2026-11-10T12:00:00Z',
      completedBy: 'Ayesha Khan',
    ),
  ];

  @override
  Future<({List<TaskModel> tasks, TaskTelemetryModel telemetry, int total, int page, int lastPage})?>
      fetchTasks({
    String list = 'mine',
    String status = 'open',
    String? due,
    int page = 1,
    int perPage = 25,
  }) async {
    List<TaskModel> filtered = mockTaskList.where((t) {
      if (status == 'finished') {
        return t.isCompleted;
      } else {
        if (t.isCompleted) return false;
        if (due == 'overdue') return t.isOverdue;
        return true;
      }
    }).toList();

    int openCount = 0;
    int completedCount = 0;
    int overdueCount = 0;

    for (final t in filtered) {
      if (t.isCompleted) {
        completedCount++;
      } else {
        openCount++;
        if (t.isOverdue) overdueCount++;
      }
    }

    final telemetry = TaskTelemetryModel(
      totalTasks: filtered.length,
      pendingCount: openCount,
      inProgressCount: overdueCount,
      completedCount: completedCount,
    );

    return (
      tasks: filtered,
      telemetry: telemetry,
      total: filtered.length,
      page: 1,
      lastPage: 1,
    );
  }

  @override
  Future<TaskModel?> fetchTaskDetails(String id) async {
    final task = mockTaskList.firstWhere((t) => t.id == id);
    return task.copyWith(
      comments: [
        const TaskCommentModel(
          id: '01jc',
          body: 'Started reviewing section 3.',
          createdAt: '2026-11-19 10:00',
        ),
      ],
    );
  }

  @override
  Future<bool> toggleTaskCompletion(String taskId, bool isDone, {String? note}) async {
    return true;
  }

  @override
  Future<bool> postComment(String taskId, {required String body, dynamic files}) async {
    return true;
  }

  @override
  Future<TaskModel?> createTask({
    required String title,
    String? description,
    String priority = 'normal',
    String? dueOn,
    List<String>? assignees,
    String? about,
    dynamic files,
  }) async {
    String normalizedPriority = 'normal';
    final p = priority.toLowerCase();
    if (p == 'urgent' || p == 'high') {
      normalizedPriority = 'high';
    } else if (p == 'low') {
      normalizedPriority = 'low';
    } else {
      normalizedPriority = 'normal';
    }

    return TaskModel(
      id: '01creatednewtask',
      title: title,
      description: description ?? '',
      priority: normalizedPriority,
      priorityLabel: normalizedPriority.capitalizeFirst ?? normalizedPriority,
      dueOn: dueOn,
      status: 'open',
      statusLabel: 'To do',
      assignee: const TaskAssigneeModel(id: '01ja', name: 'Self'),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 18 TaskModel & Schema Tests', () {
    test('TaskModel serializes and deserializes live API JSON correctly', () {
      final json = {
        'id': '01jb2x9k4m7q8r3t5v6w8y0z1a',
        'title': 'Read and accept the company policies',
        'priority': 'normal',
        'priority_label': 'Normal',
        'due_on': '2026-11-05',
        'is_overdue': false,
        'status': 'open',
        'status_label': 'To do',
        'assignee': {'id': '01ja', 'name': 'Ayesha Khan'},
        'about': {'id': '01ja', 'name': 'Ayesha Khan'},
        'checklist': {'id': '01jc', 'name': 'New joiner'},
        'linked': 'Policies accepted',
        'completed_at': null,
      };

      final task = TaskModel.fromJson(json);

      expect(task.id, '01jb2x9k4m7q8r3t5v6w8y0z1a');
      expect(task.title, 'Read and accept the company policies');
      expect(task.priority, 'normal');
      expect(task.priorityLabel, 'Normal');
      expect(task.dueOn, '2026-11-05');
      expect(task.isOverdue, false);
      expect(task.status, 'open');
      expect(task.statusLabel, 'To do');
      expect(task.isCompleted, false);
      expect(task.assignee?.name, 'Ayesha Khan');
      expect(task.checklist?.name, 'New joiner');
      expect(task.projectTag, 'New joiner');
      expect(task.linked, 'Policies accepted');
    });

    test('TaskModel copyWith updates completion state correctly', () {
      const task = TaskModel(
        id: '01jb2x',
        title: 'Complete Training',
        status: 'open',
        statusLabel: 'To do',
      );

      final updated = task.copyWith(
        isCompleted: true,
      );

      expect(updated.id, '01jb2x');
      expect(updated.isCompleted, true);
      expect(updated.status, 'finished');
      expect(updated.statusLabel, 'Finished');
    });

    test('TaskTelemetryModel parses from JSON correctly', () {
      final json = {
        'total_tasks': 15,
        'pending_count': 7,
        'in_progress_count': 2,
        'completed_count': 6,
      };

      final telemetry = TaskTelemetryModel.fromJson(json);
      expect(telemetry.totalTasks, 15);
      expect(telemetry.pendingCount, 7);
      expect(telemetry.inProgressCount, 2);
      expect(telemetry.completedCount, 6);
    });
  });

  group('TaskController Logic & Live Filter Tests', () {
    late MockTaskRepo mockRepo;
    late TaskController controller;

    setUp(() {
      Get.testMode = true;
      mockRepo = MockTaskRepo();
      controller = TaskController(repo: mockRepo);
    });

    tearDown(() {
      controller.onClose();
      Get.reset();
    });

    test('Loads open tasks by default with telemetry', () async {
      await controller.loadTasks();

      expect(controller.tasks.length, 2); // 2 open tasks
      expect(controller.telemetry.value, isNotNull);
      expect(controller.telemetry.value!.pendingCount, 2);
      expect(controller.isLoading.value, false);
    });

    test('Switches filter tab to Completed', () async {
      controller.setFilter('Completed');
      expect(controller.selectedFilter.value, 'Completed');

      await controller.loadTasks();
      expect(controller.tasks.length, 1);
      expect(controller.tasks.first.isCompleted, true);
    });

    test('Switches filter tab to Overdue', () async {
      controller.setFilter('Overdue');
      expect(controller.selectedFilter.value, 'Overdue');

      await controller.loadTasks();
      expect(controller.tasks.length, 1);
      expect(controller.tasks.first.isOverdue, true);
    });

    test('Switches scope to Given and Team', () {
      controller.setScope('given');
      expect(controller.selectedScope.value, 'given');

      controller.setScope('team');
      expect(controller.selectedScope.value, 'team');
    });

    test('Toggles task completion state optimistically', () async {
      await controller.loadTasks();
      final openTask = controller.tasks.firstWhere((t) => !t.isCompleted);

      await controller.toggleComplete(openTask);

      final toggled = controller.tasks.firstWhere((t) => t.id == openTask.id);
      expect(toggled.isCompleted, true);
      expect(toggled.status, 'finished');
    });

    test('submitTask halts cleanly when formKey is not validated', () async {
      // Empty title without formKey attachment should reject and not submit
      controller.titleController.text = '';
      await controller.submitTask();

      expect(controller.isSubmitting.value, false);
      expect(controller.tasks.any((t) => t.id == '01creatednewtask'), false);
    });
  });
}
