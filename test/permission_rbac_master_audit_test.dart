import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:ams_2/app/api/app_preferences.dart';
import 'package:ams_2/app/core/services/permission_service.dart';
import 'package:ams_2/app/core/utils/secure_storage_service.dart';
import 'package:ams_2/app/routes/app_routes.dart';
import 'package:ams_2/app/routes/auth_guard_middleware.dart';
import 'package:ams_2/app/screens/main_shell/controller/session_me_controller.dart';
import 'package:ams_2/app/screens/index/model/me_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    const MethodChannel channel =
        MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return '.';
    });
    await GetStorage.init();
    SecureStorageService.useMemoryFallback = true;
  });

  setUp(() async {
    Get.testMode = true;
    await AppPreferences.clearAll();
    SecureStorageService.resetMemoryFallback();
  });

  tearDown(() {
    Get.reset();
  });

  // =========================================================================
  // GROUP 1: All Permissions Across 15 Categories (Doc: ams_permissions_master_matrix.md)
  // =========================================================================
  group('1. Master RBAC Permissions Catalog (All 15 Categories)', () {
    test('Category 1: Users & Roles (roles.view, roles.manage, users.view, users.manage)', () async {
      final permissions = <String, dynamic>{
        AppPermissions.rolesView: true,
        AppPermissions.rolesManage: false,
        AppPermissions.usersView: null, // Type A binary allowed
        AppPermissions.usersManage: 'allowed',
      };
      await AppPreferences.setPermissions(permissions);

      expect(AppPreferences.hasPermission(AppPermissions.rolesView), isTrue);
      expect(AppPreferences.hasPermission(AppPermissions.rolesManage), isFalse);
      expect(AppPreferences.hasPermission(AppPermissions.usersView), isTrue);
      expect(AppPreferences.hasPermission(AppPermissions.usersManage), isTrue);
    });

    test('Category 2: Company & Organisation (company.manage, organisation.view, organisation.manage)', () async {
      final permissions = <String, dynamic>{
        AppPermissions.companyManage: true,
        AppPermissions.organisationView: true,
        AppPermissions.organisationManage: false,
      };
      await AppPreferences.setPermissions(permissions);

      expect(AppPreferences.hasPermission(AppPermissions.companyManage), isTrue);
      expect(AppPreferences.hasPermission(AppPermissions.organisationView), isTrue);
      expect(AppPreferences.hasPermission(AppPermissions.organisationManage), isFalse);
    });

    test('Category 3: Employees (employees.view, sensitive.view, manage, accounts.manage, cards.print, export)', () async {
      final permissions = <String, dynamic>{
        AppPermissions.employeesView: ['own'],
        AppPermissions.employeesSensitiveView: ['department'],
        AppPermissions.employeesManage: ['department'],
        AppPermissions.employeesAccountsManage: ['company'],
        AppPermissions.employeesCardsPrint: ['own'],
        AppPermissions.employeesExport: ['company'],
      };
      await AppPreferences.setPermissions(permissions);

      expect(AppPreferences.hasPermission(AppPermissions.employeesView, AppPermissionScopes.own), isTrue);
      expect(AppPreferences.hasPermission(AppPermissions.employeesView, AppPermissionScopes.department), isFalse);
      expect(AppPreferences.hasPermission(AppPermissions.employeesSensitiveView, AppPermissionScopes.department), isTrue);
      expect(AppPreferences.hasPermission(AppPermissions.employeesManage, AppPermissionScopes.department), isTrue);
      expect(AppPreferences.hasPermission(AppPermissions.employeesAccountsManage, AppPermissionScopes.company), isTrue);
      expect(AppPreferences.hasPermission(AppPermissions.employeesCardsPrint, AppPermissionScopes.own), isTrue);
      expect(AppPreferences.hasPermission(AppPermissions.employeesExport, AppPermissionScopes.company), isTrue);
    });

    test('Category 4: Attendance & Time Tracking (attendance.view, manage, setup, face.manage, kiosks.manage)', () async {
      final permissions = <String, dynamic>{
        AppPermissions.attendanceView: ['own'],
        AppPermissions.attendanceManage: ['department'],
        AppPermissions.attendanceSetup: true,
        AppPermissions.attendanceFaceManage: ['location'],
        AppPermissions.kiosksManage: ['company'],
      };
      await AppPreferences.setPermissions(permissions);

      expect(AppPreferences.hasPermission(AppPermissions.attendanceView, AppPermissionScopes.own), isTrue);
      expect(AppPreferences.hasPermission(AppPermissions.attendanceManage, AppPermissionScopes.department), isTrue);
      expect(AppPreferences.hasPermission(AppPermissions.attendanceSetup), isTrue);
      expect(AppPreferences.hasPermission(AppPermissions.attendanceFaceManage, AppPermissionScopes.location), isTrue);
      expect(AppPreferences.hasPermission(AppPermissions.kiosksManage, AppPermissionScopes.company), isTrue);
    });

    test('Category 5: Schedules & Duty Rotas (schedules.view, manage, setup)', () async {
      final permissions = <String, dynamic>{
        AppPermissions.schedulesView: ['department'],
        AppPermissions.schedulesManage: ['department'],
        AppPermissions.schedulesSetup: true,
      };
      await AppPreferences.setPermissions(permissions);

      expect(AppPreferences.hasPermission(AppPermissions.schedulesView, AppPermissionScopes.department), isTrue);
      expect(AppPreferences.hasPermission(AppPermissions.schedulesManage, AppPermissionScopes.department), isTrue);
      expect(AppPreferences.hasPermission(AppPermissions.schedulesSetup), isTrue);
    });

    test('Category 6: Requests & Approvals (approvals.manage, approvals.override)', () async {
      final permissions = <String, dynamic>{
        AppPermissions.approvalsManage: ['department'],
        AppPermissions.approvalsOverride: true,
      };
      await AppPreferences.setPermissions(permissions);

      expect(AppPreferences.hasPermission(AppPermissions.approvalsManage, AppPermissionScopes.department), isTrue);
      expect(AppPreferences.hasPermission(AppPermissions.approvalsOverride), isTrue);
    });

    test('Category 7: Leave Management (leave.view, manage, adjust, setup)', () async {
      final permissions = <String, dynamic>{
        AppPermissions.leaveView: ['department'],
        AppPermissions.leaveManage: ['department'],
        AppPermissions.leaveAdjust: ['company'],
        AppPermissions.leaveSetup: true,
      };
      await AppPreferences.setPermissions(permissions);

      expect(AppPreferences.hasPermission(AppPermissions.leaveView, AppPermissionScopes.department), isTrue);
      expect(AppPreferences.hasPermission(AppPermissions.leaveManage, AppPermissionScopes.department), isTrue);
      expect(AppPreferences.hasPermission(AppPermissions.leaveAdjust, AppPermissionScopes.company), isTrue);
      expect(AppPreferences.hasPermission(AppPermissions.leaveSetup), isTrue);
    });

    test('Category 8: Pay & Payroll (pay.view, manage, payroll.run, export, setup)', () async {
      final permissions = <String, dynamic>{
        AppPermissions.payView: ['own'],
        AppPermissions.payManage: ['company'],
        AppPermissions.payrollRun: true,
        AppPermissions.payrollExport: true,
        AppPermissions.payrollSetup: true,
      };
      await AppPreferences.setPermissions(permissions);

      expect(AppPreferences.hasPermission(AppPermissions.payView, AppPermissionScopes.own), isTrue);
      expect(AppPreferences.hasPermission(AppPermissions.payManage, AppPermissionScopes.company), isTrue);
      expect(AppPreferences.hasPermission(AppPermissions.payrollRun), isTrue);
      expect(AppPreferences.hasPermission(AppPermissions.payrollExport), isTrue);
      expect(AppPreferences.hasPermission(AppPermissions.payrollSetup), isTrue);
    });

    test('Category 9: Loans, Advances & Expenses (money.view, manage, setup)', () async {
      final permissions = <String, dynamic>{
        AppPermissions.moneyView: ['own'],
        AppPermissions.moneyManage: ['department'],
        AppPermissions.moneySetup: true,
      };
      await AppPreferences.setPermissions(permissions);

      expect(AppPreferences.hasPermission(AppPermissions.moneyView, AppPermissionScopes.own), isTrue);
      expect(AppPreferences.hasPermission(AppPermissions.moneyManage, AppPermissionScopes.department), isTrue);
      expect(AppPreferences.hasPermission(AppPermissions.moneySetup), isTrue);
    });

    test('Category 10: Performance Reviews (performance.view, manage, setup)', () async {
      final permissions = <String, dynamic>{
        AppPermissions.performanceView: ['own'],
        AppPermissions.performanceManage: ['department'],
        AppPermissions.performanceSetup: true,
      };
      await AppPreferences.setPermissions(permissions);

      expect(AppPreferences.hasPermission(AppPermissions.performanceView, AppPermissionScopes.own), isTrue);
      expect(AppPreferences.hasPermission(AppPermissions.performanceManage, AppPermissionScopes.department), isTrue);
      expect(AppPreferences.hasPermission(AppPermissions.performanceSetup), isTrue);
    });

    test('Category 11: Documents, Letters & News (documents.view, manage, setup, letters.issue, setup, communication.manage)', () async {
      final permissions = <String, dynamic>{
        AppPermissions.documentsView: ['own'],
        AppPermissions.documentsManage: ['department'],
        AppPermissions.documentsSetup: true,
        AppPermissions.lettersIssue: ['department'],
        AppPermissions.lettersSetup: true,
        AppPermissions.communicationManage: ['company'],
      };
      await AppPreferences.setPermissions(permissions);

      expect(AppPreferences.hasPermission(AppPermissions.documentsView, AppPermissionScopes.own), isTrue);
      expect(AppPreferences.hasPermission(AppPermissions.documentsManage, AppPermissionScopes.department), isTrue);
      expect(AppPreferences.hasPermission(AppPermissions.documentsSetup), isTrue);
      expect(AppPreferences.hasPermission(AppPermissions.lettersIssue, AppPermissionScopes.department), isTrue);
      expect(AppPreferences.hasPermission(AppPermissions.lettersSetup), isTrue);
      expect(AppPreferences.hasPermission(AppPermissions.communicationManage, AppPermissionScopes.company), isTrue);
    });

    test('Category 12: Onboarding, Checklists & Tasks (tasks.manage, onboarding.manage, setup, job_descriptions.manage)', () async {
      final permissions = <String, dynamic>{
        AppPermissions.tasksManage: ['department'],
        AppPermissions.onboardingManage: ['department'],
        AppPermissions.onboardingSetup: true,
        AppPermissions.jobDescriptionsManage: ['company'],
      };
      await AppPreferences.setPermissions(permissions);

      expect(AppPreferences.hasPermission(AppPermissions.tasksManage, AppPermissionScopes.department), isTrue);
      expect(AppPreferences.hasPermission(AppPermissions.onboardingManage, AppPermissionScopes.department), isTrue);
      expect(AppPreferences.hasPermission(AppPermissions.onboardingSetup), isTrue);
      expect(AppPreferences.hasPermission(AppPermissions.jobDescriptionsManage, AppPermissionScopes.company), isTrue);
    });

    test('Category 13: Assets & Training (assets.view, manage, training.view, manage)', () async {
      final permissions = <String, dynamic>{
        AppPermissions.assetsView: ['own'],
        AppPermissions.assetsManage: ['department'],
        AppPermissions.trainingView: ['own'],
        AppPermissions.trainingManage: ['department'],
      };
      await AppPreferences.setPermissions(permissions);

      expect(AppPreferences.hasPermission(AppPermissions.assetsView, AppPermissionScopes.own), isTrue);
      expect(AppPreferences.hasPermission(AppPermissions.assetsManage, AppPermissionScopes.department), isTrue);
      expect(AppPreferences.hasPermission(AppPermissions.trainingView, AppPermissionScopes.own), isTrue);
      expect(AppPreferences.hasPermission(AppPermissions.trainingManage, AppPermissionScopes.department), isTrue);
    });

    test('Category 14: HR Helpdesk & Support (helpdesk.handle, setup, support.view, raise)', () async {
      final permissions = <String, dynamic>{
        AppPermissions.helpdeskHandle: ['department'],
        AppPermissions.helpdeskSetup: true,
        AppPermissions.supportView: true,
        AppPermissions.supportRaise: true,
      };
      await AppPreferences.setPermissions(permissions);

      expect(AppPreferences.hasPermission(AppPermissions.helpdeskHandle, AppPermissionScopes.department), isTrue);
      expect(AppPreferences.hasPermission(AppPermissions.helpdeskSetup), isTrue);
      expect(AppPreferences.hasPermission(AppPermissions.supportView), isTrue);
      expect(AppPreferences.hasPermission(AppPermissions.supportRaise), isTrue);
    });

    test('Category 15: Biometric Devices & Reports (devices.manage, reports.view, schedule)', () async {
      final permissions = <String, dynamic>{
        AppPermissions.devicesManage: ['location'],
        AppPermissions.reportsView: ['department'],
        AppPermissions.reportsSchedule: ['company'],
      };
      await AppPreferences.setPermissions(permissions);

      expect(AppPreferences.hasPermission(AppPermissions.devicesManage, AppPermissionScopes.location), isTrue);
      expect(AppPreferences.hasPermission(AppPermissions.reportsView, AppPermissionScopes.department), isTrue);
      expect(AppPreferences.hasPermission(AppPermissions.reportsSchedule, AppPermissionScopes.company), isTrue);
    });
  });

  // =========================================================================
  // GROUP 2: Dropdown Types & Scope Hierarchy Mathematical Rigor
  // =========================================================================
  group('2. Dropdown Types & Scope Hierarchy Evaluation Engine', () {
    test('Type A Binary: Allowed (true, null, string) vs Not Allowed (false, omitted)', () async {
      await AppPreferences.setPermissions({
        'binary.true': true,
        'binary.null': null,
        'binary.string': 'allowed',
        'binary.false': false,
      });

      expect(AppPreferences.hasPermission('binary.true'), isTrue);
      expect(AppPreferences.hasPermission('binary.null'), isTrue);
      expect(AppPreferences.hasPermission('binary.string'), isTrue);
      expect(AppPreferences.hasPermission('binary.false'), isFalse);
      expect(AppPreferences.hasPermission('binary.omitted'), isFalse);
    });

    test('Scope Hierarchy Inheritance: company >= location >= department >= own', () async {
      // User with 'company' scope satisfies ALL scopes
      await AppPreferences.setPermissions({
        'scope.test': ['company'],
      });
      expect(AppPreferences.hasPermission('scope.test', AppPermissionScopes.company), isTrue);
      expect(AppPreferences.hasPermission('scope.test', AppPermissionScopes.location), isTrue);
      expect(AppPreferences.hasPermission('scope.test', AppPermissionScopes.department), isTrue);
      expect(AppPreferences.hasPermission('scope.test', AppPermissionScopes.own), isTrue);

      // User with 'location' scope satisfies location, department, own; but NOT company
      await AppPreferences.setPermissions({
        'scope.test': ['location'],
      });
      expect(AppPreferences.hasPermission('scope.test', AppPermissionScopes.company), isFalse);
      expect(AppPreferences.hasPermission('scope.test', AppPermissionScopes.location), isTrue);
      expect(AppPreferences.hasPermission('scope.test', AppPermissionScopes.department), isTrue);
      expect(AppPreferences.hasPermission('scope.test', AppPermissionScopes.own), isTrue);

      // User with 'department' scope satisfies department, own; but NOT location or company
      await AppPreferences.setPermissions({
        'scope.test': ['department'],
      });
      expect(AppPreferences.hasPermission('scope.test', AppPermissionScopes.company), isFalse);
      expect(AppPreferences.hasPermission('scope.test', AppPermissionScopes.location), isFalse);
      expect(AppPreferences.hasPermission('scope.test', AppPermissionScopes.department), isTrue);
      expect(AppPreferences.hasPermission('scope.test', AppPermissionScopes.own), isTrue);

      // User with 'own' scope satisfies ONLY own
      await AppPreferences.setPermissions({
        'scope.test': ['own'],
      });
      expect(AppPreferences.hasPermission('scope.test', AppPermissionScopes.company), isFalse);
      expect(AppPreferences.hasPermission('scope.test', AppPermissionScopes.location), isFalse);
      expect(AppPreferences.hasPermission('scope.test', AppPermissionScopes.department), isFalse);
      expect(AppPreferences.hasPermission('scope.test', AppPermissionScopes.own), isTrue);
    });

    test('Normalization of "all" scope to "company"', () async {
      await AppPreferences.setPermissions({
        'alias.test': ['all'],
      });
      expect(AppPreferences.hasPermission('alias.test', AppPermissionScopes.company), isTrue);
      expect(AppPreferences.hasPermission('alias.test', AppPermissionScopes.department), isTrue);
      expect(PermissionService.getHighestScope('alias.test'), AppPermissionScopes.company);
    });
  });

  // =========================================================================
  // GROUP 3: View vs Edit vs Delete vs Action-Level Gates
  // =========================================================================
  group('3. View vs Edit vs Delete & Action-Level Authorization Gates', () {
    test('User can view employees (own) but cannot manage or export', () async {
      await AppPreferences.setPermissions({
        AppPermissions.employeesView: ['own'],
      });

      expect(AppPreferences.hasPermission(AppPermissions.employeesView), isTrue);
      expect(AppPreferences.hasPermission(AppPermissions.employeesManage), isFalse);
      expect(AppPreferences.hasPermission(AppPermissions.employeesExport), isFalse);
    });

    test('User can manage employees (department) but cannot export', () async {
      await AppPreferences.setPermissions({
        AppPermissions.employeesView: ['department'],
        AppPermissions.employeesManage: ['department'],
      });

      expect(AppPreferences.hasPermission(AppPermissions.employeesView, AppPermissionScopes.department), isTrue);
      expect(AppPreferences.hasPermission(AppPermissions.employeesManage, AppPermissionScopes.department), isTrue);
      expect(AppPreferences.hasPermission(AppPermissions.employeesExport), isFalse);
    });

    test('User can approve standard requests but cannot override', () async {
      await AppPreferences.setPermissions({
        AppPermissions.approvalsManage: ['department'],
      });

      expect(AppPreferences.hasPermission(AppPermissions.approvalsManage), isTrue);
      expect(AppPreferences.hasPermission(AppPermissions.approvalsOverride), isFalse);
    });

    test('User has module access but cannot perform restricted sub-action', () async {
      // User has access to Documents, but not letter issuing
      await AppPreferences.setPermissions({
        AppPermissions.documentsView: ['company'],
      });

      expect(AppPreferences.hasPermission(AppPermissions.documentsView), isTrue);
      expect(AppPreferences.hasPermission(AppPermissions.lettersIssue), isFalse);
    });

    test('PermissionService.verifyAction returns true on authorized and false on denied', () async {
      await AppPreferences.setPermissions({
        AppPermissions.tasksManage: ['department'],
      });

      // Authorized action
      final allowed = PermissionService.verifyAction(
        AppPermissions.tasksManage,
        requiredScope: AppPermissionScopes.department,
        actionName: 'create task',
      );
      expect(allowed, isTrue);

      // Denied action (insufficient scope)
      final deniedScope = PermissionService.verifyAction(
        AppPermissions.tasksManage,
        requiredScope: AppPermissionScopes.company,
        actionName: 'manage company tasks',
      );
      expect(deniedScope, isFalse);

      // Denied action (missing permission)
      final deniedMissing = PermissionService.verifyAction(
        AppPermissions.companyManage,
        actionName: 'edit company profile',
      );
      expect(deniedMissing, isFalse);
    });
  });

  // =========================================================================
  // GROUP 4: Navigation & Route Guard Authorization
  // =========================================================================
  group('4. Route Guard Authorization & Separate Account Navigation Flows', () {
    test('Unauthenticated user is redirected to Routes.LOGIN', () {
      final guard = AuthGuardMiddleware();
      final redirect = guard.redirect(Routes.INDEX);

      expect(redirect?.name, Routes.LOGIN);
    });

    test('Company account is redirected to Routes.COMPANY_DASHBOARD on root access', () async {
      await AppPreferences.saveAuthData(
        token: 'test_token',
        isCompany: true,
      );

      final guard = AuthGuardMiddleware();
      final redirect = guard.redirect('/');

      expect(redirect?.name, Routes.COMPANY_DASHBOARD);
    });

    test('Employee account is redirected to Routes.INDEX on root access', () async {
      await AppPreferences.saveAuthData(
        token: 'test_token',
        isCompany: false,
      );

      final guard = AuthGuardMiddleware();
      final redirect = guard.redirect('/');

      expect(redirect?.name, Routes.INDEX);
    });

    test('Guarded route denies access when user lacks required permission', () async {
      await AppPreferences.saveAuthData(
        token: 'test_token',
        isCompany: false,
      );
      await AppPreferences.setPermissions({
        AppPermissions.assetsView: ['own'],
      });

      final trainingGuard = AuthGuardMiddleware(requiredPermission: AppPermissions.trainingView);
      final redirect = trainingGuard.redirect(Routes.TRAINING);

      // Since user has no training.view permission, access is denied and redirected to fallback
      expect(redirect?.name, Routes.INDEX);
    });

    test('Guarded route permits access when user has required permission', () async {
      await AppPreferences.saveAuthData(
        token: 'test_token',
        isCompany: false,
      );
      await AppPreferences.setPermissions({
        AppPermissions.trainingView: ['own'],
      });

      final trainingGuard = AuthGuardMiddleware(requiredPermission: AppPermissions.trainingView);
      final redirect = trainingGuard.redirect(Routes.TRAINING);

      // Access is permitted, redirect is null
      expect(redirect, isNull);
    });
  });

  // =========================================================================
  // GROUP 5: Session Lifecycle & Memory Isolation Safety
  // =========================================================================
  group('5. Permission Lifecycle, Memory Safety & Account Switching', () {
    test('clearSession purges in-memory state and notifies SessionMeController', () async {
      final sessionController = Get.put(SessionMeController());

      // Seed preferences and session observables
      await AppPreferences.setPermissions({
        AppPermissions.attendanceView: ['own'],
        AppPermissions.leaveView: ['department'],
      });
      await AppPreferences.setModules(['attendance', 'leave']);

      sessionController.user.value = const MeUser(
        id: '01jb2x9k4m7q8r3t5v6w8y0z1a',
        name: 'John Doe',
        email: 'john@example.com',
        twoFactorEnabled: false,
      );
      sessionController.company.value = const MeCompany(
        id: '01jb2x9k4m7q8r3t5v6w8y0z1b',
        name: 'Acme Corp',
        code: 'ACM123',
      );
      sessionController.modules.assignAll(['attendance', 'leave']);
      sessionController.permissions.assignAll({
        AppPermissions.attendanceView: ['own'],
        AppPermissions.leaveView: ['department'],
      });
      sessionController.menu.assignAll([
        const MeMenuItem(key: 'attendance', label: 'Attendance', icon: 'clock', module: 'attendance'),
        const MeMenuItem(key: 'leave', label: 'Leaves', icon: 'calendar', module: 'leave'),
      ]);

      expect(sessionController.hasModule('attendance'), isTrue);
      expect(sessionController.hasPermission(AppPermissions.leaveView), isTrue);

      // Clear session (simulating logout or 401 token expiry)
      await AppPreferences.clearSession();

      // Verify in-memory observables have been purged
      expect(sessionController.user.value, isNull);
      expect(sessionController.company.value, isNull);
      expect(sessionController.modules, isEmpty);
      expect(sessionController.permissions, isEmpty);
      expect(sessionController.menu, isEmpty);
      expect(sessionController.hasModule('attendance'), isFalse);
      expect(sessionController.hasPermission(AppPermissions.leaveView), isFalse);

      Get.delete<SessionMeController>();
    });

    test('Account switching cleanly overrides permissions with no carry-over', () async {
      // Account 1: HR Manager with company-wide attendance & employee manage
      await AppPreferences.setPermissions({
        AppPermissions.attendanceView: ['company'],
        AppPermissions.employeesManage: ['company'],
      });
      expect(AppPreferences.hasPermission(AppPermissions.employeesManage), isTrue);

      // User logs out and Account 2 logs in: Standard Employee with only own attendance
      await AppPreferences.clearSession();
      await AppPreferences.setPermissions({
        AppPermissions.attendanceView: ['own'],
      });

      expect(AppPreferences.hasPermission(AppPermissions.attendanceView, AppPermissionScopes.own), isTrue);
      expect(AppPreferences.hasPermission(AppPermissions.attendanceView, AppPermissionScopes.company), isFalse);
      expect(AppPreferences.hasPermission(AppPermissions.employeesManage), isFalse);
    });

    test('Undefined or null permission values safely evaluate to false without exception', () {
      expect(AppPreferences.hasPermission('non_existent_key'), isFalse);
      expect(AppPreferences.hasPermission(''), isFalse);
      expect(PermissionService.hasPermission('unknown_perm'), isFalse);
      expect(PermissionService.getHighestScope('unknown_perm'), isNull);
    });
  });
}
