import '../../../api/api_client.dart';
import '../../../api/api_endpoints.dart';
import '../../../api/exception_handler.dart';
import '../model/attendance_summary_model.dart';

class AttendanceSummaryRepo {
  final String _tag = 'AttendanceSummaryRepo / AttendanceSummaryScreen';

  /// Fetches monthly attendance summary breakdown from live API GET /me/attendance/summary
  Future<AttendanceSummaryResponseModel?> fetchSummary(DateTime month) async {
    try {
      final monthStr = '${month.year}-${month.month.toString().padLeft(2, '0')}';

      final response = await ApiClient.request(
        endpoint: ApiEndpoints.attendanceSummary,
        method: HttpMethod.get,
        queryParameters: {'month': monthStr},
        tag: '$_tag -> fetchSummary()',
        showToastOnError: false,
      );

      if (response != null && response is Map && response['data'] != null) {
        return AttendanceSummaryResponseModel.fromJson(
          Map<String, dynamic>.from(response),
        );
      }
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to fetch attendance summary: $e'),
        tag: '$_tag -> fetchSummary() [${stackTrace.toString().split('\n').first}]',
      );
    }
    // Zero Dummy Fallback Policy: return clean null on failure
    return null;
  }
}
