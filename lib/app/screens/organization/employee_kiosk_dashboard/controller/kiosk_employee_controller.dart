import 'dart:async';

import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../routes/app_routes.dart';
import '../model/kiosk_employee_model.dart';
import '../repo/kiosk_employee_repo.dart';

class KioskEmployeeController extends GetxController {
  final KioskEmployeeRepo repo;
  KioskEmployeeController({required this.repo});

  // Observables
  final RxBool isLoading = false.obs;
  final RxBool isPunching = false.obs;
  final Rxn<KioskEmployeeProfileModel> profile =
      Rxn<KioskEmployeeProfileModel>();

  // 1-Minute Security Auto-Logout Timer Observables
  static const int totalIdleDurationSeconds = 60;
  final RxInt remainingSeconds = totalIdleDurationSeconds.obs;
  Timer? _countdownTimer;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
    startIdleCountdown();
  }

  /// Loads employee kiosk profile with try-finally guard
  Future<void> loadProfile() async {
    try {
      isLoading.value = true;
      final result = await repo.fetchKioskProfile();
      if (result != null) {
        profile.value = result;
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Starts the 1-minute countdown timer
  void startIdleCountdown() {
    _countdownTimer?.cancel();
    remainingSeconds.value = totalIdleDurationSeconds;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 1) {
        remainingSeconds.value--;
      } else {
        timer.cancel();
        handleAutoLogout();
      }
    });
  }

  /// Resets idle timer when user touches the screen
  void resetIdleTimer() {
    if (_countdownTimer != null && _countdownTimer!.isActive) {
      remainingSeconds.value = totalIdleDurationSeconds;
    }
  }

  /// Handles timeout auto-logout
  void handleAutoLogout() {
    _countdownTimer?.cancel();
    CustomSnackbar.showInfo(
      message: 'Kiosk terminal session auto-cleared for security.',
    );
    Get.back();
  }

  /// Manual Logout Button
  void manualLogout() {
    _countdownTimer?.cancel();
    HapticFeedback.lightImpact();
    Get.back();
  }

  /// Attendance punch action (Check-In / Check-Out / Break)
  Future<void> punchAction(String action) async {
    resetIdleTimer();
    HapticFeedback.mediumImpact();

    try {
      isPunching.value = true;
      final success = await repo.punchAttendance(action);
      if (success) {
        CustomSnackbar.showSuccess(
          title: 'Action Recorded',
          message: '$action successfully registered at this terminal.',
        );
      }
    } finally {
      isPunching.value = false;
    }
  }

  /// Navigates to individual self-service actions
  void openLeaveRequest() {
    resetIdleTimer();
    Get.toNamed(Routes.CORRECTION);
  }

  void openEvaluations() {
    resetIdleTimer();
    Get.toNamed(Routes.EVALUATION);
  }

  void openEmployeeCard() {
    resetIdleTimer();
    Get.toNamed(Routes.EMPLOYEE_CARD);
  }

  void openTasks() {
    resetIdleTimer();
    Get.toNamed(Routes.TASKS);
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    super.onClose();
  }
}
