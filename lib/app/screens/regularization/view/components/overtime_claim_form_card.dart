import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../controller/regularization_controller.dart';

class OvertimeClaimFormCard extends GetView<RegularizationController> {
  const OvertimeClaimFormCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
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
            blurRadius: 14.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Row(
            children: [
              Container(
                width: 32.r,
                height: 32.r,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.more_time_rounded,
                  size: 17.sp,
                  color: AppColors.warning,
                ),
              ),
              AppSpaces.hSpace10,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overtime Claim Submission',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.text14.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                    Text(
                      'Claim approved compensation for extended shift hours',
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

          AppSpaces.vSpace16,

          // Section 1: OT Date & Duration Stepper Row
          Row(
            children: [
              // Date Selection Capsule
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overtime Date',
                      style: AppTextStyles.text10.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.subTextColor,
                      ),
                    ),
                    AppSpaces.vSpace4,
                    Obx(() {
                      final dt = controller.otDate.value;
                      final dateLabel = dt != null
                          ? RegularizationController.formatDate(dt)
                          : 'Select Date';

                      return InkWell(
                        onTap: () => controller.pickDate(context, true),
                        borderRadius: BorderRadius.circular(10.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 9.h,
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
                            children: [
                              Icon(
                                Icons.event_available_rounded,
                                size: 13.sp,
                                color: AppColors.warning,
                              ),
                              AppSpaces.hSpace6,
                              Expanded(
                                child: Text(
                                  dateLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.text12.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              AppSpaces.hSpace10,

              // Duration Stepper Counter
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Claimed Duration',
                      style: AppTextStyles.text10.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.subTextColor,
                      ),
                    ),
                    AppSpaces.vSpace4,
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 3.h,
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Decrement Button
                          InkWell(
                            onTap: controller.decrementHours,
                            borderRadius: BorderRadius.circular(6.r),
                            child: Container(
                              width: 28.r,
                              height: 28.r,
                              decoration: BoxDecoration(
                                color: AppColors.cardBackground,
                                borderRadius: BorderRadius.circular(6.r),
                                border: Border.all(
                                  color: AppColors.borderColor,
                                  width: 0.8.w,
                                ),
                              ),
                              child: Icon(
                                Icons.remove_rounded,
                                size: 14.sp,
                                color: AppColors.textColor,
                              ),
                            ),
                          ),

                          // Hours Value
                          Obx(
                            () => Text(
                              '${controller.overtimeHours.value.toStringAsFixed(1)} hrs',
                              style: AppTextStyles.text12.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                            ),
                          ),

                          // Increment Button
                          InkWell(
                            onTap: controller.incrementHours,
                            borderRadius: BorderRadius.circular(6.r),
                            child: Container(
                              width: 28.r,
                              height: 28.r,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Icon(
                                Icons.add_rounded,
                                size: 14.sp,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          AppSpaces.vSpace14,

          // Section 2: Project / Initiative Category Chips
          Text(
            'Project / Delivery Tag',
            style: AppTextStyles.text10.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.subTextColor,
            ),
          ),
          AppSpaces.vSpace6,

          Obx(() {
            final current = controller.projectTag.value;
            final projects = [
              'Mobile App Release',
              'Sprint Deliverables',
              'Infrastructure Migration',
              'Client Support',
            ];

            return Wrap(
              spacing: 8.w,
              runSpacing: 6.h,
              children: projects.map((prj) {
                final isSelected = current == prj;

                return InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    controller.projectTag.value = prj;
                  },
                  borderRadius: BorderRadius.circular(8.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.inputFill,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.borderColor,
                        width: 0.8.w,
                      ),
                    ),
                    child: Text(
                      prj,
                      style: AppTextStyles.text10.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? AppColors.white
                            : AppColors.textColor,
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }),

          AppSpaces.vSpace14,

          // Section 3: Deliverables Justification Text Field
          Text(
            'Deliverables & Work Summary',
            style: AppTextStyles.text10.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.subTextColor,
            ),
          ),
          AppSpaces.vSpace6,

          CustomTextField(
            hintText: 'Briefly state tasks completed during extended hours...',
            controller: controller.remarksController,
            focusNode: controller.remarksFocusNode,
            maxLines: 2,
            maxLength: 150,
          ),

          AppSpaces.vSpace14,

          // Section 4: Submit CTA Button
          Obx(
            () => CustomButton(
              text: 'Submit Overtime Claim',
              isLoading: controller.isSubmitting.value,
              onPressed: controller.isSubmitting.value
                  ? null
                  : () => controller.submitForm(context),
              icon: Icon(
                Icons.send_rounded,
                size: 15.sp,
                color: AppColors.white,
              ),
              backgroundColor: AppColors.primary,
              height: 48.h,
              borderRadius: 12.r,
            ),
          ),
        ],
      ),
    );
  }
}
