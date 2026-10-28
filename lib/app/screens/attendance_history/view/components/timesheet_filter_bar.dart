import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../controller/attendance_history_controller.dart';

class TimesheetFilterBar extends GetView<AttendanceHistoryController> {
  const TimesheetFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentFilter = controller.selectedFilter.value;

      final filters = [
        _FilterItem('all', 'All', controller.totalRecordsCount, AppColors.primary),
        _FilterItem('present', 'Present', controller.presentCount, AppColors.onTimeColor),
        _FilterItem('late', 'Late', controller.lateCount, AppColors.lateColor),
        _FilterItem('absent', 'Absent', controller.absentCount, AppColors.absentColor),
        _FilterItem('off', 'Day Off', controller.offCount, AppColors.subTextColor),
      ];

      return SizedBox(
        height: 38.h,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: filters.length,
          separatorBuilder: (context, index) => AppSpaces.hSpace8,
          itemBuilder: (context, index) {
            final item = filters[index];
            final isSelected = currentFilter == item.key;

            return InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                controller.setFilter(item.key);
              },
              borderRadius: BorderRadius.circular(20.r),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.borderColor,
                    width: 1.w,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.18),
                            blurRadius: 8.r,
                            offset: Offset(0, 3.h),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.label,
                      style: AppTextStyles.text12.copyWith(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? AppColors.white : AppColors.textColor,
                      ),
                    ),
                    AppSpaces.hSpace6,
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.white.withValues(alpha: 0.22)
                            : item.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        '${item.count}',
                        style: AppTextStyles.text10.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppColors.white : item.color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }
}

class _FilterItem {
  final String key;
  final String label;
  final int count;
  final Color color;

  const _FilterItem(this.key, this.label, this.count, this.color);
}
