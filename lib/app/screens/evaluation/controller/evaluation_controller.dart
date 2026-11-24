import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../api/app_preferences.dart';
import '../../../core/services/permission_service.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../routes/app_routes.dart';
import '../model/evaluation_model.dart';
import '../repo/evaluation_repo.dart';

class EvaluationController extends GetxController {
  final EvaluationRepo repo;

  EvaluationController({required this.repo});

  // State Observables
  final RxBool isLoading = false.obs;
  final RxBool isDetailsLoading = false.obs;
  final RxBool isSubmitting = false.obs;

  /// Selected inbox box: 'mine' or 'to_review'
  final RxString selectedBox =
      (AppPreferences.isCompanyMode ? 'to_review' : 'mine').obs;

  bool get canViewPerformance =>
      AppPreferences.hasModule('performance') &&
      AppPreferences.hasPermission(AppPermissions.performanceView);
  bool get canManagePerformance =>
      AppPreferences.hasPermission(
        AppPermissions.performanceManage,
        AppPermissionScopes.department,
      );

  /// List of reviews for current box
  final RxList<EvaluationListItemModel> reviews =
      <EvaluationListItemModel>[].obs;

  /// Currently open / loaded evaluation details
  final Rxn<EvaluationDetailsModel> selectedReview =
      Rxn<EvaluationDetailsModel>();

  // Form State / Interactive User Inputs
  final Map<int, TextEditingController> textControllers = {};
  final RxMap<int, int?> selectedRatings = <int, int?>{}.obs;
  final RxMap<int, bool> isNaSelected = <int, bool>{}.obs;
  final RxMap<int, num?> numberValues = <int, num?>{}.obs;
  final RxMap<int, Map<String, List<num>>> figuresRows =
      <int, Map<String, List<num>>>{}.obs;

  // Goals Inputs
  final RxMap<String, int?> goalRatings = <String, int?>{}.obs;
  final Map<String, TextEditingController> goalCommentControllers = {};

  // Manager specific
  final TextEditingController managerSummaryController =
      TextEditingController();
  final RxnString selectedRecommendedAction = RxnString();

  // Acknowledgment
  final TextEditingController acknowledgeCommentController =
      TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _handleArguments();
    loadReviews();
  }

  void _handleArguments() {
    final args = Get.arguments;
    if (args is Map) {
      if (args['box'] != null && args['box'] is String) {
        selectedBox.value = args['box'] as String;
      }
      if (args['openId'] != null && args['openId'] is String) {
        final openId = args['openId'] as String;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          loadReviewDetails(openId);
        });
      }
    }
  }

  /// Loads reviews list for currently selected box ('mine' or 'to_review')
  Future<void> loadReviews({bool isRefresh = false}) async {
    if (!canViewPerformance) {
      reviews.clear();
      return;
    }
    try {
      isLoading.value = true;
      final result = await repo.fetchReviews(box: selectedBox.value);
      reviews.assignAll(result);
    } finally {
      isLoading.value = false;
    }
  }

  /// Switches inbox box between 'mine' and 'to_review'
  void switchBox(String box) {
    if (selectedBox.value == box && !isLoading.value) return;
    HapticFeedback.selectionClick();
    selectedBox.value = box;
    loadReviews();
  }

  /// Fetches details for a single evaluation and initializes draft inputs
  Future<void> loadReviewDetails(String id) async {
    try {
      isDetailsLoading.value = true;
      final details = await repo.fetchReviewDetails(id);
      if (details != null) {
        selectedReview.value = details;
        _populateInputsFromDetails(details);
      }
    } finally {
      isDetailsLoading.value = false;
    }
  }

  /// Navigates to Evaluation Details screen with target ID
  void openReviewDetails(String id) {
    HapticFeedback.lightImpact();
    loadReviewDetails(id);
    Get.toNamed(
      Routes.EVALUATION_DETAILS,
      arguments: {'evaluationId': id},
    );
  }

  /// Pre-fills input controllers and state from existing draft/submitted data
  void _populateInputsFromDetails(EvaluationDetailsModel details) {
    _clearQuestionInputs();

    final writesAs = details.viewer.writesAs;

    for (final section in details.sections) {
      for (final q in section.questions) {
        ReviewAnswerModel? existing = q.mine;
        if (existing == null) {
          if (writesAs == 'self') existing = q.selfAnswer;
          if (writesAs == 'manager') existing = q.managerAnswer;
        }

        final ctrl = TextEditingController(text: existing?.text ?? '');
        textControllers[q.id] = ctrl;

        selectedRatings[q.id] = existing?.rating;
        isNaSelected[q.id] = existing?.na ?? false;
        numberValues[q.id] = existing?.number;

        if (existing?.rows != null) {
          final mapped = <String, List<num>>{};
          existing!.rows!.forEach((key, val) {
            if (val is List) {
              mapped[key] = val.map((e) => (e as num?) ?? 0).toList();
            }
          });
          figuresRows[q.id] = mapped;
        }
      }
    }

    for (final goal in details.goals) {
      if (writesAs == 'manager') {
        goalRatings[goal.id] = goal.managerRating;
        goalCommentControllers[goal.id] =
            TextEditingController(text: goal.managerComment ?? '');
      } else {
        goalRatings[goal.id] = goal.selfRating;
        goalCommentControllers[goal.id] =
            TextEditingController(text: goal.selfComment ?? '');
      }
    }

    managerSummaryController.text = details.summary ?? '';
    selectedRecommendedAction.value = details.recommendedAction;
  }

  void _clearQuestionInputs() {
    for (final ctrl in textControllers.values) {
      ctrl.dispose();
    }
    textControllers.clear();
    selectedRatings.clear();
    isNaSelected.clear();
    numberValues.clear();
    figuresRows.clear();

    for (final ctrl in goalCommentControllers.values) {
      ctrl.dispose();
    }
    goalCommentControllers.clear();
    goalRatings.clear();
  }

  /// Updates or creates a figure cell value for a specific month and column
  void updateFigureCell({
    required int questionId,
    required String month,
    required int columnIndex,
    required int totalColumns,
    required num value,
  }) {
    final currentMap = Map<String, List<num>>.from(figuresRows[questionId] ?? {});
    final currentList = List<num>.from(
      currentMap[month] ?? List<num>.filled(totalColumns, 0),
    );

    if (columnIndex < currentList.length) {
      currentList[columnIndex] = value;
    } else {
      while (currentList.length <= columnIndex) {
        currentList.add(0);
      }
      currentList[columnIndex] = value;
    }

    currentMap[month] = currentList;
    figuresRows[questionId] = currentMap;
  }

  /// Validates all submission constraints from doc/api.md before POST /submit
  String? validateSubmission(EvaluationDetailsModel details) {
    final writesAs = details.viewer.writesAs;

    // 1. Every required question must be answered
    for (final section in details.sections) {
      for (final q in section.questions) {
        bool isMyTurn = false;
        if (writesAs == 'self' && q.selfAnswers) isMyTurn = true;
        if (writesAs == 'manager' && q.managerAnswers) isMyTurn = true;
        if (writesAs == 'peer' && q.peersAnswer) isMyTurn = true;

        if (!isMyTurn || !q.required) continue;

        if (q.kind == 'rating') {
          final isNa = isNaSelected[q.id] == true;
          final rating = selectedRatings[q.id];
          if (!isNa && rating == null) {
            return 'Please select a rating for "${q.text}".';
          }
        } else if (q.kind == 'text') {
          final txt = textControllers[q.id]?.text.trim();
          if (txt == null || txt.isEmpty) {
            return 'Please provide an answer for "${q.text}".';
          }
        } else if (q.kind == 'number') {
          if (numberValues[q.id] == null) {
            return 'Please enter a numeric value for "${q.text}".';
          }
        }
      }
    }

    // 2. Person and manager: every goal must be rated (if review has goals)
    if ((writesAs == 'self' || writesAs == 'manager') &&
        details.goals.isNotEmpty) {
      for (final goal in details.goals) {
        if (goalRatings[goal.id] == null) {
          return 'Please provide a rating for goal: "${goal.title}".';
        }
      }
    }

    // 3. Manager submission specific requirements
    if (writesAs == 'manager') {
      final summary = managerSummaryController.text.trim();
      if (summary.isEmpty) {
        return 'Manager summary is required before submission.';
      }
      if (details.recommendedActions.isNotEmpty &&
          selectedRecommendedAction.value == null) {
        return 'Please select a recommended action.';
      }
    }

    return null; // Validated successfully!
  }

  /// Builds request payload for PUT /answers or POST /submit
  Map<String, dynamic> _buildPayload(EvaluationDetailsModel details) {
    final writesAs = details.viewer.writesAs;

    final answers = <Map<String, dynamic>>[];
    for (final section in details.sections) {
      for (final q in section.questions) {
        bool shouldAnswer = false;
        if (writesAs == 'self' && q.selfAnswers) shouldAnswer = true;
        if (writesAs == 'manager' && q.managerAnswers) shouldAnswer = true;
        if (writesAs == 'peer' && q.peersAnswer) shouldAnswer = true;

        if (!shouldAnswer) continue;

        final item = <String, dynamic>{'question': q.id};

        if (q.kind == 'rating') {
          final isNa = isNaSelected[q.id] == true;
          if (isNa) {
            item['na'] = true;
          } else if (selectedRatings[q.id] != null) {
            item['rating'] = selectedRatings[q.id];
          }
          final text = textControllers[q.id]?.text.trim();
          if (text != null && text.isNotEmpty) {
            item['text'] = text;
          }
        } else if (q.kind == 'text') {
          item['text'] = textControllers[q.id]?.text.trim() ?? '';
        } else if (q.kind == 'number') {
          item['number'] = numberValues[q.id];
        } else if (q.kind == 'figures') {
          if (figuresRows[q.id] != null) {
            item['rows'] = figuresRows[q.id];
          }
        }

        answers.add(item);
      }
    }

    final goals = <Map<String, dynamic>>[];
    for (final g in details.goals) {
      final goalItem = <String, dynamic>{'id': g.id};
      if (goalRatings[g.id] != null) {
        goalItem['rating'] = goalRatings[g.id];
      }
      final comment = goalCommentControllers[g.id]?.text.trim();
      if (comment != null && comment.isNotEmpty) {
        goalItem['comment'] = comment;
      }
      goals.add(goalItem);
    }

    final payload = <String, dynamic>{
      'answers': answers,
      if (goals.isNotEmpty) 'goals': goals,
    };

    if (writesAs == 'manager') {
      final summary = managerSummaryController.text.trim();
      if (summary.isNotEmpty) payload['summary'] = summary;
      if (selectedRecommendedAction.value != null) {
        payload['recommended_action'] = selectedRecommendedAction.value;
      }
    }

    return payload;
  }

  /// Saves a draft of the current answers (PUT /performance/reviews/{id}/answers)
  Future<bool> saveDraft(String id) async {
    final details = selectedReview.value;
    if (details == null || isSubmitting.value) return false;

    if (details.viewer.writesAs == 'manager' && !canManagePerformance) {
      CustomSnackbar.showError(
        title: 'Access Denied',
        message: 'You do not have permission to submit manager evaluations.',
      );
      return false;
    }

    try {
      isSubmitting.value = true;
      final payload = _buildPayload(details);
      final updated = await repo.saveAnswers(id, payload);
      if (updated != null) {
        selectedReview.value = updated;
        _populateInputsFromDetails(updated);
        CustomSnackbar.showSuccess(
          title: 'Draft Saved',
          message: 'Your evaluation progress has been saved.',
        );
        return true;
      }
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Submits the final review answers (POST /performance/reviews/{id}/submit)
  Future<bool> submitReview(String id) async {
    final details = selectedReview.value;
    if (details == null || isSubmitting.value) return false;

    if (details.viewer.writesAs == 'manager' && !canManagePerformance) {
      CustomSnackbar.showError(
        title: 'Access Denied',
        message: 'You do not have permission to submit manager evaluations.',
      );
      return false;
    }

    // Pre-flight Client Validation Check
    final validationError = validateSubmission(details);
    if (validationError != null) {
      CustomSnackbar.showWarning(
        title: 'Required Field Missing',
        message: validationError,
      );
      return false;
    }

    try {
      isSubmitting.value = true;
      final payload = _buildPayload(details);
      final updated = await repo.submitReview(id, payload);
      if (updated != null) {
        selectedReview.value = updated;
        _populateInputsFromDetails(updated);
        loadReviews();
        CustomSnackbar.showSuccess(
          title: 'Submitted Successfully',
          message: 'Your evaluation submission has been finalized.',
        );
        return true;
      }
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Updates or replaces goals when can.edit_goals == true
  Future<bool> updateGoals(
    String id,
    List<Map<String, dynamic>> goalsList,
  ) async {
    if (isSubmitting.value) return false;

    try {
      isSubmitting.value = true;
      final updated = await repo.updateGoals(id, goalsList);
      if (updated != null) {
        selectedReview.value = updated;
        _populateInputsFromDetails(updated);
        CustomSnackbar.showSuccess(
          title: 'Goals Updated',
          message: 'Evaluation goals have been updated successfully.',
        );
        return true;
      }
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Manager asks colleagues for feedback (POST /performance/reviews/{id}/peers)
  Future<bool> invitePeers(String id, List<String> userIds) async {
    if (isSubmitting.value) return false;

    if (!PermissionService.verifyAction(
      AppPermissions.performanceManage,
      requiredScope: AppPermissionScopes.department,
      actionName: 'invite colleagues for peer reviews',
    )) {
      return false;
    }

    try {
      isSubmitting.value = true;
      final updated = await repo.invitePeers(id, userIds);
      if (updated != null) {
        selectedReview.value = updated;
        CustomSnackbar.showSuccess(
          title: 'Peers Invited',
          message: 'Colleagues have been invited for peer evaluation feedback.',
        );
        return true;
      }
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Acknowledges reading the final review (POST /performance/reviews/{id}/acknowledge)
  Future<bool> acknowledgeReview(String id) async {
    if (isSubmitting.value) return false;

    try {
      isSubmitting.value = true;
      final comment = acknowledgeCommentController.text.trim();
      final updated = await repo.acknowledgeReview(id, comment: comment);
      if (updated != null) {
        selectedReview.value = updated;
        loadReviews();
        CustomSnackbar.showSuccess(
          title: 'Evaluation Acknowledged',
          message: 'You have confirmed reading this evaluation appraisal.',
        );
        return true;
      }
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Declines peer feedback (POST /performance/reviews/{id}/decline)
  Future<bool> declineReview(String id) async {
    if (isSubmitting.value) return false;

    try {
      isSubmitting.value = true;
      final success = await repo.declineReview(id);
      if (success) {
        Get.back();
        loadReviews();
        CustomSnackbar.showInfo(
          title: 'Declined',
          message: 'You have declined the peer review request.',
        );
        return true;
      }
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    _clearQuestionInputs();
    managerSummaryController.dispose();
    acknowledgeCommentController.dispose();
    super.onClose();
  }
}
