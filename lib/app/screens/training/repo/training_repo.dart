import '../../../api/api_client.dart';
import '../../../api/api_endpoints.dart';
import '../../../api/exception_handler.dart';
import '../model/training_model.dart';

class TrainingRepo {
  final String _tag = 'TrainingRepo / TrainingScreen';

  /// GET /me/training
  /// Fetches required compliance courses and employee training certification history.
  /// Zero Dummy / Fallback Policy: Returns live mapped model or null on error.
  Future<TrainingDataModel?> fetchTraining() async {
    final methodTag = '$_tag -> fetchTraining()';
    try {
      final response = await ApiClient.request(
        endpoint: ApiEndpoints.meTraining,
        method: HttpMethod.get,
        tag: methodTag,
        showToastOnError: false,
      );

      if (response != null && response is Map<String, dynamic>) {
        final rawData = response['data'];
        if (rawData is Map<String, dynamic>) {
          return TrainingDataModel.fromJson(rawData);
        } else if (response.containsKey('required') ||
            response.containsKey('records')) {
          return TrainingDataModel.fromJson(response);
        }
      }
      return null;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to fetch training programs: $e'),
        tag: '$methodTag [${stackTrace.toString().split('\n').first}]',
        showToast: false,
      );
      return null;
    }
  }
}
