// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';
import 'app_routes.dart';

import '../screens/splash/view/splash_view.dart';
import '../screens/splash/controller/splash_controller.dart';
import '../screens/splash/repo/splash_repo.dart';

import '../screens/auth/view/login_view.dart';
import '../screens/auth/controller/auth_controller.dart';
import '../screens/auth/repo/auth_repo.dart';

import '../screens/dashboard/view/dashboard_view.dart';
import '../screens/dashboard/controller/dashboard_controller.dart';
import '../screens/dashboard/repo/dashboard_repo.dart';

class AppPages {
  // Initial Entry Route
  static const INITIAL = Routes.SPLASH;

  static final routes = [
    // 1. Splash Screen
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => SplashRepo(), fenix: true);
        Get.lazyPut(() => SplashController(repo: Get.find()), fenix: true);
      }),
    ),

    // 2. Authentication Screen
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AuthRepo(), fenix: true);
        Get.lazyPut(() => AuthController(repo: Get.find()), fenix: true);
      }),
    ),

    // 3. Dashboard Screen
    GetPage(
      name: Routes.DASHBOARD,
      page: () => const DashboardView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => DashboardRepo(), fenix: true);
        Get.lazyPut(() => DashboardController(repo: Get.find()), fenix: true);
      }),
    ),
  ];
}
