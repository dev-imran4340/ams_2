import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../controller/index_controller.dart';
import 'nav_item_capsule.dart';

class FloatingBottomNavBar extends GetView<IndexController> {
  const FloatingBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 12.w, right: 12.w, bottom: 5.h, top: 5.h),
      height: 60.h,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(
          color: AppColors.borderColor,
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 24.r,
            offset: Offset(0, 8.h),
          ),
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.05),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),

      child: Obx(() {
        final current = controller.currentIndex.value;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // 0: Dashboard Tab
            NavItemCapsule(
              icon: Icons.space_dashboard_rounded,
              label: 'Home',
              isSelected: current == 0,
              onTap: () => controller.changeTab(0),
            ),

            // 1: Attendance Logs Tab
            NavItemCapsule(
              icon: Icons.calendar_month_rounded,
              label: 'Logs',
              isSelected: current == 1,
              hasBadge: controller.hasUnreadLogs.value,
              onTap: () => controller.changeTab(1),
            ),

            // 2: Leaves & Requests Tab
            NavItemCapsule(
              icon: Icons.beach_access_rounded,
              label: 'Leaves',
              isSelected: current == 2,
              hasBadge: controller.hasPendingLeaves.value,
              onTap: () => controller.changeTab(2),
            ),

            // 3: Profile & Settings Tab
            NavItemCapsule(
              icon: Icons.person_rounded,
              label: 'Profile',
              isSelected: current == 3,
              onTap: () => controller.changeTab(3),
            ),
          ],
        );
      }),
    );
  }
}
