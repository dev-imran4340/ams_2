import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../api/app_preferences.dart';
import '../../../core/services/permission_service.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../model/task_model.dart';
import '../repo/task_repo.dart';
import '../view/components/create_task_bottom_sheet.dart';
import '../view/components/task_details_bottom_sheet.dart';

class TaskController extends GetxController {
  final TaskRepo repo;

  TaskController({required this.repo});

  // State Observables
  final RxBool isLoading = false.obs;
  final RxBool isDetailsLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isCommentSubmitting = false.obs;

  /// Server Scope: 'mine' (My Tasks), 'given' (Assigned by Me), 'team' (Team Tasks)
  final RxString selectedScope = 'mine'.obs;

  /// Status & Due Filter: 'All', 'To Do', 'In Progress', 'Overdue', 'Due Today', 'This Week', 'Completed'
  final RxString selectedFilter = 'All'.obs;

  final RxList<TaskModel> tasks = <TaskModel>[].obs;
  final Rxn<TaskModel> selectedTask = Rxn<TaskModel>();
  final Rxn<TaskTelemetryModel> telemetry = Rxn<TaskTelemetryModel>();

  // Pagination metadata
  final RxInt currentPage = 1.obs;
  final RxInt lastPage = 1.obs;
  final RxInt totalTasks = 0.obs;

  // Create Form State & Validation Keys
  final GlobalKey<FormState> createTaskFormKey = GlobalKey<FormState>();
  final ScrollController createModalScrollController = ScrollController();
  final GlobalKey titleFieldKey = GlobalKey();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController commentInputController = TextEditingController();
  final FocusNode titleFocusNode = FocusNode();
  final FocusNode descFocusNode = FocusNode();

  final RxString selectedPriority = 'normal'.obs; // 'low', 'normal', 'high'
  final Rxn<DateTime> selectedDueDate = Rxn<DateTime>();

  /// Team scope is strictly restricted to users with tasks.manage permission (doc/api.md)
  bool get canManageTeamTasks => AppPreferences.hasPermission('tasks.manage');

  List<String> get scopeTabs => [
        'mine',
        'given',
        if (canManageTeamTasks) 'team',
      ];

  final List<String> filterTabs = [
    'All',
    'To Do',
    'Overdue',
    'Due Today',
    'This Week',
    'Completed',
  ];

  /// Filtered tasks list for local reactive filtering if needed
  List<TaskModel> get filteredTasks => tasks;

  @override
  void onInit() {
    super.onInit();
    selectedDueDate.value = DateTime.now().add(const Duration(days: 2));

    loadTasks();
  }

  @override
  void onClose() {
    // Strict resource disposal contract
    titleController.dispose();
    descriptionController.dispose();
    commentInputController.dispose();
    titleFocusNode.dispose();
    descFocusNode.dispose();
    createModalScrollController.dispose();
    super.onClose();
  }

  /// Loads tasks and telemetry from repository with live query parameters
  Future<void> loadTasks({bool isRefresh = false}) async {
    try {
      isLoading.value = true;

      // Map filter tab to backend query parameters
      String status = 'open';
      String? due;

      final currentFilter = selectedFilter.value;
      if (currentFilter == 'Completed') {
        status = 'finished';
      } else if (currentFilter == 'Overdue') {
        status = 'open';
        due = 'overdue';
      } else if (currentFilter == 'Due Today') {
        status = 'open';
        due = 'today';
      } else if (currentFilter == 'This Week') {
        status = 'open';
        due = 'week';
      } else {
        status = 'open';
      }

      final result = await repo.fetchTasks(
        list: selectedScope.value,
        status: status,
        due: due,
        page: isRefresh ? 1 : currentPage.value,
      );

      if (result != null) {
        tasks.assignAll(result.tasks);
        telemetry.value = result.telemetry;
        currentPage.value = result.page;
        lastPage.value = result.lastPage;
        totalTasks.value = result.total;
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Changes active scope ('mine', 'given', 'team') and refreshes roster
  void setScope(String scope) {
    if (selectedScope.value == scope) return;
    HapticFeedback.selectionClick();
    selectedScope.value = scope;
    loadTasks(isRefresh: true);
  }

  /// Changes active status/due filter tab
  void setFilter(String filter) {
    if (selectedFilter.value == filter) return;
    HapticFeedback.selectionClick();
    selectedFilter.value = filter;
    loadTasks(isRefresh: true);
  }

  /// Fetches single task details and presents TaskDetailsBottomSheet
  Future<void> openTaskDetails(TaskModel task) async {
    HapticFeedback.lightImpact();
    selectedTask.value = task;

    // Show modal bottom sheet immediately with available info
    Get.bottomSheet(
      TaskDetailsBottomSheet(initialTask: task),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );

    // Fetch full audit & comments from GET /tasks/{id}
    try {
      isDetailsLoading.value = true;
      final details = await repo.fetchTaskDetails(task.id);
      if (details != null) {
        selectedTask.value = details;

        // Also update in list if present
        final idx = tasks.indexWhere((t) => t.id == task.id);
        if (idx != -1) {
          tasks[idx] = details;
        }
      }
    } finally {
      isDetailsLoading.value = false;
    }
  }

  /// Toggles task completion state with optimistic UI update
  Future<void> toggleComplete(TaskModel task, {bool? isDone, String? note}) async {
    final nextState = isDone ?? !task.isCompleted;
    if (task.isCompleted == nextState) return;
    HapticFeedback.mediumImpact();

    // Optimistic UI update
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      tasks[index] = task.copyWith(
        isCompleted: nextState,
        status: nextState ? 'finished' : 'open',
        statusLabel: nextState ? 'Finished' : 'To do',
      );
      _recomputeLocalTelemetry();
    }

    if (selectedTask.value?.id == task.id) {
      selectedTask.value = selectedTask.value!.copyWith(
        isCompleted: nextState,
        status: nextState ? 'finished' : 'open',
        statusLabel: nextState ? 'Finished' : 'To do',
      );
    }

    final success = await repo.toggleTaskCompletion(task.id, nextState, note: note);

    if (success) {
      if (nextState) {
        CustomSnackbar.showSuccess(
          title: 'Task Finished',
          message: '"${task.title}" marked as completed.',
        );
      } else {
        CustomSnackbar.showInfo(
          message: '"${task.title}" reopened.',
        );
      }
    } else {
      // Revert if API failed
      if (index != -1) {
        tasks[index] = task;
        _recomputeLocalTelemetry();
      }
      if (selectedTask.value?.id == task.id) {
        selectedTask.value = task;
      }
    }
  }

  /// Submits comment reply to task thread
  Future<void> postCommentToTask(String taskId) async {
    final text = commentInputController.text.trim();
    if (text.isEmpty) return;

    try {
      isCommentSubmitting.value = true;
      HapticFeedback.mediumImpact();

      final success = await repo.postComment(taskId, body: text);
      if (success) {
        commentInputController.clear();
        FocusManager.instance.primaryFocus?.unfocus();

        // Refresh task details
        final fresh = await repo.fetchTaskDetails(taskId);
        if (fresh != null) {
          selectedTask.value = fresh;
        }

        CustomSnackbar.showSuccess(
          title: 'Comment Posted',
          message: 'Your reply has been added to the discussion.',
        );
      }
    } finally {
      isCommentSubmitting.value = false;
    }
  }

  /// Opens bottom sheet for creating a new task
  void openCreateTaskModal(BuildContext context) {
    if (!PermissionService.verifyAction(
      AppPermissions.tasksManage,
      actionName: 'create or delegate tasks',
    )) {
      return;
    }
    HapticFeedback.lightImpact();
    titleController.clear();
    descriptionController.clear();
    selectedPriority.value = 'normal';
    selectedDueDate.value = DateTime.now().add(const Duration(days: 1));

    Get.bottomSheet(
      const CreateTaskBottomSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  /// Submits new deliverable
  Future<void> submitTask() async {
    if (!PermissionService.verifyAction(
      AppPermissions.tasksManage,
      actionName: 'create or delegate tasks',
    )) {
      return;
    }
    // Strict FormKey validation invariant & Error Auto-Scroll
    if (createTaskFormKey.currentState == null ||
        !createTaskFormKey.currentState!.validate()) {
      HapticFeedback.lightImpact();
      if (titleFieldKey.currentContext != null) {
        Scrollable.ensureVisible(
          titleFieldKey.currentContext!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.1,
        );
      }
      titleFocusNode.requestFocus();
      return;
    }

    final title = titleController.text.trim();

    try {
      isSubmitting.value = true;
      HapticFeedback.mediumImpact();

      final dueFormatted = selectedDueDate.value != null
          ? '${selectedDueDate.value!.year}-${selectedDueDate.value!.month.toString().padLeft(2, '0')}-${selectedDueDate.value!.day.toString().padLeft(2, '0')}'
          : null;

      String backendPriority = 'normal';
      final p = selectedPriority.value.toLowerCase();
      if (p == 'urgent' || p == 'high') {
        backendPriority = 'high';
      } else if (p == 'low') {
        backendPriority = 'low';
      } else {
        backendPriority = 'normal';
      }

      final created = await repo.createTask(
        title: title,
        description: descriptionController.text.trim(),
        priority: backendPriority,
        dueOn: dueFormatted,
      );

      if (created != null) {
        tasks.insert(0, created);
        _recomputeLocalTelemetry();
        Get.back(); // Close modal
        HapticFeedback.heavyImpact();

        CustomSnackbar.showSuccess(
          title: 'Task Created',
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
    int openCount = 0;
    int completedCount = 0;
    int overdueCount = 0;

    for (final t in tasks) {
      if (t.isCompleted) {
        completedCount++;
      } else {
        openCount++;
        if (t.isOverdue) overdueCount++;
      }
    }

    telemetry.value = TaskTelemetryModel(
      totalTasks: tasks.length,
      pendingCount: openCount,
      inProgressCount: overdueCount,
      completedCount: completedCount,
    );
  }
}
