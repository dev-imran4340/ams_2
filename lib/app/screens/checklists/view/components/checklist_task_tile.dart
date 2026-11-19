import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../model/checklist_model.dart';

class ChecklistTaskTile extends StatelessWidget {
  final ChecklistTaskModel task;

  const ChecklistTaskTile({
    super.key,
    required this.task,
  });

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppColors.error;
      case 'low':
        return AppColors.subTextColor;
      case 'normal':
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDone = task.isCompleted;
    final priorityColor = _getPriorityColor(task.priority);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: isDone ? AppColors.success.withValues(alpha: 0.3) : AppColors.borderColor,
          width: 0.8.w,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Completion Checkmark Icon
          Container(
            margin: EdgeInsets.only(top: 2.h),
            width: 20.r,
            height: 20.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDone
                  ? AppColors.success.withValues(alpha: 0.15)
                  : Colors.transparent,
              border: Border.all(
                color: isDone ? AppColors.success : AppColors.borderColor,
                width: 1.5.w,
              ),
            ),
            child: isDone
                ? Icon(
                    Icons.check_rounded,
                    size: 13.sp,
                    color: AppColors.success,
                  )
                : null,
          ),
          AppSpaces.hSpace10,

          // Task details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: AppTextStyles.text12.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDone ? AppColors.subTextColor : AppColors.textColor,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                AppSpaces.vSpace4,
                Wrap(
                  spacing: 6.w,
                  runSpacing: 4.h,
                  children: [
                    if (task.assigneeName != null && task.assigneeName!.isNotEmpty)
                      _buildChip(
                        icon: Icons.person_outline_rounded,
                        label: task.assigneeName!,
                        color: AppColors.primary,
                      ),
                    if (task.dueOn != null)
                      _buildChip(
                        icon: Icons.event_outlined,
                        label: 'Due ${task.dueOn!}',
                        color: task.isOverdue ? AppColors.error : AppColors.subTextColor,
                      ),
                    _buildChip(
                      icon: Icons.flag_outlined,
                      label: task.priorityLabel,
                      color: priorityColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10.sp, color: color),
          AppSpaces.hSpace4,
          Text(
            label,
            style: AppTextStyles.text10.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
