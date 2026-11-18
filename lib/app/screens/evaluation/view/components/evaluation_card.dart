import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../model/evaluation_model.dart';

class EvaluationCard extends StatelessWidget {
  final EvaluationListItemModel evaluation;
  final VoidCallback onTap;

  const EvaluationCard({
    super.key,
    required this.evaluation,
    required this.onTap,
  });

  Color _resolveToneColor(String tone) {
    switch (tone.toLowerCase()) {
      case 'emerald':
        return AppColors.success;
      case 'amber':
        return AppColors.warning;
      case 'rose':
        return AppColors.error;
      case 'slate':
        return AppColors.subTextColor;
      case 'brand':
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final toneColor = _resolveToneColor(evaluation.tone);

    return CustomCard(
      onTap: onTap,
      margin: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Evaluation Cycle & Status Pill
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  evaluation.cycle,
                  style: AppTextStyles.text14.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              AppSpaces.hSpace8,
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 9.w,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: toneColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: toneColor.withValues(alpha: 0.35),
                    width: 1.w,
                  ),
                ),
                child: Text(
                  evaluation.statusLabel,
                  style: AppTextStyles.text10.copyWith(
                    fontWeight: FontWeight.w600,
                    color: toneColor,
                  ),
                ),
              ),
            ],
          ),

          AppSpaces.vSpace10,

          // Employee Details
          Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                size: 15.w,
                color: AppColors.secondary,
              ),
              AppSpaces.hSpace6,
              Expanded(
                child: Text(
                  '${evaluation.employee.name} (${evaluation.employee.number})',
                  style: AppTextStyles.text12.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          if (evaluation.reviewer != null && evaluation.reviewer!.isNotEmpty) ...[
            AppSpaces.vSpace6,
            Row(
              children: [
                Icon(
                  Icons.rate_review_outlined,
                  size: 15.w,
                  color: AppColors.subTextColor,
                ),
                AppSpaces.hSpace6,
                Expanded(
                  child: Text(
                    'Reviewer: ${evaluation.reviewer}',
                    style: AppTextStyles.text12.copyWith(
                      color: AppColors.subTextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],

          AppSpaces.vSpace10,

          // Footer Row: Due Dates / Result Score & Chevron
          Row(
            children: [
              if (evaluation.managerDueOn != null &&
                  evaluation.managerDueOn!.isNotEmpty)
                _buildInfoBadge(
                  icon: Icons.calendar_today_rounded,
                  label: 'Due ${evaluation.managerDueOn}',
                  color: AppColors.subTextColor,
                )
              else if (evaluation.selfDueOn != null &&
                  evaluation.selfDueOn!.isNotEmpty)
                _buildInfoBadge(
                  icon: Icons.calendar_today_rounded,
                  label: 'Due ${evaluation.selfDueOn}',
                  color: AppColors.subTextColor,
                ),

              // Finalized Score
              if (evaluation.result != null &&
                  evaluation.result!.scoreText != null) ...[
                AppSpaces.hSpace8,
                _buildInfoBadge(
                  icon: Icons.grade_rounded,
                  label:
                      '${evaluation.result!.scoreText} • ${evaluation.result!.levelLabel ?? ""}',
                  color: AppColors.success,
                ),
              ],

              const Spacer(),

              // Action Chevron
              Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13.w,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.w, color: color),
          AppSpaces.hSpace4,
          Text(
            label,
            style: AppTextStyles.text10.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
