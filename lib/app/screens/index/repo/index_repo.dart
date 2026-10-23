import 'dart:async';

import '../../../api/api_client.dart';
import '../../../api/api_endpoints.dart';
import '../../../api/app_preferences.dart';
import '../../../api/exception_handler.dart';
import '../model/me_model.dart';

class IndexRepo {
  final String _tag = 'IndexRepo / MainShell';

  /// Fetches authenticated user identity, company, permissions, modules, and dynamic menu.
  /// Strictly persists full response and separately isolates user and company in AppPreferences.
  Future<MeResponseModel?> fetchMe() async {
    try {
      final response = await ApiClient.request(
        endpoint: ApiEndpoints.me,
        method: HttpMethod.get,
        tag: '$_tag -> fetchMe()',
      );

      if (response == null || response is! Map) {
        ExceptionHandler.handle(
          ApiException(
            message: 'Invalid identity session payload received from server.',
            errorCode: 'INVALID_ME_RESPONSE',
          ),
          tag: '$_tag -> fetchMe()',
        );
        return null;
      }

      final Map<String, dynamic> responseMap =
          Map<String, dynamic>.from(response);

      // Save complete session payload, user, and company into local storage
      await AppPreferences.saveMeData(responseMap);

      return MeResponseModel.fromJson(responseMap);
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to hydrate identity session (/me): $e'),
        tag: '$_tag -> fetchMe() [${stackTrace.toString().split('\n').first}]',
      );
      return null;
    }
  }
}
