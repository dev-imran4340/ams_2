import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../controller/profile_controller.dart';

class ProfileEmergencyCard extends GetView<ProfileController> {
  const ProfileEmergencyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final p = controller.profile.value;
      final address =
          p?.address ?? 'House #42, Street 8, Sector G-11/1';
      final city = p?.city ?? 'Islamabad';
      final postalCode = p?.postalCode ?? '44000';
      final emergencyName = p?.emergencyContactName ?? 'Tariq Mehmood';
      final emergencyPhone = p?.emergencyContactPhone ?? '+92 321 7654321';
      final emergencyRelation = p?.emergencyContactRelation ?? 'Brother';

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
                          color: AppColors.warning.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.contact_emergency_rounded,
                          size: 17.sp,
                          color: AppColors.warning,
                        ),
                      ),
                      AppSpaces.hSpace10,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Address & Emergency Contact',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.text14.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                            ),
                            AppSpaces.vSpace2,
                            Text(
                              'Residential location & next of kin',
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

            // Residential Address
            _buildInfoRow(
              icon: Icons.home_outlined,
              iconColor: AppColors.primary,
              label: 'RESIDENTIAL ADDRESS',
              value: '$address, $city • $postalCode',
            ),

            AppSpaces.vSpace10,

            // Emergency Contact Person & Relation
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    icon: Icons.person_pin_circle_outlined,
                    iconColor: AppColors.warning,
                    label: 'EMERGENCY CONTACT',
                    value: emergencyName,
                  ),
                ),
                AppSpaces.hSpace10,
                Expanded(
                  child: _buildInfoRow(
                    icon: Icons.people_outline_rounded,
                    iconColor: AppColors.info,
                    label: 'RELATIONSHIP',
                    value: emergencyRelation,
                  ),
                ),
              ],
            ),

            AppSpaces.vSpace10,

            // Emergency Phone Number
            _buildInfoRow(
              icon: Icons.phone_in_talk_rounded,
              iconColor: AppColors.error,
              label: 'EMERGENCY PHONE NUMBER',
              value: emergencyPhone,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildInfoRow({
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
