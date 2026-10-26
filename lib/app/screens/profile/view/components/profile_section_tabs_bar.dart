import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../controller/profile_controller.dart';
import '../../model/profile_model.dart';

/// Dynamic Horizontal Section Tabs Bar (MVVM GetView)
/// Uses controller.tabsScrollController for smooth, automated centering
/// of the active tab. Conforms strictly with architecture_guidelines_ams2.md.
class ProfileSectionTabsBar extends GetView<ProfileController> {
  const ProfileSectionTabsBar({super.key});

  IconData _getIconForSection(String key) {
    switch (key.toLowerCase()) {
      case 'overview':
        return Icons.space_dashboard_outlined;
      case 'personal':
        return Icons.person_outline_rounded;
      case 'job':
        return Icons.work_outline_rounded;
      case 'attendance':
        return Icons.access_time_rounded;
      case 'documents':
        return Icons.description_outlined;
      case 'bank':
        return Icons.account_balance_outlined;
      case 'account':
        return Icons.badge_outlined;
      case 'history':
        return Icons.history_rounded;
      default:
        return Icons.tune_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final sections = controller.activeSections;
      final currentKey = controller.selectedSectionKey.value;

      return SizedBox(
        height: 42.h,
        child: SingleChildScrollView(
          controller: controller.tabsScrollController,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          child: Row(
            children: [
              for (int index = 0; index < sections.length; index++) ...[
                if (index > 0) AppSpaces.hSpace8,
                _buildTabItem(sections[index], currentKey),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTabItem(ProfileSectionModel section, String currentKey) {
    final bool isSelected = section.key == currentKey;
    final icon = _getIconForSection(section.key);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => controller.selectSection(section.key),
        borderRadius: BorderRadius.circular(22.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: 14.w,
            vertical: 8.h,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.cardBackground,
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(
              color: isSelected ? AppColors.secondary : AppColors.borderColor,
              width: isSelected ? 1.5.w : 1.w,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 8.r,
                      offset: Offset(0, 3.h),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15.sp,
                color:
                    isSelected ? AppColors.secondary : AppColors.subTextColor,
              ),
              AppSpaces.hSpace6,
              Text(
                section.label,
                style: AppTextStyles.text12.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppColors.white : AppColors.textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
