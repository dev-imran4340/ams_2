import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../controller/task_controller.dart';
import '../../model/task_model.dart';

/// Modal bottom sheet presenting full task audit details, checklist linkages, and metadata.
/// Strictly connected to GET /tasks/{id}, POST /tasks/{id}/complete, and POST /tasks/{id}/reopen.
class TaskDetailsBottomSheet extends GetView<TaskController> {
  final TaskModel initialTask;

  const TaskDetailsBottomSheet({super.key, required this.initialTask});

  static void show(BuildContext context, {required TaskModel task}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TaskDetailsBottomSheet(initialTask: task),
    );
  }

  Color _resolvePriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
      case 'high':
        return AppColors.error;
      case 'medium':
      case 'normal':
        return AppColors.warning;
      case 'low':
      default:
        return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentTask = controller.selectedTask.value ?? initialTask;
      final isDetailsLoading = controller.isDetailsLoading.value;
      final priorityColor = _resolvePriorityColor(currentTask.priority);

      return Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          children: [
            // 1. Drag Handle
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 10.h, bottom: 8.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.borderColor,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),

            // 2. Header: Title 'Task Details' & Close Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                children: [
                  Container(
                    width: 32.r,
                    height: 32.r,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.assignment_outlined,
                        size: 18.sp,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                  AppSpaces.hSpace10,
                  Text(
                    'Task Details',
                    style: AppTextStyles.text16.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  const Spacer(),
                  if (isDetailsLoading) ...[
                    SizedBox(
                      width: 16.r,
                      height: 16.r,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.w,
                        color: AppColors.secondary,
                      ),
                    ),
                    AppSpaces.hSpace8,
                  ],
                  IconButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Get.back();
                    },
                    icon: Icon(
                      Icons.close_rounded,
                      color: AppColors.subTextColor,
                      size: 20.sp,
                    ),
                  ),
                ],
              ),
            ),

            Divider(
              color: AppColors.borderColor.withValues(alpha: 0.6),
              height: 1.h,
            ),

            // 3. Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Task Title
                    Text(
                      currentTask.title,
                      style: AppTextStyles.text18.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                        decoration: currentTask.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),

                    AppSpaces.vSpace8,

                    // Badges Row: Priority, Overdue, Status
                    Row(
                      children: [
                        // Priority Pill
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: priorityColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(
                              color: priorityColor.withValues(alpha: 0.4),
                              width: 0.8.w,
                            ),
                          ),
                          child: Text(
                            currentTask.priorityLabel.toUpperCase(),
                            style: AppTextStyles.text10.copyWith(
                              color: priorityColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                        if (currentTask.isOverdue &&
                            !currentTask.isCompleted) ...[
                          AppSpaces.hSpace6,
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6.r),
                              border: Border.all(
                                color: AppColors.error.withValues(alpha: 0.4),
                                width: 0.8.w,
                              ),
                            ),
                            child: Text(
                              'OVERDUE',
                              style: AppTextStyles.text10.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],

                        AppSpaces.hSpace6,

                        // Status Badge
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: currentTask.isCompleted
                                ? AppColors.success.withValues(alpha: 0.12)
                                : AppColors.secondary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            currentTask.statusLabel,
                            style: AppTextStyles.text10.copyWith(
                              color: currentTask.isCompleted
                                  ? AppColors.success
                                  : AppColors.secondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    AppSpaces.vSpace14,

                    // Overview Card (Signature 3.w Teal Accent)
                    CustomCard(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 14.h,
                      ),
                      child: Column(
                        children: [
                          if (currentTask.dueOn != null) ...[
                            _buildMetaRow(
                              icon: Icons.calendar_today_rounded,
                              label: 'Due Date',
                              value: currentTask.dueOn!,
                            ),
                            AppSpaces.vSpace10,
                          ],
                          if (currentTask.assignee != null) ...[
                            _buildMetaRow(
                              icon: Icons.person_outline_rounded,
                              label: 'Assigned To',
                              value: currentTask.assignee!.name,
                            ),
                            AppSpaces.vSpace10,
                          ],
                          if (currentTask.createdBy != null) ...[
                            _buildMetaRow(
                              icon: Icons.create_outlined,
                              label: 'Created By',
                              value: currentTask.createdBy!.name,
                            ),
                            AppSpaces.vSpace10,
                          ],
                          if (currentTask.checklist != null) ...[
                            _buildMetaRow(
                              icon: Icons.checklist_rounded,
                              label: 'Checklist',
                              value: currentTask.checklist!.name,
                            ),
                            AppSpaces.vSpace10,
                          ],
                          if (currentTask.linked != null) ...[
                            _buildMetaRow(
                              icon: Icons.link_rounded,
                              label: 'Automated Fact',
                              value: currentTask.linked!,
                            ),
                            AppSpaces.vSpace10,
                          ],
                          _buildMetaRow(
                            icon: Icons.timelapse_rounded,
                            label: 'Status',
                            value: currentTask.statusLabel,
                          ),
                        ],
                      ),
                    ),

                    // Description Section
                    if (currentTask.description.isNotEmpty) ...[
                      AppSpaces.vSpace14,
                      Text(
                        'Description',
                        style: AppTextStyles.text14.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textColor,
                        ),
                      ),
                      AppSpaces.vSpace8,
                      CustomCard(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 14.h,
                        ),
                        child: Text(
                          currentTask.description,
                          style: AppTextStyles.text12.copyWith(
                            color: AppColors.textColor,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],

                    // Completion Note if finished
                    if (currentTask.completionNote != null &&
                        currentTask.completionNote!.isNotEmpty) ...[
                      AppSpaces.vSpace14,
                      Text(
                        'Completion Note',
                        style: AppTextStyles.text14.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textColor,
                        ),
                      ),
                      AppSpaces.vSpace8,
                      CustomCard(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 14.h,
                        ),
                        child: Text(
                          currentTask.completionNote!,
                          style: AppTextStyles.text12.copyWith(
                            color: AppColors.textColor,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],

                    // Files & Attachments Section
                    if (currentTask.files.isNotEmpty) ...[
                      AppSpaces.vSpace14,
                      Text(
                        'Attachments (${currentTask.files.length})',
                        style: AppTextStyles.text14.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textColor,
                        ),
                      ),
                      AppSpaces.vSpace8,
                      ...currentTask.files.map((file) {
                        return Container(
                          margin: EdgeInsets.only(bottom: 8.h),
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 10.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: AppColors.borderColor,
                              width: 0.8.w,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.attach_file_rounded,
                                size: 16.w,
                                color: AppColors.secondary,
                              ),
                              AppSpaces.hSpace8,
                              Expanded(
                                child: Text(
                                  file.name,
                                  style: AppTextStyles.text12.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (file.size.isNotEmpty)
                                Text(
                                  file.size,
                                  style: AppTextStyles.text10.copyWith(
                                    color: AppColors.subTextColor,
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),
                    ],

                    // Discussion Comments (Read-only list if available from API)
                    if (currentTask.comments.isNotEmpty) ...[
                      AppSpaces.vSpace14,
                      Text(
                        'Activity Notes (${currentTask.comments.length})',
                        style: AppTextStyles.text14.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textColor,
                        ),
                      ),
                      AppSpaces.vSpace8,
                      ...currentTask.comments.map((comment) {
                        return Container(
                          margin: EdgeInsets.only(bottom: 8.h),
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 10.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: AppColors.borderColor,
                              width: 0.8.w,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    comment.author?.name ?? 'User',
                                    style: AppTextStyles.text12.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textColor,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    comment.createdAt,
                                    style: AppTextStyles.text10.copyWith(
                                      color: AppColors.subTextColor,
                                    ),
                                  ),
                                ],
                              ),
                              AppSpaces.vSpace4,
                              Text(
                                comment.body,
                                style: AppTextStyles.text12.copyWith(
                                  color: AppColors.textColor,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],

                    AppSpaces.vSpace16,
                  ],
                ),
              ),
            ),

            // 4. Action Buttons Footer: Cancel & Complete
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                border: Border(
                  top: BorderSide(color: AppColors.borderColor, width: 0.8.w),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Close',
                        isOutlined: true,
                        borderColor: AppColors.borderColor,
                        textColor: AppColors.subTextColor,
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Get.back();
                        },
                      ),
                    ),
                    AppSpaces.hSpace12,
                    Expanded(
                      child: CustomButton(
                        text: currentTask.isCompleted ? 'Reopen' : 'Complete',
                        isGradient: !currentTask.isCompleted,
                        backgroundColor: currentTask.isCompleted
                            ? AppColors.warning
                            : null,
                        textColor: AppColors.white,
                        onPressed: () async {
                          final targetState = !currentTask.isCompleted;
                          Get.back();
                          await controller.toggleComplete(
                            currentTask,
                            isDone: targetState,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMetaRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14.w, color: AppColors.secondary),
        AppSpaces.hSpace8,
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.text10.copyWith(
              color: AppColors.subTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        Flexible(
          child: Text(
            value,
            style: AppTextStyles.text12.copyWith(
              color: AppColors.textColor,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.start,
          ),
        ),
      ],
    );
  }
}
