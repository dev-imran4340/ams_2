// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';
import 'app_routes.dart';
import 'auth_guard_middleware.dart';
import '../core/services/permission_service.dart';

import '../screens/splash/view/splash_view.dart';
import '../screens/splash/controller/splash_controller.dart';

import '../screens/auth/view/login_view.dart';
import '../screens/auth/view/forgot_password_view.dart';
import '../screens/auth/controller/auth_controller.dart';
import '../screens/auth/repo/auth_repo.dart';

import '../screens/index/view/index_view.dart';
import '../screens/index/controller/index_controller.dart';
import '../screens/index/repo/index_repo.dart';

import '../screens/dashboard/view/dashboard_view.dart';
import '../screens/dashboard/controller/dashboard_controller.dart';
import '../screens/dashboard/repo/dashboard_repo.dart';

import '../screens/attendance_history/view/attendance_history_view.dart';
import '../screens/attendance_history/controller/attendance_history_controller.dart';
import '../screens/attendance_history/repo/attendance_history_repo.dart';

import '../screens/attendance_summary/view/attendance_summary_view.dart';
import '../screens/attendance_summary/controller/attendance_summary_controller.dart';
import '../screens/attendance_summary/repo/attendance_summary_repo.dart';

import '../screens/leaves/view/leave_management_view.dart';
import '../screens/leaves/controller/leave_controller.dart';
import '../screens/leaves/repo/leave_repo.dart';

import '../screens/approvals/view/approvals_inbox_view.dart';
import '../screens/approvals/controller/approval_controller.dart';
import '../screens/approvals/repo/approval_repo.dart';

import '../screens/profile/view/profile_view.dart';
import '../screens/profile/view/profile_details_view.dart';
import '../screens/profile/controller/profile_controller.dart';
import '../screens/profile/repo/profile_repo.dart';

import '../screens/correction/view/correction_view.dart';
import '../screens/correction/controller/correction_controller.dart';
import '../screens/correction/repo/correction_repo.dart';

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
import '../screens/evaluation/view/evaluation_details_view.dart';
import '../screens/evaluation/controller/evaluation_controller.dart';
import '../screens/evaluation/repo/evaluation_repo.dart';

import '../screens/employee_card/view/employee_card_view.dart';
import '../screens/employee_card/controller/employee_card_controller.dart';
import '../screens/employee_card/repo/employee_card_repo.dart';

import '../screens/kiosk/view/kiosk_view.dart';
import '../screens/kiosk/controller/kiosk_controller.dart';
import '../screens/kiosk/repo/kiosk_repo.dart';

import '../screens/edit_profile/view/edit_profile_view.dart';
import '../screens/edit_profile/controller/edit_profile_controller.dart';
import '../screens/edit_profile/repo/edit_profile_repo.dart';

import '../screens/employees/controller/department_employees_controller.dart';
import '../screens/employees/repo/department_employees_repo.dart';
import '../screens/employees/view/employees_view.dart';
import '../screens/main_shell/controller/session_me_controller.dart';

import '../screens/notifications/view/notifications_view.dart';
import '../screens/notifications/view/notification_preferences_view.dart';
import '../screens/notifications/controller/notification_controller.dart';
import '../screens/notifications/repo/notification_repo.dart';

import '../screens/schedule/view/schedule_view.dart';
import '../screens/schedule/controller/schedule_controller.dart';
import '../screens/schedule/repo/schedule_repo.dart';

import '../screens/payroll/view/payroll_view.dart';
import '../screens/payroll/controller/payroll_controller.dart';
import '../screens/payroll/repo/payroll_repo.dart';

import '../screens/loans/view/money_requests_view.dart';
import '../screens/loans/controller/money_request_controller.dart';
import '../screens/loans/repo/money_request_repo.dart';

import '../screens/support_tickets/view/support_tickets_view.dart';
import '../screens/support_tickets/controller/support_ticket_controller.dart';
import '../screens/support_tickets/repo/support_ticket_repo.dart';

import '../screens/documents/view/documents_view.dart';
import '../screens/documents/view/policy_details_view.dart';
import '../screens/documents/controller/document_controller.dart';
import '../screens/documents/repo/document_repo.dart';

import '../screens/news/view/news_view.dart';
import '../screens/news/view/announcement_details_view.dart';
import '../screens/news/controller/news_controller.dart';
import '../screens/news/repo/news_repo.dart';

import '../screens/assets/view/assets_view.dart';
import '../screens/assets/controller/asset_controller.dart';
import '../screens/assets/repo/asset_repo.dart';

import '../screens/training/view/training_view.dart';
import '../screens/training/controller/training_controller.dart';
import '../screens/training/repo/training_repo.dart';

import '../screens/checklists/view/checklists_view.dart';
import '../screens/checklists/controller/checklist_controller.dart';
import '../screens/checklists/repo/checklist_repo.dart';

import '../screens/helpdesk/view/helpdesk_view.dart';
import '../screens/helpdesk/view/helpdesk_ticket_view.dart';
import '../screens/helpdesk/controller/helpdesk_controller.dart';
import '../screens/helpdesk/repo/helpdesk_repo.dart';

import '../screens/job_description/view/job_description_view.dart';
import '../screens/job_description/controller/job_description_controller.dart';
import '../screens/job_description/repo/job_description_repo.dart';

import '../screens/company/dashboard/view/company_dashboard_view.dart';
import '../screens/company/dashboard/controller/company_dashboard_controller.dart';
import '../screens/company/dashboard/repo/company_dashboard_repo.dart';
import '../screens/company/kiosk_setup/view/kiosk_setup_view.dart';
import '../screens/kiosk/view/kiosk_main_view.dart';

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

    // 2.1 Forgot Password Screen
    GetPage(
      name: Routes.FORGOT_PASSWORD,
      page: () => const ForgotPasswordView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AuthRepo(), fenix: true);
        Get.lazyPut(() => AuthController(repo: Get.find()), fenix: true);
      }),
    ),

    // 3. Main Shell / Index Screen (Hosts Dashboard, Logs, Leaves, Profile)
    GetPage(
      name: Routes.INDEX,
      page: () => const IndexView(),
      middlewares: [AuthGuardMiddleware()],
      binding: BindingsBuilder(() {
        Get.lazyPut(() => IndexRepo(), fenix: true);
        Get.lazyPut(() => IndexController(repo: Get.find()), fenix: true);
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
        Get.lazyPut(() => ApprovalRepo(), fenix: true);
        Get.lazyPut(
          () => ApprovalController(repo: Get.find()),
          fenix: true,
        );
        Get.lazyPut(() => PayrollRepo(), fenix: true);
        Get.lazyPut(
          () => PayrollController(repo: Get.find()),
          fenix: true,
        );
        Get.lazyPut(() => MoneyRequestRepo(), fenix: true);
        Get.lazyPut(
          () => MoneyRequestController(repo: Get.find()),
          fenix: true,
        );
        Get.lazyPut(() => SupportTicketRepo(), fenix: true);
        Get.lazyPut(
          () => SupportTicketController(repo: Get.find()),
          fenix: true,
        );
        Get.lazyPut(() => ProfileRepo(), fenix: true);
        Get.lazyPut(
          () => ProfileController(repo: Get.find()),
          fenix: true,
        );
        Get.lazyPut(() => TaskRepo(), fenix: true);
        Get.lazyPut(
          () => TaskController(repo: Get.find()),
          fenix: true,
        );
        Get.lazyPut(() => EvaluationRepo(), fenix: true);
        Get.lazyPut(
          () => EvaluationController(repo: Get.find()),
          fenix: true,
        );
        Get.lazyPut(() => DepartmentEmployeesRepo(), fenix: true);
        Get.lazyPut(
          () => DepartmentEmployeesController(repo: Get.find()),
          fenix: true,
        );
        Get.lazyPut(() => NotificationRepo(), fenix: true);
        Get.lazyPut(
          () => NotificationController(repo: Get.find()),
          fenix: true,
        );
        Get.lazyPut(() => SessionMeController(), fenix: true);
      }),
    ),

    // 4. Standalone Dashboard Screen
    GetPage(
      name: Routes.DASHBOARD,
      page: () => const DashboardView(),
      middlewares: [AuthGuardMiddleware()],
      binding: BindingsBuilder(() {
        Get.lazyPut(() => DashboardRepo(), fenix: true);
        Get.lazyPut(() => DashboardController(repo: Get.find()), fenix: true);
        Get.lazyPut(() => SessionMeController(), fenix: true);
      }),
    ),

    // 5. Standalone Attendance History Screen
    GetPage(
      name: Routes.ATTENDANCE_HISTORY,
      page: () => const AttendanceHistoryView(),
      middlewares: [
        AuthGuardMiddleware(
          requiredModule: 'attendance',
          requiredPermission: 'attendance.view',
        ),
      ],
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AttendanceHistoryRepo(), fenix: true);
        Get.lazyPut(
          () => AttendanceHistoryController(repo: Get.find()),
          fenix: true,
        );
      }),
    ),

    // 5.1 Standalone Attendance Summary Screen
    GetPage(
      name: Routes.ATTENDANCE_SUMMARY,
      page: () => const AttendanceSummaryView(),
      middlewares: [
        AuthGuardMiddleware(
          requiredModule: 'attendance',
          requiredPermission: 'attendance.view',
        ),
      ],
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AttendanceSummaryRepo(), fenix: true);
        Get.lazyPut(
          () => AttendanceSummaryController(repo: Get.find()),
          fenix: true,
        );
      }),
    ),

    // 6. Regularization & Overtime Screen
    GetPage(
      name: Routes.CORRECTION,
      page: () => const CorrectionView(),
      middlewares: [
        AuthGuardMiddleware(
          requiredModule: 'attendance',
          requiredPermission: AppPermissions.attendanceView,
        ),
      ],
      binding: BindingsBuilder(() {
        Get.lazyPut(() => CorrectionRepo(), fenix: true);
        Get.lazyPut(
          () => CorrectionController(repo: Get.find()),
          fenix: true,
        );
      }),
    ),

    // 7. Multi-Factor Verification - Step 1: Employee Card QR Scanner
    GetPage(
      name: Routes.QR_SCANNER,
      page: () => const QRScannerView(),
      middlewares: [AuthGuardMiddleware()],
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
      middlewares: [AuthGuardMiddleware()],
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
      middlewares: [AuthGuardMiddleware(requiredModule: 'onboarding')],
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
      middlewares: [
        AuthGuardMiddleware(
          requiredModule: 'performance',
          requiredPermission: 'performance.view',
        ),
      ],
      binding: BindingsBuilder(() {
        Get.lazyPut(() => EvaluationRepo(), fenix: true);
        Get.lazyPut(
          () => EvaluationController(repo: Get.find()),
          fenix: true,
        );
      }),
    ),

    // 10b. Employee Evaluation Details Screen
    GetPage(
      name: Routes.EVALUATION_DETAILS,
      page: () => const EvaluationDetailsView(),
      transition: Transition.rightToLeftWithFade,
      middlewares: [
        AuthGuardMiddleware(
          requiredModule: 'performance',
          requiredPermission: 'performance.view',
        ),
      ],
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
      middlewares: [
        AuthGuardMiddleware(requiredPermission: 'employees.cards.print'),
      ],
      binding: BindingsBuilder(() {
        Get.lazyPut(() => EmployeeCardRepo(), fenix: true);
        Get.lazyPut(
          () => EmployeeCardController(repo: Get.find()),
          fenix: true,
        );
      }),
    ),

    // 15. Enterprise Kiosk & Terminal PIN (Phase 10)
    GetPage(
      name: Routes.KIOSK,
      page: () => const KioskView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => KioskRepo(), fenix: true);
        Get.lazyPut(
          () => KioskController(repo: Get.find()),
          fenix: true,
        );
      }),
    ),

    // 19. Individual Attendance History Hub & Break Management (Aliases /attendance-actions)
    GetPage(
      name: Routes.ATTENDANCE_ACTIONS,
      page: () => const AttendanceHistoryView(),
      middlewares: [AuthGuardMiddleware(requiredModule: 'attendance')],
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AttendanceHistoryRepo(), fenix: true);
        Get.lazyPut(
          () => AttendanceHistoryController(repo: Get.find()),
          fenix: true,
        );
      }),
    ),

    // 20. Edit Employee Profile Screen
    GetPage(
      name: Routes.EDIT_PROFILE,
      page: () => const EditProfileView(),
      middlewares: [AuthGuardMiddleware()],
      binding: BindingsBuilder(() {
        Get.lazyPut(() => EditProfileRepo(), fenix: true);
        Get.lazyPut(
          () => EditProfileController(repo: Get.find()),
          fenix: true,
        );
      }),
    ),

    // 21. Profile Screen (Hub with Cards, Settings, 2FA & Logout)
    GetPage(
      name: Routes.PROFILE,
      page: () => const ProfileView(),
      middlewares: [AuthGuardMiddleware()],
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ProfileRepo(), fenix: true);
        Get.lazyPut(
          () => ProfileController(repo: Get.find()),
          fenix: true,
        );
      }),
    ),

    // 22. Detailed Profile Screen (Tabs & Full Records)
    GetPage(
      name: Routes.PROFILE_DETAILS,
      page: () => const ProfileDetailsView(),
      middlewares: [AuthGuardMiddleware()],
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ProfileRepo(), fenix: true);
        Get.lazyPut(
          () => ProfileController(repo: Get.find()),
          fenix: true,
        );
      }),
    ),

    // 23. Leave Management Screen (Phase 11)
    GetPage(
      name: Routes.LEAVE,
      page: () => const LeaveManagementView(),
      middlewares: [
        AuthGuardMiddleware(
          requiredModule: 'leave',
          requiredPermission: 'leave.view',
        ),
      ],
      binding: BindingsBuilder(() {
        Get.lazyPut(() => LeaveRepo(), fenix: true);
        Get.lazyPut(
          () => LeaveController(repo: Get.find()),
          fenix: true,
        );
      }),
    ),

    // 23.1 Universal Requests & Approvals Inbox Screen
    GetPage(
      name: Routes.APPROVALS,
      page: () => const ApprovalsInboxView(),
      middlewares: [AuthGuardMiddleware()],
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ApprovalRepo(), fenix: true);
        Get.lazyPut(
          () => ApprovalController(repo: Get.find()),
          fenix: true,
        );
      }),
    ),

    // 24. In-App Notifications Screen (The Bell)
    GetPage(
      name: Routes.NOTIFICATIONS,
      page: () => const NotificationsView(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 250),
      middlewares: [AuthGuardMiddleware()],
      binding: BindingsBuilder(() {
        Get.lazyPut(() => NotificationRepo(), fenix: true);
        Get.lazyPut(
          () => NotificationController(repo: Get.find()),
          fenix: true,
        );
      }),
    ),

    // 25. Notification Preferences Screen (Channel Toggles)
    GetPage(
      name: Routes.NOTIFICATION_PREFERENCES,
      page: () => const NotificationPreferencesView(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 250),
      middlewares: [AuthGuardMiddleware()],
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<NotificationRepo>()) {
          Get.lazyPut(() => NotificationRepo(), fenix: true);
        }
        if (!Get.isRegistered<NotificationController>()) {
          Get.lazyPut(
            () => NotificationController(repo: Get.find()),
            fenix: true,
          );
        }
      }),
    ),

    // 26. Work Schedule & Rota Screen (Phase 8 Live Engine)
    GetPage(
      name: Routes.SCHEDULE,
      page: () => const ScheduleView(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 250),
      middlewares: [
        AuthGuardMiddleware(
          requiredPermission: 'schedules.view',
        ),
      ],
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ScheduleRepo(), fenix: true);
        Get.lazyPut(
          () => ScheduleController(repo: Get.find()),
          fenix: true,
        );
      }),
    ),

    // 27. Payroll & Payslips Screen (Phase 12 Live Engine)
    GetPage(
      name: Routes.PAYROLL,
      page: () => const PayrollView(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 250),
      middlewares: [
        AuthGuardMiddleware(
          requiredModule: 'payroll',
          requiredPermission: 'pay.view',
        ),
      ],
      binding: BindingsBuilder(() {
        Get.lazyPut(() => PayrollRepo(), fenix: true);
        Get.lazyPut(
          () => PayrollController(repo: Get.find()),
          fenix: true,
        );
      }),
    ),

    // 28. Loans, Advances & Expenses Screen (Phase 13 Live Engine)
    GetPage(
      name: Routes.LOANS,
      page: () => const MoneyRequestsView(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 250),
      middlewares: [
        AuthGuardMiddleware(
          requiredModule: 'loans_expenses',
          requiredPermission: 'money.view',
        ),
      ],
      binding: BindingsBuilder(() {
        Get.lazyPut(() => MoneyRequestRepo(), fenix: true);
        Get.lazyPut(
          () => MoneyRequestController(repo: Get.find()),
          fenix: true,
        );
      }),
    ),

    // 29. Support Tickets & Helpdesk Screen (Phase 10 Live Engine)
    GetPage(
      name: Routes.SUPPORT_TICKETS,
      page: () => const SupportTicketsView(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 250),
      middlewares: [
        AuthGuardMiddleware(
          requiredPermission: AppPermissions.supportView,
        ),
      ],
      binding: BindingsBuilder(() {
        Get.lazyPut(() => SupportTicketRepo(), fenix: true);
        Get.lazyPut(
          () => SupportTicketController(repo: Get.find()),
          fenix: true,
        );
      }),
    ),

    // 30. Documents, Policies & Letters Screen (Phase 17 Live Engine)
    GetPage(
      name: Routes.DOCUMENTS,
      page: () => const DocumentsView(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 250),
      middlewares: [
        AuthGuardMiddleware(
          requiredModule: 'documents',
          requiredPermission: 'documents.view',
        ),
      ],
      binding: BindingsBuilder(() {
        Get.lazyPut(() => DocumentRepo(), fenix: true);
        Get.lazyPut(
          () => DocumentController(repo: Get.find()),
          fenix: true,
        );
      }),
    ),

    // 31. Policy Details Screen
    GetPage(
      name: Routes.POLICY_DETAILS,
      page: () => const PolicyDetailsView(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 250),
      middlewares: [
        AuthGuardMiddleware(
          requiredModule: 'documents',
          requiredPermission: AppPermissions.documentsView,
        ),
      ],
      binding: BindingsBuilder(() {
        Get.lazyPut(() => DocumentRepo(), fenix: true);
        Get.lazyPut(
          () => DocumentController(repo: Get.find()),
          fenix: true,
        );
      }),
    ),

    // 32. News, Events & Milestones Screen (Phase 17 Pillar 2)
    GetPage(
      name: Routes.NEWS,
      page: () => const NewsView(),
      middlewares: [AuthGuardMiddleware(requiredModule: 'documents')],
      binding: BindingsBuilder(() {
        Get.lazyPut(() => NewsRepo(), fenix: true);
        Get.lazyPut(
          () => NewsController(repo: Get.find()),
          fenix: true,
        );
      }),
    ),

    // 33. Announcement Details Screen
    GetPage(
      name: Routes.ANNOUNCEMENT_DETAILS,
      page: () => const AnnouncementDetailsView(),
      transition: Transition.rightToLeftWithFade,
      middlewares: [AuthGuardMiddleware(requiredModule: 'documents')],
      binding: BindingsBuilder(() {
        Get.lazyPut(() => NewsRepo(), fenix: true);
        Get.lazyPut(
          () => NewsController(repo: Get.find()),
          fenix: true,
        );
      }),
    ),

    // 34. Company Assets Screen (Phase 18 Part 2)
    GetPage(
      name: Routes.ASSETS,
      page: () => const AssetsView(),
      transition: Transition.rightToLeftWithFade,
      middlewares: [
        AuthGuardMiddleware(
          requiredModule: 'onboarding',
          requiredPermission: AppPermissions.assetsView,
        ),
      ],
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AssetRepo(), fenix: true);
        Get.lazyPut(
          () => AssetController(repo: Get.find()),
          fenix: true,
        );
      }),
    ),

    // 35. Training & Certifications Screen (Phase 18 Part 3)
    GetPage(
      name: Routes.TRAINING,
      page: () => const TrainingView(),
      transition: Transition.rightToLeftWithFade,
      middlewares: [
        AuthGuardMiddleware(
          requiredModule: 'onboarding',
          requiredPermission: AppPermissions.trainingView,
        ),
      ],
      binding: BindingsBuilder(() {
        Get.lazyPut(() => TrainingRepo(), fenix: true);
        Get.lazyPut(
          () => TrainingController(repo: Get.find()),
          fenix: true,
        );
      }),
    ),

    // 36. Checklists / Onboarding & Offboarding (Phase 18 Part 4)
    GetPage(
      name: Routes.CHECKLISTS,
      page: () => const ChecklistsView(),
      transition: Transition.rightToLeftWithFade,
      middlewares: [
        AuthGuardMiddleware(
          requiredModule: 'onboarding',
          requiredPermission: AppPermissions.onboardingManage,
        ),
      ],
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ChecklistRepo(), fenix: true);
        Get.lazyPut(
          () => ChecklistController(repo: Get.find()),
          fenix: true,
        );
      }),
    ),

    // 37. HR Helpdesk & Support Tickets (Phase 18 Part 5)
    GetPage(
      name: Routes.HELPDESK,
      page: () => const HelpdeskView(),
      transition: Transition.rightToLeftWithFade,
      middlewares: [AuthGuardMiddleware(requiredModule: 'onboarding')],
      binding: BindingsBuilder(() {
        Get.lazyPut(() => HelpdeskRepo(), fenix: true);
        Get.lazyPut(
          () => HelpdeskController(repo: Get.find()),
          fenix: true,
        );
      }),
    ),

    // 38. HR Helpdesk Ticket Discussion Screen
    GetPage(
      name: Routes.HELPDESK_TICKET,
      page: () => const HelpdeskTicketView(),
      transition: Transition.rightToLeftWithFade,
      middlewares: [AuthGuardMiddleware(requiredModule: 'onboarding')],
      binding: BindingsBuilder(() {
        Get.lazyPut(() => HelpdeskRepo(), fenix: true);
        Get.lazyPut(
          () => HelpdeskController(repo: Get.find()),
          fenix: true,
        );
      }),
    ),

    // 39. Job Description Screen (Phase 18)
    GetPage(
      name: Routes.JOB_DESCRIPTION,
      page: () => const JobDescriptionView(),
      transition: Transition.rightToLeftWithFade,
      middlewares: [AuthGuardMiddleware()],
      binding: BindingsBuilder(() {
        Get.lazyPut(() => JobDescriptionRepo(), fenix: true);
        Get.lazyPut(
          () => JobDescriptionController(repo: Get.find()),
          fenix: true,
        );
      }),
    ),

    // 40. Company Dedicated Dashboard
    GetPage(
      name: Routes.COMPANY_DASHBOARD,
      page: () => const CompanyDashboardView(),
      middlewares: [AuthGuardMiddleware()],
      binding: BindingsBuilder(() {
        Get.lazyPut(() => CompanyDashboardRepo(), fenix: true);
        Get.lazyPut(
          () => CompanyDashboardController(repo: Get.find()),
          fenix: true,
        );
      }),
    ),

    // 41. Company Employees Directory (Reuses EmployeesView with company mode)
    GetPage(
      name: Routes.COMPANY_EMPLOYEES,
      page: () => const EmployeesView(),
      middlewares: [AuthGuardMiddleware(requiredPermission: 'employees.view')],
      binding: BindingsBuilder(() {
        Get.lazyPut(() => DepartmentEmployeesRepo(), fenix: true);
        Get.lazyPut(
          () => DepartmentEmployeesController(repo: Get.find()),
          fenix: true,
        );
      }),
    ),

    // 42. Kiosk Setup & Provisioning
    GetPage(
      name: Routes.KIOSK_SETUP,
      page: () => const KioskSetupView(),
      middlewares: [AuthGuardMiddleware(requiredPermission: 'kiosks.manage')],
      binding: BindingsBuilder(() {
        Get.lazyPut(() => CompanyDashboardRepo(), fenix: true);
        Get.lazyPut(
          () => CompanyDashboardController(repo: Get.find()),
          fenix: true,
        );
      }),
    ),

    // 43. Kiosk Main Shared Tablet Screen
    GetPage(
      name: Routes.KIOSK_MAIN,
      page: () => const KioskMainView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => KioskRepo(), fenix: true);
        Get.lazyPut(
          () => KioskController(repo: Get.find()),
          fenix: true,
        );
      }),
    ),

    // 44. Department Employees Directory
    GetPage(
      name: Routes.EMPLOYEES,
      page: () => const DepartmentEmployeesView(),
      middlewares: [AuthGuardMiddleware(requiredPermission: 'employees.view')],
      binding: BindingsBuilder(() {
        Get.lazyPut(() => DepartmentEmployeesRepo(), fenix: true);
        Get.lazyPut(
          () => DepartmentEmployeesController(repo: Get.find()),
          fenix: true,
        );
      }),
    ),
  ];
}

