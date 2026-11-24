import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../api/app_preferences.dart';
import '../../../core/services/permission_service.dart';
import '../model/training_model.dart';
import '../repo/training_repo.dart';
import '../view/components/training_details_bottom_sheet.dart';

class TrainingController extends GetxController {
  final TrainingRepo repo;

  TrainingController({required this.repo});

  // State Observables
  final RxBool isLoading = false.obs;
  final RxBool isAccessRestricted = false.obs;
  final RxString accessRestrictedMessage = ''.obs;

  bool get canViewTraining =>
      AppPreferences.hasPermission(AppPermissions.trainingView);
  bool get canManageTraining =>
      AppPreferences.hasPermission(AppPermissions.trainingManage);

  /// Main View Tab: 'Required' or 'Records' (matching backend JSON keys)
  final RxString selectedViewTab = 'Required'.obs;

  /// Active Telemetry Selection ID: 'required', 'compliant', 'pending', 'records'
  final RxString selectedTelemetryId = 'required'.obs;

  /// Records Filter: 'All', 'Attended', 'Passed', 'Failed'
  final RxString selectedRecordFilter = 'All'.obs;

  final RxList<TrainingRequiredModel> requiredCourses =
      <TrainingRequiredModel>[].obs;
  final RxList<TrainingRecordModel> records = <TrainingRecordModel>[].obs;

  final Rxn<TrainingRecordModel> selectedRecord = Rxn<TrainingRecordModel>();
  final Rxn<TrainingRequiredModel> selectedRequiredCourse =
      Rxn<TrainingRequiredModel>();

  final List<String> viewTabs = ['Required', 'Records'];
  final List<String> recordFilters = ['All', 'Attended', 'Passed', 'Failed'];

  // Telemetry Metrics
  int get totalRequired => requiredCourses.length;
  int get validCompliantCount => requiredCourses.where((c) => c.valid).length;
  int get pendingRequiredCount => requiredCourses.where((c) => !c.valid).length;
  int get totalRecordsCount => records.length;
  int get passedCount => records.where((r) => r.isPassed).length;

  /// Filtered list of required courses based on telemetry selection
  List<TrainingRequiredModel> get filteredRequiredCourses {
    switch (selectedTelemetryId.value) {
      case 'compliant':
        return requiredCourses.where((c) => c.valid).toList();
      case 'pending':
        return requiredCourses.where((c) => !c.valid).toList();
      case 'required':
      default:
        return requiredCourses;
    }
  }

  /// Filtered list of completed training records
  List<TrainingRecordModel> get filteredRecords {
    switch (selectedRecordFilter.value) {
      case 'Passed':
        return records.where((r) => r.isPassed).toList();
      case 'Attended':
        return records
            .where((r) => r.result.toLowerCase() == 'attended')
            .toList();
      case 'Failed':
        return records.where((r) => r.isFailed).toList();
      case 'All':
      default:
        return records;
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadTraining();
  }

  /// Loads training and certifications data from repository
  Future<void> loadTraining({bool isRefresh = false}) async {
    if (!canViewTraining) {
      isAccessRestricted.value = true;
      accessRestrictedMessage.value =
          'You do not have permission to view training records.';
      return;
    }
    isAccessRestricted.value = false;
    try {
      isLoading.value = true;
      final result = await repo.fetchTraining();
      if (result != null) {
        requiredCourses.assignAll(result.required);
        records.assignAll(result.records);
      }
    } finally {
      isLoading.value = false;
    }
  }

  void selectTelemetry(String id) {
    if (selectedTelemetryId.value == id) return;
    HapticFeedback.selectionClick();
    selectedTelemetryId.value = id;

    if (id == 'records') {
      selectedViewTab.value = 'Records';
    } else {
      selectedViewTab.value = 'Required';
    }
  }

  void setViewTab(String tab) {
    if (selectedViewTab.value == tab) return;
    HapticFeedback.selectionClick();
    selectedViewTab.value = tab;
    if (tab == 'Records') {
      selectedTelemetryId.value = 'records';
    } else {
      selectedTelemetryId.value = 'required';
    }
  }

  void setRecordFilter(String filter) {
    if (selectedRecordFilter.value == filter) return;
    HapticFeedback.selectionClick();
    selectedRecordFilter.value = filter;
  }

  void openRecordDetails(BuildContext context, TrainingRecordModel record) {
    HapticFeedback.lightImpact();
    selectedRecord.value = record;
    TrainingDetailsBottomSheet.showRecord(context, record: record);
  }

  void openCourseDetails(BuildContext context, TrainingRequiredModel item) {
    HapticFeedback.lightImpact();
    selectedRequiredCourse.value = item;
    TrainingDetailsBottomSheet.showCourse(context, item: item);
  }
}
