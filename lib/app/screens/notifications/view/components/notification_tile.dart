import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../model/notification_item_model.dart';

/// Signature Notification Item Card adhering to AMS 2 Floating Card Blueprint
class NotificationTile extends StatelessWidget {
  final NotificationItemModel item;
  final VoidCallback onTap;

  const NotificationTile({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isUnread = !item.read;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: isUnread
            ? AppColors.cardBackground
            : AppColors.cardBackground.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(
          color: isUnread
              ? AppColors.secondary.withValues(alpha: 0.35)
              : AppColors.borderColor,
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: isUnread
                ? AppColors.primary.withValues(alpha: 0.08)
                : AppColors.primary.withValues(alpha: 0.03),
            blurRadius: isUnread ? 10.r : 4.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.r),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  // Signature inside padding strictly 12.w horizontal, 14.h vertical
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                // 1. Kind Icon Indicator Pill
                Container(
                  width: 38.w,
                  height: 38.w,
                  decoration: BoxDecoration(
                    color: item.kindBackgroundColor,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: item.kindToneColor.withValues(alpha: 0.35),
                      width: 1.w,
                    ),
                  ),
                  child: Icon(
                    item.kindIcon,
                    color: item.kindToneColor,
                    size: 20.sp,
                  ),
                ),

                AppSpaces.hSpace12,

                // 2. Notification Main Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Kind Badge & Created Ago
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 7.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: item.kindBackgroundColor,
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              item.kindLabel,
                              style: AppTextStyles.text10.copyWith(
                                fontWeight: FontWeight.w700,
                                color: item.kindToneColor,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            item.createdAgo ?? '',
                            style: AppTextStyles.text10.copyWith(
                              color: AppColors.subTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (isUnread) ...[
                            AppSpaces.hSpace6,
                            Container(
                              width: 8.w,
                              height: 8.w,
                              decoration: const BoxDecoration(
                                color: AppColors.secondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),

                      AppSpaces.vSpace6,

                      // Notification Title
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.text14.copyWith(
                          fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                          color: AppColors.textColor,
                        ),
                      ),

                      AppSpaces.vSpace4,

                      // Notification Body
                      Text(
                        item.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.text12.copyWith(
                          color: isUnread
                              ? AppColors.textColor.withValues(alpha: 0.85)
                              : AppColors.subTextColor,
                          height: 1.35,
                        ),
                      ),

                      // Destination Action Hint
                      if (item.target.screen != null && item.target.screen!.isNotEmpty) ...[
                        AppSpaces.vSpace8,
                        Row(
                          children: [
                            Text(
                              item.target.screen == 'request'
                                  ? 'Tap to review request'
                                  : (item.target.screen == 'requests'
                                      ? 'Tap to open approvals inbox'
                                      : 'Tap to view details'),
                              style: AppTextStyles.text10.copyWith(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            AppSpaces.hSpace4,
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 12.sp,
                              color: AppColors.secondary,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isUnread)
            Container(
              height: 3.h,
              width: double.infinity,
              color: AppColors.secondary,
            ),
        ],
      ),
    ),
  ),
),
);
  }
}
