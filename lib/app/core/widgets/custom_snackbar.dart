import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

class CustomSnackbar {
  /// Displays a floating top snackbar safely using Get.rawSnackbar with Toast fallback.
  /// Immune to "An OverlayEntry should be removed only once" crashes across route transitions.
  static void _showSnackbar({
    required String title,
    required String message,
    required Color backgroundColor,
    required IconData icon,
    Duration duration = const Duration(seconds: 2),
  }) {
    try {
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }

      Get.rawSnackbar(
        titleText: Text(
          title,
          style: AppTextStyles.text14.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        messageText: Text(
          message,
          style: AppTextStyles.text12.copyWith(color: AppColors.white),
        ),
        icon: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Icon(icon, color: AppColors.white, size: 24.sp),
        ),
        snackPosition: SnackPosition.TOP,
        backgroundColor: backgroundColor,
        borderRadius: 12.r,
        margin: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        duration: duration,
        snackStyle: SnackStyle.FLOATING,
        animationDuration: const Duration(milliseconds: 300),
      );
      return;
    } catch (_) {}

    _fallbackToast(message, backgroundColor);
  }

  /// Safe fallback to Fluttertoast
  static void _fallbackToast(String message, Color backgroundColor) {
    try {
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: backgroundColor,
        textColor: AppColors.white,
        fontSize: 14.0,
      ).catchError((_) => null);
    } catch (_) {}
  }

  /// Shows Success Top Snackbar
  static void showSuccess({
    required String message,
    String title = 'Success',
    BuildContext? context,
  }) {
    _showSnackbar(
      title: title,
      message: message,
      backgroundColor: AppColors.success,
      icon: Icons.check_circle_rounded,
      duration: const Duration(seconds: 2),
    );
  }

  /// Shows Error Top Snackbar
  static void showError({
    required String message,
    String title = 'Error',
    BuildContext? context,
  }) {
    _showSnackbar(
      title: title,
      message: message,
      backgroundColor: AppColors.error,
      icon: Icons.error_outline_rounded,
      duration: const Duration(seconds: 3),
    );
  }

  /// Shows Info / Warning Top Snackbar
  static void showWarning({
    required String message,
    String title = 'Warning',
    BuildContext? context,
  }) {
    _showSnackbar(
      title: title,
      message: message,
      backgroundColor: AppColors.warning,
      icon: Icons.warning_amber_rounded,
      duration: const Duration(seconds: 2),
    );
  }

  /// Shows Info Top Snackbar
  static void showInfo({
    required String message,
    String title = 'Information',
    BuildContext? context,
  }) {
    _showSnackbar(
      title: title,
      message: message,
      backgroundColor: AppColors.secondary,
      icon: Icons.info_outline_rounded,
      duration: const Duration(seconds: 2),
    );
  }
}

