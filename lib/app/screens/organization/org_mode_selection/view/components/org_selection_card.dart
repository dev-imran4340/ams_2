import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_spaces.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../model/org_mode_model.dart';

class OrgSelectionCard extends StatelessWidget {
  final OrgModeOption option;
  final VoidCallback onTap;

  const OrgSelectionCard({
    super.key,
    required this.option,
    required this.onTap,
  });

  Color get _badgeBackgroundColor {
    switch (option.id) {
      case 'visitor':
        return AppColors.secondary.withValues(alpha: 0.12);
      case 'employee':
        return AppColors.blue.withValues(alpha: 0.12);
      case 'add_employee':
        return AppColors.warning.withValues(alpha: 0.14);
      default:
        return AppColors.secondary.withValues(alpha: 0.12);
    }
  }

  Color get _badgeTextColor {
    switch (option.id) {
      case 'visitor':
        return AppColors.secondary;
      case 'employee':
        return AppColors.blue;
      case 'add_employee':
        return AppColors.warning;
      default:
        return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: _badgeTextColor.withValues(alpha: 0.25),
          width: 1.2.w,
        ),
        boxShadow: [
          BoxShadow(
            color: _badgeTextColor.withValues(alpha: 0.08),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashColor: AppColors.secondary.withValues(alpha: 0.08),
          highlightColor: AppColors.secondary.withValues(alpha: 0.04),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Circular Icon Container with AppColors.primary fill & white icon
                    Container(
                      width: 48.r,
                      height: 48.r,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.18),
                            blurRadius: 8.r,
                            offset: Offset(0, 3.h),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          option.icon,
                          size: 22.sp,
                          color: AppColors.white,
                        ),
                      ),
                    ),

                    AppSpaces.hSpace12,

                    // Badge Pill & Title
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Badge Pill
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              color: _badgeBackgroundColor,
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              option.badge,
                              style: AppTextStyles.text10.copyWith(
                                color: _badgeTextColor,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),

                          AppSpaces.vSpace4,

                          // Title
                          Text(
                            option.title,
                            style: AppTextStyles.text18.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    AppSpaces.hSpace8,

                    // Chevron indicator
                    Container(
                      width: 32.r,
                      height: 32.r,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16.sp,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  ],
                ),

                AppSpaces.vSpace12,

                // Description text
                Text(
                  option.description,
                  style: AppTextStyles.text12.copyWith(
                    color: AppColors.subTextColor,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
