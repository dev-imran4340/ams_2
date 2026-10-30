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
    final List<_ActivityTimelineEvent> events = [];
    final Set<String> seenEventKeys = {};

    void addEvent({
      DateTime? timestamp,
      required String time,
      required String title,
      required String subtitle,
      required String tag,
      required Color color,
      required String uniqueKey,
    }) {
      if (time.isEmpty || (time == '--:--' && !title.contains('Check-In'))) return;
      if (!seenEventKeys.contains(uniqueKey)) {
        seenEventKeys.add(uniqueKey);
        events.add(
          _ActivityTimelineEvent(
            timestamp: timestamp,
            time: time,
            title: title,
            subtitle: subtitle,
            tag: tag,
            color: color,
          ),
        );
      }
    }

    final List segments = today?.segments ?? [];
    final dynamic breaksList = today?.breaks;

    if (segments.isNotEmpty) {
      // 1. Separate segments into work & break
      final workSegments = segments
          .where((s) => s.kind?.toString().toLowerCase() == 'work')
          .toList();
      final totalWork = workSegments.length;

      int workIndex = 0;
      for (final s in workSegments) {
        workIndex++;
        final bool isFirstSession = (workIndex == 1);
        final bool isLastSession = (workIndex == totalWork);
        final bool isCurrentlyActive = (s.ends == null && isCheckedIn);

        // Check-In Event for this session
        final String inTime = s.starts ?? '--:--';
        final String inTitle = isFirstSession
            ? 'Shift Check-In'
            : (totalWork > 1 ? 'Work Check-In ($workIndex)' : 'Work Check-In');
        final String inTag = isFirstSession ? 'First In' : 'Re-entry';
        final String inSubtitle = isCurrentlyActive
            ? 'Active work session'
            : (isFirstSession ? 'Workday started' : 'Resumed shift');

        addEvent(
          timestamp: s.startsAt,
          time: inTime,
          title: inTitle,
          subtitle: inSubtitle,
          tag: inTag,
          color: AppColors.onTimeColor,
          uniqueKey: 'work_in_${workIndex}_${inTime}_${s.startsAt?.toIso8601String()}',
        );

        // Check-Out Event for this session (if ended)
        if (s.ends != null && s.ends!.isNotEmpty && s.ends != '--:--') {
          final String outTime = s.ends!;
          String durationText = '';
          if (s.startsAt != null && s.endsAt != null) {
            final diff = s.endsAt!.difference(s.startsAt!);
            final m = diff.inMinutes;
            final sec = diff.inSeconds % 60;
            if (m > 0) {
              durationText = ' • ${m}m ${sec}s session';
            } else if (sec > 0) {
              durationText = ' • ${sec}s session';
            }
          }

          final bool isFinalOut = isLastSession && !isCheckedIn;
          final String outTitle = isFinalOut
              ? 'Shift Check-Out'
              : (totalWork > 1 ? 'Check-Out ($workIndex)' : 'Check-Out');
          final String outTag = isFinalOut ? 'Completed' : 'Check Out';
          final String outSubtitle = isFinalOut
              ? 'Workday completed$durationText'
              : 'Session logged$durationText';

          addEvent(
            timestamp: s.endsAt,
            time: outTime,
            title: outTitle,
            subtitle: outSubtitle,
            tag: outTag,
            color: AppColors.info,
            uniqueKey: 'work_out_${workIndex}_${outTime}_${s.endsAt?.toIso8601String()}',
          );
        }
      }

    } else {
      // Legacy Fallback if segments array is empty
      final String? checkIn = today?.checkInTime;
      if (checkIn != null && checkIn != '--:--' && checkIn.isNotEmpty) {
        addEvent(
          timestamp: today?.checkInDateTime,
          time: checkIn,
          title: 'Shift Check-In',
          subtitle: isCheckedIn ? 'Shift in progress' : 'Workday started',
          tag: 'Check In',
          color: AppColors.onTimeColor,
          uniqueKey: 'legacy_in_$checkIn',
        );
      }
      final String? checkOut = today?.checkOutTime;
      if (isCheckedOut && checkOut != null && checkOut != '--:--' && checkOut.isNotEmpty) {
        addEvent(
          time: checkOut,
          title: 'Shift Check-Out',
          subtitle: 'Workday completed',
          tag: 'Completed',
          color: AppColors.info,
          uniqueKey: 'legacy_out_$checkOut',
        );
      }
    }

    // 2. Breaks strictly parsed from today.breaks (break list)
    bool hasOngoingBreakInList = false;
    if (breaksList is List && breaksList.isNotEmpty) {
      final totalBreaks = breaksList.length;
      int bIdx = 0;
      for (final b in breaksList) {
        bIdx++;
        String starts = '--:--';
        String? ends;
        DateTime? startsAt;
        DateTime? endsAt;
        bool paid = false;
        int minutes = 0;

        if (b is Map) {
          starts = b['starts']?.toString() ?? '--:--';
          final rawEnds = b['ends']?.toString();
          if (rawEnds != null && rawEnds.isNotEmpty && rawEnds != '--:--') {
            ends = rawEnds;
          }
          if (b['starts_at'] != null) {
            startsAt = b['starts_at'] is DateTime
                ? b['starts_at'] as DateTime
                : DateTime.tryParse(b['starts_at'].toString())?.toLocal();
          }
          if (b['ends_at'] != null) {
            endsAt = b['ends_at'] is DateTime
                ? b['ends_at'] as DateTime
                : DateTime.tryParse(b['ends_at'].toString())?.toLocal();
          }
          paid = b['paid'] as bool? ?? false;
          minutes = (b['minutes'] as num?)?.toInt() ?? 0;
        } else {
          try {
            starts = (b as dynamic).starts?.toString() ?? '--:--';
            final rawEnds = (b as dynamic).ends?.toString();
            if (rawEnds != null && rawEnds.isNotEmpty && rawEnds != '--:--') {
              ends = rawEnds;
            }
            if ((b as dynamic).startsAt != null) {
              startsAt = (b as dynamic).startsAt;
            }
            if ((b as dynamic).endsAt != null) {
              endsAt = (b as dynamic).endsAt;
            }
            paid = (b as dynamic).paid as bool? ?? false;
            minutes = ((b as dynamic).minutes as num?)?.toInt() ?? 0;
          } catch (_) {}
        }

        final bool isBreakOngoing =
            (ends == null || ends.isEmpty || ends == '--:--');
        if (isBreakOngoing || (today?.breakSince != null && starts == today?.breakSince)) {
          hasOngoingBreakInList = true;
        }

        // Break In Event
        final String inTitle = totalBreaks > 1 ? 'Break In ($bIdx)' : 'Break In';
        final String inSubtitle =
            isBreakOngoing ? 'Break in progress' : 'Started break';
        final String inTag = paid ? 'Paid Break' : 'Break In';

        addEvent(
          timestamp: startsAt,
          time: starts,
          title: inTitle,
          subtitle: inSubtitle,
          tag: inTag,
          color: AppColors.warning,
          uniqueKey: 'break_in_${bIdx}_$starts',
        );

        // Break Out Event (if completed)
        if (!isBreakOngoing) {
          final String outTime = ends;
          String bDurationText = '';
          if (minutes >= 60) {
            final h = minutes ~/ 60;
            final m = minutes % 60;
            bDurationText = m > 0 ? ' • ${h}h ${m}m break' : ' • ${h}h break';
          } else if (minutes > 0) {
            bDurationText = ' • ${minutes}m break';
          } else if (startsAt != null && endsAt != null) {
            final diff = endsAt.difference(startsAt);
            final m = diff.inMinutes;
            final sec = diff.inSeconds % 60;
            if (m > 0) {
              bDurationText = ' • ${m}m break';
            } else if (sec > 0) {
              bDurationText = ' • ${sec}s break';
            }
          }

          final String outTitle = totalBreaks > 1 ? 'Break Out ($bIdx)' : 'Break Out';
          final String outSubtitle = 'Resumed shift$bDurationText';

          addEvent(
            timestamp: endsAt,
            time: outTime,
            title: outTitle,
            subtitle: outSubtitle,
            tag: 'Break Out',
            color: AppColors.secondary,
            uniqueKey: 'break_out_${bIdx}_$outTime',
          );
        }
      }
    }

    // 3. Live ongoing break check (only if not already listed in breaksList)
    if (today?.isOnBreak ?? false) {
      final breakTime = today?.breakSince ?? '--:--';
      final bool alreadyLogged = hasOngoingBreakInList ||
          events.any((e) => e.title.contains('Break In') && e.time == breakTime);

      if (!alreadyLogged && breakTime.isNotEmpty && breakTime != '--:--') {
        addEvent(
          time: breakTime,
          title: 'Break In',
          subtitle: 'Break in progress',
          tag: 'On Break',
          color: AppColors.warning,
          uniqueKey: 'live_break_in_$breakTime',
        );
      }
    }

    // Sort events chronologically so the timeline flows from earliest to latest
    events.sort((a, b) {
      if (a.timestamp != null && b.timestamp != null) {
        final cmp = a.timestamp!.compareTo(b.timestamp!);
        if (cmp != 0) return cmp;
      }
      return a.time.compareTo(b.time);
    });

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
  final DateTime? timestamp;
  final String time;
  final String title;
  final String subtitle;
  final String tag;
  final Color color;

  const _ActivityTimelineEvent({
    this.timestamp,
    required this.time,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.color,
  });
}
