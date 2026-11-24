import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../api/app_preferences.dart';
import '../widgets/custom_snackbar.dart';

/// Centralized technical API permission keys synchronized with Web Admin Role Editor
/// and doc/ams_permissions_master_matrix.md (RBAC Master Matrix).
class AppPermissions {
  AppPermissions._();

  // Category 1: Users & Roles
  static const String rolesView = 'roles.view';
  static const String rolesManage = 'roles.manage';
  static const String usersView = 'users.view';
  static const String usersManage = 'users.manage';

  // Category 2: Company & Organisation
  static const String companyManage = 'company.manage';
  static const String organisationView = 'organisation.view';
  static const String organisationManage = 'organisation.manage';

  // Category 3: Employees (Directory & Profiles)
  static const String employeesView = 'employees.view';
  static const String employeesSensitiveView = 'employees.sensitive.view';
  static const String employeesManage = 'employees.manage';
  static const String employeesAccountsManage = 'employees.accounts.manage';
  static const String employeesCardsPrint = 'employees.cards.print';
  static const String employeesExport = 'employees.export';

  // Category 4: Attendance & Time Tracking
  static const String attendanceView = 'attendance.view';
  static const String attendanceManage = 'attendance.manage';
  static const String attendanceSetup = 'attendance.setup';
  static const String attendanceFaceManage = 'attendance.face.manage';
  static const String kiosksManage = 'kiosks.manage';

  // Category 5: Schedules & Duty Rotas
  static const String schedulesView = 'schedules.view';
  static const String schedulesManage = 'schedules.manage';
  static const String schedulesSetup = 'schedules.setup';

  // Category 6: Requests & Approvals
  static const String approvalsManage = 'approvals.manage';
  static const String approvalsOverride = 'approvals.override';

  // Category 7: Leave Management
  static const String leaveView = 'leave.view';
  static const String leaveManage = 'leave.manage';
  static const String leaveAdjust = 'leave.adjust';
  static const String leaveSetup = 'leave.setup';

  // Category 8: Pay & Payroll
  static const String payView = 'pay.view';
  static const String payManage = 'pay.manage';
  static const String payrollRun = 'payroll.run';
  static const String payrollExport = 'payroll.export';
  static const String payrollSetup = 'payroll.setup';

  // Category 9: Loans, Advances & Expenses
  static const String moneyView = 'money.view';
  static const String moneyManage = 'money.manage';
  static const String moneySetup = 'money.setup';

  // Category 10: Performance Reviews
  static const String performanceView = 'performance.view';
  static const String performanceManage = 'performance.manage';
  static const String performanceSetup = 'performance.setup';

  // Category 11: Documents, Letters & News
  static const String documentsView = 'documents.view';
  static const String documentsManage = 'documents.manage';
  static const String documentsSetup = 'documents.setup';
  static const String lettersIssue = 'letters.issue';
  static const String lettersSetup = 'letters.setup';
  static const String communicationManage = 'communication.manage';

  // Category 12: Onboarding, Checklists & Tasks
  static const String tasksManage = 'tasks.manage';
  static const String onboardingManage = 'onboarding.manage';
  static const String onboardingSetup = 'onboarding.setup';
  static const String jobDescriptionsManage = 'job_descriptions.manage';

  // Category 13: Assets & Training
  static const String assetsView = 'assets.view';
  static const String assetsManage = 'assets.manage';
  static const String trainingView = 'training.view';
  static const String trainingManage = 'training.manage';

  // Category 14: HR Helpdesk & Support
  static const String helpdeskHandle = 'helpdesk.handle';
  static const String helpdeskSetup = 'helpdesk.setup';
  static const String supportView = 'support.view';
  static const String supportRaise = 'support.raise';

  // Category 15: Biometric Devices & Reports
  static const String devicesManage = 'devices.manage';
  static const String reportsView = 'reports.view';
  static const String reportsSchedule = 'reports.schedule';
}

/// Standardized permission scopes from Web Admin dropdown selection.
class AppPermissionScopes {
  AppPermissionScopes._();

  static const String company = 'company';
  static const String location = 'location';
  static const String department = 'department';
  static const String own = 'own';
  static const String all = 'all'; // Standard alias for company
}

/// Centralized Access Control & Permission Evaluation Engine for AMS 2.
/// Evaluates binary permissions, scoped lists, hierarchical inheritance,
/// and guards action execution across views, controllers, and repositories.
class PermissionService {
  PermissionService._();

  /// Evaluates mathematical scope hierarchy:
  /// company (or all) [Rank 4] > location [Rank 3] > department [Rank 2] > own [Rank 1]
  static int _scopeRank(String scope) {
    final s = scope.toLowerCase().trim();
    switch (s) {
      case 'company':
      case 'all':
        return 4;
      case 'location':
        return 3;
      case 'department':
        return 2;
      case 'own':
      case 'records':
        return 1;
      default:
        return 0;
    }
  }

  /// Verifies if [assignedScope] satisfies or exceeds [requiredScope].
  static bool isScopeSufficient(String assignedScope, String requiredScope) {
    final int assigned = _scopeRank(assignedScope);
    final int required = _scopeRank(requiredScope);
    if (assigned == 0 || required == 0) {
      return assignedScope.toLowerCase().trim() == requiredScope.toLowerCase().trim();
    }
    return assigned >= required;
  }

  /// Verifies whether the authenticated user possesses a given permission and optional scope.
  /// Handles:
  /// - Missing key -> false (Access Denied)
  /// - Binary permission (`"key": null` or `"key": true`) -> true
  /// - Explicit false -> false
  /// - Scoped list (`"key": ["department"]`) -> hierarchical check
  /// - Empty list (`"key": []`) -> false
  /// - Single string representation -> normalized to list check
  static bool hasPermission(String key, [String? requiredScope]) {
    final perms = AppPreferences.permissions;
    if (perms == null || !perms.containsKey(key)) return false;

    final value = perms[key];

    // Explicit false check
    if (value == false) return false;

    // Binary allowed (Type A in Master Matrix, e.g. "support.raise": null, "kiosks.manage": null)
    if (value == null || value == true) return true;

    // Scoped permissions (Type B, C, D in Master Matrix)
    List<dynamic> scopeList;
    if (value is List) {
      scopeList = value;
    } else if (value is String) {
      scopeList = [value];
    } else {
      return false;
    }

    if (scopeList.isEmpty) return false;

    // If no scope constraint is requested, holding any valid scope grants access
    if (requiredScope == null || requiredScope.trim().isEmpty) {
      return true;
    }

    final int reqRank = _scopeRank(requiredScope);

    for (final item in scopeList) {
      final String s = item.toString();
      final int rank = _scopeRank(s);
      if (rank >= reqRank && reqRank > 0) return true;
      if (s.toLowerCase().trim() == requiredScope.toLowerCase().trim()) return true;
    }

    return false;
  }

  /// Checks if any of the provided permissions is granted.
  static bool hasAny(List<String> keys, [String? requiredScope]) {
    for (final k in keys) {
      if (hasPermission(k, requiredScope)) return true;
    }
    return false;
  }

  /// Checks if all of the provided permissions are granted.
  static bool hasAll(List<String> keys, [String? requiredScope]) {
    for (final k in keys) {
      if (!hasPermission(k, requiredScope)) return false;
    }
    return true;
  }

  /// Returns the highest granted scope name for a given permission key
  /// (e.g. 'company', 'location', 'department', 'own') or null if denied.
  static String? getHighestScope(String key) {
    final perms = AppPreferences.permissions;
    if (perms == null || !perms.containsKey(key)) return null;

    final value = perms[key];
    if (value == null || value == true) return 'company';
    if (value is! List && value is! String) return null;

    final List<dynamic> list = value is List ? value : [value];
    if (list.isEmpty) return null;

    String? topScope;
    int maxRank = 0;

    for (final item in list) {
      final s = item.toString().toLowerCase().trim();
      final rank = _scopeRank(s);
      if (rank > maxRank) {
        maxRank = rank;
        topScope = s == 'all' ? 'company' : s;
      }
    }

    return topScope;
  }

  /// Verifies permission before executing an action.
  /// If unauthorized:
  /// - Blocks execution
  /// - Displays a consistent Access Denied snackbar
  /// Returns true if authorized, false otherwise.
  static bool verifyAction(
    String permissionKey, {
    String? requiredScope,
    String? actionName,
    bool showToast = true,
  }) {
    final allowed = hasPermission(permissionKey, requiredScope);
    if (!allowed) {
      if (kDebugMode) {
        Get.log('🚫 [PermissionService] Action blocked. Missing: $permissionKey (scope: $requiredScope)');
      }
      if (showToast) {
        final action = actionName != null && actionName.isNotEmpty
            ? 'to $actionName'
            : 'to perform this action';
        CustomSnackbar.showError(
          title: 'Access Denied',
          message: 'You do not have permission $action.',
        );
      }
      return false;
    }
    return true;
  }

  /// Verifies company module subscription (core module is always active).
  static bool hasModule(String moduleKey) {
    return AppPreferences.hasModule(moduleKey);
  }

  /// Verifies dynamic menu item presence in GET /me payload.
  static bool hasMenuItem(String menuKey) {
    final menu = AppPreferences.menu;
    if (menu == null || menu.isEmpty) return false;
    return menu.any((item) {
      if (item is Map) {
        return item['key']?.toString() == menuKey;
      }
      return false;
    });
  }
}
