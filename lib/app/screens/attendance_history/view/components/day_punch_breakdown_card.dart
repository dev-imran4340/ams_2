import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../controller/attendance_history_controller.dart';

class DayPunchBreakdownCard extends GetView<AttendanceHistoryController> {
  const DayPunchBreakdownCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final log = controller.selectedDayLog.value;

      if (log == null) {
        return const SizedBox.shrink();
      }

      Color statusColor;
      switch (log.status) {
        case 'On-Time':
          statusColor = AppColors.onTimeColor;
          break;
        case 'Late':
          statusColor = AppColors.warning;
          break;
        case 'Absent':
          statusColor = AppColors.absentColor;
          break;
        case 'Leave':
          statusColor = AppColors.info;
          break;
        case 'Holiday':
          statusColor = AppColors.subTextColor;
          break;
        default:
          statusColor = AppColors.subTextColor;
      }

      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.borderColor,
            width: 1.w,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.06),
              blurRadius: 18.r,
              offset: Offset(0, 6.h),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Date info & Status badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(7.r),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.event_available_rounded,
                        size: 16.sp,
                        color: AppColors.secondary,
                      ),
                    ),
                    AppSpaces.hSpace8,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          log.formattedDate,
                          style: AppTextStyles.text14.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                        AppSpaces.vSpace2,
                        Text(
                          '${log.dayName} • Scheduled Shift 09:00 AM - 06:00 PM',
                          style: AppTextStyles.text10.copyWith(
                            color: AppColors.subTextColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Status Capsule Pill
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.3),
                      width: 1.w,
                    ),
                  ),
                  child: Text(
                    log.status,
                    style: AppTextStyles.text10.copyWith(
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),

            AppSpaces.vSpace14,

            // 4-Tile Telemetry Grid
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    title: 'First In',
                    value: log.checkInTime,
                    icon: Icons.login_rounded,
                    accentColor: AppColors.onTimeColor,
                  ),
                ),
                AppSpaces.hSpace8,
                Expanded(
                  child: _buildMetricTile(
                    title: 'Last Out',
                    value: log.checkOutTime,
                    icon: Icons.logout_rounded,
                    accentColor: AppColors.info,
                  ),
                ),
              ],
            ),
            AppSpaces.vSpace8,
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    title: 'Net Working',
                    value: log.workingHours,
                    icon: Icons.timer_rounded,
                    accentColor: AppColors.secondary,
                  ),
                ),
                AppSpaces.hSpace8,
                Expanded(
                  child: _buildMetricTile(
                    title: 'Break Taken',
                    value: log.breakDuration,
                    icon: Icons.coffee_rounded,
                    accentColor: AppColors.warning,
                  ),
                ),
              ],
            ),

            AppSpaces.vSpace12,

            // Divider
            Divider(
              color: AppColors.borderColor,
              thickness: 1.h,
              height: 1.h,
            ),

            AppSpaces.vSpace10,

            // Bottom Location & Cloud Sync Verification Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 6.r,
                      height: 6.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.onTimeColor,
                      ),
                    ),
                    AppSpaces.hSpace6,
                    Text(
                      '${log.workLocation} • Geofence Verified (25m)',
                      style: AppTextStyles.text10.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.textColor,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.cloud_done_rounded,
                      size: 13.sp,
                      color: AppColors.secondary,
                    ),
                    AppSpaces.hSpace4,
                    Text(
                      'Synced',
                      style: AppTextStyles.text10.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required IconData icon,
    required Color accentColor,
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
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(5.r),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 14.sp, color: accentColor),
          ),
          AppSpaces.hSpace8,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.text10.copyWith(
                  color: AppColors.subTextColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
              AppSpaces.vSpace2,
              Text(
                value,
                style: AppTextStyles.text12.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
