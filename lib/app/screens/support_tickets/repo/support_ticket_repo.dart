import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../../api/api_client.dart';
import '../../../api/api_endpoints.dart';
import '../../../api/app_preferences.dart';
import '../../../api/exception_handler.dart';
import '../model/support_ticket_model.dart';

/// Repository for Support Tickets & Helpdesk (Phase 10)
/// Adheres strictly to .agents/rules/ams.md:
/// - Mandatory Origin Tagging
/// - Deserializes JSON envelope into strongly-typed models
/// - Zero fallback / dummy data injection
class SupportTicketRepo {
  static const String _originTag = 'SupportTicketRepo / SupportTicketsScreen';

  /// Fetches tickets list (GET /api/v1/support/tickets)
  /// [finished]: if true, includes resolved and closed tickets
  Future<List<SupportTicketItemModel>> fetchTickets({
    int page = 1,
    int perPage = 25,
    bool finished = false,
  }) async {
    final methodTag = '$_originTag -> fetchTickets(finished: $finished, page: $page)';
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
        if (finished) 'finished': 1,
      };

      final response = await ApiClient.request(
        endpoint: ApiEndpoints.supportTickets,
        method: HttpMethod.get,
        queryParameters: queryParams,
        tag: methodTag,
        showToastOnError: false,
      );

      if (response != null && response is Map<String, dynamic>) {
        final data = response['data'];
        if (data is List) {
          return data
              .map((item) =>
                  SupportTicketItemModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } on ApiException catch (e) {
      if (e.statusCode == 403) rethrow;
      return [];
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to fetch support tickets: $e'),
        tag: '$methodTag [${stackTrace.toString().split('\n').first}]',
        showToast: false,
      );
      return [];
    }
  }

  /// Fetches ticket discussion thread (GET /api/v1/support/tickets/{id})
  Future<SupportTicketDetailsModel?> fetchTicketDetails(String id) async {
    final methodTag = '$_originTag -> fetchTicketDetails($id)';
    try {
      final response = await ApiClient.request(
        endpoint: ApiEndpoints.supportTicketDetails(id),
        method: HttpMethod.get,
        tag: methodTag,
        showToastOnError: true,
      );

      if (response != null && response is Map<String, dynamic>) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          return SupportTicketDetailsModel.fromJson(data);
        }
      }
      return null;
    } on ApiException catch (e) {
      if (e.statusCode == 403 || e.statusCode == 404) rethrow;
      return null;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to fetch ticket thread: $e'),
        tag: '$methodTag [${stackTrace.toString().split('\n').first}]',
        showToast: true,
      );
      return null;
    }
  }

  /// Opens a new support ticket (POST /api/v1/support/tickets)
  /// Supports both standard JSON and multipart when files are attached
  Future<SupportTicketDetailsModel?> createTicket({
    required String subject,
    required String body,
    String? category,
    String? priority,
    String? pageUrl,
    List<File>? attachments,
  }) async {
    const methodTag = '$_originTag -> createTicket()';
    try {
      // 1. Multipart submission if attachments are present
      if (attachments != null && attachments.isNotEmpty) {
        final fields = <String, String>{
          'subject': subject.trim(),
          'body': body.trim(),
          if (category != null && category.isNotEmpty) 'category': category,
          if (priority != null && priority.isNotEmpty) 'priority': priority,
          if (pageUrl != null && pageUrl.isNotEmpty) 'page_url': pageUrl.trim(),
        };

        final files = <http.MultipartFile>[];
        for (final file in attachments) {
          if (await file.exists()) {
            final multipart = await http.MultipartFile.fromPath(
              'attachments[]',
              file.path,
            );
            files.add(multipart);
          }
        }

        final response = await ApiClient.requestMultipart(
          method: HttpMethod.post,
          endpoint: ApiEndpoints.supportTickets,
          fields: fields,
          files: files,
          tag: '$methodTag [Multipart]',
          showToastOnError: true,
        );

        if (response != null && response is Map<String, dynamic>) {
          final data = response['data'];
          if (data is Map<String, dynamic>) {
            return SupportTicketDetailsModel.fromJson(data);
          }
        }
        return null;
      }

      // 2. Standard JSON submission
      final requestBody = <String, dynamic>{
        'subject': subject.trim(),
        'body': body.trim(),
        if (category != null && category.isNotEmpty) 'category': category,
        if (priority != null && priority.isNotEmpty) 'priority': priority,
        if (pageUrl != null && pageUrl.isNotEmpty) 'page_url': pageUrl.trim(),
      };

      final response = await ApiClient.request(
        endpoint: ApiEndpoints.supportTickets,
        method: HttpMethod.post,
        body: requestBody,
        tag: methodTag,
        showToastOnError: true,
      );

      if (response != null && response is Map<String, dynamic>) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          return SupportTicketDetailsModel.fromJson(data);
        }
      }
      return null;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to create support ticket: $e'),
        tag: '$methodTag [${stackTrace.toString().split('\n').first}]',
        showToast: true,
      );
      return null;
    }
  }

  /// Appends a reply to an open support ticket (POST /api/v1/support/tickets/{id}/replies)
  Future<SupportTicketDetailsModel?> replyTicket(
    String ticketId, {
    required String body,
    List<File>? attachments,
  }) async {
    final methodTag = '$_originTag -> replyTicket($ticketId)';
    try {
      if (attachments != null && attachments.isNotEmpty) {
        final fields = <String, String>{
          'body': body.trim(),
        };

        final files = <http.MultipartFile>[];
        for (final file in attachments) {
          if (await file.exists()) {
            final multipart = await http.MultipartFile.fromPath(
              'attachments[]',
              file.path,
            );
            files.add(multipart);
          }
        }

        final response = await ApiClient.requestMultipart(
          method: HttpMethod.post,
          endpoint: ApiEndpoints.supportTicketReplies(ticketId),
          fields: fields,
          files: files,
          tag: '$methodTag [Multipart]',
          showToastOnError: true,
        );

        if (response != null && response is Map<String, dynamic>) {
          final data = response['data'];
          if (data is Map<String, dynamic>) {
            return SupportTicketDetailsModel.fromJson(data);
          }
        }
        return null;
      }

      final response = await ApiClient.request(
        endpoint: ApiEndpoints.supportTicketReplies(ticketId),
        method: HttpMethod.post,
        body: {'body': body.trim()},
        tag: methodTag,
        showToastOnError: true,
      );

      if (response != null && response is Map<String, dynamic>) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          return SupportTicketDetailsModel.fromJson(data);
        }
      }
      return null;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to send reply: $e'),
        tag: '$methodTag [${stackTrace.toString().split('\n').first}]',
        showToast: true,
      );
      return null;
    }
  }

  /// Closes an active ticket (POST /api/v1/support/tickets/{id}/close)
  Future<SupportTicketDetailsModel?> closeTicket(String ticketId) async {
    final methodTag = '$_originTag -> closeTicket($ticketId)';
    try {
      final response = await ApiClient.request(
        endpoint: ApiEndpoints.supportTicketClose(ticketId),
        method: HttpMethod.post,
        tag: methodTag,
        showToastOnError: true,
      );

      if (response != null && response is Map<String, dynamic>) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          return SupportTicketDetailsModel.fromJson(data);
        }
      }
      return null;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to close ticket: $e'),
        tag: '$methodTag [${stackTrace.toString().split('\n').first}]',
        showToast: true,
      );
      return null;
    }
  }

  /// Reopens a resolved ticket (POST /api/v1/support/tickets/{id}/reopen)
  Future<SupportTicketDetailsModel?> reopenTicket(String ticketId) async {
    final methodTag = '$_originTag -> reopenTicket($ticketId)';
    try {
      final response = await ApiClient.request(
        endpoint: ApiEndpoints.supportTicketReopen(ticketId),
        method: HttpMethod.post,
        tag: methodTag,
        showToastOnError: true,
      );

      if (response != null && response is Map<String, dynamic>) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          return SupportTicketDetailsModel.fromJson(data);
        }
      }
      return null;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to reopen ticket: $e'),
        tag: '$methodTag [${stackTrace.toString().split('\n').first}]',
        showToast: true,
      );
      return null;
    }
  }

  /// Downloads an attachment file from a support ticket (GET /api/v1/support/tickets/{id}/files/{file})
  Future<File?> downloadAttachment(
    String ticketId,
    String fileId,
    String fileName,
  ) async {
    final methodTag = '$_originTag -> downloadAttachment($ticketId, $fileId)';
    try {
      String cleanBase = ApiEndpoints.baseUrl;
      if (cleanBase.endsWith('/')) {
        cleanBase = cleanBase.substring(0, cleanBase.length - 1);
      }
      final url = Uri.parse(
          '$cleanBase${ApiEndpoints.supportTicketFile(ticketId, fileId)}');

      final headers = <String, String>{
        'Accept': '*/*',
        'X-App-Version': '2.0.0',
      };
      final token = AppPreferences.token;
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(url, headers: headers).timeout(
            const Duration(seconds: 30),
          );

      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        final dir = await getApplicationDocumentsDirectory();
        final sanitized = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
        final filePath = '${dir.path}/support_${ticketId}_$sanitized';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes, flush: true);
        return file;
      } else {
        throw ApiException(
          message:
              'Failed to download attachment (HTTP ${response.statusCode})',
          statusCode: response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Attachment download error: $e'),
        tag: '$methodTag [${stackTrace.toString().split('\n').first}]',
        showToast: true,
      );
      return null;
    }
  }
}
