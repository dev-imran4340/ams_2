import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:flutter/services.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../routes/app_routes.dart';
import '../../controller/dashboard_controller.dart';
import 'attendance_slider_button.dart';

class LiveShiftClockCard extends GetView<DashboardController> {
  const LiveShiftClockCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderColor, width: 1.w),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 24.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
              child: Column(
                children: [
                  // 1. Top Shift Title & Geofence Status Pill
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Shift Badge
                      Obx(() {
                        final shift =
                            controller
                                .dashboardData
                                .value
                                ?.todayAttendance
                                .shiftName ??
                            'General Shift';
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.liteSecondary.withValues(
                              alpha: 0.3,
                            ),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: AppColors.secondary.withValues(
                                alpha: 0.25,
                              ),
                              width: 1.w,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                size: 14.sp,
                                color: AppColors.secondary,
                              ),
                              AppSpaces.hSpace6,
                              Text(
                                shift,
                                style: AppTextStyles.text10.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      // Geofence Radar Status Chip
                      Obx(() {
                        final radiusStatus =
                            controller
                                .dashboardData
                                .value
                                ?.todayAttendance
                                .officeRadiusStatus ??
                            'Inside Office Perimeter (25m)';
                        final isInside = radiusStatus.toLowerCase().contains(
                          'inside',
                        );

                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: isInside
                                ? AppColors.onTimeColor.withValues(alpha: 0.1)
                                : AppColors.absentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: isInside
                                  ? AppColors.onTimeColor.withValues(alpha: 0.3)
                                  : AppColors.absentColor.withValues(
                                      alpha: 0.3,
                                    ),
                              width: 1.w,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6.r,
                                height: 6.r,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isInside
                                      ? AppColors.onTimeColor
                                      : AppColors.absentColor,
                                ),
                              ),
                              AppSpaces.hSpace6,
                              Text(
                                isInside
                                    ? 'In Perimeter (25m)'
                                    : 'Outside Office',
                                style: AppTextStyles.text10.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isInside
                                      ? AppColors.onTimeColor
                                      : AppColors.absentColor,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),

                  AppSpaces.vSpace14,

                  // 2. Center Live Digital Clock Display
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.inputFill.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: AppColors.borderColor.withValues(alpha: 0.8),
                        width: 1.w,
                      ),
                    ),
                    child: Column(
                      children: [
                        Obx(
                          () => Text(
                            controller.liveClock.value.isEmpty
                                ? '--:--:--'
                                : controller.liveClock.value,
                            style: AppTextStyles.text28.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor,
                              letterSpacing: 1.4,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ),
                        AppSpaces.vSpace4,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 12.sp,
                              color: AppColors.secondary,
                            ),
                            AppSpaces.hSpace6,
                            Obx(
                              () => Text(
                                controller.liveDate.value,
                                style: AppTextStyles.text12.copyWith(
                                  color: AppColors.subTextColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  AppSpaces.vSpace12,

                  // 3. Shift Duration & Elapsed Counter Telemetry Bar
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.inputFill.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: AppColors.borderColor.withValues(alpha: 0.7),
                        width: 1.w,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left: Shift Timing
                        Obx(() {
                          final timing =
                              controller
                                  .dashboardData
                                  .value
                                  ?.todayAttendance
                                  .shiftTiming ??
                              '09:00 AM - 06:00 PM';
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Shift Timing',
                                style: AppTextStyles.text10.copyWith(
                                  color: AppColors.subTextColor,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              AppSpaces.vSpace2,
                              Text(
                                timing,
                                style: AppTextStyles.text12.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ],
                          );
                        }),

                        // Right: Live Shift Elapsed Counter Pill
                        Obx(() {
                          final isCheckedIn =
                              controller
                                  .dashboardData
                                  .value
                                  ?.todayAttendance
                                  .isCheckedIn ??
                              false;
                          final elapsed = controller.elapsedShiftTimer.value;

                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: isCheckedIn
                                  ? AppColors.onTimeColor.withValues(
                                      alpha: 0.12,
                                    )
                                  : AppColors.borderColor.withValues(
                                      alpha: 0.4,
                                    ),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: isCheckedIn
                                    ? AppColors.onTimeColor.withValues(
                                        alpha: 0.3,
                                      )
                                    : AppColors.borderColor,
                                width: 1.w,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6.r,
                                  height: 6.r,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isCheckedIn
                                        ? AppColors.onTimeColor
                                        : AppColors.subTextColor,
                                  ),
                                ),
                                AppSpaces.hSpace6,
                                Text(
                                  isCheckedIn ? elapsed : 'Not Started',
                                  style: AppTextStyles.text10.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isCheckedIn
                                        ? AppColors.onTimeColor
                                        : AppColors.subTextColor,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  AppSpaces.vSpace14,

                  // 4. Interactive Slide-to-Confirm Punch Button
                  const AttendanceSliderButton(),

                  AppSpaces.vSpace10,

                  // 5. Open Dedicated Attendance Actions & Break Management Portal
                  InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Get.toNamed(Routes.ATTENDANCE_ACTIONS);
                    },
                    borderRadius: BorderRadius.circular(10.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 9.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: AppColors.secondary.withValues(alpha: 0.25),
                          width: 1.w,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.touch_app_rounded,
                                size: 16.sp,
                                color: AppColors.secondary,
                              ),
                              AppSpaces.hSpace8,
                              Text(
                                'Attendance Actions & Breaks Hub',
                                style: AppTextStyles.text12.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                'Breaks & More',
                                style: AppTextStyles.text10.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.secondary,
                                ),
                              ),
                              AppSpaces.hSpace4,
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 11.sp,
                                color: AppColors.secondary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Signature Teal Accent Border
          ],
        ),
      ),
    );
  }
}
