import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../routes/app_routes.dart';
import '../model/company_dashboard_model.dart';
import '../repo/company_dashboard_repo.dart';

class CompanyDashboardController extends GetxController {
  final CompanyDashboardRepo repo;
  CompanyDashboardController({required this.repo});

  // Observables
  final RxBool isLoading = false.obs;
  final Rxn<CompanyDashboardModel> dashboard = Rxn<CompanyDashboardModel>();
  final RxString selectedActivityFilter = 'All'.obs;
  final RxnInt expandedActivityIndex = RxnInt();
  final RxnInt expandedLeaveIndex = RxnInt();

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  /// Toggles expandable item for activities
  void toggleActivityExpanded(int index) {
    HapticFeedback.selectionClick();
    if (expandedActivityIndex.value == index) {
      expandedActivityIndex.value = null;
    } else {
      expandedActivityIndex.value = index;
    }
  }

  /// Toggles expandable item for leaves
  void toggleLeaveExpanded(int index) {
    HapticFeedback.selectionClick();
    if (expandedLeaveIndex.value == index) {
      expandedLeaveIndex.value = null;
    } else {
      expandedLeaveIndex.value = index;
    }
  }

  /// Loads company dashboard telemetry with enforced try-finally loading guard
  Future<void> loadDashboard() async {
    try {
      isLoading.value = true;
      final result = await repo.fetchCompanyDashboard();
      if (result != null) {
        dashboard.value = result;
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Filtered activities
  List<CompanyRecentActivityModel> get filteredActivities {
    final list = dashboard.value?.recentActivities ?? [];
    if (selectedActivityFilter.value == 'All') return list;
    if (selectedActivityFilter.value == 'Check-In') {
      return list.where((a) => a.isCheckIn).toList();
    }
    return list.where((a) => !a.isCheckIn).toList();
  }

  /// Launches Employee Terminal scanner
  void launchAttendanceScanner() {
    HapticFeedback.mediumImpact();
    Get.toNamed(Routes.EMPLOYEE_TERMINAL);
  }
}
