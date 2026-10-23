import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

class CustomSnackbar {
  /// Safely resolves the active OverlayState without throwing FlutterError
  static OverlayState? _getOverlayState([BuildContext? context]) {
    try {
      if (context != null) {
        final state = Overlay.maybeOf(context);
        if (state != null) return state;
      }
      if (Get.key.currentState?.overlay != null) {
        return Get.key.currentState!.overlay;
      }
      if (Get.overlayContext != null) {
        final state = Overlay.maybeOf(Get.overlayContext!);
        if (state != null) return state;
      }
      if (Get.context != null) {
        final state = Overlay.maybeOf(Get.context!);
        if (state != null) return state;
      }
    } catch (_) {}
    return null;
  }

  /// Safe fallback to Fluttertoast or Get.rawSnackbar when Overlay is unavailable
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
    } catch (_) {
      try {
        Get.rawSnackbar(
          message: message,
          backgroundColor: backgroundColor,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
      } catch (_) {}
    }
  }

  /// Shows Success Top Snackbar
  static void showSuccess({
    required String message,
    String title = 'Success',
    BuildContext? context,
  }) {
    try {
      final overlayState = _getOverlayState(context);
      if (overlayState != null) {
        showTopSnackBar(
          overlayState,
          CustomSnackBar.success(
            message: message,
            backgroundColor: AppColors.success,
            textStyle: AppTextStyles.text14.copyWith(color: AppColors.white),
          ),
          displayDuration: const Duration(milliseconds: 500),
        );
        return;
      }
    } catch (_) {}

    _fallbackToast(message, AppColors.success);
  }

  /// Shows Error Top Snackbar
  static void showError({
    required String message,
    String title = 'Error',
    BuildContext? context,
  }) {
    try {
      final overlayState = _getOverlayState(context);
      if (overlayState != null) {
        showTopSnackBar(
          overlayState,
          CustomSnackBar.error(
            message: message,
            backgroundColor: AppColors.error,
            textStyle: AppTextStyles.text14.copyWith(color: AppColors.white),
          ),
          displayDuration: const Duration(milliseconds: 500),
        );
        return;
      }
    } catch (_) {}

    _fallbackToast(message, AppColors.error);
  }

  /// Shows Info / Warning Top Snackbar
  static void showWarning({
    required String message,
    String title = 'Warning',
    BuildContext? context,
  }) {
    try {
      final overlayState = _getOverlayState(context);
      if (overlayState != null) {
        showTopSnackBar(
          overlayState,
          CustomSnackBar.info(
            message: message,
            backgroundColor: AppColors.warning,
            textStyle: AppTextStyles.text14.copyWith(color: AppColors.white),
          ),
          displayDuration: const Duration(milliseconds: 500),
        );
        return;
      }
    } catch (_) {}

    _fallbackToast(message, AppColors.warning);
  }

  /// Shows Info Top Snackbar
  static void showInfo({required String message, BuildContext? context}) {
    try {
      final overlayState = _getOverlayState(context);
      if (overlayState != null) {
        showTopSnackBar(
          overlayState,
          CustomSnackBar.info(
            message: message,
            backgroundColor: AppColors.blue,
            textStyle: AppTextStyles.text14.copyWith(color: AppColors.white),
          ),
          displayDuration: const Duration(seconds: 3),
        );
        return;
      }
    } catch (_) {}

    _fallbackToast(message, AppColors.blue);
  }
}
