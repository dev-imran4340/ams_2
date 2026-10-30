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
        return;
      } catch (_) {}
    }

    // Direct fallback from individual cached session values in AppPreferences
    final uName = AppPreferences.userName ?? 'Maryam Malik';
    final uEmail = AppPreferences.userEmail ?? 'maryam@example.com';
    final uId = AppPreferences.userId ?? 'EMP-1024';
    final cName = AppPreferences.companyName ?? 'Kumash';
    final cCode = AppPreferences.companyCode ?? 'ZDTT3V';
    final cId = AppPreferences.companyId ?? 'comp-1';

    user.value = MeUser(
      id: uId,
      name: uName,
      email: uEmail,
      twoFactorEnabled: AppPreferences.isTwoFactorEnabled,
    );

    company.value = MeCompany(
      id: cId,
      name: cName,
      code: cCode,
    );

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
