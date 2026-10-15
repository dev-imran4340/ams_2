import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/network_boundary_wrapper.dart';
import '../controller/employee_terminal_controller.dart';
import 'components/attendance_success_overlay.dart';
import 'components/biometric_kiosk_viewfinder.dart';
import 'components/recent_punch_activity_list.dart';
import 'components/terminal_card_qr_viewfinder.dart';
import 'components/terminal_live_stats_strip.dart';
import 'components/terminal_mode_selector_bar.dart';

class EmployeeTerminalView extends GetView<EmployeeTerminalController> {
  const EmployeeTerminalView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkBoundaryWrapper(
      onRetry: controller.loadInitialData,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Executive Curved Corporate Navy Gradient Header
              _buildHeader(context),

              // 2. Overlapping Interactive Body Content
              Transform.translate(
                offset: Offset(0, -45.h),
                child: Padding(
                  padding: AppSpaces.horizontalPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Component 1: Live Telemetry Stats Strip
                      Obx(
                        () => TerminalLiveStatsStrip(
                          telemetry: controller.telemetry.value,
                        ),
                      ),

                      AppSpaces.vSpace14,

                      // Component 2: Main Scanner Viewfinder / Success Overlay
                      Obx(() {
                        if (controller.showSuccessBadge.value &&
                            controller.lastPunchedEmployee.value != null) {
                          return AttendanceSuccessOverlay(
                            punch: controller.lastPunchedEmployee.value!,
                          );
                        }

                        if (controller.activeScannerMode.value == 0) {
                          return const BiometricKioskViewfinder();
                        } else {
                          return const TerminalCardQrViewfinder();
                        }
                      }),

                      AppSpaces.vSpace14,

                      // Component 3: Live Rolling Attendance Punch Feed
                      Obx(
                        () => RecentPunchActivityList(
                          punches: controller.recentPunches.toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }

  /// Executive Curved Header with Back Pill, Titles, Ambient Circles, and Dual Mode Switcher
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
          // Ambient Decorative Circle 1 (Top-Right)
          Positioned(
            top: -40.r,
            right: -30.r,
            child: Container(
              width: 150.r,
              height: 150.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white.withValues(alpha: 0.05),
              ),
            ),
          ),

          // Ambient Decorative Circle 2 (Bottom-Left)
          Positioned(
            bottom: 20.r,
            left: -40.r,
            child: Container(
              width: 140.r,
              height: 140.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withValues(alpha: 0.05),
              ),
            ),
          ),

          // Header Foreground Content
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 65.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Back Glass Pill & Station Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back Glass Pill Button
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
                                  'Portal Hub',
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

                      // Station Badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: AppColors.white.withValues(alpha: 0.2),
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
                                color: AppColors.successMint,
                                shape: BoxShape.circle,
                              ),
                            ),
                            AppSpaces.hSpace4,
                            Text(
                              'GATE GATEWAY 01',
                              style: AppTextStyles.text8.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  AppSpaces.vSpace14,

                  // Title
                  Text(
                    'Attendance Gate Terminal',
                    style: AppTextStyles.text22.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),

                  AppSpaces.vSpace4,

                  // Subtitle
                  Text(
                    'Continuous 1:N Facial AI & Smart Card Verification',
                    style: AppTextStyles.text12.copyWith(
                      color: AppColors.litePrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  AppSpaces.vSpace14,

                  // Dual Mode Switcher
                  Obx(
                    () => TerminalModeSelectorBar(
                      selectedIndex: controller.activeScannerMode.value,
                      onChanged: controller.switchScannerMode,
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
