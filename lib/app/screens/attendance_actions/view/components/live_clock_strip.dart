import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../controller/attendance_actions_controller.dart';

class LiveClockStrip extends GetView<AttendanceActionsController> {
  const LiveClockStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.borderColor, width: 1.w),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Calendar Date and Live Beacon
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.calendar_today_rounded,
                  size: 16.sp,
                  color: AppColors.secondary,
                ),
              ),
              AppSpaces.hSpace10,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CURRENT LOCAL TIME',
                    style: AppTextStyles.text10.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: AppColors.subTextColor,
                    ),
                  ),
                  AppSpaces.vSpace2,
                  Obx(
                    () => Text(
                      controller.liveDate.value.isEmpty
                          ? 'Today'
                          : controller.liveDate.value,
                      style: AppTextStyles.text12.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Right: Tabular Live Digital Clock
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.inputFill.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: AppColors.borderColor.withValues(alpha: 0.8),
                width: 1.w,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7.r,
                  height: 7.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.onTimeColor,
                  ),
                ),
                AppSpaces.hSpace8,
                Obx(
                  () => Text(
                    controller.liveClock.value.isEmpty
                        ? '--:--:--'
                        : controller.liveClock.value,
                    style: AppTextStyles.text14.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                      letterSpacing: 0.8,
                      fontFeatures: const [
                        FontFeature.tabularFigures(),
                      ],
                    ),
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
