import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_spaces.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../model/employee_terminal_model.dart';

class AttendanceSuccessOverlay extends StatelessWidget {
  final PunchRecordItem punch;

  const AttendanceSuccessOverlay({
    super.key,
    required this.punch,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCheckIn = punch.isCheckIn;
    final Color badgeColor = isCheckIn ? AppColors.success : AppColors.warning;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: badgeColor.withValues(alpha: 0.18),
            blurRadius: 24.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.r),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            border: Border(
              bottom: BorderSide(
                color: AppColors.secondary,
                width: 3.w,
              ),
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Glowing Checkmark Emblem
              Container(
                width: 64.r,
                height: 64.r,
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: badgeColor,
                    width: 2.5.w,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: badgeColor.withValues(alpha: 0.3),
                      blurRadius: 16.r,
                      spreadRadius: 2.r,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 38.sp,
                    color: badgeColor,
                  ),
                ),
              ),

              AppSpaces.vSpace14,

              // Punch Type Capsule
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: badgeColor.withValues(alpha: 0.4),
                    width: 1.w,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isCheckIn ? Icons.login_rounded : Icons.logout_rounded,
                      size: 14.sp,
                      color: badgeColor,
                    ),
                    AppSpaces.hSpace6,
                    Text(
                      isCheckIn
                          ? 'CHECK-IN RECORDED'
                          : 'CHECK-OUT RECORDED',
                      style: AppTextStyles.text10.copyWith(
                        fontWeight: FontWeight.bold,
                        color: badgeColor,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),

              AppSpaces.vSpace12,

              // Employee Name
              Text(
                punch.employeeName,
                textAlign: TextAlign.center,
                style: AppTextStyles.text18.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                  letterSpacing: -0.2,
                ),
              ),

              AppSpaces.vSpace4,

              // Employee ID & Department
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      '#${punch.employeeId}',
                      style: AppTextStyles.text10.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  AppSpaces.hSpace8,
                  Flexible(
                    child: Text(
                      punch.department,
                      style: AppTextStyles.text12.copyWith(
                        color: AppColors.subTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              AppSpaces.vSpace14,

              // Timestamp & Match Confidence
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: AppColors.borderColor, width: 1.w),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_filled_rounded,
                          size: 14.sp,
                          color: AppColors.primary,
                        ),
                        AppSpaces.hSpace6,
                        Text(
                          'Today at ${punch.formattedTime}',
                          style: AppTextStyles.text10.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          size: 14.sp,
                          color: AppColors.secondary,
                        ),
                        AppSpaces.hSpace4,
                        Text(
                          'Match: ${punch.matchConfidence}%',
                          style: AppTextStyles.text10.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              AppSpaces.vSpace10,

              // Auto-reset helper indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 10.r,
                    height: 10.r,
                    child: CircularProgressIndicator(
                      color: AppColors.secondary,
                      strokeWidth: 1.8.w,
                    ),
                  ),
                  AppSpaces.hSpace6,
                  Text(
                    'Resetting for next employee in 2.5s...',
                    style: AppTextStyles.text8.copyWith(
                      color: AppColors.subTextColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
