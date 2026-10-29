import 'dart:async';

import '../../../api/api_client.dart';
import '../../../api/api_endpoints.dart';
import '../../../api/exception_handler.dart';
import '../model/approval_model.dart';

class ApprovalRepo {
  static const String _tag = 'ApprovalRepo / ApprovalsScreen';

  /// Fetches approvals categorized by box (waiting, pending, mine, decided)
  /// In accordance with Module 6 (API 6.1: List Approvals Inbox)
  /// Strict Invariant: Returns live data or empty list []; NO dummy / mock fallback.
  Future<List<ApprovalItemModel>> fetchApprovalsBox({
    String box = 'waiting',
    String? type,
    int page = 1,
    int perPage = 25,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'box': box,
        'page': page.toString(),
        'per_page': perPage.toString(),
      };
      if (type != null && type.trim().isNotEmpty) {
        queryParams['type'] = type.trim();
      }

      final response = await ApiClient.request(
        endpoint: ApiEndpoints.approvals,
        method: HttpMethod.get,
        queryParameters: queryParams,
        tag: '$_tag -> fetchApprovalsBox($box)',
        showToastOnError: false,
      );

      if (response != null && response is Map) {
        final rawData = response['data'];
        if (rawData is List) {
          final list = rawData
              .whereType<Map>()
              .map((e) => ApprovalItemModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();

          return list;
        }
      }
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Remote approvals fetch failed: $e'),
        tag: '$_tag -> fetchApprovalsBox($box) [${stackTrace.toString().split('\n').first}]',
      );
    }

    // Zero dummy data: return empty list on null response or error
    return <ApprovalItemModel>[];
  }

  /// Fetches audit detail for a specific approval request (API 6.2)
  /// Strict Invariant: Returns live data or null; NO dummy / mock fallback.
  Future<ApprovalItemModel?> fetchApprovalDetails(String id) async {
    try {
      final response = await ApiClient.request(
        endpoint: ApiEndpoints.approvalDetails(id),
        method: HttpMethod.get,
        tag: '$_tag -> fetchApprovalDetails($id)',
        showToastOnError: false,
      );

      if (response != null && response is Map) {
        final rawData = response['data'];
        if (rawData is Map) {
          return ApprovalItemModel.fromJson(Map<String, dynamic>.from(rawData));
        }
      }
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to fetch approval details: $e'),
        tag: '$_tag -> fetchApprovalDetails($id) [${stackTrace.toString().split('\n').first}]',
      );
    }

    return null;
  }

  /// Grants approval on current step (API 6.3)
  Future<ApprovalItemModel?> approveRequest(
    String id, {
    String? comment,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (comment != null && comment.trim().isNotEmpty) {
        body['comment'] = comment.trim();
      }

      final response = await ApiClient.request(
        endpoint: ApiEndpoints.approveApproval(id),
        method: HttpMethod.post,
        body: body,
        tag: '$_tag -> approveRequest($id)',
        showToastOnError: true,
      );

      if (response != null && response is Map) {
        final rawData = response['data'];
        if (rawData is Map) {
          return ApprovalItemModel.fromJson(Map<String, dynamic>.from(rawData));
        }
      }
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Approval action failed: $e'),
        tag: '$_tag -> approveRequest($id) [${stackTrace.toString().split('\n').first}]',
      );
    }
    return null;
  }

  /// Rejects the request with a mandatory comment (API 6.4)
  Future<ApprovalItemModel?> rejectRequest(
    String id, {
    required String comment,
  }) async {
    try {
      final body = <String, dynamic>{
        'comment': comment.trim(),
      };

      final response = await ApiClient.request(
        endpoint: ApiEndpoints.rejectApproval(id),
        method: HttpMethod.post,
        body: body,
        tag: '$_tag -> rejectRequest($id)',
        showToastOnError: true,
      );

      if (response != null && response is Map) {
        final rawData = response['data'];
        if (rawData is Map) {
          return ApprovalItemModel.fromJson(Map<String, dynamic>.from(rawData));
        }
      }
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Reject action failed: $e'),
        tag: '$_tag -> rejectRequest($id) [${stackTrace.toString().split('\n').first}]',
      );
    }
    return null;
  }

  /// Cancels / withdraws a waiting request (API 6.5)
  Future<ApprovalItemModel?> cancelRequest(String id) async {
    try {
      final response = await ApiClient.request(
        endpoint: ApiEndpoints.cancelApproval(id),
        method: HttpMethod.post,
        tag: '$_tag -> cancelRequest($id)',
        showToastOnError: true,
      );

      if (response != null && response is Map) {
        final rawData = response['data'];
        if (rawData is Map) {
          return ApprovalItemModel.fromJson(Map<String, dynamic>.from(rawData));
        }
      }
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Cancel request failed: $e'),
        tag: '$_tag -> cancelRequest($id) [${stackTrace.toString().split('\n').first}]',
      );
    }
    return null;
  }
}
