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
import '../controller/training_controller.dart';
import 'components/training_record_card.dart';
import 'components/training_required_card.dart';
import 'components/training_telemetry_strip.dart';

class TrainingView extends GetView<TrainingController> {
  const TrainingView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkBoundaryWrapper(
      onRetry: controller.loadTraining,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Stack(
          children: [
            // 1. Signature Curved Ambient Gradient Header (240.h)
            EmployeeAmbientHeader(height: 240.h),

            // 2. Sticky Header + Scrollable Body
            SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 0),
                    child: const CustomScreenHeader(
                      title: 'Training & Development',
                      subtitle: 'Compliance courses, skills & certifications',
                    ),
                  ),
                  AppSpaces.vSpace14,
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => controller.loadTraining(isRefresh: true),
                      color: AppColors.secondary,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 4.h,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Component 1: Telemetry Metrics
                      const TrainingTelemetryStrip(),

                      AppSpaces.vSpace14,

                      // Component 2: Main View Tab Selector (Required vs Records)
                      _buildMainTabSelector(),

                      // Component 2b: Records Status Filters (if on Records tab)
                      Obx(() {
                        if (controller.selectedViewTab.value != 'Records') {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          children: [
                            AppSpaces.vSpace10,
                            _buildRecordFilters(),
                          ],
                        );
                      }),

                      AppSpaces.vSpace16,

                      // Section Header: Count
                      _buildSectionHeader(),

                      AppSpaces.vSpace10,

                      // Component 3: Dynamic Course / Records List
                      _buildContentList(context),

                      // Bottom clearance for navigation
                      SizedBox(height: 80.h),
                    ],
                  ),
                ),
              ),
            ),
                  ],
                ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainTabSelector() {
    return Obx(() {
      final selected = controller.selectedViewTab.value;

      return Container(
        height: 44.h,
        padding: EdgeInsets.all(4.r),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.borderColor, width: 1.w),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildSegmentButton(
                title: 'Required',
                icon: Icons.checklist_rounded,
                isSelected: selected == 'Required',
                onTap: () => controller.setViewTab('Required'),
              ),
            ),
            Expanded(
              child: _buildSegmentButton(
                title: 'Records',
                icon: Icons.history_edu_rounded,
                isSelected: selected == 'Records',
                onTap: () => controller.setViewTab('Records'),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSegmentButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(9.r),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 14.sp,
                  color: isSelected ? AppColors.white : AppColors.subTextColor,
                ),
                AppSpaces.hSpace6,
                Text(
                  title,
                  style: AppTextStyles.text12.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color:
                        isSelected ? AppColors.white : AppColors.subTextColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecordFilters() {
    return SizedBox(
      height: 34.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: controller.recordFilters.length,
        separatorBuilder: (_, _) => AppSpaces.hSpace8,
        itemBuilder: (context, index) {
          final filter = controller.recordFilters[index];

          return Obx(() {
            final isSelected = controller.selectedRecordFilter.value == filter;

            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => controller.setRecordFilter(filter),
                borderRadius: BorderRadius.circular(16.r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.secondary
                        : AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.secondary
                          : AppColors.borderColor,
                      width: 1.w,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      filter,
                      style: AppTextStyles.text10.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected
                            ? AppColors.white
                            : AppColors.subTextColor,
                      ),
                    ),
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Obx(() {
      final isRequiredTab = controller.selectedViewTab.value == 'Required';
      final count = isRequiredTab
          ? controller.filteredRequiredCourses.length
          : controller.filteredRecords.length;

      final title = isRequiredTab
          ? (controller.selectedTelemetryId.value == 'compliant'
              ? 'Compliant Courses'
              : controller.selectedTelemetryId.value == 'pending'
                  ? 'Pending Courses'
                  : 'Required Courses')
          : (controller.selectedRecordFilter.value == 'All'
              ? 'Training Records'
              : '${controller.selectedRecordFilter.value} Records');

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.text14.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              '$count ${count == 1 ? 'item' : 'items'}',
              style: AppTextStyles.text10.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildContentList(BuildContext context) {
    return Obx(() {
      if (controller.isAccessRestricted.value) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: Center(
            child: CustomStateView.error(
              title: 'Access Restricted',
              message: controller.accessRestrictedMessage.value.isNotEmpty
                  ? controller.accessRestrictedMessage.value
                  : 'You do not have permission to view training records.',
            ),
          ),
        );
      }

      if (controller.isLoading.value) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.secondary,
              strokeWidth: 2.5.w,
            ),
          ),
        );
      }

      final isRequiredTab = controller.selectedViewTab.value == 'Required';

      if (isRequiredTab) {
        final list = controller.filteredRequiredCourses;
        if (list.isEmpty) {
          final isFilterActive =
              controller.selectedTelemetryId.value != 'required';
          return Center(
            child: CustomStateView.empty(
              icon: Icons.checklist_rounded,
              title: isFilterActive
                  ? 'No ${controller.selectedTelemetryId.value.capitalizeFirst} Courses'
                  : 'No Required Courses',
              message: isFilterActive
                  ? 'No courses found matching this compliance filter.'
                  : 'There are no mandatory training or compliance certifications required for your current role.',
              padding: EdgeInsets.symmetric(vertical: 36.h),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: list.length,
          separatorBuilder: (_, _) => AppSpaces.vSpace12,
          itemBuilder: (context, index) {
            final item = list[index];
            return TrainingRequiredCard(
              key: ValueKey(item.course.id),
              item: item,
            );
          },
        );
      } else {
        final list = controller.filteredRecords;
        if (list.isEmpty) {
          return Center(
            child: CustomStateView.empty(
              icon: Icons.history_edu_rounded,
              title: 'No Records Found',
              message:
                  'No training completion records matching the "${controller.selectedRecordFilter.value}" filter.',
              padding: EdgeInsets.symmetric(vertical: 36.h),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: list.length,
          separatorBuilder: (_, _) => AppSpaces.vSpace12,
          itemBuilder: (context, index) {
            final item = list[index];
            return TrainingRecordCard(
              key: ValueKey(item.id),
              record: item,
            );
          },
        );
      }
    });
  }
}
