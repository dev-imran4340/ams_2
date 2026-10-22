import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

import '../../../api/api_client.dart';
import '../../../api/api_endpoints.dart';
import '../../../api/app_preferences.dart';
import '../model/auth_model.dart';

class AuthRepo {
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

    return LoginResponseModel.fromJson(response);
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

  /// Biometric authentication fallback / mock support
  Future<LoginResponseModel?> authenticateWithBiometrics() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final mockUser = UserModel(
      id: '01jb2x9k4m7q8r3t5v6w8y0z1a',
      name: 'Authenticated Employee',
      email: AppPreferences.savedEmail ?? 'employee@acme.pk',
      employeeId: 'EMP-0001',
      designation: 'Staff Member',
      department: 'Corporate Headquarters',
      avatarUrl: null,
      accountType: 'organization',
    );

    return LoginResponseModel(
      twoFactorRequired: false,
      token: AppPreferences.token ?? 'ams_bio_session_token',
      refreshToken: 'ams_bio_ref_mock_token',
      user: mockUser,
      message: 'Biometric verification successful',
    );
  }
}

