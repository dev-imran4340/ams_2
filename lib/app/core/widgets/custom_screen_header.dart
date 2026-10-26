import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../../screens/index/controller/index_controller.dart';
import '../utils/app_colors.dart';
import '../utils/app_spaces.dart';
import '../utils/app_text_styles.dart';

/// Centralized Corporate Screen Header:
/// Consistent top navigation bar with rounded squircle back button,
/// primary title, subtitle, and customizable trailing action buttons.
class CustomScreenHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showBackButton;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final Widget? customTitleWidget;
  final Color? titleColor;
  final Color? subtitleColor;

  const CustomScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showBackButton = true,
    this.onBack,
    this.actions,
    this.customTitleWidget,
    this.titleColor,
    this.subtitleColor,
  });

  /// Factory helper for a uniform square action button with white card styling
  static Widget actionButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
    Color? backgroundColor,
    double? iconSize,
    String? tooltip,
  }) {
    return Material(
      color: Colors.transparent,
      child: Tooltip(
        message: tooltip ?? '',
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.all(9.r),
            decoration: BoxDecoration(
              color: backgroundColor ?? AppColors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.borderColor, width: 0.8.w),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  blurRadius: 6.r,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: iconSize ?? 18.sp,
              color: iconColor ?? AppColors.secondary,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. Back Button: Navigates to Index (Home / Dashboard) smoothly
        if (showBackButton) ...[
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                if (onBack != null) {
                  onBack!();
                } else if (Navigator.canPop(context)) {
                  Get.back();
                } else if (Get.isRegistered<IndexController>()) {
                  Get.find<IndexController>().changeTab(0);
                } else {
                  Get.offAllNamed(Routes.INDEX);
                }
              },
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                padding: EdgeInsets.all(9.r),
                margin: EdgeInsets.only(right: 10.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.borderColor, width: 0.8.w),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      blurRadius: 6.r,
                      offset: Offset(0, 2.h),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16.sp,
                  color: AppColors.textColor,
                ),
              ),
            ),
          ),
        ],

        // 2. Title & Subtitle with flex protection
        Expanded(
          child: customTitleWidget ??
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.text16.copyWith(
                      fontWeight: FontWeight.bold,
                      color: titleColor ?? AppColors.textColor,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    AppSpaces.vSpace2,
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.text10.copyWith(
                        color: subtitleColor ??
                            (titleColor != null
                                ? titleColor!.withValues(alpha: 0.75)
                                : AppColors.textColor.withValues(alpha: 0.75)),
                      ),
                    ),
                  ],
                ],
              ),
        ),

        // 3. Actions
        if (actions != null && actions!.isNotEmpty) ...[
          AppSpaces.hSpace8,
          Row(
            mainAxisSize: MainAxisSize.min,
            children: actions!
                .map((action) => Padding(
                      padding: EdgeInsets.only(left: 6.w),
                      child: action,
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }
}
