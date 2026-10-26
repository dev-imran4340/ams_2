import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:flutter/services.dart';
import '../../../../api/app_preferences.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../routes/app_routes.dart';
import '../../../main_shell/controller/session_me_controller.dart';
import '../../controller/dashboard_controller.dart';
import 'attendance_slider_button.dart';

class LiveShiftClockCard extends GetView<DashboardController> {
  const LiveShiftClockCard({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionMe = Get.isRegistered<SessionMeController>()
        ? Get.find<SessionMeController>()
        : Get.put(SessionMeController(), permanent: true);

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
                  // 1. Top Shift Title & Company Code Pill (from auth/me)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Shift Badge
                      Flexible(
                        child: Obx(() {
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
                                Flexible(
                                  child: Text(
                                    shift,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.text10.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),

                      AppSpaces.hSpace8,

                      // Company Code Pill strictly from auth/me (replaces perimeter 25m)
                      Obx(() {
                        final code = sessionMe.company.value?.code ??
                            AppPreferences.companyCode ??
                            'K7MP2Q';

                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              width: 1.w,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.business_rounded,
                                size: 13.sp,
                                color: AppColors.primary,
                              ),
                              AppSpaces.hSpace4,
                              Text(
                                'Company: $code',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.text10.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),

                  AppSpaces.vSpace14,

                  // 2. Center Shift Timer & Live Real-Time Clock
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
                        // Live Real-Time Wall Clock & Date header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 13.sp,
                              color: AppColors.secondary,
                            ),
                            AppSpaces.hSpace4,
                            Obx(
                              () => Text(
                                controller.liveClock.value.isEmpty
                                    ? '--:--'
                                    : controller.liveClock.value,
                                style: AppTextStyles.text12.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.subTextColor,
                                ),
                              ),
                            ),
                            AppSpaces.hSpace8,
                            Text(
                              '•',
                              style: TextStyle(color: AppColors.borderColor),
                            ),
                            AppSpaces.hSpace8,
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 11.sp,
                              color: AppColors.secondary,
                            ),
                            AppSpaces.hSpace4,
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

                        AppSpaces.vSpace8,

                        // Prominent Shift Timer (00:00:00 when unpunched, running from 0 on check-in, frozen on check-out)
                        Obx(() {
                          final today =
                              controller.dashboardData.value?.todayAttendance;
                          final isCheckedIn = today?.isCheckedIn ?? false;
                          final isCheckedOut = (today?.checkOutTime != null &&
                              today?.checkOutTime != '--:--');

                          String timerText;
                          String statusText;
                          Color statusColor;

                          if (isCheckedIn) {
                            timerText = controller.elapsedShiftTimer.value;
                            statusText =
                                'Shift In Progress • Started at ${today?.checkInTime}';
                            statusColor = AppColors.onTimeColor;
                          } else if (isCheckedOut) {
                            timerText = today?.workingHours ?? '00h 00m';
                            statusText =
                                'Shift Completed • Ended at ${today?.checkOutTime}';
                            statusColor = AppColors.secondary;
                          } else {
                            timerText = '00:00:00';
                            statusText =
                                'Shift Not Started • Swipe to Check In';
                            statusColor = AppColors.subTextColor;
                          }

                          return Column(
                            children: [
                              Text(
                                timerText,
                                style: AppTextStyles.text28.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isCheckedIn
                                      ? AppColors.secondary
                                      : AppColors.textColor,
                                  letterSpacing: 1.4,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                              AppSpaces.vSpace4,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 6.r,
                                    height: 6.r,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: statusColor,
                                    ),
                                  ),
                                  AppSpaces.hSpace6,
                                  Text(
                                    statusText,
                                    style: AppTextStyles.text10.copyWith(
                                      color: statusColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }),
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
                        // Left: Shift Timing (Initially 00:00, then real checkIn - checkOut)
                        Obx(() {
                          final timing = controller
                                  .dashboardData
                                  .value
                                  ?.todayAttendance
                                  .shiftTiming ??
                              '00:00';
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

                        // Right: Live Shift Status Pill
                        Obx(() {
                          final today =
                              controller.dashboardData.value?.todayAttendance;
                          final isCheckedIn = today?.isCheckedIn ?? false;
                          final isCheckedOut = (today?.checkOutTime != null &&
                              today?.checkOutTime != '--:--');

                          String badgeText;
                          Color badgeColor;

                          if (isCheckedIn) {
                            badgeText = 'Running';
                            badgeColor = AppColors.onTimeColor;
                          } else if (isCheckedOut) {
                            badgeText = 'Completed';
                            badgeColor = AppColors.secondary;
                          } else {
                            badgeText = 'Not Started';
                            badgeColor = AppColors.subTextColor;
                          }

                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: badgeColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: badgeColor.withValues(alpha: 0.3),
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
                                    color: badgeColor,
                                  ),
                                ),
                                AppSpaces.hSpace6,
                                Text(
                                  badgeText,
                                  style: AppTextStyles.text10.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: badgeColor,
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
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.touch_app_rounded,
                                  size: 16.sp,
                                  color: AppColors.secondary,
                                ),
                                AppSpaces.hSpace8,
                                Expanded(
                                  child: Text(
                                    'Attendance Actions',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.text12.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AppSpaces.hSpace8,
                          Row(
                            mainAxisSize: MainAxisSize.min,
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
