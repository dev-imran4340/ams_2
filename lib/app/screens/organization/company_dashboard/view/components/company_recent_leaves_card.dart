import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_spaces.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../controller/company_dashboard_controller.dart';
import '../../model/company_dashboard_model.dart';

class CompanyRecentLeavesCard extends GetView<CompanyDashboardController> {
  const CompanyRecentLeavesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.borderColor.withValues(alpha: 0.8),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 20.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Header Row
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 10.h),
            child: Row(
              children: [
                Container(
                  width: 36.r,
                  height: 36.r,
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.event_busy_rounded,
                      color: AppColors.warning,
                      size: 20.sp,
                    ),
                  ),
                ),
                AppSpaces.hSpace10,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Leaves',
                      style: AppTextStyles.text14.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                    AppSpaces.vSpace2,
                    Text(
                      'Scheduled leave approvals • Tap row to expand',
                      style: AppTextStyles.text10.copyWith(
                        color: AppColors.subTextColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          AppSpaces.vSpace4,

          // 2. Table Column Headers (Expanded flex - Fits Phone & Tablet, No Horizontal Scroll)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            color: AppColors.warning.withValues(alpha: 0.06),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    'STAFF MEMBER',
                    style: AppTextStyles.text10.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'LEAVE DATES',
                    style: AppTextStyles.text10.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'STATUS',
                    style: AppTextStyles.text10.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                SizedBox(width: 24.w), // Space for expand chevron
              ],
            ),
          ),

          // 3. Responsive & Expandable Rows (Zero Horizontal Scroll!)
          Obx(() {
            final leaves = controller.dashboard.value?.recentLeaves ?? [];

            if (leaves.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_available_rounded,
                        size: 32.sp,
                        color: AppColors.subTextColor.withValues(alpha: 0.5),
                      ),
                      AppSpaces.vSpace8,
                      Text(
                        'No active leave requests recorded for today.',
                        style: AppTextStyles.text12.copyWith(color: AppColors.subTextColor),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: leaves.length,
              separatorBuilder: (context, index) => Divider(
                color: AppColors.borderColor.withValues(alpha: 0.6),
                height: 1.h,
              ),
              itemBuilder: (context, index) {
                final leave = leaves[index];
                final isExpanded = controller.expandedLeaveIndex.value == index;

                return _buildExpandableLeaveRow(leave, index, isExpanded);
              },
            );
          }),

          AppSpaces.vSpace6,
        ],
      ),
    );
  }

  Widget _buildExpandableLeaveRow(
    CompanyRecentLeaveModel leave,
    int index,
    bool isExpanded,
  ) {
    final isApproved = leave.status.toLowerCase().contains('approved');
    final badgeColor = isApproved ? AppColors.success : AppColors.warning;

    return InkWell(
      onTap: () => controller.toggleLeaveExpanded(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        color: isExpanded
            ? AppColors.warning.withValues(alpha: 0.03)
            : Colors.transparent,
        child: Column(
          children: [
            // Main Responsive Row
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  // 1. Employee Avatar & Name
                  Expanded(
                    flex: 4,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14.r,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                          child: Text(
                            leave.name.isNotEmpty ? leave.name[0] : 'L',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        AppSpaces.hSpace8,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                leave.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.text12.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textColor,
                                ),
                              ),
                              AppSpaces.vSpace2,
                              Text(
                                leave.reason,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.text10.copyWith(
                                  color: AppColors.subTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 2. Dates
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          leave.leaveFrom,
                          style: AppTextStyles.text12.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                        AppSpaces.vSpace2,
                        Text(
                          'to ${leave.leaveTo}',
                          style: AppTextStyles.text10.copyWith(
                            color: AppColors.subTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 3. Status Badge
                  Expanded(
                    flex: 3,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isApproved
                                  ? Icons.check_circle_outline_rounded
                                  : Icons.hourglass_top_rounded,
                              size: 11.sp,
                              color: badgeColor,
                            ),
                            AppSpaces.hSpace4,
                            Text(
                              leave.status,
                              style: AppTextStyles.text10.copyWith(
                                fontWeight: FontWeight.bold,
                                color: badgeColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 4. Expand Chevron
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20.sp,
                      color: AppColors.subTextColor,
                    ),
                  ),
                ],
              ),
            ),

            // Expandable Detail Drawer ("expand wala functionality")
            if (isExpanded)
              Container(
                margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: AppColors.borderColor.withValues(alpha: 0.8),
                    width: 1.w,
                  ),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      icon: Icons.notes_rounded,
                      label: 'Leave Reason',
                      value: leave.reason,
                      valueColor: AppColors.textColor,
                    ),
                    Divider(height: 12.h, color: AppColors.borderColor.withValues(alpha: 0.5)),
                    _buildDetailRow(
                      icon: Icons.date_range_rounded,
                      label: 'Complete Span',
                      value: '${leave.leaveFrom} → ${leave.leaveTo}',
                      valueColor: AppColors.textColor,
                    ),
                    Divider(height: 12.h, color: AppColors.borderColor.withValues(alpha: 0.5)),
                    _buildDetailRow(
                      icon: Icons.verified_user_outlined,
                      label: 'HR Approval',
                      value: isApproved ? 'Approved by Admin' : 'Pending Verification',
                      valueColor: badgeColor,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14.sp, color: AppColors.subTextColor),
        AppSpaces.hSpace8,
        Text(
          label,
          style: AppTextStyles.text10.copyWith(
            color: AppColors.subTextColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        AppSpaces.hSpace12,
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: AppTextStyles.text10.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }
}
