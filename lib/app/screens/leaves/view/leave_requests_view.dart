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
import '../controller/leave_controller.dart';
import 'components/approval_request_tile.dart';

class LeaveRequestsView extends GetView<LeaveController> {
  const LeaveRequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkBoundaryWrapper(
      onRetry: () => controller.loadLeaveData(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Stack(
          children: [
            // 1. Signature Curved Ambient Gradient Background Container (Consistent across all screens)
            EmployeeAmbientHeader(height: 230.h),

            // 2. Overlapping Foreground Content
            SafeArea(
              child: Column(
                children: [
                  // 1. Top Bar: Screen Title, Subtitle & Apply Leave Action
                  Padding(
                    padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 0),
                    child: _buildTopBar(context),
                  ),

                  AppSpaces.vSpace12,

                  // 2. Approvals 4 Boxes Filter Tabs (waiting, mine, pending, decided)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: _buildBoxFilterStrip(),
                  ),

                  AppSpaces.vSpace16,

                  // 3. Requests List or Centered Empty State
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoading.value &&
                          controller.approvalsList.isEmpty) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2.5.w,
                          ),
                        );
                      }

                      if (controller.approvalsList.isEmpty) {
                        return RefreshIndicator(
                          onRefresh: controller.loadLeaveData,
                          color: AppColors.primary,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            child: Container(
                              height: 0.6.sh,
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: CustomStateView.empty(
                                title: 'Not Found',
                                message:
                                    'No approval requests found for this box.',
                                buttonText: 'Refresh',
                                onAction: controller.fetchApprovals,
                              ),
                            ),
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: controller.loadLeaveData,
                        color: AppColors.primary,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: EdgeInsets.fromLTRB(12.w, 4.h, 12.w, 85.h),
                          itemCount: controller.approvalsList.length,
                          itemBuilder: (context, index) {
                            final item = controller.approvalsList[index];
                            return ApprovalRequestTile(
                              item: item,
                              onTap: () =>
                                  controller.openApprovalDetails(context, item),
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

  /// Top executive navigation bar with Title, Subtitle and Apply Leave Action Button
  Widget _buildTopBar(BuildContext context) {
    return CustomScreenHeader(
      title: 'Requests & Approvals',
      subtitle: 'Approvals & requests inbox',
    );
  }

  /// 4 Standard Approvals Boxes in a prominent 2x2 executive card grid
  /// Beautifully occupying the ambient header container space
  Widget _buildBoxFilterStrip() {
    return Obx(() {
      final current = controller.selectedBox.value;

      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildBoxTabCard(
                  key: 'waiting',
                  label: 'Waiting',
                  icon: Icons.pending_actions_rounded,
                  isSelected: current == 'waiting',
                ),
              ),
              AppSpaces.hSpace10,
              Expanded(
                child: _buildBoxTabCard(
                  key: 'mine',
                  label: 'My Requests',
                  icon: Icons.send_rounded,
                  isSelected: current == 'mine',
                ),
              ),
            ],
          ),
          AppSpaces.vSpace10,
          Row(
            children: [
              Expanded(
                child: _buildBoxTabCard(
                  key: 'pending',
                  label: 'Pending',
                  icon: Icons.corporate_fare_rounded,
                  isSelected: current == 'pending',
                ),
              ),
              AppSpaces.hSpace10,
              Expanded(
                child: _buildBoxTabCard(
                  key: 'decided',
                  label: 'Decided',
                  icon: Icons.task_alt_rounded,
                  isSelected: current == 'decided',
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  /// Individual prominent tab card with icon pill, title, signature teal bottom accent,
  /// and active count chip
  Widget _buildBoxTabCard({
    required String key,
    required String label,
    required IconData icon,
    required bool isSelected,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => controller.changeBox(key),
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.cardBackground,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: isSelected ? AppColors.secondary : AppColors.borderColor,
              width: isSelected ? 1.5.w : 1.w,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.18)
                    : AppColors.primary.withValues(alpha: 0.04),
                blurRadius: isSelected ? 10.r : 6.r,
                offset: Offset(0, 3.h),
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(7.r),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.secondary.withValues(alpha: 0.2)
                            : AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        icon,
                        size: 16.sp,
                        color: isSelected
                            ? AppColors.secondary
                            : AppColors.primary,
                      ),
                    ),
                    AppSpaces.hSpace8,
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.text12.copyWith(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w600,
                          color: isSelected
                              ? AppColors.white
                              : AppColors.textColor,
                        ),
                      ),
                    ),
                    if (isSelected && controller.approvalsList.isNotEmpty) ...[
                      AppSpaces.hSpace4,
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          '${controller.approvalsList.length}',
                          style: AppTextStyles.text10.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
