import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../controller/training_controller.dart';
import '../../model/training_model.dart';

class TrainingRecordCard extends GetView<TrainingController> {
  final TrainingRecordModel record;

  const TrainingRecordCard({
    super.key,
    required this.record,
  });

  Color _getResultColor(String result) {
    switch (result.toLowerCase()) {
      case 'passed':
        return AppColors.success;
      case 'failed':
        return AppColors.error;
      case 'attended':
      default:
        return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final resultColor = _getResultColor(record.result);

    return CustomCard(
      accentColor: resultColor,
      accentWidth: 3.w,
      onTap: () => controller.openRecordDetails(context, record),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
              // 1. Header: Icon, Course Name & Result Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40.r,
                    height: 40.r,
                    decoration: BoxDecoration(
                      color: resultColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: resultColor.withValues(alpha: 0.25),
                        width: 1.w,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.school_rounded,
                        size: 20.sp,
                        color: resultColor,
                      ),
                    ),
                  ),

                  AppSpaces.hSpace12,

                  // Course Name & Provider
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.course.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.text14.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                        AppSpaces.vSpace4,
                        Text(
                          record.course.provider,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.text10.copyWith(
                            color: AppColors.subTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  AppSpaces.hSpace8,

                  // Result Pill
                  _buildResultBadge(resultColor),
                ],
              ),

              // 2. Trainer & Completion Date Info
              AppSpaces.vSpace12,
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    if (record.completedOn != null) ...[
                      Icon(
                        Icons.event_available_rounded,
                        size: 13.sp,
                        color: AppColors.subTextColor,
                      ),
                      AppSpaces.hSpace4,
                      Text(
                        'Completed: ${record.completedOn}',
                        style: AppTextStyles.text10.copyWith(
                          color: AppColors.subTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const Spacer(),
                    if (record.durationMinutes != null) ...[
                      Icon(
                        Icons.schedule_rounded,
                        size: 13.sp,
                        color: AppColors.subTextColor,
                      ),
                      AppSpaces.hSpace4,
                      Text(
                        '${record.durationMinutes} mins',
                        style: AppTextStyles.text10.copyWith(
                          color: AppColors.textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // 3. Footer: Expiry & Certificate Indicator
              AppSpaces.vSpace10,
              Row(
                children: [
                  if (record.expiresOn != null) ...[
                    Icon(
                      Icons.event_busy_rounded,
                      size: 12.sp,
                      color: record.isValid
                          ? AppColors.subTextColor
                          : AppColors.error,
                    ),
                    AppSpaces.hSpace4,
                    Text(
                      'Expires: ${record.expiresOn}',
                      style: AppTextStyles.text10.copyWith(
                        color: record.isValid
                            ? AppColors.subTextColor
                            : AppColors.error,
                        fontWeight:
                            record.isValid ? FontWeight.w500 : FontWeight.bold,
                      ),
                    ),
                  ],

                  const Spacer(),

                  if (record.hasCertificate)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6.r),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          width: 0.8.w,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.card_membership_rounded,
                            size: 12.sp,
                            color: AppColors.primary,
                          ),
                          AppSpaces.hSpace4,
                          Text(
                            'Certificate',
                            style: AppTextStyles.text10.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
    );
  }

  Widget _buildResultBadge(Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 0.8.w,
        ),
      ),
      child: Text(
        record.resultLabel.toUpperCase(),
        style: AppTextStyles.text10.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
