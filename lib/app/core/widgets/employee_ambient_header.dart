import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/app_colors.dart';

/// Unified Ambient Curved Gradient Header for all Employee Mode screens.
/// Standardizes the visual header language across:
/// - Dashboard (`dashboard_view.dart`)
/// - Leaves (`leave_requests_view.dart`)
/// - Employees / Directory (`department_employees_view.dart`)
/// - Profile Hub (`profile_view.dart`)
/// - Profile Details (`profile_details_view.dart`)
/// - Employee ID Card (`employee_card_view.dart`)
/// - Edit Profile & Attendance Regularization
class EmployeeAmbientHeader extends StatelessWidget {
  final double? height;
  final double? borderRadius;
  final Widget? child;
  final List<Color>? gradientColors;

  const EmployeeAmbientHeader({
    super.key,
    this.height,
    this.borderRadius,
    this.child,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = height ?? 280.h;
    final effectiveRadius = borderRadius ?? 20.r;

    return Container(
      width: double.infinity,
      height: effectiveHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors ??
              const [
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
          bottomLeft: Radius.circular(effectiveRadius),
          bottomRight: Radius.circular(effectiveRadius),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // Ambient Decorative Top-Right Ring
          Positioned(
            top: -70.r,
            right: -45.r,
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
            bottom: 45.r,
            left: -65.r,
            child: Container(
              width: 130.r,
              height: 130.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withValues(alpha: 0.05),
              ),
            ),
          ),

          ?child,
        ],
      ),
    );
  }
}
