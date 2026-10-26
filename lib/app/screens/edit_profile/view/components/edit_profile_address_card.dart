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
                width: 34.r,
                height: 34.r,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.home_work_outlined,
                  size: 18.sp,
                  color: AppColors.primary,
                ),
              ),
              AppSpaces.hSpace10,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Residential Address',
                      style: AppTextStyles.text14.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                    AppSpaces.vSpace2,
                    Text(
                      'Street, city, postal code & country',
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

          // Address Line 1 (address_line1: up to 255)
          CustomTextField(
            labelText: 'Address Line 1',
            hintText: 'House #, Street name, Area or Sector',
            controller: controller.addressLine1Controller,
            focusNode: controller.addressLine1FocusNode,
            validator: controller.validateAddressLine1,
            inputFormatters: [
              LengthLimitingTextInputFormatter(255),
            ],
            prefixIcon: Icon(
              Icons.location_on_outlined,
              size: 20.sp,
              color: AppColors.subTextColor,
            ),
          ),
          Obx(() => _buildErrorRow(controller.addressLine1Error.value)),

          AppSpaces.vSpace12,

          // Address Line 2 (address_line2: up to 255)
          CustomTextField(
            labelText: 'Address Line 2 (Optional)',
            hintText: 'Apartment, Suite, Unit, Building floor',
            controller: controller.addressLine2Controller,
            focusNode: controller.addressLine2FocusNode,
            validator: controller.validateAddressLine2,
            inputFormatters: [
              LengthLimitingTextInputFormatter(255),
            ],
            prefixIcon: Icon(
              Icons.apartment_rounded,
              size: 20.sp,
              color: AppColors.subTextColor,
            ),
          ),

          AppSpaces.vSpace12,

          // City Name (city_name: up to 100)
          CustomTextField(
            labelText: 'City',
            hintText: 'e.g. Lahore',
            controller: controller.cityController,
            focusNode: controller.cityFocusNode,
            validator: controller.validateCity,
            inputFormatters: [
              LengthLimitingTextInputFormatter(100),
            ],
            prefixIcon: Icon(
              Icons.location_city_rounded,
              size: 20.sp,
              color: AppColors.subTextColor,
            ),
          ),
          Obx(() => _buildErrorRow(controller.cityError.value)),

          AppSpaces.vSpace12,

          // Postcode (postcode: up to 12)
          CustomTextField(
            labelText: 'Postcode',
            hintText: 'e.g. 54000',
            controller: controller.postcodeController,
            focusNode: controller.postcodeFocusNode,
            validator: controller.validatePostcode,
            inputFormatters: [
              LengthLimitingTextInputFormatter(12),
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s\-]')),
            ],
            prefixIcon: Icon(
              Icons.markunread_mailbox_outlined,
              size: 20.sp,
              color: AppColors.subTextColor,
            ),
          ),
          Obx(() => _buildErrorRow(controller.postcodeError.value)),

          AppSpaces.vSpace12,

          // Country Code (country_code: 2-letter ISO e.g. PK)
          CustomTextField(
            labelText: 'Country Code (2-letter ISO)',
            hintText: 'e.g. PK, GB, US, AE',
            controller: controller.countryCodeController,
            focusNode: controller.countryCodeFocusNode,
            validator: controller.validateCountryCode,
            inputFormatters: [
              LengthLimitingTextInputFormatter(2),
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
            ],
            prefixIcon: Icon(
              Icons.public_rounded,
              size: 20.sp,
              color: AppColors.subTextColor,
            ),
          ),
          Obx(() => _buildErrorRow(controller.countryCodeError.value)),
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
