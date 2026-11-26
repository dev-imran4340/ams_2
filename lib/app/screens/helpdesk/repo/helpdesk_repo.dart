import 'dart:io';
import '../../../api/api_client.dart';
import '../../../api/api_endpoints.dart';
import '../../../api/exception_handler.dart';
import '../model/helpdesk_model.dart';

/// Repository for HR Helpdesk & Support Tickets (Phase 18 Part 5)
/// Adheres strictly to .agents/rules/ams.md:
/// - Mandatory Origin Tagging
/// - Deserializes JSON envelope into strongly-typed models
/// - Zero fallback / dummy data injection
class HelpdeskRepo {
  static const String _originTag = 'HelpdeskRepo / HelpdeskScreen';

  /// Fetches corporate helpdesk tickets list (GET /helpdesk/tickets)
  Future<List<HelpdeskTicketModel>?> fetchTickets() async {
    final methodTag = '$_originTag -> fetchTickets()';
    try {
      final response = await ApiClient.request(
        endpoint: ApiEndpoints.helpdeskTickets,
        method: HttpMethod.get,
        tag: methodTag,
        showToastOnError: false,
      );

      if (response != null && response is Map<String, dynamic>) {
        final data = response['data'];
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map((item) => HelpdeskTicketModel.fromJson(item))
              .toList();
        }
      }
      return [];
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to fetch helpdesk tickets: $e'),
        tag: '$methodTag [${stackTrace.toString().split('\n').first}]',
        showToast: false,
      );
      return null;
    }
  }

  /// Fetches helpdesk ticket categories (GET /helpdesk/categories)
  Future<List<HelpdeskCategoryModel>?> fetchCategories() async {
    final methodTag = '$_originTag -> fetchCategories()';
    try {
      final response = await ApiClient.request(
        endpoint: ApiEndpoints.helpdeskCategories,
        method: HttpMethod.get,
        tag: methodTag,
        showToastOnError: false,
      );

      if (response != null && response is Map<String, dynamic>) {
        final data = response['data'];
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map((item) => HelpdeskCategoryModel.fromJson(item))
              .toList();
        }
      }
      return [];
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to fetch helpdesk categories: $e'),
        tag: '$methodTag [${stackTrace.toString().split('\n').first}]',
        showToast: false,
      );
      return null;
    }
  }

  /// Fetches single ticket details with full messages conversation thread (GET /helpdesk/tickets/{id})
  Future<HelpdeskTicketModel?> fetchTicketDetails(String id) async {
    final methodTag = '$_originTag -> fetchTicketDetails(id: $id)';
    try {
      final response = await ApiClient.request(
        endpoint: ApiEndpoints.helpdeskTicketDetails(id),
        method: HttpMethod.get,
        tag: methodTag,
        showToastOnError: false,
      );

      if (response != null && response is Map<String, dynamic>) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          return HelpdeskTicketModel.fromJson(data);
        }
      }
      return null;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to fetch ticket details: $e'),
        tag: '$methodTag [${stackTrace.toString().split('\n').first}]',
        showToast: false,
      );
      return null;
    }
  }

  /// Creates a new helpdesk ticket (POST /helpdesk/tickets)
  Future<HelpdeskTicketModel?> createTicket({
    required String categoryId,
    required String subject,
    required String message,
    String priority = 'normal',
    bool isConfidential = false,
  }) async {
    final methodTag = '$_originTag -> createTicket(subject: $subject)';
    try {
      final payload = {
        'category': categoryId,
        'subject': subject,
        'body': message,
        'priority': priority,
      };

      final response = await ApiClient.request(
        endpoint: ApiEndpoints.helpdeskTickets,
        method: HttpMethod.post,
        body: payload,
        tag: methodTag,
        showToastOnError: true,
      );

      if (response != null && response is Map<String, dynamic>) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          return HelpdeskTicketModel.fromJson(data);
        }
      }
      return null;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to create ticket: $e'),
        tag: '$methodTag [${stackTrace.toString().split('\n').first}]',
        showToast: true,
      );
      return null;
    }
  }

  /// Sends a reply message on a ticket thread (POST /helpdesk/tickets/{id}/messages)
  Future<HelpdeskMessageModel?> postMessage({
    required String ticketId,
    required String body,
    List<File>? files,
  }) async {
    final methodTag = '$_originTag -> postMessage(ticketId: $ticketId)';
    try {
      final response = await ApiClient.request(
        endpoint: ApiEndpoints.helpdeskTicketMessages(ticketId),
        method: HttpMethod.post,
        body: {'body': body},
        tag: methodTag,
        showToastOnError: true,
      );

      if (response != null && response is Map<String, dynamic>) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          return HelpdeskMessageModel.fromJson(data);
        }
      }
      return null;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to post message: $e'),
        tag: '$methodTag [${stackTrace.toString().split('\n').first}]',
        showToast: true,
      );
      return null;
    }
  }

  /// Cancels an open ticket (POST /helpdesk/tickets/{id}/cancel)
  Future<bool> cancelTicket(String ticketId, {String? reason}) async {
    final methodTag = '$_originTag -> cancelTicket(ticketId: $ticketId)';
    try {
      final response = await ApiClient.request(
        endpoint: ApiEndpoints.helpdeskTicketCancel(ticketId),
        method: HttpMethod.post,
        body: reason != null ? {'reason': reason} : null,
        tag: methodTag,
        showToastOnError: true,
      );
      return response != null;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to cancel ticket: $e'),
        tag: '$methodTag [${stackTrace.toString().split('\n').first}]',
        showToast: true,
      );
      return false;
    }
  }
}
