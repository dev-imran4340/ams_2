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
      final totalHours = today?.workingHours ?? '00h 00m';
      final overtime = today?.overtime ?? '+00h 00m';
      final status = today?.status ?? 'On Time';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Check-In',
                  value: checkIn,
                  subtitle: 'Std: 09:00 AM',
                  tag: status,
                  tagColor: AppColors.onTimeColor,
                  icon: Icons.login_rounded,
                  accentColor: AppColors.onTimeColor,
                ),
              ),
              AppSpaces.hSpace12,
              Expanded(
                child: _buildStatCard(
                  title: 'Check-Out',
                  value: checkOut,
                  subtitle: 'Exp: 06:00 PM',
                  tag: checkOut == '--:--' ? 'Pending' : 'Completed',
                  tagColor: checkOut == '--:--'
                      ? AppColors.subTextColor
                      : AppColors.info,
                  icon: Icons.logout_rounded,
                  accentColor: AppColors.info,
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
                  subtitle: 'Target: 09h 00m',
                  tag: 'Standard',
                  tagColor: AppColors.secondary,
                  icon: Icons.timelapse_rounded,
                  accentColor: AppColors.secondary,
                ),
              ),
              AppSpaces.hSpace12,
              Expanded(
                child: _buildStatCard(
                  title: 'Overtime',
                  value: overtime,
                  subtitle: 'Rate: 1.5x Std',
                  tag: 'Approved',
                  tagColor: AppColors.warning,
                  icon: Icons.more_time_rounded,
                  accentColor: AppColors.warning,
                ),
              ),
            ],
          ),
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
