import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../controller/attendance_history_controller.dart';

class AttendanceTelemetryStrip extends GetView<AttendanceHistoryController> {
  const AttendanceTelemetryStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final summary = controller.summary.value;
      final present = summary?.presentCount ?? 0;
      final lateCount = summary?.lateCount ?? 0;
      final absent = summary?.absentCount ?? 0;
      final leaves = summary?.leaveCount ?? 0;

      return Row(
        children: [
          Expanded(
            child: _buildTelemetryCard(
              label: 'Present',
              value: '$present',
              color: AppColors.onTimeColor,
            ),
          ),
          AppSpaces.hSpace8,
          Expanded(
            child: _buildTelemetryCard(
              label: 'Late',
              value: '$lateCount',
              color: AppColors.warning,
            ),
          ),
          AppSpaces.hSpace8,
          Expanded(
            child: _buildTelemetryCard(
              label: 'Absent',
              value: '$absent',
              color: AppColors.absentColor,
            ),
          ),
          AppSpaces.hSpace8,
          Expanded(
            child: _buildTelemetryCard(
              label: 'Leave',
              value: '$leaves',
              color: AppColors.info,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildTelemetryCard({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
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
            blurRadius: 10.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 6.r,
                height: 6.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
              ),
              AppSpaces.hSpace4,
              Text(
                label,
                style: AppTextStyles.text10.copyWith(
                  color: AppColors.subTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          AppSpaces.vSpace4,
          Text(
            value,
            style: AppTextStyles.text16.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
        ],
      ),
    );
  }
}
