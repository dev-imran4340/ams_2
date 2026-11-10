import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_spaces.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/widgets/custom_screen_header.dart';
import '../../../core/widgets/custom_state_view.dart';
import '../../../core/widgets/employee_ambient_header.dart';
import '../../../core/widgets/network_boundary_wrapper.dart';
import '../controller/schedule_controller.dart';
import 'components/holidays_bottom_sheet.dart';
import 'components/schedule_date_range_bar.dart';
import 'components/schedule_day_card.dart';
import 'components/schedule_hero_summary_card.dart';

class ScheduleView extends GetView<ScheduleController> {
  const ScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkBoundaryWrapper(
      onRetry: () => controller.loadSchedule(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Stack(
          children: [
            // 1. Signature Ambient Teal to Navy Top Header
            EmployeeAmbientHeader(height: 230.h),

            // 2. Overlapping Scrollable Body
            SafeArea(
              child: Column(
                children: [
                  AppSpaces.vSpace16,

                  // Top Header with Title and Custom Holidays Action Button
                  Padding(
                    padding: AppSpaces.horizontalPadding,
                    child: Obx(() {
                      final isOther = controller.targetEmployeeId.value != null;
                      final otherName = controller.targetEmployeeName.value;

                      return CustomScreenHeader(
                        title: isOther ? '$otherName\'s Rota' : 'Work Schedule & Rota',
                        subtitle: isOther
                            ? 'MANAGER SCHEDULE AUDIT'
                            : 'SHIFTS, PATTERNS & ROSTER',
                        titleMaxLines: 2,
                        titleOverflow: TextOverflow.visible,
                        actions: [
                          _buildHolidaysButton(context),
                        ],
                      );
                    }),
                  ),

                  AppSpaces.vSpace10,

                  // From & To Date Selection Row (Replaces Clunky Tabs)
                  ScheduleDateRangeBar(controller: controller),

                  AppSpaces.vSpace10,

                  // Main Scrollable Rota Feed
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (controller.errorMessage.value.isNotEmpty) {
                        return CustomStateView.error(
                          title: 'Access Restricted',
                          message: controller.errorMessage.value,
                          buttonText: 'Go Back',
                          onRetry: () => Get.back(),
                        );
                      }

                      final days = controller.scheduleResponse.value?.data ?? [];

                      if (days.isEmpty) {
                        return CustomStateView.empty(
                          title: 'No Shifts Scheduled',
                          message: 'No work shifts or rest days found for the selected query window.',
                          buttonText: 'Reset to Next 14 Days',
                          onAction: () => controller.applyRange('14_days'),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () => controller.loadSchedule(),
                        color: AppColors.secondary,
                        backgroundColor: AppColors.cardBackground,
                        child: ListView.separated(
                          controller: controller.scrollController,
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: EdgeInsets.only(bottom: 24.h),
                          itemCount: days.length + 1, // 0: Summary Hero Card, 1..N: Days
                          separatorBuilder: (context, index) {
                            return AppSpaces.vSpace10;
                          },
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return Padding(
                                padding: AppSpaces.horizontalPadding,
                                child: ScheduleHeroSummaryCard(
                                  controller: controller,
                                ),
                              );
                            }

                            final day = days[index - 1];
                            return Padding(
                              padding: AppSpaces.horizontalPadding,
                              child: ScheduleDayCard(day: day),
                            );
                          },
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Custom Holidays action pill button displayed in the screen header
  Widget _buildHolidaysButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Tooltip(
        message: 'View Annual Holidays',
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            HolidaysBottomSheet.show(context, controller);
          },
          borderRadius: BorderRadius.circular(10.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: AppColors.borderColor, width: 0.8.w),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  blurRadius: 4.r,
                  offset: Offset(0, 1.h),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.celebration_rounded,
                  size: 14.sp,
                  color: AppColors.success,
                ),
                AppSpaces.hSpace4,
                Text(
                  'Holidays',
                  style: AppTextStyles.text12.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
