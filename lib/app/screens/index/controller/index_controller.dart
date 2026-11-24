import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../api/app_preferences.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../routes/app_routes.dart';
import '../../approvals/view/approvals_inbox_view.dart';
import '../../assets/view/assets_view.dart';
import '../../attendance_history/view/attendance_history_view.dart';
import '../../checklists/view/checklists_view.dart';
import '../../dashboard/controller/dashboard_controller.dart';
import '../../dashboard/view/dashboard_view.dart';
import '../../documents/view/documents_view.dart';
import '../../employees/view/employees_view.dart';
import '../../evaluation/view/evaluation_view.dart';
import '../../loans/view/money_requests_view.dart';
import '../../news/view/news_view.dart';
import '../../payroll/view/payroll_view.dart';
import '../../profile/view/profile_view.dart';
import '../../schedule/view/schedule_view.dart';
import '../../support_tickets/view/support_tickets_view.dart';
import '../../tasks/view/task_view.dart';
import '../../training/view/training_view.dart';
import '../model/me_model.dart';
import '../model/nav_tab_model.dart';
import '../repo/index_repo.dart';

class IndexController extends GetxController with WidgetsBindingObserver {
  final IndexRepo repo;

  IndexController({required this.repo});

  // GlobalKey for Scaffold drawer management (dynamic registration eliminates duplicate key collisions)
  GlobalKey<ScaffoldState>? _activeScaffoldKey;
  final GlobalKey<ScaffoldState> _fallbackScaffoldKey = GlobalKey<ScaffoldState>();

  GlobalKey<ScaffoldState> get scaffoldKey => _activeScaffoldKey ?? _fallbackScaffoldKey;

  void registerScaffoldKey(GlobalKey<ScaffoldState> key) {
    _activeScaffoldKey = key;
  }

  void unregisterScaffoldKey(GlobalKey<ScaffoldState> key) {
    if (_activeScaffoldKey == key) {
      _activeScaffoldKey = null;
    }
  }

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

  // Freshness & Offline Session Observables
  final RxBool isPermissionsFresh = false.obs;
  final RxBool isOfflineMode = false.obs;
  final RxnString sessionErrorMessage = RxnString();

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
    WidgetsBinding.instance.addObserver(this);
    loadCachedSession();
    fetchMe();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Get.log('📱 [IndexController] App returned to foreground: refreshing /me');
      fetchMe();
    }
  }

  /// Instantly synchronizes local storage cached state for zero UI latency
  void loadCachedSession() {
    isPermissionsFresh.value = false;
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
        // Zero dummy fallback policy: no artificial modules injected
        activeModules.clear();
      }
    }

    refreshDynamicTabs();
  }

  IconData _resolveIcon(String key) {
    switch (key) {
      case 'home':
        return Icons.space_dashboard_rounded;
      case 'requests':
        return Icons.inbox_rounded;
      case 'employees':
        return Icons.badge_outlined;
      case 'attendance':
        return Icons.calendar_today_rounded;
      case 'schedule':
        return Icons.access_time_rounded;
      case 'payroll':
      case 'payslips':
        return Icons.payments_outlined;
      case 'money':
        return Icons.account_balance_wallet_outlined;
      case 'support':
      case 'helpdesk':
        return Icons.support_agent_rounded;
      case 'tasks':
        return Icons.task_alt_rounded;
      case 'onboarding':
      case 'checklists':
        return Icons.checklist_rounded;
      case 'assets':
        return Icons.inventory_2_outlined;
      case 'training':
        return Icons.school_outlined;
      case 'documents':
        return Icons.description_outlined;
      case 'news':
        return Icons.newspaper_rounded;
      case 'performance':
        return Icons.rate_review_outlined;
      case 'profile':
        return Icons.person_rounded;
      case 'organisation':
      case 'company':
      case 'users':
      case 'roles':
        return Icons.business_rounded;
      default:
        return Icons.widgets_outlined;
    }
  }

  Widget _resolveView(String key, String label) {
    switch (key) {
      case 'home':
        return const DashboardView();
      case 'requests':
        return const ApprovalsInboxView();
      case 'employees':
        return const DepartmentEmployeesView();
      case 'attendance':
        return const AttendanceHistoryView();
      case 'schedule':
        return const ScheduleView();
      case 'payroll':
      case 'payslips':
        return const PayrollView();
      case 'money':
        return const MoneyRequestsView();
      case 'support':
      case 'helpdesk':
        return const SupportTicketsView();
      case 'tasks':
        return const TaskView();
      case 'onboarding':
      case 'checklists':
        return const ChecklistsView();
      case 'assets':
        return const AssetsView();
      case 'training':
        return TrainingView();
      case 'documents':
        return const DocumentsView();
      case 'news':
        return const NewsView();
      case 'performance':
        return const EvaluationView();
      case 'profile':
        return const ProfileView();
      case 'organisation':
      case 'company':
      case 'users':
      case 'roles':
      default:
        return Scaffold(
          appBar: AppBar(title: Text(label)),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                '$label is accessible through the AMS 2 web portal.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        );
    }
  }

  /// Priority ranking for bottom navigation bar items.
  /// When server's 'menu' provides more than 4 eligible options,
  /// this ranking selects the best 4 options while preserving the server's relative order.
  static const List<String> _preferredBottomNavOrder = [
    'home',         // 1. Dashboard & overview
    'attendance',   // 2. Daily attendance & punch logs
    'requests',     // 3. Approvals & requests inbox
    'profile',      // 4. Employee profile (Preferred 4th tab at last index)
    'schedule',     // 5. Work schedule & rota
    'employees',    // 6. Employees / department directory
    'payroll',      // 7. Payslips & salary
    'payslips',     // 8. Payslips alternative key
    'money',        // 9. Loans & advances
    'tasks',        // 10. Daily tasks & checklists
    'documents',    // 11. Documents & letters
    'performance',  // 12. Evaluation reviews
    'checklists',   // 13. Onboarding checklists
    'training',     // 14. Training & courses
    'assets',       // 15. Hardware assets
    'news',         // 16. Company announcements
    'support',      // 17. Help & support tickets
    'helpdesk',     // 18. Service desk
  ];

  /// Strictly builds navigation tabs matching the server's 'menu' array from GET /me.
  /// Dynamically selects the best 4 options from the menu list to keep the bottom nav bar sleek & usable,
  /// while preserving exact relative server order. All other modules remain accessible via AppDrawer.
  void refreshDynamicTabs() {
    final menu = dynamicMenu.isNotEmpty
        ? dynamicMenu
        : (AppPreferences.menu != null
            ? (AppPreferences.menu as List)
                .map((e) => MeMenuItem.fromJson(Map<String, dynamic>.from(e as Map)))
                .toList()
            : <MeMenuItem>[]);

    if (menu.isEmpty) {
      navTabs.clear();
      currentIndex.value = 0;
      return;
    }

    // 1. Filter eligible menu items based on module subscription and permissions
    final List<MeMenuItem> eligibleItems = [];
    for (final item in menu) {
      // Module subscription check
      if (item.module.isNotEmpty && item.module != 'core') {
        if (!AppPreferences.hasModule(item.module)) {
          continue;
        }
      }

      // Permission and mode checks for specific modules
      if (item.key == 'employees') {
        if (!AppPreferences.hasPermission('employees.view')) continue;
      } else if (item.key == 'attendance') {
        // Hide personal punch tab for company/admin mode
        if (AppPreferences.isCompanyMode) continue;
        if (!AppPreferences.hasPermission('attendance.view')) continue;
      } else if (item.key == 'schedule') {
        if (!AppPreferences.hasPermission('schedules.view') &&
            !AppPreferences.hasPermission('attendance.view')) {
          continue;
        }
      } else if (item.key == 'payroll' || item.key == 'payslips') {
        if (!AppPreferences.hasPermission('pay.view')) continue;
      } else if (item.key == 'money') {
        if (!AppPreferences.hasPermission('money.view')) continue;
      } else if (item.key == 'documents') {
        if (!AppPreferences.hasPermission('documents.view')) continue;
      } else if (item.key == 'performance') {
        if (!AppPreferences.hasPermission('performance.view')) continue;
      } else if (item.key == 'support') {
        if (!AppPreferences.hasPermission('support.view')) continue;
      }

      eligibleItems.add(item);
    }

    // 2. Always ensure Profile is included for every employee as the core 4th tab
    if (!eligibleItems.any((item) => item.key == 'profile')) {
      eligibleItems.add(
        const MeMenuItem(
          key: 'profile',
          label: 'Profile',
          icon: 'person',
          module: 'core',
        ),
      );
    }

    // 3. Select the best 4 options ranked by enterprise priority
    final List<MeMenuItem> ranked = List<MeMenuItem>.from(eligibleItems);
    ranked.sort((a, b) {
      final rankA = _preferredBottomNavOrder.indexOf(a.key);
      final rankB = _preferredBottomNavOrder.indexOf(b.key);
      final scoreA = rankA != -1 ? rankA : 999;
      final scoreB = rankB != -1 ? rankB : 999;
      return scoreA.compareTo(scoreB);
    });

    final List<MeMenuItem> selectedItems = ranked.take(4).toList();

    // 4. Strict standard layout order:
    // Tab 1 (Index 0): home (Dashboard)
    // Tab 2 (Index 1): attendance (Punch logs & timesheets)
    // Tab 3 (Index 2): requests (Approvals & requests inbox)
    // Tab 4 (Index 3): profile (Employee Profile)
    selectedItems.sort((a, b) {
      final rankA = _preferredBottomNavOrder.indexOf(a.key);
      final rankB = _preferredBottomNavOrder.indexOf(b.key);
      final scoreA = rankA != -1 ? rankA : 999;
      final scoreB = rankB != -1 ? rankB : 999;
      return scoreA.compareTo(scoreB);
    });

    // 3. Construct DynamicNavTab instances for the selected items
    final List<DynamicNavTab> tabs = selectedItems.map((item) {
      return DynamicNavTab(
        id: item.key,
        label: item.label,
        icon: _resolveIcon(item.key),
        builder: () => _resolveView(item.key, item.label),
        requiredModule: item.module,
        hasBadge: () => (menuBadges[item.key] ?? 0) > 0,
        badgeCount: () => menuBadges[item.key] ?? 0,
      );
    }).toList();

    navTabs.assignAll(tabs);

    if (tabs.isEmpty) {
      currentIndex.value = 0;
    } else if (currentIndex.value >= tabs.length) {
      currentIndex.value = 0;
    }
  }

  /// Calls live GET /api/v1/me endpoint to hydrate session, company, permissions, and menu.
  /// Deduplicates concurrent calls to eliminate redundant HTTP round-trips.
  Future<void> fetchMe() async {
    if (isLoadingMe.value) return;

    try {
      isLoadingMe.value = true;
      sessionErrorMessage.value = null;
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
        isPermissionsFresh.value = true;
        isOfflineMode.value = false;

        Get.log(
          '👤 [/me] Successfully hydrated fresh identity for: ${result.user.name} (${result.company.name})',
        );
        refreshDynamicTabs();

        // Ensure Dashboard telemetry loads after fresh identity/permissions hydration
        if (Get.isRegistered<DashboardController>()) {
          final dashboardCtrl = Get.find<DashboardController>();
          if (dashboardCtrl.dashboardData.value == null && !dashboardCtrl.isLoading.value) {
            dashboardCtrl.loadDashboard();
          }
        }
      } else {
        // fetchMe returned null (unauthenticated, network outage, or account suspended)
        if (!AppPreferences.isLoggedIn || AppPreferences.token == null) {
          isPermissionsFresh.value = false;
          Get.offAllNamed(Routes.LOGIN);
          return;
        }
        isPermissionsFresh.value = false;
        isOfflineMode.value = true;
        sessionErrorMessage.value = 'Offline: Showing cached workplace profile';
      }
    } catch (e) {
      isPermissionsFresh.value = false;
      isOfflineMode.value = true;
      sessionErrorMessage.value = 'Offline: Unable to refresh identity session';
    } finally {
      isLoadingMe.value = false;
    }
  }

  /// Opens the executive navigation drawer from right side (endDrawer)
  void openDrawer([BuildContext? context]) {
    if (context != null) {
      Scaffold.maybeOf(context)?.openEndDrawer();
      return;
    }
    scaffoldKey.currentState?.openEndDrawer();
  }

  /// Closes the executive navigation drawer
  void closeDrawer([BuildContext? context]) {
    if (context != null) {
      Scaffold.maybeOf(context)?.closeEndDrawer();
      return;
    }
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

  /// Safely activates a navigation tab by its key identifier (e.g. 'home', 'requests', 'attendance').
  /// Returns true if the tab was found and activated in the dynamic bottom navigation bar.
  bool openTabByKey(String key) {
    final idx = navTabs.indexWhere((t) => t.id == key);
    if (idx != -1) {
      changeTab(idx);
      return true;
    }
    return false;
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
    WidgetsBinding.instance.removeObserver(this);
    _lastBackPressTime = null;
    super.onClose();
  }
}
