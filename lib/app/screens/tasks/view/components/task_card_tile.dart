import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../controller/task_controller.dart';
import '../../model/task_model.dart';

class TaskCardTile extends GetView<TaskController> {
  final TaskModel task;

  const TaskCardTile({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = _getPriorityColor(task.priority);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.borderColor,
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 16.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Header Row: Checkbox, Title & Priority Badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Animated Checkbox Circle
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => controller.toggleComplete(task),
                          borderRadius: BorderRadius.circular(12.r),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 24.r,
                            height: 24.r,
                            decoration: BoxDecoration(
                              color: task.isCompleted
                                  ? AppColors.success
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: task.isCompleted
                                    ? AppColors.success
                                    : AppColors.subTextColor
                                        .withValues(alpha: 0.5),
                                width: 2.w,
                              ),
                            ),
                            child: task.isCompleted
                                ? Icon(
                                    Icons.check_rounded,
                                    size: 15.sp,
                                    color: AppColors.white,
                                  )
                                : null,
                          ),
                        ),
                      ),

                      AppSpaces.hSpace10,

                      // Task Title
                      Expanded(
                        child: Text(
                          task.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.text14.copyWith(
                            fontWeight: FontWeight.bold,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: task.isCompleted
                                ? AppColors.subTextColor
                                : AppColors.textColor,
                          ),
                        ),
                      ),

                      AppSpaces.hSpace8,

                      // Priority Pill Badge
                      _buildPriorityPill(task.priority),
                    ],
                  ),

                  // 2. Body: Description
                  if (task.description.isNotEmpty) ...[
                    AppSpaces.vSpace8,
                    Padding(
                      padding: EdgeInsets.only(left: 34.w),
                      child: Text(
                        task.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.text12.copyWith(
                          color: AppColors.subTextColor,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],

                  AppSpaces.vSpace12,

                  // 3. Footer Row: Project Tag, Due Date, Status Avatar
                  Padding(
                    padding: EdgeInsets.only(left: 34.w),
                    child: Row(
                      children: [
                        // Project Badge
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            task.projectTag,
                            style: AppTextStyles.text10.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),

                        AppSpaces.hSpace8,

                        // Due Date Pill
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 11.sp,
                              color: AppColors.subTextColor,
                            ),
                            AppSpaces.hSpace4,
                            Text(
                              _formatDueDate(task.dueDate),
                              style: AppTextStyles.text10.copyWith(
                                color: AppColors.subTextColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        // Status Badge
                        _buildStatusBadge(task.status, task.isCompleted),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 4. Signature Bottom Accent Strip (3.h)
            Container(
              height: 3.h,
              color: task.isCompleted ? AppColors.success : accentColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityPill(String priority) {
    final color = _getPriorityColor(priority);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 0.8.w,
        ),
      ),
      child: Text(
        priority,
        style: AppTextStyles.text10.copyWith(
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, bool isCompleted) {
    Color color = AppColors.subTextColor;
    String label = status;

    if (isCompleted || status == 'Completed') {
      color = AppColors.success;
      label = 'Completed';
    } else if (status == 'In Progress') {
      color = AppColors.secondary;
      label = 'In Progress';
    } else {
      color = AppColors.subTextColor;
      label = 'To Do';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: AppTextStyles.text10.copyWith(
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return AppColors.error;
      case 'high':
        return AppColors.warning;
      case 'medium':
        return AppColors.info;
      case 'low':
      default:
        return AppColors.subTextColor;
    }
  }

  String _formatDueDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}
