import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../api/app_preferences.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../dashboard/view/dashboard_view.dart';

import '../../approvals/view/approvals_inbox_view.dart';

import '../../employees/view/employees_view.dart';
import '../../attendance_history/view/attendance_history_view.dart';
import '../../profile/view/profile_view.dart';
import '../model/me_model.dart';
import '../model/nav_tab_model.dart';
import '../repo/index_repo.dart';

class IndexController extends GetxController {
  final IndexRepo repo;

  IndexController({required this.repo});

  // GlobalKey for Scaffold drawer management
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  // Current active navigation tab index
  final RxInt currentIndex = 0.obs;

  // Set of tab indices visited / loaded so far (ensures true lazy initialization)
  final RxSet<int> loadedTabIndexes = <int>{0}.obs;

  // Double back-press timestamp tracking for graceful exit
  DateTime? _lastBackPressTime;

  // Identity & Session Observables (from GET /me)
  final RxBool isLoadingMe = false.obs;
  final Rxn<MeResponseModel> meData = Rxn<MeResponseModel>();
  final RxString userId = ''.obs;
  final RxString userName = ''.obs;
  final RxString userEmail = ''.obs;
  final RxString companyId = ''.obs;
  final RxString companyName = ''.obs;
  final RxString companyCode = ''.obs;
  final RxList<MeMenuItem> dynamicMenu = <MeMenuItem>[].obs;
  final RxMap<String, int> menuBadges = <String, int>{}.obs;

  // Badge notification indicators
  final RxBool hasPendingLeaves = false.obs;
  final RxBool hasUnreadLogs = false.obs;

  // Dynamic Navigation Tabs strictly driven by active company modules & permissions
  final RxList<DynamicNavTab> navTabs = <DynamicNavTab>[].obs;

  // Active Modules strictly from /me response (e.g. core, attendance, devices, leave, etc.)
  final RxList<String> activeModules = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCachedSession();
    fetchMe();
  }

  /// Instantly synchronizes local storage cached state for zero UI latency
  void loadCachedSession() {
    userId.value = AppPreferences.userId ?? '';
    userName.value = AppPreferences.userName ?? '';
    userEmail.value = AppPreferences.userEmail ?? '';
    companyId.value = AppPreferences.companyId ?? '';
    companyName.value = AppPreferences.companyName ?? '';
    companyCode.value = AppPreferences.companyCode ?? '';

    final cachedMe = AppPreferences.meData;
    if (cachedMe != null) {
      try {
        final model = MeResponseModel.fromJson(cachedMe);
        meData.value = model;
        dynamicMenu.assignAll(model.menu);
        menuBadges.assignAll(model.badges);
        activeModules.assignAll(model.modules);
      } catch (_) {}
    } else {
      final cachedMods = AppPreferences.modules;
      if (cachedMods != null) {
        activeModules.assignAll(cachedMods.map((e) => e.toString()).toList());
      } else {
        activeModules.assignAll([
          'core',
          'attendance',
          'devices',
          'leave',
          'payroll',
          'loans_expenses',
          'performance',
          'documents',
          'onboarding',
          'reports',
        ]);
      }
    }

    refreshDynamicTabs();
  }

  /// Strictly builds bottom navigation tabs matching the server's 'menu' array from /me.
  /// Index 0 -> Home / Dashboard View
  /// Index 1 -> Requests / Approvals Inbox View
  /// Index 2 -> Employees Directory View (Filtered by Department Scope)
  void refreshDynamicTabs() {
    final List<DynamicNavTab> tabs = [];

    final menu = dynamicMenu.isNotEmpty
        ? dynamicMenu
        : (AppPreferences.menu != null
            ? (AppPreferences.menu as List)
                .map((e) => MeMenuItem.fromJson(Map<String, dynamic>.from(e as Map)))
                .toList()
            : <MeMenuItem>[]);

    if (menu.isNotEmpty) {
      for (final item in menu) {
        // Module check: if module is specified and not core, verify subscription
        if (item.module.isNotEmpty && item.module != 'core') {
          if (!AppPreferences.hasModule(item.module)) {
            continue;
          }
        }

        if (item.key == 'home') {
          tabs.add(
            DynamicNavTab(
              id: 'home',
              label: item.label,
              icon: Icons.space_dashboard_rounded,
              builder: () => const DashboardView(),
              requiredModule: item.module,
              hasBadge: () => (menuBadges['home'] ?? 0) > 0,
              badgeCount: () => menuBadges['home'] ?? 0,
            ),
          );
        } else if (item.key == 'requests') {
          tabs.add(
            DynamicNavTab(
              id: 'requests',
              label: item.label,
              icon: Icons.inbox_rounded,
              builder: () => const ApprovalsInboxView(),
              requiredModule: item.module,
              hasBadge: () => (menuBadges['requests'] ?? 0) > 0,
              badgeCount: () => menuBadges['requests'] ?? 0,
            ),
          );
        } else if (item.key == 'employees') {
          // Strictly verify employees.view permission before rendering tab
          if (AppPreferences.hasPermission('employees.view')) {
            tabs.add(
              DynamicNavTab(
                id: 'employees',
                label: item.label,
                icon: Icons.badge_outlined,
                builder: () => const DepartmentEmployeesView(),
                requiredModule: item.module,
                requiredPermission: 'employees.view',
                hasBadge: () => (menuBadges['employees'] ?? 0) > 0,
                badgeCount: () => menuBadges['employees'] ?? 0,
              ),
            );
          }
        } else if (item.key == 'attendance') {
          // Strictly verify attendance module and attendance.view permission
          if (AppPreferences.hasModule('attendance') &&
              AppPreferences.hasPermission('attendance.view')) {
            tabs.add(
              DynamicNavTab(
                id: 'attendance',
                label: item.label,
                icon: Icons.calendar_today_rounded,
                builder: () => const AttendanceHistoryView(),
                requiredModule: item.module,
                requiredPermission: 'attendance.view',
                hasBadge: () => (menuBadges['attendance'] ?? 0) > 0,
                badgeCount: () => menuBadges['attendance'] ?? 0,
              ),
            );
          }
        }
      }

      // Tab 4: Profile (Employee Profile, Company Info & Account Settings)
      tabs.add(
        DynamicNavTab(
          id: 'profile',
          label: 'Profile',
          icon: Icons.person_rounded,
          builder: () => const ProfileView(),
          requiredModule: 'core',
          hasBadge: () => (menuBadges['profile'] ?? 0) > 0,
          badgeCount: () => menuBadges['profile'] ?? 0,
        ),
      );
    } else {
      // Direct baseline corresponding to server's menu items + Profile
      tabs.add(
        DynamicNavTab(
          id: 'home',
          label: 'Home',
          icon: Icons.space_dashboard_rounded,
          builder: () => const DashboardView(),
          requiredModule: 'core',
          hasBadge: () => (menuBadges['home'] ?? 0) > 0,
          badgeCount: () => menuBadges['home'] ?? 0,
        ),
      );
      tabs.add(
        DynamicNavTab(
          id: 'requests',
          label: 'Requests',
          icon: Icons.inbox_rounded,
          builder: () => const ApprovalsInboxView(),
          requiredModule: 'core',
          hasBadge: () => (menuBadges['requests'] ?? 0) > 0,
          badgeCount: () => menuBadges['requests'] ?? 0,
        ),
      );

      // Only add employees tab if user has employees.view permission
      if (AppPreferences.hasPermission('employees.view')) {
        tabs.add(
          DynamicNavTab(
            id: 'employees',
            label: 'Employees',
            icon: Icons.badge_outlined,
            builder: () => const DepartmentEmployeesView(),
            requiredModule: 'core',
            requiredPermission: 'employees.view',
            hasBadge: () => (menuBadges['employees'] ?? 0) > 0,
            badgeCount: () => menuBadges['employees'] ?? 0,
          ),
        );
      }

      tabs.add(
        DynamicNavTab(
          id: 'profile',
          label: 'Profile',
          icon: Icons.person_rounded,
          builder: () => const ProfileView(),
          requiredModule: 'core',
          hasBadge: () => (menuBadges['profile'] ?? 0) > 0,
          badgeCount: () => menuBadges['profile'] ?? 0,
        ),
      );
    }

    navTabs.assignAll(tabs);

    // Prevent out-of-range state after dynamic reconfiguration
    if (currentIndex.value >= navTabs.length) {
      currentIndex.value = 0;
    }
  }

  /// Calls live GET /api/v1/me endpoint to hydrate session, company, permissions, and menu
  Future<void> fetchMe() async {
    try {
      isLoadingMe.value = true;
      final result = await repo.fetchMe();
      if (result != null) {
        meData.value = result;
        userId.value = result.user.id;
        userName.value = result.user.name;
        userEmail.value = result.user.email;
        companyId.value = result.company.id;
        companyName.value = result.company.name;
        companyCode.value = result.company.code;
        dynamicMenu.assignAll(result.menu);
        menuBadges.assignAll(result.badges);
        activeModules.assignAll(result.modules);
        Get.log(
          '👤 [/me] Successfully hydrated identity for: ${result.user.name} (${result.company.name})',
        );
        refreshDynamicTabs();
      }
    } finally {
      isLoadingMe.value = false;
    }
  }

  /// Opens the executive navigation drawer from right side (endDrawer)
  void openDrawer() {
    scaffoldKey.currentState?.openEndDrawer();
  }

  /// Closes the executive navigation drawer
  void closeDrawer() {
    scaffoldKey.currentState?.closeEndDrawer();
  }

  /// Changes the current tab with range safety, lazy initialization, and haptic feedback
  void changeTab(int index) {
    if (index < 0 || index >= navTabs.length) return;
    if (!loadedTabIndexes.contains(index)) {
      loadedTabIndexes.add(index);
    }
    if (currentIndex.value != index) {
      HapticFeedback.lightImpact();
      currentIndex.value = index;
    }
  }

  /// Handles Android system back button behavior
  bool handleBackPress() {
    if (currentIndex.value != 0) {
      changeTab(0);
      return false;
    }

    final now = DateTime.now();
    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      CustomSnackbar.showInfo(
        message: 'Press back again to exit application',
      );
      return false;
    }

    return true;
  }

  @override
  void onClose() {
    _lastBackPressTime = null;
    super.onClose();
  }
}
