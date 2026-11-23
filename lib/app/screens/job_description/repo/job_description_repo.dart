import '../../../api/api_client.dart';
import '../../../api/api_endpoints.dart';
import '../../../api/app_preferences.dart';
import '../../../api/exception_handler.dart';
import '../model/job_description_model.dart';

/// Repository for Employee Job Description (Phase 18)
/// Strictly adheres to .agents/rules/ams.md:
/// - MVVM Flow: View -> Controller -> Repository -> ApiClient
/// - Mandatory Origin Tagging
/// - Deserializes JSON envelope into strongly-typed model
/// - Zero dummy / fallback policy
class JobDescriptionRepo {
  static const String _originTag = 'JobDescriptionRepo / JobDescriptionScreen';

  /// GET /me/job-description
  /// Returns the current job description of employee's designation or null.
  Future<JobDescriptionModel?> fetchJobDescription() async {
    if (AppPreferences.isCompanyMode) return null;
    final methodTag = '$_originTag -> fetchJobDescription()';
    try {
      final response = await ApiClient.request(
        endpoint: ApiEndpoints.meJobDescription,
        method: HttpMethod.get,
        tag: methodTag,
        showToastOnError: false,
      );

      if (response != null && response is Map<String, dynamic>) {
        final rawData = response['data'];
        if (rawData is Map<String, dynamic>) {
          return JobDescriptionModel.fromJson(rawData);
        }
      }
      return null;
    } catch (e) {
      ExceptionHandler.handle(e, tag: methodTag);
      return null;
    }
  }
}
