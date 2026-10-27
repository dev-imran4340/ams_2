import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../model/attendance_history_model.dart';

class AttendanceLogTile extends StatelessWidget {
  final AttendanceDayLog log;
  final bool isSelected;
  final VoidCallback onTap;

  const AttendanceLogTile({
    super.key,
    required this.log,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    if (log.flags.contains('late') || log.lateMinutes > 0) {
      statusColor = AppColors.warning;
    } else {
      switch (log.tone) {
        case 'emerald':
          statusColor = AppColors.onTimeColor;
          break;
        case 'amber':
          statusColor = AppColors.warning;
          break;
        case 'rose':
          statusColor = AppColors.absentColor;
          break;
        case 'slate':
        default:
          statusColor = AppColors.subTextColor;
      }
    }

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.secondary.withValues(alpha: 0.06)
            : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isSelected ? AppColors.secondary : AppColors.borderColor,
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.03),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Date & Day
                Row(
                  children: [
                    // Status Accent Pill
                    Container(
                      width: 3.5.w,
                      height: 32.h,
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                    AppSpaces.hSpace8,

                    Container(
                      width: 36.r,
                      height: 36.r,
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        log.date.day.toString().padLeft(2, '0'),
                        style: AppTextStyles.text14.copyWith(
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                    AppSpaces.hSpace10,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${log.dayName}, ${log.formattedDate.split(',').first}',
                          style: AppTextStyles.text12.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                        AppSpaces.vSpace2,
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 11.sp,
                              color: AppColors.subTextColor,
                            ),
                            AppSpaces.hSpace4,
                            Text(
                              '${log.checkInTime} - ${log.checkOutTime}',
                              style: AppTextStyles.text10.copyWith(
                                color: AppColors.subTextColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                // Net Working Hours & Status Capsule
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        log.statusLabel,
                        style: AppTextStyles.text10.copyWith(
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                    AppSpaces.vSpace4,
                    Text(
                      log.workingHours,
                      style: AppTextStyles.text10.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor,
                      ),
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
