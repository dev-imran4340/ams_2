import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';

class DrawerModuleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentTint;
  final VoidCallback onTap;

  const DrawerModuleCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentTint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 10.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(15.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                child: Row(
                  children: [
                    // Icon Badge: Rounded container (8.r) with pastel tint fill, high-contrast icon
                    Container(
                      width: 32.r,
                      height: 32.r,
                      decoration: BoxDecoration(
                        color: accentTint.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: accentTint.withValues(alpha: 0.25),
                          width: 1.w,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Icon(icon, size: 20.sp, color: accentTint),
                    ),

                    AppSpaces.hSpace10,

                    // Typography: Title & Subtitle with flex protection
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.text14.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor,
                            ),
                          ),
                          AppSpaces.vSpace2,
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.text10.copyWith(
                              color: AppColors.subTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    AppSpaces.hSpace8,

                    // Trailing: Subtle chevron icon
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20.sp,
                      color: AppColors.subTextColor.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),

              // Signature Accent: Mandatory 3.w Modern Teal bottom border
            ],
          ),
        ),
      ),
    );
  }
}
