import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../controller/attendance_history_controller.dart';

class DayPunchBreakdownCard extends GetView<AttendanceHistoryController> {
  const DayPunchBreakdownCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final log = controller.selectedDayLog.value;

      if (log == null) {
        return const SizedBox.shrink();
      }

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

      final shiftName = log.shift?.name ?? 'Day Shift';
      final shiftCode = log.shift?.code ?? 'DAY';
      final shiftTiming = (log.shift != null && log.shift!.starts.isNotEmpty)
          ? '${log.shift!.starts} - ${log.shift!.ends}'
          : '09:00 - 17:00';
      final targetHours = log.plannedMinutes > 0
          ? '${(log.plannedMinutes ~/ 60)}h ${(log.plannedMinutes % 60).toString().padLeft(2, '0')}m'
          : 'Standard';

      return CustomCard(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Date info & Status badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(7.r),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.event_available_rounded,
                          size: 16.sp,
                          color: AppColors.secondary,
                        ),
                      ),
                      AppSpaces.hSpace8,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              log.formattedDate,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.text14.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                            ),
                            AppSpaces.vSpace2,
                            Text(
                              '$shiftName ($shiftCode) • $shiftTiming',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.text10.copyWith(
                                color: AppColors.subTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                AppSpaces.hSpace8,

                // Status Capsule Pill
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.3),
                      width: 1.w,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5.r,
                        height: 5.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: statusColor,
                        ),
                      ),
                      AppSpaces.hSpace4,
                      Text(
                        log.statusLabel,
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

            AppSpaces.vSpace14,

            // 4-Tile Telemetry Grid
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    title: 'First In',
                    value: log.checkInTime,
                    icon: Icons.login_rounded,
                    accentColor: AppColors.onTimeColor,
                  ),
                ),
                AppSpaces.hSpace8,
                Expanded(
                  child: _buildMetricTile(
                    title: 'Last Out',
                    value: log.checkOutTime,
                    icon: Icons.logout_rounded,
                    accentColor: AppColors.info,
                  ),
                ),
              ],
            ),
            AppSpaces.vSpace8,
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    title: 'Net Worked',
                    value: log.workingHours,
                    icon: Icons.timer_rounded,
                    accentColor: AppColors.secondary,
                  ),
                ),
                AppSpaces.hSpace8,
                Expanded(
                  child: _buildMetricTile(
                    title: 'Target Time',
                    value: targetHours,
                    icon: Icons.flag_rounded,
                    accentColor: AppColors.primary,
                  ),
                ),
              ],
            ),

            // Compliance & Deviations Row (Late, Early Out, Short Time)
            if (log.lateMinutes > 0 || log.earlyOutMinutes > 0 || log.shortMinutes > 0 || log.breakMinutes > 0) ...[
              AppSpaces.vSpace12,
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.inputFill.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: AppColors.borderColor.withValues(alpha: 0.7),
                    width: 0.8.w,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    if (log.lateMinutes > 0)
                      _buildMiniBadge(
                        label: 'Late',
                        value: '${log.lateMinutes}m',
                        color: AppColors.warning,
                      ),
                    if (log.earlyOutMinutes > 0)
                      _buildMiniBadge(
                        label: 'Early Out',
                        value: '${log.earlyOutMinutes}m',
                        color: AppColors.warning,
                      ),
                    if (log.shortMinutes > 0)
                      _buildMiniBadge(
                        label: 'Short',
                        value: '${log.shortMinutes}m',
                        color: AppColors.absentColor,
                      ),
                    if (log.breakMinutes > 0)
                      _buildMiniBadge(
                        label: 'Break',
                        value: '${log.breakMinutes}m',
                        color: AppColors.secondary,
                      ),
                  ],
                ),
              ),
            ],

            // Real Punch Segments Timeline (if available)
            if (log.segments.isNotEmpty) ...[
              AppSpaces.vSpace12,
              Text(
                'Punch Segments',
                style: AppTextStyles.text10.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.subTextColor,
                ),
              ),
              AppSpaces.vSpace6,
              Column(
                children: log.segments.map((seg) {
                  final starts = seg.starts ?? '--:--';
                  final ends = seg.ends ?? '--:--';
                  return Container(
                    margin: EdgeInsets.only(bottom: 4.h),
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: AppColors.inputFill.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              seg.kind == 'work' ? Icons.work_outline_rounded : Icons.coffee_rounded,
                              size: 13.sp,
                              color: AppColors.secondary,
                            ),
                            AppSpaces.hSpace6,
                            Text(
                              seg.kind.toUpperCase(),
                              style: AppTextStyles.text10.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '$starts - $ends',
                          style: AppTextStyles.text10.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],

            AppSpaces.vSpace12,

            // Bottom Location & Status Verification Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 6.r,
                      height: 6.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.onTimeColor,
                      ),
                    ),
                    AppSpaces.hSpace6,
                    Text(
                      '${log.timezone} • Shift Verified',
                      style: AppTextStyles.text10.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.textColor,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.cloud_done_rounded,
                      size: 13.sp,
                      color: AppColors.secondary,
                    ),
                    AppSpaces.hSpace4,
                    Text(
                      'Live Record',
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
      );
    });
  }

  Widget _buildMiniBadge({
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5.r,
          height: 5.r,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        AppSpaces.hSpace4,
        Text(
          '$label: $value',
          style: AppTextStyles.text10.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.inputFill.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: AppColors.borderColor.withValues(alpha: 0.8),
          width: 0.8.w,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(5.r),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 14.sp, color: accentColor),
          ),
          AppSpaces.hSpace8,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.text10.copyWith(
                    color: AppColors.subTextColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                AppSpaces.vSpace2,
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.text12.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
