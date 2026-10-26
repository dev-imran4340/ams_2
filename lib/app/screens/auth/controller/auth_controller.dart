import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../api/app_preferences.dart';
import '../../../api/exception_handler.dart';
import '../../../services/push_notification_service.dart';
import '../../../core/utils/device_info_helper.dart';
import '../../../routes/app_routes.dart';
import '../components/saved_account_sheet.dart';
import '../components/two_factor_sheet.dart';
import '../model/auth_model.dart';
import '../repo/auth_repo.dart';

class AuthController extends GetxController {
  final AuthRepo repo;

  AuthController({required this.repo});

  // Text Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController companyCodeController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController twoFactorCodeController = TextEditingController();
  final TextEditingController forgotPasswordEmailController =
      TextEditingController();

  // Focus Nodes
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode companyCodeFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode twoFactorFocusNode = FocusNode();
  final FocusNode forgotPasswordFocusNode = FocusNode();

  // Observables
  final RxBool isEmployeeNumberMode = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool is2faLoading = false.obs;
  final RxBool isForgotPasswordLoading = false.obs;
  final RxBool isBiometricLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool rememberMe = false.obs;
  final RxBool isRecoveryCode = false.obs;
  final RxnString pendingChallenge = RxnString();

  // Remembered Credentials Observables
  final RxBool hasSavedCredentials = false.obs;
  final RxnString savedAccountLabel = RxnString();
  final RxBool isSavedPromptVisible = false.obs;

  // Inline Validation & Error Observables
  final RxnString loginError = RxnString();
  final RxnString companyCodeError = RxnString();
  final RxnString passwordError = RxnString();
  final RxnString twoFactorError = RxnString();
  final RxnString forgotPasswordError = RxnString();
  final RxnString forgotPasswordSuccessMessage = RxnString();

  // Rate Limiting
  final RxInt retryAfterSeconds = 0.obs;
  Timer? _rateLimitTimer;

  final Rxn<LoginResponseModel> authResponse = Rxn<LoginResponseModel>();

  @override
  void onInit() {
    super.onInit();
    _loadSavedCredentialsStatus();
  }

  @override
  void onReady() {
    super.onReady();
    _promptSavedAccountIfAvailable();
  }

  void _loadSavedCredentialsStatus() {
    rememberMe.value = AppPreferences.rememberMe;
    if (AppPreferences.hasRememberedCredentials()) {
      hasSavedCredentials.value = true;
      savedAccountLabel.value = AppPreferences.getSavedLoginIdentifier();
      isSavedPromptVisible.value = true;
    } else {
      final saved = AppPreferences.savedEmail;
      if (saved != null && saved.isNotEmpty) {
        emailController.text = saved;
        forgotPasswordEmailController.text = saved;
      }
    }
  }

  /// Prompts the user via SavedAccountSheet if an encrypted remembered account is available
  void _promptSavedAccountIfAvailable() {
    if (AppPreferences.hasRememberedCredentials() &&
        emailController.text.trim().isEmpty &&
        passwordController.text.isEmpty) {
      final creds = AppPreferences.getDecryptedCredentials();
      if (creds != null && Get.context != null) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (Get.context != null &&
              !Get.isSnackbarOpen &&
              !(Get.isBottomSheetOpen ?? false)) {
            SavedAccountSheet.show(
              Get.context!,
              accountIdentifier: creds['login'] ?? '',
              isEmployeeNumberMode: creds['isEmployeeNumberMode'] == true,
            );
          }
        });
      }
    }
  }

  /// Manually trigger showing the saved account selection sheet
  void showSavedAccountPrompt() {
    final creds = AppPreferences.getDecryptedCredentials();
    if (creds != null && Get.context != null) {
      SavedAccountSheet.show(
        Get.context!,
        accountIdentifier: creds['login'] ?? '',
        isEmployeeNumberMode: creds['isEmployeeNumberMode'] == true,
      );
    }
  }

  /// Populates input fields with decrypted credentials
  void applySavedCredentials() {
    final creds = AppPreferences.getDecryptedCredentials();
    if (creds != null) {
      final bool isEmp = creds['isEmployeeNumberMode'] == true;
      isEmployeeNumberMode.value = isEmp;
      emailController.text = creds['login'] ?? '';
      passwordController.text = creds['password'] ?? '';
      if (isEmp && creds['companyCode'] != null) {
        companyCodeController.text = creds['companyCode'] ?? '';
      } else {
        companyCodeController.clear();
      }
      rememberMe.value = true;
      clearInlineErrors();
      isSavedPromptVisible.value = false;
      Get.log(
        '🔐 [AuthController] Decrypted & populated saved credentials for: ${creds['login']}',
      );
    }
  }

  /// Clears stored remembered credentials and resets the form
  Future<void> forgetSavedAccount() async {
    await AppPreferences.clearRememberedCredentials();
    hasSavedCredentials.value = false;
    savedAccountLabel.value = null;
    isSavedPromptVisible.value = false;
    rememberMe.value = false;
    emailController.clear();
    passwordController.clear();
    companyCodeController.clear();
    clearInlineErrors();
    Get.log('🗑️ [AuthController] Cleared remembered account from local storage.');
  }

  /// Dismisses the saved account banner/prompt without wiping credentials
  void dismissSavedAccountPrompt() {
    isSavedPromptVisible.value = false;
  }

  void toggleLoginMode() {
    isEmployeeNumberMode.value = !isEmployeeNumberMode.value;
    clearInlineErrors();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
  }

  void clearInlineErrors() {
    loginError.value = null;
    companyCodeError.value = null;
    passwordError.value = null;
    twoFactorError.value = null;
    forgotPasswordError.value = null;
  }

  void _startRateLimitCountdown(int seconds) {
    _rateLimitTimer?.cancel();
    retryAfterSeconds.value = seconds;
    _rateLimitTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (retryAfterSeconds.value <= 1) {
        retryAfterSeconds.value = 0;
        timer.cancel();
      } else {
        retryAfterSeconds.value--;
      }
    });
  }

  /// Handles User Login (Credentials) - Dual mode: Email or Employee ID + Company Code
  Future<void> login() async {
    if (retryAfterSeconds.value > 0) {
      ExceptionHandler.handle(
        ApiException(
          message:
              'Rate limit in effect. Please wait ${retryAfterSeconds.value}s before retrying.',
          statusCode: 429,
          errorCode: 'too_many_requests',
        ),
        tag: 'AuthController / LoginScreen -> login()',
      );
      return;
    }

    clearInlineErrors();

    // Strict Client-Side Pre-Validation
    final String loginInput = emailController.text.trim();
    final String passwordInput = passwordController.text;
    final String companyCodeInput = companyCodeController.text.trim();

    if (isEmployeeNumberMode.value) {
      if (companyCodeInput.isEmpty) {
        companyCodeError.value = 'Please enter 6-character company code';
        companyCodeFocusNode.requestFocus();
        return;
      }
      if (loginInput.isEmpty) {
        loginError.value = 'Please enter your employee ID (e.g. EMP-0001)';
        emailFocusNode.requestFocus();
        return;
      }
    } else {
      if (loginInput.isEmpty) {
        loginError.value = 'Please enter your corporate email address';
        emailFocusNode.requestFocus();
        return;
      }
      if (!GetUtils.isEmail(loginInput)) {
        loginError.value = 'Please enter a valid corporate email address';
        emailFocusNode.requestFocus();
        return;
      }
    }

    if (passwordInput.isEmpty) {
      passwordError.value = 'Please enter your password';
      passwordFocusNode.requestFocus();
      return;
    }

    try {
      isLoading.value = true;

      // Ensure device name is available from AppPreferences or resolved
      String? deviceName = AppPreferences.deviceName;
      if (deviceName == null || deviceName.isEmpty) {
        final info = await DeviceInfoHelper.initDeviceInfo();
        deviceName = info['deviceName'];
      }

      final response = await repo.login(
        login: loginInput,
        password: passwordInput,
        companyCode: isEmployeeNumberMode.value ? companyCodeInput : null,
        deviceName: deviceName,
      );

      authResponse.value = response;

      // Handle Two-Factor Challenge requirement
      if (response.twoFactorRequired) {
        pendingChallenge.value = response.challenge;
        await AppPreferences.setTwoFactorChallenge(response.challenge);
        twoFactorCodeController.clear();
        twoFactorError.value = null;

        if (Get.context != null) {
          TwoFactorSheet.show(Get.context!);
        }
        return;
      }

      // Handle Direct Login (No 2FA Required)
      if (response.token != null && response.token!.isNotEmpty) {
        await AppPreferences.saveAuthData(
          token: response.token!,
          refreshToken: response.refreshToken,
          user: response.user,
        );

        if (rememberMe.value) {
          await AppPreferences.saveRememberedCredentials(
            login: loginInput,
            password: passwordInput,
            companyCode: isEmployeeNumberMode.value ? companyCodeInput : null,
            isEmployeeNumberMode: isEmployeeNumberMode.value,
          );
        } else {
          await AppPreferences.clearRememberedCredentials();
        }

        Get.log(
          '🔑 [AuthController -> login()] Session token successfully persisted to local storage (AppPreferences): ${AppPreferences.token}',
        );

        // Register FCM device push token with AMS 2 backend
        PushNotificationService.instance.registerDevicePushToken();

        Get.offAllNamed(Routes.INDEX);
      } else {
        loginError.value = response.message ?? 'Authentication failed. Please verify your credentials.';
      }
    } catch (e) {
      if (e is ApiException) {
        if (e.isRateLimited) {
          _startRateLimitCountdown(e.retryAfterSeconds ?? 60);
        }
        if (e.isValidationFailed && e.fields != null) {
          final fields = e.fields!;
          if (fields.containsKey('login') && fields['login']!.isNotEmpty) {
            loginError.value = fields['login']!.first;
          }
          if (fields.containsKey('company_code') &&
              fields['company_code']!.isNotEmpty) {
            companyCodeError.value = fields['company_code']!.first;
          }
          if (fields.containsKey('password') &&
              fields['password']!.isNotEmpty) {
            passwordError.value = fields['password']!.first;
          }
        }
      }
      ExceptionHandler.handle(e, tag: 'AuthController -> login()');
    } finally {
      isLoading.value = false;
    }
  }

  /// Verifies Two-Factor TOTP or Recovery Code
  Future<void> verifyTwoFactor() async {
    final String challenge = pendingChallenge.value ??
        AppPreferences.twoFactorChallenge ??
        '';

    if (challenge.isEmpty) {
      twoFactorError.value = 'Two-factor session expired. Please sign in again.';
      return;
    }

    final String inputCode = twoFactorCodeController.text.trim();
    if (inputCode.isEmpty) {
      twoFactorError.value = isRecoveryCode.value
          ? 'Please enter recovery code'
          : 'Please enter 6-digit TOTP code';
      twoFactorFocusNode.requestFocus();
      return;
    }

    try {
      is2faLoading.value = true;
      twoFactorError.value = null;

      final response = await repo.verifyTwoFactor(
        challenge: challenge,
        code: isRecoveryCode.value ? null : inputCode,
        recoveryCode: isRecoveryCode.value ? inputCode : null,
      );

      if (response.token != null && response.token!.isNotEmpty) {
        await AppPreferences.saveAuthData(token: response.token!);
        await AppPreferences.setTwoFactorChallenge(null);

        if (rememberMe.value) {
          await AppPreferences.saveRememberedCredentials(
            login: emailController.text.trim(),
            password: passwordController.text,
            companyCode: isEmployeeNumberMode.value
                ? companyCodeController.text.trim()
                : null,
            isEmployeeNumberMode: isEmployeeNumberMode.value,
          );
        } else {
          await AppPreferences.clearRememberedCredentials();
        }

        if (Get.isBottomSheetOpen ?? false) {
          Get.back();
        }

        // Register FCM device push token with AMS 2 backend
        PushNotificationService.instance.registerDevicePushToken();

        Get.offAllNamed(Routes.INDEX);
      }
    } catch (e) {
      if (e is ApiException) {
        twoFactorError.value = e.message;
      } else {
        twoFactorError.value = 'Verification failed. Please retry.';
      }
      ExceptionHandler.handle(e, tag: 'AuthController -> verifyTwoFactor()');
    } finally {
      is2faLoading.value = false;
    }
  }

  /// Submits Password Reset Request
  Future<void> submitForgotPassword() async {
    final String email = forgotPasswordEmailController.text.trim();
    forgotPasswordError.value = null;
    forgotPasswordSuccessMessage.value = null;

    if (email.isEmpty) {
      forgotPasswordError.value = 'Please enter your registered email address';
      forgotPasswordFocusNode.requestFocus();
      return;
    }

    if (!GetUtils.isEmail(email)) {
      forgotPasswordError.value = 'Please enter a valid email address';
      forgotPasswordFocusNode.requestFocus();
      return;
    }

    try {
      isForgotPasswordLoading.value = true;
      final response = await repo.forgotPassword(email: email);
      forgotPasswordSuccessMessage.value = response.message ??
          'If the address has an account, a reset link has been sent.';
    } catch (e) {
      if (e is ApiException) {
        forgotPasswordError.value = e.message;
      }
      ExceptionHandler.handle(e, tag: 'AuthController -> submitForgotPassword()');
    } finally {
      isForgotPasswordLoading.value = false;
    }
  }

  /// Biometric authentication flow
  Future<void> loginWithBiometrics() async {
    try {
      isBiometricLoading.value = true;
      final response = await repo.authenticateWithBiometrics();
      if (response != null && response.token != null) {
        authResponse.value = response;
        await AppPreferences.saveAuthData(
          token: response.token!,
          refreshToken: response.refreshToken,
          user: response.user,
        );

        // Register FCM device push token with AMS 2 backend
        PushNotificationService.instance.registerDevicePushToken();

        Get.offAllNamed(Routes.INDEX);
      }
    } catch (e) {
      ExceptionHandler.handle(e, tag: 'AuthController -> loginWithBiometrics()');
    } finally {
      isBiometricLoading.value = false;
    }
  }

  /// Logout current session and purge local storage
  Future<void> logout() async {
    try {
      await repo.logout();
    } catch (e) {
      ExceptionHandler.handle(e, tag: 'AuthController -> logout()');
    } finally {
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  @override
  void onClose() {
    _rateLimitTimer?.cancel();
    emailController.dispose();
    companyCodeController.dispose();
    passwordController.dispose();
    twoFactorCodeController.dispose();
    forgotPasswordEmailController.dispose();

    emailFocusNode.dispose();
    companyCodeFocusNode.dispose();
    passwordFocusNode.dispose();
    twoFactorFocusNode.dispose();
    forgotPasswordFocusNode.dispose();
    super.onClose();
  }
}

