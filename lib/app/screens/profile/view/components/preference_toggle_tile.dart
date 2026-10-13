import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../controller/profile_controller.dart';

class PreferenceToggleHub extends GetView<ProfileController> {
  const PreferenceToggleHub({super.key});

  @override
  Widget build(BuildContext context) {
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
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 12.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            child: Row(
              children: [
                Container(
                  width: 32.r,
                  height: 32.r,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    size: 17.sp,
                    color: AppColors.secondary,
                  ),
                ),
                AppSpaces.hSpace10,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Workplace Preferences',
                      style: AppTextStyles.text14.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                    Text(
                      'Biometric security & automated telemetry',
                      style: AppTextStyles.text10.copyWith(
                        color: AppColors.subTextColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Divider(
            color: AppColors.borderColor,
            height: 1.h,
            thickness: 0.8.h,
          ),

          // Tile 1: Biometric Quick Punch
          Obx(
            () => _buildSwitchTile(
              icon: Icons.fingerprint_rounded,
              iconColor: AppColors.secondary,
              title: 'Biometric Quick Punch',
              subtitle: 'Allow instant attendance logging via Face ID / Touch ID',
              value: controller.biometricPunch.value,
              onChanged: controller.toggleBiometric,
            ),
          ),

          Divider(
            color: AppColors.borderColor.withValues(alpha: 0.6),
            height: 1.h,
            indent: 52.w,
          ),

          // Tile 2: Shift Reminders
          Obx(
            () => _buildSwitchTile(
              icon: Icons.notifications_active_rounded,
              iconColor: AppColors.warning,
              title: 'Shift Start/End Alerts',
              subtitle: 'Send 15-minute advance alerts before punch window',
              value: controller.shiftReminders.value,
              onChanged: controller.toggleReminders,
            ),
          ),

          Divider(
            color: AppColors.borderColor.withValues(alpha: 0.6),
            height: 1.h,
            indent: 52.w,
          ),

          // Tile 3: Geofence Auto-Detection
          Obx(
            () => _buildSwitchTile(
              icon: Icons.radar_rounded,
              iconColor: AppColors.primary,
              title: 'Office Geofence Beacon',
              subtitle: 'Validate premises beacon automatically upon arrival',
              value: controller.geofenceAutoCheck.value,
              onChanged: controller.toggleGeofence,
            ),
          ),

          Divider(
            color: AppColors.borderColor.withValues(alpha: 0.6),
            height: 1.h,
            indent: 52.w,
          ),

          // Tile 4: Official Company Holidays (Navigation)
          _buildActionTile(
            icon: Icons.calendar_month_rounded,
            iconColor: AppColors.info,
            title: 'Official Company Holidays',
            subtitle: '14 gazetted holidays scheduled for year 2026',
            onTap: () {
              HapticFeedback.lightImpact();
              CustomSnackbar.showSuccess(
                title: 'Holidays Schedule',
                message: 'Viewing 2026 gazetted corporate holidays calendar.',
              );
            },
          ),

          Divider(
            color: AppColors.borderColor.withValues(alpha: 0.6),
            height: 1.h,
            indent: 52.w,
          ),

          // Tile 5: Workplace Policy & Guidelines
          _buildActionTile(
            icon: Icons.verified_user_outlined,
            iconColor: AppColors.textColor,
            title: 'AMS Workplace Policy',
            subtitle: 'Attendance grace rules, leave quotas & telemetry terms',
            onTap: () {
              HapticFeedback.lightImpact();
              CustomSnackbar.showSuccess(
                title: 'Attendance Policy',
                message: 'Version 2.4 corporate attendance handbook verified.',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      child: Row(
        children: [
          Container(
            width: 32.r,
            height: 32.r,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, size: 16.sp, color: iconColor),
          ),
          AppSpaces.hSpace12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.text12.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                AppSpaces.vSpace2,
                Text(
                  subtitle,
                  style: AppTextStyles.text10.copyWith(
                    color: AppColors.subTextColor,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          AppSpaces.hSpace8,
          Transform.scale(
            scale: 0.82,
            child: Switch.adaptive(
              value: value,
              activeThumbColor: AppColors.secondary,
              activeTrackColor: AppColors.secondary.withValues(alpha: 0.35),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
        child: Row(
          children: [
            Container(
              width: 32.r,
              height: 32.r,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, size: 16.sp, color: iconColor),
            ),
            AppSpaces.hSpace12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.text12.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  AppSpaces.vSpace2,
                  Text(
                    subtitle,
                    style: AppTextStyles.text10.copyWith(
                      color: AppColors.subTextColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20.sp,
              color: AppColors.subTextColor,
            ),
          ],
        ),
      ),
    );
  }
}
