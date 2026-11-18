import '../../../api/api_client.dart';
import '../../../api/api_endpoints.dart';
import '../../../api/exception_handler.dart';
import '../model/news_model.dart';

class NewsRepo {
  final String _originTag = 'NewsRepo / NewsScreen';

  /// GET /announcements
  /// Fetches published announcements (pinned first, then newest, at most 50)
  Future<AnnouncementsResponseModel> fetchAnnouncements() async {
    final methodTag = '$_originTag -> fetchAnnouncements()';
    try {
      final response = await ApiClient.request(
        method: HttpMethod.get,
        endpoint: ApiEndpoints.announcements,
        tag: methodTag,
      );

      if (response != null && response is Map<String, dynamic>) {
        return AnnouncementsResponseModel.fromJson(response);
      }
      return const AnnouncementsResponseModel(
        announcements: [],
        unreadCount: 0,
      );
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to fetch announcements: $e'),
        tag: '$methodTag [${stackTrace.toString().split('\n').first}]',
        showToast: false,
      );
      return const AnnouncementsResponseModel(
        announcements: [],
        unreadCount: 0,
      );
    }
  }

  /// GET /announcements/{id}
  /// Fetches full announcement body content and marks it read
  Future<AnnouncementItemModel?> fetchAnnouncementDetails(String id) async {
    final methodTag = '$_originTag -> fetchAnnouncementDetails($id)';
    try {
      final response = await ApiClient.request(
        method: HttpMethod.get,
        endpoint: ApiEndpoints.announcementDetails(id),
        tag: methodTag,
      );

      if (response != null && response['data'] is Map<String, dynamic>) {
        return AnnouncementItemModel.fromJson(
          response['data'] as Map<String, dynamic>,
        );
      }
      return null;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to load announcement details: $e'),
        tag: '$methodTag [${stackTrace.toString().split('\n').first}]',
      );
      return null;
    }
  }

  /// GET /events?from=&to=
  /// Fetches upcoming company events (soonest first)
  Future<List<CompanyEventItemModel>> fetchEvents({
    String? from,
    String? to,
  }) async {
    final methodTag = '$_originTag -> fetchEvents()';
    try {
      final endpoint = ApiEndpoints.events(from: from, to: to);
      final response = await ApiClient.request(
        method: HttpMethod.get,
        endpoint: endpoint,
        tag: methodTag,
      );

      if (response != null && response['data'] is List) {
        return (response['data'] as List)
            .whereType<Map<String, dynamic>>()
            .map((e) => CompanyEventItemModel.fromJson(e))
            .toList();
      }
      return [];
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to fetch company events: $e'),
        tag: '$methodTag [${stackTrace.toString().split('\n').first}]',
        showToast: false,
      );
      return [];
    }
  }

  /// GET /people/milestones
  /// Fetches birthdays & work anniversaries for colleagues at user's location in next 14 days
  Future<List<ColleagueMilestoneItemModel>> fetchMilestones() async {
    final methodTag = '$_originTag -> fetchMilestones()';
    try {
      final response = await ApiClient.request(
        method: HttpMethod.get,
        endpoint: ApiEndpoints.peopleMilestones,
        tag: methodTag,
      );

      if (response != null && response['data'] is List) {
        return (response['data'] as List)
            .whereType<Map<String, dynamic>>()
            .map((e) => ColleagueMilestoneItemModel.fromJson(e))
            .toList();
      }
      return [];
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to fetch colleague milestones: $e'),
        tag: '$methodTag [${stackTrace.toString().split('\n').first}]',
        showToast: false,
      );
      return [];
    }
  }

  /// PUT /me/birthday-sharing
  /// Toggles whether user's own birthday is shared with location colleagues
  Future<bool?> updateBirthdaySharing(bool shares) async {
    final methodTag = '$_originTag -> updateBirthdaySharing()';
    try {
      final response = await ApiClient.request(
        method: HttpMethod.put,
        endpoint: ApiEndpoints.meBirthdaySharing,
        body: {'shares': shares},
        tag: methodTag,
      );

      if (response != null && response['data'] is Map<String, dynamic>) {
        final data = response['data'] as Map<String, dynamic>;
        return data['shares'] == true;
      }
      return null;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to update birthday privacy: $e'),
        tag: '$methodTag [${stackTrace.toString().split('\n').first}]',
      );
      return null;
    }
  }
}
