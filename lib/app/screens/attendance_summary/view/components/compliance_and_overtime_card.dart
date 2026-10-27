import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../controller/attendance_summary_controller.dart';

class ComplianceAndOvertimeCard extends GetView<AttendanceSummaryController> {
  const ComplianceAndOvertimeCard({super.key});

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
                  Icons.policy_rounded,
                  size: 16.sp,
                  color: AppColors.secondary,
                ),
                AppSpaces.hSpace8,
                Text(
                  'Policy Compliance & Overtime',
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
                  child: _buildIncidentTile(
                    title: 'Late Arrivals',
                    countText: '${data.late.count} Occurrence',
                    minutesText: data.lateHoursFormatted,
                    icon: Icons.history_toggle_off_rounded,
                    color: AppColors.warning,
                  ),
                ),
                AppSpaces.hSpace8,
                Expanded(
                  child: _buildIncidentTile(
                    title: 'Early Departures',
                    countText: '${data.earlyOut.count} Occurrence',
                    minutesText: data.earlyOutHoursFormatted,
                    icon: Icons.run_circle_outlined,
                    color: AppColors.absentColor,
                  ),
                ),
              ],
            ),
            AppSpaces.vSpace10,
            Row(
              children: [
                Expanded(
                  child: _buildIncidentTile(
                    title: 'Approved Overtime',
                    countText: data.approvedOvertimeFormatted,
                    minutesText: '${data.overtime.approvedMinutes} Total Mins',
                    icon: Icons.more_time_rounded,
                    color: AppColors.onTimeColor,
                  ),
                ),
                AppSpaces.hSpace8,
                Expanded(
                  child: _buildIncidentTile(
                    title: 'Pending Overtime',
                    countText: data.pendingOvertimeFormatted,
                    minutesText: '${data.overtime.pendingMinutes} Total Mins',
                    icon: Icons.hourglass_empty_rounded,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            AppSpaces.vSpace10,
            // Penalties Banner
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
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
                        Icons.gavel_rounded,
                        size: 14.sp,
                        color: data.penalties.isNotEmpty ? AppColors.absentColor : AppColors.subTextColor,
                      ),
                      AppSpaces.hSpace8,
                      Text(
                        'HR Deductions & Penalties',
                        style: AppTextStyles.text12.copyWith(
                          color: AppColors.textColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    data.penalties.isEmpty ? '0 Penalties' : '${data.penalties.length} Logged',
                    style: AppTextStyles.text10.copyWith(
                      fontWeight: FontWeight.bold,
                      color: data.penalties.isEmpty ? AppColors.onTimeColor : AppColors.absentColor,
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

  Widget _buildIncidentTile({
    required String title,
    required String countText,
    required String minutesText,
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
            countText,
            style: AppTextStyles.text12.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          AppSpaces.vSpace2,
          Text(
            minutesText,
            style: AppTextStyles.text10.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 9.sp,
            ),
          ),
        ],
      ),
    );
  }
}
