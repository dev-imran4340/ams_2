import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../api/api_client.dart';
import '../../../api/api_endpoints.dart';
import '../../../api/app_preferences.dart';
import '../../../api/exception_handler.dart';
import '../model/kiosk_model.dart';

class KioskRepo {
  final String _tag = 'KioskRepo / KioskScreen';

  // -------------------------------------------------------------
  // 1. SELF-SERVICE KIOSK PIN (PUT /me/kiosk-pin)
  // -------------------------------------------------------------

  /// Configures employee's 4-6 digit kiosk fallback PIN.
  /// Allowed for all staff members under Phase 10 spec.
  Future<bool> setKioskPin({
    required String pin,
    required String pinConfirmation,
  }) async {
    try {
      final response = await ApiClient.request(
        endpoint: ApiEndpoints.meKioskPin,
        method: HttpMethod.put,
        body: {
          'pin': pin,
          'pin_confirmation': pinConfirmation,
        },
        tag: '$_tag -> setKioskPin()',
      );

      if (response != null) {
        await AppPreferences.setKioskPinConfigured(true);
        return true;
      }
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to configure kiosk PIN: $e'),
        tag: '$_tag -> setKioskPin() [${stackTrace.toString().split('\n').first}]',
      );
    }
    return false;
  }

  // -------------------------------------------------------------
  // 2. KIOSK PROVISIONING (POST /kiosks)
  // -------------------------------------------------------------

  /// Provisions this tablet as a kiosk terminal.
  /// Requires user token with 'kiosks.manage' permissions.
  Future<KioskConfigModel?> provisionKiosk({
    required String name,
    required String location,
    bool replace = false,
  }) async {
    try {
      final response = await ApiClient.request(
        method: HttpMethod.post,
        endpoint: ApiEndpoints.kiosks,
        body: {
          'name': name,
          'location': location,
          'replace': replace,
        },
        tag: '$_tag -> provisionKiosk()',
      );

      if (response != null && response is Map<String, dynamic>) {
        final payload = response['data'] is Map<String, dynamic>
            ? response['data'] as Map<String, dynamic>
            : response;

        final model = KioskConfigModel.fromJson(payload);

        // Store kiosk secret token and configuration securely in AppPreferences
        if (model.token != null && model.token!.isNotEmpty) {
          await AppPreferences.setKioskToken(model.token!);
          await AppPreferences.setKioskConfig(model.toJson());
        }

        return model;
      }
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to provision kiosk terminal: $e'),
        tag: '$_tag -> provisionKiosk() [${stackTrace.toString().split('\n').first}]',
      );
    }
    return null;
  }

  // -------------------------------------------------------------
  // 3. FETCH ACTIVE KIOSK CONFIG (GET /kiosk)
  // -------------------------------------------------------------

  /// Fetches active kiosk configuration using the tablet's KIOSK TOKEN.
  /// STRICT INVARIANT: If the tablet is not provisioned (kioskToken == null),
  /// this method returns null immediately and NEVER calls GET /kiosk with a user token.
  Future<KioskConfigModel?> fetchKioskConfig() async {
    final token = AppPreferences.kioskToken;
    if (token == null || token.isEmpty) {
      // Tablet not provisioned — prevent sending user token to /kiosk which causes 401
      return null;
    }

    try {
      final headers = <String, String>{
        'Authorization': 'Bearer $token',
      };

      final response = await ApiClient.request(
        method: HttpMethod.get,
        endpoint: ApiEndpoints.kiosk,
        headers: headers,
        tag: '$_tag -> fetchKioskConfig()',
        showToastOnError: false,
      );

      if (response != null && response is Map<String, dynamic>) {
        final payload = response['data'] is Map<String, dynamic>
            ? response['data'] as Map<String, dynamic>
            : response;

        final model = KioskConfigModel.fromJson(payload);
        await AppPreferences.setKioskConfig(model.toJson());
        return model;
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('[$_tag] Kiosk config check: $e (${stackTrace.toString().split('\n').first})');
      }
    }

    // Check cached kiosk config
    final cached = AppPreferences.kioskConfig;
    if (cached != null) {
      return KioskConfigModel.fromJson(cached);
    }
    return null;
  }

  // -------------------------------------------------------------
  // 4. IDENTIFY EMPLOYEE AT KIOSK (POST /kiosk/identify)
  // -------------------------------------------------------------

  /// Identifies an employee via QR badge or Employee Number + PIN.
  Future<KioskIdentifyResponseModel?> identifyEmployee({
    String? badge,
    String? employeeNumber,
    String? pin,
  }) async {
    final token = AppPreferences.kioskToken;
    if (token == null || token.isEmpty) return null;

    try {
      final Map<String, dynamic> body = {};
      if (badge != null && badge.isNotEmpty) {
        body['badge'] = badge;
      } else {
        body['employee_number'] = employeeNumber ?? '';
        body['pin'] = pin ?? '';
      }

      final headers = <String, String>{
        'Authorization': 'Bearer $token',
      };

      final response = await ApiClient.request(
        method: HttpMethod.post,
        endpoint: ApiEndpoints.kioskIdentify,
        body: body,
        headers: headers,
        tag: '$_tag -> identifyEmployee()',
      );

      if (response != null && response is Map<String, dynamic>) {
        final payload = response['data'] is Map<String, dynamic>
            ? response['data'] as Map<String, dynamic>
            : response;

        return KioskIdentifyResponseModel.fromJson(payload);
      }
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to identify employee: $e'),
        tag: '$_tag -> identifyEmployee() [${stackTrace.toString().split('\n').first}]',
      );
    }
    return null;
  }

  // -------------------------------------------------------------
  // 5. DOWNLOAD KIOSK FACE PHOTO (GET /kiosk/face?ticket=...)
  // -------------------------------------------------------------

  /// Downloads the identified employee's face photo for local verification on the kiosk tablet.
  Future<Uint8List?> fetchKioskFace({required String ticket}) async {
    final token = AppPreferences.kioskToken;
    if (token == null || token.isEmpty) return null;

    try {
      String cleanBase = ApiEndpoints.baseUrl;
      if (cleanBase.endsWith('/')) {
        cleanBase = cleanBase.substring(0, cleanBase.length - 1);
      }
      final url = Uri.parse('$cleanBase${ApiEndpoints.kioskFace(ticket)}');

      final headers = <String, String>{
        'Accept': 'image/jpeg, image/png, image/*, application/json',
        'X-App-Version': '2.0.0',
        'X-Client-Platform': defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
        'Authorization': 'Bearer $token',
      };

      final response = await http.get(url, headers: headers).timeout(
        const Duration(seconds: 20),
      );

      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        return response.bodyBytes;
      }
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to download kiosk face template: $e'),
        tag: '$_tag -> fetchKioskFace() [${stackTrace.toString().split('\n').first}]',
      );
    }
    return null;
  }

  // -------------------------------------------------------------
  // 6. SUBMIT KIOSK ATTENDANCE PUNCH (POST /kiosk/punches)
  // -------------------------------------------------------------

  /// Submits an attendance punch from the kiosk tablet.
  /// Supports Live Online Mode (with ticket) or Offline Queued Mode (with badge/PIN + punched_at).
  Future<KioskPunchResultModel?> submitKioskPunch({
    String? ticket,
    required String kind,
    required String idempotencyKey,
    File? photo,
    String? faceMatch,
    double? faceScore,
    bool? faceConsent,
    String? badge,
    String? employeeNumber,
    String? pin,
    String? punchedAt,
  }) async {
    final token = AppPreferences.kioskToken;
    if (token == null || token.isEmpty) return null;

    try {
      final headers = <String, String>{
        'Authorization': 'Bearer $token',
      };

      dynamic response;

      if (photo != null && await photo.exists()) {
        final fields = <String, String>{
          'kind': kind,
          'idempotency_key': idempotencyKey,
        };
        if (ticket != null && ticket.isNotEmpty) fields['ticket'] = ticket;
        if (faceMatch != null) fields['face_match'] = faceMatch;
        if (faceScore != null) fields['face_score'] = faceScore.toStringAsFixed(4);
        if (faceConsent != null) fields['face_consent'] = faceConsent.toString();
        if (badge != null) fields['badge'] = badge;
        if (employeeNumber != null) fields['employee_number'] = employeeNumber;
        if (pin != null) fields['pin'] = pin;
        if (punchedAt != null) fields['punched_at'] = punchedAt;

        final multipartFile = await http.MultipartFile.fromPath('photo', photo.path);
        response = await ApiClient.requestMultipart(
          method: HttpMethod.post,
          endpoint: ApiEndpoints.kioskPunches,
          fields: fields,
          files: [multipartFile],
          headers: headers,
          tag: '$_tag -> submitKioskPunch() [Multipart]',
        );
      } else {
        final body = <String, dynamic>{
          'kind': kind,
          'idempotency_key': idempotencyKey,
        };
        if (ticket != null && ticket.isNotEmpty) body['ticket'] = ticket;
        if (faceMatch != null) body['face_match'] = faceMatch;
        if (faceScore != null) body['face_score'] = faceScore;
        if (faceConsent != null) body['face_consent'] = faceConsent;
        if (badge != null) body['badge'] = badge;
        if (employeeNumber != null) body['employee_number'] = employeeNumber;
        if (pin != null) body['pin'] = pin;
        if (punchedAt != null) body['punched_at'] = punchedAt;

        response = await ApiClient.request(
          method: HttpMethod.post,
          endpoint: ApiEndpoints.kioskPunches,
          body: body,
          headers: headers,
          tag: '$_tag -> submitKioskPunch() [JSON]',
        );
      }

      if (response != null && response is Map<String, dynamic>) {
        final payload = response['data'] is Map<String, dynamic>
            ? response['data'] as Map<String, dynamic>
            : response;

        return KioskPunchResultModel.fromJson(payload);
      }
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to submit punch: $e'),
        tag: '$_tag -> submitKioskPunch() [${stackTrace.toString().split('\n').first}]',
      );
    }
    return null;
  }
}
