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
import '../controller/news_controller.dart';
import 'components/announcement_card.dart';
import 'components/birthday_privacy_card.dart';
import 'components/event_card.dart';
import 'components/event_date_range_sheet.dart';
import 'components/milestone_card.dart';

class NewsView extends GetView<NewsController> {
  const NewsView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkBoundaryWrapper(
      onRetry: () => controller.loadActiveTab(isRefresh: true),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Stack(
          children: [
            // 1. Signature Ambient Curved Gradient Header
            EmployeeAmbientHeader(height: 220.h),

            // 2. Safe Area Content
            SafeArea(
              child: Column(
                children: [
                  // Top Navigation Header
                  Padding(
                    padding: AppSpaces.horizontalPadding,
                    child: CustomScreenHeader(
                      title: 'News & Events',
                      subtitle: 'Announcements, events & milestones',
                    ),
                  ),

                  AppSpaces.vSpace10,

                  // 3-Tab Capsule Switcher
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                    child: _buildCapsuleTabSwitcher(),
                  ),

                  AppSpaces.vSpace10,

                  // Body Content (Switched per Active Tab)
                  Expanded(
                    child: Obx(() {
                      switch (controller.selectedTabIndex.value) {
                        case 0:
                          return _buildAnnouncementsTab();
                        case 1:
                          return _buildEventsTab();
                        case 2:
                          return _buildMilestonesTab();
                        default:
                          return _buildAnnouncementsTab();
                      }
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

  /// 3-Tab Segmented Capsule Bar
  Widget _buildCapsuleTabSwitcher() {
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(25.r),
        border: Border.all(color: AppColors.borderColor, width: 0.8.w),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 10.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Obx(() {
        final activeTab = controller.selectedTabIndex.value;
        final unread = controller.unreadAnnouncementsCount.value;

        return Row(
          children: [
            _buildTabPill(
              index: 0,
              label: 'Announcements',
              badgeCount: unread,
              isActive: activeTab == 0,
            ),
            _buildTabPill(
              index: 1,
              label: 'Events',
              isActive: activeTab == 1,
            ),
            _buildTabPill(
              index: 2,
              label: 'Milestones',
              isActive: activeTab == 2,
            ),
          ],
        );
      }),
    );
  }

  Widget _buildTabPill({
    required int index,
    required String label,
    required bool isActive,
    int? badgeCount,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.switchTab(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: AppTextStyles.text12.copyWith(
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? Colors.white : AppColors.subTextColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (badgeCount != null && badgeCount > 0) ...[
                AppSpaces.hSpace4,
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    badgeCount.toString(),
                    style: AppTextStyles.text10.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 9.sp,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Tab 0: Announcements List (Dedicated Loader & Tab-specific Refresh)
  Widget _buildAnnouncementsTab() {
    return Obx(() {
      if (controller.isLoadingAnnouncements.value) {
        return Center(
          child: CircularProgressIndicator(
            color: AppColors.secondary,
            strokeWidth: 2.5.w,
          ),
        );
      }

      final list = controller.announcements;

      if (list.isEmpty) {
        return LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: CustomStateView.empty(
                  icon: Icons.campaign_outlined,
                  title: 'No Announcements',
                  message: 'No published announcements for you at this time.',
                  buttonText: 'Refresh',
                  onAction: () => controller.loadAnnouncements(isRefresh: true),
                ),
              ),
            ),
          ),
        );
      }

      return RefreshIndicator(
        color: AppColors.secondary,
        onRefresh: () => controller.loadAnnouncements(isRefresh: true),
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: EdgeInsets.fromLTRB(14.w, 4.h, 14.w, 24.h),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final item = list[index];
            return AnnouncementCard(
              announcement: item,
              onTap: () => controller.openAnnouncementDetails(item.id),
            );
          },
        ),
      );
    });
  }

  /// Tab 1: Company Events List (Dedicated Loader & Tab-specific Refresh)
  Widget _buildEventsTab() {
    return Column(
      children: [
        // Event Date Range Selector Bar
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 2.h),
          child: _buildEventDateFilterBar(),
        ),

        AppSpaces.vSpace4,

        Expanded(
          child: Obx(() {
            if (controller.isLoadingEvents.value) {
              return Center(
                child: CircularProgressIndicator(
                  color: AppColors.secondary,
                  strokeWidth: 2.5.w,
                ),
              );
            }

            final list = controller.events;

            if (list.isEmpty) {
              return LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: Center(
                      child: CustomStateView.empty(
                        icon: Icons.event_available_rounded,
                        title: 'No Upcoming Events',
                        message: controller.hasCustomEventDateFilter.value
                            ? 'No events found within the selected date range.'
                            : 'There are no company events scheduled in the next 60 days.',
                        buttonText: 'Refresh',
                        onAction: () => controller.loadEvents(isRefresh: true),
                      ),
                    ),
                  ),
                ),
              );
            }

            return RefreshIndicator(
              color: AppColors.secondary,
              onRefresh: () => controller.loadEvents(isRefresh: true),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: EdgeInsets.fromLTRB(14.w, 4.h, 14.w, 24.h),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  return EventCard(event: list[index]);
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  /// Event Date Filter Header Bar
  Widget _buildEventDateFilterBar() {
    return Obx(() {
      final label = controller.activeEventRangeLabel.value;
      final isFiltered = controller.hasCustomEventDateFilter.value;

      return GestureDetector(
        onTap: () => EventDateRangeSheet.show(Get.context!, controller),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isFiltered ? AppColors.secondary : AppColors.borderColor,
              width: 1.w,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.04),
                blurRadius: 6.r,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_month_outlined,
                size: 16.w,
                color: isFiltered ? AppColors.secondary : AppColors.primary,
              ),
              AppSpaces.hSpace8,
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.text12.copyWith(
                    fontWeight: isFiltered ? FontWeight.w700 : FontWeight.w600,
                    color:
                        isFiltered ? AppColors.secondary : AppColors.textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isFiltered)
                GestureDetector(
                  onTap: () => controller.resetEventDateFilter(),
                  child: Padding(
                    padding: EdgeInsets.all(2.r),
                    child: Icon(
                      Icons.cancel_rounded,
                      size: 16.w,
                      color: AppColors.subTextColor,
                    ),
                  ),
                )
              else
                Icon(
                  Icons.arrow_drop_down_rounded,
                  size: 20.w,
                  color: AppColors.subTextColor,
                ),
            ],
          ),
        ),
      );
    });
  }

  /// Tab 2: Colleague Milestones & Privacy Switcher (Dedicated Loader & Tab-specific Refresh)
  Widget _buildMilestonesTab() {
    return RefreshIndicator(
      color: AppColors.secondary,
      onRefresh: () => controller.loadMilestones(isRefresh: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(14.w, 4.h, 14.w, 24.h),
        children: [
          // Modern Solid Birthday Sharing Card
          Obx(() {
            return BirthdayPrivacyCard(
              isShared: controller.isBirthdayShared.value,
              isLoading: controller.isUpdatingPrivacy.value,
              onToggle: (val) => controller.toggleBirthdaySharing(val),
            );
          }),

          Obx(() {
            if (controller.isLoadingMilestones.value) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 40.h),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.secondary,
                    strokeWidth: 2.5.w,
                  ),
                ),
              );
            }

            final list = controller.milestones;

            if (list.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 30.h),
                child: Center(
                  child: CustomStateView.empty(
                    icon: Icons.celebration_outlined,
                    title: 'No Milestones Ahead',
                    message:
                        'No birthdays or work anniversaries at your location in the next 14 days.',
                    buttonText: 'Refresh',
                    onAction: () => controller.loadMilestones(isRefresh: true),
                  ),
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                  child: Text(
                    'Next 14 Days',
                    style: AppTextStyles.text12.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.subTextColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                AppSpaces.vSpace4,
                ...list.map((m) => MilestoneCard(milestone: m)),
              ],
            );
          }),
        ],
      ),
    );
  }
}
