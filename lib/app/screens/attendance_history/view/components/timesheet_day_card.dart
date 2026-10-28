import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../model/attendance_history_model.dart';
import 'timesheet_breaks_sheet.dart';

class TimesheetDayCard extends StatelessWidget {
  final AttendanceHistoryDayModel log;

  const TimesheetDayCard({
    super.key,
    required this.log,
  });

  Color _resolveToneColor(String tone) {
    switch (tone.toLowerCase()) {
      case 'emerald':
        return AppColors.onTimeColor;
      case 'brand':
        return AppColors.secondary;
      case 'rose':
        return AppColors.absentColor;
      case 'amber':
        return AppColors.warning;
      case 'slate':
      default:
        return AppColors.subTextColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = _resolveToneColor(log.tone);

    return CustomCard(
      accentColor: accentColor,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header: Date, Shift Name, and Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 36.r,
                      height: 36.r,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        log.statusCode,
                        style: AppTextStyles.text14.copyWith(
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                    ),
                    AppSpaces.hSpace10,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            log.dateLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.text14.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor,
                            ),
                          ),
                          AppSpaces.vSpace2,
                          Text(
                            log.shift != null
                                ? '${log.shift!.name} • ${log.shift!.starts} - ${log.shift!.ends}'
                                : (log.isDayOff
                                    ? 'Scheduled Day Off'
                                    : 'No Shift Assigned'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.text10.copyWith(
                              color: AppColors.subTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              AppSpaces.hSpace8,

              // Status Badge Chip
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.3),
                    width: 0.8.w,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6.r,
                      height: 6.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accentColor,
                      ),
                    ),
                    AppSpaces.hSpace6,
                    Text(
                      log.statusLabel,
                      style: AppTextStyles.text10.copyWith(
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // If day is OFF or ABSENT without punches, show minimal summary
          if (log.isDayOff || (log.isAbsent && log.firstIn == null)) ...[
            AppSpaces.vSpace10,
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.borderColor.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                log.isDayOff
                    ? 'Enjoy your rest day! No punch activity recorded.'
                    : 'No punch recorded. Planned shift hours: ${(log.plannedMinutes ~/ 60)}h.',
                style: AppTextStyles.text10.copyWith(
                  color: AppColors.subTextColor,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ] else ...[
            AppSpaces.vSpace12,

            // 2. Punch Telemetry Grid (In, Out, Worked, Counted)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: AppColors.borderColor.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                children: [
                  // Check In
                  Expanded(
                    child: _buildTelemetryColumn(
                      label: 'Check In',
                      time: log.checkInDisplay,
                      icon: Icons.login_rounded,
                      color: AppColors.onTimeColor,
                    ),
                  ),
                  _buildDivider(),

                  // Check Out
                  Expanded(
                    child: _buildTelemetryColumn(
                      label: 'Check Out',
                      time: log.checkOutDisplay,
                      icon: Icons.logout_rounded,
                      color: log.isInProgress
                          ? AppColors.secondary
                          : AppColors.primary,
                    ),
                  ),
                  _buildDivider(),

                  // Worked
                  Expanded(
                    child: _buildTelemetryColumn(
                      label: 'Worked',
                      time: log.workedFormatted,
                      icon: Icons.access_time_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  _buildDivider(),

                  // Counted (Paid)
                  Expanded(
                    child: _buildTelemetryColumn(
                      label: 'Counted',
                      time: log.countedFormatted,
                      icon: Icons.check_circle_outline_rounded,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),

            // 3. Flags and Interactive Breaks Button Strip
            if (log.hasLate || log.hasEarlyOut || log.hasBreaks) ...[
              AppSpaces.vSpace10,
              Wrap(
                spacing: 6.w,
                runSpacing: 6.h,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (log.hasLate)
                    _buildFlagPill(
                      label: 'Late Arrival (+${log.lateMinutes}m)',
                      icon: Icons.warning_amber_rounded,
                      color: AppColors.lateColor,
                    ),
                  if (log.hasEarlyOut)
                    _buildFlagPill(
                      label: 'Early Exit (-${log.earlyOutMinutes}m)',
                      icon: Icons.timelapse_rounded,
                      color: AppColors.absentColor,
                    ),

                  // Interactive Break Details Button (Strictly shown if break exists)
                  if (log.hasBreaks)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => TimesheetBreaksSheet.show(context, log),
                        borderRadius: BorderRadius.circular(8.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 9.w,
                            vertical: 3.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color:
                                  AppColors.secondary.withValues(alpha: 0.35),
                              width: 0.8.w,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.coffee_rounded,
                                size: 11.sp,
                                color: AppColors.secondary,
                              ),
                              AppSpaces.hSpace4,
                              Text(
                                log.totalBreakMinutes > 0
                                    ? 'Breaks (${log.totalBreakFormatted})'
                                    : 'Check Breaks',
                                style: AppTextStyles.text10.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.secondary,
                                ),
                              ),
                              AppSpaces.hSpace4,
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 8.sp,
                                color: AppColors.secondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildTelemetryColumn({
    required String label,
    required String time,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 11.sp, color: color),
            AppSpaces.hSpace4,
            Text(
              label,
              style: AppTextStyles.text10.copyWith(
                color: AppColors.subTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        AppSpaces.vSpace4,
        Text(
          time,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.text12.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1.w,
      height: 24.h,
      color: AppColors.borderColor,
    );
  }

  Widget _buildFlagPill({
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
          width: 0.8.w,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11.sp, color: color),
          AppSpaces.hSpace4,
          Text(
            label,
            style: AppTextStyles.text10.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
