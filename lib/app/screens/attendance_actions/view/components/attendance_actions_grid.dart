import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../controller/attendance_actions_controller.dart';

class AttendanceActionsGrid extends GetView<AttendanceActionsController> {
  const AttendanceActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final t = controller.telemetry.value;
      final isCheckedIn = t?.isCheckedIn ?? false;
      final isOnBreak = t?.isOnBreak ?? false;
      final checkInTime = t?.checkInTime ?? '--:--';
      final checkOutTime = t?.checkOutTime ?? '--:--';
      final isPunching = controller.isPunching.value;
      final isBreakLoading = controller.isBreakActionLoading.value;

      final canCheckIn = !isCheckedIn;
      final canCheckOut = isCheckedIn && !isOnBreak;
      final canStartBreak = isCheckedIn && !isOnBreak;
      final canEndBreak = isCheckedIn && isOnBreak;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 4.w,
                    height: 16.h,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  AppSpaces.hSpace8,
                  Text(
                    'Attendance Actions',
                    style: AppTextStyles.text16.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: AppColors.liteSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'Daily Punch & Recess',
                  style: AppTextStyles.text10.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),

          AppSpaces.vSpace12,

          // 2x2 Modern Executive Tiles
          Row(
            children: [
              // 1. Check-In Tile
              Expanded(
                child: _buildActionTile(
                  icon: Icons.login_rounded,
                  title: 'Check In',
                  subtitle: isCheckedIn ? 'Logged $checkInTime' : 'Ready to Start',
                  badgeText: isCheckedIn ? 'Active' : null,
                  badgeColor: AppColors.onTimeColor,
                  accentColor: AppColors.onTimeColor,
                  bgColor: AppColors.onTimeColor.withValues(alpha: 0.1),
                  isEnabled: canCheckIn && !isPunching,
                  isLoading: isPunching && canCheckIn,
                  onTap: controller.handleCheckIn,
                ),
              ),

              AppSpaces.hSpace12,

              // 2. Check-Out Tile
              Expanded(
                child: _buildActionTile(
                  icon: Icons.logout_rounded,
                  title: 'Check Out',
                  subtitle: !isCheckedIn && checkOutTime != '--:--'
                      ? 'Departed $checkOutTime'
                      : (canCheckOut ? 'End Daily Shift' : 'Unavailable'),
                  badgeText: !isCheckedIn && checkOutTime != '--:--'
                      ? 'Concluded'
                      : null,
                  badgeColor: AppColors.absentColor,
                  accentColor: AppColors.absentColor,
                  bgColor: AppColors.absentColor.withValues(alpha: 0.1),
                  isEnabled: canCheckOut && !isPunching,
                  isLoading: isPunching && canCheckOut,
                  onTap: controller.handleCheckOut,
                ),
              ),
            ],
          ),

          AppSpaces.vSpace12,

          Row(
            children: [
              // 3. Start Break Tile
              Expanded(
                child: _buildActionTile(
                  icon: Icons.coffee_rounded,
                  title: 'Start Break',
                  subtitle: isOnBreak
                      ? 'Break in Progress'
                      : (canStartBreak ? 'Take 45m Recess' : 'Requires Check-In'),
                  badgeText: isOnBreak ? 'Ongoing' : null,
                  badgeColor: AppColors.warning,
                  accentColor: AppColors.warning,
                  bgColor: AppColors.warning.withValues(alpha: 0.1),
                  isEnabled: canStartBreak && !isBreakLoading,
                  isLoading: isBreakLoading && canStartBreak,
                  onTap: controller.handleStartBreak,
                ),
              ),

              AppSpaces.hSpace12,

              // 4. End Break Tile
              Expanded(
                child: _buildActionTile(
                  icon: Icons.work_history_rounded,
                  title: 'End Break',
                  subtitle: canEndBreak
                      ? 'Resume Working'
                      : (isOnBreak ? 'Tap to Conclude' : 'Not on Break'),
                  badgeText: canEndBreak ? 'Ready' : null,
                  badgeColor: AppColors.info,
                  accentColor: AppColors.info,
                  bgColor: AppColors.info.withValues(alpha: 0.1),
                  isEnabled: canEndBreak && !isBreakLoading,
                  isLoading: isBreakLoading && canEndBreak,
                  onTap: controller.handleEndBreak,
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accentColor,
    required Color bgColor,
    required bool isEnabled,
    required bool isLoading,
    required VoidCallback onTap,
    String? badgeText,
    Color? badgeColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isEnabled
            ? AppColors.cardBackground
            : AppColors.inputFill.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isEnabled
              ? accentColor.withValues(alpha: 0.35)
              : AppColors.borderColor,
          width: 1.w,
        ),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.08),
                  blurRadius: 16.r,
                  offset: Offset(0, 6.h),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          onTap: isEnabled && !isLoading ? onTap : null,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Icon Container & Optional Badge / Loader
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 42.r,
                      height: 42.r,
                      decoration: BoxDecoration(
                        color: isEnabled
                            ? bgColor
                            : AppColors.borderColor.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        icon,
                        size: 22.sp,
                        color: isEnabled ? accentColor : AppColors.subTextColor,
                      ),
                    ),
                    if (isLoading)
                      SizedBox(
                        width: 18.r,
                        height: 18.r,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.w,
                          color: accentColor,
                        ),
                      )
                    else if (badgeText != null)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: (badgeColor ?? accentColor).withValues(
                            alpha: 0.12,
                          ),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          badgeText,
                          style: AppTextStyles.text10.copyWith(
                            fontWeight: FontWeight.bold,
                            color: badgeColor ?? accentColor,
                          ),
                        ),
                      ),
                  ],
                ),

                AppSpaces.vSpace12,

                // Title
                Text(
                  title,
                  style: AppTextStyles.text14.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isEnabled
                        ? AppColors.textColor
                        : AppColors.subTextColor,
                  ),
                ),

                AppSpaces.vSpace2,

                // Subtitle / Timestamps
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.text10.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isEnabled
                        ? AppColors.subTextColor
                        : AppColors.hintColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
