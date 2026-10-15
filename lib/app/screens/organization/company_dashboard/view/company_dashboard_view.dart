import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/network_boundary_wrapper.dart';
import '../controller/company_dashboard_controller.dart';
import 'components/company_attendance_donut_chart.dart';
import 'components/company_recent_activities_card.dart';
import 'components/company_recent_leaves_card.dart';
import 'components/company_scan_quick_action.dart';
import 'components/company_summary_stats_grid.dart';

class CompanyDashboardView extends GetView<CompanyDashboardController> {
  const CompanyDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkBoundaryWrapper(
      onRetry: controller.loadDashboard,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: RefreshIndicator(
          color: AppColors.secondary,
          onRefresh: controller.loadDashboard,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Executive Curved Corporate Navy Header
                _buildHeader(context),

                // 2. Overlapping Dashboard Content (-45.h)
                Transform.translate(
                  offset: Offset(0, -45.h),
                  child: Padding(
                    padding: AppSpaces.horizontalPadding,
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 80.h),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.secondary,
                              strokeWidth: 3.w,
                            ),
                          ),
                        );
                      }

                      final data = controller.dashboard.value;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 1. Scan Gate Attendance Quick Action
                          const CompanyScanQuickAction(),

                          AppSpaces.vSpace16,

                          // 2. Attendance Presence Donut Chart
                          CompanyAttendanceDonutChart(
                            totalEmployees: data?.totalEmployees ?? 160,
                            presentToday: data?.presentToday ?? 138,
                            absentToday: data?.absentToday ?? 14,
                            unmarkedToday: data?.unmarkedToday ?? 8,
                          ),

                          AppSpaces.vSpace16,

                          // 3. Four-Metric Summary Grid
                          const CompanySummaryStatsGrid(),

                          AppSpaces.vSpace16,

                          // 4. Recent Activities Feed Card
                          const CompanyRecentActivitiesCard(),

                          AppSpaces.vSpace16,

                          // 5. Recent Leaves Card
                          const CompanyRecentLeavesCard(),

                          AppSpaces.vSpace20,
                        ],
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Executive Curved Header with Back Pill, Refresh button, and Title
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary,
            AppColors.primary,
            AppColors.secondary,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(18.r),
          bottomRight: Radius.circular(18.r),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 18.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Ambient Circles
          Positioned(
            top: -30.r,
            right: -20.r,
            child: Container(
              width: 140.r,
              height: 140.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: 20.r,
            left: -40.r,
            child: Container(
              width: 110.r,
              height: 110.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withValues(alpha: 0.06),
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 64.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Navigation Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back Pill Button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Get.back(),
                          borderRadius: BorderRadius.circular(20.r),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: AppColors.white.withValues(alpha: 0.25),
                                width: 1.w,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  size: 13.sp,
                                  color: AppColors.white,
                                ),
                                AppSpaces.hSpace4,
                                Text(
                                  'Back',
                                  style: AppTextStyles.text12.copyWith(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Refresh / Reload Action Button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: controller.loadDashboard,
                          borderRadius: BorderRadius.circular(20.r),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: AppColors.white.withValues(alpha: 0.25),
                                width: 1.w,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.refresh_rounded,
                                  size: 14.sp,
                                  color: AppColors.white,
                                ),
                                AppSpaces.hSpace4,
                                Text(
                                  'Refresh',
                                  style: AppTextStyles.text12.copyWith(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  AppSpaces.vSpace16,

                  // Title & Subtitle
                  Text(
                    'Company Dashboard',
                    style: AppTextStyles.text24.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppSpaces.vSpace4,
                  Text(
                    'Open company dashboard and attendance',
                    style: AppTextStyles.text12.copyWith(
                      color: AppColors.white.withValues(alpha: 0.85),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
