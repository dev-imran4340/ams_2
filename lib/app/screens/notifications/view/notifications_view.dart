import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_spaces.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/widgets/custom_state_view.dart';
import '../../../core/widgets/network_boundary_wrapper.dart';
import '../../../routes/app_routes.dart';
import '../controller/notification_controller.dart';
import 'components/notification_filter_chip.dart';
import 'components/notification_tile.dart';

/// In-App Notifications Screen (The Bell)
/// Displays paginated notifications, filter by unread, and navigates seamlessly.
class NotificationsView extends GetView<NotificationController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkBoundaryWrapper(
      onRetry: () => controller.loadNotifications(isRefresh: true),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            // 1. Filter Chips (All vs Unread)
            _buildFilterSection(),

            // 2. Main Notifications List with Pull-to-Refresh
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.notifications.isEmpty) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2.5.w,
                    ),
                  );
                }

                if (controller.notifications.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () => controller.loadNotifications(isRefresh: true),
                    color: AppColors.secondary,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      child: Container(
                        height: 0.65.sh,
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: CustomStateView.empty(
                          title: controller.selectedFilter.value == 'unread'
                              ? 'All Caught Up!'
                              : 'No Notifications Yet',
                          message: controller.selectedFilter.value == 'unread'
                              ? 'You have reviewed all incoming requests and alerts.'
                              : 'When you receive request approvals, reminders, or team alerts, they will appear here.',
                          buttonText: 'Refresh',
                          onAction: () => controller.loadNotifications(isRefresh: true),
                        ),
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => controller.loadNotifications(isRefresh: true),
                  color: AppColors.secondary,
                  child: ListView.builder(
                    controller: controller.scrollController,
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                    itemCount: controller.notifications.length +
                        (controller.isLoadingMore.value ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == controller.notifications.length) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          child: Center(
                            child: SizedBox(
                              width: 24.w,
                              height: 24.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.w,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        );
                      }

                      final item = controller.notifications[index];
                      return NotificationTile(
                        item: item,
                        onTap: () => controller.onNotificationTap(item),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.backgroundColor,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColors.textColor,
          size: 20.sp,
        ),
        onPressed: () => Get.back(),
      ),
      title: Row(
        children: [
          Text(
            'Notifications',
            style: AppTextStyles.text18.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          AppSpaces.hSpace8,
          Obx(() {
            final unread = controller.unreadCount.value;
            if (unread == 0) return const SizedBox.shrink();
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                unread > 99 ? '99+' : '$unread',
                style: AppTextStyles.text10.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            );
          }),
        ],
      ),
      actions: [
        // Mark all as read button
        Obx(() {
          final isMarking = controller.isMarkingAllRead.value;
          final hasUnread = controller.unreadCount.value > 0;

          return IconButton(
            tooltip: 'Mark all as read',
            icon: isMarking
                ? SizedBox(
                    width: 16.w,
                    height: 16.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.w,
                      color: AppColors.primary,
                    ),
                  )
                : Icon(
                    Icons.done_all_rounded,
                    color: hasUnread ? AppColors.secondary : AppColors.subTextColor,
                    size: 22.sp,
                  ),
            onPressed: (!hasUnread || isMarking) ? null : controller.markAllAsRead,
          );
        }),

        // Preferences Screen Gear Button
        IconButton(
          tooltip: 'Notification Settings',
          icon: Icon(
            Icons.settings_outlined,
            color: AppColors.primary,
            size: 22.sp,
          ),
          onPressed: () => Get.toNamed(Routes.NOTIFICATION_PREFERENCES),
        ),

        AppSpaces.hSpace8,
      ],
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      child: Obx(() {
        final current = controller.selectedFilter.value;
        final unread = controller.unreadCount.value;

        return Row(
          children: [
            NotificationFilterChip(
              label: 'All Notifications',
              isSelected: current == 'all',
              onTap: () => controller.changeFilter('all'),
            ),
            AppSpaces.hSpace8,
            NotificationFilterChip(
              label: 'Unread Only',
              count: unread,
              isSelected: current == 'unread',
              onTap: () => controller.changeFilter('unread'),
            ),
          ],
        );
      }),
    );
  }
}
