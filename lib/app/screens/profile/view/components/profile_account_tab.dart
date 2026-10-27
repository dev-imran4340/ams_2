import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../api/app_preferences.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../controller/profile_controller.dart';
import 'preference_toggle_tile.dart';

class ProfileAccountTab extends GetView<ProfileController> {
  const ProfileAccountTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final p = controller.profile.value;
      final isOther = controller.isViewingOtherEmployee.value;
      final email = (p?.email.isNotEmpty == true)
          ? p!.email
          : (p?.contact?.workEmail?.isNotEmpty == true
              ? p!.contact!.workEmail
              : (isOther ? null : AppPreferences.userEmail));
      final empId = (p?.employeeNumber.isNotEmpty == true)
          ? p!.employeeNumber
          : (p?.employeeId.isNotEmpty == true
              ? p!.employeeId
              : (isOther ? null : AppPreferences.employeeNumber));
      final is2FA = AppPreferences.isTwoFactorEnabled;

      final rows = <_AccountRowData>[];
      if (email != null && email.trim().isNotEmpty) {
        rows.add(_AccountRowData('Login Identifier', email, Icons.alternate_email_rounded));
      }
      if (empId != null && empId.trim().isNotEmpty) {
        rows.add(_AccountRowData('Employee Identifier', empId, Icons.badge_outlined));
      }
      if (!isOther) {
        rows.add(_AccountRowData(
          'Two-Factor Authentication',
          is2FA ? 'Enabled' : 'Disabled (Optional)',
          Icons.phonelink_lock_rounded,
        ));
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Sign-In Credentials & Identity
          if (rows.isNotEmpty) ...[
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32.r,
                        height: 32.r,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.lock_outline_rounded,
                          size: 16.sp,
                          color: AppColors.primary,
                        ),
                      ),
                      AppSpaces.hSpace8,
                      Text(
                        'Account & Security',
                        style: AppTextStyles.text14.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                    ],
                  ),
                  AppSpaces.vSpace14,
                  for (int i = 0; i < rows.length; i++) ...[
                    _buildInfoRow(rows[i].label, rows[i].value, rows[i].icon),
                    if (i < rows.length - 1) _buildDivider(),
                  ],
                ],
              ),
            ),
            AppSpaces.vSpace14,
          ],

          // 2. Digital ID Card Launcher Card (No Action - PDF opens in future)
          CustomCard(
            onTap: () {
              // Action disabled as per requirement: PDF viewer will open here in the future
            },
            child: Row(
              children: [
                Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.badge_outlined,
                    size: 22.sp,
                    color: AppColors.primary,
                  ),
                ),
                AppSpaces.hSpace12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Digital Employee ID Card',
                        style: AppTextStyles.text14.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                      AppSpaces.vSpace2,
                      Text(
                        'Official employee credentials PDF document',
                        style: AppTextStyles.text10.copyWith(
                          color: AppColors.subTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: AppColors.borderColor,
                      width: 0.8.w,
                    ),
                  ),
                  child: Text(
                    'PDF',
                    style: AppTextStyles.text10.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.subTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (!controller.isViewingOtherEmployee.value) ...[
            AppSpaces.vSpace14,
            // 3. Workplace Preferences & Toggles
            const PreferenceToggleHub(),

            AppSpaces.vSpace14,

            // 4. Workplace Sign Out Action Card
            CustomCard(
              onTap: () => controller.showLogoutConfirmation(context),
              child: Row(
                children: [
                  Container(
                    width: 38.r,
                    height: 38.r,
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.logout_rounded,
                      color: AppColors.error,
                      size: 20.sp,
                    ),
                  ),
                  AppSpaces.hSpace12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sign Out',
                          style: AppTextStyles.text14.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                          ),
                        ),
                        AppSpaces.vSpace2,
                        Text(
                          'Securely end workplace session on this device',
                          style: AppTextStyles.text10.copyWith(
                            color: AppColors.subTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.subTextColor,
                    size: 20.sp,
                  ),
                ],
              ),
            ),
          ],
        ],
      );
    });
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 15.sp, color: AppColors.secondary),
        AppSpaces.hSpace8,
        Text(
          label,
          style: AppTextStyles.text12.copyWith(
            color: AppColors.subTextColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        AppSpaces.hSpace8,
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 3,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.text12.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Divider(
        height: 1.h,
        color: AppColors.borderColor.withValues(alpha: 0.6),
      ),
    );
  }
}

class _AccountRowData {
  final String label;
  final String value;
  final IconData icon;
  const _AccountRowData(this.label, this.value, this.icon);
}
