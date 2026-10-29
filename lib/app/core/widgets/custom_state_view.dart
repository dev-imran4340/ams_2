import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/app_colors.dart';
import '../utils/app_spaces.dart';
import '../utils/app_text_styles.dart';
import 'custom_button.dart';

class CustomStateView extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final String? title;
  final String message;
  final String? buttonText;
  final VoidCallback? onRetry;
  final VoidCallback? onAction;
  final Widget? customAction;
  final EdgeInsetsGeometry? padding;

  const CustomStateView({
    super.key,
    required this.icon,
    this.iconColor,
    this.iconBackgroundColor,
    this.title,
    required this.message,
    this.buttonText,
    this.onRetry,
    this.onAction,
    this.customAction,
    this.padding,
  });

  /// Factory for Error States with optional Retry button
  factory CustomStateView.error({
    Key? key,
    IconData icon = Icons.error_outline_rounded,
    Color? iconColor,
    String? title = 'Something went wrong',
    required String message,
    String buttonText = 'Retry',
    VoidCallback? onRetry,
    EdgeInsetsGeometry? padding,
  }) {
    return CustomStateView(
      key: key,
      icon: icon,
      iconColor: iconColor ?? AppColors.error,
      iconBackgroundColor: AppColors.error.withValues(alpha: 0.1),
      title: title,
      message: message,
      buttonText: buttonText,
      onRetry: onRetry,
      padding: padding,
    );
  }

  /// Factory for Empty States with optional Action button
  factory CustomStateView.empty({
    Key? key,
    IconData icon = Icons.inbox_rounded,
    Color? iconColor,
    String? title = 'No Data Found',
    required String message,
    String? buttonText,
    VoidCallback? onAction,
    EdgeInsetsGeometry? padding,
  }) {
    return CustomStateView(
      key: key,
      icon: icon,
      iconColor: iconColor ?? AppColors.primary,
      iconBackgroundColor: AppColors.litePrimary,
      title: title,
      message: message,
      buttonText: buttonText,
      onAction: onAction,
      padding: padding,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveButtonAction = onRetry ?? onAction;

    return Center(
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding: padding ?? AppSpaces.defaultPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
            // Icon Container
            Container(
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: iconBackgroundColor ?? AppColors.cardBackground,
                shape: BoxShape.circle,
                border: Border.all(
                  color: (iconColor ?? AppColors.subTextColor)
                      .withValues(alpha: 0.2),
                  width: 1.5.w,
                ),
              ),
              child: Icon(
                icon,
                size: 38.sp,
                color: iconColor ?? AppColors.subTextColor,
              ),
            ),
            AppSpaces.vSpace16,

            // Title (Optional)
            if (title != null && title!.isNotEmpty) ...[
              Text(
                title!,
                style: AppTextStyles.text18.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpaces.vSpace8,
            ],

            // Message
            Text(
              message,
              style: AppTextStyles.text14.copyWith(
                color: AppColors.subTextColor,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            // Action / Retry Button
            if (customAction != null) ...[
              AppSpaces.vSpace20,
              customAction!,
            ] else if (effectiveButtonAction != null && buttonText != null) ...[
              AppSpaces.vSpace20,
              CustomButton(
                text: buttonText!,
                width: 130.w,
                height: 42.h,
                borderRadius: 10.r,
                onPressed: effectiveButtonAction,
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
}
