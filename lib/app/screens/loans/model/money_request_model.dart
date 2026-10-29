import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/utils/app_colors.dart';

/// Available Money Request Type from GET /api/v1/me/money-request-types
class MoneyRequestTypeModel {
  final String id;
  final String name;
  final String kind; // 'loan', 'advance', 'payment', 'expense'
  final String kindLabel;
  final String? description;
  final bool repayable;
  final bool hasLines;
  final int? maxInstalments;
  final String? maxPerRequest;
  final String? maxOutstanding;
  final bool receiptRequired;

  MoneyRequestTypeModel({
    required this.id,
    required this.name,
    required this.kind,
    required this.kindLabel,
    this.description,
    required this.repayable,
    required this.hasLines,
    this.maxInstalments,
    this.maxPerRequest,
    this.maxOutstanding,
    required this.receiptRequired,
  });

  factory MoneyRequestTypeModel.fromJson(Map<String, dynamic> json) {
    return MoneyRequestTypeModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      kind: json['kind']?.toString() ?? 'loan',
      kindLabel: json['kind_label']?.toString() ?? 'Loan',
      description: json['description']?.toString(),
      repayable: json['repayable'] == true,
      hasLines: json['has_lines'] == true,
      maxInstalments: json['max_instalments'] is int
          ? json['max_instalments']
          : int.tryParse(json['max_instalments']?.toString() ?? ''),
      maxPerRequest: json['max_per_request']?.toString(),
      maxOutstanding: json['max_outstanding']?.toString(),
      receiptRequired: json['receipt_required'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'kind': kind,
        'kind_label': kindLabel,
        'description': description,
        'repayable': repayable,
        'has_lines': hasLines,
        'max_instalments': maxInstalments,
        'max_per_request': maxPerRequest,
        'max_outstanding': maxOutstanding,
        'receipt_required': receiptRequired,
      };

  IconData get icon {
    switch (kind) {
      case 'loan':
        return Icons.account_balance_outlined;
      case 'advance':
        return Icons.forward_to_inbox_rounded;
      case 'expense':
        return Icons.receipt_long_outlined;
      case 'payment':
        return Icons.payments_outlined;
      default:
        return Icons.monetization_on_outlined;
    }
  }
}

/// Expense category for itemized expense lines
class ExpenseCategoryModel {
  final String id;
  final String name;

  ExpenseCategoryModel({
    required this.id,
    required this.name,
  });

  factory ExpenseCategoryModel.fromJson(Map<String, dynamic> json) {
    return ExpenseCategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

/// Combined metadata response from GET /api/v1/me/money-request-types
class MoneyRequestTypesResponse {
  final List<MoneyRequestTypeModel> types;
  final List<ExpenseCategoryModel> categories;

  MoneyRequestTypesResponse({
    required this.types,
    required this.categories,
  });

  factory MoneyRequestTypesResponse.fromJson(Map<String, dynamic> json) {
    return MoneyRequestTypesResponse(
      types: (json['types'] as List<dynamic>?)
              ?.map((t) =>
                  MoneyRequestTypeModel.fromJson(Map<String, dynamic>.from(t)))
              .toList() ??
          [],
      categories: (json['categories'] as List<dynamic>?)
              ?.map((c) =>
                  ExpenseCategoryModel.fromJson(Map<String, dynamic>.from(c)))
              .toList() ??
          [],
    );
  }
}

/// Payout details on approved / disbursed request
class MoneyPayoutModel {
  final String method;
  final String methodLabel;
  final String? period;
  final String? paidOutOn;
  final String? reference;
  final String? firstPeriod;

  MoneyPayoutModel({
    required this.method,
    required this.methodLabel,
    this.period,
    this.paidOutOn,
    this.reference,
    this.firstPeriod,
  });

  factory MoneyPayoutModel.fromJson(Map<String, dynamic> json) {
    return MoneyPayoutModel(
      method: json['method']?.toString() ?? '',
      methodLabel: json['method_label']?.toString() ?? '',
      period: json['period']?.toString(),
      paidOutOn: json['paid_out_on']?.toString(),
      reference: json['reference']?.toString(),
      firstPeriod: json['first_period']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'method': method,
        'method_label': methodLabel,
        'period': period,
        'paid_out_on': paidOutOn,
        'reference': reference,
        'first_period': firstPeriod,
      };
}

/// Individual itemized expense claim line
class ExpenseLineItemModel {
  final int position;
  final String? category;
  final String spentOn;
  final num amount;
  final String amountText;
  final String? note;
  final bool hasReceipt;

  ExpenseLineItemModel({
    required this.position,
    this.category,
    required this.spentOn,
    required this.amount,
    required this.amountText,
    this.note,
    required this.hasReceipt,
  });

  factory ExpenseLineItemModel.fromJson(Map<String, dynamic> json) {
    return ExpenseLineItemModel(
      position: json['position'] is int
          ? json['position']
          : int.tryParse(json['position']?.toString() ?? '1') ?? 1,
      category: json['category']?.toString(),
      spentOn: json['spent_on']?.toString() ?? '',
      amount: json['amount'] is num
          ? (json['amount'] as num)
          : num.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      amountText: json['amount_text']?.toString() ?? '',
      note: json['note']?.toString(),
      hasReceipt: json['has_receipt'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'position': position,
        'category': category,
        'spent_on': spentOn,
        'amount': amount,
        'amount_text': amountText,
        'note': note,
        'has_receipt': hasReceipt,
      };
}

/// Repayment schedule pay period entry for loans & advances
class RepaymentSchedulePeriodModel {
  final String period;
  final String amountText;
  final String state; // 'recovered', 'missed', 'skipped', 'planned'
  final String stateLabel;
  final String owedAfterText;

  RepaymentSchedulePeriodModel({
    required this.period,
    required this.amountText,
    required this.state,
    required this.stateLabel,
    required this.owedAfterText,
  });

  factory RepaymentSchedulePeriodModel.fromJson(Map<String, dynamic> json) {
    return RepaymentSchedulePeriodModel(
      period: json['period']?.toString() ?? '',
      amountText: json['amount_text']?.toString() ?? '',
      state: json['state']?.toString() ?? 'planned',
      stateLabel: json['state_label']?.toString() ?? 'Planned',
      owedAfterText: json['owed_after_text']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'period': period,
        'amount_text': amountText,
        'state': state,
        'state_label': stateLabel,
        'owed_after_text': owedAfterText,
      };

  Color get stateColor {
    switch (state) {
      case 'recovered':
        return AppColors.success;
      case 'missed':
        return AppColors.error;
      case 'skipped':
        return AppColors.warning;
      case 'planned':
      default:
        return AppColors.primary;
    }
  }
}

/// Payroll recovery record
class LoanRecoveryModel {
  final String amountText;
  final String sourceLabel;
  final String? period;
  final String? recordedOn;
  final String? note;

  LoanRecoveryModel({
    required this.amountText,
    required this.sourceLabel,
    this.period,
    this.recordedOn,
    this.note,
  });

  factory LoanRecoveryModel.fromJson(Map<String, dynamic> json) {
    return LoanRecoveryModel(
      amountText: json['amount_text']?.toString() ?? '',
      sourceLabel: json['source_label']?.toString() ?? '',
      period: json['period']?.toString(),
      recordedOn: json['recorded_on']?.toString(),
      note: json['note']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'amount_text': amountText,
        'source_label': sourceLabel,
        'period': period,
        'recorded_on': recordedOn,
        'note': note,
      };
}

/// Primary Money Request Entity from GET /api/v1/me/money-requests
class MoneyRequestItemModel {
  final String id;
  final String? employeeName;
  final String typeId;
  final String typeName;
  final String typeKind;
  final String typeKindLabel;
  final int amount;
  final String currency;
  final String amountText;
  final String status;
  final String statusLabel;
  final String tone;
  final String source;
  final String sourceLabel;
  final String? reason;
  final String requestedAt;
  final bool repayable;
  final int? instalments;
  final int? instalmentAmount;
  final String? instalmentText;
  final int? balance;
  final String? balanceText;
  final MoneyPayoutModel? payout;
  final String? closedOn;
  final String? cancelReason;
  final List<ExpenseLineItemModel> lines;
  final List<RepaymentSchedulePeriodModel> schedule;
  final List<LoanRecoveryModel> recoveries;

  MoneyRequestItemModel({
    required this.id,
    this.employeeName,
    required this.typeId,
    required this.typeName,
    required this.typeKind,
    required this.typeKindLabel,
    required this.amount,
    required this.currency,
    required this.amountText,
    required this.status,
    required this.statusLabel,
    required this.tone,
    required this.source,
    required this.sourceLabel,
    this.reason,
    required this.requestedAt,
    required this.repayable,
    this.instalments,
    this.instalmentAmount,
    this.instalmentText,
    this.balance,
    this.balanceText,
    this.payout,
    this.closedOn,
    this.cancelReason,
    this.lines = const [],
    this.schedule = const [],
    this.recoveries = const [],
  });

  factory MoneyRequestItemModel.fromJson(Map<String, dynamic> json) {
    final typeMap = json['type'] is Map ? json['type'] : null;
    final empMap = json['employee'] is Map ? json['employee'] : null;

    return MoneyRequestItemModel(
      id: json['id']?.toString() ?? '',
      employeeName: empMap?['name']?.toString(),
      typeId: typeMap?['id']?.toString() ?? '',
      typeName: typeMap?['name']?.toString() ?? 'Money Request',
      typeKind: typeMap?['kind']?.toString() ?? 'loan',
      typeKindLabel: typeMap?['kind_label']?.toString() ?? 'Loan',
      amount: json['amount'] is int
          ? json['amount']
          : int.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      currency: json['currency']?.toString() ?? 'PKR',
      amountText: json['amount_text']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      statusLabel: json['status_label']?.toString() ?? 'Pending',
      tone: json['tone']?.toString() ?? 'amber',
      source: json['source']?.toString() ?? 'self',
      sourceLabel: json['source_label']?.toString() ?? 'Asked by employee',
      reason: json['reason']?.toString(),
      requestedAt: json['requested_at']?.toString() ?? '',
      repayable: json['repayable'] == true,
      instalments: json['instalments'] is int
          ? json['instalments']
          : int.tryParse(json['instalments']?.toString() ?? ''),
      instalmentAmount: json['instalment_amount'] is int
          ? json['instalment_amount']
          : int.tryParse(json['instalment_amount']?.toString() ?? ''),
      instalmentText: json['instalment_text']?.toString(),
      balance: json['balance'] is int
          ? json['balance']
          : int.tryParse(json['balance']?.toString() ?? ''),
      balanceText: json['balance_text']?.toString(),
      payout: json['payout'] is Map
          ? MoneyPayoutModel.fromJson(Map<String, dynamic>.from(json['payout']))
          : null,
      closedOn: json['closed_on']?.toString(),
      cancelReason: json['cancel_reason']?.toString(),
      lines: (json['lines'] as List<dynamic>?)
              ?.map((l) =>
                  ExpenseLineItemModel.fromJson(Map<String, dynamic>.from(l)))
              .toList() ??
          [],
      schedule: (json['schedule'] as List<dynamic>?)
              ?.map((s) => RepaymentSchedulePeriodModel.fromJson(
                  Map<String, dynamic>.from(s)))
              .toList() ??
          [],
      recoveries: (json['recoveries'] as List<dynamic>?)
              ?.map((r) =>
                  LoanRecoveryModel.fromJson(Map<String, dynamic>.from(r)))
              .toList() ??
          [],
    );
  }

  Color get statusToneColor {
    switch (tone.toLowerCase()) {
      case 'emerald':
      case 'green':
        return AppColors.success;
      case 'rose':
      case 'red':
        return AppColors.error;
      case 'brand':
      case 'secondary':
      case 'teal':
        return AppColors.secondary;
      case 'amber':
      case 'orange':
      case 'warning':
        return AppColors.warning;
      case 'slate':
      default:
        return AppColors.subTextColor;
    }
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRepaying => status == 'repaying';
}

/// Client-side draft line for creating expense claims
class ExpenseDraftLine {
  final String categoryId;
  final String categoryName;
  final String spentOn;
  final String amount;
  final String note;
  final File? receiptFile;

  ExpenseDraftLine({
    required this.categoryId,
    required this.categoryName,
    required this.spentOn,
    required this.amount,
    required this.note,
    this.receiptFile,
  });
}
