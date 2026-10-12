import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../api/app_preferences.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_spaces.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/widgets/custom_state_view.dart';
import '../../../core/widgets/network_boundary_wrapper.dart';
import '../../../routes/app_routes.dart';
import '../components/dashboard_stat_card.dart';
import '../controller/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AppPreferences.getUser();

    return NetworkBoundaryWrapper(
      onRetry: controller.loadDashboard,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          title: Text(
            'AMS 2 Dashboard',
            style: AppTextStyles.text18.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.logout_rounded, color: AppColors.textColor, size: 22.sp),
              onPressed: () async {
                await AppPreferences.clearSession();
                Get.offAllNamed(Routes.LOGIN);
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value) {
              return Center(
                child: CircularProgressIndicator(color: AppColors.primary),
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

            return RefreshIndicator(
              onRefresh: controller.loadDashboard,
              child: ListView(
                padding: AppSpaces.defaultPadding,
                children: [
                  // User Welcome Banner
                  Container(
                    padding: AppSpaces.defaultPadding,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24.r,
                          backgroundColor: AppColors.white.withValues(alpha: 0.15),
                          child: Icon(Icons.person, color: AppColors.white, size: 26.sp),
                        ),
                        AppSpaces.hSpace14,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.name ?? 'Welcome Back',
                                style: AppTextStyles.text16.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.white,
                                ),
                              ),
                              AppSpaces.vSpace4,
                              Text(
                                user?.designation ?? 'Attendance Management Lead',
                                style: AppTextStyles.text12.copyWith(
                                  color: AppColors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSpaces.vSpace20,

                  Text(
                    "Today's Attendance Overview",
                    style: AppTextStyles.text16.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  AppSpaces.vSpace12,

                  DashboardStatCard(
                    title: 'Total Workforce',
                    value: '${data.totalEmployees} Employees',
                    icon: Icons.groups_rounded,
                    color: AppColors.primary,
                  ),
                  AppSpaces.vSpace12,
                  DashboardStatCard(
                    title: 'On-Time (Present)',
                    value: '${data.onTimeToday} Check-ins',
                    icon: Icons.check_circle_rounded,
                    color: AppColors.onTimeColor,
                  ),
                  AppSpaces.vSpace12,
                  DashboardStatCard(
                    title: 'Late Arrivals',
                    value: '${data.lateToday} Flagged',
                    icon: Icons.alarm_on_rounded,
                    color: AppColors.lateColor,
                  ),
                  AppSpaces.vSpace12,
                  DashboardStatCard(
                    title: 'Absent / Unrecorded',
                    value: '${data.absentToday} Missing',
                    icon: Icons.cancel_rounded,
                    color: AppColors.absentColor,
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
