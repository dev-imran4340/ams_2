import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/widgets/custom_snackbar.dart';

class IndexController extends GetxController {
  // Current active navigation tab index (0: Dashboard, 1: History, 2: Leaves, 3: Profile)
  final RxInt currentIndex = 0.obs;

  // Double back-press timestamp tracking for graceful exit
  DateTime? _lastBackPressTime;

  // Badge notification indicators
  final RxBool hasPendingLeaves = true.obs;
  final RxBool hasUnreadLogs = false.obs;

  /// Changes the current tab with range safety and haptic feedback
  void changeTab(int index) {
    if (index < 0 || index > 3) return;
    if (currentIndex.value != index) {
      HapticFeedback.lightImpact();
      currentIndex.value = index;
    }
  }

  /// Handles Android system back button behavior:
  /// - If on another tab, navigates back to Dashboard (tab 0).
  /// - If on Dashboard, requires double-press within 2 seconds to exit app.
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
