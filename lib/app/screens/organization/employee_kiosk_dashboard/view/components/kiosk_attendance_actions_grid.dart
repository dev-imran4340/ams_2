import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_spaces.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../controller/kiosk_employee_controller.dart';

class KioskAttendanceActionsGrid extends GetView<KioskEmployeeController> {
  const KioskAttendanceActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(
          color: AppColors.borderColor.withValues(alpha: 0.8),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 24.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32.r,
                height: 32.r,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: Icon(
                    Icons.touch_app_rounded,
                    size: 18.sp,
                    color: AppColors.primary,
                  ),
                ),
              ),
              AppSpaces.hSpace8,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Direct Kiosk Punch',
                    style: AppTextStyles.text14.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  Text(
                    'Touch an action to register shift telemetry',
                    style: AppTextStyles.text10.copyWith(
                      color: AppColors.subTextColor,
                    ),
                  ),
                ],
              ),
            ],
          ),

          AppSpaces.vSpace16,

          // 2x2 Punch Action Buttons
          Row(
            children: [
              // 1. Check In
              Expanded(
                child: _buildActionButton(
                  title: 'Shift Check-In',
                  subtitle: 'Arrival Stamp',
                  icon: Icons.login_rounded,
                  color: AppColors.success,
                  onTap: () => controller.punchAction('Check-In'),
                ),
              ),
              AppSpaces.hSpace10,

              // 2. Check Out
              Expanded(
                child: _buildActionButton(
                  title: 'Shift Check-Out',
                  subtitle: 'Closing Duty',
                  icon: Icons.logout_rounded,
                  color: AppColors.error,
                  onTap: () => controller.punchAction('Check-Out'),
                ),
              ),
            ],
          ),

          AppSpaces.vSpace10,

          Row(
            children: [
              // 3. Start Break
              Expanded(
                child: _buildActionButton(
                  title: 'Start Lunch Break',
                  subtitle: 'Meal Interval',
                  icon: Icons.lunch_dining_rounded,
                  color: AppColors.warning,
                  onTap: () => controller.punchAction('Start Break'),
                ),
              ),
              AppSpaces.hSpace10,

              // 4. Resume Duty
              Expanded(
                child: _buildActionButton(
                  title: 'End Break',
                  subtitle: 'Resume Shift',
                  icon: Icons.play_arrow_rounded,
                  color: AppColors.secondary,
                  onTap: () => controller.punchAction('End Break'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: color.withValues(alpha: 0.25),
            width: 1.w,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32.r,
              height: 32.r,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Center(
                child: Icon(icon, size: 18.sp, color: AppColors.white),
              ),
            ),
            AppSpaces.vSpace8,
            Text(
              title,
              style: AppTextStyles.text12.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            Text(
              subtitle,
              style: AppTextStyles.text10.copyWith(
                color: AppColors.subTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
