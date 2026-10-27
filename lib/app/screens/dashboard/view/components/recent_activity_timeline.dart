import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../controller/dashboard_controller.dart';

class RecentActivityTimeline extends GetView<DashboardController> {
  const RecentActivityTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final today = controller.dashboardData.value?.todayAttendance;
      final isCheckedIn = today?.isCheckedIn ?? false;
      final isCheckedOut =
          (today?.checkOutTime != null && today?.checkOutTime != '--:--');

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 4.w,
                    height: 16.h,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  AppSpaces.hSpace8,
                  Text(
                    "Today's Activity Log",
                    style: AppTextStyles.text16.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  'Live Log',
                  style: AppTextStyles.text10.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),

          AppSpaces.vSpace12,

          // Timeline Card Container
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.borderColor, width: 1.w),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 20.r,
                  offset: Offset(0, 8.h),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                child: _buildTimelineContent(
                  today,
                  isCheckedIn,
                  isCheckedOut,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildTimelineContent(
    dynamic today,
    bool isCheckedIn,
    bool isCheckedOut,
  ) {
    // 1. Extract breaks directly from API payload (day.breaks or break segments)
    final List<_BreakItem> rawBreaks = [];
    final dynamic breaksList = today?.breaks;
    final List segments = today?.segments ?? [];

    if (breaksList is List && breaksList.isNotEmpty) {
      for (final b in breaksList) {
        if (b is Map) {
          final starts = b['starts']?.toString() ?? '--:--';
          final ends = b['ends']?.toString();
          final paid = b['paid'] as bool? ?? false;
          rawBreaks.add(_BreakItem(starts: starts, ends: ends, paid: paid));
        }
      }
    } else if (segments.isNotEmpty) {
      for (final s in segments) {
        if (s.kind?.toString().toLowerCase() == 'break') {
          rawBreaks.add(
            _BreakItem(
              starts: s.starts ?? '--:--',
              ends: s.ends,
              paid: s.paid == true,
            ),
          );
        }
      }
    }

    // 2. Strict Deduplication: Eliminate duplicate break occurrences (e.g. repeated test punches in the same minute)
    final List<_BreakItem> uniqueBreaks = [];
    final Set<String> seenBreakKeys = {};

    for (final b in rawBreaks) {
      final key = '${b.starts}_${b.ends}';
      if (!seenBreakKeys.contains(key)) {
        seenBreakKeys.add(key);
        uniqueBreaks.add(b);
      }
    }

    // 3. Build Timeline Events (Check-In -> Breaks -> Check-Out)
    final List<_ActivityTimelineEvent> events = [];
    final Set<String> seenEventKeys = {};

    void addEvent({
      required String time,
      required String title,
      required String subtitle,
      required String tag,
      required Color color,
    }) {
      if (time.isEmpty || (time == '--:--' && title != 'Shift Check-In')) return;
      final key = '${time}_$title';
      if (!seenEventKeys.contains(key)) {
        seenEventKeys.add(key);
        events.add(
          _ActivityTimelineEvent(
            time: time,
            title: title,
            subtitle: subtitle,
            tag: tag,
            color: color,
          ),
        );
      }
    }

    // Step A: Shift Check-In (only when first_in is present from server)
    final String? checkIn = today?.checkInTime;
    if (checkIn != null && checkIn != '--:--' && checkIn.isNotEmpty) {
      addEvent(
        time: checkIn,
        title: 'Shift Check-In',
        subtitle: isCheckedIn ? 'Shift in progress' : 'Workday started',
        tag: 'Check In',
        color: AppColors.onTimeColor,
      );
    }

    // Step B: Breaks (Break Start & Break End)
    for (final b in uniqueBreaks) {
      final bool isOngoing = (b.ends == null || b.ends == '--:--' || b.ends!.isEmpty);

      addEvent(
        time: b.starts,
        title: 'Break Start',
        subtitle: isOngoing ? 'Break in progress' : 'Started break',
        tag: b.paid ? 'Paid Break' : 'Break',
        color: AppColors.warning,
      );

      if (!isOngoing) {
        addEvent(
          time: b.ends!,
          title: 'Break End',
          subtitle: 'Resumed shift',
          tag: 'Resumed',
          color: AppColors.secondary,
        );
      }
    }

    // Step C: Live break state from state.on_break
    if (today?.isOnBreak ?? false) {
      addEvent(
        time: today?.breakSince ?? '--:--',
        title: 'Break Start',
        subtitle: 'Break in progress',
        tag: 'On Break',
        color: AppColors.warning,
      );
    }

    // Step D: Shift Check-Out (only when employee has actually checked out)
    final String? checkOut = today?.checkOutTime;
    if (isCheckedOut && checkOut != null && checkOut != '--:--' && checkOut.isNotEmpty) {
      addEvent(
        time: checkOut,
        title: 'Shift Check-Out',
        subtitle: 'Workday completed',
        tag: 'Completed',
        color: AppColors.info,
      );
    }

    if (events.isNotEmpty) {
      return Column(
        children: List.generate(events.length, (index) {
          final e = events[index];
          return _buildTimelineItem(
            time: e.time,
            title: e.title,
            subtitle: e.subtitle,
            tag: e.tag,
            color: e.color,
            isFirst: index == 0,
            isLast: index == events.length - 1,
          );
        }),
      );
    }

    // Zero Dummy Fallback State: No fake items when not checked in yet
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Column(
          children: [
            Icon(
              Icons.history_toggle_off_rounded,
              size: 28.sp,
              color: AppColors.subTextColor.withValues(alpha: 0.6),
            ),
            AppSpaces.vSpace8,
            Text(
              'No activity logged yet today',
              style: AppTextStyles.text12.copyWith(
                color: AppColors.subTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            AppSpaces.vSpace4,
            Text(
              today?.status ?? 'Not Checked In',
              style: AppTextStyles.text10.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required String time,
    required String title,
    required String subtitle,
    required String tag,
    required Color color,
    required bool isFirst,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Time Stamp Column
          SizedBox(
            width: 50.w,
            child: Text(
              time,
              style: AppTextStyles.text12.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
          ),

          // Timeline Node & Vertical Connector
          Column(
            children: [
              Container(
                width: 10.r,
                height: 10.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  border: Border.all(
                    color: AppColors.cardBackground,
                    width: 2.w,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.4),
                      blurRadius: 4.r,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2.w,
                    margin: EdgeInsets.symmetric(vertical: 5.h),
                    decoration: BoxDecoration(
                      color: AppColors.borderColor,
                      borderRadius: BorderRadius.circular(1.r),
                    ),
                  ),
                ),
            ],
          ),

          AppSpaces.hSpace12,

          // Details Card Column
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.text12.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          tag,
                          style: AppTextStyles.text10.copyWith(
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  AppSpaces.vSpace4,
                  Text(

                    
                    subtitle,
                    style: AppTextStyles.text10.copyWith(
                      color: AppColors.subTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityTimelineEvent {
  final String time;
  final String title;
  final String subtitle;
  final String tag;
  final Color color;

  const _ActivityTimelineEvent({
    required this.time,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.color,
  });
}

class _BreakItem {
  final String starts;
  final String? ends;
  final bool paid;

  const _BreakItem({
    required this.starts,
    this.ends,
    required this.paid,
  });
}
