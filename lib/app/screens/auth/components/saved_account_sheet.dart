import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_spaces.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../controller/auth_controller.dart';

/// Modal bottom sheet asking the user if they wish to auto-populate
/// credentials from their securely encrypted remembered account.
class SavedAccountSheet {
  static void show(BuildContext context, {required String accountIdentifier, required bool isEmployeeNumberMode}) {
    final controller = Get.find<AuthController>();

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20.r),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.12),
              blurRadius: 24.r,
              offset: Offset(0, -4.h),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Drag Handle
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.borderColor,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              AppSpaces.vSpace16,

              // 2. Shield / Vault Icon
              Container(
                width: 52.r,
                height: 52.r,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.lock_person_rounded,
                    color: AppColors.secondary,
                    size: 26.sp,
                  ),
                ),
              ),
              AppSpaces.vSpace12,

              // 3. Header Titles
              Text(
                'Use Saved Account?',
                textAlign: TextAlign.center,
                style: AppTextStyles.text20.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              AppSpaces.vSpace4,
              Text(
                'Would you like to sign in with your saved credentials?',
                textAlign: TextAlign.center,
                style: AppTextStyles.text12.copyWith(
                  color: AppColors.subTextColor,
                ),
              ),
              AppSpaces.vSpace16,

              // 4. Saved Account Card with 3.w Teal Accent
              Container(
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.only(bottom: 3.w),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.backgroundColor,
                    borderRadius: BorderRadius.circular(11.r),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  child: Row(
                    children: [
                      Container(
                        width: 40.r,
                        height: 40.r,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            isEmployeeNumberMode
                                ? Icons.badge_rounded
                                : Icons.person_rounded,
                            color: AppColors.primary,
                            size: 22.sp,
                          ),
                        ),
                      ),
                      AppSpaces.hSpace12,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              accountIdentifier,
                              style: AppTextStyles.text14.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            AppSpaces.vSpace2,
                            Row(
                              children: [
                                Icon(
                                  Icons.enhanced_encryption_rounded,
                                  size: 12.sp,
                                  color: AppColors.secondary,
                                ),
                                AppSpaces.hSpace4,
                                Text(
                                  isEmployeeNumberMode
                                      ? 'Employee ID Account'
                                      : 'Corporate Email Account',
                                  style: AppTextStyles.text10.copyWith(
                                    color: AppColors.subTextColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AppSpaces.vSpace20,

              // 5. Primary Action Button (Yes, Fill and Continue)
              CustomButton(
                isGradient: true,
                text: 'Yes, Use This Account',
                onPressed: () {
                  controller.applySavedCredentials();
                  Get.back();
                },
              ),
              AppSpaces.vSpace8,

              // 6. Secondary Options (Use Different Account & Forget)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      controller.forgetSavedAccount();
                      Get.back();
                    },
                    child: Text(
                      'Forget Account',
                      style: AppTextStyles.text12.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      controller.dismissSavedAccountPrompt();
                      Get.back();
                    },
                    child: Text(
                      'Use Different Account',
                      style: AppTextStyles.text12.copyWith(
                        color: AppColors.textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      enableDrag: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
    );
  }
}
