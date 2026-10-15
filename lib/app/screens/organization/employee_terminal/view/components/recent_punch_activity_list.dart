import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_spaces.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../model/employee_terminal_model.dart';

class RecentPunchActivityList extends StatelessWidget {
  final List<PunchRecordItem> punches;

  const RecentPunchActivityList({
    super.key,
    required this.punches,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 18.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.r),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            border: Border(
              bottom: BorderSide(
                color: AppColors.secondary,
                width: 3.w,
              ),
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row with Pulsing Live Beacon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8.r,
                        height: 8.r,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      AppSpaces.hSpace6,
                      Text(
                        'Recent Activity Log',
                        style: AppTextStyles.text14.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 2.5.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      'Live Feed',
                      style: AppTextStyles.text10.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),

              AppSpaces.vSpace12,

              if (punches.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: Center(
                    child: Text(
                      'No recent attendance punches yet.',
                      style: AppTextStyles.text12.copyWith(
                        color: AppColors.subTextColor,
                      ),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: punches.take(5).length,
                  separatorBuilder: (context, index) => Divider(
                    color: AppColors.borderColor,
                    height: 14.h,
                    thickness: 0.8.h,
                  ),
                  itemBuilder: (context, index) {
                    final punch = punches[index];
                    return _buildPunchRow(punch);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPunchRow(PunchRecordItem punch) {
    final bool isCheckIn = punch.isCheckIn;
    final Color punchColor = isCheckIn ? AppColors.success : AppColors.warning;

    return Row(
      children: [
        // Avatar circle with initials or icon
        Container(
          width: 36.r,
          height: 36.r,
          decoration: BoxDecoration(
            color: punchColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(
              color: punchColor.withValues(alpha: 0.3),
              width: 1.w,
            ),
          ),
          child: Center(
            child: Icon(
              isCheckIn ? Icons.login_rounded : Icons.logout_rounded,
              size: 16.sp,
              color: punchColor,
            ),
          ),
        ),

        AppSpaces.hSpace10,

        // Employee Name & Department
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                punch.employeeName,
                style: AppTextStyles.text12.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              AppSpaces.vSpace2,
              Text(
                '${punch.employeeId} • ${punch.department}',
                style: AppTextStyles.text10.copyWith(
                  color: AppColors.subTextColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        AppSpaces.hSpace8,

        // Punch Pill & Relative Time
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: punchColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                punch.punchType.toUpperCase(),
                style: AppTextStyles.text8.copyWith(
                  fontWeight: FontWeight.bold,
                  color: punchColor,
                  letterSpacing: 0.4,
                ),
              ),
            ),
            AppSpaces.vSpace2,
            Text(
              punch.relativeTimeString,
              style: AppTextStyles.text8.copyWith(
                color: AppColors.subTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
