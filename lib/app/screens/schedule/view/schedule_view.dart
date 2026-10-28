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
import 'components/schedule_day_card.dart';
import 'components/schedule_filter_chips.dart';
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

                  // Top Header with Title and Holiday Button Action
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
                        actions: [
                          CustomScreenHeader.actionButton(
                            icon: Icons.celebration_rounded,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              HolidaysBottomSheet.show(context, controller);
                            },
                            tooltip: 'View Holidays Calendar',
                          ),
                          AppSpaces.hSpace8,
                          CustomScreenHeader.actionButton(
                            icon: Icons.date_range_rounded,
                            onTap: () => controller.pickCustomRange(context),
                            tooltip: 'Select Custom Date Range',
                          ),
                        ],
                      );
                    }),
                  ),

                  AppSpaces.vSpace12,

                  // Quick Date Range Filter Bar
                  _buildDateRangeSelector(context),

                  AppSpaces.vSpace12,

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

                      final days = controller.filteredDays;

                      if (days.isEmpty) {
                        return CustomStateView.empty(
                          title: 'No Shifts Scheduled',
                          message: 'No work shifts or rest days found for the selected query window.',
                          buttonText: 'Next 14 Days',
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
                          itemCount: days.length + 2, // 0: Summary, 1: Filter Chips, 2..N: Days
                          separatorBuilder: (context, index) {
                            if (index < 2) return AppSpaces.vSpace12;
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

                            if (index == 1) {
                              return ScheduleFilterChips(
                                controller: controller,
                              );
                            }

                            final day = days[index - 2];
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

  Widget _buildDateRangeSelector(BuildContext context) {
    return Obx(() {
      final active = controller.selectedRange.value;

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: AppSpaces.horizontalPadding,
        child: Row(
          children: [
            _buildRangeCapsule('Next 14 Days', '14_days', active == '14_days'),
            AppSpaces.hSpace8,
            _buildRangeCapsule('Next 30 Days', '30_days', active == '30_days'),
            AppSpaces.hSpace8,
            _buildRangeCapsule('This Month', 'this_month', active == 'this_month'),
            AppSpaces.hSpace8,
            _buildRangeCapsule('Custom (Max 62d)', 'custom', active == 'custom', isCustom: true),
          ],
        ),
      );
    });
  }

  Widget _buildRangeCapsule(String label, String key, bool isSelected, {bool isCustom = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (isCustom) {
            controller.pickCustomRange(Get.context!);
          } else {
            controller.applyRange(key);
          }
        },
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.secondary
                : AppColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isSelected
                  ? AppColors.secondary
                  : AppColors.borderColor,
              width: 1.w,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isCustom) ...[
                Icon(
                  Icons.edit_calendar_rounded,
                  size: 11.sp,
                  color: isSelected ? AppColors.white : AppColors.subTextColor,
                ),
                AppSpaces.hSpace4,
              ],
              Text(
                label,
                style: AppTextStyles.text10.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppColors.white : AppColors.textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
