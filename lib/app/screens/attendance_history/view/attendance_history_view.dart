import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../api/app_preferences.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_spaces.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/widgets/custom_screen_header.dart';
import '../../../core/widgets/employee_ambient_header.dart';
import '../../../core/widgets/network_boundary_wrapper.dart';
import '../../../routes/app_routes.dart';
import '../controller/attendance_history_controller.dart';
import 'components/attendance_date_range_bar.dart';
import 'components/timesheet_day_card.dart';
import 'components/timesheet_filter_bar.dart';
import 'components/timesheet_metric_overview_card.dart';

class AttendanceHistoryView extends GetView<AttendanceHistoryController> {
  const AttendanceHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkBoundaryWrapper(
      onRetry: controller.loadTimesheet,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Stack(
          children: [
            // 1. Signature Curved Ambient Gradient Header
            EmployeeAmbientHeader(height: 230.h),

            // 2. Main Scrollable Content Overlapping Header
            SafeArea(
              child: RefreshIndicator(
                onRefresh: controller.loadTimesheet,
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
                      // Top Executive Navigation Header with Dynamic Sync Status
                      CustomScreenHeader(
                        title: 'Attendance History',
                        subtitle: 'Verified daily punches & activity logs',
                        actions: [
                          if (AppPreferences.hasModule('attendance') &&
                              AppPreferences.hasPermission('attendance.view'))
                            CustomScreenHeader.actionButton(
                              icon: Icons.schedule_rounded,
                              onTap: () {
                                HapticFeedback.lightImpact();
                                Get.toNamed(Routes.SCHEDULE);
                              },
                              tooltip: 'Work Schedule & Rota',
                            ),
                        ],
                      ),

                      AppSpaces.vSpace14,

                      // 1. Date Range & Month Selection Filter Bar (Always visible!)
                      const AttendanceDateRangeBar(),

                      AppSpaces.vSpace14,

                      // 2. Signature Overview & Period Analytics Card
                      const TimesheetMetricOverviewCard(),

                      AppSpaces.vSpace14,

                      // 3. Status Filters Bar (All, Present, Late, Absent, Off)
                      const TimesheetFilterBar(),

                      AppSpaces.vSpace14,

                      // 4. Section Heading: Daily Records Count
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
                                'Daily Logged Records',
                                style: AppTextStyles.text16.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ],
                          ),
                          Obx(() {
                            final list = controller.filteredList;
                            return Text(
                              '${list.length} Days Displayed',
                              style: AppTextStyles.text10.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.subTextColor,
                              ),
                            );
                          }),
                        ],
                      ),

                      AppSpaces.vSpace10,

                      // 5. In-Body State: Loading Spinner, Empty State, or Records List
                      Obx(() {
                        // ─── STATE A: Loading in progress ───
                        if (controller.isLoading.value) {
                          return _buildLoadingState();
                        }

                        final response = controller.timesheetResponse.value;

                        // ─── STATE B: No Data Found for Period ───
                        if (response == null || response.data.isEmpty) {
                          return _buildNoDataCard(context);
                        }

                        final list = controller.filteredList;

                        // ─── STATE C: No Records for Selected Filter Pill ───
                        if (list.isEmpty) {
                          return _buildFilterEmptyCard();
                        }

                        // ─── STATE D: Active Records List ───
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            return TimesheetDayCard(log: list[index]);
                          },
                        );
                      }),

                      // Safe clearance for bottom floating navigation bar
                      SizedBox(height: 70.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// In-Body Loading State Indicator
  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 42.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: AppColors.borderColor, width: 0.8.w),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.03),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 30.r,
            height: 30.r,
            child: CircularProgressIndicator(
              color: AppColors.secondary,
              strokeWidth: 2.5.w,
            ),
          ),
          AppSpaces.vSpace14,
          Text(
            'Fetching Attendance Records...',
            style: AppTextStyles.text12.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textColor,
            ),
          ),
          AppSpaces.vSpace4,
          Text(
            'Loading verified logs for ${controller.filterLabel.value}',
            textAlign: TextAlign.center,
            style: AppTextStyles.text10.copyWith(color: AppColors.subTextColor),
          ),
        ],
      ),
    );
  }

  /// In-Body Empty State Card (Leaves Header & Range Bar accessible at all times)
  Widget _buildNoDataCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 28.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(15.r),
        border: Border(
          bottom: BorderSide(color: AppColors.secondary, width: 3.w),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_busy_rounded,
              size: 24.sp,
              color: AppColors.secondary,
            ),
          ),
          AppSpaces.vSpace12,
          Text(
            'No Attendance Records Found',
            style: AppTextStyles.text14.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          AppSpaces.vSpace6,
          Text(
            'No daily punch logs were found for ${controller.filterLabel.value}.\n(${controller.filterSubtitle.value})',
            textAlign: TextAlign.center,
            style: AppTextStyles.text12.copyWith(
              color: AppColors.subTextColor,
              height: 1.4,
            ),
          ),
          AppSpaces.vSpace16,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () => controller.openCustomDateRangeSheet(context),
                icon: Icon(
                  Icons.date_range_rounded,
                  size: 14.sp,
                  color: AppColors.secondary,
                ),
                label: Text(
                  'Change Date Range',
                  style: AppTextStyles.text12.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.secondary, width: 1.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 9.h,
                  ),
                ),
              ),
              AppSpaces.hSpace10,
              ElevatedButton.icon(
                onPressed: controller.loadTimesheet,
                icon: Icon(
                  Icons.refresh_rounded,
                  size: 14.sp,
                  color: AppColors.white,
                ),
                label: Text(
                  'Retry',
                  style: AppTextStyles.text12.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 9.h,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// In-Body Filter Empty Card (When 'Absent' or other filter has 0 matches)
  Widget _buildFilterEmptyCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: AppColors.borderColor, width: 0.8.w),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.filter_list_off_rounded,
            size: 32.sp,
            color: AppColors.subTextColor,
          ),
          AppSpaces.vSpace10,
          Text(
            'No Records for "${controller.selectedFilter.value.capitalizeFirst}"',
            style: AppTextStyles.text12.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          AppSpaces.vSpace4,
          Text(
            'There are no attendance records matching this filter in the current period.',
            textAlign: TextAlign.center,
            style: AppTextStyles.text10.copyWith(color: AppColors.subTextColor),
          ),
          AppSpaces.vSpace12,
          TextButton(
            onPressed: () => controller.setFilter('all'),
            child: Text(
              'Show All Records',
              style: AppTextStyles.text12.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
