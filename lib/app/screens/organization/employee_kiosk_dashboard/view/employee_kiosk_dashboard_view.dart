import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/network_boundary_wrapper.dart';
import '../controller/kiosk_employee_controller.dart';
import 'components/kiosk_attendance_actions_grid.dart';
import 'components/kiosk_employee_profile_banner.dart';
import 'components/kiosk_more_actions_card.dart';
import 'components/kiosk_security_timer_bar.dart';

class EmployeeKioskDashboardView extends GetView<KioskEmployeeController> {
  const EmployeeKioskDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkBoundaryWrapper(
      onRetry: controller.loadProfile,
      child: PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {
          controller.resetIdleTimer();
        },
        child: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (_) => controller.resetIdleTimer(),
          onPointerMove: (_) => controller.resetIdleTimer(),
          onPointerSignal: (_) => controller.resetIdleTimer(),
          child: Scaffold(
            backgroundColor: AppColors.backgroundColor,
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Executive Curved Header Section
                  _buildHeader(context),

                  // 2. Overlapping Dashboard Body (-45.h)
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

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 1. 1-Minute Security Auto-Clear Timer Bar
                            const KioskSecurityTimerBar(),

                            AppSpaces.vSpace14,

                            // 2. Employee Profile Card Banner
                            const KioskEmployeeProfileBanner(),

                            AppSpaces.vSpace16,

                            // 3. Direct Kiosk Punch Action Grid
                            const KioskAttendanceActionsGrid(),

                            AppSpaces.vSpace16,

                            // 4. More Self-Service Actions Card
                            const KioskMoreActionsCard(),

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
      ),
    );
  }

  /// Executive Curved Header with Logout Button and Terminal Gateway Info
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
                    children: [
                      // Exit / Close Kiosk Session Pill
                      InkWell(
                        onTap: controller.manualLogout,
                        borderRadius: BorderRadius.circular(10.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: AppColors.white.withValues(alpha: 0.2),
                              width: 1.w,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.power_settings_new_rounded,
                                size: 14.sp,
                                color: AppColors.white,
                              ),
                              AppSpaces.hSpace4,
                              Text(
                                'Exit Session',
                                style: AppTextStyles.text12.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Kiosk Station Tag
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.secondary.withValues(alpha: 0.4),
                            width: 0.8.w,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.touch_app_rounded,
                              size: 13.sp,
                              color: AppColors.liteSecondary,
                            ),
                            AppSpaces.hSpace4,
                            Text(
                              'Terminal Kiosk Mode',
                              style: AppTextStyles.text10.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  AppSpaces.vSpace16,

                  // Title & Subtitle
                  Text(
                    'Employee Station',
                    style: AppTextStyles.text24.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppSpaces.vSpace4,
                  Text(
                    'Shared reception terminal dashboard with automated idle security timeout.',
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
