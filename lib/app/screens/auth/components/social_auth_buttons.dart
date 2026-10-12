import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_spaces.dart';
import '../../../core/utils/app_text_styles.dart';
import '../controller/auth_controller.dart';

class SocialAuthButtons extends GetView<AuthController> {
  const SocialAuthButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Column(
        children: [
          // Elegant Thin "Or" Divider
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: AppColors.borderColor,
                  thickness: 1.h,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                child: Text(
                  'Or',
                  style: AppTextStyles.text12.copyWith(
                    color: AppColors.subTextColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: AppColors.borderColor,
                  thickness: 1.h,
                ),
              ),
            ],
          ),
          AppSpaces.vSpace20,

          // Side-by-Side Modern Pill Buttons (From Design Mockup)
          Row(
            children: [
              // Google Pill Button
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      // Google sign-in trigger
                    },
                    borderRadius: BorderRadius.circular(25.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 13.h),
                      decoration: BoxDecoration(
                        color: AppColors.inputFill,
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Crisp Google 'G' Icon
                          Container(
                            width: 20.w,
                            height: 20.w,
                            alignment: Alignment.center,
                            child: Text(
                              'G',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFEA4335),
                                fontFamily: AppTextStyles.fontFamily,
                              ),
                            ),
                          ),
                          AppSpaces.hSpace8,
                          Text(
                            'Google',
                            style: AppTextStyles.text14.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              AppSpaces.hSpace14,

              // Quick Biometric / Work SSO Pill Button
              Expanded(
                child: Obx(() {
                  final isProcessing = controller.isLoading.value ||
                      controller.isBiometricLoading.value;

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: isProcessing
                          ? null
                          : controller.loginWithBiometrics,
                      borderRadius: BorderRadius.circular(25.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 13.h),
                        decoration: BoxDecoration(
                          color: AppColors.inputFill,
                          borderRadius: BorderRadius.circular(25.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (controller.isBiometricLoading.value)
                              SizedBox(
                                width: 18.w,
                                height: 18.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              )
                            else ...[
                              Icon(
                                Icons.fingerprint_rounded,
                                color: AppColors.primary,
                                size: 20.sp,
                              ),
                              AppSpaces.hSpace8,
                              Text(
                                'Biometric',
                                style: AppTextStyles.text14.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
