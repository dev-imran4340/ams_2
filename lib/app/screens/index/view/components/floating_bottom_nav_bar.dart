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
        final tabs = controller.navTabs;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(tabs.length, (index) {
            final tab = tabs[index];
            final bool hasBadge = tab.hasBadge?.call() ?? false;

            return NavItemCapsule(
              icon: tab.icon,
              label: tab.label,
              isSelected: current == index,
              hasBadge: hasBadge,
              onTap: () => controller.changeTab(index),
            );
          }),
        );
      }),
    );
  }
}
