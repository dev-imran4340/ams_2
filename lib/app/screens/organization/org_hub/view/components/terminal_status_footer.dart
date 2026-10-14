import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_spaces.dart';
import '../../../../../core/utils/app_text_styles.dart';

class TerminalStatusFooter extends StatelessWidget {
  const TerminalStatusFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 6.r,
                height: 6.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.success,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withValues(alpha: 0.5),
                      blurRadius: 4.r,
                      spreadRadius: 1.r,
                    ),
                  ],
                ),
              ),
              AppSpaces.hSpace8,
              Text(
                'Terminal Node: ISB-HQ-01 • AMS v2.0 Enterprise Secured',
                style: AppTextStyles.text10.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                  color: AppColors.subTextColor,
                ),
              ),
            ],
          ),
          AppSpaces.vSpace4,
          Text(
            'Encrypted Gateway Connection • SoftGenie Business Systems',
            style: AppTextStyles.text10.copyWith(
              fontSize: 9.sp,
              color: AppColors.subTextColor.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
