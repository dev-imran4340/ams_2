import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_state_view.dart';
import '../../../leaves/model/leave_model.dart';
import '../../controller/department_employees_controller.dart';
import '../../model/department_employee_model.dart';

/// Modal bottom sheet for Manager / HR to audit subordinate employee leave balances and requests (GET /employees/{id}/leave)
class EmployeeLeaveAuditSheet extends StatelessWidget {
  final DepartmentEmployeesController controller;
  final DepartmentEmployeeModel employee;

  const EmployeeLeaveAuditSheet({
    super.key,
    required this.controller,
    required this.employee,
  });

  static void show(
    BuildContext context,
    DepartmentEmployeesController controller,
    DepartmentEmployeeModel employee,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EmployeeLeaveAuditSheet(
        controller: controller,
        employee: employee,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: 0.88.sh,
      ),
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 20.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        border: Border.all(color: AppColors.borderColor, width: 1.w),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Grabber handle
            Center(
              child: Container(
                width: 44.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.borderColor,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),

            // Header Row: Avatar, Title & Close Button
            Row(
              children: [
                Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.secondary,
                      width: 1.5.w,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      employee.name.isNotEmpty
                          ? employee.name[0].toUpperCase()
                          : 'E',
                      style: AppTextStyles.text18.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                AppSpaces.hSpace12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              employee.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.text16.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                            ),
                          ),
                          AppSpaces.hSpace8,
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              'AUDIT',
                              style: AppTextStyles.text10.copyWith(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      AppSpaces.vSpace2,
                      Text(
                        'Leave Balances & Absence Requests',
                        style: AppTextStyles.text12.copyWith(
                          color: AppColors.subTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    size: 20.sp,
                    color: AppColors.subTextColor,
                  ),
                  onPressed: () => Get.back(),
                ),
              ],
            ),

            AppSpaces.vSpace12,
            Divider(color: AppColors.borderColor, height: 1.h),
            AppSpaces.vSpace12,

            // Reactive Audit Content
            Expanded(
              child: Obx(() {
                if (controller.isLoadingLeaveAudit.value) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: AppColors.secondary,
                          strokeWidth: 2.5.w,
                        ),
                        AppSpaces.vSpace12,
                        Text(
                          'Loading leave records...',
                          style: AppTextStyles.text12.copyWith(
                            color: AppColors.subTextColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (controller.leaveAuditError.value.isNotEmpty) {
                  return Center(
                    child: CustomStateView.error(
                      title: 'Failed to Load Records',
                      message: controller.leaveAuditError.value,
                    ),
                  );
                }

                final audit = controller.leaveAuditData.value;
                if (audit == null ||
                    (audit.balances.isEmpty && audit.requests.isEmpty)) {
                  return Center(
                    child: CustomStateView.empty(
                      title: 'No Leave Data',
                      message:
                          'No leave entitlements or applications recorded for this employee.',
                    ),
                  );
                }

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section 1: Quota Entitlement & Balances
                      if (audit.balances.isNotEmpty) ...[
                        Text(
                          'QUOTA ENTITLEMENTS',
                          style: AppTextStyles.text12.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.subTextColor,
                            letterSpacing: 0.8,
                          ),
                        ),
                        AppSpaces.vSpace10,
                        ...audit.balances.map((b) => _buildBalanceCard(b)),
                        AppSpaces.vSpace16,
                      ],

                      // Section 2: Submitted Leave Requests
                      Text(
                        'LEAVE APPLICATIONS & HISTORY',
                        style: AppTextStyles.text12.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.subTextColor,
                          letterSpacing: 0.8,
                        ),
                      ),
                      AppSpaces.vSpace10,
                      if (audit.requests.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 24.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(15.r),
                            border: Border.all(color: AppColors.borderColor),
                          ),
                          child: Center(
                            child: Text(
                              'No leave requests found for this employee.',
                              style: AppTextStyles.text12.copyWith(
                                color: AppColors.subTextColor,
                              ),
                            ),
                          ),
                        )
                      else
                        ...audit.requests.map((r) => _buildRequestCard(r)),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  /// Balance card with signature 12.w padding, 15.r radius, and 3.w accent border
  Widget _buildBalanceCard(LeaveBalanceModel balance) {
    final double remaining = balance.remaining;
    final double total = balance.entitlement;
    final double taken = balance.taken;
    final double progress = total > 0 ? (remaining / total).clamp(0.0, 1.0) : 0.0;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: AppColors.borderColor, width: 1.w),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.03),
            blurRadius: 8.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                balance.categoryName,
                style: AppTextStyles.text14.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 3.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '${remaining.toStringAsFixed(1)} Days Left',
                  style: AppTextStyles.text10.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
          AppSpaces.vSpace8,
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.borderColor,
              valueColor: AlwaysStoppedAnimation<Color>(
                remaining > 2 ? AppColors.secondary : AppColors.warning,
              ),
              minHeight: 6.h,
            ),
          ),
          AppSpaces.vSpace8,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Entitlement: ${total.toStringAsFixed(1)}d',
                style: AppTextStyles.text10.copyWith(
                  color: AppColors.subTextColor,
                ),
              ),
              Text(
                'Taken: ${taken.toStringAsFixed(1)}d',
                style: AppTextStyles.text10.copyWith(
                  color: AppColors.subTextColor,
                ),
              ),
              if (balance.pending > 0)
                Text(
                  'Pending: ${balance.pending.toStringAsFixed(1)}d',
                  style: AppTextStyles.text10.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Request card with signature accent border and status pill
  Widget _buildRequestCard(LeaveRequestItemModel request) {
    final statusColor = _resolveStatusColor(request.status);

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: AppColors.borderColor, width: 1.w),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 8.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  request.leaveType,
                  style: AppTextStyles.text14.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 3.h,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.3),
                      width: 0.8.w,
                    ),
                  ),
                  child: Text(
                    request.status.toUpperCase(),
                    style: AppTextStyles.text10.copyWith(
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            AppSpaces.vSpace6,
            Row(
              children: [
                Icon(
                  Icons.date_range_rounded,
                  size: 13.sp,
                  color: AppColors.subTextColor,
                ),
                AppSpaces.hSpace4,
                Text(
                  '${request.startsOn} → ${request.endsOn}',
                  style: AppTextStyles.text12.copyWith(
                    color: AppColors.subTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                AppSpaces.hSpace8,
                Text(
                  '(${request.amountText})',
                  style: AppTextStyles.text12.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            if (request.reason.isNotEmpty) ...[
              AppSpaces.vSpace6,
              Text(
                request.reason,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.text12.copyWith(
                  color: AppColors.textColor.withValues(alpha: 0.8),
                ),
              ),
            ],
          ],
        ),
      ),
      Container(height: 3.h, color: statusColor), // Signature bottom accent
    ],
  ),
),
);
}

  Color _resolveStatusColor(String status) {
    switch (status.toLowerCase().trim()) {
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      case 'pending':
      case 'waiting':
        return AppColors.warning;
      default:
        return AppColors.subTextColor;
    }
  }
}
