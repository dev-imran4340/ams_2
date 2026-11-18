import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../controller/document_controller.dart';

class RequestLetterBottomSheet extends GetView<DocumentController> {
  const RequestLetterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final templates = controller.meDocuments.value?.requestableLetters ?? [];

    return Obx(() {
      final isSubmitting = controller.isSubmitting.value;

      return PopScope(
        canPop: !isSubmitting,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 20.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Bottom Sheet Grabber Handle
                  Center(
                    child: Container(
                      width: 36.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: AppColors.borderColor,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  AppSpaces.vSpace14,

                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Request Official Letter',
                        style: AppTextStyles.text16.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        onPressed: isSubmitting ? null : () => Get.back(),
                        icon: Icon(
                          Icons.close_rounded,
                          size: 20.w,
                          color: AppColors.subTextColor,
                        ),
                      ),
                    ],
                  ),

                  AppSpaces.vSpace10,

                  // Template Selector
                  Text(
                    'Letter Type',
                    style: AppTextStyles.text12.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor,
                    ),
                  ),
                  AppSpaces.vSpace6,

                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: templates.map((tmpl) {
                      final isSelected =
                          controller.selectedTemplate.value?.id == tmpl.id;
                      return ChoiceChip(
                        label: Text(
                          tmpl.name,
                          style: AppTextStyles.text12.copyWith(
                            color: isSelected ? Colors.white : AppColors.textColor,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.backgroundColor,
                        checkmarkColor: AppColors.secondary,
                        onSelected: isSubmitting
                            ? null
                            : (selected) {
                                if (selected) {
                                  controller.selectedTemplate.value = tmpl;
                                }
                              },
                      );
                    }).toList(),
                  ),

                  AppSpaces.vSpace14,

                  // Purpose Input Field
                  Text(
                    'Purpose / Reason',
                    style: AppTextStyles.text12.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor,
                    ),
                  ),
                  AppSpaces.vSpace6,
                  CustomTextField(
                    controller: controller.purposeController,
                    hintText:
                        'e.g., Bank account opening, Visa application, Embassy submission',
                    maxLines: 3,
                    maxLength: 300,
                    enabled: !isSubmitting,
                  ),

                  AppSpaces.vSpace20,

                  // Submit Button
                  CustomButton(
                    text: 'Submit Request',
                    isGradient: true,
                    isLoading: isSubmitting,
                    onPressed: () => controller.submitLetterRequest(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
