import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_spaces.dart';
import '../../../../../core/utils/app_text_styles.dart';

class OrgActionHeroCard extends StatelessWidget {
  final String title;
  final String tag;
  final String description;
  final String buttonText;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const OrgActionHeroCard({
    super.key,
    required this.title,
    required this.tag,
    required this.description,
    required this.buttonText,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: accentColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 18.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      padding: EdgeInsets.only(bottom: 3.5.w),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: Radius.circular(13.r),
            bottomRight: Radius.circular(13.r),
          ),
          border: Border.all(
            color: AppColors.borderColor,
            width: 1.w,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Icon Badge & Operational Tag Capsule
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Icon Badge Container
                      Container(
                        width: 48.r,
                        height: 48.r,
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: accentColor.withValues(alpha: 0.28),
                            width: 1.w,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            icon,
                            size: 24.sp,
                            color: accentColor,
                          ),
                        ),
                      ),

                      // Operational Tag Capsule
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: accentColor.withValues(alpha: 0.25),
                            width: 0.8.w,
                          ),
                        ),
                        child: Text(
                          tag,
                          style: AppTextStyles.text10.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.4,
                            color: accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  AppSpaces.vSpace14,

                  // Title
                  Text(
                    title,
                    style: AppTextStyles.text18.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),

                  AppSpaces.vSpace6,

                  // Description
                  Text(
                    description,
                    style: AppTextStyles.text12.copyWith(
                      color: AppColors.subTextColor,
                      height: 1.45,
                    ),
                  ),

                  AppSpaces.vSpace14,

                  Divider(
                    color: AppColors.borderColor,
                    height: 1.h,
                    thickness: 0.8.h,
                  ),

                  AppSpaces.vSpace10,

                  // Action Button Row
                  Row(
                    children: [
                      Text(
                        buttonText,
                        style: AppTextStyles.text12.copyWith(
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                          letterSpacing: 0.3,
                        ),
                      ),
                      AppSpaces.hSpace6,
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 15.sp,
                        color: accentColor,
                      ),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.all(4.r),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accentColor.withValues(alpha: 0.08),
                        ),
                        child: Icon(
                          Icons.chevron_right_rounded,
                          size: 16.sp,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
