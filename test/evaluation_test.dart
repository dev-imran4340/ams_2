import 'package:ams_2/app/screens/evaluation/model/evaluation_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Performance Review Models Tests', () {
    test('PerformanceReviewListItemModel serializes and deserializes correctly', () {
      final json = {
        'id': '01m6n2y0mnf18z15tk5xbsschp',
        'cycle': 'Development Team Evaluation 2025–26',
        'kind': 'regular',
        'employee': {
          'id': '01m6jjx5amjtx5v4wcc3fgkest',
          'name': 'Malik Muhammad Imran',
          'number': '554',
        },
        'reviewer': 'Malik Saddique Ahmed',
        'status': 'manager_review',
        'status_label': 'Manager review',
        'tone': 'brand',
        'self_due_on': null,
        'manager_due_on': '2026-11-15',
        'result': null,
      };

      final item = PerformanceReviewListItemModel.fromJson(json);

      expect(item.id, '01m6n2y0mnf18z15tk5xbsschp');
      expect(item.cycle, 'Development Team Evaluation 2025–26');
      expect(item.employee.name, 'Malik Muhammad Imran');
      expect(item.employee.number, '554');
      expect(item.reviewer, 'Malik Saddique Ahmed');
      expect(item.status, 'manager_review');
      expect(item.statusLabel, 'Manager review');
      expect(item.tone, 'brand');
      expect(item.managerDueOn, '2026-11-15');
      expect(item.result, isNull);
    });

    test('PerformanceReviewDetailsModel serializes and deserializes questions correctly', () {
      final json = {
        'id': '01m6n2y0mnf18z15tk5xbsschp',
        'cycle': {
          'id': '01m6n2y0jr841nf7q2vmf9en1e',
          'name': 'Development Team Evaluation 2025–26',
          'kind': 'regular',
          'kind_label': 'Review cycle',
          'period_from': '2025-11-01',
          'period_to': '2026-10-31',
        },
        'kind': 'regular',
        'employee': {
          'id': '01m6jjx5amjtx5v4wcc3fgkest',
          'name': 'Malik Muhammad Imran',
          'number': '554',
          'department': 'Development',
          'designation': 'Flutter Developer',
        },
        'reviewer': 'Malik Saddique Ahmed',
        'status': 'manager_review',
        'status_label': 'Manager review',
        'tone': 'brand',
        'viewer': {
          'is_self': true,
          'is_reviewer': false,
          'is_peer': false,
          'writes_as': null,
        },
        'can': {
          'save': false,
          'submit': false,
          'edit_goals': false,
          'ask_peers': false,
          'decline': false,
          'acknowledge': false,
        },
        'scale': {
          'allows_na': true,
          'levels': [
            {'value': 5, 'label': 'Outstanding', 'description': 'Far above expectations'},
            {'value': 4, 'label': 'Exceeds expectations', 'description': 'Often above expectations'},
          ],
        },
        'sections': [
          {
            'id': 15,
            'title': 'Work delivered',
            'kind': 'questions',
            'weight': '0',
            'questions': [
              {
                'id': 64,
                'text': 'List every product you worked on',
                'kind': 'text',
                'self_answers': true,
                'manager_answers': false,
                'peers_answer': false,
                'required': true,
                'columns': [],
                'self': {
                  'text': 'Audit Tracker 24/7',
                },
              },
            ],
          },
        ],
      };

      final details = PerformanceReviewDetailsModel.fromJson(json);

      expect(details.id, '01m6n2y0mnf18z15tk5xbsschp');
      expect(details.cycle.name, 'Development Team Evaluation 2025–26');
      expect(details.employee.name, 'Malik Muhammad Imran');
      expect(details.employee.department, 'Development');
      expect(details.employee.designation, 'Flutter Developer');
      expect(details.viewer.isSelf, true);
      expect(details.can.save, false);
      expect(details.sections.length, 1);
      expect(details.sections.first.questions.length, 1);
      expect(details.sections.first.questions.first.id, 64);
      expect(details.sections.first.questions.first.selfAnswer?.text, 'Audit Tracker 24/7');
    });
  });
}
