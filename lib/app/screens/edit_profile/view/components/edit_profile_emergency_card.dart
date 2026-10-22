import 'package:flutter/material.dart';
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
          // Header with Icon
          Row(
            children: [
              Container(
                width: 32.r,
                height: 32.r,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.contact_emergency_rounded,
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
                      'Emergency Contact',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.text16.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                    AppSpaces.vSpace2,
                    Text(
                      'Next of kin & immediate emergency dispatch',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.text12.copyWith(
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

          // Contact Person Name
          CustomTextField(
            labelText: 'Emergency Contact Person *',
            hintText: 'e.g. Tariq Mehmood',
            controller: controller.emergencyNameController,
            focusNode: controller.emergencyNameFocusNode,
            prefixIcon: Icon(
              Icons.person_pin_rounded,
              size: 20.sp,
              color: AppColors.subTextColor,
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Please enter emergency contact name';
              }
              return null;
            },
          ),

          AppSpaces.vSpace12,

          // Relationship Field with Quick Chips
          CustomTextField(
            labelText: 'Relationship to Employee *',
            hintText: 'e.g. Brother, Father, Spouse',
            controller: controller.emergencyRelationController,
            focusNode: controller.emergencyRelationFocusNode,
            prefixIcon: Icon(
              Icons.people_outline_rounded,
              size: 20.sp,
              color: AppColors.subTextColor,
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Please enter relationship';
              }
              return null;
            },
          ),

          AppSpaces.vSpace8,

          // Quick Relationship Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _suggestedRelations.map((rel) {
                return Padding(
                  padding: EdgeInsets.only(right: 6.w),
                  child: ActionChip(
                    label: Text(
                      rel,
                      style: AppTextStyles.text10.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    backgroundColor: AppColors.primary.withValues(alpha: 0.06),
                    side: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      width: 0.8.w,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    onPressed: () {
                      controller.emergencyRelationController.text = rel;
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          AppSpaces.vSpace12,

          // Emergency Phone Number
          CustomTextField(
            labelText: 'Emergency Phone Number *',
            hintText: '+92 321 7654321',
            controller: controller.emergencyPhoneController,
            focusNode: controller.emergencyPhoneFocusNode,
            keyboardType: TextInputType.phone,
            prefixIcon: Icon(
              Icons.phone_in_talk_rounded,
              size: 20.sp,
              color: AppColors.subTextColor,
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Please enter emergency phone number';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
