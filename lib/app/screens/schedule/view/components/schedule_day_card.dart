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
            ? AppColors.secondary
            : (isHoliday ? AppColors.success : AppColors.borderColor));

    return CustomCard(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      borderRadius: 14.r,
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
              width: 44.w,
              padding: EdgeInsets.symmetric(vertical: 6.h),
              decoration: BoxDecoration(
                color: isToday
                    ? AppColors.secondary.withValues(alpha: 0.15)
                    : AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8.r),
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
                      fontSize: 9.sp,
                      fontWeight: FontWeight.bold,
                      color: isToday ? AppColors.secondary : AppColors.subTextColor,
                    ),
                  ),
                  AppSpaces.vSpace2,
                  Text(
                    day.dayNumber,
                    style: AppTextStyles.text16.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isToday ? AppColors.secondary : AppColors.textColor,
                    ),
                  ),
                  Text(
                    day.monthName,
                    style: AppTextStyles.text10.copyWith(
                      fontSize: 9.sp,
                      color: AppColors.subTextColor,
                    ),
                  ),
                  if (isToday) ...[
                    AppSpaces.vSpace2,
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                      child: Text(
                        'TODAY',
                        style: AppTextStyles.text10.copyWith(
                          fontSize: 7.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            AppSpaces.hSpace10,

            // Right Body Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row with Shift Name or Rest Tag (Wrap to Next Line, No Ellipsis)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          isWorking
                              ? (shift?.name ?? day.label)
                              : (isHoliday
                                  ? (day.holiday?.name ?? "Public Holiday")
                                  : "Rest Day / Day Off"),
                          style: AppTextStyles.text12.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                            height: 1.25,
                          ),
                        ),
                      ),
                      AppSpaces.hSpace6,
                      _buildTypeBadge(),
                    ],
                  ),

                  AppSpaces.vSpace6,

                  // Subtitle info
                  if (isWorking && shift != null) ...[
                    // Timing & Planned Badge
                    Wrap(
                      spacing: 6.w,
                      runSpacing: 4.h,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 12.sp,
                              color: AppColors.secondary,
                            ),
                            AppSpaces.hSpace4,
                            Text(
                              shift.timeRangeLabel,
                              style: AppTextStyles.text10.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textColor,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            '${day.planned} planned',
                            style: AppTextStyles.text10.copyWith(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                        if (shift.breakMinutes > 0)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                            decoration: BoxDecoration(
                              color: AppColors.borderColor.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              '${shift.breakMinutes}m break',
                              style: AppTextStyles.text10.copyWith(
                                fontSize: 9.sp,
                                color: AppColors.subTextColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        if (shift.overnight)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(3.r),
                            ),
                            child: Text(
                              'OVERNIGHT',
                              style: AppTextStyles.text10.copyWith(
                                fontSize: 7.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.warning,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (day.pattern != null && day.pattern!.isNotEmpty) ...[
                      AppSpaces.vSpace4,
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(5.r),
                          border: Border.all(
                            color: AppColors.borderColor.withValues(alpha: 0.4),
                            width: 0.7.w,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 1.h),
                              child: Icon(
                                Icons.calendar_view_week_rounded,
                                size: 10.sp,
                                color: AppColors.subTextColor,
                              ),
                            ),
                            AppSpaces.hSpace4,
                            Expanded(
                              child: Text(
                                day.pattern!,
                                style: AppTextStyles.text10.copyWith(
                                  fontSize: 9.sp,
                                  color: AppColors.subTextColor,
                                  height: 1.25,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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

  Widget _buildTypeBadge() {
    final shift = day.shift;
    if (day.isWorkingDay) {
      // Rule: Agar code null ya empty hai to exact API 'day.type' (e.g. WORKING) show hoga
      final String badgeText;
      if (shift?.code != null && shift!.code!.trim().isNotEmpty) {
        badgeText = shift.code!.trim().toUpperCase();
      } else {
        badgeText = day.type.trim().toUpperCase(); // e.g. "WORKING"
      }

      // Working shift uses Corporate Navy / Teal tone for a professional look
      final color = AppColors.secondary;
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
          badgeText,
          style: AppTextStyles.text10.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      );
    } else if (day.isHoliday) {
      // Holiday case: Server 'day.type' (e.g. HOLIDAY)
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
          day.type.trim().toUpperCase(), // "HOLIDAY"
          style: AppTextStyles.text10.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.success,
          ),
        ),
      );
    } else {
      // Off / Rest case: Server 'day.type' (e.g. OFF / REST)
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: const Color(0xFF64748B).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Text(
          day.type.trim().toUpperCase(), // "OFF"
          style: AppTextStyles.text10.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF64748B),
          ),
        ),
      );
    }
  }
}
