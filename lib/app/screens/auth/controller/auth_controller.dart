import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../api/app_preferences.dart';
import '../../../routes/app_routes.dart';
import '../model/auth_model.dart';
import '../repo/auth_repo.dart';

class AuthController extends GetxController {
  final AuthRepo repo;

  AuthController({required this.repo});

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
    // try {
    //   isLoading.value = true;
    //   final response = await repo.login(
    //     email: emailController.text.trim(),
    //     password: passwordController.text.trim(),
    //   );
    //   if (response != null) {
    //     authResponse.value = response;
    //     if (rememberMe.value) {
    //       AppPreferences.setSavedEmail(emailController.text.trim());
    //       AppPreferences.setRememberMe(true);
    //     } else {
    //       AppPreferences.setSavedEmail(null);
    //       AppPreferences.setRememberMe(false);
    //     }

    //     final accountType = response.user?.accountType ?? 'organization';
    //     if (accountType == 'organization') {
    //       Get.offNamed(Routes.ORG_HUB);
    //     } else {
    //       Get.offNamed(Routes.INDEX);
    //     }
    //   } else {
    //     Get.offNamed(Routes.INDEX);
    //   }
    // } finally {
    //   isLoading.value = false;
    // }
    Get.offNamed(Routes.ORG_MODE_SELECTION);
  }

  Future<void> loginWithBiometrics() async {
    try {
      isBiometricLoading.value = true;
      final response = await repo.authenticateWithBiometrics();
      if (response != null) {
        authResponse.value = response;
        final accountType = response.user?.accountType ?? 'organization';
        if (accountType == 'organization') {
          Get.offNamed(Routes.ORG_HUB);
        } else {
          Get.offNamed(Routes.INDEX);
        }
      } else {
        Get.offNamed(Routes.INDEX);
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
