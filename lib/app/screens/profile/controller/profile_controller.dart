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
  final Rxn<EmployeeProfileModel> profile = Rxn<EmployeeProfileModel>();
  final RxBool biometricPunch = true.obs;
  final RxBool shiftReminders = true.obs;
  final RxBool geofenceAutoCheck = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  /// Loads executive employee profile and preferences
  Future<void> loadProfile() async {
    try {
      isLoading.value = true;
      final result = await repo.fetchProfile();
      if (result != null) {
        profile.value = result;
        biometricPunch.value = result.biometricEnabled;
        shiftReminders.value = result.remindersEnabled;
        geofenceAutoCheck.value = result.geofenceAutoCheck;
      }
    } finally {
      isLoading.value = false;
    }
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

  /// Executes sign out workflow and clears active session
  Future<void> logout() async {
    if (isLoggingOut.value) return;

    try {
      isLoggingOut.value = true;
      HapticFeedback.heavyImpact();

      // Clear session strictly via AppPreferences abstraction
      await AppPreferences.clearSession();

      // Close modal sheet
      if (Get.isBottomSheetOpen == true) {
        Get.back();
      }

      // Navigate to Login screen
      Get.offAllNamed(Routes.LOGIN);

      CustomSnackbar.showSuccess(
        title: 'Signed Out',
        message: 'Your workplace session has been cleared securely.',
      );
    } finally {
      isLoggingOut.value = false;
    }
  }
}
