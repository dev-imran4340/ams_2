import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_spaces.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/widgets/custom_state_view.dart';
import '../../../core/widgets/network_boundary_wrapper.dart';
import '../controller/leave_controller.dart';
import 'components/leave_balance_card.dart';
import 'components/leave_request_tile.dart';

class LeaveRequestsView extends GetView<LeaveController> {
  const LeaveRequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkBoundaryWrapper(
      onRetry: () => controller.loadLeaveData(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2.5.w,
              ),
            );
          }

          return Stack(
            children: [
              // 1. Curved Ambient Gradient Header
              _buildAmbientHeader(),

              // 2. Main Scrollable Content Overlapping the Header
              SafeArea(
                child: RefreshIndicator(
                  onRefresh: controller.loadLeaveData,
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
                        // Top Executive Header: Title & Apply Leave Action Button
                        _buildTopBar(context),

                        AppSpaces.vSpace14,

                        // Section 1: Quota Balances Carousel
                        const LeaveBalanceCardStrip(),

                        AppSpaces.vSpace16,

                        // Section 2: Request Status Filter Chips
                        _buildFilterStrip(),

                        AppSpaces.vSpace14,

                        // Section 3: Applications Section Header
                        _buildSectionHeader(),

                        AppSpaces.vSpace10,

                        // Section 4: Applications List or Empty State
                        _buildRequestsList(context),

                        // Bottom safe clearance for the floating navigation bar
                        SizedBox(height: 85.h),
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

  /// Ambient Curved Gradient Header matching executive style
  Widget _buildAmbientHeader() {
    return Container(
      width: double.infinity,
      height: 220.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.liteSecondary,
            AppColors.liteSecondary,
            AppColors.liteSecondary,
            AppColors.liteSecondary,
            AppColors.secondary,
            AppColors.primary,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.r),
          bottomRight: Radius.circular(20.r),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -60.r,
            right: -40.r,
            child: Container(
              width: 140.r,
              height: 140.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: 20.r,
            left: -50.r,
            child: Container(
              width: 120.r,
              height: 120.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withValues(alpha: 0.05),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Top executive navigation bar with Title and Quick Apply Button
  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Title & Subtitle with flex protection
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Time-Off & Leaves',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.text18.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              AppSpaces.vSpace2,
              Text(
                'Track balance, apply requests & monitor approvals',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.text10.copyWith(
                  color: AppColors.textColor.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
        ),

        AppSpaces.hSpace8,

        // Top Action: Apply Leave Button Capsule
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => controller.openApplyLeaveModal(context),
            borderRadius: BorderRadius.circular(20.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.9),
                  width: 1.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 10.r,
                    offset: Offset(0, 3.h),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 22.r,
                    height: 22.r,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      size: 15.sp,
                      color: AppColors.white,
                    ),
                  ),
                  AppSpaces.hSpace6,
                  Text(
                    'Apply Leave',
                    style: AppTextStyles.text12.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Filter tabs for request approval states (All, Pending, Approved, Rejected)
  Widget _buildFilterStrip() {
    final filters = ['All', 'Pending', 'Approved', 'Rejected'];

    return Obx(() {
      final current = controller.selectedFilter.value;

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: filters.map((filter) {
            final isSelected = current.toLowerCase() == filter.toLowerCase();

            // Calculate count for this filter
            int count;
            if (filter == 'All') {
              count = controller.requests.length;
            } else {
              count = controller.requests
                  .where((r) => r.status.toLowerCase() == filter.toLowerCase())
                  .length;
            }

            return Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: InkWell(
                onTap: () => controller.setFilter(filter),
                borderRadius: BorderRadius.circular(20.r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.borderColor,
                      width: 1.w,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          blurRadius: 8.r,
                          offset: Offset(0, 3.h),
                        ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        filter,
                        style: AppTextStyles.text12.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? AppColors.white
                              : AppColors.textColor,
                        ),
                      ),
                      AppSpaces.hSpace6,
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 5.w,
                          vertical: 1.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.white.withValues(alpha: 0.25)
                              : AppColors.inputFill,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          '$count',
                          style: AppTextStyles.text10.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? AppColors.white
                                : AppColors.subTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  /// Section Header: Applications count & title
  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 4.w,
              height: 16.h,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            AppSpaces.hSpace8,
            Text(
              'Recent Applications',
              style: AppTextStyles.text16.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
          ],
        ),
        Obx(
          () => Text(
            '${controller.filteredRequests.length} Requests',
            style: AppTextStyles.text12.copyWith(
              color: AppColors.subTextColor,
            ),
          ),
        ),
      ],
    );
  }

  /// Applications List or Empty State
  Widget _buildRequestsList(BuildContext context) {
    return Obx(() {
      final items = controller.filteredRequests;

      if (items.isEmpty) {
        return Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(vertical: 20.h),
          child: CustomStateView.empty(
            title: 'No Leave Requests Found',
            message:
                'You currently have no ${controller.selectedFilter.value.toLowerCase()} requests on record.',
            buttonText: 'Apply For Leave',
            onAction: () => controller.openApplyLeaveModal(context),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return LeaveRequestTile(
            item: item,
            onTap: () {
              HapticFeedback.lightImpact();
            },
          );
        },
      );
    });
  }
}
