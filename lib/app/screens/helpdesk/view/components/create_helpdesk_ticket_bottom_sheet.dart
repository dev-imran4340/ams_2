import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_dropdown.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../controller/helpdesk_controller.dart';
import '../../model/helpdesk_model.dart';

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

    return Obx(() {
      final isSubmitting = controller.isCreatingTicket.value;

      return PopScope(
        canPop: !isSubmitting,
        child: Container(
          height: 0.82.sh,
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
                      icon: Icon(
                        Icons.close_rounded,
                        size: 22.sp,
                        color: AppColors.subTextColor,
                      ),
                      onPressed: isSubmitting ? null : () => Get.back(),
                    ),
                  ],
                ),
              ),

              Divider(color: AppColors.borderColor, height: 1.h),

              // Form Body
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                  child: Form(
                    key: controller.createFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Category Selection (Using existing CustomDropdown)
                        Obx(() {
                          final cats = controller.categories.toList();
                          final selectedId = controller.selectedCategoryId.value;
                          final initialCat = cats.firstWhereOrNull(
                            (c) => c.id == selectedId,
                          );

                          return CustomDropdown<HelpdeskCategoryModel>(
                            labelText: 'Category',
                            isRequired: true,
                            hintText: cats.isEmpty
                                ? 'No categories available'
                                : 'Select Category',
                            items: cats,
                            initialItem: initialCat,
                            enabled: !isSubmitting && cats.isNotEmpty,
                            fillColor: AppColors.cardBackground,
                            borderColor: AppColors.borderColor,
                            prefixIcon: Icon(
                              Icons.category_outlined,
                              size: 18.sp,
                              color: AppColors.primary,
                            ),
                            onChanged: (cat) {
                              controller.selectedCategoryId.value = cat?.id;
                            },
                            validator: (cat) {
                              if (cat == null) {
                                return 'Please select a category';
                              }
                              return null;
                            },
                          );
                        }),

                        AppSpaces.vSpace16,

                        // 2. Priority Selection (doc/api.md: 'normal' | 'urgent')
                        _buildFieldLabel('Priority Level'),
                        AppSpaces.vSpace6,
                        Obx(() {
                          final selected = controller.selectedPriority.value;
                          return Row(
                            children: [
                              _buildPriorityChip(
                                'normal',
                                'Normal',
                                AppColors.secondary,
                                selected,
                                isSubmitting,
                                controller,
                              ),
                              AppSpaces.hSpace10,
                              _buildPriorityChip(
                                'urgent',
                                'Urgent',
                                AppColors.error,
                                selected,
                                isSubmitting,
                                controller,
                              ),
                            ],
                          );
                        }),

                        AppSpaces.vSpace16,

                        // 3. Subject Field (doc/api.md: required, max 150 chars)
                        _buildFieldLabel('Subject *'),
                        AppSpaces.vSpace6,
                        CustomTextField(
                          controller: controller.subjectController,
                          focusNode: controller.subjectFocusNode,
                          enabled: !isSubmitting,
                          maxLength: 150,
                          hintText: 'Brief summary of the issue or inquiry',
                          fillColor: AppColors.cardBackground,
                          borderColor: AppColors.borderColor,
                          borderRadius: 12.r,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 12.h,
                          ),
                          validator: (val) {
                            final trimmed = val?.trim() ?? '';
                            if (trimmed.isEmpty) {
                              return 'Subject is required';
                            }
                            if (trimmed.length > 150) {
                              return 'Subject must be 150 characters or less';
                            }
                            return null;
                          },
                        ),

                        AppSpaces.vSpace16,

                        // 4. Description / Body Field (doc/api.md: required, max 5000 chars)
                        _buildFieldLabel('Message / Description *'),
                        AppSpaces.vSpace6,
                        CustomTextField(
                          controller: controller.descriptionController,
                          focusNode: controller.descriptionFocusNode,
                          enabled: !isSubmitting,
                          maxLines: 5,
                          maxLength: 5000,
                          hintText:
                              'Provide full details, background context, or instructions...',
                          fillColor: AppColors.cardBackground,
                          borderColor: AppColors.borderColor,
                          borderRadius: 12.r,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 12.h,
                          ),
                          validator: (val) {
                            final trimmed = val?.trim() ?? '';
                            if (trimmed.isEmpty) {
                              return 'Description is required';
                            }
                            if (trimmed.length > 5000) {
                              return 'Description must be 5000 characters or less';
                            }
                            return null;
                          },
                        ),

                        AppSpaces.vSpace24,

                        // 5. Submit Button
                        CustomButton(
                          text: isSubmitting
                              ? 'Submitting Ticket...'
                              : 'Submit Ticket',
                          isGradient: true,
                          isLoading: isSubmitting,
                          onPressed:
                              isSubmitting ? null : controller.submitNewTicket,
                        ),

                        AppSpaces.vSpace20,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
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
    bool isSubmitting,
    HelpdeskController controller,
  ) {
    final isSelected = selected == id;

    return Expanded(
      child: InkWell(
        onTap: isSubmitting
            ? null
            : () => controller.selectedPriority.value = id,
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.14)
                : AppColors.cardBackground,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: isSelected ? color : AppColors.borderColor,
              width: isSelected ? 1.5.w : 1.w,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.text12.copyWith(
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
