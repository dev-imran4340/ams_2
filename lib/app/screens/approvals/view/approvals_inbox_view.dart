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
import '../controller/approval_controller.dart';
import 'components/approval_request_tile.dart';

/// Screen: Universal Requests & Approvals Inbox (GET /api/v1/approvals)
/// Central decision and task management hub for all company requests:
/// Details change, attendance corrections, leaves, overtime, and loans.
class ApprovalsInboxView extends GetView<ApprovalController> {
  const ApprovalsInboxView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkBoundaryWrapper(
      onRetry: () => controller.fetchApprovals(),
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
                  // Top Bar: Screen Title & Subtitle
                  Padding(
                    padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 0),
                    child: const CustomScreenHeader(
                      title: 'Requests & Approvals',
                      subtitle: 'Universal decisions & task inbox',
                    ),
                  ),

                  AppSpaces.vSpace12,

                  // Approvals 4 Boxes Filter Tabs (waiting, mine, pending, decided)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: _buildBoxFilterStrip(),
                  ),

                  AppSpaces.vSpace14,

                  // Requests List or Empty State
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
                          onRefresh: controller.fetchApprovals,
                          color: AppColors.primary,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            child: Container(
                              height: 0.55.sh,
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: CustomStateView.empty(
                                title: 'No Requests Found',
                                message:
                                    'No requests or tasks found in the "${controller.selectedBox.value}" box.',
                                buttonText: 'Refresh Inbox',
                                onAction: controller.fetchApprovals,
                              ),
                            ),
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: controller.fetchApprovals,
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

  /// 4 Standard Approvals Boxes in a prominent 2x2 executive card grid
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
          child: Padding(
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
                    color: isSelected ? AppColors.secondary : AppColors.primary,
                  ),
                ),
                AppSpaces.hSpace8,
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.text12.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? AppColors.white : AppColors.textColor,
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
        ),
      ),
    );
  }
}
