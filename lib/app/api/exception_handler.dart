import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../core/widgets/custom_snackbar.dart';
import '../routes/app_routes.dart';
import 'app_preferences.dart';

/// Standard Application & API Exception
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;
  final Map<String, dynamic>? validationErrors;
  final int? retryAfterSeconds;

  ApiException({
    required this.message,
    this.statusCode,
    String? errorCode,
    String? code,
    Map<String, dynamic>? validationErrors,
    Map<String, dynamic>? fields,
    this.retryAfterSeconds,
  })  : errorCode = errorCode ?? code,
        validationErrors = validationErrors ?? fields;

  /// Alias for errorCode
  String? get code => errorCode;

  /// Alias for validationErrors
  Map<String, dynamic>? get fields => validationErrors;

  /// True when the user token is invalid, expired, or credentials failed
  bool get isUnauthenticated =>
      statusCode == 401 ||
      errorCode == 'unauthenticated' ||
      errorCode == 'invalid_credentials' ||
      errorCode == 'invalid_two_factor_code';

  /// True when input validation failed on the backend (HTTP 422)
  bool get isValidationFailed =>
      statusCode == 422 || errorCode == 'validation_failed';

  /// True when the account or company is locked/disabled (HTTP 403)
  bool get isAccountUnavailable => errorCode == 'account_unavailable';

  /// True when a business rule conflict occurred (HTTP 409)
  bool get isConflict => statusCode == 409 || errorCode == 'conflict';

  /// True when rate limit threshold was breached (HTTP 429)
  bool get isRateLimited =>
      statusCode == 429 || errorCode == 'too_many_requests';

  /// True when connection or timeout prevented reaching the server
  bool get isNetworkError =>
      errorCode == 'NO_INTERNET' ||
      errorCode == 'NETWORK_ERROR' ||
      errorCode == 'TIMEOUT' ||
      errorCode == 'SSL_ERROR';

  /// Extracts the first validation error message from the fields map
  String? get firstValidationError {
    if (validationErrors == null || validationErrors!.isEmpty) return null;
    final firstVal = validationErrors!.values.first;
    if (firstVal is List && firstVal.isNotEmpty) {
      return firstVal.first.toString();
    }
    return firstVal?.toString();
  }

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
        message: 'Request timed out. The server took too long to respond.',
        errorCode: 'TIMEOUT',
      );
    } else if (error is http.ClientException) {
      apiException = ApiException(
        message: 'Network connection was interrupted. Please check your signal and retry.',
        errorCode: 'NETWORK_ERROR',
      );
    } else if (error is HandshakeException || error is CertificateException) {
      apiException = ApiException(
        message: 'Secure connection could not be established. Please verify system date/time or network security.',
        errorCode: 'SSL_ERROR',
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
      if (apiException.retryAfterSeconds != null) {
        buffer.writeln('⏳ RETRY AFTER    : ${apiException.retryAfterSeconds}s');
      }
      buffer.writeln('❌ ERROR DETAILS   : ${apiException.message}');
      if (apiException.validationErrors != null) {
        buffer.writeln('📋 VALIDATION MAP : ${apiException.validationErrors}');
      }
      buffer.writeln('==============================================================\n');
      Get.log(buffer.toString());
    }

    if (showToast && apiException.message.isNotEmpty) {
      try {
        CustomSnackbar.showError(
          title: _getErrorTitle(apiException.statusCode, apiException.errorCode),
          message: apiException.message,
        );
      } catch (_) {}
    }

    return apiException;
  }

  /// Processes HTTP status codes outside 200, 201, 204
  static ApiException handleResponse(
    int statusCode,
    String responseBody, {
    Map<String, String>? headers,
    required String tag,
    bool showToast = true,
  }) {
    String message = 'Something went wrong';
    String? errorCode;
    Map<String, dynamic>? validationErrors;
    int? retryAfterSeconds;

    // Parse Retry-After header if present (standard for 429 too_many_requests)
    if (headers != null) {
      final retryHeader = headers['retry-after'] ?? headers['Retry-After'];
      if (retryHeader != null) {
        retryAfterSeconds = int.tryParse(retryHeader.trim());
      }
    }

    // Check for HTML response (e.g. Cloudflare / 502 / Nginx HTML error pages)
    final trimmed = responseBody.trim().toLowerCase();
    if (trimmed.startsWith('<!doctype html') || trimmed.startsWith('<html')) {
      message = 'Server returned HTML instead of JSON (HTTP $statusCode).';
      errorCode = 'HTML_RESPONSE_BLOCKED';
    } else {
      try {
        final decoded = jsonDecode(responseBody);
        if (decoded is Map<String, dynamic>) {
          // Support official AMS API v1 error envelope from doc/api.md:
          // { "error": { "code": "...", "message": "...", "fields": {...} } }
          if (decoded.containsKey('error') &&
              decoded['error'] is Map<String, dynamic>) {
            final errorMap = decoded['error'] as Map<String, dynamic>;
            if (errorMap.containsKey('code') && errorMap['code'] != null) {
              errorCode = errorMap['code'].toString();
            }
            if (errorMap.containsKey('message') && errorMap['message'] != null) {
              message = errorMap['message'].toString();
            }
            if (errorMap.containsKey('fields') &&
                errorMap['fields'] is Map<String, dynamic>) {
              validationErrors = errorMap['fields'] as Map<String, dynamic>;
              if (validationErrors.isNotEmpty) {
                final firstKey = validationErrors.keys.first;
                final firstVal = validationErrors[firstKey];
                if (firstVal is List && firstVal.isNotEmpty) {
                  message = firstVal.first.toString();
                }
              }
            }
          } else {
            // Fallback for standard error envelopes
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
        }
      } catch (_) {
        message = _getDefaultMessageForStatusCode(statusCode, retryAfterSeconds);
      }
    }

    // Special message for 429 if retryAfter is present
    if (statusCode == 429 && retryAfterSeconds != null && retryAfterSeconds > 0) {
      message = 'Rate limit exceeded. Please wait $retryAfterSeconds seconds before trying again.';
      errorCode = 'too_many_requests';
    }

    // Auto-clear auth on 401 Unauthorized or disabled account and redirect to login
    if (statusCode == 401 || (statusCode == 403 && errorCode == 'account_unavailable')) {
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
      retryAfterSeconds: retryAfterSeconds,
    );

    return handle(apiException, tag: tag, showToast: showToast);
  }

  static String _getErrorTitle(int? statusCode, String? errorCode) {
    if (errorCode == 'NO_INTERNET' || errorCode == 'NETWORK_ERROR') {
      return 'Network Disconnected';
    }
    if (errorCode == 'TIMEOUT') return 'Request Timeout';
    if (errorCode == 'SSL_ERROR') return 'Security Verification Failed';
    if (errorCode == 'account_unavailable') return 'Account Unavailable';
    if (errorCode == 'invalid_two_factor_code') return 'Two-Factor Failed';
    if (errorCode == 'too_many_requests' || statusCode == 429) {
      return 'Rate Limit Hit';
    }
    if (statusCode == null) return 'Connection Error';
    if (statusCode == 400) return 'Invalid Request';
    if (statusCode == 401) return 'Session Expired';
    if (statusCode == 403) return 'Access Denied';
    if (statusCode == 404) return 'Not Found';
    if (statusCode == 409) return 'Request Conflict';
    if (statusCode == 422) return 'Validation Failed';
    if (statusCode >= 500) return 'Server Error';
    return 'Error';
  }

  static String _getDefaultMessageForStatusCode(int statusCode, [int? retryAfter]) {
    switch (statusCode) {
      case 400:
        return 'Bad request. The submission could not be handled.';
      case 401:
        return 'Session expired or unauthenticated. Please log in again.';
      case 403:
        return 'You do not have permission to perform this action.';
      case 404:
        return 'Requested resource was not found.';
      case 409:
        return 'Operation conflicted with current business rules.';
      case 422:
        return 'Validation failed on the submitted information.';
      case 429:
        return retryAfter != null
            ? 'Too many requests. Please wait $retryAfter seconds before trying again.'
            : 'Too many requests. Please wait a moment and try again.';
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
