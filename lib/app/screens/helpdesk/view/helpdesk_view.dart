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
import '../controller/helpdesk_controller.dart';
import 'components/create_helpdesk_ticket_bottom_sheet.dart';
import 'components/helpdesk_ticket_card.dart';

class HelpdeskView extends GetView<HelpdeskController> {
  const HelpdeskView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkBoundaryWrapper(
      onRetry: () => controller.loadInitialData(isRefresh: true),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Stack(
          children: [
            // 1. Signature Curved Ambient Header (215.h)
            EmployeeAmbientHeader(height: 215.h),

            // 2. Sticky Header + Scrollable Body
            SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 0),
                    child: CustomScreenHeader(
                      title: 'HR Helpdesk',
                      subtitle: 'Corporate inquiries & service desk',
                      actions: [
                        CustomScreenHeader.actionButton(
                          icon: Icons.add_rounded,
                          tooltip: 'Open Ticket',
                          onTap: () =>
                              CreateHelpdeskTicketBottomSheet.show(context),
                        ),
                      ],
                    ),
                  ),
                  AppSpaces.vSpace14,
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () =>
                          controller.loadInitialData(isRefresh: true),
                      color: AppColors.secondary,
                      child: SingleChildScrollView(
                        controller: controller.scrollController,
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
                            // Component 1: Telemetry Strip (Total, Open, In Progress, Resolved)
                            _buildTelemetryStrip(),

                      AppSpaces.vSpace14,

                      // Component 2: Category Filter Chips
                      _buildCategoryChips(),

                      AppSpaces.vSpace16,

                      // Section Header with Dynamic Background Contrast Adaptation
                      _buildSectionHeader(),

                      AppSpaces.vSpace10,

                      // Component 3: Tickets List or Centered States
                      _buildTicketsList(),

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
          ],
        ),
      ),
    );
  }

  Widget _buildTelemetryStrip() {
    return Obx(() {
      final total = controller.totalCount;
      final open = controller.openCount;
      final inProgress = controller.inProgressCount;
      final resolved = controller.resolvedCount;

      final items = [
        CustomTelemetryItem(
          id: 'all',
          label: 'Total',
          count: total,
          icon: Icons.confirmation_number_outlined,
          accentColor: AppColors.primary,
        ),
        CustomTelemetryItem(
          id: 'open',
          label: 'Open',
          count: open,
          icon: Icons.access_time_rounded,
          accentColor: AppColors.warning,
        ),
        CustomTelemetryItem(
          id: 'in_progress',
          label: 'In Progress',
          count: inProgress,
          icon: Icons.sync_rounded,
          accentColor: AppColors.secondary,
        ),
        CustomTelemetryItem(
          id: 'resolved',
          label: 'Resolved',
          count: resolved,
          icon: Icons.check_circle_outline_rounded,
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

  Widget _buildCategoryChips() {
    return Obx(() {
      final cats = controller.categories;
      if (cats.isEmpty) return const SizedBox.shrink();

      final allCategories = ['All', ...cats.map((c) => c.name)];
      final selected = controller.selectedCategoryFilter.value;

      return SizedBox(
        height: 32.h,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: allCategories.length,
          separatorBuilder: (_, _) => AppSpaces.hSpace8,
          itemBuilder: (context, index) {
            final cat = allCategories[index];
            final isSelected = selected == cat;

            return InkWell(
              onTap: () => controller.setCategoryFilter(cat),
              borderRadius: BorderRadius.circular(16.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.borderColor,
                    width: 0.8.w,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            blurRadius: 4.r,
                            offset: Offset(0, 2.h),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    cat,
                    style: AppTextStyles.text10.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textColor,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildSectionHeader() {
    return Obx(() {
      final list = controller.filteredTickets;
      final filter = controller.selectedFilter.value;
      final label = filter == 'all'
          ? 'All Tickets'
          : '${filter.capitalizeFirst} Tickets';

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
              '${list.length} ${list.length == 1 ? 'ticket' : 'tickets'}',
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

  Widget _buildTicketsList() {
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

      final list = controller.filteredTickets;

      if (list.isEmpty) {
        final isFilterActive = controller.selectedFilter.value != 'all' ||
            controller.selectedCategoryFilter.value != 'All';
        return Center(
          child: CustomStateView.empty(
            icon: Icons.confirmation_number_outlined,
            title: isFilterActive
                ? 'No Tickets Found'
                : 'No Helpdesk Tickets',
            message: isFilterActive
                ? 'No tickets match the selected status or category filter.'
                : 'You have not submitted any helpdesk inquiries yet. Tap "+ Open Ticket" to submit one.',
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
          final ticket = list[index];
          return HelpdeskTicketCard(
            key: ValueKey(ticket.id),
            ticket: ticket,
          );
        },
      );
    });
  }
}
