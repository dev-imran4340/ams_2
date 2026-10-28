import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../controller/attendance_history_controller.dart';

class TimesheetMetricOverviewCard extends GetView<AttendanceHistoryController> {
  const TimesheetMetricOverviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final meta = controller.timesheetResponse.value?.meta;
      final fromStr = meta?.from ?? 'Recent';
      final toStr = meta?.to ?? 'Today';
      final totalRecords = controller.totalRecordsCount;
      final presentCount = controller.presentCount;
      final lateCount = controller.lateCount;
      final workedFormatted = controller.totalWorkedFormatted;

      final compliancePercent = totalRecords > 0
          ? ((presentCount / totalRecords) * 100).toStringAsFixed(0)
          : '0';

      return CustomCard(
        accentColor: AppColors.secondary,
        margin: EdgeInsets.zero,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Date Range & Active Employee Tag
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6.r),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.date_range_rounded,
                        color: AppColors.secondary,
                        size: 16.sp,
                      ),
                    ),
                    AppSpaces.hSpace8,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Verified Timesheet Period',
                          style: AppTextStyles.text10.copyWith(
                            color: AppColors.subTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        AppSpaces.vSpace2,
                        Text(
                          '$fromStr — $toStr',
                          style: AppTextStyles.text12.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.onTimeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: AppColors.onTimeColor.withValues(alpha: 0.25),
                      width: 0.8.w,
                    ),
                  ),
                  child: Text(
                    '$compliancePercent% Attendance Rate',
                    style: AppTextStyles.text10.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.onTimeColor,
                    ),
                  ),
                ),
              ],
            ),

            AppSpaces.vSpace14,

            // 3-Metric Executive Banner
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: AppColors.litePrimary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.litePrimary.withValues(alpha: 0.3),
                  width: 0.8.w,
                ),
              ),
              child: Row(
                children: [
                  // 1. Total Worked Time
                  Expanded(
                    child: _buildMetricTile(
                      label: 'Total Worked',
                      value: workedFormatted,
                      icon: Icons.timer_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  Container(
                    width: 1.w,
                    height: 32.h,
                    color: AppColors.borderColor,
                  ),

                  // 2. Present Days
                  Expanded(
                    child: _buildMetricTile(
                      label: 'Present Days',
                      value: '$presentCount Days',
                      icon: Icons.check_circle_outline_rounded,
                      color: AppColors.onTimeColor,
                    ),
                  ),
                  Container(
                    width: 1.w,
                    height: 32.h,
                    color: AppColors.borderColor,
                  ),

                  // 3. Late Occurrences
                  Expanded(
                    child: _buildMetricTile(
                      label: 'Late Incidents',
                      value: '$lateCount',
                      icon: Icons.warning_amber_rounded,
                      color: AppColors.lateColor,
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
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 13.sp),
            AppSpaces.hSpace4,
            Text(
              label,
              style: AppTextStyles.text10.copyWith(
                color: AppColors.subTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        AppSpaces.vSpace4,
        Text(
          value,
          style: AppTextStyles.text14.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
