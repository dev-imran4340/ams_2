import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_spaces.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../controller/visitor_controller.dart';
import '../../model/visitor_model.dart';

class VisitorDetailsFormCard extends GetView<VisitorController> {
  const VisitorDetailsFormCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 20.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.r),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            border: Border(
              bottom: BorderSide(
                color: AppColors.secondary,
                width: 3.w,
              ),
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Selfie Thumbnail Snapshot & Retake Action
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.borderColor, width: 1.w),
                  ),
                  child: Row(
                    children: [
                      // Snapshot Avatar
                      Container(
                        width: 50.r,
                        height: 50.r,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.secondary,
                            width: 2.w,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.face_rounded,
                            size: 28.sp,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      AppSpaces.hSpace12,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Facial Snapshot Stamped',
                              style: AppTextStyles.text12.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                            ),
                            AppSpaces.vSpace2,
                            Text(
                              'Verified for digital entry pass',
                              style: AppTextStyles.text10.copyWith(
                                color: AppColors.subTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Retake Action Button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: controller.retakePhoto,
                          borderRadius: BorderRadius.circular(8.r),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: AppColors.secondary.withValues(alpha: 0.3),
                                width: 0.8.w,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.refresh_rounded,
                                  size: 14.sp,
                                  color: AppColors.secondary,
                                ),
                                AppSpaces.hSpace4,
                                Text(
                                  'Retake',
                                  style: AppTextStyles.text10.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                AppSpaces.vSpace16,

                // Section Label
                Text(
                  'Visitor Identification',
                  style: AppTextStyles.text14.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                AppSpaces.vSpace10,

                // 1. Full Name
                CustomTextField(
                  controller: controller.nameController,
                  focusNode: controller.nameFocusNode,
                  hintText: 'Guest Full Name',
                  prefixIcon: Icon(
                    Icons.person_outline_rounded,
                    size: 18.sp,
                    color: AppColors.primary,
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter visitor full name';
                    }
                    if (value.trim().length < 3) {
                      return 'Name must be at least 3 characters';
                    }
                    return null;
                  },
                ),

                AppSpaces.vSpace12,

                // 2. CNIC / National ID
                CustomTextField(
                  controller: controller.cnicController,
                  focusNode: controller.cnicFocusNode,
                  hintText: 'CNIC / National ID (e.g. 42101-XXXXXXX-X)',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icon(
                    Icons.badge_outlined,
                    size: 18.sp,
                    color: AppColors.primary,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9\-]')),
                    LengthLimitingTextInputFormatter(15),
                  ],
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter CNIC or National ID';
                    }
                    if (value.trim().length < 13) {
                      return 'Please enter valid 13 or 15 digit CNIC';
                    }
                    return null;
                  },
                ),

                AppSpaces.vSpace12,

                // 3. Mobile Number
                CustomTextField(
                  controller: controller.phoneController,
                  focusNode: controller.phoneFocusNode,
                  hintText: 'Mobile Phone (e.g. 0300-1234567)',
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icon(
                    Icons.phone_outlined,
                    size: 18.sp,
                    color: AppColors.primary,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9\+\-\s]')),
                    LengthLimitingTextInputFormatter(16),
                  ],
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter mobile contact number';
                    }
                    if (value.trim().length < 10) {
                      return 'Please enter valid phone number';
                    }
                    return null;
                  },
                ),

                AppSpaces.vSpace16,

                // Section Label: Purpose of Visit
                Text(
                  'Purpose of Visit',
                  style: AppTextStyles.text14.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                AppSpaces.vSpace8,

                // Purpose Selector Chips
                Obx(
                  () => Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: controller.purposes.map((purpose) {
                      final bool isSelected =
                          controller.selectedPurpose.value == purpose;
                      return ChoiceChip(
                        label: Text(purpose),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            controller.selectedPurpose.value = purpose;
                          }
                        },
                        selectedColor: AppColors.secondary,
                        backgroundColor: AppColors.inputFill,
                        labelStyle: AppTextStyles.text12.copyWith(
                          color: isSelected
                              ? AppColors.white
                              : AppColors.textColor,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.secondary
                              : AppColors.borderColor,
                          width: 1.w,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        showCheckmark: false,
                      );
                    }).toList(),
                  ),
                ),

                AppSpaces.vSpace16,

                // Section Label: Host Employee
                Text(
                  'Host Employee (Company Staff)',
                  style: AppTextStyles.text14.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                AppSpaces.vSpace8,

                // Host Employee Selector Container
                Obx(
                  () => Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.inputFill,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: AppColors.borderColor,
                        width: 1.w,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<HostEmployeeOption>(
                        value: controller.selectedHost.value,
                        isExpanded: true,
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.primary,
                          size: 22.sp,
                        ),
                        hint: Text(
                          'Select Host Employee',
                          style: AppTextStyles.text12.copyWith(
                            color: AppColors.subTextColor,
                          ),
                        ),
                        items: controller.hostEmployees.map((host) {
                          return DropdownMenuItem<HostEmployeeOption>(
                            value: host,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.business_center_outlined,
                                  size: 16.sp,
                                  color: AppColors.secondary,
                                ),
                                AppSpaces.hSpace8,
                                Expanded(
                                  child: Text(
                                    host.displayName,
                                    style: AppTextStyles.text12.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textColor,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            controller.selectedHost.value = value;
                          }
                        },
                      ),
                    ),
                  ),
                ),

                AppSpaces.vSpace24,

                // Submit Check-In Button
                Obx(
                  () => CustomButton(
                    text: 'Complete Check-In & Issue Pass',
                    isGradient: true,
                    isLoading: controller.isSubmitting.value,
                    icon: Icon(
                      Icons.verified_user_rounded,
                      size: 18.sp,
                      color: AppColors.white,
                    ),
                    onPressed: controller.isSubmitting.value
                        ? null
                        : controller.submitEntry,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
