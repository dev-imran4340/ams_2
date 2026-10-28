import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../controller/attendance_history_controller.dart';

/// Interactive Date Range & Month Filter Bar for Attendance History
/// Allows 1-tap switching between This Month, Last Month, Recent 14 Days,
/// and Custom Date Range (from/to parameters) matching GET /me/attendance?from=...&to=...
class AttendanceDateRangeBar extends GetView<AttendanceHistoryController> {
  const AttendanceDateRangeBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── 1. Active Period & Date Range Capsule ───
        Obx(() {
          final label = controller.filterLabel.value;
          final subtitle = controller.filterSubtitle.value;

          return Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: AppColors.borderColor,
                width: 1.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.04),
                  blurRadius: 8.r,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 32.r,
                  height: 32.r,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.calendar_month_rounded,
                    size: 16.sp,
                    color: AppColors.secondary,
                  ),
                ),
                AppSpaces.hSpace10,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.text12.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
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
                InkWell(
                  onTap: () => controller.pickCustomDateRange(context),
                  borderRadius: BorderRadius.circular(8.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.inputFill,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: AppColors.borderColor,
                        width: 0.8.w,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.date_range_rounded,
                          size: 12.sp,
                          color: AppColors.secondary,
                        ),
                        AppSpaces.hSpace4,
                        Text(
                          'Range',
                          style: AppTextStyles.text10.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),

        AppSpaces.vSpace8,

        // ─── 2. Quick Preset Filter Pills ───
        Obx(() {
          final active = controller.activeDateRangeFilter.value;

          final filters = [
            {
              'key': 'this_month',
              'label': 'This Month (Oct 26)',
              'icon': Icons.today_rounded
            },
            {
              'key': 'last_month',
              'label': 'Last Month (Sep 26)',
              'icon': Icons.history_rounded
            },
            {
              'key': 'last_14_days',
              'label': 'Recent 14 Days',
              'icon': Icons.timeline_rounded
            },
            {
              'key': 'custom',
              'label': 'Custom Range 📅',
              'icon': Icons.tune_rounded
            },
          ];

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: filters.map((item) {
                final key = item['key'] as String;
                final label = item['label'] as String;
                final icon = item['icon'] as IconData;
                final isSelected = active == key;

                return Padding(
                  padding: EdgeInsets.only(right: 6.w),
                  child: InkWell(
                    onTap: () {
                      if (key == 'this_month') {
                        controller.applyThisMonth();
                      } else if (key == 'last_month') {
                        controller.applyLastMonth();
                      } else if (key == 'last_14_days') {
                        controller.applyLast14Days();
                      } else if (key == 'custom') {
                        controller.pickCustomDateRange(context);
                      }
                    },
                    borderRadius: BorderRadius.circular(8.r),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.borderColor,
                          width: 1.w,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.15),
                                  blurRadius: 4.r,
                                  offset: Offset(0, 2.h),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            icon,
                            size: 11.sp,
                            color: isSelected
                                ? AppColors.white
                                : AppColors.secondary,
                          ),
                          AppSpaces.hSpace4,
                          Text(
                            label,
                            style: AppTextStyles.text10.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.white
                                  : AppColors.textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }),
      ],
    );
  }
}
