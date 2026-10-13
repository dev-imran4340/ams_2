import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../model/regularization_model.dart';

class AdjustmentRequestTile extends StatelessWidget {
  final AdjustmentRequestItem item;
  final VoidCallback? onTap;

  const AdjustmentRequestTile({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    Color statusBgColor;
    IconData statusIcon;

    if (item.isApproved) {
      statusColor = AppColors.success;
      statusBgColor = AppColors.success.withValues(alpha: 0.1);
      statusIcon = Icons.check_circle_rounded;
    } else if (item.isPending) {
      statusColor = AppColors.warning;
      statusBgColor = AppColors.warning.withValues(alpha: 0.1);
      statusIcon = Icons.access_time_filled_rounded;
    } else {
      statusColor = AppColors.error;
      statusBgColor = AppColors.error.withValues(alpha: 0.1);
      statusIcon = Icons.cancel_rounded;
    }

    final typeColor = item.isMissedPunch
        ? AppColors.secondary
        : AppColors.primary;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.borderColor,
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.03),
            blurRadius: 10.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(12.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Vertical Pill + ID & Type + Status Pill
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          // Status accent vertical pill
                          Container(
                            width: 3.5.w,
                            height: 16.h,
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(2.r),
                            ),
                          ),
                          AppSpaces.hSpace8,
                          Text(
                            '#${item.id}',
                            style: AppTextStyles.text10.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.subTextColor,
                            ),
                          ),
                          AppSpaces.hSpace6,
                          Container(
                            width: 4.r,
                            height: 4.r,
                            decoration: BoxDecoration(
                              color: AppColors.borderColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          AppSpaces.hSpace6,
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: typeColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              item.type,
                              style: AppTextStyles.text10.copyWith(
                                fontWeight: FontWeight.bold,
                                color: typeColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppSpaces.hSpace8,
                    // Status Pill
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.25),
                          width: 0.8.w,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 11.sp, color: statusColor),
                          AppSpaces.hSpace4,
                          Text(
                            item.status,
                            style: AppTextStyles.text10.copyWith(
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                AppSpaces.vSpace10,

                // Details Box (Timing / Hours Breakdown)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 7.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 13.sp,
                            color: AppColors.secondary,
                          ),
                          AppSpaces.hSpace6,
                          Text(
                            item.date,
                            style: AppTextStyles.text12.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor,
                            ),
                          ),
                        ],
                      ),
                      Flexible(
                        child: Text(
                          item.details,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.text10.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Remarks Excerpt (if present)
                if (item.remarks != null && item.remarks!.isNotEmpty) ...[
                  AppSpaces.vSpace8,
                  Text(
                    item.remarks!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.text12.copyWith(
                      color: AppColors.textColor.withValues(alpha: 0.85),
                      height: 1.35,
                    ),
                  ),
                ],

                // Reviewer Notes / Remarks (if present)
                if (item.reviewerNotes != null &&
                    item.reviewerNotes!.isNotEmpty) ...[
                  AppSpaces.vSpace6,
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: AppColors.borderColor.withValues(alpha: 0.7),
                        width: 0.8.w,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.forum_outlined,
                          size: 12.sp,
                          color: AppColors.subTextColor,
                        ),
                        AppSpaces.hSpace6,
                        Expanded(
                          child: Text(
                            item.reviewerNotes!,
                            style: AppTextStyles.text10.copyWith(
                              fontStyle: FontStyle.italic,
                              color: AppColors.subTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                AppSpaces.vSpace8,

                // Bottom Metadata Row: Applied Date
                Text(
                  'Submitted: ${item.appliedAt}',
                  style: AppTextStyles.text10.copyWith(
                    color: AppColors.subTextColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
