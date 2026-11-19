import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/app_colors.dart';
import '../utils/app_spaces.dart';
import '../utils/app_text_styles.dart';

/// Model representing a single metric tile within the telemetry strip
class CustomTelemetryItem {
  final String id;
  final String label;
  final int count;
  final IconData icon;
  final Color accentColor;

  const CustomTelemetryItem({
    required this.id,
    required this.label,
    required this.count,
    required this.icon,
    required this.accentColor,
  });
}

/// Centralized, dynamic telemetry metrics bar adhering strictly to AMS 2.0 design rules.
/// Used universally across screens (Training, Assets, etc.) with strict single-selection state isolation.
class CustomTelemetryStrip extends StatelessWidget {
  final List<CustomTelemetryItem> items;
  final String selectedId;
  final ValueChanged<String> onSelect;
  final EdgeInsetsGeometry? padding;

  const CustomTelemetryStrip({
    super.key,
    required this.items,
    required this.selectedId,
    required this.onSelect,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderColor, width: 1.w),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 16.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            Expanded(
              child: _buildTile(items[i]),
            ),
            if (i < items.length - 1) _buildDivider(),
          ],
        ],
      ),
    );
  }

  Widget _buildTile(CustomTelemetryItem item) {
    final bool isSelected = selectedId.toLowerCase() == item.id.toLowerCase();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onSelect(item.id),
        borderRadius: BorderRadius.circular(12.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 2.w),
          decoration: BoxDecoration(
            color: isSelected
                ? item.accentColor.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected
                  ? item.accentColor.withValues(alpha: 0.4)
                  : Colors.transparent,
              width: 1.w,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                item.icon,
                size: 16.sp,
                color: isSelected ? item.accentColor : AppColors.subTextColor,
              ),
              AppSpaces.vSpace4,
              Text(
                item.count.toString(),
                style: AppTextStyles.text16.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? item.accentColor : AppColors.textColor,
                  height: 1.1,
                ),
              ),
              AppSpaces.vSpace2,
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyles.text10.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? item.accentColor
                      : AppColors.subTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1.w,
      height: 28.h,
      color: AppColors.borderColor,
      margin: EdgeInsets.symmetric(horizontal: 2.w),
    );
  }
}
