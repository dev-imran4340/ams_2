import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_spaces.dart';
import '../../../../../core/utils/app_text_styles.dart';

class VisitorModeSegmentedBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final int activeCount;

  const VisitorModeSegmentedBar({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
    required this.activeCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.22),
          width: 1.w,
        ),
      ),
      child: Row(
        children: [
          // Segment 1: Visitor Entry
          Expanded(
            child: _buildSegmentItem(
              index: 0,
              icon: Icons.person_add_alt_1_rounded,
              title: 'Visitor Entry',
              badgeText: null,
            ),
          ),
          AppSpaces.hSpace6,
          // Segment 2: Visitor Exit
          Expanded(
            child: _buildSegmentItem(
              index: 1,
              icon: Icons.exit_to_app_rounded,
              title: 'Visitor Exit',
              badgeText: '$activeCount on-site',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentItem({
    required int index,
    required IconData icon,
    required String title,
    String? badgeText,
  }) {
    final bool isSelected = selectedIndex == index;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(index),
        borderRadius: BorderRadius.circular(10.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 8.r,
                      offset: Offset(0, 2.h),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16.sp,
                color: isSelected ? AppColors.primary : AppColors.white,
              ),
              AppSpaces.hSpace6,
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.text12.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? AppColors.primary : AppColors.white,
                  ),
                ),
              ),
              if (badgeText != null) ...[
                AppSpaces.hSpace6,
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.secondary
                        : AppColors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    badgeText,
                    style: AppTextStyles.text10.copyWith(
                      fontSize: 9.sp,
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
    );
  }
}
