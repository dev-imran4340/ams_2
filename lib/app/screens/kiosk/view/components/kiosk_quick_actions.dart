import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:ams_2/app/core/utils/app_colors.dart';
import 'package:ams_2/app/core/utils/app_spaces.dart';
import 'package:ams_2/app/core/utils/app_text_styles.dart';
import 'package:ams_2/app/core/widgets/custom_card.dart';
import 'package:ams_2/app/routes/app_routes.dart';
import '../../controller/kiosk_controller.dart';

class _KioskQuickActionItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;

  const _KioskQuickActionItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
  });
}

/// Quick Self-Service Actions card shown after an employee identifies via QR badge.
class KioskQuickActions extends StatelessWidget {
  final KioskController controller;

  const KioskQuickActions({super.key, required this.controller});

  static const List<_KioskQuickActionItem> _items = [
    _KioskQuickActionItem(
      title: 'My Requests',
      subtitle: 'Track approvals',
      icon: Icons.inbox_rounded,
      color: AppColors.primary,
      route: Routes.APPROVALS,
    ),
    _KioskQuickActionItem(
      title: 'Leave Request',
      subtitle: 'Apply for leave',
      icon: Icons.beach_access_rounded,
      color: AppColors.secondary,
      route: Routes.LEAVE,
    ),
    _KioskQuickActionItem(
      title: 'Money Request',
      subtitle: 'Loan & expense',
      icon: Icons.account_balance_wallet_rounded,
      color: AppColors.warning,
      route: Routes.LOANS,
    ),
    _KioskQuickActionItem(
      title: 'Create Ticket',
      subtitle: 'HR helpdesk',
      icon: Icons.support_agent_rounded,
      color: AppColors.info,
      route: Routes.HELPDESK,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      borderRadius: 15.r,
      accentColor: AppColors.secondary,
      accentWidth: 3.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quick Actions',
                style: AppTextStyles.text16.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
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

          Obx(() {
            final isBusy = controller.isSubmitting.value;
            return Column(
              children: [
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: _buildTile(_items[0], isBusy)),
                      AppSpaces.hSpace10,
                      Expanded(child: _buildTile(_items[1], isBusy)),
                    ],
                  ),
                ),
                AppSpaces.vSpace10,
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: _buildTile(_items[2], isBusy)),
                      AppSpaces.hSpace10,
                      Expanded(child: _buildTile(_items[3], isBusy)),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTile(_KioskQuickActionItem item, bool isBusy) {
    return Opacity(
      opacity: isBusy ? 0.55 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.cardBackground,
              item.color.withValues(alpha: 0.06),
            ],
          ),
          borderRadius: BorderRadius.circular(13.r),
          border: Border.all(
            color: AppColors.borderColor,
            width: 1.w,
          ),
        ),
        child: Material(
          color: AppColors.transparent,
          borderRadius: BorderRadius.circular(13.r),
          child: InkWell(
            onTap: isBusy
                ? null
                : () {
                    HapticFeedback.lightImpact();
                    controller.onQuickActionTap(
                      route: item.route,
                      title: item.title,
                    );
                  },
            borderRadius: BorderRadius.circular(13.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 36.r,
                    height: 36.r,
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.11),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      item.icon,
                      size: 19.sp,
                      color: item.color,
                    ),
                  ),
                  AppSpaces.vSpace10,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: AppTextStyles.text14.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor,
                          height: 1.2,
                        ),
                      ),
                      AppSpaces.vSpace2,
                      Text(
                        item.subtitle,
                        style: AppTextStyles.text10.copyWith(
                          color: AppColors.subTextColor,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
