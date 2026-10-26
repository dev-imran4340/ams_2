import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_spaces.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/widgets/custom_screen_header.dart';
import '../../../core/widgets/custom_state_view.dart';
import '../../../core/widgets/employee_ambient_header.dart';
import '../../../core/widgets/network_boundary_wrapper.dart';
import '../controller/attendance_history_controller.dart';
import 'components/attendance_calendar_strip.dart';
import 'components/attendance_log_tile.dart';
import 'components/attendance_telemetry_strip.dart';
import 'components/day_punch_breakdown_card.dart';

class AttendanceHistoryView extends GetView<AttendanceHistoryController> {
  const AttendanceHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return NetworkBoundaryWrapper(
      onRetry: () => controller.loadMonthlyLogs(controller.selectedMonth.value),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2.5.w,
              ),
            );
          }

          if (controller.logs.isEmpty) {
            return CustomStateView.empty(
              title: 'No Attendance Records',
              message: 'No log records found for the selected month.',
              buttonText: 'Refresh',
              onAction: () =>
                  controller.loadMonthlyLogs(controller.selectedMonth.value),
            );
          }

          final monthNum = controller.selectedMonth.value.month;
          final yearNum = controller.selectedMonth.value.year;
          final monthStr = '${months[monthNum - 1]} $yearNum';

          return Stack(
            children: [
              // 1. Curved Ambient Gradient Header
              EmployeeAmbientHeader(height: 230.h),

              // 2. Main Scrollable Content Overlapping the Header
              SafeArea(
                child: RefreshIndicator(
                  onRefresh: () => controller.loadMonthlyLogs(
                    controller.selectedMonth.value,
                  ),
                  color: AppColors.primary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 10.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Executive Header: Month Switcher Capsule & Export PDF Action
                        _buildTopBar(monthStr),

                        AppSpaces.vSpace14,

                        // Component 1: Floating Monthly Telemetry Summary Capsules
                        const AttendanceTelemetryStrip(),

                        AppSpaces.vSpace14,

                        // Component 2: Interactive Horizontal Calendar Strip
                        const AttendanceCalendarStrip(),

                        AppSpaces.vSpace14,

                        // Component 3: Detailed Selected Day Punch Breakdown Card
                        const DayPunchBreakdownCard(),

                        AppSpaces.vSpace16,

                        // Section Header: Monthly Logs List
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 4.w,
                                  height: 16.h,
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary,
                                    borderRadius: BorderRadius.circular(2.r),
                                  ),
                                ),
                                AppSpaces.hSpace8,
                                Text(
                                  'Daily Attendance Logs',
                                  style: AppTextStyles.text16.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textColor,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${controller.logs.length} Records',
                              style: AppTextStyles.text10.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.subTextColor,
                              ),
                            ),
                          ],
                        ),

                        AppSpaces.vSpace10,

                        // Component 4: Historical Daily Log Tiles List
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.logs.length,
                          itemBuilder: (context, index) {
                            final log = controller.logs[index];
                            final isSelected =
                                controller.selectedDate.value != null &&
                                controller.selectedDate.value!.day ==
                                    log.date.day;

                            return AttendanceLogTile(
                              log: log,
                              isSelected: isSelected,
                              onTap: () => controller.selectDate(log.date),
                            );
                          },
                        ),

                        // Bottom safe clearance for the floating navigation bar
                        SizedBox(height: 80.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  /// Top executive navigation bar with Month Switcher Capsule and Export Action Button
  Widget _buildTopBar(String monthStr) {
    return CustomScreenHeader(
      title: 'Attendance History',
      subtitle: 'Verified punches & telemetry',
      actions: [
            // Month Switcher Capsule
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.9),
                  width: 1.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 10.r,
                    offset: Offset(0, 3.h),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.chevron_left_rounded,
                      size: 18.sp,
                      color: AppColors.textColor,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(
                      minWidth: 26.r,
                      minHeight: 26.r,
                    ),
                    onPressed: () => controller.changeMonth(-1),
                  ),
                  Text(
                    monthStr.split(' ').first,
                    style: AppTextStyles.text12.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.chevron_right_rounded,
                      size: 18.sp,
                      color: AppColors.textColor,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(
                      minWidth: 26.r,
                      minHeight: 26.r,
                    ),
                    onPressed: () => controller.changeMonth(1),
                  ),
                ],
              ),
            ),

            AppSpaces.hSpace6,

            // Circular Export PDF Button
            Container(
              width: 36.r,
              height: 36.r,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.9),
                  width: 1.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 10.r,
                    offset: Offset(0, 3.h),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: controller.exportReport,
                  child: Obx(
                    () => controller.isExporting.value
                        ? Padding(
                            padding: EdgeInsets.all(9.r),
                            child: CircularProgressIndicator(
                              strokeWidth: 2.w,
                              color: AppColors.secondary,
                            ),
                          )
                        : Icon(
                            Icons.file_download_outlined,
                            size: 17.sp,
                            color: AppColors.secondary,
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
}
