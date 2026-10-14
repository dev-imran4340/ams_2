import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/widgets/custom_snackbar.dart';
import '../model/task_model.dart';
import '../repo/task_repo.dart';
import '../view/components/create_task_bottom_sheet.dart';

class TaskController extends GetxController {
  final TaskRepo repo;

  TaskController({required this.repo});

  // Observables
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString selectedFilter = 'All'.obs; // 'All', 'To Do', 'In Progress', 'Completed'
  final RxList<TaskModel> tasks = <TaskModel>[].obs;
  final Rxn<TaskTelemetryModel> telemetry = Rxn<TaskTelemetryModel>();

  // Create Form State
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;
  late final FocusNode titleFocusNode;
  late final FocusNode descFocusNode;

  final RxString selectedPriority = 'High'.obs; // 'Urgent', 'High', 'Medium', 'Low'
  final Rxn<DateTime> selectedDueDate = Rxn<DateTime>();
  final RxString selectedProject = 'AMS 2 Mobile'.obs;

  final List<String> availableProjects = [
    'AMS 2 Mobile',
    'HR Operations',
    'Core Engine',
    'Finance & Payroll',
    'Security & Auth',
    'Operations',
  ];

  final List<String> filterTabs = [
    'All',
    'To Do',
    'In Progress',
    'Completed',
  ];

  /// Filtered tasks computed getter
  List<TaskModel> get filteredTasks {
    final filter = selectedFilter.value;
    if (filter == 'All') {
      return tasks;
    } else if (filter == 'Completed') {
      return tasks.where((t) => t.isCompleted || t.status == 'Completed').toList();
    } else if (filter == 'In Progress') {
      return tasks.where((t) => !t.isCompleted && t.status == 'In Progress').toList();
    } else if (filter == 'To Do') {
      return tasks.where((t) => !t.isCompleted && t.status == 'To Do').toList();
    }
    return tasks;
  }

  @override
  void onInit() {
    super.onInit();
    titleController = TextEditingController();
    descriptionController = TextEditingController();
    titleFocusNode = FocusNode();
    descFocusNode = FocusNode();
    selectedDueDate.value = DateTime.now().add(const Duration(days: 2));

    loadTasks();
  }

  @override
  void onClose() {
    // Strict resource disposal contract
    titleController.dispose();
    descriptionController.dispose();
    titleFocusNode.dispose();
    descFocusNode.dispose();
    super.onClose();
  }

  /// Loads tasks and telemetry from repository with try-finally loading standard
  Future<void> loadTasks() async {
    try {
      isLoading.value = true;
      final result = await repo.fetchTasks();
      if (result != null) {
        tasks.assignAll(result.tasks);
        telemetry.value = result.telemetry;
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Changes active status filter tab
  void setFilter(String filter) {
    if (selectedFilter.value == filter) return;
    HapticFeedback.selectionClick();
    selectedFilter.value = filter;
  }

  /// Toggles task completion state
  Future<void> toggleComplete(TaskModel task) async {
    final nextState = !task.isCompleted;
    HapticFeedback.mediumImpact();

    // Optimistic UI update
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      tasks[index] = task.copyWith(
        isCompleted: nextState,
        status: nextState ? 'Completed' : 'To Do',
      );
      _recomputeLocalTelemetry();
    }

    final success = await repo.toggleTaskCompletion(task.id, nextState);
    if (success) {
      if (nextState) {
        CustomSnackbar.showSuccess(
          title: 'Deliverable Completed',
          message: '"${task.title}" marked as completed.',
        );
      }
    } else {
      // Revert if API failed
      if (index != -1) {
        tasks[index] = task;
        _recomputeLocalTelemetry();
      }
    }
  }

  /// Opens bottom sheet for creating a new task
  void openCreateTaskModal(BuildContext context) {
    HapticFeedback.lightImpact();
    titleController.clear();
    descriptionController.clear();
    selectedPriority.value = 'High';
    selectedProject.value = 'AMS 2 Mobile';
    selectedDueDate.value = DateTime.now().add(const Duration(days: 1));

    Get.bottomSheet(
      const CreateTaskBottomSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  /// Submits new deliverable
  Future<void> submitTask() async {
    final title = titleController.text.trim();
    if (title.isEmpty) {
      CustomSnackbar.showError(
        title: 'Title Required',
        message: 'Please enter a title for the deliverable.',
      );
      titleFocusNode.requestFocus();
      return;
    }

    try {
      isSubmitting.value = true;
      HapticFeedback.mediumImpact();

      final body = {
        'title': title,
        'description': descriptionController.text.trim(),
        'priority': selectedPriority.value,
        'project_tag': selectedProject.value,
        'due_date': selectedDueDate.value ?? DateTime.now().add(const Duration(days: 1)),
      };

      final created = await repo.createTask(body);

      if (created != null) {
        tasks.insert(0, created);
        _recomputeLocalTelemetry();
        Get.back(); // Close modal
        HapticFeedback.heavyImpact();

        CustomSnackbar.showSuccess(
          title: 'Deliverable Logged',
          message: '"${created.title}" successfully added to operational roster.',
        );
      }
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Selects due date via DatePicker
  Future<void> pickDueDate(BuildContext context) async {
    HapticFeedback.lightImpact();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDueDate.value ?? now.add(const Duration(days: 1)),
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      selectedDueDate.value = picked;
    }
  }

  void _recomputeLocalTelemetry() {
    int pending = 0;
    int inProgress = 0;
    int completed = 0;

    for (final t in tasks) {
      if (t.isCompleted || t.status == 'Completed') {
        completed++;
      } else if (t.status == 'In Progress') {
        inProgress++;
      } else {
        pending++;
      }
    }

    telemetry.value = TaskTelemetryModel(
      totalTasks: tasks.length,
      pendingCount: pending,
      inProgressCount: inProgress,
      completedCount: completed,
    );
  }
}
