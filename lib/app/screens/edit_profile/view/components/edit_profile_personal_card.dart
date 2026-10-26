import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/custom_dropdown.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../controller/edit_profile_controller.dart';

class EditProfilePersonalCard extends GetView<EditProfileController> {
  const EditProfilePersonalCard({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Icon & Self-Service Badge
          Row(
            children: [
              Container(
                width: 34.r,
                height: 34.r,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_pin_rounded,
                  size: 18.sp,
                  color: AppColors.secondary,
                ),
              ),
              AppSpaces.hSpace10,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact Information',
                      style: AppTextStyles.text14.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                    AppSpaces.vSpace2,
                    Text(
                      'Personal mobile, email & preferred calling name',
                      style: AppTextStyles.text10.copyWith(
                        color: AppColors.subTextColor,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          AppSpaces.vSpace14,

          // Field 1: Preferred Calling Name (preferred_name: up to 80 chars)
          CustomTextField(
            labelText: 'Preferred Calling Name',
            hintText: 'e.g. Maryam or Alex (up to 80 chars)',
            controller: controller.preferredNameController,
            focusNode: controller.preferredNameFocusNode,
            validator: controller.validatePreferredName,
            inputFormatters: [
              LengthLimitingTextInputFormatter(80),
              FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s'.\-]")),
            ],
            prefixIcon: Icon(
              Icons.badge_outlined,
              size: 20.sp,
              color: AppColors.subTextColor,
            ),
          ),
          Obx(() => _buildErrorRow(controller.preferredNameError.value)),

          AppSpaces.vSpace12,

          // Field 2: Personal Phone (personal_phone: up to 20 chars)
          CustomTextField(
            labelText: 'Personal Mobile Phone',
            hintText: 'e.g. 0300 2222222 or +92 300 1234567',
            controller: controller.personalPhoneController,
            focusNode: controller.personalPhoneFocusNode,
            validator: controller.validatePersonalPhone,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              LengthLimitingTextInputFormatter(20),
              FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-()\s]')),
            ],
            prefixIcon: Icon(
              Icons.phone_iphone_rounded,
              size: 20.sp,
              color: AppColors.subTextColor,
            ),
          ),
          Obx(() => _buildErrorRow(controller.personalPhoneError.value)),

          AppSpaces.vSpace12,

          // Field 3: Personal Email (personal_email: up to 255 chars)
          CustomTextField(
            labelText: 'Personal Email Address',
            hintText: 'e.g. employee@personal.com',
            controller: controller.personalEmailController,
            focusNode: controller.personalEmailFocusNode,
            validator: controller.validatePersonalEmail,
            keyboardType: TextInputType.emailAddress,
            inputFormatters: [
              LengthLimitingTextInputFormatter(255),
            ],
            prefixIcon: Icon(
              Icons.mail_outline_rounded,
              size: 20.sp,
              color: AppColors.subTextColor,
            ),
          ),
          Obx(() => _buildErrorRow(controller.personalEmailError.value)),

          AppSpaces.vSpace12,

          // Field 4: Marital Status Dropdown (marital_status)
          Obx(
            () => CustomDropdown<String>(
              labelText: 'Marital Status',
              hintText: 'Select marital status',
              items: controller.maritalStatusOptions,
              initialItem: controller.selectedMaritalStatus.value.isNotEmpty
                  ? controller.selectedMaritalStatus.value
                  : null,
              onChanged: (val) => controller.setMaritalStatus(val),
              canClearSelection: true,
              prefixIcon: Icon(
                Icons.favorite_outline_rounded,
                size: 20.sp,
                color: AppColors.subTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorRow(String? error) {
    if (error == null || error.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(top: 4.h, left: 6.w),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, size: 12.sp, color: AppColors.error),
          AppSpaces.hSpace4,
          Expanded(
            child: Text(
              error,
              style: AppTextStyles.text10.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
