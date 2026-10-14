import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/theme_controller.dart';

class AppColors {
  // Brand & Corporate Navy Primary
  static const Color primary = Color(0xFF012B43); // Deep Corporate Navy
  static const Color litePrimary = Color(0xFF99BBD6); // Soft Navy Tint

  // Secondary & Accents
  static const Color secondary = Color(0xFF0DA6A3);
  static const Color liteSecondary = Color(0xFFB4E3E4);
  static const Color accentNavy = Color(0xFF023E61);

  // Status & Attendance Accents
  static const Color success = Color(0xFF10B981); // On-time Green
  static const Color warning = Color(0xFFF59E0B); // Late Amber
  static const Color error = Color(0xFFEF4444); // Absent Red
  static const Color info = Color(0xFF3B82F6); // Corporate Blue
  static const Color blue = Color(0xFF3B82F6);
  static const Color successMint = Color(0xFF34D399);

  // Hardware, ID Card & Executive Accents
  static const Color darkStripe = Color(0xFF1E293B);
  static const Color metallicGold = Color(0xFFD4AF37);
  
    static const Color metallicGoldDark = Color(0xFFB8860B);
  static const Color metallicGoldPath = Color(0xFF996515);
  static const Color deepNavyBase = Color(0xFF001524);

  // Attendance Specific Aliases
  static const Color onTime = success;
  static const Color late = warning;
  static const Color absent = error;

  // Neutrals
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;

  // Light Theme Palette
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightCardBackground = Color(0xFFFFFFFF);
  static const Color lightInputFill = Color(0xFFF3F4F6); // Cool Grey
  static const Color lightTextColor = Color(0xFF012B43);
  static const Color lightSubTextColor = Color(0xFF64748B);
  static const Color lightBorderColor = Color(0xFFE2E8F0);
  static const Color lightHintColor = Color(0xFF94A3B8);
  static const Color lightSurfaceColor = Color(0xFFFFFFFF);

  // Dark Theme Palette
  static const Color darkBackground = Color(0xFF0B132B);
  static const Color darkCardBackground = Color(0xFF1C2541);
  static const Color darkInputFill = Color(0xFF1E293B);
  static const Color darkTextColor = Color(0xFFF8FAFC);
  static const Color darkSubTextColor = Color(0xFF94A3B8);
  static const Color darkBorderColor = Color(0xFF334155);
  static const Color darkHintColor = Color(0xFF64748B);
  static const Color darkSurfaceColor = Color(0xFF1C2541);

  static bool get _isDarkMode {
    if (Get.isRegistered<ThemeController>()) {
      return Get.find<ThemeController>().isDarkMode.value;
    }
    try {
      final dynamic themeController = Get.find(tag: 'ThemeController');
      return themeController.isDarkMode.value;
    } catch (_) {
      return Get.isDarkMode;
    }
  }

  // Dynamic Theme Getters (Enforces zero inline ternaries in UI views)
  static Color get primaryColor => primary;
  static Color get litePrimaryColor =>
      _isDarkMode ? darkSurfaceColor : litePrimary;
  static Color get textColor => _isDarkMode ? darkTextColor : lightTextColor;
  static Color get subTextColor =>
      _isDarkMode ? darkSubTextColor : lightSubTextColor;
  static Color get backgroundColor =>
      _isDarkMode ? darkBackground : lightBackground;
  static Color get cardBackground =>
      _isDarkMode ? darkCardBackground : lightCardBackground;
  static Color get inputFill => _isDarkMode ? darkInputFill : lightInputFill;
  static Color get borderColor =>
      _isDarkMode ? darkBorderColor : lightBorderColor;
  static Color get surfaceColor =>
      _isDarkMode ? darkSurfaceColor : lightSurfaceColor;
  static Color get hintColor => _isDarkMode ? darkHintColor : lightHintColor;
  static Color get accent => _isDarkMode ? litePrimary : accentNavy;
  static Color get accentColor => accentNavy;
  static Color get onTimeColor => onTime;
  static Color get lateColor => late;
  static Color get absentColor => absent;
}
