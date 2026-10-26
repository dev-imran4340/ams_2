import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../controller/edit_profile_controller.dart';

class EditProfileEmergencyCard extends GetView<EditProfileController> {
  const EditProfileEmergencyCard({super.key});

  static const List<String> _suggestedRelations = [
    'Father',
    'Mother',
    'Brother',
    'Sister',
    'Spouse',
    'Guardian',
  ];

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Icon & Mode Indicator
          Row(
            children: [
              Container(
                width: 34.r,
                height: 34.r,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.contact_emergency_rounded,
                  size: 18.sp,
                  color: AppColors.warning,
                ),
              ),
              AppSpaces.hSpace10,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emergency Contact',
                      style: AppTextStyles.text14.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                    AppSpaces.vSpace2,
                    Text(
                      'Next of kin & immediate emergency dispatch',
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

          // Contact Person Name (name: required, up to 80 chars)
          CustomTextField(
            labelText: 'Emergency Contact Person *',
            hintText: 'e.g. Bilal Khan',
            controller: controller.emergencyNameController,
            focusNode: controller.emergencyNameFocusNode,
            validator: controller.validateEmergencyName,
            inputFormatters: [
              LengthLimitingTextInputFormatter(80),
              FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s'.\-]")),
            ],
            prefixIcon: Icon(
              Icons.person_outline_rounded,
              size: 20.sp,
              color: AppColors.subTextColor,
            ),
          ),
          Obx(() => _buildErrorRow(controller.emergencyNameError.value)),

          AppSpaces.vSpace12,

          // Relationship (relationship: required, up to 40 chars)
          CustomTextField(
            labelText: 'Relationship *',
            hintText: 'e.g. Brother, Spouse, Father',
            controller: controller.emergencyRelationController,
            focusNode: controller.emergencyRelationFocusNode,
            validator: controller.validateEmergencyRelation,
            inputFormatters: [
              LengthLimitingTextInputFormatter(40),
              FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s'.\-]")),
            ],
            prefixIcon: Icon(
              Icons.family_restroom_rounded,
              size: 20.sp,
              color: AppColors.subTextColor,
            ),
          ),
          Obx(() => _buildErrorRow(controller.emergencyRelationError.value)),

          AppSpaces.vSpace8,

          // Quick relationship suggestion chips
          Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            children: _suggestedRelations.map((rel) {
              return InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  controller.emergencyRelationController.text = rel;
                  controller.emergencyRelationError.value = null;
                },
                borderRadius: BorderRadius.circular(16.r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: AppColors.borderColor,
                      width: 0.8.w,
                    ),
                  ),
                  child: Text(
                    rel,
                    style: AppTextStyles.text10.copyWith(
                      color: AppColors.textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          AppSpaces.vSpace12,

          // Primary Phone (phone: required, up to 20 chars)
          CustomTextField(
            labelText: 'Emergency Phone Number *',
            hintText: 'e.g. 0300 3333333',
            controller: controller.emergencyPhoneController,
            focusNode: controller.emergencyPhoneFocusNode,
            validator: controller.validateEmergencyPhone,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              LengthLimitingTextInputFormatter(20),
              FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-()\s]')),
            ],
            prefixIcon: Icon(
              Icons.phone_rounded,
              size: 20.sp,
              color: AppColors.subTextColor,
            ),
          ),
          Obx(() => _buildErrorRow(controller.emergencyPhoneError.value)),

          AppSpaces.vSpace12,

          // Alternative Phone (alternative_phone: optional, up to 20 chars)
          CustomTextField(
            labelText: 'Alternative Phone (Optional)',
            hintText: 'e.g. 0321 4444444',
            controller: controller.emergencyAltPhoneController,
            focusNode: controller.emergencyAltPhoneFocusNode,
            validator: controller.validateEmergencyAltPhone,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              LengthLimitingTextInputFormatter(20),
              FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-()\s]')),
            ],
            prefixIcon: Icon(
              Icons.phone_outlined,
              size: 20.sp,
              color: AppColors.subTextColor,
            ),
          ),
          Obx(() => _buildErrorRow(controller.emergencyAltPhoneError.value)),

          AppSpaces.vSpace12,

          // Physical Address (address: optional, up to 255 chars)
          CustomTextField(
            labelText: 'Home / Workplace Address (Optional)',
            hintText: 'Street address or landmark',
            controller: controller.emergencyAddressController,
            focusNode: controller.emergencyAddressFocusNode,
            inputFormatters: [
              LengthLimitingTextInputFormatter(255),
            ],
            prefixIcon: Icon(
              Icons.location_on_outlined,
              size: 20.sp,
              color: AppColors.subTextColor,
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
