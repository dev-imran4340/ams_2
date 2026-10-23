import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../api/app_preferences.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../controller/profile_controller.dart';

class ProfileHeaderCard extends GetView<ProfileController> {
  final bool isClickable;
  final VoidCallback? onTap;

  const ProfileHeaderCard({
    super.key,
    this.isClickable = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final p = controller.profile.value;
      final name = p?.name ?? AppPreferences.userName ?? 'Maryam Malik';
      final designation = p?.designation ?? 'Sales Manager';
      final employeeId = p?.employeeNumber ?? p?.employeeId ?? 'EMP-0002';
      final department = p?.department ?? 'Sales';
      final location = p?.workLocation ?? 'Head office';
      final tenure = p?.tenureYears ?? '3 years 3 months';
      final stage = p?.stageLabel ?? 'Active';
      final initials = p?.initials ?? 'MM';
      final avatarPath = p?.avatarPath;
      final hasLocalAvatar =
          avatarPath != null && File(avatarPath).existsSync();

      return CustomCard(
        onTap: isClickable
            ? (onTap ?? controller.navigateToProfileDetails)
            : null,
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
                      width: 60.r,
                      height: 60.r,
                      decoration: BoxDecoration(
                        gradient: !hasLocalAvatar
                            ? const LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.accentNavy,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
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
                      child: ClipOval(
                        child: hasLocalAvatar
                            ? Image.file(
                                File(avatarPath),
                                width: 60.r,
                                height: 60.r,
                                fit: BoxFit.cover,
                              )
                            : Text(
                                initials,
                                style: AppTextStyles.text20.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.white,
                                ),
                              ),
                      ),
                    ),

                    // Active Online Status Beacon
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 14.r,
                        height: 14.r,
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
                              horizontal: 7.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              stage,
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
                          Flexible(
                            child: Text(
                              '#$employeeId • $location',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.text10.copyWith(
                                fontWeight: FontWeight.w500,
                                color: AppColors.subTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            AppSpaces.vSpace12,

            // Quick Stats Pill Row: Department | Location | Tenure
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(10.r),
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
                      value: department,
                      icon: Icons.domain_rounded,
                      color: AppColors.primary,
                    ),
                  ),

                  _buildDivider(),

                  // Stat 2: Tenure
                  Expanded(
                    child: _buildStatItem(
                      label: 'SERVICE',
                      value: tenure,
                      icon: Icons.timeline_rounded,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),

            if (isClickable) ...[
              AppSpaces.vSpace12,
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.22),
                    width: 0.8.w,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.badge_outlined,
                      size: 15.sp,
                      color: AppColors.secondary,
                    ),
                    AppSpaces.hSpace8,
                    Expanded(
                      child: Text(
                        'View Full Details & Official Records',
                        style: AppTextStyles.text12.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12.sp,
                      color: AppColors.secondary,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 14.sp, color: color),
        AppSpaces.hSpace6,
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.text10.copyWith(
                  letterSpacing: 0.6,
                  fontWeight: FontWeight.w600,
                  color: AppColors.subTextColor,
                ),
              ),
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
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 22.h,
      width: 1.w,
      color: AppColors.borderColor.withValues(alpha: 0.8),
    );
  }
}
