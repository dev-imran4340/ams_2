import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../model/news_model.dart';

class AnnouncementCard extends StatelessWidget {
  final AnnouncementItemModel announcement;
  final VoidCallback onTap;

  const AnnouncementCard({
    super.key,
    required this.announcement,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isUnread = !announcement.read;

    return CustomCard(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Badges & Timestamp
          Row(
            children: [
              if (announcement.isPinned) ...[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      width: 0.8.w,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.push_pin_rounded,
                        size: 11.w,
                        color: AppColors.primary,
                      ),
                      AppSpaces.hSpace4,
                      Text(
                        'Pinned',
                        style: AppTextStyles.text10.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpaces.hSpace8,
              ],
              if (isUnread) ...[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    'New',
                    style: AppTextStyles.text10.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
                AppSpaces.hSpace8,
              ],
              const Spacer(),
              if (announcement.publishedOn != null)
                Text(
                  announcement.publishedOn!,
                  style: AppTextStyles.text10.copyWith(
                    color: AppColors.subTextColor,
                  ),
                ),
            ],
          ),

          AppSpaces.vSpace8,

          // Title
          Text(
            announcement.title,
            style: AppTextStyles.text14.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textColor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          // Excerpt
          if (announcement.excerpt != null &&
              announcement.excerpt!.isNotEmpty) ...[
            AppSpaces.vSpace6,
            Text(
              announcement.excerpt!,
              style: AppTextStyles.text12.copyWith(
                color: AppColors.subTextColor,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          AppSpaces.vSpace10,

          // Read More Action Row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Read Announcement',
                style: AppTextStyles.text10.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                ),
              ),
              AppSpaces.hSpace4,
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 10.w,
                color: AppColors.secondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
