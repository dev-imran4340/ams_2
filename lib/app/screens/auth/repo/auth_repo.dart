import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

import '../../../api/api_client.dart';
import '../../../api/api_endpoints.dart';
import '../../../api/app_preferences.dart';
import '../model/auth_model.dart';

class AuthRepo {
  final LocalAuthentication _localAuth;

  AuthRepo({LocalAuthentication? localAuth})
      : _localAuth = localAuth ?? LocalAuthentication();
  /// Authenticates user credentials via POST /api/v1/auth/login.
  /// Supports dual-mode: corporate email or employee number + company code.
  Future<LoginResponseModel> login({
    required String login,
    required String password,
    String? companyCode,
    String? deviceName,
  }) async {
    final String resolvedDeviceName = deviceName ??
        AppPreferences.deviceName ??
        (Platform.isAndroid
            ? 'Android Device'
            : Platform.isIOS
                ? 'iOS Device'
                : 'AMS Mobile App');

    final requestModel = LoginRequestModel(
      login: login,
      password: password,
      companyCode: companyCode,
      deviceName: resolvedDeviceName,
    );

    debugPrint('🚀 [AuthRepo -> login()] Dispatching credentials with device_name: "$resolvedDeviceName"');

    final response = await ApiClient.request(
      endpoint: ApiEndpoints.login,
      method: HttpMethod.post,
      body: requestModel.toJson(),
      tag: 'AuthRepo / LoginScreen -> login()',
    );

    if (response is Map) {
      return LoginResponseModel.fromJson(Map<String, dynamic>.from(response));
    }

    return LoginResponseModel();
  }

  /// Verifies Two-Factor challenge via POST /api/v1/auth/two-factor.
  /// Accepts either 6-digit TOTP code or single-use recovery code.
  Future<TwoFactorResponseModel> verifyTwoFactor({
    required String challenge,
    String? code,
    String? recoveryCode,
  }) async {
    final requestModel = TwoFactorRequestModel(
      challenge: challenge,
      code: code,
      recoveryCode: recoveryCode,
    );

    final response = await ApiClient.request(
      endpoint: ApiEndpoints.twoFactor,
      method: HttpMethod.post,
      body: requestModel.toJson(),
      tag: 'AuthRepo / TwoFactorSheet -> verifyTwoFactor()',
    );

    return TwoFactorResponseModel.fromJson(response);
  }

  /// Dispatches password reset link via POST /api/v1/auth/forgot-password.
  /// Server returns a probing-proof identical success message.
  Future<ForgotPasswordResponseModel> forgotPassword({
    required String email,
  }) async {
    final requestModel = ForgotPasswordRequestModel(email: email);

    final response = await ApiClient.request(
      endpoint: ApiEndpoints.forgotPassword,
      method: HttpMethod.post,
      body: requestModel.toJson(),
      tag: 'AuthRepo / ForgotPasswordScreen -> forgotPassword()',
    );

    return ForgotPasswordResponseModel.fromJson(response);
  }

  /// Terminates the current active session via POST /api/v1/auth/logout.
  /// Returns 204 No Content, then purges local session.
  Future<void> logout() async {
    try {
      await ApiClient.request(
        endpoint: ApiEndpoints.logout,
        method: HttpMethod.post,
        tag: 'AuthRepo / MainShell -> logout()',
      );
    } finally {
      await AppPreferences.clearAuth();
    }
  }

  /// Verifies if device has functional biometric hardware and enrolled biometrics
  Future<bool> isBiometricHardwareAvailable() async {
    try {
      final bool canCheck = await _localAuth.canCheckBiometrics;
      final bool isSupported = await _localAuth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (e) {
      debugPrint('⚠️ [AuthRepo -> isBiometricHardwareAvailable] $e');
      return false;
    }
  }

  /// Prompts device platform-backed biometric authentication (Fingerprint / Face ID).
  /// Strictly performs local unlock only — does not create sessions or fake tokens.
  Future<bool> authenticateWithBiometricsLocally({
    String reason = 'Authenticate to access your AMS 2 session',
  }) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } catch (e) {
      debugPrint('⚠️ [AuthRepo -> authenticateWithBiometricsLocally] $e');
      return false;
    }
  }
}

