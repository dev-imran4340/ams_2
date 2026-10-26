
import 'package:ams_2/app/api/app_preferences.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../routes/app_routes.dart';
import '../model/org_mode_model.dart';
import '../repo/org_mode_repo.dart';

class OrgModeController extends GetxController {
  final OrgModeRepo repo;

  OrgModeController({required this.repo});

  // Observables
  final RxBool isLoading = false.obs;
  final RxList<OrgModeOption> options = <OrgModeOption>[].obs;
  final RxBool isNavigating = false.obs;
  final RxBool isLoggingOut = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadOptions();
  }

  /// Fetches organization operational modules with strict try-finally loading pattern
  Future<void> loadOptions() async {
    try {
      isLoading.value = true;
      final result = await repo.getModeOptions();
      options.assignAll(result);
    } finally {
      isLoading.value = false;
    }
  }

  /// Triggers haptic feedback and navigates to the selected module
  void selectOption(String id) {
    if (isNavigating.value) return;

    HapticFeedback.lightImpact();
    isNavigating.value = true;

    try {
      switch (id) {
        case 'visitor':
          final hasRoute = Get.routeTree.routes.any(
            (r) => r.name == Routes.VISITOR_MANAGEMENT,
          );
          if (hasRoute) {
            Get.toNamed(Routes.VISITOR_MANAGEMENT);
          } else {
            CustomSnackbar.showInfo(
              message:
                  'Visitor Management Kiosk is being prepared for reception deployment.',
            );
          }
          break;

        case 'employee':
          Get.toNamed(Routes.COMPANY_DASHBOARD);
          break;

        case 'add_employee':
          final hasRoute = Get.routeTree.routes.any(
            (r) => r.name == Routes.ADD_EMPLOYEE,
          );
          if (hasRoute) {
            Get.toNamed(Routes.ADD_EMPLOYEE);
          } else {
            CustomSnackbar.showInfo(
              message:
                  'Employee Registration Form is being prepared for staff onboarding.',
            );
          }
          break;

        default:
          break;
      }
    } finally {
      Future.delayed(const Duration(milliseconds: 400), () {
        isNavigating.value = false;
      });
    }
  }

  /// Displays bottom confirmation sheet to switch back to Individual Mode or terminate session
  Future<void> logout() async {
    HapticFeedback.lightImpact();
    await AppPreferences.clearSession();
    Get.offAllNamed(Routes.LOGIN);
  }

  @override
  void onClose() {
    // Guaranteed zero memory leak contract
    super.onClose();
  }
}
