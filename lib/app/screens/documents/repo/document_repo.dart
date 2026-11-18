import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../../api/api_client.dart';
import '../../../api/api_endpoints.dart';
import '../../../api/app_preferences.dart';
import '../../../api/exception_handler.dart';
import '../model/document_model.dart';

class DocumentRepo {
  final String _originTag = 'DocumentRepo / DocumentsScreen';

  /// GET /me/documents
  /// Fetches employee's central document repository: files, expiring, policiesToAccept, letters, letterRequests, requestableLetters
  Future<MeDocumentsModel> fetchMeDocuments() async {
    final methodTag = '$_originTag -> fetchMeDocuments()';
    try {
      final response = await ApiClient.request(
        method: HttpMethod.get,
        endpoint: ApiEndpoints.meDocuments,
        tag: methodTag,
      );

      if (response != null && response['data'] is Map<String, dynamic>) {
        return MeDocumentsModel.fromJson(response['data'] as Map<String, dynamic>);
      }
      return const MeDocumentsModel();
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to fetch personal documents: $e'),
        tag: '$methodTag [${stackTrace.toString().split('\n').first}]',
        showToast: false,
      );
      return const MeDocumentsModel();
    }
  }

  /// GET /company-documents
  /// Fetches published and active company documents/handbooks
  Future<List<CompanyDocumentListItemModel>> fetchCompanyDocuments() async {
    final methodTag = '$_originTag -> fetchCompanyDocuments()';
    try {
      final response = await ApiClient.request(
        method: HttpMethod.get,
        endpoint: ApiEndpoints.companyDocuments,
        tag: methodTag,
      );

      if (response != null && response['data'] is List) {
        return (response['data'] as List)
            .whereType<Map<String, dynamic>>()
            .map((item) => CompanyDocumentListItemModel.fromJson(item))
            .toList();
      }
      return const [];
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to fetch company documents: $e'),
        tag: '$methodTag [${stackTrace.toString().split('\n').first}]',
        showToast: false,
      );
      return const [];
    }
  }

  /// GET /company-documents/{id}
  /// Fetches full policy entry with current_version and versions list
  Future<CompanyDocumentDetailsModel?> fetchCompanyDocumentDetails(String id) async {
    final methodTag = '$_originTag -> fetchCompanyDocumentDetails($id)';
    try {
      final response = await ApiClient.request(
        method: HttpMethod.get,
        endpoint: ApiEndpoints.companyDocumentDetails(id),
        tag: methodTag,
      );

      if (response != null && response['data'] is Map<String, dynamic>) {
        return CompanyDocumentDetailsModel.fromJson(response['data'] as Map<String, dynamic>);
      }
      return null;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to fetch company document details: $e'),
        tag: '$methodTag [${stackTrace.toString().split('\n').first}]',
        showToast: true,
      );
      return null;
    }
  }

  /// POST /company-documents/{id}/acknowledge
  /// Submits electronic acknowledgment for the policy's current version
  Future<CompanyDocumentDetailsModel?> acknowledgePolicy(String id) async {
    final methodTag = '$_originTag -> acknowledgePolicy($id)';
    try {
      final response = await ApiClient.request(
        method: HttpMethod.post,
        endpoint: ApiEndpoints.companyDocumentAcknowledge(id),
        tag: methodTag,
      );

      if (response != null && response['data'] is Map<String, dynamic>) {
        return CompanyDocumentDetailsModel.fromJson(response['data'] as Map<String, dynamic>);
      }
      return null;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to acknowledge policy: $e'),
        tag: '$methodTag [${stackTrace.toString().split('\n').first}]',
        showToast: true,
      );
      return null;
    }
  }

  /// POST /me/letter-requests
  /// Submits a request for an official company letter (template + purpose)
  Future<LetterRequestItemModel?> requestLetter({
    required String templateId,
    required String purpose,
  }) async {
    final methodTag = '$_originTag -> requestLetter()';
    try {
      final response = await ApiClient.request(
        method: HttpMethod.post,
        endpoint: ApiEndpoints.meLetterRequests,
        body: {
          'template': templateId,
          'purpose': purpose,
        },
        tag: methodTag,
      );

      if (response != null && response['data'] is Map<String, dynamic>) {
        return LetterRequestItemModel.fromJson(response['data'] as Map<String, dynamic>);
      }
      return null;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to submit letter request: $e'),
        tag: '$methodTag [${stackTrace.toString().split('\n').first}]',
        showToast: true,
      );
      return null;
    }
  }

  /// Downloads and caches an issued letter PDF (GET /letters/{id}/pdf)
  Future<File?> downloadLetterPdf(String letterId, {String? reference}) async {
    final methodTag = '$_originTag -> downloadLetterPdf($letterId)';
    try {
      String cleanBase = ApiEndpoints.baseUrl;
      if (cleanBase.endsWith('/')) {
        cleanBase = cleanBase.substring(0, cleanBase.length - 1);
      }
      final url = Uri.parse('$cleanBase${ApiEndpoints.letterPdf(letterId)}');

      final headers = <String, String>{
        'Accept': 'application/pdf',
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
        final sanitized = (reference ?? 'Letter_$letterId')
            .replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
        final file = File('${dir.path}/$sanitized.pdf');
        await file.writeAsBytes(response.bodyBytes, flush: true);
        return file;
      } else {
        throw ApiException(
          message: 'Failed to download letter PDF (HTTP ${response.statusCode})',
          statusCode: response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Letter download error: $e'),
        tag: '$methodTag [${stackTrace.toString().split('\n').first}]',
        showToast: true,
      );
      return null;
    }
  }

  /// Downloads personal uploaded document file (GET /me/documents/files/{id})
  Future<File?> downloadDocumentFile(String fileId, {required String fileName}) async {
    final methodTag = '$_originTag -> downloadDocumentFile($fileId)';
    try {
      String cleanBase = ApiEndpoints.baseUrl;
      if (cleanBase.endsWith('/')) {
        cleanBase = cleanBase.substring(0, cleanBase.length - 1);
      }
      final url = Uri.parse('$cleanBase${ApiEndpoints.meDocumentFile(fileId)}');

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
        final file = File('${dir.path}/$sanitized');
        await file.writeAsBytes(response.bodyBytes, flush: true);
        return file;
      } else {
        throw ApiException(
          message: 'Failed to download document (HTTP ${response.statusCode})',
          statusCode: response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Document download error: $e'),
        tag: '$methodTag [${stackTrace.toString().split('\n').first}]',
        showToast: true,
      );
      return null;
    }
  }

  /// Downloads company document file (GET /company-documents/{id}/versions/{version}/file)
  Future<File?> downloadCompanyPolicyFile(
    String id,
    int version, {
    required String fileName,
  }) async {
    final methodTag = '$_originTag -> downloadCompanyPolicyFile($id, $version)';
    try {
      String cleanBase = ApiEndpoints.baseUrl;
      if (cleanBase.endsWith('/')) {
        cleanBase = cleanBase.substring(0, cleanBase.length - 1);
      }
      final url = Uri.parse('$cleanBase${ApiEndpoints.companyDocumentVersionFile(id, version)}');

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
        final file = File('${dir.path}/$sanitized');
        await file.writeAsBytes(response.bodyBytes, flush: true);
        return file;
      } else {
        throw ApiException(
          message: 'Failed to download policy file (HTTP ${response.statusCode})',
          statusCode: response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Policy file download error: $e'),
        tag: '$methodTag [${stackTrace.toString().split('\n').first}]',
        showToast: true,
      );
      return null;
    }
  }
}
