import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_card.dart';
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
    return CustomCard(
      onTap: () => controller.openTaskDetails(task),
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      accentColor: AppColors.secondary,
      accentWidth: 3.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Row: Title & Priority Pill Badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                    Text(
                      task.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.text12.copyWith(
                        color: AppColors.subTextColor,
                        height: 1.35,
                      ),
                    ),
                  ],

                  AppSpaces.vSpace12,

                  // 3. Footer Row: Checklist / Project Tag, Due Date, Status Badge
                  Row(
                    children: [
                      // Checklist / Project Badge
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

                  AppSpaces.vSpace12,
                  Divider(
                    color: AppColors.borderColor.withValues(alpha: 0.6),
                    height: 1.h,
                  ),
                  AppSpaces.vSpace10,

                  // 4. Action Button: Complete (if open) / Reopen (if completed)
                  CustomButton(
                    text: task.isCompleted ? 'Reopen' : 'Complete',
                    height: 36.h,
                    fontSize: 12.sp,
                    isGradient: !task.isCompleted,
                    isOutlined: task.isCompleted,
                    borderColor: task.isCompleted ? AppColors.warning : null,
                    textColor: task.isCompleted
                        ? AppColors.warning
                        : AppColors.white,
                    onPressed: () => controller.toggleComplete(
                      task,
                      isDone: !task.isCompleted,
                    ),
                  ),
                ],
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
