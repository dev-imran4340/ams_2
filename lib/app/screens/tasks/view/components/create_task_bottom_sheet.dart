import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../controller/task_controller.dart';

class CreateTaskBottomSheet extends GetView<TaskController> {
  const CreateTaskBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => PopScope(
        canPop: !controller.isSubmitting.value,
        child: Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        border: Border.all(
          color: AppColors.borderColor,
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 36.r,
            offset: Offset(0, -10.h),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
      child: SafeArea(
        top: false,
        child: Form(
          key: controller.createTaskFormKey,
          child: SingleChildScrollView(
            controller: controller.createModalScrollController,
            physics: const BouncingScrollPhysics(),
            child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Drag Handle
              Center(
                child: Container(
                  width: 44.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.subTextColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),

              AppSpaces.vSpace14,

              // 2. Header Row
              Row(
                children: [
                  Container(
                    width: 36.r,
                    height: 36.r,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.secondary.withValues(alpha: 0.25),
                        width: 1.w,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.add_task_rounded,
                        size: 20.sp,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                  AppSpaces.hSpace12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'New Deliverable',
                          style: AppTextStyles.text16.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                        AppSpaces.vSpace2,
                        Text(
                          'Add a daily operational milestone to your roster',
                          style: AppTextStyles.text10.copyWith(
                            color: AppColors.subTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: controller.isSubmitting.value
                        ? null
                        : () => Get.back(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: AppColors.subTextColor,
                      size: 20.sp,
                    ),
                  ),
                ],
              ),

              AppSpaces.vSpace16,

              // 3. Title Input (Validated & Keyed for Auto-Scroll)
              KeyedSubtree(
                key: controller.titleFieldKey,
                child: CustomTextField(
                  controller: controller.titleController,
                  focusNode: controller.titleFocusNode,
                  labelText: 'Deliverable Title',
                  hintText: 'e.g. Audit Weekly Attendance Regularizations',
                  prefixIcon: Icon(
                    Icons.title_rounded,
                    size: 18.sp,
                    color: AppColors.secondary,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a deliverable title';
                    }
                    if (value.trim().length > 150) {
                      return 'Title cannot exceed 150 characters';
                    }
                    return null;
                  },
                ),
              ),

              AppSpaces.vSpace12,

              // 4. Description Input
              CustomTextField(
                controller: controller.descriptionController,
                focusNode: controller.descFocusNode,
                labelText: 'Description (Optional)',
                hintText: 'Add deliverables, requirements, or dependencies...',
                maxLines: 3,
                prefixIcon: Icon(
                  Icons.notes_rounded,
                  size: 18.sp,
                  color: AppColors.secondary,
                ),
              ),

              AppSpaces.vSpace14,

              // 5. Priority & Due Date Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Priority Selection
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Priority Level',
                          style: AppTextStyles.text12.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                        AppSpaces.vSpace6,
                        Row(
                          children: ['Urgent', 'High', 'Medium', 'Low']
                              .map(
                                (p) => Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 4.w),
                                    child: Obx(() {
                                      final isSelected =
                                          controller.selectedPriority.value == p;
                                      final color = _getPriorityColor(p);

                                      return Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () => controller
                                              .selectedPriority.value = p,
                                          borderRadius:
                                              BorderRadius.circular(10.r),
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 180),
                                            padding: EdgeInsets.symmetric(
                                                vertical: 8.h),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? color
                                                  : color.withValues(
                                                      alpha: 0.08),
                                              borderRadius:
                                                  BorderRadius.circular(10.r),
                                              border: Border.all(
                                                color: isSelected
                                                    ? color
                                                    : color.withValues(
                                                        alpha: 0.25),
                                                width: 1.w,
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                p,
                                                style: AppTextStyles.text10
                                                    .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: isSelected
                                                      ? AppColors.white
                                                      : color,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),

                  AppSpaces.hSpace8,

                  // Due Date Trigger
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Target Due Date',
                          style: AppTextStyles.text12.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                        AppSpaces.vSpace6,
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => controller.pickDueDate(context),
                            borderRadius: BorderRadius.circular(10.r),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 8.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.inputFill,
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: AppColors.borderColor,
                                  width: 1.w,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.event_rounded,
                                    size: 14.sp,
                                    color: AppColors.secondary,
                                  ),
                                  AppSpaces.hSpace6,
                                  Obx(() {
                                    final d =
                                        controller.selectedDueDate.value;
                                    final dateText = d != null
                                        ? '${d.day}/${d.month}'
                                        : 'Select';
                                    return Text(
                                      dateText,
                                      style: AppTextStyles.text12.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textColor,
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              AppSpaces.vSpace20,

              // 7. Submit Action Button
              Obx(
                () => CustomButton(
                  text: 'Create Deliverable',
                  isGradient: true,
                  isLoading: controller.isSubmitting.value,
                  onPressed: controller.isSubmitting.value
                      ? null
                      : controller.submitTask,
                ),
              ),

              AppSpaces.vSpace14,

              // 8. Signature 3.w Teal Bottom Accent Line
              Center(
                child: Container(
                  width: 80.w,
                  height: 3.5.h,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),

              AppSpaces.vSpace4,
            ],
          ),
        ),
      ),
    ),
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
}
