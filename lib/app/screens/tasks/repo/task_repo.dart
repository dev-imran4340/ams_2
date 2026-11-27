import 'dart:io';
import 'package:http/http.dart' as http;

import '../../../api/api_client.dart';
import '../../../api/api_endpoints.dart';
import '../../../api/app_preferences.dart';
import '../../../api/exception_handler.dart';
import '../../employees/model/department_employee_model.dart';
import '../model/task_model.dart';

class TaskRepo {
  final String _tag = 'TaskRepo / TasksScreen';

  /// GET /tasks?list=&status=&due=&page=&per_page=
  /// Fetches live server-filtered task roster with pagination & operational telemetry
  /// Zero Dummy Fallback Policy: Live data or clean empty list on failure
  Future<({List<TaskModel> tasks, TaskTelemetryModel telemetry, int total, int page, int lastPage})?>
      fetchTasks({
    String list = 'mine',
    String status = 'open',
    String? due,
    int page = 1,
    int perPage = 25,
  }) async {
    final methodTag =
        '$_tag -> fetchTasks(list=$list, status=$status, due=$due, page=$page)';

    try {
      final queryParams = <String, dynamic>{
        'list': list,
        'status': status,
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (due != null && due.isNotEmpty && status == 'open') {
        queryParams['due'] = due;
      }

      final response = await ApiClient.request(
        endpoint: ApiEndpoints.tasks,
        method: HttpMethod.get,
        queryParameters: queryParams,
        tag: methodTag,
        showToastOnError: false,
      );

      if (response != null && response is Map<String, dynamic>) {
        final rawData = response['data'];
        final meta = response['meta'] is Map<String, dynamic>
            ? response['meta'] as Map<String, dynamic>
            : <String, dynamic>{};

        List<TaskModel> taskList = [];
        if (rawData is List) {
          taskList = rawData
              .whereType<Map<String, dynamic>>()
              .map((item) => TaskModel.fromJson(item))
              .toList();
        }

        final int total = (meta['total'] as num?)?.toInt() ?? taskList.length;
        final int currentPage = (meta['page'] as num?)?.toInt() ?? page;
        final int lastPage = (meta['last_page'] as num?)?.toInt() ?? 1;

        // Compute telemetry from received tasks list
        int openCount = 0;
        int completedCount = 0;
        int overdueCount = 0;

        for (final t in taskList) {
          if (t.isCompleted) {
            completedCount++;
          } else {
            openCount++;
            if (t.isOverdue) overdueCount++;
          }
        }

        final telemetry = TaskTelemetryModel(
          totalTasks: total,
          pendingCount: openCount,
          inProgressCount: overdueCount,
          completedCount: completedCount,
        );

        return (
          tasks: taskList,
          telemetry: telemetry,
          total: total,
          page: currentPage,
          lastPage: lastPage,
        );
      }
      return null;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to fetch task operations: $e'),
        tag: '$methodTag [${stackTrace.toString().split('\n').first}]',
        showToast: false,
      );
      return null;
    }
  }

  /// GET /tasks/{id}
  /// Fetches complete audit details, description, linked checklist, files and discussion thread
  Future<TaskModel?> fetchTaskDetails(String id) async {
    final methodTag = '$_tag -> fetchTaskDetails($id)';
    try {
      final response = await ApiClient.request(
        endpoint: ApiEndpoints.taskDetails(id),
        method: HttpMethod.get,
        tag: methodTag,
        showToastOnError: true,
      );

      if (response != null && response is Map<String, dynamic>) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          return TaskModel.fromJson(data);
        }
      }
      return null;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to fetch task details: $e'),
        tag: '$methodTag [${stackTrace.toString().split('\n').first}]',
        showToast: true,
      );
      return null;
    }
  }

  /// POST /tasks
  /// Creates a new deliverable task on the live backend
  Future<TaskModel?> createTask({
    required String title,
    String? description,
    String priority = 'normal',
    String? dueOn,
    List<String>? assignees,
    String? about,
    List<File>? files,
  }) async {
    final methodTag = '$_tag -> createTask()';
    try {
      // Priority must be strictly 'low', 'normal', or 'high'
      String normalizedPriority = 'normal';
      final p = priority.toLowerCase().trim();
      if (p == 'urgent' || p == 'high') {
        normalizedPriority = 'high';
      } else if (p == 'low') {
        normalizedPriority = 'low';
      } else {
        normalizedPriority = 'normal';
      }

      // Backend validator strictly requires 'assignees' => 'required|array'
      final selfUserId =
          AppPreferences.userId ?? AppPreferences.selfEmployeeId ?? '';
      final List<String> effectiveAssignees =
          (assignees != null && assignees.isNotEmpty)
              ? assignees
              : (selfUserId.isNotEmpty ? [selfUserId] : <String>[]);

      // Check if files are attached -> Multipart request
      dynamic response;
      if (files != null && files.isNotEmpty) {
        final fields = <String, String>{
          'title': title.trim(),
          'priority': normalizedPriority,
        };

        if (description != null && description.trim().isNotEmpty) {
          fields['description'] = description.trim();
        }

        if (dueOn != null && dueOn.trim().isNotEmpty) {
          fields['due_on'] = dueOn.trim();
        }

        if (about != null && about.trim().isNotEmpty) {
          fields['about'] = about.trim();
        }

        for (int i = 0; i < effectiveAssignees.length; i++) {
          fields['assignees[$i]'] = effectiveAssignees[i];
        }

        final multipartFiles = <http.MultipartFile>[];
        for (final f in files) {
          if (await f.exists()) {
            multipartFiles.add(
              await http.MultipartFile.fromPath('files[]', f.path),
            );
          }
        }

        response = await ApiClient.requestMultipart(
          method: HttpMethod.post,
          endpoint: ApiEndpoints.tasks,
          fields: fields,
          files: multipartFiles,
          tag: '$methodTag [multipart]',
          showToastOnError: true,
        );
      } else {
        final jsonBody = <String, dynamic>{
          'title': title.trim(),
          'priority': normalizedPriority,
          'assignees': effectiveAssignees,
        };

        if (description != null && description.trim().isNotEmpty) {
          jsonBody['description'] = description.trim();
        }

        if (dueOn != null && dueOn.trim().isNotEmpty) {
          jsonBody['due_on'] = dueOn.trim();
        }

        if (about != null && about.trim().isNotEmpty) {
          jsonBody['about'] = about.trim();
        }

        response = await ApiClient.request(
          endpoint: ApiEndpoints.tasks,
          method: HttpMethod.post,
          body: jsonBody,
          tag: methodTag,
          showToastOnError: true,
        );
      }

      if (response != null && response is Map<String, dynamic>) {
        final data = response['data'];
        if (data is List && data.isNotEmpty) {
          final first = data.first;
          if (first is Map<String, dynamic>) {
            return TaskModel.fromJson(first);
          }
        } else if (data is Map<String, dynamic>) {
          return TaskModel.fromJson(data);
        }
      }
      return null;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to create task deliverable: $e'),
        tag: '$methodTag [${stackTrace.toString().split('\n').first}]',
        showToast: true,
      );
      return null;
    }
  }

  /// POST /tasks/{id}/complete
  /// Marks an active deliverable as completed with an optional note
  Future<bool> completeTask(String id, {String? note}) async {
    final methodTag = '$_tag -> completeTask($id)';
    try {
      final body = <String, dynamic>{};
      if (note != null && note.trim().isNotEmpty) {
        body['note'] = note.trim();
      }

      final response = await ApiClient.request(
        endpoint: ApiEndpoints.completeTask(id),
        method: HttpMethod.post,
        body: body,
        tag: methodTag,
        showToastOnError: true,
      );

      return response != null;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to mark task completed: $e'),
        tag: '$methodTag [${stackTrace.toString().split('\n').first}]',
        showToast: true,
      );
      return false;
    }
  }

  /// POST /tasks/{id}/reopen
  /// Reopens a previously completed deliverable
  Future<bool> reopenTask(String id) async {
    final methodTag = '$_tag -> reopenTask($id)';
    try {
      final response = await ApiClient.request(
        endpoint: ApiEndpoints.reopenTask(id),
        method: HttpMethod.post,
        tag: methodTag,
        showToastOnError: true,
      );

      return response != null;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to reopen task: $e'),
        tag: '$methodTag [${stackTrace.toString().split('\n').first}]',
        showToast: true,
      );
      return false;
    }
  }

  /// Toggles task completion state calling live complete or reopen
  Future<bool> toggleTaskCompletion(String taskId, bool isDone, {String? note}) async {
    if (isDone) {
      return await completeTask(taskId, note: note);
    } else {
      return await reopenTask(taskId);
    }
  }

  /// POST /tasks/{id}/comments
  /// Appends comment reply to the task thread with optional file attachments
  Future<bool> postComment(
    String taskId, {
    required String body,
    List<File>? files,
  }) async {
    final methodTag = '$_tag -> postComment($taskId)';
    try {
      final fields = <String, String>{
        'body': body.trim(),
      };

      dynamic response;
      if (files != null && files.isNotEmpty) {
        final multipartFiles = <http.MultipartFile>[];
        for (final f in files) {
          if (await f.exists()) {
            multipartFiles.add(
              await http.MultipartFile.fromPath('files[]', f.path),
            );
          }
        }

        response = await ApiClient.requestMultipart(
          method: HttpMethod.post,
          endpoint: ApiEndpoints.taskComments(taskId),
          fields: fields,
          files: multipartFiles,
          tag: '$methodTag [multipart]',
          showToastOnError: true,
        );
      } else {
        response = await ApiClient.request(
          endpoint: ApiEndpoints.taskComments(taskId),
          method: HttpMethod.post,
          body: fields,
          tag: methodTag,
          showToastOnError: true,
        );
      }

      return response != null;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to post task comment: $e'),
        tag: '$methodTag [${stackTrace.toString().split('\n').first}]',
        showToast: true,
      );
      return false;
    }
  }

  /// GET /employees?per_page=100
  /// Fetches server-filtered team members within the manager's tasks.manage reach
  Future<List<DepartmentEmployeeModel>> fetchAssignableEmployees({
    String? search,
  }) async {
    final methodTag = '$_tag -> fetchAssignableEmployees()';
    try {
      final queryParams = <String, dynamic>{
        'per_page': '100',
      };
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      final response = await ApiClient.request(
        endpoint: ApiEndpoints.employees,
        method: HttpMethod.get,
        queryParameters: queryParams,
        tag: methodTag,
        showToastOnError: false,
      );

      if (response != null && response is Map<String, dynamic>) {
        final rawData = response['data'];
        if (rawData is List) {
          return rawData
              .whereType<Map>()
              .map(
                (e) => DepartmentEmployeeModel.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList();
        }
      }
      return <DepartmentEmployeeModel>[];
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to load team members: $e'),
        tag: '$methodTag [${stackTrace.toString().split('\n').first}]',
        showToast: false,
      );
      return <DepartmentEmployeeModel>[];
    }
  }
}
