import 'dart:async';
import '../../../api/api_client.dart';
import '../../../api/api_endpoints.dart';
import '../../../api/exception_handler.dart';
import '../model/evaluation_model.dart';

/// Repository for Performance Reviews & Appraisals (Phase 16)
/// Strictly adheres to .agents/rules/ams.md:
/// - Mandatory Origin Tagging
/// - Deserializes JSON envelope into strongly-typed models
/// - Zero fallback / dummy data injection
class EvaluationRepo {
  static const String _originTag = 'EvaluationRepo / EvaluationScreen';

  /// Fetches reviews list for specified box: 'mine' or 'to_review'
  /// GET /performance/reviews?box=mine|to_review
  Future<List<PerformanceReviewListItemModel>> fetchReviews({
    String box = 'mine',
  }) async {
    final methodTag = '$_originTag -> fetchReviews(box: $box)';
    try {
      final response = await ApiClient.request(
        endpoint: ApiEndpoints.performanceReviews,
        method: HttpMethod.get,
        queryParameters: {'box': box},
        tag: methodTag,
        showToastOnError: false,
      );

      if (response != null && response is Map<String, dynamic>) {
        final data = response['data'];
        if (data is List) {
          return data
              .map(
                (item) => PerformanceReviewListItemModel.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList();
        }
      }
      return [];
    } on ApiException catch (e) {
      if (e.statusCode == 403 || e.statusCode == 401) rethrow;
      return [];
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to fetch performance reviews: $e'),
        tag: '$methodTag [${stackTrace.toString().split('\n').first}]',
        showToast: false,
      );
      return [];
    }
  }

  /// Fetches full review details including sections, questions, and answers
  /// GET /performance/reviews/{id}
  Future<PerformanceReviewDetailsModel?> fetchReviewDetails(String id) async {
    final methodTag = '$_originTag -> fetchReviewDetails(id: $id)';
    try {
      final response = await ApiClient.request(
        endpoint: ApiEndpoints.performanceReviewDetails(id),
        method: HttpMethod.get,
        tag: methodTag,
        showToastOnError: false,
      );

      if (response != null && response is Map<String, dynamic>) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          return PerformanceReviewDetailsModel.fromJson(data);
        }
      }
      return null;
    } on ApiException catch (e) {
      if (e.statusCode == 403 || e.statusCode == 401) rethrow;
      return null;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to fetch review details: $e'),
        tag: '$methodTag [${stackTrace.toString().split('\n').first}]',
        showToast: false,
      );
      return null;
    }
  }

  /// Saves a draft of answers
  /// PUT /performance/reviews/{id}/answers
  Future<PerformanceReviewDetailsModel?> saveAnswers(
    String id,
    Map<String, dynamic> body,
  ) async {
    final methodTag = '$_originTag -> saveAnswers(id: $id)';
    try {
      final response = await ApiClient.request(
        endpoint: ApiEndpoints.performanceReviewAnswers(id),
        method: HttpMethod.put,
        body: body,
        tag: methodTag,
        showToastOnError: true,
      );

      if (response != null && response is Map<String, dynamic>) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          return PerformanceReviewDetailsModel.fromJson(data);
        }
      }
      return null;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to save review draft: $e'),
        tag: '$methodTag [${stackTrace.toString().split('\n').first}]',
        showToast: true,
      );
      return null;
    }
  }

  /// Final submission of review answers
  /// POST /performance/reviews/{id}/submit
  Future<PerformanceReviewDetailsModel?> submitReview(
    String id,
    Map<String, dynamic> body,
  ) async {
    final methodTag = '$_originTag -> submitReview(id: $id)';
    try {
      final response = await ApiClient.request(
        endpoint: ApiEndpoints.performanceReviewSubmit(id),
        method: HttpMethod.post,
        body: body,
        tag: methodTag,
        showToastOnError: true,
      );

      if (response != null && response is Map<String, dynamic>) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          return PerformanceReviewDetailsModel.fromJson(data);
        }
      }
      return null;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to submit review: $e'),
        tag: '$methodTag [${stackTrace.toString().split('\n').first}]',
        showToast: true,
      );
      return null;
    }
  }

  /// Updates or replaces review goals (when can.edit_goals == true)
  /// PUT /performance/reviews/{id}/goals
  Future<PerformanceReviewDetailsModel?> updateGoals(
    String id,
    List<Map<String, dynamic>> goals,
  ) async {
    final methodTag = '$_originTag -> updateGoals(id: $id)';
    try {
      final response = await ApiClient.request(
        endpoint: ApiEndpoints.performanceReviewGoals(id),
        method: HttpMethod.put,
        body: {'goals': goals},
        tag: methodTag,
        showToastOnError: true,
      );

      if (response != null && response is Map<String, dynamic>) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          return PerformanceReviewDetailsModel.fromJson(data);
        }
      }
      return null;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to update review goals: $e'),
        tag: '$methodTag [${stackTrace.toString().split('\n').first}]',
        showToast: true,
      );
      return null;
    }
  }

  /// Manager asks colleagues for peer feedback (when can.ask_peers == true)
  /// POST /performance/reviews/{id}/peers
  Future<PerformanceReviewDetailsModel?> invitePeers(
    String id,
    List<String> userIds,
  ) async {
    final methodTag = '$_originTag -> invitePeers(id: $id)';
    try {
      final response = await ApiClient.request(
        endpoint: ApiEndpoints.performanceReviewPeers(id),
        method: HttpMethod.post,
        body: {'people': userIds},
        tag: methodTag,
        showToastOnError: true,
      );

      if (response != null && response is Map<String, dynamic>) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          return PerformanceReviewDetailsModel.fromJson(data);
        }
      }
      return null;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to invite peers: $e'),
        tag: '$methodTag [${stackTrace.toString().split('\n').first}]',
        showToast: true,
      );
      return null;
    }
  }

  /// Peer declines to answer (when can.decline == true)
  /// POST /performance/reviews/{id}/decline
  Future<bool> declineReview(String id) async {
    final methodTag = '$_originTag -> declineReview(id: $id)';
    try {
      final response = await ApiClient.request(
        endpoint: ApiEndpoints.performanceReviewDecline(id),
        method: HttpMethod.post,
        tag: methodTag,
        showToastOnError: true,
      );
      return response != null;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to decline review: $e'),
        tag: '$methodTag [${stackTrace.toString().split('\n').first}]',
        showToast: true,
      );
      return false;
    }
  }

  /// Employee confirms they read a shared review (when can.acknowledge == true)
  /// POST /performance/reviews/{id}/acknowledge
  Future<PerformanceReviewDetailsModel?> acknowledgeReview(
    String id, {
    String? comment,
  }) async {
    final methodTag = '$_originTag -> acknowledgeReview(id: $id)';
    try {
      final response = await ApiClient.request(
        endpoint: ApiEndpoints.performanceReviewAcknowledge(id),
        method: HttpMethod.post,
        body: {
          if (comment != null && comment.isNotEmpty) 'comment': comment,
        },
        tag: methodTag,
        showToastOnError: true,
      );

      if (response != null && response is Map<String, dynamic>) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          return PerformanceReviewDetailsModel.fromJson(data);
        }
      }
      return null;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to acknowledge review: $e'),
        tag: '$methodTag [${stackTrace.toString().split('\n').first}]',
        showToast: true,
      );
      return null;
    }
  }
}
