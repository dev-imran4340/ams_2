import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_spaces.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../controller/auth_controller.dart';

class ForgotPasswordView extends GetView<AuthController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textColor,
            size: 18.sp,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Forgot Password',
          style: AppTextStyles.text18.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon Container
              Center(
                child: Container(
                  width: 72.r,
                  height: 72.r,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_reset_rounded,
                    color: AppColors.secondary,
                    size: 38.sp,
                  ),
                ),
              ),
              AppSpaces.vSpace20,

              // Instructions Header
              Text(
                'Password Recovery',
                textAlign: TextAlign.center,
                style: AppTextStyles.text22.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              AppSpaces.vSpace6,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  'Enter your registered corporate email. We will send a secure password reset link to your inbox.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.text12.copyWith(
                    color: AppColors.hintColor,
                    height: 1.4,
                  ),
                ),
              ),
              AppSpaces.vSpace24,

              // Strict Floating Card with 12.w inside padding, 15.r radius, and 3.w Teal bottom accent border
              Container(
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(15.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      blurRadius: 20.r,
                      offset: Offset(0, 8.h),
                    ),
                  ],
                ),
                padding: EdgeInsets.only(bottom: 3.w),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15.r),
                      topRight: Radius.circular(15.r),
                      bottomLeft: Radius.circular(12.r),
                      bottomRight: Radius.circular(12.r),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 18.h,
                  ),
                  child: Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Email Field
                        CustomTextField(
                          labelText: 'Registered Email Address',
                          hintText: 'e.g. employee@acme.pk',
                          controller: controller.forgotPasswordEmailController,
                          focusNode: controller.forgotPasswordFocusNode,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icon(
                            Icons.mail_outline_rounded,
                            color: AppColors.hintColor,
                            size: 20.sp,
                          ),
                          onFieldSubmitted: (_) =>
                              controller.submitForgotPassword(),
                        ),

                        // Inline validation error
                        if (controller.forgotPasswordError.value != null &&
                            controller
                                .forgotPasswordError.value!.isNotEmpty) ...[
                          AppSpaces.vSpace8,
                          Row(
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                color: AppColors.error,
                                size: 16.sp,
                              ),
                              AppSpaces.hSpace6,
                              Expanded(
                                child: Text(
                                  controller.forgotPasswordError.value!,
                                  style: AppTextStyles.text12.copyWith(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        // Probing-proof server success message card
                        if (controller.forgotPasswordSuccessMessage.value !=
                                null &&
                            controller.forgotPasswordSuccessMessage.value!
                                .isNotEmpty) ...[
                          AppSpaces.vSpace14,
                          Container(
                            decoration: BoxDecoration(
                              color:
                                  AppColors.secondary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color:
                                    AppColors.secondary.withValues(alpha: 0.3),
                                width: 1.w,
                              ),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 10.h,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle_outline_rounded,
                                  color: AppColors.secondary,
                                  size: 20.sp,
                                ),
                                AppSpaces.hSpace8,
                                Expanded(
                                  child: Text(
                                    controller
                                        .forgotPasswordSuccessMessage.value!,
                                    style: AppTextStyles.text12.copyWith(
                                      color: AppColors.textColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        AppSpaces.vSpace20,

                        // Pill-shaped Corporate Gradient Button
                        CustomButton(
                          isGradient: true,
                          text: 'Send Reset Link',
                          isLoading: controller.isForgotPasswordLoading.value,
                          onPressed: () => controller.submitForgotPassword(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              AppSpaces.vSpace24,

              // Return to Login Link
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    Get.back();
                  },
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    size: 16.sp,
                    color: AppColors.textColor,
                  ),
                  label: Text(
                    'Return to Sign In',
                    style: AppTextStyles.text12.copyWith(
                      color: AppColors.textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
