import 'package:flutter_test/flutter_test.dart';
import 'package:ams_2/app/screens/loans/model/money_request_model.dart';
import 'package:ams_2/app/screens/loans/controller/money_request_controller.dart';
import 'package:ams_2/app/screens/loans/repo/money_request_repo.dart';

class MockMoneyRequestRepo extends MoneyRequestRepo {
  @override
  Future<MoneyRequestTypesResponse?> fetchMoneyRequestTypes() async {
    return MoneyRequestTypesResponse(
      types: [
        MoneyRequestTypeModel(
          id: '01jd1234567890123456789012',
          name: 'Staff loan',
          kind: 'loan',
          kindLabel: 'Loan',
          repayable: true,
          hasLines: false,
          maxInstalments: 24,
          maxPerRequest: 'Rs 200,000.00',
          receiptRequired: false,
        ),
      ],
      categories: [
        ExpenseCategoryModel(id: '01je1234567890123456789012', name: 'Travel'),
      ],
    );
  }

  @override
  Future<List<MoneyRequestItemModel>> fetchMoneyRequests({
    int page = 1,
    int perPage = 25,
  }) async {
    return [
      MoneyRequestItemModel(
        id: '01jf1234567890123456789012',
        employeeName: 'Bilal Khan',
        typeId: '01jd1234567890123456789012',
        typeName: 'Staff loan',
        typeKind: 'loan',
        typeKindLabel: 'Loan',
        amount: 3000000,
        currency: 'PKR',
        amountText: 'Rs 30,000.00',
        status: 'pending',
        statusLabel: 'Pending',
        tone: 'amber',
        source: 'self',
        sourceLabel: 'Asked by employee',
        reason: 'Family emergency',
        requestedAt: '2026-10-29T10:00:00Z',
        repayable: true,
        instalments: 3,
        instalmentAmount: 1000000,
        instalmentText: 'Rs 10,000.00',
        balance: 3000000,
        balanceText: 'Rs 30,000.00',
      ),
    ];
  }

  @override
  Future<bool> cancelMoneyRequest(String id, {String? reason}) async {
    return true;
  }
}

void main() {
  group('Money Request Models Tests (Phase 13)', () {
    test('MoneyRequestTypeModel deserializes correctly', () {
      final json = {
        'id': '01jd1234567890123456789012',
        'name': 'Staff loan',
        'kind': 'loan',
        'kind_label': 'Loan',
        'description': null,
        'repayable': true,
        'has_lines': false,
        'max_instalments': 24,
        'max_per_request': 'Rs 200,000.00',
        'max_outstanding': null,
        'receipt_required': false,
      };

      final model = MoneyRequestTypeModel.fromJson(json);
      expect(model.id, equals('01jd1234567890123456789012'));
      expect(model.name, equals('Staff loan'));
      expect(model.repayable, isTrue);
      expect(model.hasLines, isFalse);
      expect(model.maxInstalments, equals(24));
    });

    test('MoneyRequestItemModel deserializes correctly', () {
      final json = {
        'id': '01jf1234567890123456789012',
        'employee': {'id': '01ja…', 'name': 'Bilal Khan'},
        'type': {
          'id': '01jd…',
          'name': 'Staff loan',
          'kind': 'loan',
          'kind_label': 'Loan',
        },
        'amount': 3000000,
        'currency': 'PKR',
        'amount_text': 'Rs 30,000.00',
        'status': 'repaying',
        'status_label': 'Being paid back',
        'tone': 'brand',
        'source': 'self',
        'source_label': 'Asked by employee',
        'reason': 'Family needs',
        'requested_at': '2026-10-29T10:00:00Z',
        'repayable': true,
        'instalments': 3,
        'instalment_amount': 1000000,
        'instalment_text': 'Rs 10,000.00',
        'balance': 2000000,
        'balance_text': 'Rs 20,000.00',
        'payout': {
          'method': 'outside',
          'method_label': 'Outside payroll (cash or transfer)',
          'period': null,
          'paid_out_on': '2026-10-29',
          'reference': 'TRX-1',
          'first_period': 'November 2026',
        },
        'closed_on': null,
        'cancel_reason': null,
      };

      final model = MoneyRequestItemModel.fromJson(json);
      expect(model.id, equals('01jf1234567890123456789012'));
      expect(model.amountText, equals('Rs 30,000.00'));
      expect(model.status, equals('repaying'));
      expect(model.payout?.methodLabel, contains('Outside payroll'));
      expect(model.payout?.reference, equals('TRX-1'));
    });

    test('RepaymentSchedulePeriodModel deserializes correctly', () {
      final json = {
        'period': 'November 2026',
        'amount_text': 'Rs 10,000.00',
        'state': 'recovered',
        'state_label': 'Deducted',
        'owed_after_text': 'Rs 20,000.00',
      };

      final schedule = RepaymentSchedulePeriodModel.fromJson(json);
      expect(schedule.period, equals('November 2026'));
      expect(schedule.state, equals('recovered'));
    });
  });

  group('MoneyRequestController Tests', () {
    test('Loads data and supports filter & cancel flows', () async {
      final repo = MockMoneyRequestRepo();
      final controller = MoneyRequestController(repo: repo);

      await controller.loadLoansData();

      expect(controller.requestTypes.length, equals(1));
      expect(controller.expenseCategories.length, equals(1));
      expect(controller.moneyRequests.length, equals(1));
      expect(controller.filteredRequests.length, equals(1));

      // Filter testing
      controller.setFilterKind('expense');
      expect(controller.filteredRequests.length, equals(0));

      controller.setFilterKind('loan');
      expect(controller.filteredRequests.length, equals(1));

      // Cancel flow
      final success =
          await controller.cancelRequest('01jf1234567890123456789012');
      expect(success, isTrue);
      expect(controller.moneyRequests.first.status, equals('cancelled'));

      controller.onClose();
    });
  });
}
