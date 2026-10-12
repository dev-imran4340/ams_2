import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../core/widgets/custom_snackbar.dart';
import '../routes/app_routes.dart';
import 'app_preferences.dart';

/// Standard Application & API Exception
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;
  final Map<String, dynamic>? validationErrors;

  ApiException({
    required this.message,
    this.statusCode,
    this.errorCode,
    this.validationErrors,
  });

  @override
  String toString() => message;
}

// Alias for backwards compatibility if needed
typedef AppException = ApiException;

class ExceptionHandler {
  /// Centralized handler for exceptions and HTTP response statuses with mandatory Origin Tagging
  static ApiException handle(
    dynamic error, {
    required String tag,
    bool showToast = true,
  }) {
    ApiException apiException;

    if (error is SocketException) {
      apiException = ApiException(
        message: 'No internet connection. Please verify your network and retry.',
        errorCode: 'NO_INTERNET',
      );
    } else if (error is TimeoutException) {
      apiException = ApiException(
        message: 'Request timed out. Please try again later.',
        errorCode: 'TIMEOUT',
      );
    } else if (error is FormatException) {
      apiException = ApiException(
        message: 'Invalid response format received from server.',
        errorCode: 'FORMAT_EXCEPTION',
      );
    } else if (error is ApiException) {
      apiException = error;
    } else {
      apiException = ApiException(
        message: error?.toString() ?? 'An unexpected error occurred.',
        errorCode: 'UNKNOWN_ERROR',
      );
    }

    // Mandatory Origin Tagging & Tracer Logging in kDebugMode
    if (kDebugMode) {
      final buffer = StringBuffer();
      buffer.writeln('\n🚨 ==================== [EXCEPTION TRACER] ====================');
      buffer.writeln('📍 ORIGIN / SCREEN : $tag');
      if (apiException.statusCode != null) {
        buffer.writeln('⬅️ STATUS CODE    : ${apiException.statusCode}');
      }
      if (apiException.errorCode != null) {
        buffer.writeln('🏷️ ERROR CODE     : ${apiException.errorCode}');
      }
      buffer.writeln('❌ ERROR DETAILS   : ${apiException.message}');
      buffer.writeln('==============================================================\n');
      Get.log(buffer.toString());
    }

    if (showToast && apiException.message.isNotEmpty) {
      try {
        CustomSnackbar.showError(
          title: _getErrorTitle(apiException.statusCode),
          message: apiException.message,
        );
      } catch (_) {}
    }

    return apiException;
  }

  /// Processes HTTP status codes outside 200/201
  static ApiException handleResponse(
    int statusCode,
    String responseBody, {
    required String tag,
    bool showToast = true,
  }) {
    String message = 'Something went wrong';
    String? errorCode;
    Map<String, dynamic>? validationErrors;

    // Check for HTML response (e.g. Cloudflare / 502 / Nginx HTML error pages)
    final trimmed = responseBody.trim().toLowerCase();
    if (trimmed.startsWith('<!doctype html') || trimmed.startsWith('<html')) {
      message = 'Server returned HTML instead of JSON (HTTP $statusCode).';
    } else {
      try {
        final decoded = jsonDecode(responseBody);
        if (decoded is Map<String, dynamic>) {
          if (decoded.containsKey('message') && decoded['message'] != null) {
            message = decoded['message'].toString();
          }
          if (decoded.containsKey('error_code') && decoded['error_code'] != null) {
            errorCode = decoded['error_code'].toString();
          }
          if (decoded.containsKey('errors') &&
              decoded['errors'] is Map<String, dynamic>) {
            validationErrors = decoded['errors'] as Map<String, dynamic>;
            if (validationErrors.isNotEmpty) {
              final firstKey = validationErrors.keys.first;
              final firstVal = validationErrors[firstKey];
              if (firstVal is List && firstVal.isNotEmpty) {
                message = firstVal.first.toString();
              }
            }
          }
        }
      } catch (_) {
        message = _getDefaultMessageForStatusCode(statusCode);
      }
    }

    // Auto-clear auth on 401 Unauthorized and redirect to login if currently on a protected route
    if (statusCode == 401) {
      AppPreferences.clearAuth();
      if (Get.currentRoute.isNotEmpty &&
          Get.currentRoute != Routes.LOGIN &&
          Get.currentRoute != Routes.SPLASH) {
        Get.offAllNamed(Routes.LOGIN);
      }
    }

    final apiException = ApiException(
      message: message,
      statusCode: statusCode,
      errorCode: errorCode,
      validationErrors: validationErrors,
    );

    return handle(apiException, tag: tag, showToast: showToast);
  }

  static String _getErrorTitle(int? statusCode) {
    if (statusCode == null) return 'Connection Error';
    if (statusCode == 401) return 'Session Expired';
    if (statusCode == 403) return 'Access Denied';
    if (statusCode == 404) return 'Not Found';
    if (statusCode == 422) return 'Validation Failed';
    if (statusCode >= 500) return 'Server Error';
    return 'Error';
  }

  static String _getDefaultMessageForStatusCode(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request. Please check your submission.';
      case 401:
        return 'Session expired. Please log in again.';
      case 403:
        return 'You do not have permission to perform this action.';
      case 404:
        return 'Requested resource was not found.';
      case 422:
        return 'Validation failed on the submitted data.';
      case 500:
      case 502:
      case 503:
      case 504:
        return 'Internal server error. Please try again shortly.';
      default:
        return 'Unexpected server response (HTTP $statusCode).';
    }
  }
}
