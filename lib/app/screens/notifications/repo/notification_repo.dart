import '../../../api/api_client.dart';
import '../../../api/api_endpoints.dart';
import '../../../api/exception_handler.dart';
import '../model/notification_item_model.dart';
import '../model/notification_preferences_model.dart';
import '../model/push_token_payload_model.dart';

/// Centralized repository handling In-App notifications, preferences, and FCM push tokens.
/// Strictly enforces the AMS 2 Layer Flow Policy: View -> Controller -> Repository -> ApiClient.
class NotificationRepo {
  static const String _tag = 'NotificationRepo';

  /// Fetches paginated in-app notification list (GET /notifications)
  Future<NotificationsResponseModel?> fetchNotifications({
    int page = 1,
    int perPage = 25,
    bool unreadOnly = false,
  }) async {
    const originTag = '$_tag / NotificationsScreen -> fetchNotifications()';
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };
      if (unreadOnly) {
        queryParams['unread'] = '1';
      }

      final response = await ApiClient.request(
        endpoint: ApiEndpoints.notifications,
        method: HttpMethod.get,
        queryParameters: queryParams,
        tag: originTag,
        showToastOnError: true,
      );

      if (response != null && response is Map<String, dynamic>) {
        return NotificationsResponseModel.fromJson(response);
      } else if (response != null && response is Map) {
        return NotificationsResponseModel.fromJson(
          Map<String, dynamic>.from(response),
        );
      }
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to fetch notifications: $e'),
        tag: '$originTag [${stackTrace.toString().split('\n').first}]',
      );
    }
    return null;
  }

  /// Marks a single notification as read (POST /notifications/{id}/read) -> 204
  Future<bool> markAsRead(String id) async {
    final originTag = '$_tag / NotificationsScreen -> markAsRead($id)';
    try {
      await ApiClient.request(
        endpoint: ApiEndpoints.notificationRead(id),
        method: HttpMethod.post,
        tag: originTag,
        showToastOnError: false,
      );
      return true;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to mark notification $id as read: $e'),
        tag: '$originTag [${stackTrace.toString().split('\n').first}]',
        showToast: false,
      );
      return false;
    }
  }

  /// Marks all notifications as read (POST /notifications/read-all) -> 204
  Future<bool> markAllAsRead() async {
    const originTag = '$_tag / NotificationsScreen -> markAllAsRead()';
    try {
      await ApiClient.request(
        endpoint: ApiEndpoints.notificationsReadAll,
        method: HttpMethod.post,
        tag: originTag,
        showToastOnError: true,
      );
      return true;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to mark all notifications as read: $e'),
        tag: '$originTag [${stackTrace.toString().split('\n').first}]',
      );
      return false;
    }
  }

  /// Fetches user notification preferences grid (GET /me/notification-preferences)
  Future<NotificationPreferencesModel?> fetchPreferences() async {
    const originTag = '$_tag / NotificationPreferencesScreen -> fetchPreferences()';
    try {
      final response = await ApiClient.request(
        endpoint: ApiEndpoints.notificationPreferences,
        method: HttpMethod.get,
        tag: originTag,
        showToastOnError: true,
      );

      if (response != null && response is Map<String, dynamic>) {
        return NotificationPreferencesModel.fromJson(response);
      } else if (response != null && response is Map) {
        return NotificationPreferencesModel.fromJson(
          Map<String, dynamic>.from(response),
        );
      }
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to load notification preferences: $e'),
        tag: '$originTag [${stackTrace.toString().split('\n').first}]',
      );
    }
    return null;
  }

  /// Updates notification preferences for an individual category (PUT /me/notification-preferences)
  /// Sends only what changed: { "preferences": { [kind]: { [channel]: value } } }
  Future<NotificationPreferencesModel?> updatePreferences({
    required String kind,
    required Map<String, bool> changedChannels,
  }) async {
    final originTag = '$_tag / NotificationPreferencesScreen -> updatePreferences($kind)';
    try {
      final body = {
        'preferences': {
          kind: changedChannels,
        },
      };

      final response = await ApiClient.request(
        endpoint: ApiEndpoints.notificationPreferences,
        method: HttpMethod.put,
        body: body,
        tag: originTag,
        showToastOnError: true,
      );

      if (response != null && response is Map<String, dynamic>) {
        return NotificationPreferencesModel.fromJson(response);
      } else if (response != null && response is Map) {
        return NotificationPreferencesModel.fromJson(
          Map<String, dynamic>.from(response),
        );
      }
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to update preferences: $e'),
        tag: '$originTag [${stackTrace.toString().split('\n').first}]',
      );
    }
    return null;
  }

  /// Registers or refreshes phone FCM registration token (POST /push-tokens) -> 204
  Future<bool> registerPushToken(PushTokenPayloadModel payload) async {
    const originTag = '$_tag / PushService -> registerPushToken()';
    try {
      await ApiClient.request(
        endpoint: ApiEndpoints.pushTokens,
        method: HttpMethod.post,
        body: payload.toJson(),
        tag: originTag,
        showToastOnError: false,
      );
      return true;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to register push token: $e'),
        tag: '$originTag [${stackTrace.toString().split('\n').first}]',
        showToast: false,
      );
      return false;
    }
  }

  /// Removes phone push token upon disabling notifications or explicit de-registration (DELETE /push-tokens) -> 204
  Future<bool> deletePushToken(String token) async {
    const originTag = '$_tag / PushService -> deletePushToken()';
    try {
      await ApiClient.request(
        endpoint: ApiEndpoints.pushTokens,
        method: HttpMethod.delete,
        body: {'token': token},
        tag: originTag,
        showToastOnError: false,
      );
      return true;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to delete push token: $e'),
        tag: '$originTag [${stackTrace.toString().split('\n').first}]',
        showToast: false,
      );
      return false;
    }
  }
}
