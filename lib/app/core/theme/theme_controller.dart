import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../api/app_preferences.dart';
import 'app_theme.dart';

class ThemeController extends GetxController {
  final RxBool isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    // 1. Check saved local preference from AppPreferences (GetStorage)
    final savedTheme = AppPreferences.isDarkMode;
    if (savedTheme != null) {
      isDarkMode.value = savedTheme;
    } else {
      // 2. Fallback to system theme mode
      isDarkMode.value = Get.isPlatformDarkMode;
    }
  }

  Future<void> toggleTheme(bool value) async {
    isDarkMode.value = value;
    // Persist to local storage
    await AppPreferences.setDarkMode(value);
    // Apply changes across GetX application
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
    Get.changeTheme(value ? AppTheme.darkTheme : AppTheme.lightTheme);
    Get.forceAppUpdate();
  }
}
