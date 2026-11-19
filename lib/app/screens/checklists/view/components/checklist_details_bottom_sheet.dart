import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../model/checklist_model.dart';
import 'checklist_task_tile.dart';

class ChecklistDetailsBottomSheet extends StatelessWidget {
  final ChecklistModel checklist;

  const ChecklistDetailsBottomSheet({
    super.key,
    required this.checklist,
  });

  static Future<void> show(
    BuildContext context, {
    required ChecklistModel checklist,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChecklistDetailsBottomSheet(checklist: checklist),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = checklist.progress;

    return Container(
      constraints: BoxConstraints(
        maxHeight: 0.85.sh,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 10.h, bottom: 8.h),
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.borderColor,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        checklist.name,
                        style: AppTextStyles.text16.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                      AppSpaces.vSpace2,
                      Text(
                        '${checklist.kindLabel} • ${checklist.statusLabel}',
                        style: AppTextStyles.text10.copyWith(
                          color: AppColors.subTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(
                    Icons.close_rounded,
                    color: AppColors.subTextColor,
                    size: 20.sp,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 0.8),

          // Scrollable Content
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress summary box
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundColor,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.borderColor, width: 0.8.w),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Overall Progress',
                              style: AppTextStyles.text12.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                            ),
                            Text(
                              '${progress.done} of ${progress.total} done (${progress.percentage}%)',
                              style: AppTextStyles.text10.copyWith(
                                fontWeight: FontWeight.bold,
                                color: checklist.isCompleted
                                    ? AppColors.success
                                    : AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                        AppSpaces.vSpace8,
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4.r),
                          child: LinearProgressIndicator(
                            value: progress.ratio,
                            minHeight: 7.h,
                            backgroundColor: AppColors.borderColor.withValues(alpha: 0.5),
                            color: checklist.isCompleted
                                ? AppColors.success
                                : AppColors.secondary,
                          ),
                        ),
                        if (checklist.anchorOn != null) ...[
                          AppSpaces.vSpace10,
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_month_outlined,
                                size: 14.sp,
                                color: AppColors.subTextColor,
                              ),
                              AppSpaces.hSpace6,
                              Text(
                                '${checklist.anchorLabel ?? 'Target Date'}: ${checklist.anchorOn!}',
                                style: AppTextStyles.text10.copyWith(
                                  color: AppColors.subTextColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  AppSpaces.vSpace16,

                  // Tasks section header
                  Text(
                    'Checklist Tasks (${checklist.tasks.length})',
                    style: AppTextStyles.text14.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  AppSpaces.vSpace10,

                  // Task tiles
                  if (checklist.tasks.isEmpty)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.h),
                        child: Text(
                          'No specific sub-tasks recorded for this checklist.',
                          style: AppTextStyles.text12.copyWith(
                            color: AppColors.subTextColor,
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: checklist.tasks.length,
                      separatorBuilder: (_, _) => AppSpaces.vSpace8,
                      itemBuilder: (context, index) {
                        return ChecklistTaskTile(task: checklist.tasks[index]);
                      },
                    ),

                  AppSpaces.vSpace20,

                  // Close button
                  CustomButton(
                    text: 'Close',
                    isOutlined: true,
                    onPressed: () => Get.back(),
                  ),

                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
