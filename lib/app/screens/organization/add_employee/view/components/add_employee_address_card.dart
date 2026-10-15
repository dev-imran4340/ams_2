import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_spaces.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../controller/add_employee_controller.dart';
import 'add_employee_city_dialog.dart';
import 'add_employee_section_header.dart';

class AddEmployeeAddressCard extends GetView<AddEmployeeController> {
  const AddEmployeeAddressCard({super.key});

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
          // Section 2 Header Banner
          const AddEmployeeSectionHeader(
            title: 'Address Information',
            icon: Icons.home_outlined,
          ),

          AppSpaces.vSpace16,

          // City Selector (Search Dialog)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'City',
                style: AppTextStyles.text14.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
              AppSpaces.vSpace8,
              Obx(() {
                final hasCountry = controller.selectedCountry.value != null;
                final cityName = controller.selectedCityModel.value?.name ?? controller.selectedCity.value;

                return InkWell(
                  onTap: () => AddEmployeeCityDialog.show(context, controller),
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: AppColors.inputFill,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: AppColors.borderColor,
                        width: 1.w,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_city_outlined,
                          size: 20.sp,
                          color: AppColors.secondary,
                        ),
                        AppSpaces.hSpace12,
                        Expanded(
                          child: Text(
                            cityName.isNotEmpty
                                ? cityName
                                : (hasCountry ? '--Select city--' : 'Select country above first'),
                            style: AppTextStyles.text14.copyWith(
                              color: cityName.isNotEmpty ? AppColors.textColor : AppColors.hintColor,
                              fontWeight: cityName.isNotEmpty ? FontWeight.w500 : FontWeight.normal,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 20.sp,
                          color: AppColors.secondary,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),

          AppSpaces.vSpace14,

          // House No
          CustomTextField(
            labelText: 'House No',
            hintText: 'Enter house number',
            prefixIcon: Icon(
              Icons.home_rounded,
              size: 20.sp,
              color: AppColors.secondary,
            ),
            controller: controller.houseNoController,
            focusNode: controller.houseNoFocusNode,
          ),

          AppSpaces.vSpace14,

          // Street
          CustomTextField(
            labelText: 'Street',
            hintText: 'Enter street address',
            prefixIcon: Icon(
              Icons.streetview_outlined,
              size: 20.sp,
              color: AppColors.secondary,
            ),
            controller: controller.streetController,
            focusNode: controller.streetFocusNode,
          ),

          AppSpaces.vSpace14,

          // Postcode
          CustomTextField(
            labelText: 'Postcode',
            hintText: 'Enter postcode',
            prefixIcon: Icon(
              Icons.markunread_mailbox_outlined,
              size: 20.sp,
              color: AppColors.secondary,
            ),
            keyboardType: TextInputType.text,
            controller: controller.postcodeController,
            focusNode: controller.postcodeFocusNode,
          ),
        ],
      ),
    );
  }
}
