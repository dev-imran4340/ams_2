import 'dart:async';

import '../../../api/exception_handler.dart';
import '../model/task_model.dart';

class TaskRepo {
  final String _tag = 'TaskRepo / TaskScreen';

  // In-memory mock task store simulating backend database
  final List<TaskModel> _mockTasks = [
    TaskModel(
      id: 'TSK-101',
      title: 'Refactor Face Recognition Stream',
      description:
          'Integrate AVFoundation camera preview with dynamic oval cutout and real-time 3D anti-spoofing telemetry.',
      priority: 'Urgent',
      status: 'In Progress',
      dueDate: DateTime.now().add(const Duration(hours: 18)),
      projectTag: 'AMS 2 Mobile',
      isCompleted: false,
    ),
    TaskModel(
      id: 'TSK-102',
      title: 'Audit Weekly Attendance Regularizations',
      description:
          'Cross-examine geo-fence check-in logs and overtime claims for Engineering & Product department staff.',
      priority: 'High',
      status: 'To Do',
      dueDate: DateTime.now().add(const Duration(days: 1)),
      projectTag: 'HR Operations',
      isCompleted: false,
    ),
    TaskModel(
      id: 'TSK-103',
      title: 'Implement Offline SQLite Punch Sync',
      description:
          'Store attendance punches locally when connectivity drops and auto-sync with exponential backoff.',
      priority: 'High',
      status: 'To Do',
      dueDate: DateTime.now().add(const Duration(days: 2)),
      projectTag: 'Core Engine',
      isCompleted: false,
    ),
    TaskModel(
      id: 'TSK-104',
      title: 'Review Overtime Claims for SFT-094',
      description:
          'Verify weekend shift supervisor approval receipts and calculate billable overtime rates.',
      priority: 'Medium',
      status: 'In Progress',
      dueDate: DateTime.now().add(const Duration(days: 3)),
      projectTag: 'Finance & Payroll',
      isCompleted: false,
    ),
    TaskModel(
      id: 'TSK-105',
      title: 'Update Biometric Encryption Handshake',
      description:
          'Rotate cryptographic public key for QR badge token signature validation.',
      priority: 'Urgent',
      status: 'Completed',
      dueDate: DateTime.now().subtract(const Duration(hours: 6)),
      projectTag: 'Security & Auth',
      isCompleted: true,
    ),
    TaskModel(
      id: 'TSK-106',
      title: 'Verify Monthly Shift Roster Allocation',
      description:
          'Confirm rotating evening shift rosters for customer support and QA engineering teams.',
      priority: 'Low',
      status: 'Completed',
      dueDate: DateTime.now().subtract(const Duration(days: 1)),
      projectTag: 'Operations',
      isCompleted: true,
    ),
  ];

  /// Computes telemetry metrics from task list
  TaskTelemetryModel _computeTelemetry(List<TaskModel> list) {
    int pending = 0;
    int inProgress = 0;
    int completed = 0;

    for (final t in list) {
      if (t.isCompleted || t.status == 'Completed') {
        completed++;
      } else if (t.status == 'In Progress') {
        inProgress++;
      } else {
        pending++;
      }
    }

    return TaskTelemetryModel(
      totalTasks: list.length,
      pendingCount: pending,
      inProgressCount: inProgress,
      completedCount: completed,
    );
  }

  /// Fetches all active tasks and computes telemetry metrics
  Future<({List<TaskModel> tasks, TaskTelemetryModel telemetry})?>
      fetchTasks() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final tasksCopy = List<TaskModel>.from(_mockTasks);
      final telemetry = _computeTelemetry(tasksCopy);

      return (tasks: tasksCopy, telemetry: telemetry);
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to fetch task operations: $e'),
        tag:
            '$_tag -> fetchTasks() [${stackTrace.toString().split('\n').first}]',
      );
      return null;
    }
  }

  /// Creates a new deliverable task and prepends to roster
  Future<TaskModel?> createTask(Map<String, dynamic> body) async {
    try {
      await Future.delayed(const Duration(milliseconds: 600));

      final newTask = TaskModel(
        id: 'TSK-${100 + _mockTasks.length + 1}',
        title: body['title']?.toString() ?? 'New Deliverable',
        description: body['description']?.toString() ?? '',
        priority: body['priority']?.toString() ?? 'Medium',
        status: 'To Do',
        dueDate: body['due_date'] is DateTime
            ? body['due_date'] as DateTime
            : DateTime.now().add(const Duration(days: 1)),
        projectTag: body['project_tag']?.toString() ?? 'AMS 2 Mobile',
        isCompleted: false,
      );

      _mockTasks.insert(0, newTask);
      return newTask;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to create task deliverable: $e'),
        tag:
            '$_tag -> createTask() [${stackTrace.toString().split('\n').first}]',
      );
      return null;
    }
  }

  /// Toggles task completion state
  Future<bool> toggleTaskCompletion(String taskId, bool isDone) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final index = _mockTasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        final existing = _mockTasks[index];
        _mockTasks[index] = existing.copyWith(
          isCompleted: isDone,
          status: isDone ? 'Completed' : 'To Do',
        );
        return true;
      }
      return false;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to toggle task completion: $e'),
        tag:
            '$_tag -> toggleTaskCompletion() [${stackTrace.toString().split('\n').first}]',
      );
      return false;
    }
  }
}
