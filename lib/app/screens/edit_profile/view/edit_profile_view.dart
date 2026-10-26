import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_spaces.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_screen_header.dart';
import '../../../core/widgets/custom_state_view.dart';
import '../../../core/widgets/employee_ambient_header.dart';
import '../../../core/widgets/network_boundary_wrapper.dart';
import '../../profile/model/profile_model.dart';
import '../controller/edit_profile_controller.dart';
import 'components/edit_profile_address_card.dart';
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

          final profile = controller.currentProfile.value;
          if (profile == null) {
            return CustomStateView.empty(
              title: 'Profile Unavailable',
              message: 'Could not load your employee profile details.',
              buttonText: 'Retry',
              onAction: controller.loadInitialProfile,
            );
          }

          return Stack(
            children: [
              // 1. Signature Ambient Curved Gradient Header
              EmployeeAmbientHeader(height: 230.h),

              // 2. Overlapping Scrollable Body Content
              SafeArea(
                child: Column(
                  children: [
                    // Top Bar with White Back Button, Title & Subtitle
                    Padding(
                      padding: AppSpaces.horizontalPadding,
                      child: CustomScreenHeader(
                        title: 'Edit Profile',
                        subtitle: 'Self-service contact & emergency updates',
                      ),
                    ),

                    AppSpaces.vSpace14,

                    // Scrollable Body Form
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: EdgeInsets.fromLTRB(14.w, 4.h, 14.w, 24.h),
                        child: Form(
                          key: controller.formKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // 1. Employee Identity Overview Card
                              _buildEmployeeHeaderCard(profile),

                              // Conflict Alert Banner (when request is already waiting)
                              _buildPendingConflictBanner(),

                              AppSpaces.vSpace16,

                              // 2. Personal & Calling Details
                              const EditProfilePersonalCard(),

                              AppSpaces.vSpace16,

                              // 3. Residential Address Details
                              const EditProfileAddressCard(),

                              AppSpaces.vSpace16,

                              // 4. Emergency Contact Details
                              const EditProfileEmergencyCard(),

                              AppSpaces.vSpace16,

                              // 5. HR Official Records (Read-Only)
                              const EditProfileEmploymentCard(),

                              AppSpaces.vSpace20,

                              // 6. Primary Action: Save Changes Button
                              Obx(
                                () => CustomButton(
                                  text: 'Save Changes',
                                  isGradient: true,
                                  isLoading: controller.isSaving.value,
                                  height: 50.h,
                                  borderRadius: 14.r,
                                  icon: Icon(
                                    Icons.check_circle_rounded,
                                    size: 18.sp,
                                    color: AppColors.white,
                                  ),
                                  onPressed: controller.saveAllChanges,
                                ),
                              ),

                              AppSpaces.vSpace12,

                              // 7. Secondary Action: Discard & Return
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

                              SizedBox(height: 16.h),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  /// Compact executive employee badge card showing legal identity & designation
  Widget _buildEmployeeHeaderCard(EmployeeProfileModel profile) {
    final initials = profile.initials;
    final name = profile.name.trim();
    final designation = profile.designation.isNotEmpty
        ? profile.designation
        : (profile.job?.designation ?? '');
    final department = profile.department.isNotEmpty
        ? profile.department
        : (profile.job?.department ?? '');
    final employeeNumber = profile.employeeNumber.isNotEmpty
        ? profile.employeeNumber
        : profile.employeeId;
    final jobDetails = [
      if (designation.isNotEmpty) designation,
      if (department.isNotEmpty) department,
    ].join(' • ');

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 12.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 8.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Row(
        children: [
          // Executive Initials Avatar
          Container(
            width: 52.r,
            height: 52.r,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.accentNavy],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.secondary, width: 2.w),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 8.r,
                  offset: Offset(0, 3.h),
                ),
              ],
            ),
            child: Center(
              child: Text(
                initials,
                style: AppTextStyles.text18.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          AppSpaces.hSpace12,

          // Name, Designation, and Employee Code
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.text16.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                    ),
                    if (employeeNumber.isNotEmpty) ...[
                      AppSpaces.hSpace6,
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          employeeNumber,
                          style: AppTextStyles.text10.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (jobDetails.isNotEmpty) ...[
                  AppSpaces.vSpace4,
                  Text(
                    jobDetails,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.text12.copyWith(
                      color: AppColors.subTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                AppSpaces.vSpace4,
                Row(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 12.sp,
                      color: AppColors.secondary,
                    ),
                    AppSpaces.hSpace4,
                    Text(
                      'Official Corporate Account',
                      style: AppTextStyles.text10.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Interactive executive warning banner rendered when an approval request is already waiting
  Widget _buildPendingConflictBanner() {
    return Obx(() {
      if (!controller.hasPendingRequestConflict.value) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: EdgeInsets.only(top: 14.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppColors.deepNavyBase,
              AppColors.primary,
              AppColors.accentNavy,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(
            color: AppColors.warning.withValues(alpha: 0.65),
            width: 1.2.w,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.deepNavyBase.withValues(alpha: 0.45),
              blurRadius: 14.r,
              offset: Offset(0, 5.h),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Icon + Title + Status Pill
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Glowing Amber Icon
                Container(
                  padding: EdgeInsets.all(7.r),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.5),
                      width: 1.w,
                    ),
                  ),
                  child: Icon(
                    Icons.hourglass_top_rounded,
                    color: AppColors.warning,
                    size: 18.sp,
                  ),
                ),
                AppSpaces.hSpace10,
                // Title and Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Request Waiting for Approval',
                        style: AppTextStyles.text14.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                      AppSpaces.vSpace2,
                      Text(
                        'Awaiting HR / Management decision',
                        style: AppTextStyles.text10.copyWith(
                          color: AppColors.liteSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpaces.hSpace8,
                // Amber Pending Tag
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.6),
                      width: 1.w,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6.r,
                        height: 6.r,
                        decoration: const BoxDecoration(
                          color: AppColors.warning,
                          shape: BoxShape.circle,
                        ),
                      ),
                      AppSpaces.hSpace4,
                      Text(
                        'PENDING',
                        style: AppTextStyles.text10.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            AppSpaces.vSpace10,

            // Glassmorphic Subtle Divider
            Container(
              height: 1.h,
              color: AppColors.white.withValues(alpha: 0.12),
            ),

            AppSpaces.vSpace10,

            // Body Message
            Text(
              controller.conflictWarningMessage.value.isNotEmpty
                  ? controller.conflictWarningMessage.value
                  : 'There is already a request waiting for approval. Wait for its answer or withdraw it first.',
              style: AppTextStyles.text12.copyWith(
                color: AppColors.white.withValues(alpha: 0.9),
                height: 1.45,
                fontWeight: FontWeight.w400,
              ),
            ),

            AppSpaces.vSpace12,

            // CTA Button (Modern Teal Corporate Action)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: controller.openMyRequestsInbox,
                borderRadius: BorderRadius.circular(10.r),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.secondary, AppColors.accentNavy],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: AppColors.secondary.withValues(alpha: 0.4),
                      width: 1.w,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondary.withValues(alpha: 0.25),
                        blurRadius: 8.r,
                        offset: Offset(0, 3.h),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_rounded,
                        size: 15.sp,
                        color: AppColors.white,
                      ),
                      AppSpaces.hSpace8,
                      Text(
                        'View & Withdraw in Requests Inbox',
                        style: AppTextStyles.text12.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                      AppSpaces.hSpace6,
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 14.sp,
                        color: AppColors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
