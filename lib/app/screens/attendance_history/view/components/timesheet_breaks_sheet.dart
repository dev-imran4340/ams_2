import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../model/attendance_history_model.dart';

class TimesheetBreaksSheet extends StatelessWidget {
  final AttendanceHistoryDayModel log;

  const TimesheetBreaksSheet({
    super.key,
    required this.log,
  });

  /// Displays the modal bottom sheet for break details
  static Future<void> show(
    BuildContext context,
    AttendanceHistoryDayModel log,
  ) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TimesheetBreaksSheet(log: log),
    );
  }

  @override
  Widget build(BuildContext context) {
    final breaks = log.allBreaks;
    final hasInProgress = breaks.any((b) => b.isInProgress);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.82,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(22.r),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.16),
            blurRadius: 28.r,
            offset: Offset(0, -6.h),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Drag Handle Pill
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.borderColor,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              AppSpaces.vSpace14,

              // 2. Header: Title, Date, and Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          Icons.coffee_rounded,
                          size: 18.sp,
                          color: AppColors.warning,
                        ),
                      ),
                      AppSpaces.hSpace10,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Break Details',
                            style: AppTextStyles.text16.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor,
                            ),
                          ),
                          AppSpaces.vSpace2,
                          Text(
                            log.dateLabel,
                            style: AppTextStyles.text10.copyWith(
                              color: AppColors.subTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Close Icon Button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Get.back(),
                      borderRadius: BorderRadius.circular(20.r),
                      child: Container(
                        padding: EdgeInsets.all(6.r),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.borderColor.withValues(alpha: 0.35),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 16.sp,
                          color: AppColors.textColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              AppSpaces.vSpace14,

              // 3. Summary Banner (Total Break Time & Sessions)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.borderColor,
                    width: 1.w,
                  ),
                ),
                child: Row(
                  children: [
                    // Total Break Time
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Break Time',
                            style: AppTextStyles.text10.copyWith(
                              color: AppColors.subTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          AppSpaces.vSpace4,
                          Row(
                            children: [
                              Text(
                                log.totalBreakMinutes > 0
                                    ? log.totalBreakFormatted
                                    : (hasInProgress ? 'In Progress' : '0m'),
                                style: AppTextStyles.text16.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              if (hasInProgress) ...[
                                AppSpaces.hSpace6,
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6.w,
                                    vertical: 2.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.warning
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Text(
                                    'Active',
                                    style: AppTextStyles.text10.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.warning,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    Container(
                      width: 1.w,
                      height: 32.h,
                      color: AppColors.borderColor,
                    ),

                    // Logged Sessions Count
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 14.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Breaks',
                              style: AppTextStyles.text10.copyWith(
                                color: AppColors.subTextColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            AppSpaces.vSpace4,
                            Text(
                              breaks.isNotEmpty
                                  ? '${breaks.length} ${breaks.length == 1 ? 'Record' : 'Records'}'
                                  : (log.totalBreakMinutes > 0
                                      ? '1 Record'
                                      : '0 Records'),
                              style: AppTextStyles.text16.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AppSpaces.vSpace14,

              // 4. Section Label
              Text(
                'LOGGED BREAK SESSIONS',
                style: AppTextStyles.text10.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.subTextColor,
                  letterSpacing: 0.5,
                ),
              ),
              AppSpaces.vSpace10,

              // 5. Scrollable Break Cards List
              Flexible(
                child: breaks.isEmpty
                    ? Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 16.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundColor,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.borderColor,
                            width: 0.8.w,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.coffee_rounded,
                              size: 26.sp,
                              color: AppColors.secondary,
                            ),
                            AppSpaces.vSpace8,
                            Text(
                              log.totalBreakMinutes > 0
                                  ? 'Total Break: ${log.totalBreakFormatted}'
                                  : 'No Breaks Logged',
                              style: AppTextStyles.text12.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                            ),
                            AppSpaces.vSpace2,
                            Text(
                              log.totalBreakMinutes > 0
                                  ? 'Daily aggregate break duration recorded without punch breakdown.'
                                  : 'No break duration or sessions were logged for this date.',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.text10.copyWith(
                                color: AppColors.subTextColor,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: breaks.length,
                        separatorBuilder: (context, index) => AppSpaces.vSpace10,
                        itemBuilder: (context, index) {
                          final item = breaks[index];
                          return _buildBreakSessionCard(item, index + 1);
                        },
                      ),
              ),
              AppSpaces.vSpace16,

              // 6. Dismiss Action Button
              CustomButton(
                text: 'Close',
                isGradient: true,
                onPressed: () => Get.back(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBreakSessionCard(AttendanceHistoryBreakModel item, int index) {
    final isInProgress = item.isInProgress;
    final statusColor =
        isInProgress ? AppColors.warning : AppColors.onTimeColor;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isInProgress
              ? AppColors.warning.withValues(alpha: 0.4)
              : AppColors.borderColor,
          width: isInProgress ? 1.w : 0.8.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Session # and Status Chip
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
                      color: statusColor,
                    ),
                  ),
                  AppSpaces.hSpace6,
                  Text(
                    item.type != null && item.type!.trim().isNotEmpty
                        ? '${item.type!.capitalizeFirst} Break (#$index)'
                        : 'Break #$index',
                    style: AppTextStyles.text12.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                ],
              ),

              // Status Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.3),
                    width: 0.8.w,
                  ),
                ),
                child: Text(
                  isInProgress ? 'In Progress' : 'Total: ${item.durationDisplay}',
                  style: AppTextStyles.text10.copyWith(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          AppSpaces.vSpace10,

          // Telemetry Row: Break In, Arrow, Break Out, Duration
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: AppColors.borderColor.withValues(alpha: 0.5),
                width: 0.8.w,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Break In Column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.login_rounded,
                          size: 11.sp,
                          color: AppColors.onTimeColor,
                        ),
                        AppSpaces.hSpace4,
                        Text(
                          'Break In',
                          style: AppTextStyles.text10.copyWith(
                            color: AppColors.subTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    AppSpaces.vSpace2,
                    Text(
                      item.breakInDisplay,
                      style: AppTextStyles.text12.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                  ],
                ),

                // Arrow Divider
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 14.sp,
                  color: AppColors.subTextColor,
                ),

                // Break Out Column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.logout_rounded,
                          size: 11.sp,
                          color: isInProgress
                              ? AppColors.warning
                              : AppColors.primary,
                        ),
                        AppSpaces.hSpace4,
                        Text(
                          'Break Out',
                          style: AppTextStyles.text10.copyWith(
                            color: AppColors.subTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    AppSpaces.vSpace2,
                    Text(
                      item.breakOutDisplay,
                      style: AppTextStyles.text12.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isInProgress
                            ? AppColors.warning
                            : AppColors.textColor,
                      ),
                    ),
                  ],
                ),

                // Paid / Unpaid Chip
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 6.w,
                    vertical: 3.h,
                  ),
                  decoration: BoxDecoration(
                    color: (item.paid ? AppColors.secondary : AppColors.subTextColor)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    item.paid ? 'Paid' : 'Unpaid',
                    style: AppTextStyles.text10.copyWith(
                      fontWeight: FontWeight.bold,
                      color: item.paid
                          ? AppColors.secondary
                          : AppColors.subTextColor,
                    ),
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
