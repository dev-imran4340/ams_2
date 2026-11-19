import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../controller/checklist_controller.dart';
import '../../model/checklist_model.dart';
import 'checklist_task_tile.dart';

class ChecklistCard extends GetView<ChecklistController> {
  final ChecklistModel checklist;

  const ChecklistCard({
    super.key,
    required this.checklist,
  });

  @override
  Widget build(BuildContext context) {
    final progress = checklist.progress;
    final accentColor = checklist.statusTone;

    return CustomCard(
      accentColor: accentColor,
      accentWidth: 3.w,
      onTap: () => controller.openChecklistDetails(context, checklist),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header: Icon, Name, Kind & Status Badges
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: (checklist.isOnboarding ? AppColors.secondary : AppColors.primary)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  checklist.isOnboarding
                      ? Icons.how_to_reg_rounded
                      : Icons.exit_to_app_rounded,
                  size: 20.sp,
                  color: checklist.isOnboarding
                      ? AppColors.secondary
                      : AppColors.primary,
                ),
              ),
              AppSpaces.hSpace12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      checklist.name,
                      style: AppTextStyles.text14.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                    AppSpaces.vSpace4,
                    Wrap(
                      spacing: 6.w,
                      runSpacing: 4.h,
                      children: [
                        _buildKindBadge(),
                        _buildStatusBadge(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          AppSpaces.vSpace12,

          // 2. Anchor Date Info (Joining / Leaving)
          if (checklist.anchorOn != null) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 13.sp,
                    color: AppColors.subTextColor,
                  ),
                  AppSpaces.hSpace6,
                  Text(
                    '${checklist.anchorLabel ?? (checklist.isOnboarding ? 'Joining Date' : 'Last Day')}: ',
                    style: AppTextStyles.text10.copyWith(
                      color: AppColors.subTextColor,
                    ),
                  ),
                  Text(
                    checklist.anchorOn!,
                    style: AppTextStyles.text10.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                ],
              ),
            ),
            AppSpaces.vSpace12,
          ],

          // 3. Progress Bar & Ratio
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress (${progress.done}/${progress.total} tasks completed)',
                    style: AppTextStyles.text10.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.subTextColor,
                    ),
                  ),
                  Text(
                    '${progress.percentage}%',
                    style: AppTextStyles.text10.copyWith(
                      fontWeight: FontWeight.bold,
                      color: checklist.isCompleted
                          ? AppColors.success
                          : AppColors.secondary,
                    ),
                  ),
                ],
              ),
              AppSpaces.vSpace6,
              ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: LinearProgressIndicator(
                  value: progress.ratio,
                  minHeight: 6.h,
                  backgroundColor: AppColors.borderColor.withValues(alpha: 0.5),
                  color: checklist.isCompleted
                      ? AppColors.success
                      : AppColors.secondary,
                ),
              ),
            ],
          ),

          // 4. Tasks preview (First 2 tasks)
          if (checklist.tasks.isNotEmpty) ...[
            AppSpaces.vSpace12,
            const Divider(height: 1, thickness: 0.6),
            AppSpaces.vSpace10,
            for (int i = 0; i < checklist.tasks.take(2).length; i++) ...[
              if (i > 0) AppSpaces.vSpace6,
              ChecklistTaskTile(task: checklist.tasks[i]),
            ],
            if (checklist.tasks.length > 2) ...[
              AppSpaces.vSpace8,
              Center(
                child: Text(
                  '+${checklist.tasks.length - 2} more tasks (tap to view all)',
                  style: AppTextStyles.text10.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildKindBadge() {
    final isJoin = checklist.isOnboarding;
    final color = isJoin ? AppColors.secondary : AppColors.primary;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        checklist.kindLabel.toUpperCase(),
        style: AppTextStyles.text10.copyWith(
          fontSize: 9.sp,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final color = checklist.statusTone;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        checklist.statusLabel.toUpperCase(),
        style: AppTextStyles.text10.copyWith(
          fontSize: 9.sp,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
