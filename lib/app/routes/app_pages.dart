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

import '../screens/tasks/view/task_view.dart';
import '../screens/tasks/controller/task_controller.dart';
import '../screens/tasks/repo/task_repo.dart';

import '../screens/evaluation/view/evaluation_view.dart';
import '../screens/evaluation/controller/evaluation_controller.dart';
import '../screens/evaluation/repo/evaluation_repo.dart';

import '../screens/employee_card/view/employee_card_view.dart';
import '../screens/employee_card/controller/employee_card_controller.dart';
import '../screens/employee_card/repo/employee_card_repo.dart';

import '../screens/organization/org_mode_selection/view/org_mode_selection_view.dart';
import '../screens/organization/org_mode_selection/controller/org_mode_controller.dart';
import '../screens/organization/org_mode_selection/repo/org_mode_repo.dart';

import '../screens/organization/visitor_management/view/visitor_management_view.dart';
import '../screens/organization/visitor_management/view/visitor_entry_view.dart';
import '../screens/organization/visitor_management/view/visitor_exit_view.dart';
import '../screens/organization/visitor_management/controller/visitor_controller.dart';
import '../screens/organization/visitor_management/repo/visitor_repo.dart';


import '../screens/organization/employee_terminal/view/employee_terminal_view.dart';
import '../screens/organization/employee_terminal/controller/employee_terminal_controller.dart';
import '../screens/organization/employee_terminal/repo/employee_terminal_repo.dart';


import '../screens/organization/add_employee/view/add_employee_view.dart';
import '../screens/organization/add_employee/controller/add_employee_controller.dart';
import '../screens/organization/add_employee/repo/add_employee_repo.dart';

import '../screens/organization/company_dashboard/view/company_dashboard_view.dart';
import '../screens/organization/company_dashboard/controller/company_dashboard_controller.dart';
import '../screens/organization/company_dashboard/repo/company_dashboard_repo.dart';

import '../screens/organization/employee_kiosk_dashboard/view/employee_kiosk_dashboard_view.dart';
import '../screens/organization/employee_kiosk_dashboard/controller/kiosk_employee_controller.dart';
import '../screens/organization/employee_kiosk_dashboard/repo/kiosk_employee_repo.dart';

import '../screens/attendance_actions/view/attendance_actions_view.dart';
import '../screens/attendance_actions/controller/attendance_actions_controller.dart';
import '../screens/attendance_actions/repo/attendance_actions_repo.dart';

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

    // 9. Daily Task Management Screen
    GetPage(
      name: Routes.TASKS,
      page: () => const TaskView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => TaskRepo(), fenix: true);
        Get.lazyPut(
          () => TaskController(repo: Get.find()),
          fenix: true,
        );
      }),
    ),

    // 10. Employee Performance & Evaluation Screen
    GetPage(
      name: Routes.EVALUATION,
      page: () => const EvaluationView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => EvaluationRepo(), fenix: true);
        Get.lazyPut(
          () => EvaluationController(repo: Get.find()),
          fenix: true,
        );
      }),
    ),

    // 11. Digital Smart Employee ID Card Screen
    GetPage(
      name: Routes.EMPLOYEE_CARD,
      page: () => const EmployeeCardView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => EmployeeCardRepo(), fenix: true);
        Get.lazyPut(
          () => EmployeeCardController(repo: Get.find()),
          fenix: true,
        );
      }),
    ),

    // 12. Organization Portal Hub (Gateway to Visitor Management, Gate Terminal & Staff Onboarding)
   

    // 13. Organization Mode Selection Screen
    GetPage(
      name: Routes.ORG_MODE_SELECTION,
      page: () => const OrgModeSelectionView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => OrgModeRepo(), fenix: true);
        Get.lazyPut(
          () => OrgModeController(repo: Get.find()),
          fenix: true,
        );
      }),
    ),

    // 14. Visitor Management Kiosk Terminal (Visitor Selection Hub)
    GetPage(
      name: Routes.VISITOR_MANAGEMENT,
      page: () => const VisitorManagementView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => VisitorRepo(), fenix: true);
        Get.lazyPut(
          () => VisitorController(repo: Get.find()),
          fenix: true,
        );
      }),
    ),

    // 14a. Visitor Check-In Entry Screen (Step Wizard, Camera Simulation, Intake Form)
    GetPage(
      name: Routes.VISITOR_ENTRY,
      page: () => const VisitorEntryView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => VisitorRepo(), fenix: true);
        Get.lazyPut(
          () => VisitorController(repo: Get.find()),
          fenix: true,
        );
      }),
    ),

    // 14b. Visitor Check-Out Exit Screen (Active Visitors Carousel, Face Verification, Departure)
    GetPage(
      name: Routes.VISITOR_EXIT,
      page: () => const VisitorExitView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => VisitorRepo(), fenix: true);
        Get.lazyPut(
          () => VisitorController(repo: Get.find()),
          fenix: true,
        );
      }),
    ),


    // 15. Employee Attendance Gate Terminal (Dual AI Face & Card QR Kiosk)
    GetPage(
      name: Routes.EMPLOYEE_TERMINAL,
      page: () => const EmployeeTerminalView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => EmployeeTerminalRepo(), fenix: true);
        Get.lazyPut(
          () => EmployeeTerminalController(repo: Get.find()),
          fenix: true,
        );
      }),
    ),

    // 16. Staff Onboarding / Employee Registration & Facial Biometric Enrollment
    GetPage(
      name: Routes.ADD_EMPLOYEE,
      page: () => const AddEmployeeView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AddEmployeeRepo(), fenix: true);
        Get.lazyPut(
          () => AddEmployeeController(repo: Get.find()),
          fenix: true,
        );
      }),
    ),

    // 17. Company Analytics Dashboard (Donut Presence Chart, Recent Activities & Leaves)
    GetPage(
      name: Routes.COMPANY_DASHBOARD,
      page: () => const CompanyDashboardView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => CompanyDashboardRepo(), fenix: true);
        Get.lazyPut(
          () => CompanyDashboardController(repo: Get.find()),
          fenix: true,
        );
      }),
    ),

    // 18. Shared Reception Kiosk Employee Dashboard (1-Min Idle Security Timeout)
    GetPage(
      name: Routes.EMPLOYEE_KIOSK_DASHBOARD,
      page: () => const EmployeeKioskDashboardView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => KioskEmployeeRepo(), fenix: true);
        Get.lazyPut(
          () => KioskEmployeeController(repo: Get.find()),
          fenix: true,
        );
      }),
    ),

    // 19. Individual Attendance Actions Hub & Break Management
    GetPage(
      name: Routes.ATTENDANCE_ACTIONS,
      page: () => const AttendanceActionsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AttendanceActionsRepo(), fenix: true);
        Get.lazyPut(
          () => AttendanceActionsController(repo: Get.find()),
          fenix: true,
        );
      }),
    ),
  ];
}

