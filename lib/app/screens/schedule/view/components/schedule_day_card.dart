import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../model/schedule_model.dart';
import 'shift_detail_sheet.dart';

class ScheduleDayCard extends StatelessWidget {
  final ScheduleDayModel day;

  const ScheduleDayCard({
    super.key,
    required this.day,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = day.isToday;
    final isWorking = day.isWorkingDay;
    final isHoliday = day.isHoliday;
    final shift = day.shift;

    final accentTone = isToday
        ? AppColors.secondary
        : (isWorking
            ? (shift?.themeColor ?? AppColors.secondary)
            : (isHoliday ? AppColors.success : AppColors.borderColor));

    return CustomCard(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      borderRadius: 15.r,
      accentColor: accentTone,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          ShiftDetailSheet.show(context, day);
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Date Pillar
            Container(
              width: 50.w,
              padding: EdgeInsets.symmetric(vertical: 8.h),
              decoration: BoxDecoration(
                color: isToday
                    ? AppColors.secondary.withValues(alpha: 0.15)
                    : AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: isToday
                      ? AppColors.secondary.withValues(alpha: 0.4)
                      : AppColors.borderColor,
                  width: 1.w,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    day.dayOfWeek,
                    style: AppTextStyles.text10.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isToday ? AppColors.secondary : AppColors.subTextColor,
                    ),
                  ),
                  AppSpaces.vSpace2,
                  Text(
                    day.dayNumber,
                    style: AppTextStyles.text18.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isToday ? AppColors.secondary : AppColors.textColor,
                    ),
                  ),
                  Text(
                    day.monthName,
                    style: AppTextStyles.text10.copyWith(
                      color: AppColors.subTextColor,
                    ),
                  ),
                  if (isToday) ...[
                    AppSpaces.vSpace4,
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        'TODAY',
                        style: AppTextStyles.text10.copyWith(
                          fontSize: 8.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            AppSpaces.hSpace12,

            // Right Body Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row with Shift Name or Rest Tag
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          isWorking
                              ? (shift?.name ?? day.label)
                              : (isHoliday
                                  ? (day.holiday?.name ?? "Public Holiday")
                                  : "Rest Day / Day Off"),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.text14.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                      ),
                      AppSpaces.hSpace6,
                      _buildTypeBadge(shift),
                    ],
                  ),

                  AppSpaces.vSpace6,

                  // Subtitle info
                  if (isWorking && shift != null) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 13.sp,
                          color: AppColors.secondary,
                        ),
                        AppSpaces.hSpace4,
                        Text(
                          shift.timeRangeLabel,
                          style: AppTextStyles.text12.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor,
                          ),
                        ),
                        AppSpaces.hSpace8,
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            '${day.planned} planned',
                            style: AppTextStyles.text10.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    AppSpaces.vSpace6,
                    Row(
                      children: [
                        Text(
                          'Pattern: ${day.pattern ?? "Standard Assigned"}',
                          style: AppTextStyles.text10.copyWith(
                            color: AppColors.subTextColor,
                          ),
                        ),
                        AppSpaces.hSpace8,
                        Text(
                          '• ${shift.breakMinutes} min break',
                          style: AppTextStyles.text10.copyWith(
                            color: AppColors.subTextColor,
                          ),
                        ),
                        if (shift.overnight) ...[
                          AppSpaces.hSpace6,
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(3.r),
                            ),
                            child: Text(
                              'OVERNIGHT',
                              style: AppTextStyles.text10.copyWith(
                                fontSize: 8.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.warning,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ] else if (isHoliday) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.celebration_rounded,
                          size: 13.sp,
                          color: AppColors.success,
                        ),
                        AppSpaces.hSpace4,
                        Text(
                          day.holiday?.isPaid == true ? 'Paid Public Holiday' : 'Company Holiday',
                          style: AppTextStyles.text12.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                    AppSpaces.vSpace4,
                    Text(
                      'No working hours scheduled for this holiday',
                      style: AppTextStyles.text10.copyWith(
                        color: AppColors.subTextColor,
                      ),
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Icon(
                          Icons.bed_rounded,
                          size: 13.sp,
                          color: const Color(0xFF64748B),
                        ),
                        AppSpaces.hSpace4,
                        Text(
                          'Weekly Rota Rest Day',
                          style: AppTextStyles.text12.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppColors.subTextColor,
                          ),
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
    );
  }

  Widget _buildTypeBadge(ShiftModel? shift) {
    if (day.isWorkingDay) {
      final code = shift?.code ?? 'WORK';
      final color = shift?.themeColor ?? AppColors.secondary;
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(4.r),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1.w,
          ),
        ),
        child: Text(
          code,
          style: AppTextStyles.text10.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      );
    } else if (day.isHoliday) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(4.r),
          border: Border.all(
            color: AppColors.success.withValues(alpha: 0.3),
            width: 1.w,
          ),
        ),
        child: Text(
          'HOLIDAY',
          style: AppTextStyles.text10.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.success,
          ),
        ),
      );
    } else {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: const Color(0xFF64748B).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Text(
          'REST',
          style: AppTextStyles.text10.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF64748B),
          ),
        ),
      );
    }
  }
}
