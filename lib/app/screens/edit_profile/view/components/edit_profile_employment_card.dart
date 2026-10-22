import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../controller/edit_profile_controller.dart';

class EditProfileEmploymentCard extends GetView<EditProfileController> {
  const EditProfileEmploymentCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final p = controller.currentProfile.value;
      final employeeId = p?.employeeId ?? 'EMP-1024';
      final department = p?.department ?? 'Engineering & Mobility';
      final designation =
          p?.designation ?? 'Senior Software Engineer & Tech Lead';
      final reportingLead =
          p?.reportingManager ?? 'Hamza Sheikh (Lead Architect)';
      final shift = p?.shiftName ?? 'General Corporate Shift';

      return CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Locked Badge
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 32.r,
                        height: 32.r,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.domain_rounded,
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
                              'Organization & Role',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.text14.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                            ),
                            AppSpaces.vSpace2,
                            Text(
                              'Corporate placement & shift',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.text10.copyWith(
                                color: AppColors.subTextColor,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpaces.hSpace8,
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 3.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(
                      color: AppColors.borderColor,
                      width: 0.8.w,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        size: 11.sp,
                        color: AppColors.subTextColor,
                      ),
                      AppSpaces.hSpace4,
                      Text(
                        'HR Managed',
                        style: AppTextStyles.text10.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.subTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            AppSpaces.vSpace14,

            // Read-only Details Grid/List
            _buildReadOnlyTile(
              label: 'EMPLOYEE ID',
              value: employeeId,
              icon: Icons.tag_rounded,
            ),
            AppSpaces.vSpace10,
            _buildReadOnlyTile(
              label: 'DESIGNATION',
              value: designation,
              icon: Icons.work_outline_rounded,
            ),
            AppSpaces.vSpace10,
            _buildReadOnlyTile(
              label: 'DEPARTMENT',
              value: department,
              icon: Icons.apartment_rounded,
            ),
            AppSpaces.vSpace10,
            _buildReadOnlyTile(
              label: 'REPORTING MANAGER',
              value: reportingLead,
              icon: Icons.supervisor_account_outlined,
            ),
            AppSpaces.vSpace10,
            _buildReadOnlyTile(
              label: 'ASSIGNED SHIFT',
              value: shift,
              icon: Icons.schedule_rounded,
            ),

            AppSpaces.vSpace14,

            // Enterprise Disclaimer Banner
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  width: 0.8.w,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 14.sp,
                    color: AppColors.secondary,
                  ),
                  AppSpaces.hSpace8,
                  Expanded(
                    child: Text(
                      'Official organization roles, reporting managers, and shifts can only be altered by your HR portal administrator.',
                      style: AppTextStyles.text10.copyWith(
                        color: AppColors.subTextColor,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildReadOnlyTile({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16.sp, color: AppColors.primary),
          AppSpaces.hSpace10,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.text10.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 8.5.sp,
                    color: AppColors.subTextColor,
                    letterSpacing: 0.5,
                  ),
                ),
                AppSpaces.vSpace2,
                Text(
                  value,
                  style: AppTextStyles.text12.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
