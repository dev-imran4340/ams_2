import 'dart:async';

import '../../../api/api_client.dart';
import '../../../api/api_endpoints.dart';
import '../../../api/exception_handler.dart';
import '../../attendance_history/model/attendance_history_model.dart';
import '../../leaves/model/leave_model.dart';
import '../model/department_employee_model.dart';

class DepartmentEmployeesRepo {
  static const String _tag = 'DepartmentEmployeesRepo / EmployeesScreen';

  /// Fetches employees list from GET /api/v1/employees
  /// Conforms strictly with Layer Flow: View -> Controller -> Repository -> ApiClient
  /// Strict Invariant: Returns live data or empty list []; NO dummy / mock fallback.
  Future<List<DepartmentEmployeeModel>> fetchDepartmentEmployees({
    String? search,
  }) async {
    try {
      final queryParams = <String, String>{
        'per_page': '50',
      };
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      final response = await ApiClient.request(
        endpoint: ApiEndpoints.employees,
        method: HttpMethod.get,
        queryParameters: queryParams,
        tag: '$_tag -> fetchDepartmentEmployees()',
        showToastOnError: false,
      );

      if (response != null && response is Map) {
        final rawData = response['data'];
        if (rawData is List) {
          final list = rawData
              .whereType<Map>()
              .map((e) => DepartmentEmployeeModel.fromJson(
                    Map<String, dynamic>.from(e),
                  ))
              .toList();

          return list;
        }
      }
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Remote employees fetch failed: $e'),
        tag:
            '$_tag -> fetchDepartmentEmployees() [${stackTrace.toString().split('\n').first}]',
      );
    }

    // Zero dummy data: return empty list on failure or empty response
    return <DepartmentEmployeeModel>[];
  }

  /// Fetches attendance records for a specific employee within manager/HR scope (GET /employees/{id}/attendance)
  Future<AttendanceHistoryResponse?> fetchEmployeeAttendance(
    String employeeId, {
    String? from,
    String? to,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (from != null && from.isNotEmpty) queryParams['from'] = from;
      if (to != null && to.isNotEmpty) queryParams['to'] = to;

      final response = await ApiClient.request(
        endpoint: ApiEndpoints.employeeAttendance(employeeId),
        method: HttpMethod.get,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        tag: '$_tag -> fetchEmployeeAttendance($employeeId)',
        showToastOnError: false,
      );

      if (response != null && response is Map && response['data'] != null) {
        return AttendanceHistoryResponse.fromJson(
          Map<String, dynamic>.from(response),
        );
      }
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to fetch employee attendance: $e'),
        tag:
            '$_tag -> fetchEmployeeAttendance($employeeId) [${stackTrace.toString().split('\n').first}]',
      );
    }
    return null;
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
      ExceptionHandler.handle(
        ApiException(message: 'Failed to fetch employee leave audit: $e'),
        tag:
            '$_tag -> fetchEmployeeLeave($employeeId) [${stackTrace.toString().split('\n').first}]',
      );
    }
    return null;
  }
}
