import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../index/controller/index_controller.dart';
import '../model/attendance_actions_model.dart';
import '../repo/attendance_actions_repo.dart';

class AttendanceActionsController extends GetxController {
  final AttendanceActionsRepo repo;

  AttendanceActionsController({required this.repo});

  // State Observables
  final RxBool isLoading = false.obs;
  final RxBool isPunching = false.obs;
  final RxBool isBreakActionLoading = false.obs;
  final RxBool isMoneyRequestSubmitting = false.obs;
  final RxBool isLoadingMoneyRequests = false.obs;

  final Rxn<EmployeeShiftTelemetry> telemetry = Rxn<EmployeeShiftTelemetry>();
  final RxList<MoneyRequestItem> moneyRequests = <MoneyRequestItem>[].obs;

  // Live Real-Time Device Clock
  final RxString liveClock = ''.obs;
  final RxString liveDate = ''.obs;
  Timer? _clockTimer;

  // Live Break Elapsed Timer
  final RxString elapsedBreakTimer = '00:00:00'.obs;
  final RxInt breakElapsedSeconds = 0.obs;
  Timer? _breakTicker;

  // Money Request Form Fields
  final selectedMoneyType = 'Salary Advance'.obs;
  final amountController = TextEditingController(text: '30000');
  final reasonController = TextEditingController();
  final selectedTenureMonths = 3.obs;

  final List<MoneyRequestTypeOption> moneyTypeOptions = const [
    MoneyRequestTypeOption(
      id: 'advance',
      title: 'Salary Advance',
      description: 'Quick advance from upcoming month salary',
      maxLimit: 50000.0,
    ),
    MoneyRequestTypeOption(
      id: 'personal',
      title: 'Personal Loan',
      description: 'Low-interest corporate assistance loan',
      maxLimit: 150000.0,
    ),
    MoneyRequestTypeOption(
      id: 'medical',
      title: 'Medical Emergency',
      description: 'Instant priority healthcare assistance',
      maxLimit: 100000.0,
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    _startLiveClock();
    loadShiftTelemetry();
    loadMoneyRequests();
  }

  @override
  void onClose() {
    _clockTimer?.cancel();
    _breakTicker?.cancel();
    amountController.dispose();
    reasonController.dispose();
    super.onClose();
  }

  /// Starts the 1-second interval device clock
  void _startLiveClock() {
    _updateClockDisplay();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateClockDisplay();
    });
  }

  void _updateClockDisplay() {
    final now = DateTime.now();

    // 12-hour clock format with AM/PM
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    final second = now.second.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    liveClock.value = '$hour:$minute:$second $period';

    // Formatted readable date
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
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
    final dayName = days[now.weekday - 1];
    final monthName = months[now.month - 1];
    liveDate.value = '$dayName, ${now.day} $monthName ${now.year}';
  }

  /// Loads full shift telemetry
  Future<void> loadShiftTelemetry() async {
    try {
      isLoading.value = true;
      final data = await repo.fetchShiftTelemetry();
      telemetry.value = data;
      if (data.isOnBreak) {
        _startBreakTimer();
      }
    } catch (e) {
      CustomSnackbar.showError(
        message: 'Could not load shift telemetry. Please retry.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Handles Check-In action
  Future<void> handleCheckIn() async {
    final current = telemetry.value;
    if (current == null) return;

    if (current.isCheckedIn) {
      CustomSnackbar.showWarning(
        message: 'You have already checked in for today at ${current.checkInTime}.',
      );
      return;
    }

    try {
      isPunching.value = true;
      HapticFeedback.mediumImpact();
      final updated = await repo.punchCheckIn(current);
      telemetry.value = updated;
      CustomSnackbar.showSuccess(
        title: 'Check-In Successful',
        message: 'Checked in at ${updated.checkInTime}. Have a productive day!',
      );
    } catch (e) {
      CustomSnackbar.showError(message: 'Check-in failed. Please try again.');
    } finally {
      isPunching.value = false;
    }
  }

  /// Handles Check-Out action
  Future<void> handleCheckOut() async {
    final current = telemetry.value;
    if (current == null) return;

    if (!current.isCheckedIn) {
      CustomSnackbar.showWarning(
        message: 'You must check-in before performing check-out.',
      );
      return;
    }

    if (current.isOnBreak) {
      CustomSnackbar.showWarning(
        message: 'Please end your active break before checking out.',
      );
      return;
    }

    try {
      isPunching.value = true;
      HapticFeedback.mediumImpact();
      final updated = await repo.punchCheckOut(current);
      telemetry.value = updated;
      CustomSnackbar.showSuccess(
        title: 'Check-Out Successful',
        message: 'Checked out at ${updated.checkOutTime}. Shift concluded.',
      );
    } catch (e) {
      CustomSnackbar.showError(message: 'Check-out failed. Please try again.');
    } finally {
      isPunching.value = false;
    }
  }

  /// Handles Start Break action
  Future<void> handleStartBreak() async {
    final current = telemetry.value;
    if (current == null) return;

    if (!current.isCheckedIn) {
      CustomSnackbar.showWarning(
        message: 'Check-in is required before starting a break.',
      );
      return;
    }

    if (current.isOnBreak) {
      CustomSnackbar.showWarning(
        message: 'Break is already in progress.',
      );
      return;
    }

    try {
      isBreakActionLoading.value = true;
      HapticFeedback.mediumImpact();
      final updated = await repo.startBreak(current);
      telemetry.value = updated;
      breakElapsedSeconds.value = 0;
      _startBreakTimer();

      CustomSnackbar.showSuccess(
        title: 'Break Started',
        message: 'Break started at ${updated.breakStartTime}. Enjoy your recess!',
      );
    } catch (e) {
      CustomSnackbar.showError(message: 'Could not start break. Please retry.');
    } finally {
      isBreakActionLoading.value = false;
    }
  }

  /// Handles End Break action
  Future<void> handleEndBreak() async {
    final current = telemetry.value;
    if (current == null) return;

    if (!current.isOnBreak) {
      CustomSnackbar.showWarning(
        message: 'No break is currently active to resume from.',
      );
      return;
    }

    try {
      isBreakActionLoading.value = true;
      HapticFeedback.mediumImpact();
      final updated = await repo.endBreak(current);
      telemetry.value = updated;
      _stopBreakTimer();

      CustomSnackbar.showSuccess(
        title: 'Break Concluded',
        message: 'Resumed shift. Total break time: ${updated.totalBreakDuration}.',
      );
    } catch (e) {
      CustomSnackbar.showError(message: 'Could not resume shift. Please retry.');
    } finally {
      isBreakActionLoading.value = false;
    }
  }

  void _startBreakTimer() {
    _breakTicker?.cancel();
    _breakTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      breakElapsedSeconds.value++;
      final totalSec = breakElapsedSeconds.value;
      final hours = (totalSec ~/ 3600).toString().padLeft(2, '0');
      final minutes = ((totalSec % 3600) ~/ 60).toString().padLeft(2, '0');
      final seconds = (totalSec % 60).toString().padLeft(2, '0');
      elapsedBreakTimer.value = '$hours:$minutes:$seconds';
    });
  }

  void _stopBreakTimer() {
    _breakTicker?.cancel();
    breakElapsedSeconds.value = 0;
    elapsedBreakTimer.value = '00:00:00';
  }

  /// Toggle remote vs on-site work simulation
  void toggleWorkMode() {
    final current = telemetry.value;
    if (current == null) return;

    HapticFeedback.selectionClick();
    final newIsRemote = !current.isRemote;
    telemetry.value = current.copyWith(
      isRemote: newIsRemote,
      workMode: newIsRemote ? 'Remote' : 'On-Site',
      officeRadiusStatus: newIsRemote
          ? 'Remote Work Mode Active'
          : 'Inside Office Perimeter (25m)',
      isInsidePerimeter: !newIsRemote,
    );

    CustomSnackbar.showInfo(
      message: 'Active mode: ${newIsRemote ? 'Remote (Home / Field)' : 'On-Site (Office Perimeter)'}',
    );
  }

  /// Loads list of money requests
  Future<void> loadMoneyRequests() async {
    try {
      isLoadingMoneyRequests.value = true;
      final list = await repo.fetchMoneyRequests();
      moneyRequests.assignAll(list);
    } catch (e) {
      // Quiet fallback
    } finally {
      isLoadingMoneyRequests.value = false;
    }
  }

  /// Submits a new money request
  Future<bool> submitMoneyRequest() async {
    final amountText = amountController.text.trim();
    final reasonText = reasonController.text.trim();

    final parsedAmount = double.tryParse(amountText);
    if (parsedAmount == null || parsedAmount <= 0) {
      CustomSnackbar.showWarning(message: 'Please enter a valid amount.');
      return false;
    }

    if (reasonText.isEmpty) {
      CustomSnackbar.showWarning(message: 'Please provide a brief reason.');
      return false;
    }

    try {
      isMoneyRequestSubmitting.value = true;
      HapticFeedback.mediumImpact();
      final newItem = await repo.submitMoneyRequest(
        type: selectedMoneyType.value,
        amount: parsedAmount,
        tenureMonths: selectedTenureMonths.value,
        reason: reasonText,
      );

      moneyRequests.insert(0, newItem);
      reasonController.clear();

      CustomSnackbar.showSuccess(
        title: 'Request Submitted',
        message: 'Your ${newItem.type} request #${newItem.id} has been logged.',
      );
      return true;
    } catch (e) {
      CustomSnackbar.showError(message: 'Failed to submit request. Please retry.');
      return false;
    } finally {
      isMoneyRequestSubmitting.value = false;
    }
  }

  // Navigation shortcuts
  void navigateToLeaveRequests() {
    if (Get.isRegistered<IndexController>()) {
      Get.find<IndexController>().changeTab(2);
      Get.back();
    } else {
      Get.toNamed(Routes.INDEX);
    }
  }

  void navigateToEvaluation() {
    Get.toNamed(Routes.EVALUATION);
  }

  void navigateToEmployeeCard() {
    Get.toNamed(Routes.EMPLOYEE_CARD);
  }

  void navigateToTasks() {
    Get.toNamed(Routes.TASKS);
  }
}
