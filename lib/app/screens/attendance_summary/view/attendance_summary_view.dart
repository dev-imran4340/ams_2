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
import '../controller/attendance_summary_controller.dart';
import 'components/attendance_score_hero_card.dart';
import 'components/compliance_and_overtime_card.dart';
import 'components/days_breakdown_grid.dart';
import 'components/working_hours_summary_card.dart';

class AttendanceSummaryView extends GetView<AttendanceSummaryController> {
  const AttendanceSummaryView({super.key});

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
      'December'
    ];

    return NetworkBoundaryWrapper(
      onRetry: () => controller.loadSummary(controller.selectedMonth.value),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Obx(() {
          if (controller.isLoading.value && controller.summary.value == null) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2.5.w,
              ),
            );
          }

          final summary = controller.summary.value;
          if (summary == null) {
            return CustomStateView.empty(
              title: 'No Summary Available',
              message: 'Could not retrieve monthly attendance summary.',
              buttonText: 'Retry',
              onAction: () => controller.loadSummary(controller.selectedMonth.value),
            );
          }

          final monthNum = controller.selectedMonth.value.month;
          final yearNum = controller.selectedMonth.value.year;
          final monthStr = '${months[monthNum - 1]} $yearNum';

          return Stack(
            children: [
              // 1. Signature Curved Ambient Gradient Header
              EmployeeAmbientHeader(height: 230.h),

              // 2. Main Scrollable Content Overlapping Header
              SafeArea(
                child: RefreshIndicator(
                  onRefresh: () => controller.loadSummary(controller.selectedMonth.value),
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
                        // Top Header with Back Navigation & Month Switcher
                        CustomScreenHeader(
                          title: 'Monthly Summary',
                          subtitle: 'Analytics & Hours Compliance',
                          actions: [
                            _buildMonthSwitcher(monthStr),
                          ],
                        ),

                        AppSpaces.vSpace14,

                        // 1. Hero Performance & Attendance Score Card
                        const AttendanceScoreHeroCard(),

                        AppSpaces.vSpace14,

                        // 2. Days Breakdown Grid (All 10 Categories)
                        const DaysBreakdownGrid(),

                        AppSpaces.vSpace14,

                        // 3. Working Hours & Shift Targets Card
                        const WorkingHoursSummaryCard(),

                        AppSpaces.vSpace14,

                        // 4. Policy Compliance, Deductions & Overtime Card
                        const ComplianceAndOvertimeCard(),

                        AppSpaces.vSpace24,
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

  Widget _buildMonthSwitcher(String monthStr) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.borderColor,
          width: 0.8.w,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 6.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => controller.changeMonth(-1),
            borderRadius: BorderRadius.circular(12.r),
            child: Padding(
              padding: EdgeInsets.all(4.r),
              child: Icon(
                Icons.chevron_left_rounded,
                size: 18.sp,
                color: AppColors.primary,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Text(
              monthStr,
              style: AppTextStyles.text10.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          InkWell(
            onTap: () => controller.changeMonth(1),
            borderRadius: BorderRadius.circular(12.r),
            child: Padding(
              padding: EdgeInsets.all(4.r),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 18.sp,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
