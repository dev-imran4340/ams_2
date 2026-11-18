import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../model/news_model.dart';

class EventCard extends StatelessWidget {
  final CompanyEventItemModel event;

  const EventCard({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Date Calendar Box
          Container(
            width: 52.w,
            padding: EdgeInsets.symmetric(vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: AppColors.borderColor,
                width: 0.8.w,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _extractMonth(event.startsOn),
                  style: AppTextStyles.text10.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                    letterSpacing: 0.5,
                  ),
                ),
                AppSpaces.vSpace2,
                Text(
                  _extractDay(event.startsOn),
                  style: AppTextStyles.text18.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
          ),

          AppSpaces.hSpace12,

          // 2. Event Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  event.title,
                  style: AppTextStyles.text14.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textColor,
                  ),
                ),

                AppSpaces.vSpace6,

                // Timing / Schedule
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 13.w,
                      color: AppColors.secondary,
                    ),
                    AppSpaces.hSpace6,
                    Expanded(
                      child: Text(
                        event.when.isNotEmpty
                            ? event.when
                            : (event.allDay
                                ? 'All Day'
                                : '${event.startsAt ?? ''} - ${event.endsAt ?? ''}'),
                        style: AppTextStyles.text12.copyWith(
                          color: AppColors.subTextColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                // Location / Place
                if (event.place != null && event.place!.isNotEmpty) ...[
                  AppSpaces.vSpace4,
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 13.w,
                        color: AppColors.primary,
                      ),
                      AppSpaces.hSpace6,
                      Expanded(
                        child: Text(
                          event.place!,
                          style: AppTextStyles.text12.copyWith(
                            color: AppColors.subTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                // Optional Description Snippet
                if (event.description != null &&
                    event.description!.isNotEmpty) ...[
                  AppSpaces.vSpace6,
                  Text(
                    event.description!,
                    style: AppTextStyles.text10.copyWith(
                      color: AppColors.subTextColor,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _extractMonth(String date) {
    try {
      final dt = DateTime.parse(date);
      const months = [
        'JAN',
        'FEB',
        'MAR',
        'APR',
        'MAY',
        'JUN',
        'JUL',
        'AUG',
        'SEP',
        'OCT',
        'NOV',
        'DEC'
      ];
      return months[dt.month - 1];
    } catch (_) {
      return 'EVENT';
    }
  }

  String _extractDay(String date) {
    try {
      final dt = DateTime.parse(date);
      return dt.day.toString().padLeft(2, '0');
    } catch (_) {
      return '--';
    }
  }
}
