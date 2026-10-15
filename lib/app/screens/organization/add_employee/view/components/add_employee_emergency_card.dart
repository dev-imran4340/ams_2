import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_spaces.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../controller/add_employee_controller.dart';
import 'add_employee_section_header.dart';

class AddEmployeeEmergencyCard extends GetView<AddEmployeeController> {
  const AddEmployeeEmergencyCard({super.key});

  static const List<String> _quickRelationships = [
    'Father',
    'Mother',
    'Spouse',
    'Brother',
    'Sister',
    'Guardian',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.borderColor,
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 18.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section 3 Header Banner
          const AddEmployeeSectionHeader(
            title: 'Emergency Contact',
            icon: Icons.emergency_outlined,
          ),

          AppSpaces.vSpace16,

          // Mobile
          CustomTextField(
            labelText: 'Mobile',
            hintText: 'Enter emergency contact mobile',
            prefixIcon: Icon(
              Icons.phone_android_outlined,
              size: 20.sp,
              color: AppColors.secondary,
            ),
            keyboardType: TextInputType.phone,
            controller: controller.emergencyPhoneController,
            focusNode: controller.emergencyPhoneFocusNode,
          ),

          AppSpaces.vSpace14,

          // Contact Name
          CustomTextField(
            labelText: 'Contact Name',
            hintText: 'Enter emergency contact name',
            prefixIcon: Icon(
              Icons.person_outline_rounded,
              size: 20.sp,
              color: AppColors.secondary,
            ),
            controller: controller.emergencyNameController,
            focusNode: controller.emergencyNameFocusNode,
          ),

          AppSpaces.vSpace14,

          // Relationship
          CustomTextField(
            labelText: 'Relationship',
            hintText: 'Enter relationship',
            prefixIcon: Icon(
              Icons.family_restroom_outlined,
              size: 20.sp,
              color: AppColors.secondary,
            ),
            controller: controller.relationshipController,
            focusNode: controller.relationshipFocusNode,
          ),

          AppSpaces.vSpace10,

          // Quick Relationship Pills
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: _quickRelationships.map((rel) {
              return InkWell(
                onTap: () {
                  controller.relationshipController.text = rel;
                  controller.selectedRelationship.value = rel;
                },
                borderRadius: BorderRadius.circular(8.r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: AppColors.borderColor,
                      width: 0.8.w,
                    ),
                  ),
                  child: Text(
                    rel,
                    style: AppTextStyles.text12.copyWith(
                      color: AppColors.subTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
