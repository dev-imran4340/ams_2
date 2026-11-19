import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../model/checklist_model.dart';
import '../repo/checklist_repo.dart';
import '../view/components/checklist_details_bottom_sheet.dart';

class ChecklistController extends GetxController {
  final ChecklistRepo repo;

  ChecklistController({required this.repo});

  // State Observables
  final RxBool isLoading = false.obs;

  /// ScrollController to track dynamic background contrast changes
  final ScrollController scrollController = ScrollController();
  final RxDouble scrollOffset = 0.0.obs;

  /// Filter: 'all', 'onboarding', 'offboarding', 'completed'
  final RxString selectedFilter = 'all'.obs;

  final RxList<ChecklistModel> checklists = <ChecklistModel>[].obs;
  final Rxn<ChecklistModel> selectedChecklist = Rxn<ChecklistModel>();

  // Telemetry counts
  int get totalCount => checklists.length;
  int get onboardingCount => checklists.where((c) => c.isOnboarding).length;
  int get offboardingCount => checklists.where((c) => c.isOffboarding).length;
  int get completedCount => checklists.where((c) => c.isCompleted).length;

  /// Filtered list of checklists based on selected telemetry filter
  List<ChecklistModel> get filteredChecklists {
    switch (selectedFilter.value.toLowerCase()) {
      case 'onboarding':
        return checklists.where((c) => c.isOnboarding).toList();
      case 'offboarding':
        return checklists.where((c) => c.isOffboarding).toList();
      case 'completed':
        return checklists.where((c) => c.isCompleted).toList();
      case 'all':
      default:
        return checklists;
    }
  }

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    loadChecklists();
  }

  void _onScroll() {
    if (scrollController.hasClients) {
      scrollOffset.value = scrollController.offset;
    }
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

  /// Loads onboarding and offboarding checklists from repository
  Future<void> loadChecklists({bool isRefresh = false}) async {
    try {
      isLoading.value = true;
      final result = await repo.fetchChecklists();
      if (result != null) {
        checklists.assignAll(result);
      }
    } finally {
      isLoading.value = false;
    }
  }

  void setFilter(String filter) {
    if (selectedFilter.value == filter) return;
    HapticFeedback.selectionClick();
    selectedFilter.value = filter;
  }

  void openChecklistDetails(BuildContext context, ChecklistModel item) {
    HapticFeedback.lightImpact();
    selectedChecklist.value = item;
    ChecklistDetailsBottomSheet.show(context, checklist: item);
  }
}
