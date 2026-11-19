import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_spaces.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/widgets/custom_screen_header.dart';
import '../../../core/widgets/custom_state_view.dart';
import '../../../core/widgets/custom_telemetry_strip.dart';
import '../../../core/widgets/employee_ambient_header.dart';
import '../../../core/widgets/network_boundary_wrapper.dart';
import '../controller/checklist_controller.dart';
import 'components/checklist_card.dart';

class ChecklistsView extends GetView<ChecklistController> {
  const ChecklistsView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkBoundaryWrapper(
      onRetry: controller.loadChecklists,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Stack(
          children: [
            // 1. Signature Curved Ambient Gradient Header (215.h)
            EmployeeAmbientHeader(height: 220.h),

            // 2. Main Scrollable Content
            SafeArea(
              bottom: false,
              child: RefreshIndicator(
                onRefresh: () => controller.loadChecklists(isRefresh: true),
                color: AppColors.secondary,
                child: SingleChildScrollView(
                  controller: controller.scrollController,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 8.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Back Pill, Title/Subtitle Capsule
                      const CustomScreenHeader(
                        title: 'Checklists',
                        subtitle: 'Onboarding & offboarding workflows',
                      ),

                      AppSpaces.vSpace14,

                      // Component 1: Telemetry Strip (Total, Onboarding, Offboarding, Completed)
                      _buildTelemetryStrip(),

                      AppSpaces.vSpace30,

                      // Section Header
                      _buildSectionHeader(),

                      AppSpaces.vSpace10,

                      // Component 2: Checklists List / States
                      _buildChecklistsList(),

                      // Safe bottom clearance
                      SizedBox(height: 80.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTelemetryStrip() {
    return Obx(() {
      final total = controller.totalCount;
      final onb = controller.onboardingCount;
      final offb = controller.offboardingCount;
      final done = controller.completedCount;

      final items = [
        CustomTelemetryItem(
          id: 'all',
          label: 'Total',
          count: total,
          icon: Icons.checklist_rtl_rounded,
          accentColor: AppColors.primary,
        ),
        CustomTelemetryItem(
          id: 'onboarding',
          label: 'Onboarding',
          count: onb,
          icon: Icons.how_to_reg_rounded,
          accentColor: AppColors.secondary,
        ),
        CustomTelemetryItem(
          id: 'offboarding',
          label: 'Offboarding',
          count: offb,
          icon: Icons.exit_to_app_rounded,
          accentColor: AppColors.primary,
        ),
        CustomTelemetryItem(
          id: 'completed',
          label: 'Completed',
          count: done,
          icon: Icons.task_alt_rounded,
          accentColor: AppColors.success,
        ),
      ];

      return CustomTelemetryStrip(
        items: items,
        selectedId: controller.selectedFilter.value,
        onSelect: controller.setFilter,
      );
    });
  }

  Widget _buildSectionHeader() {
    return Obx(() {
      final list = controller.filteredChecklists;
      final filter = controller.selectedFilter.value;
      final label = filter == 'all'
          ? 'All Checklists'
          : '${filter.capitalizeFirst} Checklists';

      // Dynamic contrast interpolation based on scroll offset:
      // When at rest on white background: AppColors.textColor (dark navy)
      // When scrolled up into the dark gradient: pure AppColors.white
      final offset = controller.scrollOffset.value;
      final double progress = (offset / 35.h).clamp(0.0, 1.0);

      final textColor = Color.lerp(
        AppColors.textColor,
        AppColors.white,
        progress,
      )!;

      final badgeBg = Color.lerp(
        AppColors.primary.withValues(alpha: 0.08),
        AppColors.white.withValues(alpha: 0.22),
        progress,
      )!;

      final badgeTextColor = Color.lerp(
        AppColors.primary,
        AppColors.white,
        progress,
      )!;

      final badgeBorder = Color.lerp(
        Colors.transparent,
        AppColors.white.withValues(alpha: 0.35),
        progress,
      )!;

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.text14.copyWith(
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: badgeBorder, width: 0.8.w),
            ),
            child: Text(
              '${list.length} ${list.length == 1 ? 'item' : 'items'}',
              style: AppTextStyles.text10.copyWith(
                fontWeight: FontWeight.bold,
                color: badgeTextColor,
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildChecklistsList() {
    return Obx(() {
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

      final list = controller.filteredChecklists;

      if (list.isEmpty) {
        final isFilterActive = controller.selectedFilter.value != 'all';
        return Center(
          child: CustomStateView.empty(
            icon: Icons.checklist_rounded,
            title: isFilterActive
                ? 'No ${controller.selectedFilter.value.capitalizeFirst} Checklists'
                : 'No Checklists Assigned',
            message: isFilterActive
                ? 'No checklists found matching this filter.'
                : 'You have no active or historical onboarding or offboarding checklists.',
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
          return ChecklistCard(key: ValueKey(item.id), checklist: item);
        },
      );
    });
  }
}
