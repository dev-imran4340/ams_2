import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../api/app_preferences.dart';
import '../../../routes/app_routes.dart';
import '../model/splash_session_model.dart';
import '../repo/splash_repo.dart';

class SplashController extends GetxController {
  final SplashRepo repo;

  SplashController({required this.repo});

  final RxBool isLoading = true.obs;
  final Rxn<SplashSessionModel> sessionData = Rxn<SplashSessionModel>();

  @override
  void onInit() {
    super.onInit();
    checkAuthentication();
  }

  /// Verifies active session with backend and routes accordingly
  Future<void> checkAuthentication() async {
    const minDelayDuration = Duration(milliseconds: 1200);

    try {
      isLoading.value = true;
      final minDelay = Future.delayed(minDelayDuration);
      final storedToken = AppPreferences.token;

      // 1. If no token exists, navigate to Login
      if (storedToken == null || storedToken.trim().isEmpty) {
        await minDelay;
        if (kDebugMode) {
          Get.log('ℹ️ [Splash] No token found in AppPreferences. Redirecting to LOGIN.');
        }
        Get.offAllNamed(Routes.LOGIN);
        return;
      }

      // 2. Verify token against backend
      final session = await repo.verifySession();
      await minDelay;

      final currentToken = AppPreferences.token;
      if (session != null && currentToken != null && currentToken.isNotEmpty) {
        sessionData.value = session;
        if (kDebugMode) {
          Get.log(
            '✅ [Splash] Session valid for user: ${session.email}. Redirecting to DASHBOARD.',
          );
        }
        Get.offAllNamed(Routes.DASHBOARD);
      } else {
        if (kDebugMode) {
          Get.log(
            '⚠️ [Splash] Session revoked or invalid. Clearing session and redirecting to LOGIN.',
          );
        }
        await AppPreferences.clearSession();
        Get.offAllNamed(Routes.LOGIN);
      }
    } catch (e) {
      if (kDebugMode) {
        Get.log('❌ [Splash Error] Verification failed ($e). Redirecting to LOGIN.');
      }
      await AppPreferences.clearSession();
      Get.offAllNamed(Routes.LOGIN);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    // Clean up any listeners or resources
    super.onClose();
  }
}
