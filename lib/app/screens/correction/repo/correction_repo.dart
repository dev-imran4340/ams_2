import '../../../api/api_client.dart';
import '../../../api/api_endpoints.dart';
import '../../../api/exception_handler.dart';
import '../model/correction_model.dart';

class CorrectionRepo {
  static const String _tag = 'CorrectionRepo';

  /// Submits an attendance correction request via POST /me/attendance/corrections
  Future<Map<String, dynamic>?> submitAttendanceCorrection(
    AttendanceCorrectionSubmitModel model,
  ) async {
    try {
      final response = await ApiClient.request(
        endpoint: ApiEndpoints.attendanceCorrections,
        method: HttpMethod.post,
        body: model.toJson(),
        tag: '$_tag / CorrectionScreen -> submitAttendanceCorrection()',
      );

      if (response != null && response is Map) {
        return Map<String, dynamic>.from(response);
      }
      return null;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to submit attendance correction: $e'),
        tag:
            '$_tag -> submitAttendanceCorrection() [${stackTrace.toString().split('\n').first}]',
      );
      return null;
    }
  }
}
