import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../controller/task_controller.dart';

class TaskFilterTabs extends GetView<TaskController> {
  const TaskFilterTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Primary Scope Capsule Switcher (My Tasks, Assigned by Me, Team)
        _buildScopeSwitcher(),

        AppSpaces.vSpace10,

        // 2. Status & Due Filter Horizontal Pills
        _buildStatusDueFilters(),
      ],
    );
  }

  /// 3-Way Scope Switcher: mine, given, team
  Widget _buildScopeSwitcher() {
    final scopes = [
      {'key': 'mine', 'label': 'My Tasks'},
      {'key': 'given', 'label': 'Assigned by Me'},
      {'key': 'team', 'label': 'Team Tasks'},
    ];

    return Container(
      width: double.infinity,
      height: 44.h,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: AppColors.borderColor,
          width: 0.8.w,
        ),
      ),
      child: Row(
        children: scopes.map((item) {
          final key = item['key']!;
          final label = item['label']!;

          return Expanded(
            child: Obx(() {
              final isSelected = controller.selectedScope.value == key;

              return InkWell(
                onTap: () => controller.setScope(key),
                borderRadius: BorderRadius.circular(18.r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(18.r),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              blurRadius: 8.r,
                              offset: Offset(0, 2.h),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: AppTextStyles.text10.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected
                            ? AppColors.white
                            : AppColors.subTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              );
            }),
          );
        }).toList(),
      ),
    );
  }

  /// Horizontal scrolling pills for status & due date filters
  Widget _buildStatusDueFilters() {
    return SizedBox(
      height: 36.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: controller.filterTabs.length,
        separatorBuilder: (_, _) => AppSpaces.hSpace8,
        itemBuilder: (context, index) {
          final tab = controller.filterTabs[index];

          return Obx(() {
            final isSelected = controller.selectedFilter.value == tab;

            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => controller.setFilter(tab),
                borderRadius: BorderRadius.circular(18.r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.secondary
                        : AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.secondary
                          : AppColors.borderColor,
                      width: 1.w,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.secondary.withValues(alpha: 0.25),
                              blurRadius: 8.r,
                              offset: Offset(0, 2.h),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) ...[
                        Container(
                          width: 5.r,
                          height: 5.r,
                          decoration: const BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        AppSpaces.hSpace6,
                      ],
                      Text(
                        tab,
                        style: AppTextStyles.text10.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected
                              ? AppColors.white
                              : AppColors.subTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }
}
