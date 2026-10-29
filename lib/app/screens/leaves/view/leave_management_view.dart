import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_spaces.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_screen_header.dart';
import '../../../core/widgets/custom_state_view.dart';
import '../../../core/widgets/employee_ambient_header.dart';
import '../../../core/widgets/network_boundary_wrapper.dart';
import '../controller/leave_controller.dart';
import '../model/leave_model.dart';
import 'components/leave_balance_card.dart';
import 'components/leave_request_tile.dart';

/// Screen 2: Dedicated Leave Management System (Phase 11)
/// Focused entirely on employee leave balances, quotas, leave history,
/// sandwich calculation rules, and absence applications.
class LeaveManagementView extends GetView<LeaveController> {
  const LeaveManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkBoundaryWrapper(
      onRetry: () => controller.loadLeaveData(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Stack(
          children: [
            // 1. Signature Curved Ambient Gradient Background Container
            EmployeeAmbientHeader(height: 230.h),

            // 2. Overlapping Foreground Content
            SafeArea(
              child: Column(
                children: [
                  // Top Bar: Screen Title, Subtitle & Apply Leave Action Button
                  Padding(
                    padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 0),
                    child: Obx(() {
                      final hasLeaveModule = controller.isLeaveModuleActive.value;

                      return CustomScreenHeader(
                        title: 'Leave Management',
                        subtitle: 'Annual quota, balances & absence requests',
                        actions: (hasLeaveModule && !controller.isAccessRestricted.value)
                            ? [
                                CustomScreenHeader.actionButton(
                                  icon: Icons.add_rounded,
                                  tooltip: 'Apply for Leave',
                                  onTap: () =>
                                      controller.openApplyLeaveModal(context),
                                ),
                              ]
                            : null,
                      );
                    }),
                  ),

                  AppSpaces.vSpace14,

                  // Scrollable Body Content
                  Expanded(
                    child: Obx(() {
                      // Gate 1: If Leave module is not enabled for company
                      if (!controller.isLeaveModuleActive.value) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: CustomStateView.empty(
                              title: 'Leave Module Disabled',
                              message:
                                  'Leave management is not included in your company subscription plan.',
                            ),
                          ),
                        );
                      }

                      // Gate 2: If server returned 403 Forbidden for this user
                      if (controller.isAccessRestricted.value) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: CustomStateView.empty(
                              title: 'Access Restricted',
                              message: controller.accessRestrictedMessage.value.isNotEmpty
                                  ? controller.accessRestrictedMessage.value
                                  : 'You do not have permission to access Leave Management.',
                              buttonText: 'Back to Home',
                              onAction: () => Get.back(),
                            ),
                          ),
                        );
                      }

                      if (controller.isLoading.value &&
                          controller.balances.isEmpty &&
                          controller.leaveRequests.isEmpty) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2.5.w,
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: controller.loadLeaveData,
                        color: AppColors.primary,
                        child: CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          slivers: [
                            // Section 1: Leave Quota & Balances Header
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 14.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 3.5.w,
                                              height: 14.h,
                                              decoration: BoxDecoration(
                                                color: AppColors.secondary,
                                                borderRadius:
                                                    BorderRadius.circular(2.r),
                                              ),
                                            ),
                                            AppSpaces.hSpace8,
                                            Text(
                                              'LEAVE BALANCES',
                                              style:
                                                  AppTextStyles.text12.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textColor,
                                                letterSpacing: 1.1,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          'Annual Quotas',
                                          style: AppTextStyles.text10.copyWith(
                                            color: AppColors.subTextColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    AppSpaces.vSpace8,
                                    const LeaveBalanceCardStrip(),
                                  ],
                                ),
                              ),
                            ),

                            SliverToBoxAdapter(child: AppSpaces.vSpace16),

                            // Section 2: My Applications Heading & Filter Pills
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 14.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 3.5.w,
                                              height: 14.h,
                                              decoration: BoxDecoration(
                                                color: AppColors.primary,
                                                borderRadius:
                                                    BorderRadius.circular(2.r),
                                              ),
                                            ),
                                            AppSpaces.hSpace8,
                                            Text(
                                              'MY APPLICATIONS',
                                              style:
                                                  AppTextStyles.text12.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textColor,
                                                letterSpacing: 1.1,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          '${controller.filteredLeaveRequests.length} Total',
                                          style: AppTextStyles.text10.copyWith(
                                            color: AppColors.subTextColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    AppSpaces.vSpace10,
                                    _buildFilterPills(),
                                  ],
                                ),
                              ),
                            ),

                            SliverToBoxAdapter(child: AppSpaces.vSpace12),

                            // Section 3: Applications List or Empty View
                            if (controller.filteredLeaveRequests.isEmpty)
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
                                  child: CustomStateView.empty(
                                    title: 'No Leave Applications',
                                    message:
                                        'No leave records found matching the "${controller.selectedLeaveFilter.value}" status.',
                                    buttonText: 'Apply for Leave',
                                    onAction: () => controller
                                        .openApplyLeaveModal(context),
                                  ),
                                ),
                              )
                            else
                              SliverPadding(
                                padding: EdgeInsets.fromLTRB(
                                  14.w,
                                  0,
                                  14.w,
                                  80.h,
                                ),
                                sliver: SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final item = controller
                                          .filteredLeaveRequests[index];
                                      return LeaveRequestTile(
                                        item: item,
                                        onTap: () => _showLeaveDetailsSheet(context, item),
                                      );
                                    },
                                    childCount: controller
                                        .filteredLeaveRequests.length,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),

        // Prominent Floating Action Bar at the Bottom
        bottomNavigationBar: Obx(() {
          if (!controller.isLeaveModuleActive.value || controller.isAccessRestricted.value) {
            return const SizedBox.shrink();
          }

          return Container(
            padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 16.h),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 16.r,
                  offset: Offset(0, -4.h),
                ),
              ],
            ),
            child: SafeArea(
              child: CustomButton(
                text: 'Apply for Leave',
                isGradient: true,
                onPressed: () => controller.openApplyLeaveModal(context),
                icon: Icon(
                  Icons.add_rounded,
                  size: 18.sp,
                  color: AppColors.white,
                ),
                height: 48.h,
                borderRadius: 14.r,
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Status filter pills row (All, Pending, Approved, Rejected)
  Widget _buildFilterPills() {
    return Obx(() {
      final current = controller.selectedLeaveFilter.value;
      final filters = [
        {'id': 'all', 'label': 'All'},
        {'id': 'pending', 'label': 'Pending'},
        {'id': 'approved', 'label': 'Approved'},
        {'id': 'rejected', 'label': 'Rejected'},
      ];

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: filters.map((f) {
            final isSelected = current == f['id'];
            return Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: InkWell(
                onTap: () => controller.setLeaveFilter(f['id']!),
                borderRadius: BorderRadius.circular(20.r),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 6.h,
                  ),
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
                  ),
                  child: Text(
                    f['label']!,
                    style: AppTextStyles.text10.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? AppColors.white
                          : AppColors.textColor,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  /// Displays detailed modal bottom sheet for a leave request
  void _showLeaveDetailsSheet(BuildContext context, LeaveRequestItemModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.primary.withValues(alpha: 0.6),
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            border: Border(bottom: BorderSide(color: AppColors.secondary, width: 3.w)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top drag handle
                Center(
                  child: Container(
                    width: 38.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColors.borderColor,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                AppSpaces.vSpace14,

                // Title row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.leaveType,
                          style: AppTextStyles.text16.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                        AppSpaces.vSpace4,
                        Text(
                          '#${item.id}',
                          style: AppTextStyles.text10.copyWith(
                            color: AppColors.subTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: (item.isApproved
                                ? AppColors.success
                                : item.isPending
                                    ? AppColors.warning
                                    : AppColors.error)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        item.statusLabel,
                        style: AppTextStyles.text10.copyWith(
                          fontWeight: FontWeight.bold,
                          color: item.isApproved
                              ? AppColors.success
                              : item.isPending
                                  ? AppColors.warning
                                  : AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpaces.vSpace16,

                // Date and duration cards
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(15.r),
                    border: Border.all(color: AppColors.borderColor, width: 0.8.w),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DURATION',
                              style: AppTextStyles.text10.copyWith(
                                color: AppColors.subTextColor,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                            AppSpaces.vSpace4,
                            Text(
                              '${item.startsOn} → ${item.endsOn}',
                              style: AppTextStyles.text12.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          item.amountText,
                          style: AppTextStyles.text12.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpaces.vSpace12,

                // Reason card
                Text(
                  'REASON',
                  style: AppTextStyles.text10.copyWith(
                    color: AppColors.subTextColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                AppSpaces.vSpace4,
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.borderColor, width: 0.8.w),
                  ),
                  child: Text(
                    item.reason,
                    style: AppTextStyles.text12.copyWith(
                      color: AppColors.textColor,
                      height: 1.4,
                    ),
                  ),
                ),

                if (item.isPending) ...[
                  AppSpaces.vSpace16,
                  CustomButton(
                    text: 'Cancel Application',
                    isOutlined: true,
                    onPressed: () {
                      Navigator.pop(ctx);
                      controller.cancelLeave(item.id, 'Withdrawn by employee');
                    },
                    height: 44.h,
                    borderRadius: 12.r,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
