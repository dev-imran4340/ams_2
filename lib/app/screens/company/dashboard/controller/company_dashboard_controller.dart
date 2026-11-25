import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:ams_2/app/api/app_preferences.dart';
import 'package:ams_2/app/core/widgets/custom_snackbar.dart';
import 'package:ams_2/app/routes/app_routes.dart';
import 'package:ams_2/app/screens/employees/model/department_employee_model.dart';
import 'package:ams_2/app/screens/kiosk/model/kiosk_model.dart';
import '../model/company_dashboard_model.dart';
import '../repo/company_dashboard_repo.dart';

class CompanyDashboardController extends GetxController {
  final CompanyDashboardRepo repo;

  CompanyDashboardController({required this.repo});

  // State Observables
  final RxBool isLoading = false.obs;
  final RxBool isProvisioning = false.obs;
  final Rxn<CompanyDashboardData> dashboardData = Rxn<CompanyDashboardData>();
  final Rxn<KioskConfigModel> activeKiosk = Rxn<KioskConfigModel>();
  final RxList<DepartmentEmployeeModel> employees = <DepartmentEmployeeModel>[].obs;
  final Rx<DateTime> liveClock = DateTime.now().obs;

  final ScrollController scrollController = ScrollController();
  Timer? _clockTimer;

  // Provisioning Form
  final GlobalKey<FormState> provisionFormKey = GlobalKey<FormState>();
  final TextEditingController kioskNameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final FocusNode kioskNameFocusNode = FocusNode();
  final FocusNode locationFocusNode = FocusNode();
  final RxBool replaceExisting = false.obs;

  // Kiosk Work Locations (GET /kiosks/locations)
  final RxList<KioskLocationModel> kioskLocations = <KioskLocationModel>[].obs;
  final Rxn<KioskLocationModel> selectedKioskLocation = Rxn<KioskLocationModel>();
  final RxBool isLoadingLocations = false.obs;
  final RxnString locationsError = RxnString();

  bool get canManageKiosks => AppPreferences.hasPermission('kiosks.manage');
  bool get canViewEmployees => AppPreferences.hasPermission('employees.view');
  bool get isKioskProvisioned => AppPreferences.isKioskProvisioned;

  @override
  void onInit() {
    super.onInit();
    _startLiveClock();
    loadDashboard();
  }

  void _startLiveClock() {
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      liveClock.value = DateTime.now();
    });
  }

  @override
  void onClose() {
    _clockTimer?.cancel();
    kioskNameController.dispose();
    locationController.dispose();
    kioskNameFocusNode.dispose();
    locationFocusNode.dispose();
    scrollController.dispose();
    super.onClose();
  }

  /// Loads company data, hydrates /me, fetches employee directory, and verifies active kiosk status
  Future<void> loadDashboard() async {
    try {
      isLoading.value = true;
      // 1. Refresh /me session
      await repo.fetchMe();

      // 2. Fetch active kiosk config if tablet is provisioned
      if (AppPreferences.isKioskProvisioned) {
        final config = await repo.fetchActiveKioskConfig();
        activeKiosk.value = config;
      } else {
        activeKiosk.value = null;
      }

      // 3. Fetch company employees if permission allows
      if (AppPreferences.hasPermission('employees.view')) {
        final staff = await repo.fetchEmployees();
        employees.assignAll(staff);
      } else {
        employees.clear();
      }

      // 4. Preload kiosk work locations if user can manage kiosks
      if (canManageKiosks) {
        await loadKioskLocations();
      }

      // 5. Update dashboard presentation model
      dashboardData.value = CompanyDashboardData.fromPreferences(
        activeKiosk: activeKiosk.value,
        employeesList: employees,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Loads available work locations from GET /kiosks/locations
  Future<void> loadKioskLocations() async {
    if (!canManageKiosks) return;
    try {
      isLoadingLocations.value = true;
      locationsError.value = null;
      final locs = await repo.fetchKioskLocations();
      kioskLocations.assignAll(locs);

      if (locs.length == 1) {
        selectedKioskLocation.value = locs.first;
      } else if (selectedKioskLocation.value != null &&
          !locs.contains(selectedKioskLocation.value)) {
        selectedKioskLocation.value = null;
      }
    } catch (e) {
      locationsError.value = e.toString();
    } finally {
      isLoadingLocations.value = false;
    }
  }

  /// Provisions this tablet as an enterprise attendance kiosk (POST /kiosks)
  /// Strictly requires kiosks.manage permission
  Future<void> provisionTabletKiosk() async {
    HapticFeedback.lightImpact();

    if (!canManageKiosks) {
      CustomSnackbar.showError(
        title: 'Permission Denied',
        message: 'Your account lacks the "kiosks.manage" permission required to set up kiosk tablets.',
      );
      return;
    }

    if (!provisionFormKey.currentState!.validate()) {
      final FocusNode targetFocus = kioskNameController.text.trim().isEmpty ||
              kioskNameController.text.trim().length < 2 ||
              kioskNameController.text.trim().length > 60
          ? kioskNameFocusNode
          : locationFocusNode;
      if (targetFocus.context != null) {
        Scrollable.ensureVisible(
          targetFocus.context!,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
        );
      }
      targetFocus.requestFocus();
      return;
    }

    final locationId = selectedKioskLocation.value?.id ?? locationController.text.trim();
    if (locationId.isEmpty) {
      if (locationFocusNode.context != null) {
        Scrollable.ensureVisible(
          locationFocusNode.context!,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
        );
      }
      locationFocusNode.requestFocus();
      return;
    }

    try {
      isProvisioning.value = true;
      final config = await repo.provisionKiosk(
        name: kioskNameController.text.trim(),
        location: locationId,
        replace: replaceExisting.value,
      );

      if (config != null) {
        activeKiosk.value = config;
        kioskNameController.clear();
        locationController.clear();
        selectedKioskLocation.value = null;
        CustomSnackbar.showSuccess(
          title: 'Kiosk Provisioned',
          message: 'Tablet successfully provisioned. Logging out setup administrator.',
        );

        // Required API Invariant: log the setup user out immediately
        await repo.logoutSetupUser();

        // Transition the device directly into Kiosk Mode
        Get.offAllNamed(Routes.KIOSK_MAIN);
      }
    } finally {
      isProvisioning.value = false;
    }
  }

  /// De-provisions the active kiosk credentials
  Future<void> deProvisionKiosk() async {
    HapticFeedback.lightImpact();
    if (!canManageKiosks) {
      CustomSnackbar.showError(
        title: 'Permission Denied',
        message: 'Lacks "kiosks.manage" permission to de-provision terminal.',
      );
      return;
    }

    await repo.clearKioskStation();
    activeKiosk.value = null;
    await loadDashboard();
    CustomSnackbar.showWarning(
      title: 'Kiosk De-provisioned',
      message: 'Tablet kiosk secret and configuration have been purged.',
    );
  }

  /// Switches directly to Kiosk Mode (if already provisioned)
  void enterKioskMode() {
    if (!isKioskProvisioned) {
      CustomSnackbar.showWarning(
        title: 'Not Provisioned',
        message: 'Please provision this tablet before entering kiosk mode.',
      );
      return;
    }
    Get.offAllNamed(Routes.KIOSK_MAIN);
  }

  /// Navigates to dedicated Company Staff Directory reusing EmployeesView with company arguments
  void navigateToEmployees() {
    Get.toNamed(
      Routes.EMPLOYEES,
      arguments: {
        'isCompanyMode': true,
        'fromCompany': true,
      },
    );
  }

  /// Opens employee detail / profile flow matching staff directory
  void openEmployeeDetail(DepartmentEmployeeModel employee) {
    HapticFeedback.lightImpact();
    Get.toNamed(
      Routes.PROFILE_DETAILS,
      arguments: {
        'employeeId': employee.id,
        'employeeName': employee.name,
        'employeeCode': employee.employeeCode,
        'department': employee.department,
        'designation': employee.designation,
        'isViewingEmployee': true,
        'isCompanyMode': true,
      },
    );
  }

  /// Navigates to Kiosk Setup Form
  void navigateToKioskSetup() {
    if (!canManageKiosks) {
      CustomSnackbar.showError(
        title: 'Permission Denied',
        message: 'You need "kiosks.manage" permission to access Kiosk Setup.',
      );
      return;
    }
    if (kioskLocations.isEmpty && !isLoadingLocations.value) {
      loadKioskLocations();
    }
    Get.toNamed(Routes.KIOSK_SETUP);
  }

  /// Navigates to Approvals / Requests
  void navigateToRequests() {
    if (AppPreferences.hasPermission('approvals.view')) {
      Get.toNamed(Routes.APPROVALS);
    } else {
      CustomSnackbar.showInfo(
        title: 'Requests',
        message: 'No pending requests requiring action.',
      );
    }
  }

  /// Navigates to Leaves
  void navigateToLeaves() {
    Get.toNamed(Routes.LEAVE);
  }

  /// Navigates to Profile
  void navigateToProfile() {
    Get.toNamed(Routes.PROFILE);
  }

  /// Logs out administrator and returns to Login
  Future<void> logout() async {
    try {
      isLoading.value = true;
      await repo.logoutSetupUser();
      Get.offAllNamed(Routes.LOGIN);
    } finally {
      isLoading.value = false;
    }
  }
}
