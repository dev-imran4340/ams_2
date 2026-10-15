import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_spaces.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../controller/company_dashboard_controller.dart';

class CompanySummaryStatsGrid extends GetView<CompanyDashboardController> {
  const CompanySummaryStatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final data = controller.dashboard.value;
      final total = data?.totalEmployees ?? 160;
      final present = data?.presentToday ?? 138;
      final absent = data?.absentToday ?? 14;

      return Row(
        children: [
          // 1. Employees
          Expanded(
            child: _buildStatChip(
              label: 'Employees',
              value: '$total',
              color: AppColors.primary,
              icon: Icons.groups_rounded,
            ),
          ),
          AppSpaces.hSpace8,

          // 2. Present
          Expanded(
            child: _buildStatChip(
              label: 'Present',
              value: '$present',
              color: AppColors.success,
              icon: Icons.check_circle_outline,
            ),
          ),
          AppSpaces.hSpace8,

          // 3. Absent
          Expanded(
            child: _buildStatChip(
              label: 'Absent',
              value: '$absent',
              color: AppColors.error,
              icon: Icons.cancel_outlined,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildStatChip({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1.w),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20.sp),
          AppSpaces.vSpace6,
          Text(
            value,
            style: AppTextStyles.text20.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpaces.vSpace2,
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.text12.copyWith(
              color: AppColors.subTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
