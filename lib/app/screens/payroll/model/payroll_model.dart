/// Summary model for payslip listing from GET /api/v1/me/payslips
class PayslipSummaryModel {
  final String id;
  final String period;
  final String paysOn;
  final String employer;
  final String currency;
  final int net;
  final String netText;
  final String grossText;

  PayslipSummaryModel({
    required this.id,
    required this.period,
    required this.paysOn,
    required this.employer,
    required this.currency,
    required this.net,
    required this.netText,
    required this.grossText,
  });

  factory PayslipSummaryModel.fromJson(Map<String, dynamic> json) {
    return PayslipSummaryModel(
      id: json['id']?.toString() ?? '',
      period: json['period']?.toString() ?? '',
      paysOn: json['pays_on']?.toString() ?? '',
      employer: json['employer']?.toString() ?? '',
      currency: json['currency']?.toString() ?? 'PKR',
      net: json['net'] is int
          ? json['net']
          : int.tryParse(json['net']?.toString() ?? '0') ?? 0,
      netText: json['net_text']?.toString() ?? '',
      grossText: json['gross_text']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'period': period,
      'pays_on': paysOn,
      'employer': employer,
      'currency': currency,
      'net': net,
      'net_text': netText,
      'gross_text': grossText,
    };
  }
}

/// Period metadata for itemized payslip
class PayslipPeriodModel {
  final String label;
  final String startsOn;
  final String endsOn;
  final String paysOn;
  final String attendanceFrom;
  final String attendanceTo;

  PayslipPeriodModel({
    required this.label,
    required this.startsOn,
    required this.endsOn,
    required this.paysOn,
    required this.attendanceFrom,
    required this.attendanceTo,
  });

  factory PayslipPeriodModel.fromJson(Map<String, dynamic> json) {
    return PayslipPeriodModel(
      label: json['label']?.toString() ?? '',
      startsOn: json['starts_on']?.toString() ?? '',
      endsOn: json['ends_on']?.toString() ?? '',
      paysOn: json['pays_on']?.toString() ?? '',
      attendanceFrom: json['attendance_from']?.toString() ?? '',
      attendanceTo: json['attendance_to']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'label': label,
        'starts_on': startsOn,
        'ends_on': endsOn,
        'pays_on': paysOn,
        'attendance_from': attendanceFrom,
        'attendance_to': attendanceTo,
      };
}

/// Employee snapshot at time of payslip finalisation
class PayslipEmployeeModel {
  final String id;
  final String name;
  final String number;
  final String department;
  final String designation;
  final String location;

  PayslipEmployeeModel({
    required this.id,
    required this.name,
    required this.number,
    required this.department,
    required this.designation,
    required this.location,
  });

  factory PayslipEmployeeModel.fromJson(Map<String, dynamic> json) {
    return PayslipEmployeeModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      number: json['number']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
      designation: json['designation']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'number': number,
        'department': department,
        'designation': designation,
        'location': location,
      };
}

/// Calendar days and worked duration for payslip
class PayslipDaysModel {
  final int period;
  final double paid;
  final double unpaid;
  final int workedMinutes;
  final int overtimeMinutes;

  PayslipDaysModel({
    required this.period,
    required this.paid,
    required this.unpaid,
    required this.workedMinutes,
    required this.overtimeMinutes,
  });

  factory PayslipDaysModel.fromJson(Map<String, dynamic> json) {
    return PayslipDaysModel(
      period: json['period'] is int
          ? json['period']
          : int.tryParse(json['period']?.toString() ?? '0') ?? 0,
      paid: (json['paid'] is num)
          ? (json['paid'] as num).toDouble()
          : double.tryParse(json['paid']?.toString() ?? '0.0') ?? 0.0,
      unpaid: (json['unpaid'] is num)
          ? (json['unpaid'] as num).toDouble()
          : double.tryParse(json['unpaid']?.toString() ?? '0.0') ?? 0.0,
      workedMinutes: json['worked_minutes'] is int
          ? json['worked_minutes']
          : int.tryParse(json['worked_minutes']?.toString() ?? '0') ?? 0,
      overtimeMinutes: json['overtime_minutes'] is int
          ? json['overtime_minutes']
          : int.tryParse(json['overtime_minutes']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'period': period,
        'paid': paid,
        'unpaid': unpaid,
        'worked_minutes': workedMinutes,
        'overtime_minutes': overtimeMinutes,
      };
}

/// Individual itemized earnings, deductions, or employer contributions line
class PayslipLineItemModel {
  final String code;
  final String name;
  final int amount;
  final String amountText;
  final String? explanation;

  PayslipLineItemModel({
    required this.code,
    required this.name,
    required this.amount,
    required this.amountText,
    this.explanation,
  });

  factory PayslipLineItemModel.fromJson(Map<String, dynamic> json) {
    return PayslipLineItemModel(
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      amount: json['amount'] is int
          ? json['amount']
          : int.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      amountText: json['amount_text']?.toString() ?? '',
      explanation: json['explanation']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'amount': amount,
        'amount_text': amountText,
        'explanation': explanation,
      };
}

/// Formatted minor unit and ready-to-display text pair
class MoneyAmountModel {
  final int amount;
  final String text;

  MoneyAmountModel({
    required this.amount,
    required this.text,
  });

  factory MoneyAmountModel.fromJson(Map<String, dynamic> json) {
    return MoneyAmountModel(
      amount: json['amount'] is int
          ? json['amount']
          : int.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      text: json['text']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'text': text,
      };
}

/// Aggregate totals on payslip (Gross, Deductions, Net, Taxable, Tax, Employer Cost)
class PayslipTotalsModel {
  final MoneyAmountModel? gross;
  final MoneyAmountModel? deductions;
  final MoneyAmountModel? net;
  final MoneyAmountModel? employerCost;
  final MoneyAmountModel? taxable;
  final MoneyAmountModel? tax;

  PayslipTotalsModel({
    this.gross,
    this.deductions,
    this.net,
    this.employerCost,
    this.taxable,
    this.tax,
  });

  factory PayslipTotalsModel.fromJson(Map<String, dynamic> json) {
    return PayslipTotalsModel(
      gross: json['gross'] is Map<String, dynamic>
          ? MoneyAmountModel.fromJson(json['gross'])
          : null,
      deductions: json['deductions'] is Map<String, dynamic>
          ? MoneyAmountModel.fromJson(json['deductions'])
          : null,
      net: json['net'] is Map<String, dynamic>
          ? MoneyAmountModel.fromJson(json['net'])
          : null,
      employerCost: json['employer_cost'] is Map<String, dynamic>
          ? MoneyAmountModel.fromJson(json['employer_cost'])
          : null,
      taxable: json['taxable'] is Map<String, dynamic>
          ? MoneyAmountModel.fromJson(json['taxable'])
          : null,
      tax: json['tax'] is Map<String, dynamic>
          ? MoneyAmountModel.fromJson(json['tax'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'gross': gross?.toJson(),
        'deductions': deductions?.toJson(),
        'net': net?.toJson(),
        'employer_cost': employerCost?.toJson(),
        'taxable': taxable?.toJson(),
        'tax': tax?.toJson(),
      };
}

/// Comprehensive payslip model from GET /api/v1/me/payslips/{id}
class PayslipDetailsModel {
  final String id;
  final PayslipPeriodModel? period;
  final String employer;
  final String runStatus;
  final String status;
  final PayslipEmployeeModel? employee;
  final String currency;
  final String paymentMethod;
  final PayslipDaysModel? days;
  final List<PayslipLineItemModel> earnings;
  final List<PayslipLineItemModel> deductions;
  final List<PayslipLineItemModel> employerContributions;
  final PayslipTotalsModel? totals;
  final PayslipTotalsModel? yearToDate;
  final String? problem;
  final bool stale;

  PayslipDetailsModel({
    required this.id,
    this.period,
    required this.employer,
    required this.runStatus,
    required this.status,
    this.employee,
    required this.currency,
    required this.paymentMethod,
    this.days,
    required this.earnings,
    required this.deductions,
    required this.employerContributions,
    this.totals,
    this.yearToDate,
    this.problem,
    required this.stale,
  });

  factory PayslipDetailsModel.fromJson(Map<String, dynamic> json) {
    return PayslipDetailsModel(
      id: json['id']?.toString() ?? '',
      period: json['period'] is Map<String, dynamic>
          ? PayslipPeriodModel.fromJson(json['period'])
          : null,
      employer: json['employer']?.toString() ?? '',
      runStatus: json['run_status']?.toString() ?? 'finalised',
      status: json['status']?.toString() ?? 'included',
      employee: json['employee'] is Map<String, dynamic>
          ? PayslipEmployeeModel.fromJson(json['employee'])
          : null,
      currency: json['currency']?.toString() ?? 'PKR',
      paymentMethod: json['payment_method']?.toString() ?? 'Bank transfer',
      days: json['days'] is Map<String, dynamic>
          ? PayslipDaysModel.fromJson(json['days'])
          : null,
      earnings: (json['earnings'] as List<dynamic>?)
              ?.map((e) => PayslipLineItemModel.fromJson(e))
              .toList() ??
          [],
      deductions: (json['deductions'] as List<dynamic>?)
              ?.map((e) => PayslipLineItemModel.fromJson(e))
              .toList() ??
          [],
      employerContributions: (json['employer_contributions'] as List<dynamic>?)
              ?.map((e) => PayslipLineItemModel.fromJson(e))
              .toList() ??
          [],
      totals: json['totals'] is Map<String, dynamic>
          ? PayslipTotalsModel.fromJson(json['totals'])
          : null,
      yearToDate: json['year_to_date'] is Map<String, dynamic>
          ? PayslipTotalsModel.fromJson(json['year_to_date'])
          : null,
      problem: json['problem']?.toString(),
      stale: json['stale'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'period': period?.toJson(),
        'employer': employer,
        'run_status': runStatus,
        'status': status,
        'employee': employee?.toJson(),
        'currency': currency,
        'payment_method': paymentMethod,
        'days': days?.toJson(),
        'earnings': earnings.map((e) => e.toJson()).toList(),
        'deductions': deductions.map((e) => e.toJson()).toList(),
        'employer_contributions':
            employerContributions.map((e) => e.toJson()).toList(),
        'totals': totals?.toJson(),
        'year_to_date': yearToDate?.toJson(),
        'problem': problem,
        'stale': stale,
      };
}

/// Salary structure formula line
class SalaryLineModel {
  final String code;
  final String name;
  final String kind; // 'earning' or 'deduction'
  final int? amount;
  final String? amountText;
  final String? percent;

  SalaryLineModel({
    required this.code,
    required this.name,
    required this.kind,
    this.amount,
    this.amountText,
    this.percent,
  });

  factory SalaryLineModel.fromJson(Map<String, dynamic> json) {
    return SalaryLineModel(
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      kind: json['kind']?.toString() ?? 'earning',
      amount: json['amount'] is int
          ? json['amount']
          : int.tryParse(json['amount']?.toString() ?? ''),
      amountText: json['amount_text']?.toString(),
      percent: json['percent']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'kind': kind,
        'amount': amount,
        'amount_text': amountText,
        'percent': percent,
      };
}

/// Active salary structure model from GET /api/v1/me/salary
class SalaryStructureModel {
  final String id;
  final String effectiveFrom;
  final String basis;
  final String basisLabel;
  final String schedule;
  final String paymentMethod;
  final String currency;
  final bool socialSecurityEnrolled;
  final String? reason;
  final List<SalaryLineModel> lines;

  SalaryStructureModel({
    required this.id,
    required this.effectiveFrom,
    required this.basis,
    required this.basisLabel,
    required this.schedule,
    required this.paymentMethod,
    required this.currency,
    required this.socialSecurityEnrolled,
    this.reason,
    required this.lines,
  });

  factory SalaryStructureModel.fromJson(Map<String, dynamic> json) {
    return SalaryStructureModel(
      id: json['id']?.toString() ?? '',
      effectiveFrom: json['effective_from']?.toString() ?? '',
      basis: json['basis']?.toString() ?? 'period',
      basisLabel: json['basis_label']?.toString() ?? 'Per pay period',
      schedule: json['schedule']?.toString() ?? 'Monthly',
      paymentMethod: json['payment_method']?.toString() ?? 'Bank transfer',
      currency: json['currency']?.toString() ?? 'PKR',
      socialSecurityEnrolled: json['social_security_enrolled'] == true,
      reason: json['reason']?.toString(),
      lines: (json['lines'] as List<dynamic>?)
              ?.map((e) => SalaryLineModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'effective_from': effectiveFrom,
        'basis': basis,
        'basis_label': basisLabel,
        'schedule': schedule,
        'payment_method': paymentMethod,
        'currency': currency,
        'social_security_enrolled': socialSecurityEnrolled,
        'reason': reason,
        'lines': lines.map((e) => e.toJson()).toList(),
      };
}
