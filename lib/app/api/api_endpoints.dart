class ApiEndpoints {
  // Base URLs (Staging ground truth from doc/api.md)
  static const String baseUrl = 'https://laravel.ams-hrpayroll.com/api/v1';

  // 1. Authentication & Security (Phase 7 Live Engine)
  static const String login = '/auth/login';
  static const String twoFactor = '/auth/two-factor';
  static const String forgotPassword = '/auth/forgot-password';
  static const String logout = '/auth/logout';
  static const String biometricLogin = '/auth/biometric-login';
  static const String register = '/auth/register';
  static const String logoutAll = '/auth/logout-all';
  static const String refreshToken = '/auth/refresh-token';
  static const String changePassword = '/auth/change-password';
  static const String resetPassword = '/auth/reset-password';

  // 2. Identity, Dynamic Menu & Self-Service (Phase 7 Live Engine)
  static const String me = '/me';
  static const String meProfile = '/me/profile';
  static const String meCard = '/me/card';
  static const String meDetailsChange = '/me/details-change';
  static const String meNotificationPreferences = '/me/notification-preferences';

  // 3. Employees Directory & Profiles (Phase 7 Live Engine)
  static const String employees = '/employees';
  static String employeeItem(String id) => '/employees/$id';

  // 4. Unified Requests & Approvals Inbox (Phase 7 Live Engine)
  static const String approvals = '/approvals';
  static String approvalItem(String id) => '/approvals/$id';
  static String approvalApprove(String id) => '/approvals/$id/approve';
  static String approvalReject(String id) => '/approvals/$id/reject';
  static String approvalCancel(String id) => '/approvals/$id/cancel';

  // 5. In-App Bell & Push Notifications (Phase 7 Live Engine)
  static const String notifications = '/notifications';
  static String notificationItem(String id) => '/notifications/$id';
  static String notificationRead(String id) => '/notifications/$id/read';
  static const String notificationsReadAll = '/notifications/read-all';
  static const String pushTokens = '/push-tokens';

  // 6. Dashboard & Telemetry
  static const String dashboard = '/dashboard';
  static const String dashboardOverview = '/dashboard/overview';
  static const String dashboardLiveStatus = '/dashboard/live-status';
  static const String dashboardRecentActivity = '/dashboard/recent-activity';

  // 7. Attendance Actions & Shift Telemetry (Roadmap Phase 10)
  static const String shiftTelemetry = '/attendance/shift-telemetry';
  static const String punchIn = '/attendance/punch-in';
  static const String punchOut = '/attendance/punch-out';
  static const String breakStart = '/attendance/break-start';
  static const String breakEnd = '/attendance/break-end';
  static const String moneyRequests = '/attendance/money-requests';

  // 8. Attendance History & Audit
  static const String attendanceHistory = '/attendance/history';
  static const String attendanceDayDetails = '/attendance/day-details';
  static const String attendanceExport = '/attendance/export';

  // 9. Leave Management (Roadmap Phase 11)
  static const String leaveBalances = '/leaves/balances';
  static const String leaveRequests = '/leaves/requests';
  static const String leaveApply = '/leaves/apply';
  static String leaveItem(String id) => '/leaves/requests/$id';

  // 10. Regularization & Overtime
  static const String regularizationTelemetry = '/regularization/telemetry';
  static const String regularizationRequests = '/regularization/requests';
  static const String regularizationSubmit = '/regularization/submit';
  static String regularizationItem(String id) => '/regularization/requests/$id';

  // 11. Tasks & Daily Deliverables
  static const String tasks = '/tasks';
  static const String taskTelemetry = '/tasks/telemetry';
  static String taskStatus(String id) => '/tasks/$id/status';
  static String taskItem(String id) => '/tasks/$id';

  // 12. Performance Evaluation & Appraisals
  static const String evaluationReport = '/evaluations/report';
  static const String evaluationCycles = '/evaluations/cycles';
  static const String evaluationAcknowledge = '/evaluations/acknowledge';

  // 13. Digital Employee ID Card
  static const String employeeCard = '/employee-card';
  static const String employeeCardPdf = '/employee-card/pdf';

  // 14. Biometric Verification (Roadmap Phase 10)
  static const String faceVerify = '/biometrics/face-verify';
  static const String qrVerify = '/biometrics/qr-verify';

  // 15. User Profile & Preferences
  static const String userProfile = '/user/profile';
  static const String updateProfile = '/user/profile';
  static const String uploadAvatar = '/user/profile/avatar';
  static const String updatePreferences = '/user/preferences';

  // 16. Organization Hub & Modes
  static const String orgModes = '/organization/modes';
  static const String registerTerminal = '/organization/terminal/register';

  // 17. Enterprise Company Dashboard
  static const String companyDashboard = '/organization/dashboard';
  static const String departmentSummary = '/organization/departments-summary';

  // 18. Terminal & Kiosk Gate Station (Roadmap Phase 14)
  static const String terminalTelemetry = '/organization/terminal/telemetry';
  static const String terminalRecentPunches = '/organization/terminal/recent-punches';
  static const String terminalPunch = '/organization/terminal/punch';
  static String kioskEmployee(String id) => '/organization/kiosk/employee/$id';

  // 19. Visitor Management & Gate Pass (Roadmap Phase 14)
  static const String visitors = '/organization/visitors';
  static const String visitorHosts = '/organization/visitors/hosts';
  static const String visitorEntry = '/organization/visitors/entry';
  static String visitorExit(String id) => '/organization/visitors/$id/exit';

  // 20. Admin Employee Onboarding
  static const String employeeLookups = '/organization/employees/lookup';
  static const String addEmployee = '/organization/employees';
}
