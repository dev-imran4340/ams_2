import 'dart:async';

import '../../../api/api_client.dart';
import '../../../api/api_endpoints.dart';
import '../../../api/exception_handler.dart';
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
}
