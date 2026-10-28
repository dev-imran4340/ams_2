import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/widgets/custom_snackbar.dart';
import '../../../routes/app_routes.dart';
import '../../index/controller/index_controller.dart';
import '../model/attendance_history_model.dart';
import '../repo/attendance_history_repo.dart';
import '../view/components/attendance_date_range_sheet.dart';

class AttendanceHistoryController extends GetxController {
  final AttendanceHistoryRepo repo;

  AttendanceHistoryController({required this.repo});

  // State Observables
  final RxBool isLoading = false.obs;
  final Rxn<AttendanceHistoryResponse> timesheetResponse =
      Rxn<AttendanceHistoryResponse>();

  // Status Filter Observable ('all', 'present', 'late', 'absent', 'off')
  final RxString selectedFilter = 'all'.obs;

  // Date Range / Month Filter Observables (matching GET /me/attendance?from=...&to=...)
  final RxString activeDateRangeFilter = 'this_month'.obs; // 'this_month', 'last_month', 'last_14_days', 'custom'
  final RxString filterLabel = 'October 2026'.obs;
  final RxString filterSubtitle = '01 Oct 2026 — 31 Oct 2026'.obs;
  final Rx<DateTime> selectedMonth = DateTime(2026, 10).obs;
  final Rxn<DateTimeRange> customRange = Rxn<DateTimeRange>();

  final RxString fromDate = ''.obs;
  final RxString toDate = ''.obs;

  static const List<String> monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static String formatIsoDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  static String formatReadableDate(DateTime dt) {
    const shortMonths = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${dt.day.toString().padLeft(2, '0')} ${shortMonths[dt.month - 1]} ${dt.year}';
  }

  @override
  void onInit() {
    super.onInit();
    // Default load current active month with from=2026-10-01 & to=2026-10-31
    applyThisMonth();
  }

  /// Loads live attendance history records from GET /me/attendance (with optional from/to range)
  Future<void> loadTimesheet({String? from, String? to}) async {
    try {
      isLoading.value = true;
      if (from != null) fromDate.value = from;
      if (to != null) toDate.value = to;

      final result = await repo.fetchAttendanceHistory(
        from: from ?? (fromDate.value.isNotEmpty ? fromDate.value : null),
        to: to ?? (toDate.value.isNotEmpty ? toDate.value : null),
      );
      timesheetResponse.value = result;
    } finally {
      isLoading.value = false;
    }
  }

  /// Quick Filter 1: This Month (e.g. October 2026) -> from=2026-10-01&to=2026-10-31
  void applyThisMonth() {
    HapticFeedback.selectionClick();
    activeDateRangeFilter.value = 'this_month';
    final month = DateTime(2026, 10);
    selectedMonth.value = month;
    filterLabel.value = 'October 2026';
    filterSubtitle.value = '01 Oct 2026 — 31 Oct 2026 (Month)';

    loadTimesheet(from: '2026-10-01', to: '2026-10-31');
  }

  /// Quick Filter 2: Last Month (e.g. September 2026) -> from=2026-09-01&to=2026-09-30
  void applyLastMonth() {
    HapticFeedback.selectionClick();
    activeDateRangeFilter.value = 'last_month';
    final month = DateTime(2026, 9);
    selectedMonth.value = month;
    filterLabel.value = 'September 2026';
    filterSubtitle.value = '01 Sep 2026 — 30 Sep 2026 (Month)';

    loadTimesheet(from: '2026-09-01', to: '2026-09-30');
  }

  /// Quick Filter 3: Recent 14 Days (Default unfiltered API response)
  void applyLast14Days() {
    HapticFeedback.selectionClick();
    activeDateRangeFilter.value = 'last_14_days';
    fromDate.value = '';
    toDate.value = '';
    filterLabel.value = 'Recent 14 Days';
    filterSubtitle.value = 'Past 14 days attendance records';

    loadTimesheet();
  }

  /// Opens the sleek corporate Bottom Sheet Date Range Picker
  void pickCustomDateRange(BuildContext context) {
    AttendanceDateRangeSheet.show(context, this);
  }

  /// Alias for opening date range sheet from anywhere in view
  void openCustomDateRangeSheet(BuildContext context) {
    AttendanceDateRangeSheet.show(context, this);
  }

  /// Applies a custom date range selected from AttendanceDateRangeSheet
  void applyCustomDateRange(DateTime start, DateTime end) {
    final daysDiff = end.difference(start).inDays + 1;
    if (daysDiff > 62) {
      CustomSnackbar.showError(
        title: 'Range Too Wide',
        message:
            'Server allows maximum 62 days range. Selected range is $daysDiff days.',
      );
      return;
    }

    customRange.value = DateTimeRange(start: start, end: end);
    activeDateRangeFilter.value = 'custom';

    final fromIso = formatIsoDate(start);
    final toIso = formatIsoDate(end);

    filterLabel.value = 'Custom Range';
    filterSubtitle.value =
        '${formatReadableDate(start)} — ${formatReadableDate(end)} ($daysDiff days)';

    loadTimesheet(from: fromIso, to: toIso);
  }

  /// Shifts active month forward or backward by the given offset
  void changeMonth(int offset) {
    HapticFeedback.lightImpact();
    final current = selectedMonth.value;
    final newMonth = DateTime(current.year, current.month + offset);
    selectedMonth.value = newMonth;
    activeDateRangeFilter.value = 'month';

    final yearStr = newMonth.year.toString();
    final monthStr = newMonth.month.toString().padLeft(2, '0');
    final lastDay = DateTime(newMonth.year, newMonth.month + 1, 0)
        .day
        .toString()
        .padLeft(2, '0');
    final from = '$yearStr-$monthStr-01';
    final to = '$yearStr-$monthStr-$lastDay';

    filterLabel.value = '${monthNames[newMonth.month - 1]} ${newMonth.year}';
    filterSubtitle.value =
        '01 ${monthNames[newMonth.month - 1].substring(0, 3)} $yearStr — $lastDay ${monthNames[newMonth.month - 1].substring(0, 3)} $yearStr';

    loadTimesheet(from: from, to: to);
  }

  /// Sets status filter ('all', 'present', 'late', 'absent', 'off')
  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  /// Returns list filtered by user-selected status pill
  List<AttendanceHistoryDayModel> get filteredList {
    final all = timesheetResponse.value?.data ?? [];
    switch (selectedFilter.value) {
      case 'present':
        return all.where((e) => e.isPresent).toList();
      case 'late':
        return all.where((e) => e.hasLate).toList();
      case 'absent':
        return all.where((e) => e.isAbsent).toList();
      case 'off':
        return all.where((e) => e.isDayOff).toList();
      default:
        return all;
    }
  }

  // Quick statistics derived strictly from live API response
  int get totalRecordsCount => timesheetResponse.value?.data.length ?? 0;
  int get presentCount =>
      timesheetResponse.value?.data.where((e) => e.isPresent).length ?? 0;
  int get lateCount =>
      timesheetResponse.value?.data.where((e) => e.hasLate).length ?? 0;
  int get absentCount =>
      timesheetResponse.value?.data.where((e) => e.isAbsent).length ?? 0;
  int get offCount =>
      timesheetResponse.value?.data.where((e) => e.isDayOff).length ?? 0;

  int get totalWorkedMinutes {
    final list = timesheetResponse.value?.data ?? [];
    return list.fold(0, (sum, item) => sum + item.workedMinutes);
  }

  String get totalWorkedFormatted {
    final mins = totalWorkedMinutes;
    final h = mins ~/ 60;
    final m = mins % 60;
    return '${h}h ${m}m';
  }

  // Fast Navigation Actions
  void navigateToMonthlySummary() {
    Get.toNamed(Routes.ATTENDANCE_SUMMARY);
  }

  void navigateToLeaveApply() {
    if (Get.isRegistered<IndexController>()) {
      Get.find<IndexController>().changeTab(2);
      Get.back();
    } else {
      Get.toNamed(Routes.LEAVE);
    }
  }
}
