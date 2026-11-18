import 'dart:convert';

/// Single item in the Performance Reviews list (/performance/reviews?box=mine|to_review)
class PerformanceReviewListItemModel {
  final String id;
  final String cycle;
  final String kind;
  final ReviewEmployeeModel employee;
  final String? reviewer;
  final String status;
  final String statusLabel;
  final String tone;
  final String? selfDueOn;
  final String? managerDueOn;
  final ReviewResultModel? result;

  const PerformanceReviewListItemModel({
    required this.id,
    required this.cycle,
    required this.kind,
    required this.employee,
    this.reviewer,
    required this.status,
    required this.statusLabel,
    this.tone = 'brand',
    this.selfDueOn,
    this.managerDueOn,
    this.result,
  });

  factory PerformanceReviewListItemModel.fromJson(Map<String, dynamic> json) {
    return PerformanceReviewListItemModel(
      id: json['id']?.toString() ?? '',
      cycle: json['cycle']?.toString() ?? '',
      kind: json['kind']?.toString() ?? 'regular',
      employee: json['employee'] is Map<String, dynamic>
          ? ReviewEmployeeModel.fromJson(json['employee'] as Map<String, dynamic>)
          : const ReviewEmployeeModel(id: '', name: 'N/A', number: ''),
      reviewer: json['reviewer']?.toString(),
      status: json['status']?.toString() ?? '',
      statusLabel: json['status_label']?.toString() ?? 'In Progress',
      tone: json['tone']?.toString() ?? 'brand',
      selfDueOn: json['self_due_on']?.toString(),
      managerDueOn: json['manager_due_on']?.toString(),
      result: json['result'] is Map<String, dynamic>
          ? ReviewResultModel.fromJson(json['result'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cycle': cycle,
      'kind': kind,
      'employee': employee.toJson(),
      'reviewer': reviewer,
      'status': status,
      'status_label': statusLabel,
      'tone': tone,
      'self_due_on': selfDueOn,
      'manager_due_on': managerDueOn,
      'result': result?.toJson(),
    };
  }
}

/// Full Details for a Single Performance Review (/performance/reviews/{id})
class PerformanceReviewDetailsModel {
  final String id;
  final ReviewCycleModel cycle;
  final String kind;
  final ReviewEmployeeModel employee;
  final String? reviewer;
  final String status;
  final String statusLabel;
  final String tone;
  final String? selfDueOn;
  final String? managerDueOn;
  final ReviewResultModel? result;
  final String? probationEndsOn;
  final ReviewViewerModel viewer;
  final ReviewCanModel can;
  final ReviewScaleModel? scale;
  final List<String> months;
  final List<ReviewSectionModel> sections;
  final List<ReviewGoalModel> goals;
  final List<dynamic> peers;
  final String? summary;
  final String? recommendedAction;
  final String? recommendedActionLabel;
  final Map<String, String> recommendedActions;
  final bool isProbation;
  final String? acknowledgedAt;
  final String? acknowledgementComment;
  final String? cancelReason;

  const PerformanceReviewDetailsModel({
    required this.id,
    required this.cycle,
    required this.kind,
    required this.employee,
    this.reviewer,
    required this.status,
    required this.statusLabel,
    this.tone = 'brand',
    this.selfDueOn,
    this.managerDueOn,
    this.result,
    this.probationEndsOn,
    required this.viewer,
    required this.can,
    this.scale,
    this.months = const [],
    this.sections = const [],
    this.goals = const [],
    this.peers = const [],
    this.summary,
    this.recommendedAction,
    this.recommendedActionLabel,
    this.recommendedActions = const {},
    this.isProbation = false,
    this.acknowledgedAt,
    this.acknowledgementComment,
    this.cancelReason,
  });

  factory PerformanceReviewDetailsModel.fromJson(Map<String, dynamic> json) {
    // Parse recommended actions map
    final recActionsMap = <String, String>{};
    if (json['recommended_actions'] is Map) {
      (json['recommended_actions'] as Map).forEach((k, v) {
        if (k != null && v != null) {
          recActionsMap[k.toString()] = v.toString();
        }
      });
    }

    // Parse months list
    final monthsList = <String>[];
    if (json['months'] is List) {
      for (final m in json['months'] as List) {
        if (m != null) monthsList.add(m.toString());
      }
    }

    // Parse sections
    final sectionsList = <ReviewSectionModel>[];
    if (json['sections'] is List) {
      for (final s in json['sections'] as List) {
        if (s is Map<String, dynamic>) {
          sectionsList.add(ReviewSectionModel.fromJson(s));
        }
      }
    }

    // Parse goals
    final goalsList = <ReviewGoalModel>[];
    if (json['goals'] is List) {
      for (final g in json['goals'] as List) {
        if (g is Map<String, dynamic>) {
          goalsList.add(ReviewGoalModel.fromJson(g));
        }
      }
    }

    return PerformanceReviewDetailsModel(
      id: json['id']?.toString() ?? '',
      cycle: json['cycle'] is Map<String, dynamic>
          ? ReviewCycleModel.fromJson(json['cycle'] as Map<String, dynamic>)
          : ReviewCycleModel(
              id: '',
              name: json['cycle']?.toString() ?? 'Performance Evaluation',
            ),
      kind: json['kind']?.toString() ?? 'regular',
      employee: json['employee'] is Map<String, dynamic>
          ? ReviewEmployeeModel.fromJson(json['employee'] as Map<String, dynamic>)
          : const ReviewEmployeeModel(id: '', name: 'N/A', number: ''),
      reviewer: json['reviewer']?.toString(),
      status: json['status']?.toString() ?? '',
      statusLabel: json['status_label']?.toString() ?? 'In Progress',
      tone: json['tone']?.toString() ?? 'brand',
      selfDueOn: json['self_due_on']?.toString(),
      managerDueOn: json['manager_due_on']?.toString(),
      result: json['result'] is Map<String, dynamic>
          ? ReviewResultModel.fromJson(json['result'] as Map<String, dynamic>)
          : null,
      probationEndsOn: json['probation_ends_on']?.toString(),
      viewer: json['viewer'] is Map<String, dynamic>
          ? ReviewViewerModel.fromJson(json['viewer'] as Map<String, dynamic>)
          : const ReviewViewerModel(),
      can: json['can'] is Map<String, dynamic>
          ? ReviewCanModel.fromJson(json['can'] as Map<String, dynamic>)
          : const ReviewCanModel(),
      scale: json['scale'] is Map<String, dynamic>
          ? ReviewScaleModel.fromJson(json['scale'] as Map<String, dynamic>)
          : null,
      months: monthsList,
      sections: sectionsList,
      goals: goalsList,
      peers: json['peers'] is List ? (json['peers'] as List) : const [],
      summary: json['summary']?.toString(),
      recommendedAction: json['recommended_action']?.toString(),
      recommendedActionLabel: json['recommended_action_label']?.toString(),
      recommendedActions: recActionsMap,
      isProbation: json['is_probation'] == true,
      acknowledgedAt: json['acknowledged_at']?.toString(),
      acknowledgementComment: json['acknowledgement_comment']?.toString(),
      cancelReason: json['cancel_reason']?.toString(),
    );
  }
}

/// Cycle metadata
class ReviewCycleModel {
  final String id;
  final String name;
  final String kind;
  final String kindLabel;
  final String? periodFrom;
  final String? periodTo;

  const ReviewCycleModel({
    required this.id,
    required this.name,
    this.kind = 'regular',
    this.kindLabel = 'Review cycle',
    this.periodFrom,
    this.periodTo,
  });

  factory ReviewCycleModel.fromJson(Map<String, dynamic> json) {
    return ReviewCycleModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      kind: json['kind']?.toString() ?? 'regular',
      kindLabel: json['kind_label']?.toString() ?? 'Review cycle',
      periodFrom: json['period_from']?.toString(),
      periodTo: json['period_to']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'kind': kind,
      'kind_label': kindLabel,
      'period_from': periodFrom,
      'period_to': periodTo,
    };
  }
}

/// Employee associated with the review
class ReviewEmployeeModel {
  final String id;
  final String name;
  final String number;
  final String? department;
  final String? designation;

  const ReviewEmployeeModel({
    required this.id,
    required this.name,
    required this.number,
    this.department,
    this.designation,
  });

  factory ReviewEmployeeModel.fromJson(Map<String, dynamic> json) {
    return ReviewEmployeeModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      number: json['number']?.toString() ?? '',
      department: json['department']?.toString(),
      designation: json['designation']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'number': number,
      'department': department,
      'designation': designation,
    };
  }
}

/// Context of the current viewer
class ReviewViewerModel {
  final bool isSelf;
  final bool isReviewer;
  final bool isPeer;
  final String? writesAs; // 'self', 'manager', 'peer', or null

  const ReviewViewerModel({
    this.isSelf = false,
    this.isReviewer = false,
    this.isPeer = false,
    this.writesAs,
  });

  factory ReviewViewerModel.fromJson(Map<String, dynamic> json) {
    return ReviewViewerModel(
      isSelf: json['is_self'] == true,
      isReviewer: json['is_reviewer'] == true,
      isPeer: json['is_peer'] == true,
      writesAs: json['writes_as']?.toString(),
    );
  }
}

/// Permissions of what the user can do right now
class ReviewCanModel {
  final bool save;
  final bool submit;
  final bool editGoals;
  final bool askPeers;
  final bool decline;
  final bool acknowledge;
  final bool calibrate;
  final bool reopen;
  final bool reassign;
  final bool cancel;

  const ReviewCanModel({
    this.save = false,
    this.submit = false,
    this.editGoals = false,
    this.askPeers = false,
    this.decline = false,
    this.acknowledge = false,
    this.calibrate = false,
    this.reopen = false,
    this.reassign = false,
    this.cancel = false,
  });

  factory ReviewCanModel.fromJson(Map<String, dynamic> json) {
    return ReviewCanModel(
      save: json['save'] == true,
      submit: json['submit'] == true,
      editGoals: json['edit_goals'] == true,
      askPeers: json['ask_peers'] == true,
      decline: json['decline'] == true,
      acknowledge: json['acknowledge'] == true,
      calibrate: json['calibrate'] == true,
      reopen: json['reopen'] == true,
      reassign: json['reassign'] == true,
      cancel: json['cancel'] == true,
    );
  }
}

/// Rating scale configuration
class ReviewScaleModel {
  final bool allowsNa;
  final List<ReviewScaleLevelModel> levels;

  const ReviewScaleModel({
    this.allowsNa = true,
    this.levels = const [],
  });

  factory ReviewScaleModel.fromJson(Map<String, dynamic> json) {
    final levelsList = <ReviewScaleLevelModel>[];
    if (json['levels'] is List) {
      for (final lvl in json['levels'] as List) {
        if (lvl is Map<String, dynamic>) {
          levelsList.add(ReviewScaleLevelModel.fromJson(lvl));
        }
      }
    }
    return ReviewScaleModel(
      allowsNa: json['allows_na'] == true,
      levels: levelsList,
    );
  }
}

/// Individual rating level (e.g. 1 to 5)
class ReviewScaleLevelModel {
  final int value;
  final String label;
  final String description;

  const ReviewScaleLevelModel({
    required this.value,
    required this.label,
    required this.description,
  });

  factory ReviewScaleLevelModel.fromJson(Map<String, dynamic> json) {
    return ReviewScaleLevelModel(
      value: (json['value'] as num?)?.toInt() ?? 0,
      label: json['label']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }
}

/// Section inside a review (e.g. Competencies, Work delivered, Manager questions)
class ReviewSectionModel {
  final int id;
  final String title;
  final String kind;
  final String weight;
  final List<ReviewQuestionModel> questions;

  const ReviewSectionModel({
    required this.id,
    required this.title,
    required this.kind,
    required this.weight,
    this.questions = const [],
  });

  factory ReviewSectionModel.fromJson(Map<String, dynamic> json) {
    final questionsList = <ReviewQuestionModel>[];
    if (json['questions'] is List) {
      for (final q in json['questions'] as List) {
        if (q is Map<String, dynamic>) {
          questionsList.add(ReviewQuestionModel.fromJson(q));
        }
      }
    }
    return ReviewSectionModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      kind: json['kind']?.toString() ?? 'questions',
      weight: json['weight']?.toString() ?? '0',
      questions: questionsList,
    );
  }
}

/// Individual question inside a review section
class ReviewQuestionModel {
  final int id;
  final String text;
  final String? help;
  final String kind; // 'rating', 'text', 'number', 'figures'
  final bool selfAnswers;
  final bool managerAnswers;
  final bool peersAnswer;
  final bool required;
  final List<String> columns;
  final ReviewAnswerModel? mine;
  final ReviewAnswerModel? selfAnswer;
  final ReviewAnswerModel? managerAnswer;
  final List<ReviewAnswerModel> peers;
  final dynamic reportedTotals;

  const ReviewQuestionModel({
    required this.id,
    required this.text,
    this.help,
    required this.kind,
    this.selfAnswers = false,
    this.managerAnswers = false,
    this.peersAnswer = false,
    this.required = false,
    this.columns = const [],
    this.mine,
    this.selfAnswer,
    this.managerAnswer,
    this.peers = const [],
    this.reportedTotals,
  });

  factory ReviewQuestionModel.fromJson(Map<String, dynamic> json) {
    final cols = <String>[];
    if (json['columns'] is List) {
      for (final c in json['columns'] as List) {
        if (c != null) cols.add(c.toString());
      }
    }

    final peersList = <ReviewAnswerModel>[];
    if (json['peers'] is List) {
      for (final p in json['peers'] as List) {
        if (p is Map<String, dynamic>) {
          peersList.add(ReviewAnswerModel.fromJson(p));
        }
      }
    }

    return ReviewQuestionModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      text: json['text']?.toString() ?? '',
      help: json['help']?.toString(),
      kind: json['kind']?.toString() ?? 'text',
      selfAnswers: json['self_answers'] == true,
      managerAnswers: json['manager_answers'] == true,
      peersAnswer: json['peers_answer'] == true,
      required: json['required'] == true,
      columns: cols,
      mine: json['mine'] is Map<String, dynamic>
          ? ReviewAnswerModel.fromJson(json['mine'] as Map<String, dynamic>)
          : null,
      selfAnswer: json['self'] is Map<String, dynamic>
          ? ReviewAnswerModel.fromJson(json['self'] as Map<String, dynamic>)
          : null,
      managerAnswer: json['manager'] is Map<String, dynamic>
          ? ReviewAnswerModel.fromJson(json['manager'] as Map<String, dynamic>)
          : null,
      peers: peersList,
      reportedTotals: json['reported_totals'],
    );
  }
}

/// Answer object (mine, self, manager, peer)
class ReviewAnswerModel {
  final int? rating;
  final String? ratingLabel;
  final bool na;
  final String? text;
  final num? number;
  final Map<String, dynamic>? rows;
  final List<dynamic>? verified;
  final String? from;

  const ReviewAnswerModel({
    this.rating,
    this.ratingLabel,
    this.na = false,
    this.text,
    this.number,
    this.rows,
    this.verified,
    this.from,
  });

  factory ReviewAnswerModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? parsedRows;
    if (json['rows'] is Map<String, dynamic>) {
      parsedRows = json['rows'] as Map<String, dynamic>;
    } else if (json['text'] is String) {
      // In some configurations, figures rows or text matrices may be serialized as text
      final raw = json['text'] as String;
      if (raw.startsWith('{') && raw.endsWith('}')) {
        try {
          parsedRows = jsonDecode(raw) as Map<String, dynamic>;
        } catch (_) {}
      }
    }

    return ReviewAnswerModel(
      rating: (json['rating'] as num?)?.toInt(),
      ratingLabel: json['rating_label']?.toString(),
      na: json['na'] == true,
      text: json['text']?.toString(),
      number: json['number'] as num?,
      rows: parsedRows,
      verified: json['verified'] is List ? (json['verified'] as List) : null,
      from: json['from']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'rating_label': ratingLabel,
      'na': na,
      'text': text,
      'number': number,
      'rows': rows,
      'verified': verified,
      if (from != null) 'from': from,
    };
  }
}

/// Goal entity inside a review
class ReviewGoalModel {
  final String id;
  final String title;
  final String? measure;
  final String weight;
  final int? selfRating;
  final String? selfComment;
  final int? managerRating;
  final String? managerComment;

  const ReviewGoalModel({
    required this.id,
    required this.title,
    this.measure,
    required this.weight,
    this.selfRating,
    this.selfComment,
    this.managerRating,
    this.managerComment,
  });

  factory ReviewGoalModel.fromJson(Map<String, dynamic> json) {
    return ReviewGoalModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      measure: json['measure']?.toString(),
      weight: json['weight']?.toString() ?? '0',
      selfRating: (json['self_rating'] as num?)?.toInt(),
      selfComment: json['self_comment']?.toString(),
      managerRating: (json['manager_rating'] as num?)?.toInt(),
      managerComment: json['manager_comment']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'measure': measure,
      'weight': weight,
      'self_rating': selfRating,
      'self_comment': selfComment,
      'manager_rating': managerRating,
      'manager_comment': managerComment,
    };
  }
}

/// Final evaluation result score and level
class ReviewResultModel {
  final bool live;
  final num? score;
  final String? scoreText;
  final int? level;
  final String? levelLabel;
  final String? calculatedLevelLabel;
  final bool calibrated;
  final String? calibrationReason;
  final Map<String, dynamic>? sections;

  const ReviewResultModel({
    this.live = false,
    this.score,
    this.scoreText,
    this.level,
    this.levelLabel,
    this.calculatedLevelLabel,
    this.calibrated = false,
    this.calibrationReason,
    this.sections,
  });

  factory ReviewResultModel.fromJson(Map<String, dynamic> json) {
    return ReviewResultModel(
      live: json['live'] == true,
      score: json['score'] as num?,
      scoreText: json['score_text']?.toString(),
      level: (json['level'] as num?)?.toInt(),
      levelLabel: json['level_label']?.toString(),
      calculatedLevelLabel: json['calculated_level_label']?.toString(),
      calibrated: json['calibrated'] == true,
      calibrationReason: json['calibration_reason']?.toString(),
      sections: json['sections'] is Map<String, dynamic>
          ? json['sections'] as Map<String, dynamic>
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'live': live,
      'score': score,
      'score_text': scoreText,
      'level': level,
      'level_label': levelLabel,
      'calculated_level_label': calculatedLevelLabel,
      'calibrated': calibrated,
      'calibration_reason': calibrationReason,
      'sections': sections,
    };
  }
}

// -------------------------------------------------------------
// Aliases for Evaluation Domain Naming Consistency
// -------------------------------------------------------------
typedef EvaluationListItemModel = PerformanceReviewListItemModel;
typedef EvaluationDetailsModel = PerformanceReviewDetailsModel;
typedef EvaluationCycleModel = ReviewCycleModel;
typedef EvaluationEmployeeModel = ReviewEmployeeModel;
typedef EvaluationViewerModel = ReviewViewerModel;
typedef EvaluationCanModel = ReviewCanModel;
typedef EvaluationScaleModel = ReviewScaleModel;
typedef EvaluationScaleLevelModel = ReviewScaleLevelModel;
typedef EvaluationSectionModel = ReviewSectionModel;
typedef EvaluationQuestionModel = ReviewQuestionModel;
typedef EvaluationAnswerModel = ReviewAnswerModel;
typedef EvaluationGoalModel = ReviewGoalModel;
typedef EvaluationResultModel = ReviewResultModel;

