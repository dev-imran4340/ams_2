import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../controller/attendance_actions_controller.dart';
import 'money_request_sheet.dart';
import 'money_requests_history_sheet.dart';

class AttendanceMoreServicesSection
    extends GetView<AttendanceActionsController> {
  const AttendanceMoreServicesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 4.w,
                  height: 16.h,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                AppSpaces.hSpace8,
                Text(
                  'More Self Services',
                  style: AppTextStyles.text16.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
            Text(
              'HR & Financial Hub',
              style: AppTextStyles.text10.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.subTextColor,
              ),
            ),
          ],
        ),

        AppSpaces.vSpace12,

        // 3 Rows x 2 Columns Grid
        Row(
          children: [
            // 1. Performance Evaluations
            Expanded(
              child: _buildServiceCard(
                icon: Icons.assessment_rounded,
                title: 'Performance',
                subtitle: 'Quarterly Scores',
                color: AppColors.secondary,
                onTap: controller.navigateToEvaluation,
              ),
            ),

            AppSpaces.hSpace12,

            // 2. Leave Request
            Expanded(
              child: _buildServiceCard(
                icon: Icons.beach_access_rounded,
                title: 'Leave Request',
                subtitle: 'Apply for Leaves',
                color: const Color(0xFF0284C7),
                onTap: controller.navigateToLeaveRequests,
              ),
            ),
          ],
        ),

        AppSpaces.vSpace12,

        Row(
          children: [
            // 3. Money Request (Loan / Advance)
            Expanded(
              child: _buildServiceCard(
                icon: Icons.account_balance_wallet_rounded,
                title: 'Money Request',
                subtitle: 'Loan & Advance',
                color: const Color(0xFFD97706),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const MoneyRequestSheet(),
                  );
                },
              ),
            ),

            AppSpaces.hSpace12,

            // 4. Request History & Status
            Expanded(
              child: _buildServiceCard(
                icon: Icons.receipt_long_rounded,
                title: 'View Requests',
                subtitle: 'Track Financial Log',
                color: AppColors.onTimeColor,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const MoneyRequestsHistorySheet(),
                  );
                },
              ),
            ),
          ],
        ),

        AppSpaces.vSpace12,

        Row(
          children: [
            // 5. Daily Tasks
            Expanded(
              child: _buildServiceCard(
                icon: Icons.checklist_rounded,
                title: 'Daily Tasks',
                subtitle: 'Projects & Assignees',
                color: const Color(0xFF6366F1),
                onTap: controller.navigateToTasks,
              ),
            ),

            AppSpaces.hSpace12,

            // 6. Smart Employee Card
            Expanded(
              child: _buildServiceCard(
                icon: Icons.badge_rounded,
                title: 'Employee ID',
                subtitle: 'Digital Smart Card',
                color: AppColors.primary,
                onTap: controller.navigateToEmployeeCard,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServiceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.borderColor, width: 1.w),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            child: Row(
              children: [
                Container(
                  width: 38.r,
                  height: 38.r,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    icon,
                    size: 20.sp,
                    color: color,
                  ),
                ),
                AppSpaces.hSpace10,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.text12.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                      AppSpaces.vSpace2,
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.text10.copyWith(
                          color: AppColors.subTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
