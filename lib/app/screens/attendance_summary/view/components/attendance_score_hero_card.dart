import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../controller/attendance_summary_controller.dart';

class AttendanceScoreHeroCard extends GetView<AttendanceSummaryController> {
  const AttendanceScoreHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final summary = controller.summary.value;
      if (summary == null) return const SizedBox.shrink();

      final data = summary.data;
      final scheduled = data.scheduledDays;
      final present = data.days.present;
      final absent = data.days.absent;
      final lateCount = data.late.count;
      final rate = data.attendanceRate;

      final double presentFactor = scheduled > 0 ? (present / scheduled).clamp(0.0, 1.0) : 0.0;
      final double lateFactor = scheduled > 0 ? (lateCount / scheduled).clamp(0.0, 1.0) : 0.0;
      final double absentFactor = scheduled > 0 ? (absent / scheduled).clamp(0.0, 1.0) : 0.0;

      return CustomCard(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.12),
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
                          'Attendance Performance',
                          style: AppTextStyles.text14.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                        AppSpaces.vSpace2,
                        Text(
                          scheduled > 0
                              ? '${summary.monthLabel} • $scheduled Scheduled Days'
                              : '${summary.monthLabel} • No Schedule',
                          style: AppTextStyles.text10.copyWith(
                            color: AppColors.subTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Attendance Rate Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: AppColors.onTimeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: AppColors.onTimeColor.withValues(alpha: 0.3),
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
                        '$rate%',
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

            // Segmented Distribution Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: Container(
                height: 8.h,
                color: AppColors.borderColor.withValues(alpha: 0.3),
                child: Row(
                  children: [
                    if (presentFactor > 0)
                      Expanded(
                        flex: (presentFactor * 100).toInt().clamp(1, 100),
                        child: Container(color: AppColors.onTimeColor),
                      ),
                    if (lateFactor > 0)
                      Expanded(
                        flex: (lateFactor * 100).toInt().clamp(1, 100),
                        child: Container(color: AppColors.warning),
                      ),
                    if (absentFactor > 0)
                      Expanded(
                        flex: (absentFactor * 100).toInt().clamp(1, 100),
                        child: Container(color: AppColors.absentColor),
                      ),
                  ],
                ),
              ),
            ),

            AppSpaces.vSpace14,

            // Quick Breakdown Pills
            Row(
              children: [
                Expanded(
                  child: _buildBreakdownPill(
                    label: 'Present',
                    value: '$present Days',
                    color: AppColors.onTimeColor,
                  ),
                ),
                AppSpaces.hSpace8,
                Expanded(
                  child: _buildBreakdownPill(
                    label: 'Absent',
                    value: '$absent Days',
                    color: AppColors.absentColor,
                  ),
                ),
                AppSpaces.hSpace8,
                Expanded(
                  child: _buildBreakdownPill(
                    label: 'Off Days',
                    value: '${data.days.off} Days',
                    color: AppColors.subTextColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildBreakdownPill({
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
