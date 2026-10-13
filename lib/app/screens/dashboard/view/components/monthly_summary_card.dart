import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../controller/dashboard_controller.dart';

class MonthlySummaryCard extends GetView<DashboardController> {
  const MonthlySummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final summary = controller.dashboardData.value?.monthlySummary;
      final totalDays = summary?.totalDays ?? 30;
      final presentDays = summary?.presentDays ?? 21;
      final lateDays = summary?.lateDays ?? 2;
      final absentDays = summary?.absentDays ?? 0;
      final attendanceRate = summary?.attendanceRate ?? 94.5;
      final monthName = summary?.monthName ?? 'October 2026';

      final double presentFactor = totalDays > 0
          ? (presentDays / totalDays)
          : 0;
      final double lateFactor = totalDays > 0 ? (lateDays / totalDays) : 0;
      final double absentFactor = totalDays > 0 ? (absentDays / totalDays) : 0;

      return Container(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row: Month Name & Attendance Score Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.r),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Icon(
                                Icons.insights_rounded,
                                size: 18.sp,
                                color: AppColors.secondary,
                              ),
                            ),
                            AppSpaces.hSpace10,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Monthly Analytics',
                                  style: AppTextStyles.text14.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textColor,
                                  ),
                                ),
                                AppSpaces.vSpace2,
                                Text(
                                  '$monthName • Total $totalDays Days',
                                  style: AppTextStyles.text10.copyWith(
                                    color: AppColors.subTextColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Score Rate Badge
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.onTimeColor.withValues(
                              alpha: 0.12,
                            ),
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(
                              color: AppColors.onTimeColor.withValues(
                                alpha: 0.3,
                              ),
                              width: 1.w,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.trending_up_rounded,
                                size: 14.sp,
                                color: AppColors.onTimeColor,
                              ),
                              AppSpaces.hSpace4,
                              Text(
                                '$attendanceRate%',
                                style: AppTextStyles.text12.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onTimeColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    AppSpaces.vSpace16,

                    // Segmented Visual Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6.r),
                      child: SizedBox(
                        height: 8.h,
                        child: Row(
                          children: [
                            if (presentFactor > 0)
                              Expanded(
                                flex: (presentFactor * 100).toInt(),
                                child: Container(color: AppColors.onTimeColor),
                              ),
                            if (lateFactor > 0)
                              Expanded(
                                flex: (lateFactor * 100).toInt(),
                                child: Container(color: AppColors.lateColor),
                              ),
                            if (absentFactor > 0)
                              Expanded(
                                flex: (absentFactor * 100).toInt(),
                                child: Container(color: AppColors.absentColor),
                              ),
                          ],
                        ),
                      ),
                    ),

                    AppSpaces.vSpace16,

                    // Breakdown Stats Row in Modern Pill Chips
                    Row(
                      children: [
                        Expanded(
                          child: _buildBreakdownBox(
                            label: 'Present',
                            value: '$presentDays Days',
                            color: AppColors.onTimeColor,
                          ),
                        ),
                        AppSpaces.hSpace8,
                        Expanded(
                          child: _buildBreakdownBox(
                            label: 'Late',
                            value: '$lateDays Days',
                            color: AppColors.lateColor,
                          ),
                        ),
                        AppSpaces.hSpace8,
                        Expanded(
                          child: _buildBreakdownBox(
                            label: 'Absent',
                            value: '$absentDays Days',
                            color: AppColors.absentColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Bottom Signature Teal Accent Border
            ],
          ),
        ),
      );
    });
  }

  Widget _buildBreakdownBox({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.inputFill.withValues(alpha: 0.5),
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
              Container(
                width: 6.r,
                height: 6.r,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
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
            style: AppTextStyles.text12.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
        ],
      ),
    );
  }
}
