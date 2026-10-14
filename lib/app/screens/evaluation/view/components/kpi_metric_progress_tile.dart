import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../model/evaluation_model.dart';

class KpiMetricProgressTile extends StatelessWidget {
  final KpiMetricItem kpi;

  const KpiMetricProgressTile({
    super.key,
    required this.kpi,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = kpi.progressRatio;
    final accentColor = _getGradeColor(kpi.grade);
    final categoryIcon = _getCategoryIcon(kpi.name);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.borderColor,
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 14.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Header: Icon, Metric Name, Weightage & Grade Badge
          Row(
            children: [
              Container(
                width: 34.r,
                height: 34.r,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Center(
                  child: Icon(
                    categoryIcon,
                    size: 18.sp,
                    color: accentColor,
                  ),
                ),
              ),
              AppSpaces.hSpace10,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kpi.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.text12.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                    AppSpaces.vSpace2,
                    Text(
                      kpi.weightage,
                      style: AppTextStyles.text10.copyWith(
                        color: AppColors.subTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              AppSpaces.hSpace8,

              // Grade Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.35),
                    width: 1.w,
                  ),
                ),
                child: Text(
                  kpi.grade,
                  style: AppTextStyles.text12.copyWith(
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),

          AppSpaces.vSpace12,

          // 2. Animated Progress Bar
          Stack(
            children: [
              // Track
              Container(
                height: 7.h,
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              // Indicator
              FractionallySizedBox(
                widthFactor: ratio,
                child: Container(
                  height: 7.h,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(4.r),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.3),
                        blurRadius: 4.r,
                        offset: Offset(0, 1.h),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          AppSpaces.vSpace10,

          // 3. Footer: Numeric Score & Performance Tag
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Score: ${kpi.score.toStringAsFixed(1)} / ${kpi.target.toStringAsFixed(0)}',
                style: AppTextStyles.text10.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.trending_up_rounded,
                    size: 13.sp,
                    color: accentColor,
                  ),
                  AppSpaces.hSpace4,
                  Text(
                    ratio >= 0.95 ? 'Target Exceeded' : (ratio >= 0.85 ? 'On Target' : 'Under Review'),
                    style: AppTextStyles.text10.copyWith(
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getGradeColor(String grade) {
    switch (grade.toUpperCase()) {
      case 'A+':
        return AppColors.success;
      case 'A':
        return AppColors.secondary;
      case 'B+':
      case 'B':
        return AppColors.info;
      case 'C':
        return AppColors.warning;
      default:
        return AppColors.subTextColor;
    }
  }

  IconData _getCategoryIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('code') || lower.contains('architecture')) {
      return Icons.code_rounded;
    } else if (lower.contains('attendance') || lower.contains('punctuality')) {
      return Icons.access_time_filled_rounded;
    } else if (lower.contains('deadline') || lower.contains('sprint')) {
      return Icons.rocket_launch_rounded;
    } else if (lower.contains('collaboration') || lower.contains('team')) {
      return Icons.groups_rounded;
    }
    return Icons.star_rate_rounded;
  }
}
