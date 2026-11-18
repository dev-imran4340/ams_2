import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_card.dart';

class BirthdayPrivacyCard extends StatelessWidget {
  final bool isShared;
  final bool isLoading;
  final ValueChanged<bool> onToggle;

  const BirthdayPrivacyCard({
    super.key,
    required this.isShared,
    required this.isLoading,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      backgroundColor: AppColors.cardBackground,
      showBottomAccent: true,
      accentWidth: 3.w,
      accentColor: AppColors.secondary,
      child: Row(
        children: [
          // 1. Signature Brand Gradient Cake Badge
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withValues(alpha: 0.25),
                  blurRadius: 8.r,
                  offset: Offset(0, 3.h),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.cake_rounded,
                size: 22.w,
                color: Colors.white,
              ),
            ),
          ),

          AppSpaces.hSpace12,

          // 2. Title & Helper Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Share My Birthday',
                  style: AppTextStyles.text14.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textColor,
                  ),
                ),
                AppSpaces.vSpace2,
                Text(
                  'Visible to location colleagues in milestones',
                  style: AppTextStyles.text12.copyWith(
                    color: AppColors.subTextColor,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          AppSpaces.hSpace8,

          // 3. Modern Switch / Progress Indicator
          if (isLoading)
            SizedBox(
              width: 24.w,
              height: 24.w,
              child: CircularProgressIndicator(
                strokeWidth: 2.w,
                color: AppColors.secondary,
              ),
            )
          else
            Transform.scale(
              scale: 0.88,
              child: Switch.adaptive(
                value: isShared,
                activeTrackColor: AppColors.secondary,
                activeThumbColor: Colors.white,
                inactiveTrackColor: AppColors.borderColor,
                onChanged: onToggle,
              ),
            ),
        ],
      ),
    );
  }
}
