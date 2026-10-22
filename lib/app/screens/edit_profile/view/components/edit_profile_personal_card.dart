import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_card.dart';
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
          // Card Header with Icon
          Row(
            children: [
              Container(
                width: 32.r,
                height: 32.r,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.badge_outlined,
                  size: 17.sp,
                  color: AppColors.primary,
                ),
              ),
              AppSpaces.hSpace10,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Personal Details',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.text16.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                    AppSpaces.vSpace2,
                    Text(
                      'Official identity, credentials & vital records',
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

          // Field 1: Full Name
          CustomTextField(
            labelText: 'Full Name *',
            hintText: 'Enter your legal full name',
            controller: controller.nameController,
            focusNode: controller.nameFocusNode,
            prefixIcon: Icon(
              Icons.person_outline_rounded,
              size: 20.sp,
              color: AppColors.subTextColor,
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Please enter your full name';
              }
              return null;
            },
          ),

          AppSpaces.vSpace12,

          // Field 2: Official Corporate Email
          CustomTextField(
            labelText: 'Official Corporate Email *',
            hintText: 'imran@Softech Business Services.com',
            controller: controller.emailController,
            focusNode: controller.emailFocusNode,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icon(
              Icons.email_outlined,
              size: 20.sp,
              color: AppColors.subTextColor,
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Please enter your corporate email';
              }
              if (!v.contains('@') || !v.contains('.')) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),

          AppSpaces.vSpace12,

          // Field 3: Contact Mobile Phone
          CustomTextField(
            labelText: 'Contact Mobile Phone *',
            hintText: '+92 300 1234567',
            controller: controller.phoneController,
            focusNode: controller.phoneFocusNode,
            keyboardType: TextInputType.phone,
            prefixIcon: Icon(
              Icons.phone_outlined,
              size: 20.sp,
              color: AppColors.subTextColor,
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Please enter your contact phone';
              }
              return null;
            },
          ),

          AppSpaces.vSpace12,

          // Field 4: National ID / CNIC
          CustomTextField(
            labelText: 'National ID / CNIC *',
            hintText: '37405-1234567-1',
            controller: controller.cnicController,
            focusNode: controller.cnicFocusNode,
            keyboardType: TextInputType.text,
            prefixIcon: Icon(
              Icons.credit_card_rounded,
              size: 20.sp,
              color: AppColors.subTextColor,
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Please enter your National ID / CNIC';
              }
              return null;
            },
          ),

          AppSpaces.vSpace12,

          // Field 5: Date of Birth
          CustomTextField(
            labelText: 'Date of Birth',
            hintText: '14 May 1996',
            controller: controller.dobController,
            readOnly: true,
            onTap: () => controller.selectDateOfBirth(context),
            prefixIcon: Icon(
              Icons.cake_outlined,
              size: 20.sp,
              color: AppColors.subTextColor,
            ),
            suffixIcon: Icon(
              Icons.calendar_month_rounded,
              size: 20.sp,
              color: AppColors.secondary,
            ),
          ),

          AppSpaces.vSpace12,

          // Field 6: Gender Selection (Segmented Pills)
          Text(
            'Gender',
            style: AppTextStyles.text14.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textColor,
            ),
          ),
          SizedBox(height: 8.h),
          Obx(() {
            return Row(
              children: controller.genderOptions.map((g) {
                final isSelected = controller.selectedGender.value == g;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3.w),
                    child: InkWell(
                      onTap: () => controller.setGender(g),
                      borderRadius: BorderRadius.circular(10.r),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.inputFill,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.borderColor,
                            width: 1.w,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            g,
                            style: AppTextStyles.text12.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.white
                                  : AppColors.textColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }),

          AppSpaces.vSpace14,

          // Field 7: Blood Group Selection (Scrollable Pills)
          Text(
            'Blood Group',
            style: AppTextStyles.text14.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textColor,
            ),
          ),
          SizedBox(height: 8.h),
          Obx(() {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: controller.bloodGroupOptions.map((bg) {
                  final isSelected = controller.selectedBloodGroup.value == bg;
                  return Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: InkWell(
                      onTap: () => controller.setBloodGroup(bg),
                      borderRadius: BorderRadius.circular(10.r),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.secondary
                              : AppColors.inputFill,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.secondary
                                : AppColors.borderColor,
                            width: 1.w,
                          ),
                        ),
                        child: Text(
                          bg,
                          style: AppTextStyles.text12.copyWith(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: isSelected
                                ? AppColors.white
                                : AppColors.textColor,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          }),
        ],
      ),
    );
  }
}
