import 'dart:async';

import 'package:http/http.dart' as http;

import '../../../api/api_client.dart';
import '../../../api/api_endpoints.dart';
import '../../../api/exception_handler.dart';
import '../model/leave_model.dart';

class LeaveRepo {
  static const String _tag = 'LeaveRepo / LeaveScreen';

  /// Fetches company leave categories and configuration rules (GET /leave/types)
  Future<List<LeaveTypeModel>> fetchLeaveTypes() async {
    try {
      final response = await ApiClient.request(
        endpoint: ApiEndpoints.leaveTypes,
        method: HttpMethod.get,
        tag: '$_tag -> fetchLeaveTypes()',
        showToastOnError: false,
      );

      if (response != null && response is Map && response['data'] is List) {
        final list = response['data'] as List;
        return list
            .whereType<Map>()
            .map((e) => LeaveTypeModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (e, stackTrace) {
      if (e is ApiException && (e.statusCode == 403 || e.errorCode == 'forbidden')) {
        rethrow;
      }
      ExceptionHandler.handle(
        ApiException(message: 'Failed to fetch leave types: $e'),
        tag: '$_tag -> fetchLeaveTypes() [${stackTrace.toString().split('\n').first}]',
      );
    }
    return <LeaveTypeModel>[];
  }

  /// Fetches quota and utilization breakdown across leave categories (GET /me/leave/balances)
  Future<List<LeaveBalanceModel>> fetchLeaveBalances({String? onDate}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (onDate != null && onDate.isNotEmpty) {
        queryParams['on'] = onDate;
      }

      final response = await ApiClient.request(
        endpoint: ApiEndpoints.meLeaveBalances,
        method: HttpMethod.get,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        tag: '$_tag -> fetchLeaveBalances()',
        showToastOnError: false,
      );

      if (response != null && response is Map && response['data'] is List) {
        final list = response['data'] as List;
        return list
            .whereType<Map>()
            .map((e) => LeaveBalanceModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (e, stackTrace) {
      if (e is ApiException && (e.statusCode == 403 || e.errorCode == 'forbidden')) {
        rethrow;
      }
      ExceptionHandler.handle(
        ApiException(message: 'Failed to fetch leave balances: $e'),
        tag: '$_tag -> fetchLeaveBalances() [${stackTrace.toString().split('\n').first}]',
      );
    }
    return <LeaveBalanceModel>[];
  }

  /// Lists logged-in user's submitted leave requests (GET /me/leave/requests)
  Future<List<LeaveRequestItemModel>> fetchLeaveRequests({
    int page = 1,
    int perPage = 25,
  }) async {
    try {
      final response = await ApiClient.request(
        endpoint: ApiEndpoints.meLeaveRequests,
        method: HttpMethod.get,
        queryParameters: {
          'page': page.toString(),
          'per_page': perPage.toString(),
        },
        tag: '$_tag -> fetchLeaveRequests()',
        showToastOnError: false,
      );

      if (response != null && response is Map && response['data'] is List) {
        final list = response['data'] as List;
        return list
            .whereType<Map>()
            .map((e) => LeaveRequestItemModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (e, stackTrace) {
      if (e is ApiException && (e.statusCode == 403 || e.errorCode == 'forbidden')) {
        rethrow;
      }
      ExceptionHandler.handle(
        ApiException(message: 'Failed to fetch leave requests: $e'),
        tag: '$_tag -> fetchLeaveRequests() [${stackTrace.toString().split('\n').first}]',
      );
    }
    return <LeaveRequestItemModel>[];
  }

  /// Performs live dry-run calculation before submitting (POST /me/leave/requests/preview)
  Future<LeavePreviewModel?> previewLeaveRequest(Map<String, dynamic> body) async {
    try {
      final response = await ApiClient.request(
        endpoint: ApiEndpoints.meLeaveRequestsPreview,
        method: HttpMethod.post,
        body: body,
        tag: '$_tag -> previewLeaveRequest()',
        showToastOnError: false,
      );

      if (response != null && response is Map && response['data'] is Map) {
        return LeavePreviewModel.fromJson(
          Map<String, dynamic>.from(response['data'] as Map),
        );
      }
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Leave preview calculation failed: $e'),
        tag: '$_tag -> previewLeaveRequest() [${stackTrace.toString().split('\n').first}]',
      );
    }
    return null;
  }

  /// Submits official leave request into universal approvals chain (POST /me/leave/requests)
  Future<bool> submitLeaveApplication(
    Map<String, dynamic> body, {
    String? filePath,
  }) async {
    try {
      dynamic response;
      if (filePath != null && filePath.trim().isNotEmpty) {
        final stringFields = body.map((k, v) => MapEntry(k, v.toString()));
        final file = await http.MultipartFile.fromPath('attachment', filePath.trim());
        response = await ApiClient.requestMultipart(
          endpoint: ApiEndpoints.meLeaveRequests,
          method: HttpMethod.post,
          fields: stringFields,
          files: [file],
          tag: '$_tag -> submitLeaveApplication(multipart)',
          showToastOnError: true,
        );
      } else {
        response = await ApiClient.request(
          endpoint: ApiEndpoints.meLeaveRequests,
          method: HttpMethod.post,
          body: body,
          tag: '$_tag -> submitLeaveApplication(json)',
          showToastOnError: true,
        );
      }

      if (response != null && response is Map) {
        return true;
      }
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to submit leave application: $e'),
        tag: '$_tag -> submitLeaveApplication() [${stackTrace.toString().split('\n').first}]',
      );
    }
    return false;
  }

  /// Cancels an existing leave request (POST /me/leave/requests/{id}/cancel)
  Future<bool> cancelLeaveRequest(String id, {required String reason}) async {
    try {
      final response = await ApiClient.request(
        endpoint: ApiEndpoints.meLeaveCancel(id),
        method: HttpMethod.post,
        body: {'reason': reason.trim()},
        tag: '$_tag -> cancelLeaveRequest($id)',
        showToastOnError: true,
      );

      if (response != null && response is Map) {
        return true;
      }
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to cancel leave request: $e'),
        tag: '$_tag -> cancelLeaveRequest($id) [${stackTrace.toString().split('\n').first}]',
      );
    }
    return false;
  }

  /// Lists who is on leave on a given date (GET /leave/whos-off)
  Future<List<WhosOffItemModel>> fetchWhosOff({String? date}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (date != null && date.trim().isNotEmpty) {
        queryParams['date'] = date.trim();
      }

      final response = await ApiClient.request(
        endpoint: ApiEndpoints.leaveWhosOff,
        method: HttpMethod.get,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        tag: '$_tag -> fetchWhosOff()',
        showToastOnError: false,
      );

      if (response != null && response is Map && response['data'] is List) {
        final list = response['data'] as List;
        return list
            .whereType<Map>()
            .map((e) => WhosOffItemModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to fetch who is off: $e'),
        tag: '$_tag -> fetchWhosOff() [${stackTrace.toString().split('\n').first}]',
      );
    }
    return <WhosOffItemModel>[];
  }

  /// Fetches subordinate employee leave audit data for Manager / HR (GET /employees/{id}/leave)
  Future<EmployeeLeaveAuditModel?> fetchEmployeeLeave(String employeeId) async {
    try {
      final response = await ApiClient.request(
        endpoint: ApiEndpoints.employeeLeave(employeeId),
        method: HttpMethod.get,
        tag: '$_tag -> fetchEmployeeLeave($employeeId)',
        showToastOnError: false,
      );

      if (response != null && response is Map && response['data'] is Map) {
        return EmployeeLeaveAuditModel.fromJson(
          Map<String, dynamic>.from(response['data'] as Map),
        );
      }
    } catch (e, stackTrace) {
      if (e is ApiException && (e.statusCode == 403 || e.errorCode == 'forbidden')) {
        rethrow;
      }
      ExceptionHandler.handle(
        ApiException(message: 'Failed to fetch employee leave audit: $e'),
        tag:
            '$_tag -> fetchEmployeeLeave($employeeId) [${stackTrace.toString().split('\n').first}]',
      );
    }
    return null;
  }
}
