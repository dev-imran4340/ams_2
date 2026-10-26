import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../index/controller/index_controller.dart';

import '../../../api/app_preferences.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_spaces.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/widgets/custom_state_view.dart';
import '../../../core/widgets/employee_ambient_header.dart';
import '../../../core/widgets/network_boundary_wrapper.dart';
import '../../../routes/app_routes.dart';
import '../../main_shell/controller/session_me_controller.dart';
import '../controller/dashboard_controller.dart';
import 'components/dashboard_quick_actions.dart';
import 'components/live_shift_clock_card.dart';
import 'components/monthly_summary_card.dart';
import 'components/recent_activity_timeline.dart';
import 'components/today_stats_grid.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionController = Get.isRegistered<SessionMeController>()
        ? Get.find<SessionMeController>()
        : Get.put(SessionMeController(), permanent: true);
    final user = AppPreferences.getUser();

    return NetworkBoundaryWrapper(
      onRetry: controller.loadDashboard,
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

          final data = controller.dashboardData.value;
          if (data == null) {
            return CustomStateView.empty(
              title: 'No Attendance Data',
              message: 'No attendance records available for today.',
              buttonText: 'Refresh',
              onAction: controller.loadDashboard,
            );
          }

          final meUser = sessionController.user.value;
          final String userName = meUser?.name ?? user?.name ?? 'Maryam Malik';
          final String designation =
              AppPreferences.getProfileData()?['designation']?.toString() ??
              user?.designation ??
              'Sales Manager';

          return Stack(
            children: [
              // 1. Curved Ambient Gradient Header
              EmployeeAmbientHeader(height: 230.h),

              // 2. Main Scrollable Content Overlapping the Header
              SafeArea(
                child: RefreshIndicator(
                  onRefresh: controller.loadDashboard,
                  color: AppColors.primary,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 10.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Executive Header (Avatar, Name, Greeting, Location Pill, Notification Bell)
                        _buildTopHeader(userName, designation),

                        AppSpaces.vSpace12,

                        // 1. Floating Live Shift & Running Clock Hero Card (Overlaps curved header)
                        const LiveShiftClockCard(),

                        AppSpaces.vSpace12,

                        // 2. Executive Quick Services Hub
                        const DashboardQuickActions(),

                        AppSpaces.vSpace12,

                        // 3. Section: Today's Metrics Overview
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
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
                                  Expanded(
                                    child: Text(
                                      "Today's Overview",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.text16.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AppSpaces.hSpace8,
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(12.r),
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
                                  Container(
                                    width: 6.r,
                                    height: 6.r,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                  AppSpaces.hSpace6,
                                  Text(
                                    'Live Metrics',
                                    style: AppTextStyles.text10.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        AppSpaces.vSpace12,

                        // 4-Card Mini Grid
                        const TodayStatsGrid(),

                        AppSpaces.vSpace20,

                        // 4. Section: Monthly Performance Summary
                        Row(
                          children: [
                            Container(
                              width: 4.w,
                              height: 16.h,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(2.r),
                              ),
                            ),
                            AppSpaces.hSpace8,
                            Text(
                              'Attendance Analytics',
                              style: AppTextStyles.text16.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                            ),
                          ],
                        ),

                        AppSpaces.vSpace12,

                        // Monthly Summary Card
                        const MonthlySummaryCard(),

                        AppSpaces.vSpace20,

                        // 5. Section: Today's Punch Activity Log
                        const RecentActivityTimeline(),

                        AppSpaces.vSpace24,

                        // Bottom spacing to clear floating navigation bar
                        SizedBox(height: 76.h),
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

  /// Top executive header showing user greeting, designation, and notification badge
  Widget _buildTopHeader(String name, String designation) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : (hour < 17 ? 'Good Afternoon' : 'Good Evening');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // User Profile & Greeting
        Expanded(
          child: Row(
            children: [
              // User Avatar with Online Status Indicator
              Stack(
                children: [
                  Container(
                    width: 46.r,
                    height: 46.r,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 2.w),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          blurRadius: 10.r,
                          offset: Offset(0, 4.h),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'M',
                      style: AppTextStyles.text18.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 1.r,
                    right: 1.r,
                    child: Container(
                      width: 12.r,
                      height: 12.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.onTimeColor,
                        border: Border.all(color: AppColors.white, width: 2.w),
                      ),
                    ),
                  ),
                ],
              ),
              AppSpaces.hSpace12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.text16.copyWith(
                        color: AppColors.textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppSpaces.vSpace2,
                    Text(
                      '$greeting,',
                      style: AppTextStyles.text12.copyWith(
                        color: AppColors.textColor.withValues(alpha: 0.75),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        AppSpaces.hSpace8,

        // Circular Glass Notification Button
        IconButton(
          style: IconButton.styleFrom(
            backgroundColor: AppColors.white,
            shape: const CircleBorder(),
            shadowColor: AppColors.primary.withValues(alpha: 0.08),
            elevation: 10,
          ),
          icon: Icon(
            Icons.notifications_none_rounded,
            color: AppColors.textColor,
            size: 22.sp,
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            Get.toNamed(Routes.NOTIFICATIONS);
          },
        ),

        AppSpaces.hSpace8,

        // Menu / Drawer Trigger Button (Right Side)
        IconButton(
          style: IconButton.styleFrom(
            backgroundColor: AppColors.white,
            shape: const CircleBorder(),
            shadowColor: AppColors.primary.withValues(alpha: 0.08),
            elevation: 10,
          ),
          icon: Icon(Icons.menu_rounded, color: AppColors.primary, size: 22.sp),
          onPressed: () {
            HapticFeedback.lightImpact();
            if (Get.isRegistered<IndexController>()) {
              Get.find<IndexController>().openDrawer();
            }
          },
        ),
      ],
    );
  }
}
