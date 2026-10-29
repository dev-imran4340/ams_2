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
  static String employeeAttendance(String id) => '/employees/$id/attendance';
  static const String meFace = '/me/face';

  // 7. Schedule & Rota (Phase 8 Live Engine)
  static const String meSchedule = '/me/schedule';
  static String employeeSchedule(String id) => '/employees/$id/schedule';
  static const String holidays = '/holidays';

  // 8. Leave Management System (Phase 11 Live Engine)
  static const String leaveTypes = '/leave/types';
  static const String meLeaveBalances = '/me/leave/balances';
  static const String meLeaveRequests = '/me/leave/requests';
  static const String meLeaveRequestsPreview = '/me/leave/requests/preview';
  static String meLeaveCancel(String id) => '/me/leave/requests/$id/cancel';
  static const String leaveWhosOff = '/leave/whos-off';
  static String employeeLeave(String id) => '/employees/$id/leave';

  // 9. Payroll & Payslips (Phase 12 Live Engine)
  static const String mePayslips = '/me/payslips';
  static String mePayslipDetails(String id) => '/me/payslips/$id';
  static String mePayslipPdf(String id) => '/me/payslips/$id/pdf';
  static const String meSalary = '/me/salary';

  // 10. Loans, Advances & Expenses (Phase 13 Live Engine)
  static const String meMoneyRequestTypes = '/me/money-request-types';
  static const String meMoneyRequests = '/me/money-requests';
  static String meMoneyRequestDetails(String id) => '/me/money-requests/$id';
  static String meMoneyRequestCancel(String id) => '/me/money-requests/$id/cancel';

  // 11. Support Tickets & Helpdesk (Phase 10 Live Engine)
  static const String supportTickets = '/support/tickets';
  static String supportTicketDetails(String id) => '/support/tickets/$id';
  static String supportTicketReplies(String id) => '/support/tickets/$id/replies';
  static String supportTicketClose(String id) => '/support/tickets/$id/close';
  static String supportTicketReopen(String id) => '/support/tickets/$id/reopen';
  static String supportTicketFile(String id, String fileId) => '/support/tickets/$id/files/$fileId';
}

