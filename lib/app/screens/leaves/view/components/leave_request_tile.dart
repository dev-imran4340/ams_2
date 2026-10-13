import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../model/leave_model.dart';

class LeaveRequestTile extends StatelessWidget {
  final LeaveRequestItemModel item;
  final VoidCallback? onTap;

  const LeaveRequestTile({
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
                // Top Row: Category Icon + ID & Status Pill
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
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
                        Text(
                          item.leaveType,
                          style: AppTextStyles.text12.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                      ],
                    ),

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

                // Middle: Date Range & Duration Badge
                Container(
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
                            Icons.date_range_rounded,
                            size: 14.sp,
                            color: AppColors.secondary,
                          ),
                          AppSpaces.hSpace6,
                          Text(
                            '${item.startDate}  →  ${item.endDate}',
                            style: AppTextStyles.text12.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColor,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 7.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: AppColors.borderColor,
                            width: 0.8.w,
                          ),
                        ),
                        child: Text(
                          '${item.totalDays} ${item.totalDays == 1 ? 'Day' : 'Days'}',
                          style: AppTextStyles.text10.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                AppSpaces.vSpace8,

                // Reason Excerpt
                Text(
                  item.reason,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.text12.copyWith(
                    color: AppColors.textColor.withValues(alpha: 0.85),
                    height: 1.35,
                  ),
                ),

                // Manager Notes / Remarks (if present)
                if (item.managerNotes != null &&
                    item.managerNotes!.isNotEmpty) ...[
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
                            item.managerNotes!,
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

                // Bottom Metadata Row: Applied Date + Attachment indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Applied: ${item.appliedAt}',
                      style: AppTextStyles.text10.copyWith(
                        color: AppColors.subTextColor,
                      ),
                    ),
                    if (item.attachmentName != null)
                      Row(
                        children: [
                          Icon(
                            Icons.attach_file_rounded,
                            size: 12.sp,
                            color: AppColors.secondary,
                          ),
                          AppSpaces.hSpace2,
                          Text(
                            'Attachment',
                            style: AppTextStyles.text10.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
