import '../../../api/api_client.dart';
import '../../../api/api_endpoints.dart';
import '../../../api/exception_handler.dart';
import '../model/attendance_history_model.dart';

class AttendanceHistoryRepo {
  final String _tag = 'AttendanceHistoryRepo / AttendanceHistoryScreen';

  /// Fetches daily attendance logs directly from GET /me/attendance
  /// Supports optional query parameters: ?from=YYYY-MM-DD&to=YYYY-MM-DD
  /// Returns strongly-typed AttendanceHistoryResponse with Zero Dummy Fallback.
  Future<AttendanceHistoryResponse?> fetchAttendanceHistory({
    String? from,
    String? to,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (from != null && from.isNotEmpty) queryParams['from'] = from;
      if (to != null && to.isNotEmpty) queryParams['to'] = to;

      final response = await ApiClient.request(
        endpoint: ApiEndpoints.attendance,
        method: HttpMethod.get,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        tag: '$_tag -> fetchAttendanceHistory()',
        showToastOnError: false,
      );

      if (response != null && response is Map && response['data'] != null) {
        return AttendanceHistoryResponse.fromJson(
          Map<String, dynamic>.from(response),
        );
      }
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to fetch attendance history: $e'),
        tag:
            '$_tag -> fetchAttendanceHistory() [${stackTrace.toString().split('\n').first}]',
      );
    }
    // Zero Dummy Fallback Policy: return clean null on error, never inject fake data
    return null;
  }

  /// Convenience wrapper for fetching a complete calendar month (from 1st to last day)
  Future<AttendanceHistoryResponse?> fetchMonthlyHistory(DateTime month) async {
    final yearStr = month.year.toString();
    final monthStr = month.month.toString().padLeft(2, '0');
    final lastDay =
        DateTime(month.year, month.month + 1, 0).day.toString().padLeft(2, '0');
    final from = '$yearStr-$monthStr-01';
    final to = '$yearStr-$monthStr-$lastDay';

    return fetchAttendanceHistory(from: from, to: to);
  }

  /// Backward-compatible alias for fetchAttendanceHistory
  Future<AttendanceHistoryResponse?> fetchAttendanceTimesheet({
    String? from,
    String? to,
  }) =>
      fetchAttendanceHistory(from: from, to: to);
}
