import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../controller/attendance_summary_controller.dart';

class WorkingHoursSummaryCard extends GetView<AttendanceSummaryController> {
  const WorkingHoursSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final summary = controller.summary.value;
      if (summary == null) return const SizedBox.shrink();

      final data = summary.data;

      return CustomCard(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 16.sp,
                  color: AppColors.secondary,
                ),
                AppSpaces.hSpace8,
                Text(
                  'Working Hours & Target Compliance',
                  style: AppTextStyles.text14.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
            AppSpaces.vSpace14,
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    title: 'Planned Shift Time',
                    value: data.plannedHoursFormatted,
                    subtitle: '${data.plannedMinutes} Minutes Scheduled',
                    icon: Icons.flag_rounded,
                    color: AppColors.primary,
                  ),
                ),
                AppSpaces.hSpace8,
                Expanded(
                  child: _buildMetricTile(
                    title: 'Net Worked Time',
                    value: data.workedHoursFormatted,
                    subtitle: '${data.workedMinutes} Minutes Logged',
                    icon: Icons.timer_rounded,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            AppSpaces.vSpace8,
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    title: 'Counted Shift Time',
                    value: data.countedHoursFormatted,
                    subtitle: '${data.countedMinutes} Minutes Recognized',
                    icon: Icons.check_circle_outline_rounded,
                    color: AppColors.onTimeColor,
                  ),
                ),
                AppSpaces.hSpace8,
                Expanded(
                  child: _buildMetricTile(
                    title: 'Short Time Deficit',
                    value: data.shortHoursFormatted,
                    subtitle: '${data.shortMinutes} Minutes Deficit',
                    icon: Icons.timelapse_rounded,
                    color: AppColors.absentColor,
                  ),
                ),
              ],
            ),
            AppSpaces.vSpace8,
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
              decoration: BoxDecoration(
                color: AppColors.inputFill.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: AppColors.borderColor.withValues(alpha: 0.8),
                  width: 0.8.w,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.logout_rounded,
                        size: 15.sp,
                        color: data.missingCheckOuts > 0 ? AppColors.warning : AppColors.secondary,
                      ),
                      AppSpaces.hSpace8,
                      Text(
                        'Missing Check-Outs',
                        style: AppTextStyles.text12.copyWith(
                          color: AppColors.textColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: data.missingCheckOuts > 0
                          ? AppColors.warning.withValues(alpha: 0.15)
                          : AppColors.onTimeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      '${data.missingCheckOuts} Incidents',
                      style: AppTextStyles.text10.copyWith(
                        fontWeight: FontWeight.bold,
                        color: data.missingCheckOuts > 0 ? AppColors.warning : AppColors.onTimeColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.inputFill.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: AppColors.borderColor.withValues(alpha: 0.8),
          width: 0.8.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14.sp, color: color),
              AppSpaces.hSpace6,
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.text10.copyWith(
                    color: AppColors.subTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          AppSpaces.vSpace4,
          Text(
            value,
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
              fontSize: 9.sp,
            ),
          ),
        ],
      ),
    );
  }
}
