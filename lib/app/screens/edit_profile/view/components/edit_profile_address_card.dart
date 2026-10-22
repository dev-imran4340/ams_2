import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../controller/edit_profile_controller.dart';

class EditProfileAddressCard extends GetView<EditProfileController> {
  const EditProfileAddressCard({super.key});

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
                  color: AppColors.secondary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.home_work_outlined,
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
                      'Residential Address',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.text16.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                    AppSpaces.vSpace2,
                    Text(
                      'Primary residence & regional postal records',
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

          // Street Address
          CustomTextField(
            labelText: 'Street Address *',
            hintText: 'House #42, Street 8, Sector G-11/1',
            controller: controller.addressController,
            focusNode: controller.addressFocusNode,
            prefixIcon: Icon(
              Icons.location_on_outlined,
              size: 20.sp,
              color: AppColors.subTextColor,
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Please enter your street address';
              }
              return null;
            },
          ),

          AppSpaces.vSpace12,

          // City and Postal Code in 2 columns
          Row(
            children: [
              // City
              Expanded(
                flex: 3,
                child: CustomTextField(
                  labelText: 'City *',
                  hintText: 'Islamabad',
                  controller: controller.cityController,
                  focusNode: controller.cityFocusNode,
                  prefixIcon: Icon(
                    Icons.location_city_outlined,
                    size: 20.sp,
                    color: AppColors.subTextColor,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please enter city';
                    }
                    return null;
                  },
                ),
              ),

              AppSpaces.hSpace10,

              // Postal Code
              Expanded(
                flex: 2,
                child: CustomTextField(
                  labelText: 'Postal Code',
                  hintText: '44000',
                  controller: controller.postalCodeController,
                  focusNode: controller.postalCodeFocusNode,
                  keyboardType: TextInputType.number,
                  prefixIcon: Icon(
                    Icons.markunread_mailbox_outlined,
                    size: 20.sp,
                    color: AppColors.subTextColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
