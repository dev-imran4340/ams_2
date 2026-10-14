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

class MissedPunchFormCard extends GetView<RegularizationController> {
  const MissedPunchFormCard({super.key});

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
          // Header
          Row(
            children: [
              Container(
                width: 32.r,
                height: 32.r,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.fingerprint_rounded,
                  size: 17.sp,
                  color: AppColors.secondary,
                ),
              ),
              AppSpaces.hSpace10,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Missed Punch Regularization',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.text14.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                    Text(
                      'Request manual verification for unrecorded punches',
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

          // Section 1: Date & Punch Type Row
          Row(
            children: [
              // Date Selector Capsule
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Incident Date',
                      style: AppTextStyles.text10.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.subTextColor,
                      ),
                    ),
                    AppSpaces.vSpace4,
                    Obx(() {
                      final dt = controller.selectedDate.value;
                      final dateLabel = dt != null
                          ? RegularizationController.formatDate(dt)
                          : 'Select Date';

                      return InkWell(
                        onTap: () => controller.pickDate(context, false),
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
                                Icons.calendar_today_rounded,
                                size: 13.sp,
                                color: AppColors.secondary,
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

              // Punch Direction Switcher (Check-In / Check-Out)
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Punch Type',
                      style: AppTextStyles.text10.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.subTextColor,
                      ),
                    ),
                    AppSpaces.vSpace4,
                    Obx(() {
                      final isCheckIn =
                          controller.punchType.value == 'Check-In';

                      return Container(
                        padding: EdgeInsets.all(2.r),
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
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  controller.punchType.value = 'Check-In';
                                },
                                borderRadius: BorderRadius.circular(8.r),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 7.h),
                                  decoration: BoxDecoration(
                                    color: isCheckIn
                                        ? AppColors.primary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Check-In',
                                      style: AppTextStyles.text10.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: isCheckIn
                                            ? AppColors.white
                                            : AppColors.subTextColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  controller.punchType.value = 'Check-Out';
                                },
                                borderRadius: BorderRadius.circular(8.r),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 7.h),
                                  decoration: BoxDecoration(
                                    color: !isCheckIn
                                        ? AppColors.primary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Check-Out',
                                      style: AppTextStyles.text10.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: !isCheckIn
                                            ? AppColors.white
                                            : AppColors.subTextColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),

          AppSpaces.vSpace14,

          // Section 2: Correct Time Picker
          Text(
            'Actual Punch Time',
            style: AppTextStyles.text10.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.subTextColor,
            ),
          ),
          AppSpaces.vSpace4,
          Obx(() {
            final t = controller.selectedTime.value;
            final timeStr = RegularizationController.formatTime(t);

            return InkWell(
              onTap: () => controller.pickTime(context),
              borderRadius: BorderRadius.circular(10.r),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 14.sp,
                          color: AppColors.secondary,
                        ),
                        AppSpaces.hSpace8,
                        Text(
                          timeStr,
                          style: AppTextStyles.text12.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Tap to change',
                      style: AppTextStyles.text10.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          AppSpaces.vSpace14,

          // Section 3: Reason Category Chips
          Text(
            'Reason Category',
            style: AppTextStyles.text10.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.subTextColor,
            ),
          ),
          AppSpaces.vSpace6,

          Obx(() {
            final current = controller.reasonCategory.value;
            final categories = [
              'Biometric Glitch',
              'Power / Network Cut',
              'Client Meeting',
              'Other',
            ];

            return Wrap(
              spacing: 8.w,
              runSpacing: 6.h,
              children: categories.map((cat) {
                final isSelected = current == cat;

                return InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    controller.reasonCategory.value = cat;
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
                      cat,
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

          // Section 4: Remarks & Context
          Text(
            'Remarks & Justification',
            style: AppTextStyles.text10.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.subTextColor,
            ),
          ),
          AppSpaces.vSpace6,

          CustomTextField(
            hintText: 'Enter specific details for floor supervisor review...',
            controller: controller.remarksController,
            focusNode: controller.remarksFocusNode,
            maxLines: 2,
            maxLength: 150,
          ),

          AppSpaces.vSpace14,

          // Section 5: Submit CTA Button
          Obx(
            () => CustomButton(
              text: 'Submit Regularization Request',
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
