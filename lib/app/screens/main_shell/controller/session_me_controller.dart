import 'dart:async';
import 'package:get/get.dart';

import '../../../api/app_preferences.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../routes/app_routes.dart';
import '../../index/model/me_model.dart';
import '../../index/repo/index_repo.dart';
import '../../dashboard/controller/dashboard_controller.dart';

class SessionMeController extends GetxController {
  final IndexRepo? repo;

  SessionMeController({this.repo});

  // Identity & Session Observables strictly populated from GET /me
  final Rxn<MeUser> user = Rxn<MeUser>();
  final Rxn<MeCompany> company = Rxn<MeCompany>();
  final RxList<String> modules = <String>[].obs;
  final RxMap<String, dynamic> permissions = <String, dynamic>{}.obs;
  final RxList<MeMenuItem> menu = <MeMenuItem>[].obs;
  final RxMap<String, int> badges = <String, int>{}.obs;

  final RxBool isLoading = false.obs;
  final RxBool isLoggingOut = false.obs;

  @override
  void onInit() {
    super.onInit();
    hydrateFromPreferences();
    refreshSession();
  }

  /// Hydrates session observables instantly from local persistent storage
  void hydrateFromPreferences() {
    final cachedMe = AppPreferences.meData;
    if (cachedMe != null) {
      try {
        final model = MeResponseModel.fromJson(cachedMe);
        user.value = model.user;
        company.value = model.company;
        modules.assignAll(model.modules);
        permissions.assignAll(model.permissions);
        menu.assignAll(model.menu);
        badges.assignAll(model.badges);
        return;
      } catch (_) {}
    }

    // Direct fallback from individual cached session values in AppPreferences
    final uName = AppPreferences.userName ?? '';
    final uEmail = AppPreferences.userEmail ?? '';
    final uId = AppPreferences.userId ?? '';
    final cName = AppPreferences.companyName ?? '';
    final cCode = AppPreferences.companyCode ?? '';
    final cId = AppPreferences.companyId ?? '';

    if (uName.isNotEmpty || uId.isNotEmpty) {
      user.value = MeUser(
        id: uId,
        name: uName,
        email: uEmail,
        twoFactorEnabled: AppPreferences.isTwoFactorEnabled,
      );
    }

    if (cName.isNotEmpty || cCode.isNotEmpty || cId.isNotEmpty) {
      company.value = MeCompany(
        id: cId,
        name: cName,
        code: cCode,
      );
    }

    final cachedMods = AppPreferences.modules;
    if (cachedMods != null && cachedMods.isNotEmpty) {
      modules.assignAll(cachedMods.map((e) => e.toString()).toList());
    } else {
      // Default authorized modules baseline from server contract
      modules.assignAll([
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

    final cachedPerms = AppPreferences.permissions;
    if (cachedPerms != null) {
      permissions.assignAll(Map<String, dynamic>.from(cachedPerms));
    }

    final cachedMenu = AppPreferences.menu;
    if (cachedMenu != null && cachedMenu.isNotEmpty) {
      menu.assignAll(
        cachedMenu
            .whereType<Map>()
            .map((e) => MeMenuItem.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
    }

    final cachedBadges = AppPreferences.badges;
    if (cachedBadges != null) {
      badges.assignAll(
        cachedBadges.map((k, v) => MapEntry(k, int.tryParse(v.toString()) ?? 0)),
      );
    }
  }

  /// Refreshes live identity, modules and permissions from server GET /api/v1/me
  Future<void> refreshSession() async {
    try {
      isLoading.value = true;
      final activeRepo = repo ?? (Get.isRegistered<IndexRepo>() ? Get.find<IndexRepo>() : IndexRepo());
      final result = await activeRepo.fetchMe();
      if (result != null) {
        user.value = result.user;
        company.value = result.company;
        modules.assignAll(result.modules);
        permissions.assignAll(result.permissions);
        menu.assignAll(result.menu);
        badges.assignAll(result.badges);

        // Ensure Dashboard telemetry loads if not already loaded
        if (Get.isRegistered<DashboardController>()) {
          final dashboardCtrl = Get.find<DashboardController>();
          if (dashboardCtrl.dashboardData.value == null && !dashboardCtrl.isLoading.value) {
            dashboardCtrl.loadDashboard();
          }
        }
      }
    } catch (_) {
      // Silently fall back to cached session data on network interruption
    } finally {
      isLoading.value = false;
    }
  }

  /// Verifies if a paid company module is enabled in active subscription
  bool hasModule(String moduleKey) {
    if (moduleKey == 'core') return true;
    if (modules.contains(moduleKey)) return true;
    return AppPreferences.hasModule(moduleKey);
  }

  /// Verifies if employee possesses a specific permission and optional scope
  bool hasPermission(String permKey, [String? scope]) {
    return AppPreferences.hasPermission(permKey, scope);
  }

  /// Checks whether a menu key is enabled in server's dynamic menu.
  /// If menu is empty (offline or legacy), returns true so safe fallback applies.
  bool hasMenuItem(String key) {
    if (menu.isEmpty) return true;
    return menu.any((item) => item.key == key);
  }

  /// Returns badge count for a module/menu key (e.g. documents: 2, tasks: 5)
  int getBadge(String key) => badges[key] ?? 0;

  /// Performs secure session termination: dispatches POST /auth/logout API,
  /// purges local storage, dismisses dialogs, closes all routes, and redirects to Login.
  Future<void> logout() async {
    if (isLoggingOut.value) return;

    try {
      isLoggingOut.value = true;
      final activeRepo = repo ??
          (Get.isRegistered<IndexRepo>() ? Get.find<IndexRepo>() : IndexRepo());

      // 1. Dispatch POST /auth/logout API call
      await activeRepo.logout();

      // 2. Clear local storage session
      await AppPreferences.clearSession();

      // 3. Dismiss any active dialogs/sheets
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      if (Get.isBottomSheetOpen == true) {
        Get.back();
      }

      // 4. Close all routes and navigate to Login
      Get.offAllNamed(Routes.LOGIN);

      CustomSnackbar.showSuccess(
        title: 'Signed Out',
        message: 'Your workplace session has been cleared securely.',
      );
    } catch (_) {
      // Guaranteed fallback: clear storage and route to login
      await AppPreferences.clearSession();
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      Get.offAllNamed(Routes.LOGIN);
    } finally {
      isLoggingOut.value = false;
    }
  }
}
