import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../api/app_preferences.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../routes/app_routes.dart';
import '../model/auth_model.dart';
import '../repo/auth_repo.dart';

class AuthController extends GetxController {
  final AuthRepo repo;

  AuthController({required this.repo});

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  final RxBool isLoading = false.obs;
  final RxBool isBiometricLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool rememberMe = false.obs;
  final Rxn<LoginResponseModel> authResponse = Rxn<LoginResponseModel>();

  @override
  void onInit() {
    super.onInit();
    _loadSavedCredentials();
  }

  void _loadSavedCredentials() {
    rememberMe.value = AppPreferences.rememberMe;
    final saved = AppPreferences.savedEmail;
    if (saved != null && saved.isNotEmpty) {
      emailController.text = saved;
    }
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;
      final email = emailController.text.trim();
      final password = passwordController.text;

      final result = await repo.login(
        email: email,
        password: password,
      );

      if (result != null && result.token != null) {
        authResponse.value = result;

        // Persist session
        await AppPreferences.saveAuthData(
          token: result.token!,
          refreshToken: result.refreshToken,
          user: result.user,
        );

        // Persist remember me preferences
        await AppPreferences.setRememberMe(rememberMe.value);
        if (rememberMe.value) {
          await AppPreferences.setSavedEmail(email);
        } else {
          await AppPreferences.setSavedEmail(null);
        }

        CustomSnackbar.showSuccess(
          title: 'Welcome Back',
          message: 'Authenticated successfully as ${result.user?.name ?? 'Employee'}.',
        );

        Get.offAllNamed(Routes.DASHBOARD);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithBiometrics() async {
    try {
      isBiometricLoading.value = true;
      final result = await repo.authenticateWithBiometrics();

      if (result != null && result.token != null) {
        authResponse.value = result;

        await AppPreferences.saveAuthData(
          token: result.token!,
          refreshToken: result.refreshToken,
          user: result.user,
        );

        CustomSnackbar.showSuccess(
          title: 'Biometric Verified',
          message: 'Welcome back, ${result.user?.name ?? 'Employee'}.',
        );

        Get.offAllNamed(Routes.DASHBOARD);
      }
    } finally {
      isBiometricLoading.value = false;
    }
  }

  @override
  void onClose() {
    // Strict resource disposal contract
    emailController.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.onClose();
  }
}
