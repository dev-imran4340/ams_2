// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';
import 'app_routes.dart';

import '../screens/splash/view/splash_view.dart';
import '../screens/splash/controller/splash_controller.dart';

import '../screens/auth/view/login_view.dart';
import '../screens/auth/controller/auth_controller.dart';
import '../screens/auth/repo/auth_repo.dart';

import '../screens/index/view/index_view.dart';
import '../screens/index/controller/index_controller.dart';

import '../screens/dashboard/view/dashboard_view.dart';
import '../screens/dashboard/controller/dashboard_controller.dart';
import '../screens/dashboard/repo/dashboard_repo.dart';

import '../screens/attendance_history/view/attendance_history_view.dart';
import '../screens/attendance_history/controller/attendance_history_controller.dart';
import '../screens/attendance_history/repo/attendance_history_repo.dart';

import '../screens/leaves/controller/leave_controller.dart';
import '../screens/leaves/repo/leave_repo.dart';

import '../screens/profile/controller/profile_controller.dart';
import '../screens/profile/repo/profile_repo.dart';

import '../screens/regularization/view/regularization_view.dart';
import '../screens/regularization/controller/regularization_controller.dart';
import '../screens/regularization/repo/regularization_repo.dart';

import '../screens/verification/qr_scanner/view/qr_scanner_view.dart';
import '../screens/verification/qr_scanner/controller/qr_scan_controller.dart';
import '../screens/verification/qr_scanner/repo/qr_scan_repo.dart';

import '../screens/verification/face_recognition/view/face_recognition_view.dart';
import '../screens/verification/face_recognition/controller/face_recognition_controller.dart';
import '../screens/verification/face_recognition/repo/face_recognition_repo.dart';

class AppPages {
  // Initial Entry Route
  static const INITIAL = Routes.SPLASH;

  static final routes = [
    // 1. Splash Screen
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => SplashController(), fenix: true);
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

    // 3. Main Shell / Index Screen (Hosts Dashboard, Logs, Leaves, Profile)
    GetPage(
      name: Routes.INDEX,
      page: () => const IndexView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => IndexController(), fenix: true);
        Get.lazyPut(() => DashboardRepo(), fenix: true);
        Get.lazyPut(() => DashboardController(repo: Get.find()), fenix: true);
        Get.lazyPut(() => AttendanceHistoryRepo(), fenix: true);
        Get.lazyPut(
          () => AttendanceHistoryController(repo: Get.find()),
          fenix: true,
        );
        Get.lazyPut(() => LeaveRepo(), fenix: true);
        Get.lazyPut(
          () => LeaveController(repo: Get.find()),
          fenix: true,
        );
        Get.lazyPut(() => ProfileRepo(), fenix: true);
        Get.lazyPut(
          () => ProfileController(repo: Get.find()),
          fenix: true,
        );
      }),
    ),

    // 4. Standalone Dashboard Screen
    GetPage(
      name: Routes.DASHBOARD,
      page: () => const DashboardView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => DashboardRepo(), fenix: true);
        Get.lazyPut(() => DashboardController(repo: Get.find()), fenix: true);
      }),
    ),

    // 5. Standalone Attendance History Screen
    GetPage(
      name: Routes.ATTENDANCE_HISTORY,
      page: () => const AttendanceHistoryView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AttendanceHistoryRepo(), fenix: true);
        Get.lazyPut(
          () => AttendanceHistoryController(repo: Get.find()),
          fenix: true,
        );
      }),
    ),

    // 6. Regularization & Overtime Screen
    GetPage(
      name: Routes.REGULARIZATION,
      page: () => const RegularizationView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => RegularizationRepo(), fenix: true);
        Get.lazyPut(
          () => RegularizationController(repo: Get.find()),
          fenix: true,
        );
      }),
    ),

    // 7. Multi-Factor Verification - Step 1: Employee Card QR Scanner
    GetPage(
      name: Routes.QR_SCANNER,
      page: () => const QRScannerView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => QRScanRepo(), fenix: true);
        Get.lazyPut(
          () => QRScanController(repo: Get.find()),
          fenix: true,
        );
      }),
    ),

    // 8. Multi-Factor Verification - Step 2: AI Face Recognition Biometric
    GetPage(
      name: Routes.FACE_RECOGNITION,
      page: () => const FaceRecognitionView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => FaceRecognitionRepo(), fenix: true);
        Get.lazyPut(
          () => FaceRecognitionController(repo: Get.find()),
          fenix: true,
        );
      }),
    ),
  ];
}
