import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../controller/profile_controller.dart';

class ProfileEmploymentCard extends GetView<ProfileController> {
  const ProfileEmploymentCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final p = controller.profile.value;
      final designation =
          p?.designation ?? 'Senior Software Engineer & Tech Lead';
      final department = p?.department ?? 'Engineering & Mobility';
      final employeeId = p?.employeeId ?? 'EMP-1024';
      final joiningDate = p?.joiningDate ?? '15 Jan 2024';
      final manager = p?.reportingManager ?? 'Hamza Sheikh (Lead Architect)';
      final tenure = p?.tenureYears ?? '2.8 Yrs';
      final location =
          p?.workLocation ?? 'Softech Business Services HQ • 4th Floor';

      return CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Icon & Active Tag
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
                          Icons.apartment_rounded,
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
                              'Organization & Placement',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.text14.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                            ),
                            AppSpaces.vSpace2,
                            Text(
                              'Official corporate placement & department',
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
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 7.w,
                    vertical: 2.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    'Full-Time',
                    style: AppTextStyles.text10.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
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

            // Row 1: Designation & Department
            _buildInfoRow(
              icon: Icons.work_outline_rounded,
              iconColor: AppColors.primary,
              label: 'DESIGNATION & ROLE',
              value: '$designation\n$department',
            ),

            AppSpaces.vSpace10,

            // Row 2: Employee ID & Joining
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    icon: Icons.tag_rounded,
                    iconColor: AppColors.secondary,
                    label: 'EMPLOYEE ID',
                    value: employeeId,
                  ),
                ),
                AppSpaces.hSpace10,
                Expanded(
                  child: _buildInfoRow(
                    icon: Icons.event_available_rounded,
                    iconColor: AppColors.info,
                    label: 'JOINING DATE',
                    value: '$joiningDate ($tenure)',
                  ),
                ),
              ],
            ),

            AppSpaces.vSpace10,

            // Row 3: Reporting Manager
            _buildInfoRow(
              icon: Icons.supervisor_account_outlined,
              iconColor: AppColors.warning,
              label: 'REPORTING LEAD / MANAGER',
              value: manager,
            ),

            AppSpaces.vSpace10,

            // Row 4: Work Location
            _buildInfoRow(
              icon: Icons.location_city_rounded,
              iconColor: AppColors.error,
              label: 'PRIMARY WORKSTATION',
              value: location,
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
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
