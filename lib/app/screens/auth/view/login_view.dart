import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

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
            // 1. Curved Corporate Navy Header with Subtle Ambient Circles
            Container(
              width: double.infinity,
              height: 270.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.accentColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32.r),
                  bottomRight: Radius.circular(32.r),
                ),
              ),
              child: Stack(
                children: [
                  // Ambient Decorative Highlights
                  Positioned(
                    top: -40.r,
                    right: -30.r,
                    child: Container(
                      width: 150.r,
                      height: 150.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.white.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20.r,
                    left: -40.r,
                    child: Container(
                      width: 120.r,
                      height: 120.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.white.withValues(alpha: 0.04),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Main Content & Form Flow
            SafeArea(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSpaces.vSpace16,

                    // Header Text & AMS 2 Badge
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Welcome Back!",
                              style: AppTextStyles.text14.copyWith(
                                color: AppColors.white.withValues(alpha: 0.85),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            AppSpaces.vSpace6,
                            Text(
                              "Sign In",
                              style: AppTextStyles.text28.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                        // Enterprise Chip Badge
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: AppColors.white.withValues(alpha: 0.2),
                              width: 1.w,
                            ),
                          ),
                          child: Text(
                            "AMS 2",
                            style: AppTextStyles.text10.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    AppSpaces.vSpace32,

                    // 3. Floating Modern White Card
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 22.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(22.r),
                        border: Border.all(
                          color: AppColors.borderColor,
                          width: 1.w,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            blurRadius: 24.r,
                            offset: Offset(0, 10.h),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Modern Form Fields & Primary Action Button
                          const LoginForm(),

                          AppSpaces.vSpace22,

                          // Social & Quick Biometric Auth Pill Buttons
                          const SocialAuthButtons(),

                          AppSpaces.vSpace18,

                          // Bottom Sign Up Link
                          const LoginBottomBar(),

                          AppSpaces.vSpace4,
                        ],
                      ),
                    ),
                    AppSpaces.vSpace24,
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
