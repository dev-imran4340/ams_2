import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../model/evaluation_model.dart';
import '../repo/evaluation_repo.dart';

class EvaluationController extends GetxController {
  final EvaluationRepo repo;

  EvaluationController({required this.repo});

  // Observables
  final RxBool isLoading = false.obs;
  final RxString selectedCycle = 'Q3 2026'.obs;
  final RxList<String> cycles = <String>[
    'Q3 2026',
    'Q2 2026',
    'Annual 2025',
  ].obs;
  final Rxn<EvaluationReportModel> reportData = Rxn<EvaluationReportModel>();

  @override
  void onInit() {
    super.onInit();
    loadEvaluationData(selectedCycle.value);
  }

  /// Loads evaluation report data for the selected quarter with try-finally standard
  Future<void> loadEvaluationData(String cycle) async {
    try {
      isLoading.value = true;
      final result = await repo.fetchEvaluationReport(cycle);
      if (result != null) {
        reportData.value = result;
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Switches active quarterly review cycle with haptic feedback
  void changeCycle(String cycle) {
    if (selectedCycle.value == cycle && !isLoading.value) return;
    HapticFeedback.selectionClick();
    selectedCycle.value = cycle;
    loadEvaluationData(cycle);
  }

  @override
  void onClose() {
    // Zero-memory-leak lifecycle contract
    super.onClose();
  }
}
