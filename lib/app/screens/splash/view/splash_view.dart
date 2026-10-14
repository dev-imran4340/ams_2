import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/assets/app_images.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_spaces.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/widgets/network_boundary_wrapper.dart';
import '../controller/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkBoundaryWrapper(
      onRetry: controller.checkSessionAndRoute,
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: Stack(
          children: [
            // 1. Ambient Background with Deep Multi-Stop Gradient
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary, // Deep Corporate Navy (#012B43)
                    AppColors.accentNavy, // Slate Navy (#023E61)
                    AppColors.primary,
                    AppColors.deepNavyBase, // Ultra-dark executive base
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            // 2. Layered Translucent Decorative Floating Rings for Ambient Glow
            Positioned(
              top: -80.r,
              right: -60.r,
              child: Container(
                width: 260.r,
                height: 260.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              bottom: -100.r,
              left: -80.r,
              child: Container(
                width: 280.r,
                height: 280.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.liteSecondary.withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              top: 220.h,
              left: 40.w,
              child: Container(
                width: 140.r,
                height: 140.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withValues(alpha: 0.03),
                ),
              ),
            ),

            // 3. Center Animated Brand Emblem & Identity
            const Center(child: _SplashBrandContent()),

            // 4. Bottom Telemetry & SoftGenie Version Tag
            Positioned(
              bottom: 24.h,
              left: 0,
              right: 0,
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Minimalist Sleek Linear Progress Micro-Indicator
                    Obx(() {
                      if (controller.isLoading.value) {
                        return SizedBox(
                          width: 44.w,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(3.r),
                            child: LinearProgressIndicator(
                              minHeight: 2.5.h,
                              backgroundColor: AppColors.white.withValues(
                                alpha: 0.12,
                              ),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.secondary,
                              ),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),

                    AppSpaces.vSpace14,

                    // Version Tag
                    Text(
                      'v2.0.0 • Secured by Softech Business Services',
                      style: AppTextStyles.text10.copyWith(
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w500,
                        color: AppColors.white.withValues(alpha: 0.5),
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

/// Self-contained animated brand hero unit with zero memory leaks
class _SplashBrandContent extends StatefulWidget {
  const _SplashBrandContent();

  @override
  State<_SplashBrandContent> createState() => _SplashBrandContentState();
}

class _SplashBrandContentState extends State<_SplashBrandContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = Tween<double>(begin: 0.84, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeIn));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Center Official Brand Logo with Ambient Glow
            Stack(
              alignment: Alignment.center,
              children: [
                // Soft radial ambient teal glow behind brand logo
                Container(
                  width: 180.w,
                  height: 60.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondary.withValues(alpha: 0.22),
                        blurRadius: 48.r,
                        spreadRadius: 12.r,
                      ),
                    ],
                  ),
                ),

                // Official High-Resolution Corporate White Logo
                Image.asset(
                  AppImages.whiteLogo,
                  width: 260.w,
                  fit: BoxFit.contain,
                ),
              ],
            ),

            AppSpaces.vSpace18,

            // Enterprise Tagline Capsule
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: AppColors.secondary.withValues(alpha: 0.25),
                  width: 0.8.w,
                ),
              ),
              child: Text(
                'Enterprise Workplace Intelligence',
                style: AppTextStyles.text12.copyWith(
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                  color: AppColors.liteSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
