import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_spaces.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../controller/add_employee_controller.dart';
import '../../model/add_employee_model.dart';
import 'add_employee_section_header.dart';

class AddEmployeePersonalCard extends GetView<AddEmployeeController> {
  const AddEmployeePersonalCard({super.key});

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
          // Section 1 Header Banner
          const AddEmployeeSectionHeader(
            title: 'Personal Information',
            icon: Icons.person_outline_rounded,
          ),

          AppSpaces.vSpace16,

          // Name
          CustomTextField(
            labelText: 'Name',
            hintText: 'Enter employee name',
            prefixIcon: Icon(
              Icons.person_rounded,
              size: 20.sp,
              color: AppColors.secondary,
            ),
            controller: controller.nameController,
            focusNode: controller.nameFocusNode,
          ),

          AppSpaces.vSpace14,

          // Email
          CustomTextField(
            labelText: 'Email',
            hintText: 'Enter email address',
            prefixIcon: Icon(
              Icons.email_outlined,
              size: 20.sp,
              color: AppColors.secondary,
            ),
            keyboardType: TextInputType.emailAddress,
            controller: controller.emailController,
            focusNode: controller.emailFocusNode,
          ),

          AppSpaces.vSpace14,

          // Gender Dropdown
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gender',
                style: AppTextStyles.text14.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
              AppSpaces.vSpace8,
              Obx(() {
                final currentGender = controller.selectedGender.value;
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.borderColor, width: 1.w),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: currentGender.isEmpty ? null : currentGender,
                      hint: Text(
                        '--Select gender--',
                        style: AppTextStyles.text14.copyWith(color: AppColors.hintColor),
                      ),
                      isExpanded: true,
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.secondary,
                        size: 20.sp,
                      ),
                      items: ['Male', 'Female', 'Other'].map((String gender) {
                        return DropdownMenuItem<String>(
                          value: gender,
                          child: Row(
                            children: [
                              Icon(
                                Icons.person_outline_rounded,
                                size: 18.sp,
                                color: AppColors.secondary,
                              ),
                              AppSpaces.hSpace10,
                              Text(
                                gender,
                                style: AppTextStyles.text14.copyWith(color: AppColors.textColor),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) controller.selectedGender.value = val;
                      },
                    ),
                  ),
                );
              }),
            ],
          ),

          AppSpaces.vSpace14,

          // Country Dropdown
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Country',
                style: AppTextStyles.text14.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
              AppSpaces.vSpace8,
              Obx(() {
                final country = controller.selectedCountry.value;
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.borderColor, width: 1.w),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<CountryModel>(
                      value: country,
                      hint: Text(
                        '--Select country--',
                        style: AppTextStyles.text14.copyWith(color: AppColors.hintColor),
                      ),
                      isExpanded: true,
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.secondary,
                        size: 20.sp,
                      ),
                      items: controller.countries.map((CountryModel c) {
                        return DropdownMenuItem<CountryModel>(
                          value: c,
                          child: Row(
                            children: [
                              if (c.flag.isNotEmpty) ...[
                                Text(c.flag, style: TextStyle(fontSize: 16.sp)),
                                AppSpaces.hSpace8,
                              ],
                              Expanded(
                                child: Text(
                                  '${c.countryName} (${c.dialCode})',
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.text14.copyWith(color: AppColors.textColor),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: controller.onCountrySelected,
                    ),
                  ),
                );
              }),
            ],
          ),

          AppSpaces.vSpace14,

          // Phone Field with Dial Code Prefix
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Phone',
                style: AppTextStyles.text14.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
              AppSpaces.vSpace8,
              Obx(() {
                final dialCode = controller.selectedDialCode.value;
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.borderColor, width: 1.w),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 14.w, right: 6.w),
                        child: Icon(
                          Icons.phone_outlined,
                          size: 20.sp,
                          color: AppColors.secondary,
                        ),
                      ),
                      if (dialCode.isNotEmpty) ...[
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            dialCode,
                            style: AppTextStyles.text12.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                        Container(
                          width: 1.w,
                          height: 22.h,
                          margin: EdgeInsets.symmetric(horizontal: 8.w),
                          color: AppColors.borderColor,
                        ),
                      ],
                      Expanded(
                        child: TextFormField(
                          controller: controller.phoneController,
                          focusNode: controller.phoneFocusNode,
                          keyboardType: TextInputType.phone,
                          style: AppTextStyles.text14.copyWith(
                            color: AppColors.textColor,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter phone number',
                            hintStyle: AppTextStyles.text14.copyWith(color: AppColors.hintColor),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}
