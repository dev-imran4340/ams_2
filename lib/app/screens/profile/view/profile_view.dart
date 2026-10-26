import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_spaces.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_screen_header.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/employee_ambient_header.dart';
import '../../../core/widgets/network_boundary_wrapper.dart';
import '../controller/profile_controller.dart';
import 'components/profile_header_card.dart';

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
              EmployeeAmbientHeader(height: 230.h),

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
                        // Top Bar with Back, Title, and Edit Profile Action
                        CustomScreenHeader(
                          title: 'Account & Settings',
                          subtitle: 'Security, preferences & credentials',
                          actions: [
                            CustomScreenHeader.actionButton(
                              icon: Icons.edit_outlined,
                              onTap: controller.navigateToEditProfile,
                              tooltip: 'Edit Profile',
                            ),
                          ],
                        ),

                        AppSpaces.vSpace14,

                        // Component 1: Primary Employee Header Card (Tapable -> Opens Detailed Profile with Tabs)
                        ProfileHeaderCard(
                          isClickable: true,
                          onTap: controller.navigateToProfileDetails,
                        ),

                        AppSpaces.vSpace16,

                        // Component 2: Distinct Small Cards Grid (2FA, Change Password, Settings, Employee Card)
                        Row(
                          children: [
                            Expanded(child: _build2FACard()),
                            AppSpaces.hSpace12,
                            Expanded(child: _buildChangePasswordCard(context)),
                          ],
                        ),

                        AppSpaces.vSpace12,

                        Row(
                          children: [
                            Expanded(child: _buildSettingsCard(context)),
                            AppSpaces.hSpace12,
                            Expanded(child: _buildEmployeeCard()),
                          ],
                        ),

                        AppSpaces.vSpace18,

                        // Component 3: Just the Logout Button
                        _buildLogoutButton(context),

                        AppSpaces.vSpace18,

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



  /// Base container for small cards with subtle elevation shadow
  Widget _buildSmallCardContainer({
    required Widget child,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          height: 125.h,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppColors.borderColor.withValues(alpha: 0.7),
              width: 0.8.w,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.05),
                blurRadius: 10.r,
                offset: Offset(0, 3.h),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  /// Small Card 1: 2FA Security (with Switch & distinct Teal accent)
  Widget _build2FACard() {
    return _buildSmallCardContainer(
      onTap: () {
        controller.toggle2FA(!controller.twoFactorAuth.value);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.shield_outlined,
                  size: 18.sp,
                  color: AppColors.secondary,
                ),
              ),
              Obx(() {
                return Transform.scale(
                  scale: 0.75,
                  child: Switch.adaptive(
                    value: controller.twoFactorAuth.value,
                    onChanged: controller.toggle2FA,
                    activeTrackColor: AppColors.secondary.withValues(
                      alpha: 0.35,
                    ),
                    activeThumbColor: AppColors.secondary,
                  ),
                );
              }),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '2FA Security',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.text14.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              AppSpaces.vSpace2,
              Obx(() {
                final isEnabled = controller.twoFactorAuth.value;
                return Row(
                  children: [
                    Container(
                      width: 6.r,
                      height: 6.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isEnabled
                            ? AppColors.success
                            : AppColors.subTextColor,
                      ),
                    ),
                    AppSpaces.hSpace4,
                    Text(
                      isEnabled ? 'Enabled' : 'Disabled',
                      style: AppTextStyles.text10.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isEnabled
                            ? AppColors.success
                            : AppColors.subTextColor,
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  /// Small Card 2: Change Password (with distinct Warm Amber accent)
  Widget _buildChangePasswordCard(BuildContext context) {
    return _buildSmallCardContainer(
      onTap: () => _showChangePasswordSheet(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.lock_reset_rounded,
                  size: 18.sp,
                  color: const Color(0xFFE65100),
                ),
              ),
              Container(
                padding: EdgeInsets.all(5.r),
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 10.sp,
                  color: AppColors.subTextColor,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Password',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.text14.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              AppSpaces.vSpace2,
              Text(
                'Change password',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.text10.copyWith(
                  color: const Color(0xFFE65100),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Small Card 3: App Settings (with distinct Violet accent)
  Widget _buildSettingsCard(BuildContext context) {
    return _buildSmallCardContainer(
      onTap: () => _showSettingsSheet(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE7F6),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.tune_rounded,
                  size: 18.sp,
                  color: const Color(0xFF5E35B1),
                ),
              ),
              Container(
                padding: EdgeInsets.all(5.r),
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 10.sp,
                  color: AppColors.subTextColor,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.text14.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              AppSpaces.vSpace2,
              Text(
                'Preferences & alerts',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.text10.copyWith(
                  color: const Color(0xFF5E35B1),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Small Card 4: Employee ID Card (with distinct Corporate Navy accent)
  Widget _buildEmployeeCard() {
    return _buildSmallCardContainer(
      onTap: controller.navigateToCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.badge_outlined,
                  size: 18.sp,
                  color: AppColors.primary,
                ),
              ),
              Container(
                padding: EdgeInsets.all(5.r),
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 10.sp,
                  color: AppColors.subTextColor,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Employee Card',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.text14.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              AppSpaces.vSpace2,
              Text(
                'Digital ID & QR',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.text10.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Prominent, clean Logout Button
  Widget _buildLogoutButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          controller.showLogoutConfirmation(context);
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 13.h),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppColors.error.withValues(alpha: 0.25),
              width: 1.w,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.error.withValues(alpha: 0.05),
                blurRadius: 8.r,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, size: 18.sp, color: AppColors.error),
              AppSpaces.hSpace8,
              Text(
                'Log Out',
                style: AppTextStyles.text14.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Modal sheet for changing corporate password
  void _showChangePasswordSheet(BuildContext context) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.primary.withValues(alpha: 0.6),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(22.r),
                topRight: Radius.circular(22.r),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColors.borderColor,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ),
                AppSpaces.vSpace14,
                Text(
                  'Change Password',
                  style: AppTextStyles.text16.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                AppSpaces.vSpace4,
                Text(
                  'Enter your current password and choose a secure new one.',
                  style: AppTextStyles.text12.copyWith(
                    color: AppColors.subTextColor,
                  ),
                ),
                AppSpaces.vSpace14,
                _buildPasswordField('Current Password', oldPasswordController),
                AppSpaces.vSpace10,
                _buildPasswordField('New Password', newPasswordController),
                AppSpaces.vSpace10,
                _buildPasswordField(
                  'Confirm New Password',
                  confirmPasswordController,
                ),
                AppSpaces.vSpace18,
                CustomButton(
                  text: 'Update Password',
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    if (oldPasswordController.text.isEmpty ||
                        newPasswordController.text.isEmpty) {
                      CustomSnackbar.showError(
                        title: 'Incomplete Fields',
                        message: 'Please complete all password fields.',
                      );
                      return;
                    }
                    if (newPasswordController.text !=
                        confirmPasswordController.text) {
                      CustomSnackbar.showError(
                        title: 'Password Mismatch',
                        message: 'New password and confirmation do not match.',
                      );
                      return;
                    }
                    Navigator.pop(ctx);
                    CustomSnackbar.showSuccess(
                      title: 'Password Updated',
                      message:
                          'Your corporate password was updated successfully.',
                    );
                  },
                ),
                AppSpaces.vSpace10,
              ],
            ),
          ),
        );
      },
    );
  }

  /// Helper textfield for password input
  Widget _buildPasswordField(String hint, TextEditingController ctrl) {
    return CustomTextField(
      controller: ctrl,
      hintText: hint,
      obscureText: true,
      prefixIcon: Icon(
        Icons.lock_outline_rounded,
        size: 16.sp,
        color: AppColors.secondary,
      ),
    );
  }

  /// Modal sheet for Workplace Settings & Preferences
  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.primary.withValues(alpha: 0.6),
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(22.r),
              topRight: Radius.circular(22.r),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.borderColor,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
              AppSpaces.vSpace14,
              Text(
                'Workplace Settings',
                style: AppTextStyles.text16.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              AppSpaces.vSpace4,
              Text(
                'Manage alerts, location presence, and biometric access.',
                style: AppTextStyles.text12.copyWith(
                  color: AppColors.subTextColor,
                ),
              ),
              AppSpaces.vSpace14,

              // Shift Reminders
              Obx(() {
                return _buildSettingRow(
                  icon: Icons.notifications_active_outlined,
                  title: 'Shift Reminders',
                  subtitle: 'Daily check-in / check-out alerts',
                  value: controller.shiftReminders.value,
                  onChanged: controller.toggleReminders,
                );
              }),

              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Divider(
                  height: 1,
                  thickness: 0.6,
                  color: AppColors.borderColor.withValues(alpha: 0.6),
                ),
              ),

              // Geofence Check
              Obx(() {
                return _buildSettingRow(
                  icon: Icons.location_on_outlined,
                  title: 'Geofence Presence Check',
                  subtitle: 'Validate presence at authorized job sites',
                  value: controller.geofenceAutoCheck.value,
                  onChanged: controller.toggleGeofence,
                );
              }),

              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Divider(
                  height: 1,
                  thickness: 0.6,
                  color: AppColors.borderColor.withValues(alpha: 0.6),
                ),
              ),

              // Biometric Punch
              Obx(() {
                return _buildSettingRow(
                  icon: Icons.fingerprint_rounded,
                  title: 'Biometric Login',
                  subtitle: 'Touch ID / Face unlock for rapid check-in',
                  value: controller.biometricPunch.value,
                  onChanged: controller.toggleBiometric,
                );
              }),

              AppSpaces.vSpace18,
              CustomButton(text: 'Done', onPressed: () => Navigator.pop(ctx)),
              AppSpaces.vSpace10,
            ],
          ),
        );
      },
    );
  }

  /// Helper row inside settings sheet
  Widget _buildSettingRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Container(
          width: 32.r,
          height: 32.r,
          decoration: BoxDecoration(
            color: const Color(0xFFEDE7F6),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 16.sp, color: const Color(0xFF5E35B1)),
        ),
        AppSpaces.hSpace10,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.text12.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              AppSpaces.vSpace2,
              Text(
                subtitle,
                style: AppTextStyles.text10.copyWith(
                  color: AppColors.subTextColor,
                ),
              ),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeTrackColor: AppColors.secondary.withValues(alpha: 0.35),
          activeThumbColor: AppColors.secondary,
        ),
      ],
    );
  }
}
