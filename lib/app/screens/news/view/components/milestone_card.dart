import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../model/news_model.dart';

class MilestoneCard extends StatelessWidget {
  final ColleagueMilestoneItemModel milestone;

  const MilestoneCard({
    super.key,
    required this.milestone,
  });

  @override
  Widget build(BuildContext context) {
    final bool isBirthday = milestone.isBirthday;
    final Color badgeColor = isBirthday ? AppColors.secondary : AppColors.primary;
    final IconData icon = isBirthday ? Icons.cake_rounded : Icons.workspace_premium_rounded;

    return CustomCard(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      child: Row(
        children: [
          // 1. Milestone Type Circular Avatar
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: badgeColor.withValues(alpha: 0.25),
                width: 1.w,
              ),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 22.w,
                color: badgeColor,
              ),
            ),
          ),

          AppSpaces.hSpace12,

          // 2. Employee & Milestone Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        milestone.employee.name,
                        style: AppTextStyles.text14.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AppSpaces.hSpace8,
                    // When Pill (e.g. "Tomorrow", "Today", "In 5 days")
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        milestone.when,
                        style: AppTextStyles.text10.copyWith(
                          fontWeight: FontWeight.w700,
                          color: badgeColor,
                        ),
                      ),
                    ),
                  ],
                ),

                AppSpaces.vSpace4,

                // Designation
                if (milestone.employee.designation != null &&
                    milestone.employee.designation!.isNotEmpty)
                  Text(
                    milestone.employee.designation!,
                    style: AppTextStyles.text12.copyWith(
                      color: AppColors.subTextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                AppSpaces.vSpace4,

                // Milestone Celebration Text
                Row(
                  children: [
                    Icon(
                      Icons.celebration_rounded,
                      size: 12.w,
                      color: badgeColor,
                    ),
                    AppSpaces.hSpace4,
                    Expanded(
                      child: Text(
                        milestone.text.isNotEmpty
                            ? milestone.text
                            : (isBirthday ? 'Birthday' : 'Work Anniversary'),
                        style: AppTextStyles.text12.copyWith(
                          fontWeight: FontWeight.w600,
                          color: badgeColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
