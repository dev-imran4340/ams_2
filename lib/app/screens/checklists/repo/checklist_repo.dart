import '../../../api/api_client.dart';
import '../../../api/api_endpoints.dart';
import '../../../api/exception_handler.dart';
import '../model/checklist_model.dart';

/// Repository for Onboarding & Offboarding Checklists (Phase 18)
/// Adheres strictly to .agents/rules/ams.md:
/// - Strict MVVM: UI -> Controller -> Repository -> ApiClient
/// - Mandatory Origin Tagging
/// - Deserializes JSON envelope into strongly-typed models
/// - Zero fallback / dummy data injection
class ChecklistRepo {
  static const String _originTag = 'ChecklistRepo / ChecklistsScreen';

  /// Fetches authenticated employee's onboarding and offboarding checklists via GET /me/checklists
  Future<List<ChecklistModel>?> fetchChecklists() async {
    final methodTag = '$_originTag -> fetchChecklists()';
    try {
      final response = await ApiClient.request(
        endpoint: ApiEndpoints.meChecklists,
        method: HttpMethod.get,
        tag: methodTag,
        showToastOnError: false,
      );

      if (response != null && response is Map<String, dynamic>) {
        final data = response['data'];
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map((item) => ChecklistModel.fromJson(item))
              .toList();
        }
      }
      return [];
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to fetch checklists: $e'),
        tag: '$methodTag [${stackTrace.toString().split('\n').first}]',
        showToast: false,
      );
      return null;
    }
  }
}
