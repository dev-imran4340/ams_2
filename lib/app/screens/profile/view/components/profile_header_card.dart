import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../controller/profile_controller.dart';

class ProfileHeaderCard extends GetView<ProfileController> {
  const ProfileHeaderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final p = controller.profile.value;
      final name = p?.name ?? 'Malik Muhammad Imran';
      final designation = p?.designation ?? 'Senior Software Engineer & Tech Lead';
      final employeeId = p?.employeeId ?? 'EMP-1024';
      final department = p?.department ?? 'Engineering';
      final tenure = p?.tenureYears ?? '2.8 Yrs';
      final score = p?.attendanceScore ?? 98.4;
      final initials = p?.initials ?? 'MI';

      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: AppColors.borderColor,
            width: 1.w,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.05),
              blurRadius: 16.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Column(
          children: [
            // Avatar with Online Beacon and Profile Meta
            Row(
              children: [
                // Avatar with Beacon
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 62.r,
                      height: 62.r,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.accentNavy,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.secondary.withValues(alpha: 0.4),
                          width: 2.w,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            blurRadius: 10.r,
                            offset: Offset(0, 3.h),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        initials,
                        style: AppTextStyles.text22.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                    ),

                    // Active Online Status Beacon
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 15.r,
                        height: 15.r,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.cardBackground,
                            width: 2.w,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                AppSpaces.hSpace14,

                // Employee Info Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
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
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              'Verified',
                              style: AppTextStyles.text10.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      AppSpaces.vSpace2,
                      Text(
                        designation,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.text12.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      AppSpaces.vSpace4,
                      Row(
                        children: [
                          Icon(
                            Icons.badge_outlined,
                            size: 13.sp,
                            color: AppColors.subTextColor,
                          ),
                          AppSpaces.hSpace4,
                          Text(
                            '#$employeeId • HQ Office',
                            style: AppTextStyles.text10.copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppColors.subTextColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            AppSpaces.vSpace16,

            // Quick Stats Pill Row: Department | Tenure | Attendance
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.borderColor,
                  width: 0.8.w,
                ),
              ),
              child: Row(
                children: [
                  // Stat 1: Department
                  Expanded(
                    child: _buildStatItem(
                      label: 'DEPARTMENT',
                      value: department.split(' ').first,
                      icon: Icons.domain_rounded,
                      color: AppColors.primary,
                    ),
                  ),

                  _buildDivider(),

                  // Stat 2: Tenure
                  Expanded(
                    child: _buildStatItem(
                      label: 'TENURE',
                      value: tenure,
                      icon: Icons.timeline_rounded,
                      color: AppColors.secondary,
                    ),
                  ),

                  _buildDivider(),

                  // Stat 3: Attendance Score
                  Expanded(
                    child: _buildStatItem(
                      label: 'ATTENDANCE',
                      value: '$score%',
                      icon: Icons.verified_rounded,
                      color: AppColors.success,
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

  Widget _buildDivider() {
    return Container(
      width: 1.w,
      height: 26.h,
      color: AppColors.borderColor,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 12.sp, color: color),
            AppSpaces.hSpace4,
            Text(
              label,
              style: AppTextStyles.text10.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 8.5.sp,
                color: AppColors.subTextColor,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
        AppSpaces.vSpace2,
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.text12.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
        ),
      ],
    );
  }
}
