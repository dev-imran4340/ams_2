import 'dart:async';

import '../../../api/exception_handler.dart';
import '../model/evaluation_model.dart';

class EvaluationRepo {
  final String _tag = 'EvaluationRepo / EvaluationScreen';

  final Map<String, EvaluationReportModel> _mockReports = {
    'Q3 2026': const EvaluationReportModel(
      cycleName: 'Q3 2026 Appraisal',
      overallRating: 4.8,
      ratingLabel: 'Top Tier Performer / Exceptional',
      evaluatedBy: 'Hamza Sheikh • Lead Mobile Architect',
      evaluationDate: 'Oct 01, 2026',
      appraisalStatus: 'Approved & Finalized',
      managerFeedback: 'Imran has demonstrated extraordinary technical leadership in Flutter architecture, zero-leak memory discipline, and consistent punctuality. Delivered biometric facial authentication and QR verification modules with exceptional enterprise-grade precision.',
      kpis: [
        KpiMetricItem(
          name: 'Code Quality & Architecture',
          score: 96.0,
          target: 100.0,
          weightage: '30% Weight',
          grade: 'A+',
        ),
        KpiMetricItem(
          name: 'Attendance & Punctuality',
          score: 98.5,
          target: 100.0,
          weightage: '25% Weight',
          grade: 'A+',
        ),
        KpiMetricItem(
          name: 'Sprint Deadline Adherence',
          score: 94.0,
          target: 100.0,
          weightage: '25% Weight',
          grade: 'A',
        ),
        KpiMetricItem(
          name: 'Cross-Functional Collaboration',
          score: 95.0,
          target: 100.0,
          weightage: '20% Weight',
          grade: 'A+',
        ),
      ],
    ),
    'Q2 2026': const EvaluationReportModel(
      cycleName: 'Q2 2026 Appraisal',
      overallRating: 4.6,
      ratingLabel: 'Exceeds Expectations',
      evaluatedBy: 'Hamza Sheikh • Lead Mobile Architect',
      evaluationDate: 'Jul 05, 2026',
      appraisalStatus: 'Approved & Finalized',
      managerFeedback: 'Solid deliverables across offline punch cache, multi-factor QR security scanning, and clean MVVM component abstractions with consistent response times.',
      kpis: [
        KpiMetricItem(
          name: 'Code Quality & Architecture',
          score: 92.0,
          target: 100.0,
          weightage: '30% Weight',
          grade: 'A',
        ),
        KpiMetricItem(
          name: 'Attendance & Punctuality',
          score: 95.0,
          target: 100.0,
          weightage: '25% Weight',
          grade: 'A',
        ),
        KpiMetricItem(
          name: 'Sprint Deadline Adherence',
          score: 91.0,
          target: 100.0,
          weightage: '25% Weight',
          grade: 'A',
        ),
        KpiMetricItem(
          name: 'Cross-Functional Collaboration',
          score: 90.0,
          target: 100.0,
          weightage: '20% Weight',
          grade: 'A',
        ),
      ],
    ),
    'Annual 2025': const EvaluationReportModel(
      cycleName: 'Annual 2025 Comprehensive',
      overallRating: 4.7,
      ratingLabel: 'Distinguished Contributor',
      evaluatedBy: 'Tariq Mahmood • VP of Engineering',
      evaluationDate: 'Jan 12, 2026',
      appraisalStatus: 'Approved & Finalized',
      managerFeedback: 'Annual review highlights consistent high velocity, zero regression rate on biometric core, and valuable technical mentorship across Softech Business Services engineering squads.',
      kpis: [
        KpiMetricItem(
          name: 'Code Quality & Architecture',
          score: 94.0,
          target: 100.0,
          weightage: '30% Weight',
          grade: 'A',
        ),
        KpiMetricItem(
          name: 'Attendance & Punctuality',
          score: 96.0,
          target: 100.0,
          weightage: '25% Weight',
          grade: 'A+',
        ),
        KpiMetricItem(
          name: 'Sprint Deadline Adherence',
          score: 93.0,
          target: 100.0,
          weightage: '25% Weight',
          grade: 'A',
        ),
        KpiMetricItem(
          name: 'Cross-Functional Collaboration',
          score: 92.0,
          target: 100.0,
          weightage: '20% Weight',
          grade: 'A',
        ),
      ],
    ),
  };

  /// Fetches performance appraisal report for a specific review cycle
  Future<EvaluationReportModel?> fetchEvaluationReport(String cycle) async {
    try {
      // Simulate enterprise backend network latency
      await Future.delayed(const Duration(milliseconds: 600));

      final report = _mockReports[cycle] ?? _mockReports['Q3 2026'];
      return report;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(
          message: 'Failed to fetch evaluation report for $cycle: $e',
        ),
        tag:
            '$_tag -> fetchEvaluationReport() [${stackTrace.toString().split('\n').first}]',
      );
      return null;
    }
  }
}
