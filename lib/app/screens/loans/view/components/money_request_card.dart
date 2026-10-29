import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../model/money_request_model.dart';

/// Signature Floating Card for a Money Request (Loan, Advance, Expense).
/// Adheres strictly to .agents/rules/ams.md:
/// - Inside padding: strictly 12.w horizontal, 14.h vertical
/// - Border radius: 15.r
/// - Signature status tone bottom border accent: 3.w
class MoneyRequestCard extends StatelessWidget {
  final MoneyRequestItemModel request;
  final VoidCallback onTap;

  const MoneyRequestCard({
    super.key,
    required this.request,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = request.statusToneColor;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: AppColors.borderColor, width: 1.w),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.r),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Icon, Type Name & Status Pill
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(7.w),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Icon(
                                  _getKindIcon(request.typeKind),
                                  size: 18.sp,
                                  color: statusColor,
                                ),
                              ),
                              AppSpaces.hSpace8,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    request.typeName,
                                    style: AppTextStyles.text14.copyWith(
                                      color: AppColors.textColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.sp,
                                    ),
                                  ),
                                  Text(
                                    request.typeKindLabel,
                                    style: AppTextStyles.text12.copyWith(
                                      color: AppColors.subTextColor,
                                      fontSize: 11.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          // Status Pill
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              request.statusLabel,
                              style: AppTextStyles.text10.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),

                      AppSpaces.vSpace12,
                      Divider(color: AppColors.borderColor, height: 1.h),
                      AppSpaces.vSpace12,

                      // Financial Metric Row: Requested Amount vs Remaining Balance
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Requested Amount
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'REQUESTED AMOUNT',
                                style: AppTextStyles.text10.copyWith(
                                  color: AppColors.subTextColor,
                                  letterSpacing: 0.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              AppSpaces.vSpace2,
                              Text(
                                request.amountText,
                                style: AppTextStyles.text16.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),

                          // Balance / Instalments if repayable
                          if (request.repayable)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  request.balanceText != null
                                      ? 'OUTSTANDING'
                                      : 'INSTALMENTS',
                                  style: AppTextStyles.text10.copyWith(
                                    color: AppColors.secondary,
                                    letterSpacing: 0.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                AppSpaces.vSpace2,
                                Text(
                                  request.balanceText ??
                                      '${request.instalments ?? 1} Months',
                                  style: AppTextStyles.text14.copyWith(
                                    color: AppColors.textColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),

                      AppSpaces.vSpace10,

                      // Bottom Metadata: Request Date & Breakdown Prompt
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 12.sp,
                                color: AppColors.subTextColor,
                              ),
                              AppSpaces.hSpace4,
                              Text(
                                request.requestedAt.length >= 10
                                    ? request.requestedAt.substring(0, 10)
                                    : request.requestedAt,
                                style: AppTextStyles.text12.copyWith(
                                  color: AppColors.subTextColor,
                                  fontSize: 11.sp,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                'View Schedule & Details',
                                style: AppTextStyles.text12.copyWith(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11.sp,
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 16.sp,
                                color: AppColors.secondary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Signature status tone bottom accent line
                Container(
                  height: 3.w,
                  color: statusColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getKindIcon(String kind) {
    switch (kind.toLowerCase()) {
      case 'loan':
        return Icons.account_balance_outlined;
      case 'advance':
        return Icons.forward_to_inbox_rounded;
      case 'expense':
        return Icons.receipt_long_outlined;
      default:
        return Icons.payments_outlined;
    }
  }
}
