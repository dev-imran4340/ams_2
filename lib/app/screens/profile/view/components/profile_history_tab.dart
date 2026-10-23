import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../controller/profile_controller.dart';

class ProfileHistoryTab extends GetView<ProfileController> {
  const ProfileHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final p = controller.profile.value;
      final job = p?.job;
      final designation = p?.designation ?? job?.designation ?? 'Sales Manager';
      final company = job?.legalEntity ?? 'Kumash (Pvt) Ltd';
      final joinedOn = job?.joinedOn ?? '2023-07-15';
      final id = p?.id ?? '01m5kmp9g8wxp9ssn3aed8awzm';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                        color: AppColors.secondary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.timeline_rounded,
                        size: 16.sp,
                        color: AppColors.secondary,
                      ),
                    ),
                    AppSpaces.hSpace8,
                    Text(
                      'Career & Employment History',
                      style: AppTextStyles.text14.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                  ],
                ),
                AppSpaces.vSpace16,

                // Event 1: Current Active Role
                _buildTimelineItem(
                  title: designation,
                  subtitle: '$company • Head office',
                  dateRange: 'Jul 2023 — Present',
                  badgeText: 'Current Role',
                  badgeColor: AppColors.secondary,
                  isFirst: true,
                  isLast: false,
                ),

                // Event 2: Official Onboarding & Joining
                _buildTimelineItem(
                  title: 'Corporate Onboarding & Joining',
                  subtitle: 'Successfully inducted into Sales Department',
                  dateRange: joinedOn,
                  badgeText: 'Milestone',
                  badgeColor: AppColors.primary,
                  isFirst: false,
                  isLast: true,
                ),
              ],
            ),
          ),

          AppSpaces.vSpace14,

          // Audit Telemetry Card
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppColors.borderColor,
                width: 1.w,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.fingerprint_rounded,
                  size: 20.sp,
                  color: AppColors.secondary,
                ),
                AppSpaces.hSpace10,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Audit Record ULID',
                        style: AppTextStyles.text10.copyWith(
                          color: AppColors.subTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        id,
                        style: AppTextStyles.text12.copyWith(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildTimelineItem({
    required String title,
    required String subtitle,
    required String dateRange,
    required String badgeText,
    required Color badgeColor,
    required bool isFirst,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left timeline node & line
        Column(
          children: [
            Container(
              width: 14.r,
              height: 14.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: badgeColor,
                border: Border.all(
                  color: AppColors.white,
                  width: 2.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: badgeColor.withValues(alpha: 0.3),
                    blurRadius: 6.r,
                  ),
                ],
              ),
            ),
            if (!isLast)
              Container(
                width: 2.w,
                height: 55.h,
                color: AppColors.borderColor,
              ),
          ],
        ),

        AppSpaces.hSpace12,

        // Right details
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.text12.copyWith(
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
                        color: badgeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        badgeText,
                        style: AppTextStyles.text10.copyWith(
                          fontWeight: FontWeight.bold,
                          color: badgeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpaces.vSpace2,
                Text(
                  subtitle,
                  style: AppTextStyles.text10.copyWith(
                    color: AppColors.subTextColor,
                  ),
                ),
                AppSpaces.vSpace4,
                Text(
                  dateRange,
                  style: AppTextStyles.text10.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
