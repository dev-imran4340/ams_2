import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../controller/schedule_controller.dart';

class ScheduleHeroSummaryCard extends StatelessWidget {
  final ScheduleController controller;

  const ScheduleHeroSummaryCard({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final nextShift = controller.nextUpcomingShift;
      final workingDays = controller.workingDaysCount;
      final totalHours = controller.totalPlannedFormatted;
      final restDays = controller.restDaysCount;
      final holidays = controller.holidaysCount;

      return CustomCard(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        borderRadius: 15.r,
        accentColor: AppColors.secondary,
        showBottomAccent: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Badge & Next Upcoming Shift Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8.r,
                      height: 8.r,
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondary.withValues(alpha: 0.4),
                            blurRadius: 6.r,
                            spreadRadius: 1.r,
                          ),
                        ],
                      ),
                    ),
                    AppSpaces.hSpace8,
                    Text(
                      'WORK SCHEDULE OVERVIEW',
                      style: AppTextStyles.text10.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.subTextColor,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                if (nextShift != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: AppColors.secondary.withValues(alpha: 0.3),
                        width: 1.w,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 12.sp,
                          color: AppColors.secondary,
                        ),
                        AppSpaces.hSpace4,
                        Text(
                          'Next: ${nextShift.dayOfWeek} ${nextShift.shift?.starts ?? ""}',
                          style: AppTextStyles.text10.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            AppSpaces.vSpace12,

            // Next Shift Title / Banner
            if (nextShift != null) ...[
              Text(
                nextShift.label.isNotEmpty
                    ? nextShift.label
                    : '${nextShift.shift?.name ?? "Scheduled Shift"} (${nextShift.shift?.timeRangeLabel ?? ""})',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.text18.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              AppSpaces.vSpace2,
              Text(
                'Pattern: ${nextShift.pattern ?? "Standard Assigned Shift"} • Source: ${nextShift.source.capitalizeFirst}',
                style: AppTextStyles.text12.copyWith(
                  color: AppColors.subTextColor,
                ),
              ),
            ] else ...[
              Text(
                'No Upcoming Shifts',
                style: AppTextStyles.text18.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              AppSpaces.vSpace2,
              Text(
                'No working shifts scheduled in the active query window.',
                style: AppTextStyles.text12.copyWith(
                  color: AppColors.subTextColor,
                ),
              ),
            ],

            AppSpaces.vSpace14,
            Container(height: 1.h, color: AppColors.borderColor),
            AppSpaces.vSpace12,

            // 4 Metrics Grid (Working Shifts, Planned Hours, Rest Days, Holidays)
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    icon: Icons.calendar_month_rounded,
                    label: 'Working Shifts',
                    value: '$workingDays Days',
                    color: AppColors.primary,
                  ),
                ),
                Container(width: 1.w, height: 32.h, color: AppColors.borderColor),
                Expanded(
                  child: _buildMetricItem(
                    icon: Icons.access_time_filled_rounded,
                    label: 'Planned Hours',
                    value: totalHours,
                    color: AppColors.secondary,
                  ),
                ),
                Container(width: 1.w, height: 32.h, color: AppColors.borderColor),
                Expanded(
                  child: _buildMetricItem(
                    icon: Icons.weekend_rounded,
                    label: 'Rest Days',
                    value: '$restDays Days',
                    color: const Color(0xFF64748B),
                  ),
                ),
                Container(width: 1.w, height: 32.h, color: AppColors.borderColor),
                Expanded(
                  child: _buildMetricItem(
                    icon: Icons.celebration_rounded,
                    label: 'Holidays',
                    value: '$holidays Days',
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMetricItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 16.sp, color: color),
        AppSpaces.vSpace4,
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.text12.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
        ),
        AppSpaces.vSpace2,
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.text10.copyWith(
            color: AppColors.subTextColor,
          ),
        ),
      ],
    );
  }
}
