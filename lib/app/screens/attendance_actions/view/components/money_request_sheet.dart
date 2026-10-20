import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../controller/attendance_actions_controller.dart';

class MoneyRequestSheet extends GetView<AttendanceActionsController> {
  const MoneyRequestSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 12.h,
        left: 16.w,
        right: 16.w,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 30.r,
            offset: Offset(0, -10.h),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle Bar
            Center(
              child: Container(
                width: 44.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.borderColor,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),

            AppSpaces.vSpace14,

            // Header Title Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Request Money / Loan',
                      style: AppTextStyles.text18.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                    AppSpaces.vSpace2,
                    Text(
                      'Corporate Advance & Financial Assistance',
                      style: AppTextStyles.text10.copyWith(
                        color: AppColors.subTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(
                    Icons.close_rounded,
                    color: AppColors.subTextColor,
                    size: 22.sp,
                  ),
                ),
              ],
            ),

            AppSpaces.vSpace16,

            // 1. Select Request Type Pills
            Text(
              'Select Request Category',
              style: AppTextStyles.text12.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),

            AppSpaces.vSpace8,

            Obx(() {
              final selected = controller.selectedMoneyType.value;
              return Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: controller.moneyTypeOptions.map((opt) {
                  final isChosen = selected == opt.title;
                  return ChoiceChip(
                    label: Text(opt.title),
                    selected: isChosen,
                    onSelected: (_) {
                      controller.selectedMoneyType.value = opt.title;
                    },
                    selectedColor: AppColors.secondary.withValues(alpha: 0.18),
                    backgroundColor: AppColors.inputFill,
                    labelStyle: AppTextStyles.text10.copyWith(
                      color: isChosen
                          ? AppColors.secondary
                          : AppColors.textColor,
                      fontWeight: isChosen ? FontWeight.bold : FontWeight.w500,
                    ),
                    side: BorderSide(
                      color: isChosen
                          ? AppColors.secondary
                          : AppColors.borderColor,
                      width: 1.w,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  );
                }).toList(),
              );
            }),

            AppSpaces.vSpace16,

            // 2. Amount Input
            CustomTextField(
              labelText: 'Requested Amount (PKR)',
              hintText: 'e.g. 35000',
              controller: controller.amountController,
              keyboardType: TextInputType.number,
              prefixIcon: Icon(
                Icons.payments_outlined,
                color: AppColors.secondary,
                size: 20.sp,
              ),
            ),

            AppSpaces.vSpace14,

            // 3. Repayment Tenure Selector
            Text(
              'Repayment Tenure (Months)',
              style: AppTextStyles.text12.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),

            AppSpaces.vSpace8,

            Obx(() {
              final currentTenure = controller.selectedTenureMonths.value;
              return Row(
                children: [1, 2, 3, 6, 12].map((months) {
                  final isSelected = currentTenure == months;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 3.w),
                      child: InkWell(
                        onTap: () =>
                            controller.selectedTenureMonths.value = months,
                        borderRadius: BorderRadius.circular(8.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.inputFill,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.borderColor,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${months}m',
                            style: AppTextStyles.text10.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.white
                                  : AppColors.textColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            }),

            AppSpaces.vSpace14,

            // 4. Reason / Justification Input
            CustomTextField(
              labelText: 'Purpose & Remarks',
              hintText: 'Briefly state the justification for this request...',
              controller: controller.reasonController,
              maxLines: 3,
            ),

            AppSpaces.vSpace20,

            // 5. Submit Request Button
            Obx(
              () => CustomButton(
                text: 'Submit Request',
                isGradient: true,
                isLoading: controller.isMoneyRequestSubmitting.value,
                onPressed: () async {
                  final success = await controller.submitMoneyRequest();
                  if (success) {
                    Get.back();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
