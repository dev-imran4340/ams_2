import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../controller/task_controller.dart';

class TaskTelemetryStrip extends GetView<TaskController> {
  const TaskTelemetryStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.borderColor,
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 16.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Obx(() {
        final telemetry = controller.telemetry.value;
        final total = telemetry?.totalTasks ?? controller.tasks.length;
        final pending = telemetry?.pendingCount ?? 0;
        final inProgress = telemetry?.inProgressCount ?? 0;
        final completed = telemetry?.completedCount ?? 0;

        return Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                icon: Icons.assignment_outlined,
                label: 'Total',
                count: total,
                accentColor: AppColors.primary,
                filterTag: 'All',
              ),
            ),
            _buildDivider(),
            Expanded(
              child: _buildMetricTile(
                icon: Icons.pending_actions_rounded,
                label: 'To-Do',
                count: pending,
                accentColor: AppColors.secondary,
                filterTag: 'To Do',
              ),
            ),
            _buildDivider(),
            Expanded(
              child: _buildMetricTile(
                icon: Icons.sync_rounded,
                label: 'Active',
                count: inProgress,
                accentColor: AppColors.warning,
                filterTag: 'In Progress',
              ),
            ),
            _buildDivider(),
            Expanded(
              child: _buildMetricTile(
                icon: Icons.check_circle_outline_rounded,
                label: 'Done',
                count: completed,
                accentColor: AppColors.success,
                filterTag: 'Completed',
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required String label,
    required int count,
    required Color accentColor,
    required String filterTag,
  }) {
    return Obx(() {
      final isSelected = controller.selectedFilter.value == filterTag;

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.setFilter(filterTag),
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 4.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? accentColor.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 13.sp,
                      color: accentColor,
                    ),
                    AppSpaces.hSpace4,
                    Text(
                      '$count',
                      style: AppTextStyles.text16.copyWith(
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
                AppSpaces.vSpace2,
                Text(
                  label,
                  style: AppTextStyles.text10.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? accentColor : AppColors.subTextColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildDivider() {
    return Container(
      width: 1.w,
      height: 28.h,
      color: AppColors.borderColor,
    );
  }
}
