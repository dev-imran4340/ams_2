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
      final email = p?.email ?? 'maryam@example.com';
      final empId = p?.employeeNumber ?? 'EMP-0002';
      final is2FA = AppPreferences.isTwoFactorEnabled;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Sign-In Credentials & Identity
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
                _buildInfoRow('Login Identifier', email, Icons.alternate_email_rounded),
                _buildDivider(),
                _buildInfoRow('Employee Identifier', empId, Icons.badge_outlined),
                _buildDivider(),
                _buildInfoRow(
                  'Two-Factor Authentication',
                  is2FA ? 'Enabled' : 'Disabled (Optional)',
                  Icons.phonelink_lock_rounded,
                ),
              ],
            ),
          ),

          AppSpaces.vSpace14,

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

          AppSpaces.vSpace14,

          // 3. Workplace Preferences & Toggles
          const PreferenceToggleHub(),
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
