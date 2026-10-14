/// Single Key Performance Indicator (KPI) item
class KpiMetricItem {
  final String name;
  final double score;
  final double target;
  final String weightage;
  final String grade;

  const KpiMetricItem({
    required this.name,
    required this.score,
    required this.target,
    required this.weightage,
    required this.grade,
  });

  /// Computes completion percentage clamped to 0.0 - 1.0
  double get progressRatio => target > 0 ? (score / target).clamp(0.0, 1.0) : 0.0;

  KpiMetricItem copyWith({
    String? name,
    double? score,
    double? target,
    String? weightage,
    String? grade,
  }) {
    return KpiMetricItem(
      name: name ?? this.name,
      score: score ?? this.score,
      target: target ?? this.target,
      weightage: weightage ?? this.weightage,
      grade: grade ?? this.grade,
    );
  }

  factory KpiMetricItem.fromJson(Map<String, dynamic> json) {
    return KpiMetricItem(
      name: json['name']?.toString() ?? 'KPI Metric',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      target: (json['target'] as num?)?.toDouble() ?? 100.0,
      weightage: json['weightage']?.toString() ?? '25% Weight',
      grade: json['grade']?.toString() ?? 'A',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'score': score,
      'target': target,
      'weightage': weightage,
      'grade': grade,
    };
  }
}

/// Comprehensive Performance Evaluation & Appraisal Report Model
class EvaluationReportModel {
  final String cycleName;
  final double overallRating;
  final String ratingLabel;
  final String evaluatedBy;
  final String evaluationDate;
  final String appraisalStatus;
  final String managerFeedback;
  final List<KpiMetricItem> kpis;

  const EvaluationReportModel({
    required this.cycleName,
    required this.overallRating,
    required this.ratingLabel,
    required this.evaluatedBy,
    required this.evaluationDate,
    required this.appraisalStatus,
    required this.managerFeedback,
    required this.kpis,
  });

  EvaluationReportModel copyWith({
    String? cycleName,
    double? overallRating,
    String? ratingLabel,
    String? evaluatedBy,
    String? evaluationDate,
    String? appraisalStatus,
    String? managerFeedback,
    List<KpiMetricItem>? kpis,
  }) {
    return EvaluationReportModel(
      cycleName: cycleName ?? this.cycleName,
      overallRating: overallRating ?? this.overallRating,
      ratingLabel: ratingLabel ?? this.ratingLabel,
      evaluatedBy: evaluatedBy ?? this.evaluatedBy,
      evaluationDate: evaluationDate ?? this.evaluationDate,
      appraisalStatus: appraisalStatus ?? this.appraisalStatus,
      managerFeedback: managerFeedback ?? this.managerFeedback,
      kpis: kpis ?? this.kpis,
    );
  }

  factory EvaluationReportModel.fromJson(Map<String, dynamic> json) {
    return EvaluationReportModel(
      cycleName: json['cycle_name']?.toString() ?? 'Quarterly Appraisal',
      overallRating: (json['overall_rating'] as num?)?.toDouble() ?? 4.5,
      ratingLabel: json['rating_label']?.toString() ?? 'Top Performer',
      evaluatedBy: json['evaluated_by']?.toString() ?? 'Leadership',
      evaluationDate: json['evaluation_date']?.toString() ?? '',
      appraisalStatus: json['appraisal_status']?.toString() ?? 'Approved & Finalized',
      managerFeedback: json['manager_feedback']?.toString() ?? '',
      kpis: (json['kpis'] as List<dynamic>?)
              ?.map((item) => KpiMetricItem.fromJson(Map<String, dynamic>.from(item as Map)))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cycle_name': cycleName,
      'overall_rating': overallRating,
      'rating_label': ratingLabel,
      'evaluated_by': evaluatedBy,
      'evaluation_date': evaluationDate,
      'appraisal_status': appraisalStatus,
      'manager_feedback': managerFeedback,
      'kpis': kpis.map((kpi) => kpi.toJson()).toList(),
    };
  }
}
