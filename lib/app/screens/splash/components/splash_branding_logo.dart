import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_spaces.dart';
import '../../../core/utils/app_text_styles.dart';

class SplashBrandingLogo extends StatefulWidget {
  const SplashBrandingLogo({super.key});

  @override
  State<SplashBrandingLogo> createState() => _SplashBrandingLogoState();
}

class _SplashBrandingLogoState extends State<SplashBrandingLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );
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
          children: [
            // Elegant Attendance Brand Badge
            Container(
              width: 96.w,
              height: 96.w,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 28.r,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.fingerprint_rounded,
                  size: 52.sp,
                  color: AppColors.white,
                ),
              ),
            ),
            AppSpaces.vSpace24,
            Text(
              'AMS 2',
              style: AppTextStyles.text28.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
                letterSpacing: 1.5,
              ),
            ),
            AppSpaces.vSpace8,
            Text(
              'Attendance Management System',
              style: AppTextStyles.text14.copyWith(
                color: AppColors.subTextColor,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
