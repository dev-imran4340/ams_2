import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../model/schedule_model.dart';

class ShiftDetailSheet extends StatelessWidget {
  final ScheduleDayModel day;

  const ShiftDetailSheet({super.key, required this.day});

  static void show(BuildContext context, ScheduleDayModel day) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ShiftDetailSheet(day: day),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shift = day.shift;
    final isWorking = day.isWorkingDay;
    final isHoliday = day.isHoliday;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        border: Border.all(color: AppColors.borderColor, width: 1.w),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.borderColor,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),

            AppSpaces.vSpace16,

            // Header Row
            Row(
              children: [
                Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    color: (shift?.themeColor ?? AppColors.secondary).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    isWorking
                        ? Icons.access_time_filled_rounded
                        : (isHoliday ? Icons.celebration_rounded : Icons.weekend_rounded),
                    color: shift?.themeColor ?? AppColors.secondary,
                    size: 24.sp,
                  ),
                ),
                AppSpaces.hSpace12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isWorking
                            ? (shift?.name ?? day.label)
                            : (isHoliday ? (day.holiday?.name ?? "Holiday") : "Rest Day"),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.text18.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                      AppSpaces.vSpace2,
                      Text(
                        '${day.fullDayOfWeek}, ${day.dayNumber} ${day.monthName} ${day.parsedDate?.year ?? ""}',
                        style: AppTextStyles.text12.copyWith(
                          color: AppColors.subTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            AppSpaces.vSpace16,
            Container(height: 1.h, color: AppColors.borderColor),
            AppSpaces.vSpace14,

            // Detail Attributes Grid
            if (isWorking && shift != null) ...[
              _buildRow('Shift Timings', shift.timeRangeLabel),
              AppSpaces.vSpace8,
              _buildRow('Planned Hours', '${day.planned} (${day.plannedMinutes} minutes)'),
              AppSpaces.vSpace8,
              _buildRow('Break Duration', '${shift.breakMinutes} Minutes'),
              AppSpaces.vSpace8,
              _buildRow('Work Pattern', day.pattern ?? 'Standard Week'),
              AppSpaces.vSpace8,
              _buildRow('Overnight Shift', shift.overnight ? 'Yes (Crosses Midnight)' : 'No (Same Day)'),
              AppSpaces.vSpace8,
              _buildRow('Shift Code', shift.code),
              if (day.timezone != null) ...[
                AppSpaces.vSpace8,
                _buildRow('Timezone', day.timezone!),
              ],
              AppSpaces.vSpace8,
              _buildRow('Source', day.source.capitalizeFirst ?? day.source),
            ] else if (isHoliday) ...[
              _buildRow('Holiday Name', day.holiday?.name ?? 'Designated Holiday'),
              AppSpaces.vSpace8,
              _buildRow('Holiday Type', day.holiday?.isPublicHoliday == true ? 'Public Gazetted' : 'Company'),
              AppSpaces.vSpace8,
              _buildRow('Compensation', day.holiday?.isPaid == true ? 'Paid Holiday' : 'Unpaid'),
            ] else ...[
              _buildRow('Schedule Type', 'Rest Day / Weekly Off'),
              AppSpaces.vSpace8,
              _buildRow('Source', day.source.capitalizeFirst ?? 'Pattern'),
              AppSpaces.vSpace8,
              _buildRow('Planned Hours', '0:00 (No shift required)'),
            ],

            AppSpaces.vSpace20,

            // Close Action
            CustomButton(
              isGradient: true,
              text: 'Close Details',
              onPressed: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.text12.copyWith(
            color: AppColors.subTextColor,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.text12.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textColor,
          ),
        ),
      ],
    );
  }
}
