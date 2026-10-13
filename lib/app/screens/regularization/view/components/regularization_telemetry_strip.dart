import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../controller/regularization_controller.dart';

class RegularizationTelemetryStrip extends GetView<RegularizationController> {
  const RegularizationTelemetryStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final t = controller.telemetry.value;
      final otHours = t?.monthlyOvertimeHours ?? 12.5;
      final remaining = t?.adjustmentsRemaining ?? 2;
      final maxAdj = t?.maxAdjustments ?? 3;
      final pending = t?.pendingApprovalsCount ?? 1;

      return Row(
        children: [
          // Capsule 1: Accrued Overtime Hours
          Expanded(
            child: _buildTelemetryCard(
              title: 'OVERTIME',
              value: '${otHours.toStringAsFixed(1)}h',
              subtitle: 'Accrued',
              icon: Icons.more_time_rounded,
              accentColor: AppColors.warning,
            ),
          ),

          AppSpaces.hSpace8,

          // Capsule 2: Remaining Monthly Adjustments Quota
          Expanded(
            child: _buildTelemetryCard(
              title: 'QUOTA',
              value: '$remaining / $maxAdj',
              subtitle: 'Adjustments',
              icon: Icons.history_toggle_off_rounded,
              accentColor: AppColors.secondary,
            ),
          ),

          AppSpaces.hSpace8,

          // Capsule 3: Pending Managerial Reviews
          Expanded(
            child: _buildTelemetryCard(
              title: 'PENDING',
              value: pending.toString().padLeft(2, '0'),
              subtitle: 'In Review',
              icon: Icons.hourglass_top_rounded,
              accentColor: AppColors.primary,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildTelemetryCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
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
            blurRadius: 10.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26.r,
                height: 26.r,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 13.sp, color: accentColor),
              ),
              AppSpaces.hSpace4,
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.text10.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 8.sp,
                    color: AppColors.subTextColor,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
          AppSpaces.vSpace8,
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.text16.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textColor,
            ),
          ),
          AppSpaces.vSpace2,
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
    );
  }
}
