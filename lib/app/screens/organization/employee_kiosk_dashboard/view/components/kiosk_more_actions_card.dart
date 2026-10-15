import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_spaces.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../controller/kiosk_employee_controller.dart';

class KioskMoreActionsCard extends GetView<KioskEmployeeController> {
  const KioskMoreActionsCard({super.key});

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
                    Icons.apps_rounded,
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
                    'Self-Service Actions',
                    style: AppTextStyles.text14.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  Text(
                    'HR services, leaves, reviews & employee ID',
                    style: AppTextStyles.text10.copyWith(
                      color: AppColors.subTextColor,
                    ),
                  ),
                ],
              ),
            ],
          ),

          AppSpaces.vSpace14,

          // 2x2 Grid for Self-Service Actions
          Row(
            children: [
              Expanded(
                child: _buildTile(
                  title: 'Leave Request',
                  subtitle: 'Apply PTO / Vacation',
                  icon: Icons.beach_access_rounded,
                  color: AppColors.secondary,
                  onTap: controller.openLeaveRequest,
                ),
              ),
              AppSpaces.hSpace10,
              Expanded(
                child: _buildTile(
                  title: 'Performance',
                  subtitle: 'KPI Review & Rating',
                  icon: Icons.assessment_rounded,
                  color: AppColors.blue,
                  onTap: controller.openEvaluations,
                ),
              ),
            ],
          ),

          AppSpaces.vSpace10,

          Row(
            children: [
              Expanded(
                child: _buildTile(
                  title: 'Digital ID Card',
                  subtitle: 'QR & Barcode Badge',
                  icon: Icons.badge_rounded,
                  color: AppColors.warning,
                  onTap: controller.openEmployeeCard,
                ),
              ),
              AppSpaces.hSpace10,
              Expanded(
                child: _buildTile(
                  title: 'Daily Tasks',
                  subtitle: 'Assigned Work List',
                  icon: Icons.task_alt_rounded,
                  color: AppColors.success,
                  onTap: controller.openTasks,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.borderColor, width: 1.w),
        ),
        child: Row(
          children: [
            Container(
              width: 30.r,
              height: 30.r,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Center(
                child: Icon(icon, size: 16.sp, color: color),
              ),
            ),
            AppSpaces.hSpace8,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.text12.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.text10.copyWith(
                      color: AppColors.subTextColor,
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
