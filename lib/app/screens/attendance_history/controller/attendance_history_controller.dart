import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../api/app_preferences.dart';
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
  final RxString activeDateRangeFilter = 'this_month'.obs; // 'this_month', 'today', 'last_month', 'last_14_days', 'custom'
  final RxString filterLabel = ''.obs;
  final RxString filterSubtitle = ''.obs;
  final Rx<DateTime> selectedMonth = DateTime.now().obs;
  final Rxn<DateTimeRange> customRange = Rxn<DateTimeRange>();

  final RxString fromDate = ''.obs;
  final RxString toDate = ''.obs;

  // Manager / HR Audit Target Employee (GET /employees/{id}/attendance)
  final RxString targetEmployeeId = ''.obs;
  final RxString targetEmployeeName = ''.obs;
  final RxBool isAccessRestricted = false.obs;

  bool get isAuditMode => targetEmployeeId.value.isNotEmpty;

  bool get canViewAudit {
    if (!AppPreferences.hasModule('attendance')) return false;
    if (targetEmployeeId.value.isEmpty) {
      return AppPreferences.hasPermission('attendance.view');
    }
    return AppPreferences.hasPermission('attendance.view', 'department');
  }

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
    final args = Get.arguments;
    if (args is Map) {
      if (args['employeeId'] != null) {
        targetEmployeeId.value = args['employeeId'].toString();
      }
      if (args['employeeName'] != null) {
        targetEmployeeName.value = args['employeeName'].toString();
      }
    }
    // Default load current active month dynamically based on today's date & month
    applyThisMonth();
  }

  /// Loads live attendance history records from GET /me/attendance or GET /employees/{id}/attendance
  Future<void> loadTimesheet({String? from, String? to}) async {
    if (!canViewAudit) {
      isAccessRestricted.value = true;
      timesheetResponse.value = null;
      return;
    }
    isAccessRestricted.value = false;

    try {
      isLoading.value = true;
      if (from != null) fromDate.value = from;
      if (to != null) toDate.value = to;

      final AttendanceHistoryResponse? result;
      if (targetEmployeeId.value.isNotEmpty) {
        result = await repo.fetchEmployeeAttendance(
          targetEmployeeId.value,
          from: from ?? (fromDate.value.isNotEmpty ? fromDate.value : null),
          to: to ?? (toDate.value.isNotEmpty ? toDate.value : null),
        );
      } else {
        result = await repo.fetchAttendanceHistory(
          from: from ?? (fromDate.value.isNotEmpty ? fromDate.value : null),
          to: to ?? (toDate.value.isNotEmpty ? toDate.value : null),
        );
      }
      timesheetResponse.value = result;
    } finally {
      isLoading.value = false;
    }
  }

  /// Quick Filter 1: This Month (Dynamic current month based on DateTime.now())
  void applyThisMonth() {
    HapticFeedback.selectionClick();
    activeDateRangeFilter.value = 'this_month';
    final now = DateTime.now();
    final month = DateTime(now.year, now.month);
    selectedMonth.value = month;

    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final fromIso = formatIsoDate(startOfMonth);
    final toIso = formatIsoDate(endOfMonth);

    final monthName = monthNames[now.month - 1];
    final shortMonth = monthName.substring(0, 3);
    final lastDayStr = endOfMonth.day.toString().padLeft(2, '0');

    filterLabel.value = '$monthName ${now.year}';
    filterSubtitle.value =
        '01 $shortMonth ${now.year} — $lastDayStr $shortMonth ${now.year} (Month)';

    loadTimesheet(from: fromIso, to: toIso);
  }

  /// Quick Filter: Today (Single day punch history for current day)
  void applyToday() {
    HapticFeedback.selectionClick();
    activeDateRangeFilter.value = 'today';
    final now = DateTime.now();
    final todayIso = formatIsoDate(now);

    filterLabel.value = 'Today (${formatReadableDate(now)})';
    filterSubtitle.value = 'Daily punch records for today';

    loadTimesheet(from: todayIso, to: todayIso);
  }

  /// Quick Filter 2: Last Month (Dynamic previous calendar month)
  void applyLastMonth() {
    HapticFeedback.selectionClick();
    activeDateRangeFilter.value = 'last_month';
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1);
    selectedMonth.value = lastMonth;

    final start = DateTime(lastMonth.year, lastMonth.month, 1);
    final end = DateTime(lastMonth.year, lastMonth.month + 1, 0);

    final fromIso = formatIsoDate(start);
    final toIso = formatIsoDate(end);

    final monthName = monthNames[lastMonth.month - 1];
    final shortMonth = monthName.substring(0, 3);
    final lastDayStr = end.day.toString().padLeft(2, '0');

    filterLabel.value = '$monthName ${lastMonth.year}';
    filterSubtitle.value =
        '01 $shortMonth ${lastMonth.year} — $lastDayStr $shortMonth ${lastMonth.year} (Month)';

    loadTimesheet(from: fromIso, to: toIso);
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
