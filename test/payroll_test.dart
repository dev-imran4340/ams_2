import 'package:flutter_test/flutter_test.dart';
import 'package:ams_2/app/screens/payroll/model/payroll_model.dart';
import 'package:ams_2/app/screens/payroll/controller/payroll_controller.dart';
import 'package:ams_2/app/screens/payroll/repo/payroll_repo.dart';

class MockPayrollRepo extends PayrollRepo {
  @override
  Future<List<PayslipSummaryModel>> fetchPayslips() async {
    return [
      PayslipSummaryModel(
        id: '01jb2x9k4m7q8r3t5v6w8y0z1a',
        period: 'July 2026',
        paysOn: '2026-07-31',
        employer: 'Softech Business Services',
        currency: 'PKR',
        net: 14918000,
        netText: 'Rs 149,180.00',
        grossText: 'Rs 155,000.00',
      ),
    ];
  }

  @override
  Future<SalaryStructureModel?> fetchActiveSalary() async {
    return SalaryStructureModel(
      id: '01jc9876543210987654321098',
      effectiveFrom: '2026-01-01',
      basis: 'period',
      basisLabel: 'Per pay period',
      schedule: 'Monthly',
      paymentMethod: 'Bank transfer',
      currency: 'PKR',
      socialSecurityEnrolled: true,
      lines: [
        SalaryLineModel(
          code: 'BASIC',
          name: 'Basic salary',
          kind: 'earning',
          amount: 10000000,
          amountText: 'Rs 100,000.00',
        ),
        SalaryLineModel(
          code: 'HRA',
          name: 'House rent allowance',
          kind: 'earning',
          percent: '45',
        ),
      ],
    );
  }
}

void main() {
  group('Payroll Models Tests (Phase 12)', () {
    test('PayslipSummaryModel deserializes list item correctly', () {
      final json = {
        'id': '01jb2x9k4m7q8r3t5v6w8y0z1a',
        'period': 'July 2026',
        'pays_on': '2026-07-31',
        'employer': 'Acme Textiles (Pvt) Ltd',
        'currency': 'PKR',
        'net': 14918000,
        'net_text': 'Rs 149,180.00',
        'gross_text': 'Rs 155,000.00',
      };

      final model = PayslipSummaryModel.fromJson(json);
      expect(model.id, equals('01jb2x9k4m7q8r3t5v6w8y0z1a'));
      expect(model.period, equals('July 2026'));
      expect(model.netText, equals('Rs 149,180.00'));
      expect(model.grossText, equals('Rs 155,000.00'));
      expect(model.net, equals(14918000));
    });

    test('PayslipDetailsModel deserializes itemized breakdown correctly', () {
      final json = {
        'id': '01jb2x9k4m7q8r3t5v6w8y0z1a',
        'period': {
          'label': 'July 2026',
          'starts_on': '2026-07-01',
          'ends_on': '2026-07-31',
          'pays_on': '2026-07-31',
          'attendance_from': '2026-07-01',
          'attendance_to': '2026-07-31',
        },
        'employer': 'Acme Textiles (Pvt) Ltd',
        'run_status': 'finalised',
        'status': 'included',
        'employee': {
          'id': '01ja1234567890123456789012',
          'name': 'Bilal Khan',
          'number': 'EMP-0002',
          'department': 'Sales',
          'designation': 'Officer',
          'location': 'Head office',
        },
        'currency': 'PKR',
        'payment_method': 'Bank transfer',
        'days': {
          'period': 31,
          'paid': 31.0,
          'unpaid': 0.0,
          'worked_minutes': 9660,
          'overtime_minutes': 0,
        },
        'earnings': [
          {
            'code': 'BASIC',
            'name': 'Basic salary',
            'amount': 10000000,
            'amount_text': 'Rs 100,000.00',
            'explanation': 'Full period',
          }
        ],
        'deductions': [
          {
            'code': 'TAX',
            'name': 'Income tax',
            'amount': 545000,
            'amount_text': 'Rs 5,450.00',
            'explanation': 'Yearly tax … over 12 period(s)',
          }
        ],
        'employer_contributions': [
          {
            'code': 'SSER',
            'name': 'EOBI (employer)',
            'amount': 185000,
            'amount_text': 'Rs 1,850.00',
            'explanation': '5% of Rs 37,000.00',
          }
        ],
        'totals': {
          'gross': {'amount': 15500000, 'text': 'Rs 155,000.00'},
          'deductions': {'amount': 582000, 'text': 'Rs 5,820.00'},
          'net': {'amount': 14918000, 'text': 'Rs 149,180.00'},
          'employer_cost': {'amount': 15685000, 'text': 'Rs 156,850.00'},
          'taxable': {'amount': 14500000, 'text': 'Rs 145,000.00'},
          'tax': {'amount': 545000, 'text': 'Rs 5,450.00'},
        },
        'year_to_date': {
          'gross': {'amount': 15500000, 'text': 'Rs 155,000.00'},
          'taxable': {'amount': 14500000, 'text': 'Rs 145,000.00'},
          'tax': {'amount': 545000, 'text': 'Rs 5,450.00'},
        },
        'problem': null,
        'stale': false,
      };

      final details = PayslipDetailsModel.fromJson(json);
      expect(details.id, equals('01jb2x9k4m7q8r3t5v6w8y0z1a'));
      expect(details.period?.label, equals('July 2026'));
      expect(details.days?.workedMinutes, equals(9660));
      expect(details.earnings.length, equals(1));
      expect(details.earnings.first.code, equals('BASIC'));
      expect(details.deductions.first.code, equals('TAX'));
      expect(details.employerContributions.first.name, contains('EOBI'));
      expect(details.totals?.net?.text, equals('Rs 149,180.00'));
    });

    test('SalaryStructureModel deserializes formula lines correctly', () {
      final json = {
        'id': '01jc1234567890123456789012',
        'effective_from': '2026-01-01',
        'basis': 'period',
        'basis_label': 'Per pay period',
        'schedule': 'Monthly',
        'payment_method': 'Bank transfer',
        'currency': 'PKR',
        'social_security_enrolled': true,
        'reason': null,
        'lines': [
          {
            'code': 'BASIC',
            'name': 'Basic salary',
            'kind': 'earning',
            'amount': 10000000,
            'amount_text': 'Rs 100,000.00',
            'percent': null,
          },
          {
            'code': 'HRA',
            'name': 'House rent allowance',
            'kind': 'earning',
            'amount': null,
            'amount_text': null,
            'percent': '45',
          }
        ]
      };

      final salary = SalaryStructureModel.fromJson(json);
      expect(salary.id, equals('01jc1234567890123456789012'));
      expect(salary.socialSecurityEnrolled, isTrue);
      expect(salary.lines.length, equals(2));
      expect(salary.lines[0].amountText, equals('Rs 100,000.00'));
      expect(salary.lines[1].percent, equals('45'));
    });
  });

  group('PayrollController Tests', () {
    test('Loads payslips and salary structure correctly', () async {
      final repo = MockPayrollRepo();
      final controller = PayrollController(repo: repo);

      await controller.loadPayrollData();

      expect(controller.payslips.length, equals(1));
      expect(controller.payslips.first.period, equals('July 2026'));
      expect(controller.salaryStructure.value, isNotNull);
      expect(controller.salaryStructure.value?.schedule, equals('Monthly'));

      // Tab switcher test
      expect(controller.selectedTabIndex.value, equals(0));
      controller.switchTab(1);
      expect(controller.selectedTabIndex.value, equals(1));

      controller.onClose();
    });
  });
}
