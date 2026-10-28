import '../../../api/api_client.dart';
import '../../../api/api_endpoints.dart';
import '../../../api/exception_handler.dart';
import '../model/schedule_model.dart';

class ScheduleRepo {
  final String _tag = 'ScheduleRepo / ScheduleScreen';

  /// Fetches authenticated employee work schedule / rota via GET /me/schedule
  Future<ScheduleResponseModel?> fetchMySchedule({
    String? from,
    String? to,
  }) async {
    final queryParams = <String, String>{};
    if (from != null && from.trim().isNotEmpty) queryParams['from'] = from.trim();
    if (to != null && to.trim().isNotEmpty) queryParams['to'] = to.trim();

    try {
      final response = await ApiClient.request(
        method: HttpMethod.get,
        endpoint: ApiEndpoints.meSchedule,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        tag: '$_tag -> fetchMySchedule()',
      );

      if (response == null || response is! Map<String, dynamic>) {
        ExceptionHandler.handle(
          ApiException(message: 'Invalid response envelope from schedule API.'),
          tag: '$_tag -> fetchMySchedule()',
        );
        return null;
      }

      return ScheduleResponseModel.fromJson(response);
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to deserialize schedule response: $e'),
        tag: '$_tag -> fetchMySchedule() [${stackTrace.toString().split('\n').first}]',
      );
      return null;
    }
  }

  /// Manager / HR endpoint to view another subordinate employee schedule via GET /employees/{id}/schedule
  Future<ScheduleResponseModel?> fetchEmployeeSchedule(
    String employeeId, {
    String? from,
    String? to,
  }) async {
    final queryParams = <String, String>{};
    if (from != null && from.trim().isNotEmpty) queryParams['from'] = from.trim();
    if (to != null && to.trim().isNotEmpty) queryParams['to'] = to.trim();

    try {
      final response = await ApiClient.request(
        method: HttpMethod.get,
        endpoint: ApiEndpoints.employeeSchedule(employeeId),
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        tag: '$_tag -> fetchEmployeeSchedule($employeeId)',
      );

      if (response == null || response is! Map<String, dynamic>) {
        ExceptionHandler.handle(
          ApiException(message: 'Invalid response envelope from employee schedule API.'),
          tag: '$_tag -> fetchEmployeeSchedule()',
        );
        return null;
      }

      return ScheduleResponseModel.fromJson(response);
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to fetch employee schedule: $e'),
        tag: '$_tag -> fetchEmployeeSchedule() [${stackTrace.toString().split('\n').first}]',
      );
      return null;
    }
  }

  /// Fetches company and public holidays via GET /holidays
  Future<HolidaysResponseModel?> fetchHolidays({int? year}) async {
    final queryParams = <String, String>{};
    if (year != null) queryParams['year'] = year.toString();

    try {
      final response = await ApiClient.request(
        method: HttpMethod.get,
        endpoint: ApiEndpoints.holidays,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        tag: '$_tag -> fetchHolidays()',
      );

      if (response == null || response is! Map<String, dynamic>) {
        ExceptionHandler.handle(
          ApiException(message: 'Invalid response envelope from holidays API.'),
          tag: '$_tag -> fetchHolidays()',
        );
        return null;
      }

      return HolidaysResponseModel.fromJson(response);
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to deserialize holidays response: $e'),
        tag: '$_tag -> fetchHolidays() [${stackTrace.toString().split('\n').first}]',
      );
      return null;
    }
  }
}
