import '../../../api/api_client.dart';
import '../../../api/api_endpoints.dart';
import '../../../api/app_preferences.dart';
import '../../../api/exception_handler.dart';
import '../model/splash_session_model.dart';

class SplashRepo {
  final String _tag = 'SplashRepo / SplashScreen';

  /// Verifies active user session via backend /auth/me endpoint
  Future<SplashSessionModel?> verifySession() async {
    final token = AppPreferences.token;
    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      final response = await ApiClient.request(
        method: HttpMethod.get,
        endpoint: ApiEndpoints.me,
        tag: '$_tag -> verifySession()',
        showToastOnError: false,
      );

      if (response == null || response is! Map<String, dynamic>) {
        return null;
      }

      final jsonPayload = (response['data'] is Map<String, dynamic>)
          ? response['data'] as Map<String, dynamic>
          : response;

      return SplashSessionModel.fromJson(jsonPayload);
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Session verification failed: $e'),
        tag: '$_tag -> verifySession() [${stackTrace.toString().split('\n').first}]',
        showToast: false,
      );
      return null;
    }
  }
}
