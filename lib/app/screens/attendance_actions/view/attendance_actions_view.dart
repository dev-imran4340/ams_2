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
import '../controller/attendance_actions_controller.dart';
import 'components/active_break_card.dart';
import 'components/attendance_actions_grid.dart';
import 'components/attendance_more_services_section.dart';
import 'components/attendance_status_hero_card.dart';
import 'components/live_clock_strip.dart';

class AttendanceActionsView extends GetView<AttendanceActionsController> {
  const AttendanceActionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkBoundaryWrapper(
      onRetry: controller.loadShiftTelemetry,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Obx(() {
          if (controller.isLoading.value && controller.telemetry.value == null) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2.5.w,
              ),
            );
          }

          final data = controller.telemetry.value;
          if (data == null) {
            return CustomStateView.empty(
              title: 'No Active Shift Telemetry',
              message: 'Could not retrieve today\'s attendance shift details.',
              buttonText: 'Retry',
              onAction: controller.loadShiftTelemetry,
            );
          }

          return Stack(
            children: [
              // 1. Signature Curved Ambient Gradient Header
              EmployeeAmbientHeader(height: 260.h),

              // 2. Main Scrollable Content Overlapping Header
              SafeArea(
                child: RefreshIndicator(
                  onRefresh: controller.loadShiftTelemetry,
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
                        // Top Executive Navigation Bar
                        CustomScreenHeader(
                          title: 'Attendance Hub',
                          subtitle: 'Punches, Breaks & Requests',
                          actions: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(
                                  color: AppColors.borderColor,
                                  width: 0.8.w,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.06),
                                    blurRadius: 6.r,
                                    offset: Offset(0, 2.h),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6.r,
                                    height: 6.r,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.onTimeColor,
                                    ),
                                  ),
                                  AppSpaces.hSpace6,
                                  Text(
                                    'Live Sync',
                                    style: AppTextStyles.text10.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        AppSpaces.vSpace14,

                        // 1. Employee Status & Mode Hero Card
                        const AttendanceStatusHeroCard(),

                        AppSpaces.vSpace12,

                        // 2. Tabular Live Real-Time Clock & Date Strip
                        const LiveClockStrip(),

                        AppSpaces.vSpace14,

                        // 3. Active Break Live Timer Card (Conditional)
                        const ActiveBreakCard(),

                        // 4. Core Attendance Actions 2x2 Grid (Check In, Check Out, Start Break, End Break)
                        const AttendanceActionsGrid(),

                        AppSpaces.vSpace20,

                        // 5. Extended Services Hub (Evaluations, Leaves, Money Requests, Tasks, ID Card)
                        const AttendanceMoreServicesSection(),

                        AppSpaces.vSpace24,

                        // Bottom spacing
                        SizedBox(height: 40.h),
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


}
