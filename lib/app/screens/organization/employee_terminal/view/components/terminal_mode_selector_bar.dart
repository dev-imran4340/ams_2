import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_spaces.dart';
import '../../../../../core/utils/app_text_styles.dart';

class TerminalModeSelectorBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const TerminalModeSelectorBar({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
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
          // Mode 0: AI Face Biometric
          Expanded(
            child: _buildSegmentItem(
              index: 0,
              icon: Icons.face_retouching_natural_rounded,
              title: 'AI Face Biometric',
            ),
          ),
          AppSpaces.hSpace6,
          // Mode 1: Card QR Scanner
          Expanded(
            child: _buildSegmentItem(
              index: 1,
              icon: Icons.qr_code_scanner_rounded,
              title: 'Card QR Scanner',
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
            ],
          ),
        ),
      ),
    );
  }
}
