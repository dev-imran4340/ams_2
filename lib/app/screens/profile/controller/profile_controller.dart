import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../api/app_preferences.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../routes/app_routes.dart';
import '../model/profile_model.dart';
import '../repo/profile_repo.dart';
import '../view/components/logout_confirm_sheet.dart';

class ProfileController extends GetxController {
  final ProfileRepo repo;

  ProfileController({required this.repo});

  // Observables
  final RxBool isLoading = false.obs;
  final RxBool isLoggingOut = false.obs;

  // Active displayed profile (viewed by ProfileDetailsView and components)
  final Rxn<EmployeeProfileModel> profile = Rxn<EmployeeProfileModel>();

  // Authenticated user's own profile (strictly isolated and preserved)
  final Rxn<EmployeeProfileModel> selfProfile = Rxn<EmployeeProfileModel>();

  // Currently inspected employee profile (strictly isolated when viewing from card)
  final Rxn<EmployeeProfileModel> otherEmployeeProfile = Rxn<EmployeeProfileModel>();

  // State to track if currently viewing an employee profile vs self profile
  final RxBool isViewingOtherEmployee = false.obs;
  final RxnString activeEmployeeId = RxnString();

  // Active section tab key strictly driven by server's 'sections' list
  final RxString selectedSectionKey = 'overview'.obs;

  // Workplace Preferences & Security Observables
  final RxBool twoFactorAuth = true.obs;
  final RxBool biometricPunch = true.obs;
  final RxBool shiftReminders = true.obs;
  final RxBool geofenceAutoCheck = true.obs;

  // Horizontal Section Tabs ScrollController & Worker
  final ScrollController tabsScrollController = ScrollController();
  Worker? sectionTabsWorker;

  @override
  void onInit() {
    super.onInit();
    // Default: proactively fetch self profile
    loadProfile();

    sectionTabsWorker = ever(selectedSectionKey, (String key) {
      scrollToSection(key);
    });
  }

  /// Entry point called by ProfileDetailsView whenever the screen is displayed or updated.
  /// Applies a strict identity check to cleanly distinguish between Self Profile vs Another Employee Profile.
  Future<void> handleViewEntry(dynamic args) async {
    String? targetEmpId;
    String? targetEmpName;
    String? targetEmpCode;
    String? targetEmpDept;
    String? targetEmpDesig;
    bool explicitOtherFlag = false;

    if (args is Map) {
      if (args['employeeId'] != null) {
        targetEmpId = args['employeeId'].toString();
      }
      if (args['employeeName'] != null) {
        targetEmpName = args['employeeName'].toString();
      }
      if (args['employeeCode'] != null) {
        targetEmpCode = args['employeeCode'].toString();
      }
      if (args['department'] != null) {
        targetEmpDept = args['department'].toString();
      }
      if (args['designation'] != null) {
        targetEmpDesig = args['designation'].toString();
      }
      if (args['isViewingEmployee'] == true) {
        explicitOtherFlag = true;
      }
    } else if (args is String && args.isNotEmpty) {
      targetEmpId = args;
    }

    final String? loggedInUserId = AppPreferences.userId;
    final String? loggedInEmpCode = AppPreferences.employeeNumber;
    final String? selfEmpId = selfProfile.value?.id ?? AppPreferences.selfEmployeeId;
    final String? selfEmpNum = selfProfile.value?.employeeNumber ?? AppPreferences.selfEmployeeNumber;

    // Strict Invariant Check:
    // It is another employee if and only if targetEmpId is provided, non-empty,
    // and does NOT match the logged-in user's user ID or employee code.
    final bool isOther = targetEmpId != null &&
        targetEmpId.trim().isNotEmpty &&
        targetEmpId != loggedInUserId &&
        targetEmpId != selfEmpId &&
        targetEmpId != loggedInEmpCode &&
        targetEmpId != selfEmpNum;

    if (isOther || (explicitOtherFlag && targetEmpId != null && targetEmpId.isNotEmpty)) {
      // ➡️ Case B: Viewing Another Employee's Profile
      isViewingOtherEmployee.value = true;
      activeEmployeeId.value = targetEmpId;

      await loadEmployeeProfile(
        targetEmpId,
        nameHint: targetEmpName,
        codeHint: targetEmpCode,
        deptHint: targetEmpDept,
        desigHint: targetEmpDesig,
      );
    } else {
      // ➡️ Case A: Viewing Self Profile
      isViewingOtherEmployee.value = false;
      activeEmployeeId.value = null;
      otherEmployeeProfile.value = null;

      if (selfProfile.value != null) {
        profile.value = selfProfile.value;
        _ensureValidSectionTab(selfProfile.value!);
      }
      await loadProfile();
    }
  }

  /// Exit handler called when ProfileDetailsView route is popped / closed.
  /// Guarantees that the other employee state is flushed and self profile is safely restored.
  void handleViewExit() {
    if (isClosed) return;
    isViewingOtherEmployee.value = false;
    activeEmployeeId.value = null;
    otherEmployeeProfile.value = null;

    if (selfProfile.value != null) {
      profile.value = selfProfile.value;
      _ensureValidSectionTab(selfProfile.value!);
    }
  }

  /// Loads authenticated employee profile via GET /me/profile
  Future<void> loadProfile() async {
    try {
      isLoading.value = true;
      final result = await repo.fetchProfile();
      if (result != null) {
        selfProfile.value = result;
        // Only set active profile if we are NOT currently inspecting another employee
        if (!isViewingOtherEmployee.value) {
          profile.value = result;
          _ensureValidSectionTab(result);
        }
        biometricPunch.value = result.biometricEnabled;
        shiftReminders.value = result.remindersEnabled;
        geofenceAutoCheck.value = result.geofenceAutoCheck;
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Loads target employee profile by ID via GET /api/v1/employees/{id}
  Future<void> loadEmployeeProfile(
    String empId, {
    String? nameHint,
    String? codeHint,
    String? deptHint,
    String? desigHint,
  }) async {
    try {
      isLoading.value = true;
      activeEmployeeId.value = empId;
      isViewingOtherEmployee.value = true;

      final result = await repo.fetchEmployeeProfile(
        empId,
        nameHint: nameHint,
        codeHint: codeHint,
        deptHint: deptHint,
        desigHint: desigHint,
      );

      if (result != null) {
        otherEmployeeProfile.value = result;
        profile.value = result;
        _ensureValidSectionTab(result);
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Ensures currently selected section key exists in the active profile's server-driven sections
  void _ensureValidSectionTab(EmployeeProfileModel p) {
    if (p.sections.isNotEmpty &&
        !p.sections.any((s) => s.key == selectedSectionKey.value)) {
      selectedSectionKey.value = p.sections.first.key;
    }
  }

  /// Restores authenticated user's self profile seamlessly
  void restoreSelfProfile() {
    handleViewExit();
  }

  /// Refreshes current active profile (either self or selected employee)
  Future<void> refreshActiveProfile() async {
    if (isViewingOtherEmployee.value && activeEmployeeId.value != null) {
      await loadEmployeeProfile(activeEmployeeId.value!);
    } else {
      await loadProfile();
    }
  }

  /// Selects an active section tab with light haptic feedback
  void selectSection(String key) {
    if (selectedSectionKey.value == key) return;
    HapticFeedback.selectionClick();
    selectedSectionKey.value = key;
  }

  /// List of active sections available on current profile
  List<ProfileSectionModel> get activeSections {
    final p = profile.value;
    if (p?.sections != null && p!.sections.isNotEmpty) {
      return p.sections;
    }
    return EmployeeProfileModel.defaultSections;
  }

  /// Selects next section tab in order (for swipe gesture)
  void selectNextSection() {
    final sections = activeSections;
    if (sections.isEmpty) return;
    final currentIndex =
        sections.indexWhere((s) => s.key == selectedSectionKey.value);
    if (currentIndex >= 0 && currentIndex < sections.length - 1) {
      selectSection(sections[currentIndex + 1].key);
    }
  }

  /// Selects previous section tab in order (for swipe gesture)
  void selectPreviousSection() {
    final sections = activeSections;
    if (sections.isEmpty) return;
    final currentIndex =
        sections.indexWhere((s) => s.key == selectedSectionKey.value);
    if (currentIndex > 0) {
      selectSection(sections[currentIndex - 1].key);
    }
  }

  /// Automatically scrolls the tabs bar to center the active section tab
  void scrollToSection(String key) {
    if (!tabsScrollController.hasClients) return;
    final sections = activeSections;
    final index = sections.indexWhere((s) => s.key == key);
    if (index < 0) return;

    // Approximate tab width + spacing: 105.w per tab + 8.w spacing
    const tabWidth = 105.0;
    final screenWidth = Get.width > 0 ? Get.width : 375.0;
    final targetOffset =
        (index * (tabWidth + 8.0)) - (screenWidth / 2) + (tabWidth / 2);
    final clampedOffset = targetOffset.clamp(
      0.0,
      tabsScrollController.position.maxScrollExtent,
    );

    tabsScrollController.animateTo(
      clampedOffset,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOutCubic,
    );
  }

  /// Updates reactive profile instantly in-memory
  void updateProfileLocally(EmployeeProfileModel updated) {
    profile.value = updated;
    biometricPunch.value = updated.biometricEnabled;
    shiftReminders.value = updated.remindersEnabled;
    geofenceAutoCheck.value = updated.geofenceAutoCheck;
  }

  /// Navigates to Edit Profile Screen and refreshes upon return
  Future<void> navigateToEditProfile() async {
    HapticFeedback.lightImpact();
    final result = await Get.toNamed(
      Routes.EDIT_PROFILE,
      arguments: profile.value,
    );
    if (result == true) {
      await loadProfile();
    }
  }

  /// Navigates to Detailed Employee Profile Screen with all server-driven tabs
  void navigateToProfileDetails() {
    HapticFeedback.lightImpact();
    Get.toNamed(Routes.PROFILE_DETAILS);
  }

  /// Navigates to Employee ID Card view
  void navigateToCard() {
    HapticFeedback.lightImpact();
    Get.toNamed(Routes.EMPLOYEE_CARD);
  }

  /// Toggles Two-Factor Authentication (2FA)
  void toggle2FA(bool val) {
    HapticFeedback.selectionClick();
    twoFactorAuth.value = val;
    CustomSnackbar.showSuccess(
      title: 'Two-Factor Authentication',
      message: val
          ? '2FA security is now enabled for your account.'
          : '2FA security has been disabled.',
    );
  }

  /// Toggles biometric quick authentication
  void toggleBiometric(bool val) {
    HapticFeedback.selectionClick();
    biometricPunch.value = val;
    repo.updatePreferences(biometric: val);
    CustomSnackbar.showSuccess(
      title: 'Biometric Preference',
      message: val
          ? 'Biometric touch/face punch enabled.'
          : 'Biometric quick punch disabled.',
    );
  }

  /// Toggles shift start/end alerts
  void toggleReminders(bool val) {
    HapticFeedback.selectionClick();
    shiftReminders.value = val;
    repo.updatePreferences(reminders: val);
    CustomSnackbar.showSuccess(
      title: 'Shift Reminders',
      message: val
          ? 'Daily shift notifications active.'
          : 'Shift reminders muted.',
    );
  }

  /// Toggles geofence presence validation
  void toggleGeofence(bool val) {
    HapticFeedback.selectionClick();
    geofenceAutoCheck.value = val;
    repo.updatePreferences(geofence: val);
  }

  /// Opens the modern confirmation bottom sheet before sign out
  void showLogoutConfirmation(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.primary.withValues(alpha: 0.6),
      builder: (ctx) => const LogoutConfirmSheet(),
    );
  }

  /// Executes sign out workflow: dispatches POST /auth/logout API,
  /// clears local storage, closes all routes and navigates to Login.
  Future<void> logout() async {
    if (isLoggingOut.value) return;

    try {
      isLoggingOut.value = true;
      HapticFeedback.heavyImpact();

      // 1. Dispatch official POST /auth/logout API call
      await repo.logout();

      // 2. Clear local storage session
      await AppPreferences.clearSession();

      // 3. Close modal bottom sheet if open
      if (Get.isBottomSheetOpen == true) {
        Get.back();
      }

      // 4. Close all routes and navigate directly to Login screen
      Get.offAllNamed(Routes.LOGIN);

      CustomSnackbar.showSuccess(
        title: 'Signed Out',
        message: 'Your workplace session has been cleared securely.',
      );
    } catch (_) {
      // Guaranteed fallback: clear storage and navigate to Login
      await AppPreferences.clearSession();
      if (Get.isBottomSheetOpen == true) {
        Get.back();
      }
      Get.offAllNamed(Routes.LOGIN);
    } finally {
      isLoggingOut.value = false;
    }
  }

  @override
  void onClose() {
    sectionTabsWorker?.dispose();
    tabsScrollController.dispose();
    super.onClose();
  }
}
