import '../../../api/api_client.dart';
import '../../../api/api_endpoints.dart';
import '../../../api/exception_handler.dart';
import '../model/attendance_history_model.dart';

class AttendanceHistoryRepo {
  final String _tag = 'AttendanceHistoryRepo / AttendanceHistoryScreen';

  /// Fetches monthly attendance history records and telemetry summary from live API
  Future<AttendanceHistoryResponse?> fetchMonthlyHistory(DateTime month) async {
    try {
      final yearStr = month.year.toString();
      final monthStr = month.month.toString().padLeft(2, '0');
      final lastDay = DateTime(month.year, month.month + 1, 0).day.toString().padLeft(2, '0');
      final from = '$yearStr-$monthStr-01';
      final to = '$yearStr-$monthStr-$lastDay';

      // 1. Fetch live attendance logs (/me/attendance)
      Map<String, dynamic>? response;
      try {
        response = await ApiClient.request(
          endpoint: ApiEndpoints.attendance,
          method: HttpMethod.get,
          queryParameters: {'from': from, 'to': to},
          tag: '$_tag -> fetchMonthlyHistory()',
        );
      } catch (_) {
        // Fallback without query if query params not accepted by server
        response = await ApiClient.request(
          endpoint: ApiEndpoints.attendance,
          method: HttpMethod.get,
          tag: '$_tag -> fetchMonthlyHistory(unfiltered)',
        );
      }

      if (response == null || response['data'] == null) {
        return null;
      }

      final rawData = response['data'];
      final List<dynamic> logsList = rawData is List ? rawData : [];
      final metaMap = response['meta'] is Map<String, dynamic>
          ? response['meta'] as Map<String, dynamic>
          : (response['meta'] is Map ? Map<String, dynamic>.from(response['meta'] as Map) : null);

      // 2. Fetch live monthly telemetry summary (/me/attendance/summary)
      Map<String, dynamic>? summaryData;
      try {
        final summaryResponse = await ApiClient.request(
          endpoint: ApiEndpoints.attendanceSummary,
          method: HttpMethod.get,
          queryParameters: {'month': '$yearStr-$monthStr'},
          tag: '$_tag -> fetchMonthlySummary()',
        );
        if (summaryResponse != null && summaryResponse['data'] is Map) {
          summaryData = Map<String, dynamic>.from(summaryResponse['data'] as Map);
        }
      } catch (e) {
        // Soft fail for summary: summary will be derived directly from real logs list
      }

      return AttendanceHistoryResponse.fromApi(
        logsList,
        metaJson: metaMap,
        summaryJson: summaryData,
      );
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to fetch attendance history: $e'),
        tag: '$_tag -> fetchMonthlyHistory() [${stackTrace.toString().split('\n').first}]',
      );
      // Zero Dummy Data Policy: return clean null on error, never inject fake logs!
      return null;
    }
  }

  /// Simulates export of monthly attendance report to PDF
  Future<bool> exportMonthlyReport(DateTime month) async {
    try {
      await Future.delayed(const Duration(milliseconds: 1000));
      return true;
    } catch (e) {
      ExceptionHandler.handle(
        ApiException(message: 'Report export failed: $e'),
        tag: '$_tag -> exportMonthlyReport()',
      );
      return false;
    }
  }
}
