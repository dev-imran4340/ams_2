import '../../../api/api_client.dart';
import '../../../api/api_endpoints.dart';
import '../../../api/exception_handler.dart';
import '../model/asset_model.dart';

class AssetRepo {
  final String _tag = 'AssetRepo / AssetsScreen';

  /// GET /me/assets
  /// Fetches equipment and company hardware assigned to the current employee.
  /// Zero Dummy / Fallback Policy: Returns live mapped model list or null on error.
  Future<List<AssetAssignmentModel>?> fetchAssets() async {
    final methodTag = '$_tag -> fetchAssets()';
    try {
      final response = await ApiClient.request(
        endpoint: ApiEndpoints.meAssets,
        method: HttpMethod.get,
        tag: methodTag,
        showToastOnError: false,
      );

      if (response != null && response is Map<String, dynamic>) {
        final rawData = response['data'];
        if (rawData is List) {
          return rawData
              .whereType<Map<String, dynamic>>()
              .map((item) => AssetAssignmentModel.fromJson(item))
              .toList();
        }
      }
      return null;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to fetch assigned assets: $e'),
        tag: '$methodTag [${stackTrace.toString().split('\n').first}]',
        showToast: false,
      );
      return null;
    }
  }

  /// POST /me/assets/{assignment}/acknowledge
  /// Confirms receipt of equipment in employee custody (204 No Content).
  Future<bool> acknowledgeAsset(String assignmentId) async {
    final methodTag = '$_tag -> acknowledgeAsset($assignmentId)';
    try {
      final response = await ApiClient.request(
        endpoint: ApiEndpoints.meAssetAcknowledge(assignmentId),
        method: HttpMethod.post,
        tag: methodTag,
        showToastOnError: true,
      );

      // 204 or 200 is success
      return response != null;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to acknowledge asset receipt: $e'),
        tag: '$methodTag [${stackTrace.toString().split('\n').first}]',
        showToast: true,
      );
      return false;
    }
  }
}
