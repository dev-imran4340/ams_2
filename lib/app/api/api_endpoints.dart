class ApiEndpoints {
  // Base URLs (Staging ground truth from doc/api.md)
  static const String baseUrl = 'https://laravel.ams-hrpayroll.com/api/v1';

  // 1. Authentication & Security (Phase 7 Live Engine)
  static const String login = '/auth/login';
  static const String twoFactor = '/auth/two-factor';
  static const String forgotPassword = '/auth/forgot-password';
  static const String logout = '/auth/logout';
 


  // 2. Identity, Dynamic Menu & Self-Service (Phase 7 Live Engine)
  static const String me = '/me';
  static const String meProfile = '/me/profile';
  static const String meCard = '/me/card';
  static const String meDetailsChange = '/me/details-change';

  // 3. Employees (Team and Colleagues)
  static const String employees = '/employees';
  static String employeeDetails(String id) => '/employees/$id';

  // 4. Universal Requests & Approvals Inbox (Phase 7 Live Engine)
  static const String approvals = '/approvals';
  static String approvalDetails(String id) => '/approvals/$id';
  static String approveApproval(String id) => '/approvals/$id/approve';
  static String rejectApproval(String id) => '/approvals/$id/reject';
  static String cancelApproval(String id) => '/approvals/$id/cancel';
  static const String leavesApply = '/leaves/apply';

  // 5. In-App Notifications & FCM Push Tokens
  static const String notifications = '/notifications';
  static String notificationRead(String id) => '/notifications/$id/read';
  static const String notificationsReadAll = '/notifications/read-all';
  static const String notificationPreferences = '/me/notification-preferences';
  static const String pushTokens = '/push-tokens';

  // 6. Attendance & Shifts (Phase 9 & 10 Live Engine)
  static const String attendanceToday = '/me/attendance/today';
  static const String attendance = '/me/attendance';
  static const String attendanceSummary = '/me/attendance/summary';
  static const String attendanceCorrections = '/me/attendance/corrections';
  static const String attendancePunches = '/me/attendance/punches';
  static const String meFace = '/me/face';
}
