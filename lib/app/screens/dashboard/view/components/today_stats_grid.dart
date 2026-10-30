import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../controller/dashboard_controller.dart';

class TodayStatsGrid extends GetView<DashboardController> {
  const TodayStatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final today = controller.dashboardData.value?.todayAttendance;
      final checkIn = today?.checkInTime ?? '--:--';
      final checkOut = today?.checkOutTime ?? '--:--';
      final latestOut = today?.latestCheckOutTime;
      final latestIn = today?.latestCheckInTime;
      final totalHours = today?.workingHours ?? '0h 00m';
      final overtime = today?.overtime ?? '0:00';
      final isCheckedIn = today?.isCheckedIn ?? false;
      final isCheckedOut = (checkOut != '--:--');

      final targetSubtitle = (today != null && today.plannedMinutes > 0)
          ? 'Target: ${(today.plannedMinutes ~/ 60)}h ${(today.plannedMinutes % 60).toString().padLeft(2, '0')}m'
          : 'Target: Standard';

      final isOvertimeActive = (overtime != '0:00' && overtime != '+00h 00m' && overtime != '00:00');

      // Check-In card values
      final bool hasMultipleIns = (latestIn != null && latestIn != checkIn && checkIn != '--:--');
      final String checkInSubtitle = checkIn == '--:--'
          ? 'Not Checked In'
          : (hasMultipleIns
              ? 'First: $checkIn • Active: $latestIn'
              : 'Started: $checkIn');
      final String checkInTag = checkIn == '--:--'
          ? 'Pending'
          : (isCheckedIn ? 'Active' : 'Logged');

      // Check-Out card values
      final bool hasPriorOut = (!isCheckedOut && latestOut != null && latestOut != '--:--');
      final String checkOutDisplayVal = isCheckedOut
          ? checkOut
          : (hasPriorOut ? latestOut : '--:--');
      final String checkOutSubtitle = isCheckedOut
          ? 'Ended: $checkOut'
          : (hasPriorOut
              ? (isCheckedIn ? 'Last Out: $latestOut (Active)' : 'Last Out: $latestOut')
              : (isCheckedIn ? 'In Progress' : 'Pending'));
      final String checkOutTag = isCheckedOut
          ? 'Completed'
          : (hasPriorOut
              ? (isCheckedIn ? 'Re-entered' : 'Logged')
              : (isCheckedIn ? 'Running' : 'Pending'));
      final Color checkOutTagColor = isCheckedOut
          ? AppColors.info
          : (hasPriorOut
              ? (isCheckedIn ? AppColors.secondary : AppColors.info)
              : (isCheckedIn ? AppColors.secondary : AppColors.subTextColor));
      final Color checkOutAccentColor = isCheckedOut
          ? AppColors.info
          : (hasPriorOut
              ? (isCheckedIn ? AppColors.secondary : AppColors.info)
              : AppColors.secondary);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Check-In',
                  value: checkIn,
                  subtitle: checkInSubtitle,
                  tag: checkInTag,
                  tagColor: checkIn == '--:--'
                      ? AppColors.subTextColor
                      : AppColors.onTimeColor,
                  icon: Icons.login_rounded,
                  accentColor: checkIn == '--:--'
                      ? AppColors.subTextColor
                      : AppColors.onTimeColor,
                ),
              ),
              AppSpaces.hSpace12,
              Expanded(
                child: _buildStatCard(
                  title: 'Check-Out',
                  value: checkOutDisplayVal,
                  subtitle: checkOutSubtitle,
                  tag: checkOutTag,
                  tagColor: checkOutTagColor,
                  icon: Icons.logout_rounded,
                  accentColor: checkOutAccentColor,
                ),
              ),
            ],
          ),
          AppSpaces.vSpace12,
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Working Hours',
                  value: totalHours,
                  subtitle: isCheckedIn
                      ? 'Live Shift Time'
                      : (isCheckedOut ? 'Total Logged' : targetSubtitle),
                  tag: isCheckedIn
                      ? 'Active'
                      : (isCheckedOut ? 'Completed' : 'Standard'),
                  tagColor: isCheckedIn
                      ? AppColors.onTimeColor
                      : (isCheckedOut ? AppColors.info : AppColors.secondary),
                  icon: Icons.timelapse_rounded,
                  accentColor: isCheckedIn ? AppColors.onTimeColor : AppColors.secondary,
                ),
              ),
              AppSpaces.hSpace12,
              Expanded(
                child: _buildStatCard(
                  title: 'Overtime',
                  value: overtime,
                  subtitle: 'Approved & Pending',
                  tag: isOvertimeActive ? 'Logged' : 'None',
                  tagColor: isOvertimeActive ? AppColors.warning : AppColors.subTextColor,
                  icon: Icons.more_time_rounded,
                  accentColor: AppColors.warning,
                ),
              ),
            ],
          ),
          AppSpaces.vSpace12,
          Builder(builder: (context) {
            final int lateMin = today?.lateMinutes ?? 0;
            final int shortMin = today?.shortMinutes ?? 0;
            final int earlyOutMin = today?.earlyOutMinutes ?? 0;
            String complianceVal = 'On Track';
            String complianceSub = 'No Penalties';
            String complianceTag = 'Compliant';
            Color complianceColor = AppColors.onTimeColor;

            if (lateMin > 0) {
              complianceVal = '${lateMin}m Late';
              complianceSub = earlyOutMin > 0 ? '${earlyOutMin}m Early Exit' : 'Late Arrival';
              complianceTag = 'Late';
              complianceColor = AppColors.warning;
            } else if (shortMin > 0) {
              complianceVal = '${shortMin}m Short';
              complianceSub = 'Shift Incomplete';
              complianceTag = 'Short';
              complianceColor = AppColors.absentColor;
            }

            final bool isOnBreak = today?.isOnBreak ?? false;
            final int breakMin = today?.breakMinutes ?? 0;

            return Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Breaks Logged',
                    value: '${breakMin}m',
                    subtitle: isOnBreak
                        ? 'Currently On Break'
                        : (today?.usesBreaks == true ? 'Breaks Allowed' : 'Disabled'),
                    tag: isOnBreak ? 'On Break' : (breakMin > 0 ? 'Logged' : 'None'),
                    tagColor: isOnBreak ? AppColors.warning : AppColors.secondary,
                    icon: Icons.coffee_rounded,
                    accentColor: isOnBreak ? AppColors.warning : AppColors.secondary,
                  ),
                ),
                AppSpaces.hSpace12,
                Expanded(
                  child: _buildStatCard(
                    title: 'Compliance',
                    value: complianceVal,
                    subtitle: complianceSub,
                    tag: complianceTag,
                    tagColor: complianceColor,
                    icon: Icons.verified_user_rounded,
                    accentColor: complianceColor,
                  ),
                ),
              ],
            );
          }),
        ],
      );
    });
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required String tag,
    required Color tagColor,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(
          color: AppColors.borderColor,
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 16.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row with Icon and Status Tag
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 36.r,
                        height: 36.r,
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, size: 18.sp, color: accentColor),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: tagColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: tagColor.withValues(alpha: 0.25),
                            width: 0.8.w,
                          ),
                        ),
                        child: Text(
                          tag,
                          style: AppTextStyles.text10.copyWith(
                            color: tagColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  AppSpaces.vSpace12,
                  Text(
                    title,
                    style: AppTextStyles.text12.copyWith(
                      color: AppColors.subTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  AppSpaces.vSpace4,
                  Text(
                    value,
                    style: AppTextStyles.text18.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  AppSpaces.vSpace4,
                  Text(
                    subtitle,
                    style: AppTextStyles.text10.copyWith(
                      color: AppColors.subTextColor.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
