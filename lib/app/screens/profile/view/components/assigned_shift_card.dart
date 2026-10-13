import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../controller/profile_controller.dart';

class AssignedShiftCard extends GetView<ProfileController> {
  const AssignedShiftCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final p = controller.profile.value;
      final shiftName = p?.shiftName ?? 'General Corporate Shift';
      final shiftTime = p?.shiftTime ?? '09:00 AM - 06:00 PM';
      final graceMinutes = p?.graceMinutes ?? 15;
      final manager = p?.reportingManager ?? 'Hamza Sheikh (Lead Architect)';
      final location = p?.workLocation ?? 'SoftGenie HQ • 4th Floor';

      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.borderColor, width: 1.w),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.04),
              blurRadius: 12.r,
              offset: Offset(0, 3.h), 
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32.r,
                          height: 32.r,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.schedule_rounded,
                            size: 17.sp,
                            color: AppColors.primary,
                          ),
                        ),
                        AppSpaces.hSpace10,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Assigned Work Shift',
                              style: AppTextStyles.text14.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                            ),
                            Text(
                              'Standard corporate office schedule',
                              style: AppTextStyles.text10.copyWith(
                                color: AppColors.subTextColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Active Tag
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: AppColors.success.withValues(alpha: 0.3),
                          width: 0.8.w,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6.r,
                            height: 6.r,
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          AppSpaces.hSpace4,
                          Text(
                            'Active',
                            style: AppTextStyles.text10.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Divider(
                color: AppColors.borderColor,
                height: 1.h,
                thickness: 0.8.h,
              ),

              // Details Body
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                child: Column(
                  children: [
                    // Row 1: Shift Timing
                    _buildShiftDetailRow(
                      icon: Icons.access_time_filled_rounded,
                      iconColor: AppColors.secondary,
                      label: 'Timing & Hours',
                      value: '$shiftName\n$shiftTime',
                    ),

                    AppSpaces.vSpace10,

                    // Row 2: Grace Period
                    _buildShiftDetailRow(
                      icon: Icons.hourglass_top_rounded,
                      iconColor: AppColors.warning,
                      label: 'Grace Buffer',
                      value: '$graceMinutes Minutes Buffer Before Late Mark',
                    ),

                    AppSpaces.vSpace10,

                    // Row 3: Reporting Manager
                    _buildShiftDetailRow(
                      icon: Icons.supervisor_account_rounded,
                      iconColor: AppColors.primary,
                      label: 'Reporting Manager',
                      value: manager,
                    ),

                    AppSpaces.vSpace10,

                    // Row 4: Location
                    _buildShiftDetailRow(
                      icon: Icons.location_on_rounded,
                      iconColor: AppColors.error,
                      label: 'Assigned Worksite',
                      value: location,
                    ),
                  ],
                ),
              ),

              // Dedicated bottom accent strip
            ],
          ),
        ),
      );
    });
  }

  Widget _buildShiftDetailRow({
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
                  color: AppColors.subTextColor,
                ),
              ),
              AppSpaces.vSpace2,
              Text(
                value,
                style: AppTextStyles.text12.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
