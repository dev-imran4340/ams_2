import 'package:ams_2/app/core/assets/app_images.dart';
import 'package:ams_2/app/core/widgets/custom_button.dart';
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
                child: Divider(color: AppColors.borderColor, thickness: 1.h),
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
                child: Divider(color: AppColors.borderColor, thickness: 1.h),
              ),
            ],
          ),
          AppSpaces.vSpace12,

          // Side-by-Side Modern Pill Buttons (From Design Mockup)
          CustomButton(
            borderRadius: 25.r,
            isOutlined: true,
            icon: Image.asset(AppImages.google, height: 18.h, width: 18.w),
            text: "Sign in with Google",
            borderColor: AppColors.primary,
            textColor: AppColors.primary,
            backgroundColor: AppColors.white,

            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
