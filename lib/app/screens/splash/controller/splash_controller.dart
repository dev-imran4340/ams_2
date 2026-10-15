import 'dart:async';
import 'package:get/get.dart';

import '../../../api/app_preferences.dart';
import '../../../api/exception_handler.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  static const String _tag = 'SplashController';

  // Observables
  final RxBool isLoading = true.obs;
  bool _isCheckingSession = false;
  bool _hasNavigated = false;

  @override
  void onInit() {
    super.onInit();
    checkSessionAndRoute();
  }

  /// Evaluates authentication state from AppPreferences and redirects smoothly
  Future<void> checkSessionAndRoute() async {
    if (_isCheckingSession || _hasNavigated) return;
    _isCheckingSession = true;

    try {
      isLoading.value = true;

      // Allow animations and executive brand presentation to complete gracefully
      await Future.delayed(const Duration(milliseconds: 2200));

      if (_hasNavigated) return;
      _hasNavigated = true;

      // Read authentication credentials strictly through AppPreferences abstraction
      final String? token = AppPreferences.token;
      final bool isLoggedIn = AppPreferences.isLoggedIn;

      if (token != null && token.trim().isNotEmpty && isLoggedIn) {
        // Active verified session: route to authenticated Main Shell (Index)
        Get.offAllNamed(Routes.INDEX);
      } else {
        // No valid token: route to Login
        Get.offAllNamed(Routes.LOGIN);
      }
    } catch (e, stackTrace) {
      if (_hasNavigated) return;
      _hasNavigated = true;
      ExceptionHandler.handle(
        ApiException(message: 'Failed to verify session during splash: $e'),
        tag:
            '$_tag -> checkSessionAndRoute() [${stackTrace.toString().split('\n').first}]',
      );
      // Fallback securely to Login screen
      Get.offAllNamed(Routes.LOGIN);
    } finally {
      isLoading.value = false;
      _isCheckingSession = false;
    }
  }
}
