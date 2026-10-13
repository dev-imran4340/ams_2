import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';

class RecentActivityTimeline extends StatelessWidget {
  const RecentActivityTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 4.w,
                  height: 16.h,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                AppSpaces.hSpace8,
                Text(
                  "Today's Activity Log",
                  style: AppTextStyles.text16.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                'Live Log',
                style: AppTextStyles.text10.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
            ),
          ],
        ),

        AppSpaces.vSpace12,

        // Timeline Card Container
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.borderColor, width: 1.w),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 20.r,
                offset: Offset(0, 8.h),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 16.h,
                  ),
                  child: Column(
                    children: [
                      _buildTimelineItem(
                        time: '09:12 AM',
                        title: 'Shift Check-In',
                        subtitle: 'Biometric Scanner • Front Gate',
                        tag: 'Verified',
                        color: AppColors.onTimeColor,
                        isFirst: true,
                        isLast: false,
                      ),
                      _buildTimelineItem(
                        time: '01:05 PM',
                        title: 'Lunch Break Began',
                        subtitle: 'Automated Cafeteria Gate Log',
                        tag: 'Break',
                        color: AppColors.info,
                        isFirst: false,
                        isLast: false,
                      ),
                      _buildTimelineItem(
                        time: '01:50 PM',
                        title: 'Resumed Workstation',
                        subtitle: 'Office Floor 3 Beacon Ping',
                        tag: 'Active',
                        color: AppColors.secondary,
                        isFirst: false,
                        isLast: false,
                      ),
                      _buildTimelineItem(
                        time: '06:00 PM',
                        title: 'Expected Check-Out',
                        subtitle: 'Standard Shift Target Completion',
                        tag: 'Upcoming',
                        color: AppColors.subTextColor,
                        isFirst: false,
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem({
    required String time,
    required String title,
    required String subtitle,
    required String tag,
    required Color color,
    required bool isFirst,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time Stamp Column
          SizedBox(
            width: 60.w,
            child: Text(
              time,
              style: AppTextStyles.text12.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
          ),

          // Timeline Node & Vertical Connector
          Column(
            children: [
              Container(
                width: 10.r,
                height: 10.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  border: Border.all(
                    color: AppColors.cardBackground,
                    width: 2.w,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.4),
                      blurRadius: 4.r,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.5.w,
                    color: AppColors.borderColor,
                    margin: EdgeInsets.symmetric(vertical: 2.h),
                  ),
                ),
            ],
          ),

          AppSpaces.hSpace12,

          // Details & Tag
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.text12.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                        AppSpaces.vSpace2,
                        Text(
                          subtitle,
                          style: AppTextStyles.text10.copyWith(
                            color: AppColors.subTextColor,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      tag,
                      style: AppTextStyles.text10.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
