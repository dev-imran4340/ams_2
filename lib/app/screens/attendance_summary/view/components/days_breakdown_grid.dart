import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../controller/attendance_summary_controller.dart';

class DaysBreakdownGrid extends GetView<AttendanceSummaryController> {
  const DaysBreakdownGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final summary = controller.summary.value;
      if (summary == null) return const SizedBox.shrink();

      final days = summary.data.days;

      final categories = [
        _DayCategory(
          label: 'Present',
          count: days.present,
          icon: Icons.check_circle_rounded,
          color: AppColors.onTimeColor,
        ),
        _DayCategory(
          label: 'Absent',
          count: days.absent,
          icon: Icons.cancel_rounded,
          color: AppColors.absentColor,
        ),
        _DayCategory(
          label: 'Off Days',
          count: days.off,
          icon: Icons.weekend_rounded,
          color: AppColors.subTextColor,
        ),
        _DayCategory(
          label: 'Upcoming',
          count: days.upcoming,
          icon: Icons.event_rounded,
          color: AppColors.secondary,
        ),
        _DayCategory(
          label: 'Half Day',
          count: days.halfDay,
          icon: Icons.timelapse_rounded,
          color: AppColors.warning,
        ),
        _DayCategory(
          label: 'In Progress',
          count: days.inProgress,
          icon: Icons.hourglass_top_rounded,
          color: AppColors.info,
        ),
        _DayCategory(
          label: 'Incomplete',
          count: days.incomplete,
          icon: Icons.warning_amber_rounded,
          color: AppColors.warning,
        ),
        _DayCategory(
          label: 'Holiday',
          count: days.holiday,
          icon: Icons.celebration_rounded,
          color: AppColors.secondary,
        ),
        _DayCategory(
          label: 'Leave',
          count: days.leave,
          icon: Icons.flight_takeoff_rounded,
          color: AppColors.info,
        ),
        _DayCategory(
          label: 'Not Employed',
          count: days.notEmployed,
          icon: Icons.person_off_rounded,
          color: AppColors.subTextColor,
        ),
      ];

      return CustomCard(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_month_rounded,
                  size: 16.sp,
                  color: AppColors.secondary,
                ),
                AppSpaces.hSpace8,
                Text(
                  'Days Breakdown',
                  style: AppTextStyles.text14.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
            AppSpaces.vSpace14,
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8.h,
                crossAxisSpacing: 8.w,
                childAspectRatio: 2.5,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.inputFill.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: cat.count > 0
                          ? cat.color.withValues(alpha: 0.3)
                          : AppColors.borderColor.withValues(alpha: 0.6),
                      width: 0.8.w,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(5.r),
                        decoration: BoxDecoration(
                          color: cat.color.withValues(
                            alpha: cat.count > 0 ? 0.15 : 0.08,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(cat.icon, size: 14.sp, color: cat.color),
                      ),
                      AppSpaces.hSpace8,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              cat.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.text10.copyWith(
                                color: AppColors.subTextColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            AppSpaces.vSpace2,
                            Text(
                              '${cat.count} Days',
                              style: AppTextStyles.text12.copyWith(
                                fontWeight: FontWeight.bold,
                                color: cat.count > 0
                                    ? AppColors.textColor
                                    : AppColors.subTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      );
    });
  }
}

class _DayCategory {
  final String label;
  final int count;
  final IconData icon;
  final Color color;

  const _DayCategory({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
  });
}
