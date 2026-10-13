import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';

class NavItemCapsule extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool hasBadge;
  final VoidCallback onTap;

  const NavItemCapsule({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.hasBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeInOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 14.w : 10.w,
          vertical: 8.h,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(22.r),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.28),
                    blurRadius: 10.r,
                    offset: Offset(0, 3.h),
                  ),
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.15),
                    blurRadius: 6.r,
                    offset: Offset(0, 1.h),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with optional notification badge indicator
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: isSelected ? 18.sp : 22.sp,
                  color: isSelected ? AppColors.white : AppColors.subTextColor,
                ),
                if (hasBadge && !isSelected)
                  Positioned(
                    top: -2.r,
                    right: -3.r,
                    child: Container(
                      width: 7.r,
                      height: 7.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.absentColor,
                        border: Border.all(
                          color: AppColors.cardBackground,
                          width: 1.5.w,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Animated Label Expansion
            if (isSelected) ...[
              AppSpaces.hSpace6,
              Text(
                label,
                style: AppTextStyles.text12.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
