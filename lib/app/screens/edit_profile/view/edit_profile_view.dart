import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_spaces.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/network_boundary_wrapper.dart';
import '../controller/edit_profile_controller.dart';
import 'components/edit_profile_address_card.dart';
import 'components/edit_profile_avatar_picker.dart';
import 'components/edit_profile_emergency_card.dart';
import 'components/edit_profile_employment_card.dart';
import 'components/edit_profile_personal_card.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkBoundaryWrapper(
      onRetry: controller.loadInitialProfile,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2.5.w,
              ),
            );
          }

          return Stack(
            children: [
              // 1. Signature Ambient Curved Gradient Header
              _buildAmbientHeader(),

              // 2. Scrollable Body Content Overlapping Header
              SafeArea(
                child: Form(
                  key: controller.formKey,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 10.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Top Bar with Back Pill and Screen Title
                        _buildTopBar(context),

                        AppSpaces.vSpace16,

                        // Component 1: Interactive Profile Avatar Picker
                        const EditProfileAvatarPicker(),

                        AppSpaces.vSpace16,

                        // Component 2: Personal Details Card (3.w Teal Accent)
                        const EditProfilePersonalCard(),

                        AppSpaces.vSpace16,

                        // Component 3: Residential Address Card (3.w Teal Accent)
                        const EditProfileAddressCard(),

                        AppSpaces.vSpace16,

                        // Component 4: Emergency Contact Card (3.w Teal Accent)
                        const EditProfileEmergencyCard(),

                        AppSpaces.vSpace16,

                        // Component 5: Employment & Placement Info (HR Read-Only)
                        const EditProfileEmploymentCard(),

                        AppSpaces.vSpace20,

                        // Primary Action: Gradient Save Changes Button
                        Obx(
                          () => CustomButton(
                            text: 'Save Profile Changes',
                            isGradient: true,
                            isLoading: controller.isSaving.value,
                            height: 50.h,
                            borderRadius: 14.r,
                            icon: Icon(
                              Icons.check_circle_rounded,
                              size: 18.sp,
                              color: AppColors.white,
                            ),
                            onPressed: controller.saveProfile,
                          ),
                        ),

                        AppSpaces.vSpace14,

                        // Secondary Action: Cancel
                        Center(
                          child: TextButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              Get.back();
                            },
                            child: Text(
                              'Discard & Return',
                              style: AppTextStyles.text12.copyWith(
                                color: AppColors.subTextColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        // Bottom safe clearance
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  /// Ambient Curved Gradient Header matching executive guidelines
  Widget _buildAmbientHeader() {
    return Container(
      width: double.infinity,
      height: 230.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.liteSecondary,
            AppColors.liteSecondary,
            AppColors.liteSecondary,
            AppColors.liteSecondary,
            AppColors.secondary,
            AppColors.primary,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.r),
          bottomRight: Radius.circular(20.r),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -50.r,
            right: -30.r,
            child: Container(
              width: 130.r,
              height: 130.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: 30.r,
            left: -40.r,
            child: Container(
              width: 110.r,
              height: 110.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withValues(alpha: 0.05),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Top navigation bar with Back Pill and Title
  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        // Back Button Pill
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              Get.back();
            },
            borderRadius: BorderRadius.circular(20.r),
            child: Container(
              width: 38.r,
              height: 38.r,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 10.r,
                    offset: Offset(0, 3.h),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16.sp,
                color: AppColors.primary,
              ),
            ),
          ),
        ),

        AppSpaces.hSpace12,

        // Screen Title and Subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Profile',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.text18.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              AppSpaces.vSpace2,
              Text(
                'Update personal identity & emergency contact',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.text10.copyWith(
                  color: AppColors.textColor.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
