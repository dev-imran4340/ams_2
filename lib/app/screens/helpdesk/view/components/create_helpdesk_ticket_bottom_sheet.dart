import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../controller/helpdesk_controller.dart';

class CreateHelpdeskTicketBottomSheet extends StatelessWidget {
  const CreateHelpdeskTicketBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreateHelpdeskTicketBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HelpdeskController>();

    return Container(
      height: 0.86.sh,
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 10.h, bottom: 8.h),
              width: 38.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.borderColor,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Open Helpdesk Ticket',
                      style: AppTextStyles.text18.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                    AppSpaces.vSpace2,
                    Text(
                      'Submit an inquiry to HR, Payroll or IT department',
                      style: AppTextStyles.text10.copyWith(
                        color: AppColors.subTextColor,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, size: 22.sp, color: AppColors.subTextColor),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
          ),

          Divider(color: AppColors.borderColor, height: 1.h),

          // Form Body
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Form(
                key: controller.createFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Category Selection
                    _buildFieldLabel('Category'),
                    AppSpaces.vSpace6,
                    Obx(() {
                      final cats = controller.categories;
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: AppColors.borderColor, width: 0.8.w),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: controller.selectedCategoryId.value,
                            isExpanded: true,
                            hint: Text('Select Category', style: AppTextStyles.text12),
                            icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                            items: cats.map((cat) {
                              return DropdownMenuItem<String>(
                                value: cat.id,
                                child: Text(
                                  cat.name,
                                  style: AppTextStyles.text12.copyWith(color: AppColors.textColor),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                controller.selectedCategoryId.value = val;
                              }
                            },
                          ),
                        ),
                      );
                    }),

                    AppSpaces.vSpace16,

                    // 2. Priority Selection
                    _buildFieldLabel('Priority Level'),
                    AppSpaces.vSpace6,
                    Obx(() {
                      final selected = controller.selectedPriority.value;
                      return Row(
                        children: [
                          _buildPriorityChip('normal', 'Normal', AppColors.secondary, selected, controller),
                          AppSpaces.hSpace8,
                          _buildPriorityChip('high', 'High', AppColors.warning, selected, controller),
                          AppSpaces.hSpace8,
                          _buildPriorityChip('urgent', 'Urgent', AppColors.error, selected, controller),
                        ],
                      );
                    }),

                    AppSpaces.vSpace16,

                    // 3. Subject Field
                    _buildFieldLabel('Subject'),
                    AppSpaces.vSpace6,
                    CustomTextField(
                      controller: controller.subjectController,
                      focusNode: controller.subjectFocusNode,
                      hintText: 'Brief summary of the issue or inquiry',
                      fillColor: AppColors.cardBackground,
                      borderColor: AppColors.borderColor,
                      borderRadius: 10.r,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Subject is required';
                        }
                        return null;
                      },
                    ),

                    AppSpaces.vSpace16,

                    // 4. Message / Description Field
                    _buildFieldLabel('Detailed Description'),
                    AppSpaces.vSpace6,
                    CustomTextField(
                      controller: controller.descriptionController,
                      focusNode: controller.descriptionFocusNode,
                      maxLines: 5,
                      hintText: 'Provide full details, background context, or instructions...',
                      fillColor: AppColors.cardBackground,
                      borderColor: AppColors.borderColor,
                      borderRadius: 10.r,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Description is required';
                        }
                        return null;
                      },
                    ),

                    AppSpaces.vSpace16,

                    // 5. Confidential Checkbox
                    Obx(() {
                      final isConf = controller.isConfidential.value;
                      return InkWell(
                        onTap: () => controller.isConfidential.toggle(),
                        borderRadius: BorderRadius.circular(8.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            color: isConf ? AppColors.error.withValues(alpha: 0.05) : AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: isConf ? AppColors.error : AppColors.borderColor,
                              width: 0.8.w,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isConf ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                                color: isConf ? AppColors.error : AppColors.subTextColor,
                                size: 20.sp,
                              ),
                              AppSpaces.hSpace8,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Mark as Confidential (Grievance / Sensitive)',
                                      style: AppTextStyles.text12.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: isConf ? AppColors.error : AppColors.textColor,
                                      ),
                                    ),
                                    Text(
                                      'Restricts ticket visibility strictly to the assigned HR officer.',
                                      style: AppTextStyles.text10.copyWith(color: AppColors.subTextColor),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    AppSpaces.vSpace24,

                    // 6. Submit Button
                    Obx(() {
                      final isSubmitting = controller.isCreatingTicket.value;
                      return CustomButton(
                        text: isSubmitting ? 'Submitting Ticket...' : 'Submit Ticket',
                        isGradient: true,
                        isLoading: isSubmitting,
                        onPressed: isSubmitting ? null : controller.submitNewTicket,
                      );
                    }),

                    AppSpaces.vSpace20,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: AppTextStyles.text12.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.textColor,
      ),
    );
  }

  Widget _buildPriorityChip(
    String id,
    String label,
    Color color,
    String selected,
    HelpdeskController controller,
  ) {
    final isSelected = selected == id;

    return Expanded(
      child: InkWell(
        onTap: () => controller.selectedPriority.value = id,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.15) : AppColors.cardBackground,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: isSelected ? color : AppColors.borderColor,
              width: isSelected ? 1.5.w : 0.8.w,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.text10.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? color : AppColors.subTextColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
