import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../api/app_preferences.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../routes/app_routes.dart';
import '../../../main_shell/controller/session_me_controller.dart';

class _QuickActionItem {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });
}

class DashboardQuickActions extends StatelessWidget {
  const DashboardQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Get.isRegistered<SessionMeController>()
        ? Get.find<SessionMeController>()
        : null;

    final bool hasAttendance = (session?.hasModule('attendance') ??
            AppPreferences.hasModule('attendance')) &&
        (session?.hasPermission('attendance.view') ??
            AppPreferences.hasPermission('attendance.view'));

    final bool hasLeave =
        session?.hasModule('leave') ?? AppPreferences.hasModule('leave');

    final bool hasPayroll = (session?.hasModule('payroll') ??
            AppPreferences.hasModule('payroll')) &&
        (session?.hasPermission('pay.view') ??
            AppPreferences.hasPermission('pay.view'));

    final bool hasLoans = (session?.hasModule('loans_expenses') ??
            AppPreferences.hasModule('loans_expenses')) &&
        (session?.hasPermission('money.view') ??
            AppPreferences.hasPermission('money.view'));

    final bool hasSupport = session?.hasPermission('support.view') ??
        AppPreferences.hasPermission('support.view');

    // Dynamically build action tiles strictly adhering to Permission-Driven Access Invariant
    final actions = <_QuickActionItem>[];

    if (hasAttendance) {
      actions.add(_QuickActionItem(
        icon: Icons.insights_rounded,
        title: 'Attendance\nSummary',
        color: AppColors.secondary,
        onTap: () {
          HapticFeedback.lightImpact();
          Get.toNamed(Routes.ATTENDANCE_SUMMARY);
        },
      ));
      actions.add(_QuickActionItem(
        icon: Icons.view_timeline_rounded,
        title: 'Attendance\nHistory',
        color: AppColors.primary,
        onTap: () {
          HapticFeedback.lightImpact();
          Get.toNamed(Routes.ATTENDANCE_HISTORY);
        },
      ));
      actions.add(_QuickActionItem(
        icon: Icons.edit_calendar_rounded,
        title: 'Attendance\nCorrection',
        color: AppColors.warning,
        onTap: () {
          HapticFeedback.lightImpact();
          Get.toNamed(Routes.CORRECTION);
        },
      ));
    }

    if (hasLeave) {
      actions.add(_QuickActionItem(
        icon: Icons.beach_access_rounded,
        title: 'Leave\nRequests',
        color: AppColors.secondary,
        onTap: () {
          HapticFeedback.lightImpact();
          Get.toNamed(Routes.LEAVE);
        },
      ));
    }

    if (hasPayroll) {
      actions.add(_QuickActionItem(
        icon: Icons.receipt_long_rounded,
        title: 'Payslips &\nSalary',
        color: AppColors.secondary,
        onTap: () {
          HapticFeedback.lightImpact();
          Get.toNamed(Routes.PAYROLL);
        },
      ));
    }

    if (hasLoans) {
      actions.add(_QuickActionItem(
        icon: Icons.account_balance_wallet_rounded,
        title: 'Loans &\nAdvances',
        color: AppColors.warning,
        onTap: () {
          HapticFeedback.lightImpact();
          Get.toNamed(Routes.LOANS);
        },
      ));
    }

    if (hasSupport) {
      actions.add(_QuickActionItem(
        icon: Icons.support_agent_rounded,
        title: 'Helpdesk &\nSupport',
        color: AppColors.primary,
        onTap: () {
          HapticFeedback.lightImpact();
          Get.toNamed(Routes.SUPPORT_TICKETS);
        },
      ));
    }

    // Core employee smart identity badge - always accessible
    actions.add(_QuickActionItem(
      icon: Icons.badge_outlined,
      title: 'Digital\nID Card',
      color: AppColors.primary,
      onTap: () {
        HapticFeedback.lightImpact();
        Get.toNamed(Routes.EMPLOYEE_CARD);
      },
    ));

    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    Widget content;
    if (actions.length <= 4) {
      content = Row(
        children: actions.asMap().entries.map((entry) {
          final idx = entry.key;
          final item = entry.value;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: idx < actions.length - 1 ? 10.w : 0,
              ),
              child: _buildActionTile(item),
            ),
          );
        }).toList(),
      );
    } else {
      content = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: actions.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            return Padding(
              padding: EdgeInsets.only(
                right: idx < actions.length - 1 ? 10.w : 0,
              ),
              child: SizedBox(
                width: 82.w,
                child: _buildActionTile(item),
              ),
            );
          }).toList(),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
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
                  Expanded(
                    child: Text(
                      'Quick Services',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.text16.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AppSpaces.hSpace8,
            Text(
              'Self Service',
              style: AppTextStyles.text10.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.subTextColor,
              ),
            ),
          ],
        ),

        AppSpaces.vSpace12,

        content,
      ],
    );
  }

  Widget _buildActionTile(_QuickActionItem item) {
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
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(14.r),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 6.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 38.r,
                  height: 38.r,
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.icon, size: 18.sp, color: item.color),
                ),
                AppSpaces.vSpace8,
                Text(
                  item.title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.text10.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                    height: 1.2,
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
