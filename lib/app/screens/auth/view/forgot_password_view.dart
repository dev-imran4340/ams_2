import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/assets/app_images.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_spaces.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/network_boundary_wrapper.dart';
import '../controller/auth_controller.dart';

class ForgotPasswordView extends GetView<AuthController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkBoundaryWrapper(
      onRetry: () async {
        await controller.submitForgotPassword();
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Stack(
          children: [
            // 1. Curved Corporate Navy Header with Ambient Elements (Matching LoginView)
            Container(
              width: double.infinity,
              height: 300.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.liteSecondary,
                    AppColors.liteSecondary,
                    AppColors.liteSecondary,
                    AppColors.liteSecondary,
                    AppColors.liteSecondary,
                    AppColors.liteSecondary,
                    AppColors.secondary,
                    AppColors.primary,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10.r),
                  bottomRight: Radius.circular(10.r),
                ),
              ),
              child: Stack(
                children: [
                  // Ambient Decorative Top-Right Ring
                  Positioned(
                    top: -80.r,
                    right: -55.r,
                    child: Container(
                      width: 160.r,
                      height: 160.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                  // Ambient Decorative Bottom-Left Glow
                  Positioned(
                    bottom: 65.r,
                    left: -75.r,
                    child: Container(
                      width: 130.r,
                      height: 130.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.secondary.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Main Scrollable Content
            SafeArea(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () {
                          Get.back();
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.white,
                          shadowColor: AppColors.black,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: AppColors.black,
                          size: 20.sp,
                        ),
                      ),
                    ),

                    // Top Navigation Header with Circular Back Button & Centered Logo
                    Image.asset(
                      AppImages.logo1,
                      height: 60.h,
                      fit: BoxFit.cover,
                    ),

                    // Spacing to move Form Container lower down
                    AppSpaces.vSpace40,

                    // 3. Floating Modern Card Container with 3.w Teal bottom accent border
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(15.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            blurRadius: 15.r,
                            offset: Offset(0, 4.h),
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
                        child: Stack(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 18.h,
                            ),
                            child: Obx(
                              () => Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    "Forgot Password?",
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.text30.copyWith(
                                      color: AppColors.textColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  AppSpaces.vSpace2,
                                  Text(
                                    "Enter your registered corporate email to receive a recovery link",
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.text12.copyWith(
                                      color: AppColors.textColor,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  AppSpaces.vSpace20,

                                  // Registered Corporate Email Field
                                  CustomTextField(
                                    labelText: 'Corporate Email Address',
                                    hintText: 'e.g. employee@acme.pk',
                                    controller: controller
                                        .forgotPasswordEmailController,
                                    focusNode:
                                        controller.forgotPasswordFocusNode,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.done,
                                    prefixIcon: Icon(
                                      Icons.mail_outline_rounded,
                                      color: AppColors.hintColor,
                                      size: 20.sp,
                                    ),
                                    onFieldSubmitted: (_) =>
                                        controller.submitForgotPassword(),
                                  ),

                                  // Inline validation error message
                                  if (controller.forgotPasswordError.value !=
                                          null &&
                                      controller
                                          .forgotPasswordError
                                          .value!
                                          .isNotEmpty) ...[
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
                                            controller
                                                .forgotPasswordError
                                                .value!,
                                            style: AppTextStyles.text12
                                                .copyWith(
                                                  color: AppColors.error,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],

                                  // Probing-proof Success Confirmation Message Banner
                                  if (controller
                                              .forgotPasswordSuccessMessage
                                              .value !=
                                          null &&
                                      controller
                                          .forgotPasswordSuccessMessage
                                          .value!
                                          .isNotEmpty) ...[
                                    AppSpaces.vSpace14,
                                    Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.secondary.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          10.r,
                                        ),
                                        border: Border.all(
                                          color: AppColors.secondary.withValues(
                                            alpha: 0.3,
                                          ),
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
                                            Icons.check_circle_rounded,
                                            color: AppColors.secondary,
                                            size: 20.sp,
                                          ),
                                          AppSpaces.hSpace8,
                                          Expanded(
                                            child: Text(
                                              controller
                                                  .forgotPasswordSuccessMessage
                                                  .value!,
                                              style: AppTextStyles.text12
                                                  .copyWith(
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

                                  // Pill-shaped Primary Gradient Action Button
                                  CustomButton(
                                    isGradient: true,
                                    text: 'Send Reset Link',
                                    isLoading: controller
                                        .isForgotPasswordLoading
                                        .value,
                                    onPressed: () =>
                                        controller.submitForgotPassword(),
                                  ),

                                  AppSpaces.vSpace16,

                                  // Return to Sign In Link
                                  Center(
                                    child: GestureDetector(
                                      onTap: () => Get.back(),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 4.h,
                                        ),
                                        child: RichText(
                                          textAlign: TextAlign.center,
                                          text: TextSpan(
                                            text: "Remember your password? ",
                                            style: AppTextStyles.text12
                                                .copyWith(
                                                  color: AppColors.subTextColor,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                            children: [
                                              TextSpan(
                                                text: 'Sign In',
                                                style: TextStyle(
                                                  color: AppColors.textColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12.sp,
                                                  fontFamily:
                                                      AppTextStyles.fontFamily,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
