class ApiEndpoints {
  // Base URLs
  static const String baseUrl = 'https://api.ams2.com/api/v1';

  // 1. Authentication & Security
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String me = '/auth/me';
  static const String logout = '/auth/logout';
  static const String logoutAll = '/auth/logout-all';
  static const String refreshToken = '/auth/refresh-token';
  static const String changePassword = '/auth/change-password';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // 2. User & Profile
  static const String userProfile = '/user/profile';
  static const String updateProfile = '/user/profile/update';

  // 3. Dashboard & Analytics
  static const String dashboard = '/dashboard';
  static const String dashboardOverview = '/dashboard/overview';

  // 4. Notifications & Settings
  static const String notifications = '/notifications';
  static String notificationItem(String id) => '/notifications/$id';
}
