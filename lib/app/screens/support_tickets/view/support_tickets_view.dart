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
import '../controller/support_ticket_controller.dart';
import 'components/create_ticket_bottom_sheet.dart';
import 'components/support_ticket_card.dart';
import 'components/ticket_thread_bottom_sheet.dart';
import 'components/training_video_card.dart';

/// Main View for Support Tickets, Helpdesk & Training Videos (Phase 10)
/// Strictly adheres to .agents/rules/ams.md:
/// - Root wrapped in NetworkBoundaryWrapper
/// - View only calls Controller methods and observes state via Obx
/// - Permission-driven access (support.view and support.raise for tickets)
/// - Universal access for training videos without permission gates
class SupportTicketsView extends GetView<SupportTicketController> {
  const SupportTicketsView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkBoundaryWrapper(
      onRetry: () async {
        if (controller.selectedMainTab.value == 0) {
          await controller.loadTickets(isRefresh: true);
        } else {
          await controller.loadTrainingVideos(isRefresh: true);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Stack(
          children: [
            // 1. Signature Curved Ambient Background
            EmployeeAmbientHeader(height: 220.h),

            // 2. Main Foreground Layout
            SafeArea(
              child: Column(
                children: [
                  // Top Screen Header with Title & Action Button
                  Padding(
                    padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 0),
                    child: Obx(() {
                      final canRaise = controller.canRaise;
                      final isForbidden = controller.isForbidden.value;
                      final isTicketsTab =
                          controller.selectedMainTab.value == 0;

                      return CustomScreenHeader(
                        title: 'Help & Support',
                        subtitle: isTicketsTab
                            ? 'Submit inquiries, report issues & get assistance'
                            : 'Watch official AMS feature guides and walkthroughs',
                        actions: (isTicketsTab && canRaise && !isForbidden)
                            ? [
                                CustomScreenHeader.actionButton(
                                  icon: Icons.add_rounded,
                                  tooltip: 'New Ticket',
                                  onTap: () => CreateTicketBottomSheet.show(
                                    context,
                                    controller,
                                  ),
                                ),
                              ]
                            : null,
                      );
                    }),
                  ),

                  AppSpaces.vSpace10,

                  // Main Segmented Switcher (Support Tickets vs Training Videos)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Obx(() => _buildMainSectionSwitch()),
                  ),

                  AppSpaces.vSpace10,

                  // Body Area (Tickets vs Videos)
                  Expanded(
                    child: Obx(() {
                      if (controller.selectedMainTab.value == 0) {
                        return _buildTicketsSection(context);
                      } else {
                        return _buildVideosSection(context);
                      }
                    }),
                  ),
                ],
              ),
            ),

            // Loading overlay for ticket thread fetching
            Obx(() {
              if (!controller.isLoadingThread.value) {
                return const SizedBox.shrink();
              }
              return Container(
                color: Colors.black.withValues(alpha: 0.35),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 18.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 16.r,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 20.r,
                          height: 20.r,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: AppColors.secondary,
                          ),
                        ),
                        AppSpaces.hSpace16,
                        Text(
                          'Opening Discussion...',
                          style: AppTextStyles.text14.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// Modern Floating Capsule Switcher: Support Tickets vs Training Videos
  /// Clean, flat, and instant selection with zero distracting shadows or animation effects.
  Widget _buildMainSectionSwitch() {
    final selectedTab = controller.selectedMainTab.value;

    return Container(
      height: 46.h,
      padding: EdgeInsets.all(3.5.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: AppColors.borderColor,
          width: 1.w,
        ),
      ),
      child: Row(
        children: [
          // 1. Support Tickets Pill
          Expanded(
            child: _buildCapsuleOption(
              label: 'Support Tickets',
              icon: Icons.confirmation_number_outlined,
              isSelected: selectedTab == 0,
              badgeCount: controller.hasLoadedActiveTickets.value
                  ? controller.activeTickets.length
                  : null,
              onTap: () => controller.setMainTab(0),
            ),
          ),

          // 2. Training Videos Pill
          Expanded(
            child: _buildCapsuleOption(
              label: 'Training Videos',
              icon: Icons.ondemand_video_rounded,
              isSelected: selectedTab == 1,
              badgeCount: controller.hasLoadedTrainingVideos.value
                  ? controller.trainingVideos.length
                  : null,
              onTap: () => controller.setMainTab(1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapsuleOption({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    int? badgeCount,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 17.r,
              color: isSelected ? AppColors.secondary : AppColors.subTextColor,
            ),
            AppSpaces.hSpace8,
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.text12.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.subTextColor,
                ),
              ),
            ),
            if (badgeCount != null && badgeCount > 0) ...[
              AppSpaces.hSpace6,
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.secondary.withValues(alpha: 0.28)
                      : AppColors.borderColor.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  '$badgeCount',
                  style: AppTextStyles.text10.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? AppColors.secondary
                        : AppColors.subTextColor,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Tickets Section with Sub-filters (Active vs Finished) and Ticket Cards
  Widget _buildTicketsSection(BuildContext context) {
    // If ticket access is forbidden, show message but let user stay on screen
    if (controller.isForbidden.value) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomStateView.error(
                title: 'Ticket Access Restricted',
                message: controller.forbiddenMessage.value,
              ),
              AppSpaces.vSpace16,
              TextButton.icon(
                onPressed: () => controller.setMainTab(1),
                icon: Icon(
                  Icons.play_circle_outline_rounded,
                  color: AppColors.secondary,
                ),
                label: Text(
                  'Browse Training Videos Instead',
                  style: AppTextStyles.text14.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Minimalist Status Filter Row (Section title on left, Status chips on right)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Obx(() => _buildStatusFilterRow()),
        ),

        AppSpaces.vSpace10,

        // Tickets List Area
        Expanded(
          child: Obx(() {
            // 1. Loading State (Initial load, filter change, or refresh action)
            if (controller.isLoading.value) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 32.r,
                      height: 32.r,
                      child: CircularProgressIndicator(
                        color: AppColors.secondary,
                        strokeWidth: 2.8.w,
                      ),
                    ),
                    AppSpaces.vSpace12,
                    Text(
                      'Loading Support Tickets...',
                      style: AppTextStyles.text12.copyWith(
                        color: AppColors.subTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }

            final currentTickets = controller.currentTickets;

            // 2. Empty State with Refresh Action (Centered vertically in display)
            if (currentTickets.isEmpty) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return RefreshIndicator(
                    onRefresh: () => controller.loadTickets(isRefresh: true),
                    color: AppColors.secondary,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(minHeight: constraints.maxHeight),
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                            child: CustomStateView.empty(
                              icon: Icons.inbox_rounded,
                              onAction: () =>
                                  controller.loadTickets(isRefresh: true),
                              buttonText: 'Refresh',
                              title: controller.showFinished.value
                                  ? 'No Closed Tickets'
                                  : 'No Open Tickets',
                              message: controller.showFinished.value
                                  ? 'You have no resolved or closed support inquiries on record.'
                                  : 'No pending support tickets found. Need assistance? Tap "New Ticket" to contact support.',
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }

            // 3. Ticket List
            return RefreshIndicator(
              onRefresh: () => controller.loadTickets(isRefresh: true),
              color: AppColors.secondary,
              child: ListView.builder(
                controller: controller.scrollController,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                itemCount: currentTickets.length,
                itemBuilder: (ctx, index) {
                  final ticket = currentTickets[index];
                  return SupportTicketCard(
                    ticket: ticket,
                    onTap: () async {
                      final opened = await controller.openTicketThread(
                        ticket.id,
                      );
                      if (opened && context.mounted) {
                        TicketThreadBottomSheet.show(context, controller);
                      }
                    },
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  /// Training Videos Section (Universal access)
  Widget _buildVideosSection(BuildContext context) {
    return Obx(() {
      // 1. Loading State (Initial load or refresh action)
      if (controller.isLoadingVideos.value) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 32.r,
                height: 32.r,
                child: CircularProgressIndicator(
                  color: AppColors.secondary,
                  strokeWidth: 2.8.w,
                ),
              ),
              AppSpaces.vSpace12,
              Text(
                'Loading Training Videos...',
                style: AppTextStyles.text12.copyWith(
                  color: AppColors.subTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }

      final videos = controller.trainingVideos;

      // 2. Empty State with Refresh Action (Centered vertically in display)
      if (videos.isEmpty) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return RefreshIndicator(
              onRefresh: () => controller.loadTrainingVideos(isRefresh: true),
              color: AppColors.secondary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: CustomStateView.empty(
                        icon: Icons.ondemand_video_rounded,
                        onAction: () =>
                            controller.loadTrainingVideos(isRefresh: true),
                        buttonText: 'Refresh',
                        title: 'No Training Videos',
                        message:
                            'No training videos have been shared with your company yet. Check back soon for guides and walkthroughs.',
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }

      // 3. Videos List
      return RefreshIndicator(
        onRefresh: () => controller.loadTrainingVideos(isRefresh: true),
        color: AppColors.secondary,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          itemCount: videos.length,
          itemBuilder: (ctx, index) {
            final video = videos[index];
            return TrainingVideoCard(
              video: video,
              onTap: () => controller.openTrainingVideo(video),
            );
          },
        ),
      );
    });
  }

  /// Minimalist Status Filter Row:
  /// Left: Clean Section Label with indicator dot.
  /// Right: Modern interactive status chips (Active vs Closed) with prominent selected colors.
  Widget _buildStatusFilterRow() {
    final isFinished = controller.showFinished.value;
    final activeCount = controller.activeTickets.length;
    final finishedCount = controller.finishedTickets.length;
    final hasLoadedActive = controller.hasLoadedActiveTickets.value;
    final hasLoadedFinished = controller.hasLoadedFinishedTickets.value;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left: Clean Section Label with Accent Bar
        Row(
          children: [
            Container(
              width: 3.5.w,
              height: 12.h,
              decoration: BoxDecoration(
                color: isFinished ? AppColors.primary : AppColors.secondary,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            AppSpaces.hSpace6,
            Text(
              isFinished ? 'RESOLVED & CLOSED' : 'ACTIVE INQUIRIES',
              style: AppTextStyles.text10.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),

        // Right: Status Filter Chips (Active vs Closed)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Active Chip (Solid Modern Teal when selected)
            _buildStatusChip(
              label: 'Active',
              count: hasLoadedActive ? activeCount : null,
              isSelected: !isFinished,
              activeColor: AppColors.secondary,
              leading: Container(
                width: 6.5.r,
                height: 6.5.r,
                decoration: BoxDecoration(
                  color: !isFinished
                      ? Colors.white
                      : AppColors.subTextColor.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
              ),
              onTap: () => controller.setFilter(false),
            ),

            AppSpaces.hSpace8,

            // 2. Closed Chip (Solid Corporate Navy when selected)
            _buildStatusChip(
              label: 'Closed',
              count: hasLoadedFinished ? finishedCount : null,
              isSelected: isFinished,
              activeColor: AppColors.primary,
              leading: Icon(
                isFinished
                    ? Icons.check_circle_rounded
                    : Icons.check_circle_outline_rounded,
                size: 13.5.r,
                color: isFinished ? AppColors.secondary : AppColors.subTextColor,
              ),
              onTap: () => controller.setFilter(true),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip({
    required String label,
    required bool isSelected,
    required Color activeColor,
    required Widget leading,
    required VoidCallback onTap,
    int? count,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? activeColor : AppColors.borderColor,
            width: 1.w,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            leading,
            AppSpaces.hSpace6,
            Text(
              label,
              style: AppTextStyles.text12.copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.subTextColor,
              ),
            ),
            if (count != null) ...[
              AppSpaces.hSpace6,
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.24)
                      : AppColors.borderColor.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  '$count',
                  style: AppTextStyles.text10.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : AppColors.subTextColor,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
