import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../controller/leave_controller.dart';

class ApplyLeaveBottomSheet extends GetView<LeaveController> {
  const ApplyLeaveBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
        border: Border.all(
          color: AppColors.borderColor,
          width: 1.w,
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppSpaces.vSpace10,

            // Drag handle pill
            Container(
              width: 42.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.borderColor,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),

            AppSpaces.vSpace12,

            // Header Row: Title & Close Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Apply for Leave',
                        style: AppTextStyles.text18.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                      AppSpaces.vSpace2,
                      Text(
                        'Submit request for supervisor approval',
                        style: AppTextStyles.text10.copyWith(
                          color: AppColors.subTextColor,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(20.r),
                    child: Container(
                      padding: EdgeInsets.all(6.r),
                      decoration: BoxDecoration(
                        color: AppColors.inputFill,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.borderColor,
                          width: 1.w,
                        ),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 16.sp,
                        color: AppColors.subTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Divider(color: AppColors.borderColor, height: 24.h),

            // Scrollable Form Body
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Leave Category Selection
                    Text(
                      'Leave Type',
                      style: AppTextStyles.text12.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                    AppSpaces.vSpace8,

                    Obx(() {
                      final selected = controller.selectedLeaveType.value;
                      final categories = [
                        'Casual Leave',
                        'Annual Leave',
                        'Medical / Sick',
                      ];

                      return Row(
                        children: categories.map((cat) {
                          final isCurrent = selected == cat;
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: cat != categories.last ? 8.w : 0,
                              ),
                              child: InkWell(
                                onTap: () =>
                                    controller.selectedLeaveType.value = cat,
                                borderRadius: BorderRadius.circular(12.r),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 10.h),
                                  decoration: BoxDecoration(
                                    color: isCurrent
                                        ? AppColors.primary
                                        : AppColors.inputFill,
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: isCurrent
                                          ? AppColors.primary
                                          : AppColors.borderColor,
                                      width: 1.w,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      cat,
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.text12.copyWith(
                                        fontWeight: isCurrent
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: isCurrent
                                            ? AppColors.white
                                            : AppColors.textColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    }),

                    AppSpaces.vSpace16,

                    // Section 2: Date Range Picker Cards
                    Text(
                      'Duration & Date Range',
                      style: AppTextStyles.text12.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                    AppSpaces.vSpace8,

                    Obx(() {
                      final start = controller.startDate.value;
                      final end = controller.endDate.value;
                      final days = controller.calculatedDays;

                      return Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: AppColors.inputFill,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: AppColors.borderColor,
                            width: 1.w,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Start Date Capsule
                            Expanded(
                              child: InkWell(
                                onTap: () => controller.pickStartDate(context),
                                borderRadius: BorderRadius.circular(10.r),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 8.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.cardBackground,
                                    borderRadius: BorderRadius.circular(10.r),
                                    border: Border.all(
                                      color: AppColors.borderColor,
                                      width: 1.w,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'From',
                                        style: AppTextStyles.text10.copyWith(
                                          color: AppColors.subTextColor,
                                        ),
                                      ),
                                      AppSpaces.vSpace2,
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today_rounded,
                                            size: 13.sp,
                                            color: AppColors.secondary,
                                          ),
                                          AppSpaces.hSpace4,
                                          Expanded(
                                            child: Text(
                                              start != null
                                                  ? LeaveController.formatDate(start)
                                                  : 'Select',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  AppTextStyles.text12.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Days Count Badge in the Middle
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.w),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(
                                    color: AppColors.secondary
                                        .withValues(alpha: 0.3),
                                    width: 1.w,
                                  ),
                                ),
                                child: Text(
                                  '$days ${days == 1 ? 'Day' : 'Days'}',
                                  style: AppTextStyles.text10.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ),
                            ),

                            // End Date Capsule
                            Expanded(
                              child: InkWell(
                                onTap: () => controller.pickEndDate(context),
                                borderRadius: BorderRadius.circular(10.r),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 8.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.cardBackground,
                                    borderRadius: BorderRadius.circular(10.r),
                                    border: Border.all(
                                      color: AppColors.borderColor,
                                      width: 1.w,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'To',
                                        style: AppTextStyles.text10.copyWith(
                                          color: AppColors.subTextColor,
                                        ),
                                      ),
                                      AppSpaces.vSpace2,
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.event_available_rounded,
                                            size: 13.sp,
                                            color: AppColors.primary,
                                          ),
                                          AppSpaces.hSpace4,
                                          Expanded(
                                            child: Text(
                                              end != null
                                                  ? LeaveController.formatDate(end)
                                                  : 'Select',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  AppTextStyles.text12.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    AppSpaces.vSpace16,

                    // Section 3: Reason Text Field
                    Text(
                      'Reason & Justification',
                      style: AppTextStyles.text12.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                    AppSpaces.vSpace8,

                    CustomTextField(
                      hintText:
                          'Provide a concise explanation for your leave request...',
                      controller: controller.reasonController,
                      focusNode: controller.reasonFocusNode,
                      maxLines: 3,
                      maxLength: 200,
                      keyboardType: TextInputType.multiline,
                    ),

                    AppSpaces.vSpace12,

                    // Section 4: Supporting Document Tile
                    Text(
                      'Supporting Document (Optional)',
                      style: AppTextStyles.text12.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                    AppSpaces.vSpace8,

                    Obx(() {
                      final file = controller.selectedAttachment.value;
                      final isAttached = file != null;

                      return InkWell(
                        onTap: controller.toggleAttachment,
                        borderRadius: BorderRadius.circular(12.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 10.h,
                          ),
                          decoration: BoxDecoration(
                            color: isAttached
                                ? AppColors.secondary.withValues(alpha: 0.08)
                                : AppColors.inputFill,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: isAttached
                                  ? AppColors.secondary
                                  : AppColors.borderColor,
                              width: 1.w,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 34.r,
                                height: 34.r,
                                decoration: BoxDecoration(
                                  color: (isAttached
                                          ? AppColors.secondary
                                          : AppColors.subTextColor)
                                      .withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isAttached
                                      ? Icons.picture_as_pdf_rounded
                                      : Icons.attach_file_rounded,
                                  size: 16.sp,
                                  color: isAttached
                                      ? AppColors.secondary
                                      : AppColors.subTextColor,
                                ),
                              ),
                              AppSpaces.hSpace10,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isAttached
                                          ? file
                                          : 'Attach Medical Slip / PDF Document',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.text12.copyWith(
                                        fontWeight: isAttached
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: isAttached
                                            ? AppColors.secondary
                                            : AppColors.textColor,
                                      ),
                                    ),
                                    AppSpaces.vSpace2,
                                    Text(
                                      isAttached
                                          ? 'Tap to remove attachment'
                                          : 'PDF, PNG or JPG up to 5MB',
                                      style: AppTextStyles.text10.copyWith(
                                        color: AppColors.subTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                isAttached
                                    ? Icons.cancel_rounded
                                    : Icons.add_circle_outline_rounded,
                                size: 18.sp,
                                color: isAttached
                                    ? AppColors.error
                                    : AppColors.subTextColor,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    AppSpaces.vSpace20,

                    // Submit CTA Button
                    Obx(
                      () => CustomButton(
                        text: 'Submit Leave Request',
                        isLoading: controller.isSubmitting.value,
                        onPressed: () => controller.applyLeave(context),
                        icon: Icon(
                          Icons.send_rounded,
                          size: 16.sp,
                          color: AppColors.white,
                        ),
                        backgroundColor: AppColors.primary,
                        height: 48.h,
                        borderRadius: 14.r,
                      ),
                    ),

                    AppSpaces.vSpace16,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
