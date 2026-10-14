import 'package:ams_2/app/screens/evaluation/controller/evaluation_controller.dart';
import 'package:ams_2/app/screens/evaluation/model/evaluation_model.dart';
import 'package:ams_2/app/screens/evaluation/repo/evaluation_repo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('KpiMetricItem & EvaluationReportModel Tests', () {
    test('KpiMetricItem serializes and deserializes correctly', () {
      const item = KpiMetricItem(
        name: 'Code Quality & Architecture',
        score: 96.0,
        target: 100.0,
        weightage: '30% Weight',
        grade: 'A+',
      );

      expect(item.progressRatio, 0.96);

      final json = item.toJson();
      expect(json['name'], 'Code Quality & Architecture');
      expect(json['score'], 96.0);
      expect(json['target'], 100.0);
      expect(json['weightage'], '30% Weight');
      expect(json['grade'], 'A+');

      final parsed = KpiMetricItem.fromJson(json);
      expect(parsed.name, item.name);
      expect(parsed.score, 96.0);
      expect(parsed.target, 100.0);
      expect(parsed.grade, 'A+');
    });

    test('EvaluationReportModel serializes and deserializes correctly', () {
      const report = EvaluationReportModel(
        cycleName: 'Q3 2026 Appraisal',
        overallRating: 4.8,
        ratingLabel: 'Top Tier Performer',
        evaluatedBy: 'Hamza Sheikh',
        evaluationDate: 'Oct 01, 2026',
        appraisalStatus: 'Approved & Finalized',
        managerFeedback: 'Exceptional architectural delivery.',
        kpis: [
          KpiMetricItem(
            name: 'Punctuality',
            score: 98.0,
            target: 100.0,
            weightage: '25% Weight',
            grade: 'A+',
          ),
        ],
      );

      final json = report.toJson();
      expect(json['cycle_name'], 'Q3 2026 Appraisal');
      expect(json['overall_rating'], 4.8);
      expect(json['kpis'], isA<List>());

      final parsed = EvaluationReportModel.fromJson(json);
      expect(parsed.cycleName, report.cycleName);
      expect(parsed.overallRating, 4.8);
      expect(parsed.kpis.length, 1);
      expect(parsed.kpis.first.name, 'Punctuality');
    });
  });

  group('EvaluationRepo Tests', () {
    late EvaluationRepo repo;

    setUp(() {
      repo = EvaluationRepo();
    });

    test('fetchEvaluationReport returns valid data for Q3 2026', () async {
      final report = await repo.fetchEvaluationReport('Q3 2026');
      expect(report, isNotNull);
      expect(report!.overallRating, 4.8);
      expect(report.kpis.length, 4);
      expect(report.cycleName.contains('Q3 2026'), true);
    });

    test('fetchEvaluationReport returns valid data for Q2 2026', () async {
      final report = await repo.fetchEvaluationReport('Q2 2026');
      expect(report, isNotNull);
      expect(report!.overallRating, 4.6);
      expect(report.kpis.length, 4);
      expect(report.cycleName.contains('Q2 2026'), true);
    });

    test('fetchEvaluationReport returns valid data for Annual 2025', () async {
      final report = await repo.fetchEvaluationReport('Annual 2025');
      expect(report, isNotNull);
      expect(report!.overallRating, 4.7);
      expect(report.kpis.length, 4);
      expect(report.cycleName.contains('Annual 2025'), true);
    });
  });

  group('EvaluationController Logic Tests', () {
    late EvaluationRepo repo;
    late EvaluationController controller;

    setUp(() {
      repo = EvaluationRepo();
      controller = EvaluationController(repo: repo);
      controller.onInit();
    });

    tearDown(() {
      controller.onClose();
    });

    test('loadEvaluationData updates reportData accurately', () async {
      await controller.loadEvaluationData('Q3 2026');
      expect(controller.reportData.value, isNotNull);
      expect(controller.reportData.value!.overallRating, 4.8);
      expect(controller.isLoading.value, false);
    });

    test('changeCycle switches quarter and reloads report', () async {
      controller.changeCycle('Q2 2026');
      expect(controller.selectedCycle.value, 'Q2 2026');

      await controller.loadEvaluationData('Q2 2026');
      expect(controller.reportData.value!.cycleName.contains('Q2 2026'), true);
      expect(controller.reportData.value!.overallRating, 4.6);
    });
  });
}
