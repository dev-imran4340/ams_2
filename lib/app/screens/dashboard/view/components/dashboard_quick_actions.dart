import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../api/app_preferences.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../routes/app_routes.dart';
import '../../../index/controller/index_controller.dart';
import '../../../main_shell/controller/session_me_controller.dart';

class DashboardQuickActions extends StatelessWidget {
  const DashboardQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Get.isRegistered<SessionMeController>()
        ? Get.find<SessionMeController>()
        : null;
    final hasLeave =
        session?.hasModule('leave') ?? AppPreferences.hasModule('leave');
    final hasAttendance = session?.hasModule('attendance') ??
        AppPreferences.hasModule('attendance');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
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
                  Expanded(
                    child: Text(
                      'Quick Services',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.text16.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AppSpaces.hSpace8,
            Text(
              'Self Service',
              style: AppTextStyles.text10.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.subTextColor,
              ),
            ),
          ],
        ),

        AppSpaces.vSpace12,

        // 4 Action Buttons Row (First button: Attendance Summary)
        Row(
          children: [
            Expanded(
              child: _buildActionTile(
                icon: Icons.insights_rounded,
                title: 'Attendance\nSummary',
                color: AppColors.secondary,
                onTap: () {
                  HapticFeedback.lightImpact();
                  if (!hasAttendance) {
                    CustomSnackbar.showInfo(
                      message:
                          'Attendance module is not included in your company plan.',
                    );
                    return;
                  }
                  Get.toNamed(Routes.ATTENDANCE_SUMMARY);
                },
              ),
            ),
            AppSpaces.hSpace10,
            Expanded(
              child: _buildActionTile(
                icon: Icons.touch_app_rounded,
                title: 'Attendance\nActions',
                color: AppColors.primary,
                onTap: () {
                  HapticFeedback.lightImpact();
                  if (!hasAttendance) {
                    CustomSnackbar.showInfo(
                      message:
                          'Attendance module is not included in your company plan.',
                    );
                    return;
                  }
                  Get.toNamed(Routes.ATTENDANCE_ACTIONS);
                },
              ),
            ),
            AppSpaces.hSpace10,
            Expanded(
              child: _buildActionTile(
                icon: Icons.event_busy_rounded,
                title: 'Apply\nLeave',
                color: AppColors.warning,
                onTap: () {
                  if (!hasLeave) {
                    CustomSnackbar.showInfo(
                      message:
                          'Leave module is not included in your company plan.',
                    );
                    return;
                  }
                  if (Get.isRegistered<IndexController>()) {
                    Get.find<IndexController>().changeTab(2);
                  } else {
                    Get.toNamed(Routes.LEAVE);
                  }
                },
              ),
            ),
            AppSpaces.hSpace10,
            Expanded(
              child: _buildActionTile(
                icon: Icons.history_rounded,
                title: 'Punch\nHistory',
                color: AppColors.info,
                onTap: () {
                  if (!hasAttendance) {
                    CustomSnackbar.showInfo(
                      message:
                          'Attendance history is not enabled in your company plan.',
                    );
                    return;
                  }
                  if (Get.isRegistered<IndexController>()) {
                    Get.find<IndexController>().changeTab(1);
                  } else {
                    Get.toNamed(Routes.ATTENDANCE_HISTORY);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: AppColors.borderColor,
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14.r),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 6.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 38.r,
                  height: 38.r,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 18.sp,
                    color: color,
                  ),
                ),
                AppSpaces.vSpace8,
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.text10.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                    height: 1.2,
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
