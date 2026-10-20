import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../controller/attendance_actions_controller.dart';

class ActiveBreakCard extends GetView<AttendanceActionsController> {
  const ActiveBreakCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final t = controller.telemetry.value;
      final isOnBreak = t?.isOnBreak ?? false;
      if (!isOnBreak) return const SizedBox.shrink();

      final startTime = t?.breakStartTime ?? '01:00 PM';
      final allowedLimit = t?.allowedBreakLimit ?? '45 mins';
      final elapsed = controller.elapsedBreakTimer.value;
      final isEndingBreak = controller.isBreakActionLoading.value;

      return Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.warning.withValues(alpha: 0.12),
              AppColors.cardBackground,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.warning.withValues(alpha: 0.45),
            width: 1.5.w,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.warning.withValues(alpha: 0.15),
              blurRadius: 16.r,
              offset: Offset(0, 6.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Coffee Icon & Pulsing "Break Active" Pill
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.coffee_rounded,
                        color: AppColors.warning,
                        size: 20.sp,
                      ),
                    ),
                    AppSpaces.hSpace10,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Break in Progress',
                          style: AppTextStyles.text14.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                        AppSpaces.vSpace2,
                        Text(
                          'Started at $startTime • Max $allowedLimit',
                          style: AppTextStyles.text10.copyWith(
                            color: AppColors.subTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Pulsing Amber Beacon
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.5),
                      width: 1.w,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6.r,
                        height: 6.r,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.warning,
                        ),
                      ),
                      AppSpaces.hSpace6,
                      Text(
                        'RECESS',
                        style: AppTextStyles.text10.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            AppSpaces.vSpace12,

            // Live Elapsed Break Digital Counter
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 10.h),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.borderColor,
                  width: 1.w,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'ELAPSED BREAK DURATION',
                    style: AppTextStyles.text10.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: AppColors.subTextColor,
                    ),
                  ),
                  AppSpaces.vSpace4,
                  Text(
                    elapsed,
                    style: AppTextStyles.text24.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.warning,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),

            AppSpaces.vSpace12,

            // Conclude Break Quick Action Button
            CustomButton(
              text: 'End Break & Resume Work',
              isGradient: true,
              isLoading: isEndingBreak,
              onPressed: controller.handleEndBreak,
              icon: Icon(
                Icons.work_history_rounded,
                color: AppColors.white,
                size: 18.sp,
              ),
            ),
          ],
        ),
      );
    });
  }
}
