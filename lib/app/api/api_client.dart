import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'api_endpoints.dart';
import 'app_preferences.dart';
import 'exception_handler.dart';

enum HttpMethod { get, post, put, patch, delete }

/// Enterprise-grade, centralized HTTP network engine for the entire AMS 2 suite.
/// Strictly enforces the Layer Flow Policy: View -> Controller -> Repository -> ApiClient.
class ApiClient {
  static const Duration timeoutDuration = Duration(seconds: 30);

  /// Pre-flight Internet check with platform-safe exception fallback
  static Future<bool> hasInternetConnection() async {
    try {
      final connectivityResults = await Connectivity().checkConnectivity();
      if (connectivityResults.contains(ConnectivityResult.none) ||
          connectivityResults.isEmpty) {
        return false;
      }
      return true;
    } catch (_) {
      // In case of platform channel error, allow the request to attempt standard socket connection
      return true;
    }
  }

  /// Default headers with Auth Bearer token, device binding, and JSON content-type
  static Map<String, String> _buildHeaders(Map<String, String>? customHeaders) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-App-Version': '2.0.0',
      'X-Client-Platform': defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
    };

    final token = AppPreferences.token;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final deviceId = AppPreferences.deviceId;
    if (deviceId != null && deviceId.isNotEmpty) {
      headers['X-Device-Id'] = deviceId;
    }

    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }

    return headers;
  }

  /// Formats URI ensuring baseUrl and endpoints are parsed accurately with query parameters
  static Uri _buildUri(String endpoint, Map<String, dynamic>? queryParameters) {
    String cleanBase = ApiEndpoints.baseUrl;
    if (cleanBase.endsWith('/')) {
      cleanBase = cleanBase.substring(0, cleanBase.length - 1);
    }

    String cleanEndpoint = endpoint;
    if (!cleanEndpoint.startsWith('/')) {
      cleanEndpoint = '/$cleanEndpoint';
    }

    final fullUrl = '$cleanBase$cleanEndpoint';
    final parsed = Uri.parse(fullUrl);

    if (queryParameters != null && queryParameters.isNotEmpty) {
      final stringParams = queryParameters.map(
        (key, value) => MapEntry(key, value.toString()),
      );
      return parsed.replace(queryParameters: stringParams);
    }

    return parsed;
  }

  /// Generalized Request Handler (GET, POST, PUT, PATCH, DELETE)
  static Future<dynamic> request({
    required HttpMethod method,
    required String endpoint,
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    String tag = 'ApiClient -> request()',
    bool showToastOnError = true,
  }) async {
    // 1. Pre-flight internet check
    if (!await hasInternetConnection()) {
      final ex = ExceptionHandler.handle(
        ApiException(
          message: 'No internet connection. Please verify your network.',
          errorCode: 'NO_INTERNET',
        ),
        tag: tag,
        showToast: showToastOnError,
      );
      throw ex;
    }

    final uri = _buildUri(endpoint, queryParameters);
    final requestHeaders = _buildHeaders(headers);
    final encodedBody = (body != null && body is! String)
        ? jsonEncode(body)
        : (body is String ? body : null);

    // 2. Debug Logging (Request)
    final stopwatch = Stopwatch()..start();
    if (kDebugMode) {
      Get.log(
        '🌐 [API Request] ${method.name.toUpperCase()} -> $uri\n'
        'Origin: $tag\n'
        'Headers: $requestHeaders\n'
        'Params: $queryParameters\n'
        'Body: $encodedBody',
      );
    }

    try {
      http.Response response;

      switch (method) {
        case HttpMethod.get:
          response = await http
              .get(uri, headers: requestHeaders)
              .timeout(timeoutDuration);
          break;
        case HttpMethod.post:
          response = await http
              .post(uri, headers: requestHeaders, body: encodedBody)
              .timeout(timeoutDuration);
          break;
        case HttpMethod.put:
          response = await http
              .put(uri, headers: requestHeaders, body: encodedBody)
              .timeout(timeoutDuration);
          break;
        case HttpMethod.patch:
          response = await http
              .patch(uri, headers: requestHeaders, body: encodedBody)
              .timeout(timeoutDuration);
          break;
        case HttpMethod.delete:
          response = await http
              .delete(uri, headers: requestHeaders, body: encodedBody)
              .timeout(timeoutDuration);
          break;
      }

      stopwatch.stop();

      // 3. Debug Logging (Response)
      if (kDebugMode) {
        Get.log(
          '🏁 [API Response] ${response.statusCode} in ${stopwatch.elapsedMilliseconds}ms -> $uri\n'
          'Origin: $tag\n'
          'Headers: ${response.headers}\n'
          'Response Body: ${response.body}',
        );
      }

      // 4. HTML block rule & Status code validation
      final trimmedBody = response.body.trim().toLowerCase();
      if (trimmedBody.startsWith('<!doctype html') ||
          trimmedBody.startsWith('<html')) {
        throw ExceptionHandler.handle(
          ApiException(
            message:
                'Server returned HTML instead of JSON (HTTP ${response.statusCode}).',
            statusCode: response.statusCode,
            errorCode: 'HTML_RESPONSE_BLOCKED',
          ),
          tag: tag,
          showToast: showToastOnError,
        );
      }

      // Status 200 (OK), 201 (Created), and 204 (No Content) are valid success responses
      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        // 204 No Content has no body according to official doc/api.md
        if (response.statusCode == 204 || response.body.trim().isEmpty) {
          return <String, dynamic>{'success': true, 'data': null};
        }
        try {
          return jsonDecode(response.body);
        } catch (_) {
          return response.body;
        }
      } else {
        throw ExceptionHandler.handleResponse(
          response.statusCode,
          response.body,
          headers: response.headers,
          tag: tag,
          showToast: showToastOnError,
        );
      }
    } catch (e) {
      stopwatch.stop();
      if (e is ApiException) rethrow;
      throw ExceptionHandler.handle(
        e,
        tag: tag,
        showToast: showToastOnError,
      );
    }
  }

  /// Generalized Multipart Request Handler (Files & Form-data)
  static Future<dynamic> requestMultipart({
    required HttpMethod method,
    required String endpoint,
    Map<String, String>? fields,
    List<http.MultipartFile>? files,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    String tag = 'ApiClient -> requestMultipart()',
    bool showToastOnError = true,
  }) async {
    // 1. Pre-flight internet check
    if (!await hasInternetConnection()) {
      final ex = ExceptionHandler.handle(
        ApiException(
          message: 'No internet connection. Please verify your network.',
          errorCode: 'NO_INTERNET',
        ),
        tag: tag,
        showToast: showToastOnError,
      );
      throw ex;
    }

    final uri = _buildUri(endpoint, queryParameters);
    final requestHeaders = _buildHeaders(headers);
    requestHeaders.remove('Content-Type'); // Let http set multipart boundary

    final request = http.MultipartRequest(
      method.name.toUpperCase(),
      uri,
    );

    request.headers.addAll(requestHeaders);
    if (fields != null) {
      request.fields.addAll(fields);
    }
    if (files != null) {
      request.files.addAll(files);
    }

    final stopwatch = Stopwatch()..start();
    if (kDebugMode) {
      Get.log(
        '🌐 [API Multipart Request] ${method.name.toUpperCase()} -> $uri\n'
        'Origin: $tag\n'
        'Headers: ${request.headers}\n'
        'Fields: $fields\n'
        'Files: ${files?.map((f) => f.filename).toList()}',
      );
    }

    try {
      final streamedResponse = await request.send().timeout(timeoutDuration);
      final response = await http.Response.fromStream(streamedResponse);
      stopwatch.stop();

      if (kDebugMode) {
        Get.log(
          '🏁 [API Multipart Response] ${response.statusCode} in ${stopwatch.elapsedMilliseconds}ms -> $uri\n'
          'Origin: $tag\n'
          'Headers: ${response.headers}\n'
          'Response Body: ${response.body}',
        );
      }

      // Check for HTML response
      final trimmedBody = response.body.trim().toLowerCase();
      if (trimmedBody.startsWith('<!doctype html') ||
          trimmedBody.startsWith('<html')) {
        throw ExceptionHandler.handle(
          ApiException(
            message:
                'Server returned HTML instead of JSON (HTTP ${response.statusCode}).',
            statusCode: response.statusCode,
            errorCode: 'HTML_RESPONSE_BLOCKED',
          ),
          tag: tag,
          showToast: showToastOnError,
        );
      }

      // Status 200, 201, 204 are valid success responses
      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        if (response.statusCode == 204 || response.body.trim().isEmpty) {
          return <String, dynamic>{'success': true, 'data': null};
        }
        try {
          return jsonDecode(response.body);
        } catch (_) {
          return response.body;
        }
      } else {
        throw ExceptionHandler.handleResponse(
          response.statusCode,
          response.body,
          headers: response.headers,
          tag: tag,
          showToast: showToastOnError,
        );
      }
    } catch (e) {
      stopwatch.stop();
      if (e is ApiException) rethrow;
      throw ExceptionHandler.handle(
        e,
        tag: tag,
        showToast: showToastOnError,
      );
    }
  }

  /// Convenience method that automatically unwraps standard 'data' envelope from doc/api.md
  static Future<dynamic> requestData({
    required HttpMethod method,
    required String endpoint,
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    String tag = 'ApiClient -> requestData()',
    bool showToastOnError = true,
  }) async {
    final response = await request(
      method: method,
      endpoint: endpoint,
      body: body,
      queryParameters: queryParameters,
      headers: headers,
      tag: tag,
      showToastOnError: showToastOnError,
    );

    if (response is Map<String, dynamic> && response.containsKey('data')) {
      return response['data'];
    }
    return response;
  }
}
