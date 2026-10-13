import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../controller/profile_controller.dart';

class LogoutConfirmSheet extends GetView<ProfileController> {
  const LogoutConfirmSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
        border: Border.all(
          color: AppColors.borderColor,
          width: 1.w,
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle pill
            Container(
              width: 42.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.borderColor,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),

            AppSpaces.vSpace20,

            // Warning / Logout Emblem Badge
            Container(
              width: 64.r,
              height: 64.r,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.25),
                  width: 1.5.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.error.withValues(alpha: 0.15),
                    blurRadius: 16.r,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.logout_rounded,
                  size: 28.sp,
                  color: AppColors.error,
                ),
              ),
            ),

            AppSpaces.vSpace16,

            // Title
            Text(
              'Sign Out of AMS 2?',
              style: AppTextStyles.text18.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),

            AppSpaces.vSpace8,

            // Description
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                'Are you sure you want to end your active session? You will need your official credentials to sign back in.',
                textAlign: TextAlign.center,
                style: AppTextStyles.text12.copyWith(
                  color: AppColors.subTextColor,
                  height: 1.4,
                ),
              ),
            ),

            AppSpaces.vSpace24,

            // Action Buttons Row
            Row(
              children: [
                // Cancel Button
                Expanded(
                  child: CustomButton(
                    text: 'Cancel',
                    isOutlined: true,
                    borderColor: AppColors.borderColor,
                    textColor: AppColors.textColor,
                    height: 46.h,
                    borderRadius: 12.r,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),

                AppSpaces.hSpace12,

                // Confirm Sign Out Button
                Expanded(
                  child: Obx(
                    () => CustomButton(
                      text: 'Sign Out',
                      isLoading: controller.isLoggingOut.value,
                      backgroundColor: AppColors.error,
                      textColor: AppColors.white,
                      height: 46.h,
                      borderRadius: 12.r,
                      icon: Icon(
                        Icons.logout_rounded,
                        size: 16.sp,
                        color: AppColors.white,
                      ),
                      onPressed: controller.logout,
                    ),
                  ),
                ),
              ],
            ),

            AppSpaces.vSpace12,
          ],
        ),
      ),
    );
  }
}
