import 'package:http/http.dart' as http;

import '../../../api/api_client.dart';
import '../../../api/api_endpoints.dart';
import '../../../api/exception_handler.dart';
import '../model/money_request_model.dart';

class MoneyRequestRepo {
  static const String _originTag = 'MoneyRequestRepo / LoansScreen';

  /// Fetches eligible request types and expense categories (GET /api/v1/me/money-request-types)
  Future<MoneyRequestTypesResponse?> fetchMoneyRequestTypes() async {
    const methodTag = '$_originTag -> fetchMoneyRequestTypes()';
    try {
      final response = await ApiClient.request(
        endpoint: ApiEndpoints.meMoneyRequestTypes,
        method: HttpMethod.get,
        tag: methodTag,
        showToastOnError: false,
      );

      if (response != null && response is Map<String, dynamic>) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          return MoneyRequestTypesResponse.fromJson(data);
        }
      }
      return null;
    } on ApiException catch (e) {
      if (e.statusCode == 403) rethrow;
      return null;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to fetch money request types: $e'),
        tag: '$methodTag [${stackTrace.toString().split('\n').first}]',
        showToast: false,
      );
      return null;
    }
  }

  /// Lists authenticated employee's money requests (GET /api/v1/me/money-requests)
  Future<List<MoneyRequestItemModel>> fetchMoneyRequests({
    int page = 1,
    int perPage = 25,
  }) async {
    final methodTag = '$_originTag -> fetchMoneyRequests(page: $page)';
    try {
      final response = await ApiClient.request(
        endpoint: ApiEndpoints.meMoneyRequests,
        method: HttpMethod.get,
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
        tag: methodTag,
        showToastOnError: false,
      );

      if (response != null && response is Map<String, dynamic>) {
        final data = response['data'];
        if (data is List) {
          return data
              .map((item) => MoneyRequestItemModel.fromJson(
                  Map<String, dynamic>.from(item)))
              .toList();
        }
      }
      return [];
    } on ApiException catch (e) {
      if (e.statusCode == 403) rethrow;
      return [];
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to fetch money requests: $e'),
        tag: '$methodTag [${stackTrace.toString().split('\n').first}]',
        showToast: false,
      );
      return [];
    }
  }

  /// Fetches comprehensive details, repayment schedule and recoveries (GET /api/v1/me/money-requests/{id})
  Future<MoneyRequestItemModel?> fetchMoneyRequestDetails(String id) async {
    final methodTag = '$_originTag -> fetchMoneyRequestDetails($id)';
    try {
      final response = await ApiClient.request(
        endpoint: ApiEndpoints.meMoneyRequestDetails(id),
        method: HttpMethod.get,
        tag: methodTag,
        showToastOnError: true,
      );

      if (response != null && response is Map<String, dynamic>) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          return MoneyRequestItemModel.fromJson(data);
        }
      }
      return null;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to fetch money request details: $e'),
        tag: '$methodTag [${stackTrace.toString().split('\n').first}]',
        showToast: false,
      );
      return null;
    }
  }

  /// Submits an advance, staff loan or itemized expense claim (POST /api/v1/me/money-requests)
  Future<MoneyRequestItemModel?> submitMoneyRequest({
    required String typeId,
    String? amount,
    int? instalments,
    String? reason,
    List<ExpenseDraftLine>? expenseLines,
  }) async {
    const methodTag = '$_originTag -> submitMoneyRequest()';
    try {
      // 1. If expense claim with receipt files -> multipart upload
      final bool hasReceipts = expenseLines != null &&
          expenseLines.any((line) => line.receiptFile != null);

      if (hasReceipts) {
        final fields = <String, String>{
          'type': typeId,
          if (reason != null && reason.trim().isNotEmpty)
            'reason': reason.trim(),
        };

        for (int i = 0; i < expenseLines.length; i++) {
          final line = expenseLines[i];
          fields['lines[$i][category]'] = line.categoryId;
          fields['lines[$i][spent_on]'] = line.spentOn;
          fields['lines[$i][amount]'] = line.amount;
          if (line.note.isNotEmpty) {
            fields['lines[$i][note]'] = line.note;
          }
        }

        final files = <http.MultipartFile>[];
        for (int i = 0; i < expenseLines.length; i++) {
          final file = expenseLines[i].receiptFile;
          if (file != null) {
            files.add(
              await http.MultipartFile.fromPath(
                'receipts[$i]',
                file.path,
              ),
            );
          }
        }

        final response = await ApiClient.requestMultipart(
          method: HttpMethod.post,
          endpoint: ApiEndpoints.meMoneyRequests,
          fields: fields,
          files: files,
          tag: methodTag,
          showToastOnError: true,
        );

        if (response != null && response is Map<String, dynamic>) {
          final data = response['data'];
          if (data is Map<String, dynamic>) {
            return MoneyRequestItemModel.fromJson(data);
          }
        }
        return null;
      }

      // 2. Standard JSON submission for Loans, Advances, or expenses without files
      final body = <String, dynamic>{
        'type': typeId,
        if (amount != null && amount.isNotEmpty) 'amount': amount,
        'instalments': ?instalments,
        if (reason != null && reason.trim().isNotEmpty)
          'reason': reason.trim(),
      };

      if (expenseLines != null && expenseLines.isNotEmpty) {
        body['lines'] = expenseLines
            .map((line) => {
                  'category': line.categoryId,
                  'spent_on': line.spentOn,
                  'amount': line.amount,
                  if (line.note.isNotEmpty) 'note': line.note,
                })
            .toList();
      }

      final response = await ApiClient.request(
        endpoint: ApiEndpoints.meMoneyRequests,
        method: HttpMethod.post,
        body: body,
        tag: methodTag,
        showToastOnError: true,
      );

      if (response != null && response is Map<String, dynamic>) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          return MoneyRequestItemModel.fromJson(data);
        }
      }
      return null;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to submit money request: $e'),
        tag: '$methodTag [${stackTrace.toString().split('\n').first}]',
        showToast: true,
      );
      return null;
    }
  }

  /// Cancels / withdraws a pending money request (POST /api/v1/me/money-requests/{id}/cancel)
  Future<bool> cancelMoneyRequest(String id, {String? reason}) async {
    final methodTag = '$_originTag -> cancelMoneyRequest($id)';
    try {
      final body = <String, dynamic>{
        if (reason != null && reason.trim().isNotEmpty)
          'reason': reason.trim(),
      };

      final response = await ApiClient.request(
        endpoint: ApiEndpoints.meMoneyRequestCancel(id),
        method: HttpMethod.post,
        body: body,
        tag: methodTag,
        showToastOnError: true,
      );

      return response != null;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to cancel money request: $e'),
        tag: '$methodTag [${stackTrace.toString().split('\n').first}]',
        showToast: true,
      );
      return false;
    }
  }
}
