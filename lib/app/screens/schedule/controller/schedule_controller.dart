import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/widgets/custom_snackbar.dart';
import '../model/schedule_model.dart';
import '../repo/schedule_repo.dart';

class ScheduleController extends GetxController {
  final ScheduleRepo repo;

  ScheduleController({required this.repo});

  // State Observables
  final RxBool isLoading = false.obs;
  final RxBool isLoadingHolidays = false.obs;
  final RxString errorMessage = ''.obs;
  final Rxn<ScheduleResponseModel> scheduleResponse = Rxn<ScheduleResponseModel>();
  final RxList<HolidayModel> holidays = <HolidayModel>[].obs;

  // Active Filter Observable ('all', 'working', 'rest', 'holidays')
  final RxString selectedFilter = 'all'.obs;

  // Active Date Range Filter ('14_days', '30_days', 'this_month')
  final RxString selectedRange = '14_days'.obs;
  final RxString fromDate = ''.obs;
  final RxString toDate = ''.obs;

  final RxInt activeYear = (DateTime.now().year).obs;
  final RxnString targetEmployeeId = RxnString();
  final RxString targetEmployeeName = ''.obs;

  final ScrollController scrollController = ScrollController();

  static String formatIsoDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
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

    applyRange('14_days');
    loadHolidays();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  /// Loads live schedule records from GET /me/schedule (or GET /employees/{id}/schedule)
  Future<void> loadSchedule({String? from, String? to}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      if (from != null) fromDate.value = from;
      if (to != null) toDate.value = to;

      final empId = targetEmployeeId.value;
      final ScheduleResponseModel? result;

      if (empId != null && empId.isNotEmpty) {
        // Manager / HR Scope
        result = await repo.fetchEmployeeSchedule(
          empId,
          from: fromDate.value.isNotEmpty ? fromDate.value : null,
          to: toDate.value.isNotEmpty ? toDate.value : null,
        );
      } else {
        // Authenticated Employee Self Rota
        result = await repo.fetchMySchedule(
          from: fromDate.value.isNotEmpty ? fromDate.value : null,
          to: toDate.value.isNotEmpty ? toDate.value : null,
        );
      }

      if (result != null) {
        scheduleResponse.value = result;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load schedule. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Loads public and company holidays via GET /holidays
  Future<void> loadHolidays({int? year}) async {
    try {
      isLoadingHolidays.value = true;
      final targetYr = year ?? activeYear.value;
      final result = await repo.fetchHolidays(year: targetYr);
      if (result != null) {
        holidays.assignAll(result.data);
        activeYear.value = result.year;
      }
    } finally {
      isLoadingHolidays.value = false;
    }
  }

  /// Changes active display filter ('all', 'working', 'rest', 'holidays')
  void setFilter(String filter) {
    if (selectedFilter.value == filter) return;
    HapticFeedback.selectionClick();
    selectedFilter.value = filter;
  }

  /// Quick Date Range selector with validation (max 62 days API constraint)
  void applyRange(String rangeKey) {
    HapticFeedback.selectionClick();
    selectedRange.value = rangeKey;

    final now = DateTime.now();

    switch (rangeKey) {
      case '14_days':
        // Next 14 days starting today
        final to = now.add(const Duration(days: 13));
        fromDate.value = formatIsoDate(now);
        toDate.value = formatIsoDate(to);
        break;
      case '30_days':
        // Next 30 days starting today
        final to = now.add(const Duration(days: 29));
        fromDate.value = formatIsoDate(now);
        toDate.value = formatIsoDate(to);
        break;
      case 'this_month':
        // 1st of month to last of month
        final firstDay = DateTime(now.year, now.month, 1);
        final lastDay = DateTime(now.year, now.month + 1, 0);
        fromDate.value = formatIsoDate(firstDay);
        toDate.value = formatIsoDate(lastDay);
        break;
    }

    loadSchedule(from: fromDate.value, to: toDate.value);
  }

  /// Custom Date Range Picker (guaranteed <= 62 days range)
  Future<void> pickCustomRange(BuildContext context) async {
    HapticFeedback.lightImpact();
    final now = DateTime.now();
    final first = DateTime(now.year - 1, 1, 1);
    final last = DateTime(now.year + 2, 12, 31);

    final initialRange = DateTimeRange(
      start: DateTime.tryParse(fromDate.value) ?? now,
      end: DateTime.tryParse(toDate.value) ?? now.add(const Duration(days: 13)),
    );

    final picked = await showDateRangePicker(
      context: context,
      firstDate: first,
      lastDate: last,
      initialDateRange: initialRange,
      helpText: 'SELECT SCHEDULE RANGE (MAX 62 DAYS)',
    );

    if (picked != null) {
      final daysDiff = picked.end.difference(picked.start).inDays + 1;
      if (daysDiff > 62) {
        CustomSnackbar.showWarning(
          message: 'Selected range is $daysDiff days. Server limits rota queries to 62 days max.',
        );
        return;
      }

      selectedRange.value = 'custom';
      fromDate.value = formatIsoDate(picked.start);
      toDate.value = formatIsoDate(picked.end);
      loadSchedule(from: fromDate.value, to: toDate.value);
    }
  }

  // Filtered days based on active tab
  List<ScheduleDayModel> get filteredDays {
    final list = scheduleResponse.value?.data ?? [];
    switch (selectedFilter.value) {
      case 'working':
        return list.where((e) => e.isWorkingDay).toList();
      case 'rest':
        return list.where((e) => e.isRestDay).toList();
      case 'holidays':
        return list.where((e) => e.isHoliday).toList();
      case 'all':
      default:
        return list;
    }
  }

  // Summary Metrics
  int get totalDaysCount => scheduleResponse.value?.data.length ?? 0;
  int get workingDaysCount =>
      scheduleResponse.value?.data.where((e) => e.isWorkingDay).length ?? 0;
  int get restDaysCount =>
      scheduleResponse.value?.data.where((e) => e.isRestDay).length ?? 0;
  int get holidaysCount =>
      scheduleResponse.value?.data.where((e) => e.isHoliday).length ?? 0;

  int get totalPlannedMinutes {
    final list = scheduleResponse.value?.data ?? [];
    return list.fold(0, (sum, item) => sum + item.plannedMinutes);
  }

  String get totalPlannedFormatted {
    final mins = totalPlannedMinutes;
    final h = mins ~/ 60;
    final m = mins % 60;
    return '${h}h ${m}m';
  }

  /// Next active upcoming working shift
  ScheduleDayModel? get nextUpcomingShift {
    final list = scheduleResponse.value?.data ?? [];
    final todayStr = formatIsoDate(DateTime.now());
    for (final day in list) {
      if (day.date.compareTo(todayStr) >= 0 && day.isWorkingDay && day.shift != null) {
        return day;
      }
    }
    return null;
  }
}
