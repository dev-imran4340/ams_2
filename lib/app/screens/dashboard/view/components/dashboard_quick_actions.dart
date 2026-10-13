import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../routes/app_routes.dart';
import '../../../index/controller/index_controller.dart';

class DashboardQuickActions extends StatelessWidget {
  const DashboardQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
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
                  'Quick Services',
                  style: AppTextStyles.text16.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
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

        // 4 Action Buttons Row
        Row(
          children: [
            Expanded(
              child: _buildActionTile(
                icon: Icons.event_busy_rounded,
                title: 'Apply\nLeave',
                color: AppColors.secondary,
                onTap: () {
                  if (Get.isRegistered<IndexController>()) {
                    Get.find<IndexController>().changeTab(2);
                  } else {
                    CustomSnackbar.showInfo(
                      message: 'Leave Request portal is opening soon.',
                    );
                  }
                },
              ),
            ),
            AppSpaces.hSpace10,
            Expanded(
              child: _buildActionTile(
                icon: Icons.history_rounded,
                title: 'Punch\nHistory',
                color: AppColors.primary,
                onTap: () {
                  if (Get.isRegistered<IndexController>()) {
                    Get.find<IndexController>().changeTab(1);
                  } else {
                    Get.toNamed(Routes.ATTENDANCE_HISTORY);
                  }
                },
              ),
            ),
            AppSpaces.hSpace10,
            Expanded(
              child: _buildActionTile(
                icon: Icons.more_time_rounded,
                title: 'Overtime\nClaim',
                color: AppColors.warning,
                onTap: () {
                  Get.toNamed(
                    Routes.REGULARIZATION,
                    arguments: {'segmentIndex': 1},
                  );
                },
              ),
            ),
            AppSpaces.hSpace10,
            Expanded(
              child: _buildActionTile(
                icon: Icons.calendar_month_rounded,
                title: 'Shift\nRoster',
                color: AppColors.info,
                onTap: () {
                  CustomSnackbar.showInfo(
                    message: 'Shift Schedule & Rosters view.',
                  );
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
