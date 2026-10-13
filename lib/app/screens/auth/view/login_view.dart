import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/assets/app_images.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_spaces.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/widgets/network_boundary_wrapper.dart';
import '../components/login_bottom_bar.dart';
import '../components/login_form.dart';
import '../components/social_auth_buttons.dart';
import '../controller/auth_controller.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkBoundaryWrapper(
      onRetry: () async {
        await controller.login();
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Stack(
          children: [
            // 1. Curved Corporate Navy Header with Ambient Elements
            Container(
              width: double.infinity,
              height: 290.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
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
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AppSpaces.vSpace20,

                    // Top Centered Corporate Logo Container
                    Image.asset(
                      AppImages.logo1,
                      height: 60.h,
                      fit: BoxFit.cover,
                    ),

                    // Centered Welcome & Sign In Text

                    // Spacing to move Form Container lower down
                    AppSpaces.vSpace40,

                    // 3. Floating Modern Card Container with 3.w bottom accent
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(15.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            blurRadius: 24.r,
                            offset: Offset(0, 10.h),
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
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 14.h,
                                ),
                              child: Column(
                                children: [
                                  Text(
                                    "Welcome Back!",
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.text30.copyWith(
                                      color: AppColors.textColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  AppSpaces.vSpace2,
                                  Text(
                                    "Sign in to your account to continue",
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.text12.copyWith(
                                      color: AppColors.textColor,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  AppSpaces.vSpace20,
                                  // Modern Form Fields & Primary Action Button
                                  const LoginForm(),

                                  AppSpaces.vSpace12,

                                  // Social & Quick Biometric Auth Pill Buttons
                                  const SocialAuthButtons(),

                                  AppSpaces.vSpace12,

                                  // Bottom Sign Up Link
                                  const LoginBottomBar(),
                                ],
                              ),
                            ),
                          ],
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
    );
  }
}
