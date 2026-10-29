import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../../api/api_client.dart';
import '../../../api/api_endpoints.dart';
import '../../../api/app_preferences.dart';
import '../../../api/exception_handler.dart';
import '../model/payroll_model.dart';

class PayrollRepo {
  static const String _originTag = 'PayrollRepo / PayrollScreen';

  /// Fetches historical finalized payslips for authenticated employee (GET /api/v1/me/payslips)
  Future<List<PayslipSummaryModel>> fetchPayslips() async {
    const methodTag = '$_originTag -> fetchPayslips()';
    try {
      final response = await ApiClient.request(
        endpoint: ApiEndpoints.mePayslips,
        method: HttpMethod.get,
        tag: methodTag,
        showToastOnError: false,
      );

      if (response != null && response is Map<String, dynamic>) {
        final data = response['data'];
        if (data is List) {
          return data
              .map((item) =>
                  PayslipSummaryModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
      }
      return [];
    } on ApiException catch (e) {
      if (e.statusCode == 403) {
        rethrow;
      }
      return [];
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to fetch payslips: $e'),
        tag: '$methodTag [${stackTrace.toString().split('\n').first}]',
        showToast: false,
      );
      return [];
    }
  }

  /// Fetches comprehensive itemized breakdown of a payslip (GET /api/v1/me/payslips/{id})
  Future<PayslipDetailsModel?> fetchPayslipDetails(String id) async {
    final methodTag = '$_originTag -> fetchPayslipDetails($id)';
    try {
      final response = await ApiClient.request(
        endpoint: ApiEndpoints.mePayslipDetails(id),
        method: HttpMethod.get,
        tag: methodTag,
        showToastOnError: true,
      );

      if (response != null && response is Map<String, dynamic>) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          return PayslipDetailsModel.fromJson(data);
        }
      }
      return null;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to fetch payslip details: $e'),
        tag: '$methodTag [${stackTrace.toString().split('\n').first}]',
        showToast: false,
      );
      return null;
    }
  }

  /// Fetches active salary structure and formula lines (GET /api/v1/me/salary)
  Future<SalaryStructureModel?> fetchActiveSalary() async {
    const methodTag = '$_originTag -> fetchActiveSalary()';
    try {
      final response = await ApiClient.request(
        endpoint: ApiEndpoints.meSalary,
        method: HttpMethod.get,
        tag: methodTag,
        showToastOnError: false,
      );

      if (response != null && response is Map<String, dynamic>) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          return SalaryStructureModel.fromJson(data);
        }
      }
      return null;
    } on ApiException catch (e) {
      if (e.statusCode == 403) {
        rethrow;
      }
      return null;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to fetch active salary: $e'),
        tag: '$methodTag [${stackTrace.toString().split('\n').first}]',
        showToast: false,
      );
      return null;
    }
  }

  /// Downloads official payslip PDF byte stream and saves locally (GET /api/v1/me/payslips/{id}/pdf)
  Future<File?> downloadPayslipPdf(String payslipId, {String? periodLabel}) async {
    final methodTag = '$_originTag -> downloadPayslipPdf($payslipId)';
    try {
      String cleanBase = ApiEndpoints.baseUrl;
      if (cleanBase.endsWith('/')) {
        cleanBase = cleanBase.substring(0, cleanBase.length - 1);
      }
      final url = Uri.parse('$cleanBase${ApiEndpoints.mePayslipPdf(payslipId)}');

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
        final sanitizedLabel = (periodLabel ?? 'Payslip_$payslipId')
            .replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
        final filePath = '${dir.path}/$sanitizedLabel.pdf';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes, flush: true);
        return file;
      } else {
        throw ApiException(
          message: 'Failed to download payslip PDF (HTTP ${response.statusCode})',
          statusCode: response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'PDF download error: $e'),
        tag: '$methodTag [${stackTrace.toString().split('\n').first}]',
        showToast: true,
      );
      return null;
    }
  }
}
