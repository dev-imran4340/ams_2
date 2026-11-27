import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../api/api_client.dart';
import '../../../api/api_endpoints.dart';
import '../../../api/app_preferences.dart';
import '../../../api/exception_handler.dart';
import '../model/me_model.dart';

class IndexRepo {
  final String _tag = 'IndexRepo / MainShell';
  Future<MeResponseModel?>? _inFlightMeRequest;
  Future<Uint8List?>? _inFlightMePhotoRequest;

  /// Fetches authenticated user identity, company, permissions, modules, and dynamic menu.
  /// Deduplicates concurrent in-flight requests to eliminate duplicate HTTP round-trips.
  Future<MeResponseModel?> fetchMe() async {
    if (_inFlightMeRequest != null) {
      return await _inFlightMeRequest;
    }
    _inFlightMeRequest = _fetchMeInternal();
    try {
      return await _inFlightMeRequest;
    } finally {
      _inFlightMeRequest = null;
    }
  }

  Future<MeResponseModel?> _fetchMeInternal() async {
    try {
      final response = await ApiClient.request(
        endpoint: ApiEndpoints.me,
        method: HttpMethod.get,
        tag: '$_tag -> fetchMe()',
      );

      if (response == null || response is! Map) {
        ExceptionHandler.handle(
          ApiException(
            message: 'Invalid identity session payload received from server.',
            errorCode: 'INVALID_ME_RESPONSE',
          ),
          tag: '$_tag -> fetchMe()',
        );
        return null;
      }

      final Map<String, dynamic> responseMap =
          Map<String, dynamic>.from(response);

      // Save complete session payload, user, and company into local storage
      await AppPreferences.saveMeData(responseMap);

      return MeResponseModel.fromJson(responseMap);
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to hydrate identity session (/me): $e'),
        tag: '$_tag -> fetchMe() [${stackTrace.toString().split('\n').first}]',
      );
      return null;
    }
  }

  /// Terminates the current active session on the backend via POST /api/v1/auth/logout.
  /// Server responds with 204 No Content.
  Future<bool> logout() async {
    try {
      await ApiClient.request(
        endpoint: ApiEndpoints.logout,
        method: HttpMethod.post,
        tag: '$_tag -> logout()',
        showToastOnError: false,
      );
      return true;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Remote logout failed: $e'),
        tag: '$_tag -> logout() [${stackTrace.toString().split('\n').first}]',
        showToast: false,
      );
      return false;
    }
  }

  /// Fetches the authenticated employee's photo via GET /me/photo silently in background.
  /// Returns raw image bytes on 200 OK, or null on 404/error without blocking UI.
  Future<Uint8List?> fetchMePhoto() async {
    if (_inFlightMePhotoRequest != null) {
      return await _inFlightMePhotoRequest;
    }
    _inFlightMePhotoRequest = _fetchMePhotoInternal();
    try {
      return await _inFlightMePhotoRequest;
    } finally {
      _inFlightMePhotoRequest = null;
    }
  }

  Future<Uint8List?> _fetchMePhotoInternal() async {
    final token = AppPreferences.token;
    if (token == null || token.isEmpty) return null;

    try {
      if (!await ApiClient.hasInternetConnection()) return null;

      String cleanBase = ApiEndpoints.baseUrl;
      if (cleanBase.endsWith('/')) {
        cleanBase = cleanBase.substring(0, cleanBase.length - 1);
      }
      final uri = Uri.parse('$cleanBase${ApiEndpoints.mePhoto}');

      final headers = <String, String>{
        'Accept': 'application/json, image/*',
        'Authorization': 'Bearer $token',
        'X-App-Version': '2.0.0',
        'X-Client-Platform':
            defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
      };
      final deviceId = AppPreferences.deviceId;
      if (deviceId != null && deviceId.isNotEmpty) {
        headers['X-Device-Id'] = deviceId;
      }

      if (kDebugMode) {
        Get.log(
          '🌐 [API Request] GET -> $uri\nOrigin: $_tag -> fetchMePhoto()',
        );
      }

      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        Get.log(
          '🏁 [API Response] ${response.statusCode} -> $uri\n'
          'Origin: $_tag -> fetchMePhoto() | Bytes: ${response.bodyBytes.length}',
        );
      }

      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        final contentType =
            (response.headers['content-type'] ?? '').toLowerCase();
        if (contentType.contains('text/html') ||
            contentType.contains('application/json')) {
          return null;
        }
        return response.bodyBytes;
      }
      return null;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Background /me/photo fetch failed: $e'),
        tag:
            '$_tag -> fetchMePhoto() [${stackTrace.toString().split('\n').first}]',
        showToast: false,
      );
      return null;
    }
  }
}
