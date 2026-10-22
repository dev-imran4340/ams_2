import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_spaces.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/network_boundary_wrapper.dart';
import '../controller/profile_controller.dart';
import 'components/assigned_shift_card.dart';
import 'components/preference_toggle_tile.dart';
import 'components/profile_emergency_card.dart';
import 'components/profile_employment_card.dart';
import 'components/profile_header_card.dart';
import 'components/profile_personal_details_card.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkBoundaryWrapper(
      onRetry: () => controller.loadProfile(),
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
              // 1. Curved Ambient Gradient Header
              _buildAmbientHeader(),

              // 2. Main Scrollable Content Overlapping the Header
              SafeArea(
                child: RefreshIndicator(
                  onRefresh: controller.loadProfile,
                  color: AppColors.primary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 10.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Executive Header Bar with Edit & Sign Out Actions
                        _buildTopBar(context),

                        AppSpaces.vSpace14,

                        // Component 1: Primary Employee Credentials & Identity Card
                        const ProfileHeaderCard(),

                        AppSpaces.vSpace14,

                        // Component 2: Personal Contact & Vital Details Card (3.w Teal Accent)
                        const ProfilePersonalDetailsCard(),

                        AppSpaces.vSpace14,

                        // Component 3: Organization, Department & Placement Card (3.w Teal Accent)
                        const ProfileEmploymentCard(),

                        AppSpaces.vSpace14,

                        // Component 4: Assigned Work Shift & Reporting Details
                        const AssignedShiftCard(),

                        AppSpaces.vSpace14,

                        // Component 5: Residential Address & Emergency Contact Card (3.w Teal Accent)
                        const ProfileEmergencyCard(),

                        AppSpaces.vSpace14,

                        // Component 6: Workplace Preferences & Switch Hub
                        const PreferenceToggleHub(),

                        AppSpaces.vSpace18,

                        // High-Contrast Sign Out Button
                        CustomButton(
                          text: 'Sign Out Active Session',
                          isOutlined: true,
                          borderColor: AppColors.error.withValues(alpha: 0.35),
                          textColor: AppColors.error,
                          height: 48.h,
                          borderRadius: 14.r,
                          icon: Icon(
                            Icons.logout_rounded,
                            size: 16.sp,
                            color: AppColors.error,
                          ),
                          onPressed: () =>
                              controller.showLogoutConfirmation(context),
                        ),

                        AppSpaces.vSpace14,

                        // Corporate Version Stamp
                        Center(
                          child: Text(
                            'AMS 2.0 • Powered by Softech Business Services',
                            style: AppTextStyles.text10.copyWith(
                              letterSpacing: 0.5,
                              color: AppColors.subTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        // Safe clearance for the floating navigation bar
                        SizedBox(height: 85.h),
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

  /// Ambient Curved Gradient Header matching executive style
  Widget _buildAmbientHeader() {
    return Container(
      width: double.infinity,
      height: 220.h,
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
            top: -60.r,
            right: -40.r,
            child: Container(
              width: 140.r,
              height: 140.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: 20.r,
            left: -50.r,
            child: Container(
              width: 120.r,
              height: 120.r,
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

  /// Top executive navigation bar with Title and Actions (Edit Profile + Sign Out)
  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Title & Subtitle with flex protection
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile & Settings',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.text18.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              AppSpaces.vSpace2,
              Text(
                'Employee credentials, preferences & security',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.text10.copyWith(
                  color: AppColors.textColor.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
        ),

        AppSpaces.hSpace8,

        // Action 1: Edit Profile Quick Button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: controller.navigateToEditProfile,
            borderRadius: BorderRadius.circular(20.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.9),
                  width: 1.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 10.r,
                    offset: Offset(0, 3.h),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 22.r,
                    height: 22.r,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.edit_rounded,
                      size: 13.sp,
                      color: AppColors.secondary,
                    ),
                  ),
                  AppSpaces.hSpace6,
                  Text(
                    'Edit',
                    style: AppTextStyles.text12.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        AppSpaces.hSpace8,

        // Action 2: Sign Out Button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              controller.showLogoutConfirmation(context);
            },
            borderRadius: BorderRadius.circular(20.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.9),
                  width: 1.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 10.r,
                    offset: Offset(0, 3.h),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 22.r,
                    height: 22.r,
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.logout_rounded,
                      size: 13.sp,
                      color: AppColors.error,
                    ),
                  ),
                  AppSpaces.hSpace6,
                  Text(
                    'Sign Out',
                    style: AppTextStyles.text12.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
