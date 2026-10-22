import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../controller/profile_controller.dart';

class ProfilePersonalDetailsCard extends GetView<ProfileController> {
  const ProfilePersonalDetailsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final p = controller.profile.value;
      final email = p?.email ?? 'imran@Softech Business Services.com';
      final phone = p?.phone ?? '+92 300 1234567';
      final cnic = p?.cnic ?? '37405-1234567-1';
      final dob = p?.dob ?? '14 May 1996';
      final gender = p?.gender ?? 'Male';
      final bloodGroup = p?.bloodGroup ?? 'O+';

      return CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Icon & Edit Shortcut
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 32.r,
                        height: 32.r,
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person_pin_rounded,
                          size: 17.sp,
                          color: AppColors.secondary,
                        ),
                      ),
                      AppSpaces.hSpace10,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Personal Information',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.text14.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                            ),
                            AppSpaces.vSpace2,
                            Text(
                              'Identity credentials & contact records',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.text10.copyWith(
                                color: AppColors.subTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpaces.hSpace8,
                InkWell(
                  onTap: controller.navigateToEditProfile,
                  borderRadius: BorderRadius.circular(8.r),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 13.sp,
                          color: AppColors.secondary,
                        ),
                        AppSpaces.hSpace4,
                        Text(
                          'Edit',
                          style: AppTextStyles.text10.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            AppSpaces.vSpace12,

            Divider(
              color: AppColors.borderColor,
              height: 1.h,
              thickness: 0.8.h,
            ),

            AppSpaces.vSpace12,

            // Detail 1: Official Corporate Email
            _buildDetailRow(
              icon: Icons.email_outlined,
              iconColor: AppColors.primary,
              label: 'OFFICIAL CORPORATE EMAIL',
              value: email,
            ),

            AppSpaces.vSpace10,

            // Detail 2: Contact Phone Number
            _buildDetailRow(
              icon: Icons.phone_android_rounded,
              iconColor: AppColors.secondary,
              label: 'CONTACT MOBILE NUMBER',
              value: phone,
            ),

            AppSpaces.vSpace10,

            // Detail 3: National ID / CNIC
            _buildDetailRow(
              icon: Icons.credit_card_rounded,
              iconColor: AppColors.warning,
              label: 'NATIONAL IDENTITY (CNIC)',
              value: cnic,
            ),

            AppSpaces.vSpace10,

            // Detail 4: Date of Birth & Gender / Blood Group Grid
            Row(
              children: [
                Expanded(
                  child: _buildDetailRow(
                    icon: Icons.cake_outlined,
                    iconColor: AppColors.info,
                    label: 'DATE OF BIRTH',
                    value: dob,
                  ),
                ),
                AppSpaces.hSpace10,
                Expanded(
                  child: _buildDetailRow(
                    icon: Icons.bloodtype_outlined,
                    iconColor: AppColors.error,
                    label: 'GENDER & BLOOD',
                    value: '$gender • $bloodGroup',
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28.r,
          height: 28.r,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 14.sp, color: iconColor),
        ),
        AppSpaces.hSpace10,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.text10.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 8.5.sp,
                  color: AppColors.subTextColor,
                  letterSpacing: 0.4,
                ),
              ),
              AppSpaces.vSpace2,
              Text(
                value,
                style: AppTextStyles.text12.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
