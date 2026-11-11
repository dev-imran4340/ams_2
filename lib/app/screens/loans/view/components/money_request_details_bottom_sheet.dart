import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../model/money_request_model.dart';

/// Modal bottom sheet displaying detailed audit of a Money Request,
/// including Payout metadata, Repayment Schedule, and Expense Lines.
class MoneyRequestDetailsBottomSheet extends StatelessWidget {
  final MoneyRequestItemModel details;
  final Future<void> Function(String reason)? onCancelRequest;
  final bool isCancelling;

  const MoneyRequestDetailsBottomSheet({
    super.key,
    required this.details,
    this.onCancelRequest,
    this.isCancelling = false,
  });

  static void show(
    BuildContext context, {
    required MoneyRequestItemModel details,
    Future<void> Function(String reason)? onCancelRequest,
    bool isCancelling = false,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MoneyRequestDetailsBottomSheet(
        details: details,
        onCancelRequest: onCancelRequest,
        isCancelling: isCancelling,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = details.statusToneColor;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 10.h, bottom: 6.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.borderColor,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        details.typeName,
                        style: AppTextStyles.text18.copyWith(
                          color: AppColors.textColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${details.typeKindLabel} • Requested on ${details.requestedAt.length >= 10 ? details.requestedAt.substring(0, 10) : details.requestedAt}',
                        style: AppTextStyles.text12.copyWith(
                          color: AppColors.subTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    details.statusLabel.toUpperCase(),
                    style: AppTextStyles.text10.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(color: AppColors.borderColor, height: 1.h),

          // Scrollable Audit Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Amount & Balance Highlight Card
                  _buildSummaryHero(statusColor),

                  AppSpaces.vSpace14,

                  // 2. Reason / Purpose Section
                  if (details.reason != null && details.reason!.isNotEmpty) ...[
                    _buildReasonCard(),
                    AppSpaces.vSpace14,
                  ],

                  // 3. Payout Details Card (if disbursed)
                  if (details.payout != null) ...[
                    _buildPayoutCard(details.payout!),
                    AppSpaces.vSpace14,
                  ],

                  // 4. Repayment Schedule (if loan/advance)
                  if (details.schedule.isNotEmpty) ...[
                    _buildScheduleSection(),
                    AppSpaces.vSpace14,
                  ],

                  // 5. Expense Lines (if expense claim)
                  if (details.lines.isNotEmpty) ...[
                    _buildExpenseLinesSection(),
                    AppSpaces.vSpace14,
                  ],

                  // 6. Recoveries Record (if any)
                  if (details.recoveries.isNotEmpty) ...[
                    _buildRecoveriesSection(),
                    AppSpaces.vSpace14,
                  ],

                  AppSpaces.vSpace20,
                ],
              ),
            ),
          ),

          // Bottom Action: Withdraw Request if Pending
          if (details.isPending && onCancelRequest != null)
            Container(
              padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 16.h),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                border: Border(
                  top: BorderSide(color: AppColors.borderColor, width: 1.w),
                ),
              ),
              child: SafeArea(
                top: false,
                child: CustomButton(
                  isOutlined: true,
                  borderColor: AppColors.error,
                  textColor: AppColors.error,
                  isLoading: isCancelling,
                  text: 'Withdraw Pending Request',
                  icon: Icon(
                    Icons.cancel_outlined,
                    color: AppColors.error,
                    size: 18.sp,
                  ),
                  onPressed: () => _showCancelDialog(context),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryHero(Color statusColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.accentNavy,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL REQUESTED',
                style: AppTextStyles.text10.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
              Text(
                details.currency,
                style: AppTextStyles.text10.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          AppSpaces.vSpace6,
          Text(
            details.amountText,
            style: AppTextStyles.text24.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (details.repayable) ...[
            AppSpaces.vSpace10,
            Divider(color: Colors.white.withValues(alpha: 0.15), height: 1.h),
            AppSpaces.vSpace10,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryHeroItem(
                  'Outstanding Balance',
                  details.balanceText ?? details.amountText,
                ),
                _buildSummaryHeroItem(
                  'Instalments',
                  '${details.instalments ?? 1} Months',
                ),
                _buildSummaryHeroItem(
                  'Monthly Recovery',
                  details.instalmentText ?? '—',
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryHeroItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.text10.copyWith(
            color: Colors.white70,
          ),
        ),
        AppSpaces.vSpace2,
        Text(
          value,
          style: AppTextStyles.text12.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildReasonCard() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderColor, width: 1.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PURPOSE / REASON',
            style: AppTextStyles.text10.copyWith(
              color: AppColors.subTextColor,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          AppSpaces.vSpace6,
          Text(
            details.reason!,
            style: AppTextStyles.text14.copyWith(
              color: AppColors.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayoutCard(MoneyPayoutModel payout) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderColor, width: 1.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.payment_rounded,
                  size: 16.sp, color: AppColors.secondary),
              AppSpaces.hSpace8,
              Text(
                'DISBURSEMENT & PAYOUT',
                style: AppTextStyles.text12.copyWith(
                  color: AppColors.textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 11.sp,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          AppSpaces.vSpace10,
          Wrap(
            spacing: 16.w,
            runSpacing: 10.h,
            children: [
              _buildPayoutDetailItem('Method', payout.methodLabel),
              if (payout.paidOutOn != null)
                _buildPayoutDetailItem('Disbursed On', payout.paidOutOn!),
              if (payout.reference != null)
                _buildPayoutDetailItem('Reference', payout.reference!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPayoutDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTextStyles.text10.copyWith(
            color: AppColors.subTextColor,
            fontSize: 9.sp,
          ),
        ),
        AppSpaces.vSpace2,
        Text(
          value,
          style: AppTextStyles.text12.copyWith(
            color: AppColors.textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderColor, width: 1.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event_repeat_rounded,
                  size: 16.sp, color: AppColors.primary),
              AppSpaces.hSpace8,
              Text(
                'REPAYMENT SCHEDULE',
                style: AppTextStyles.text12.copyWith(
                  color: AppColors.textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 11.sp,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          AppSpaces.vSpace10,
          ...details.schedule.map((entry) => Container(
                margin: EdgeInsets.only(bottom: 6.h),
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: AppColors.borderColor, width: 1.w),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.period,
                          style: AppTextStyles.text14.copyWith(
                            color: AppColors.textColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13.sp,
                          ),
                        ),
                        Text(
                          'Owed After: ${entry.owedAfterText}',
                          style: AppTextStyles.text10.copyWith(
                            color: AppColors.subTextColor,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          entry.amountText,
                          style: AppTextStyles.text14.copyWith(
                            color: AppColors.textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        AppSpaces.hSpace8,
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: entry.stateColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            entry.stateLabel,
                            style: AppTextStyles.text10.copyWith(
                              color: entry.stateColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildExpenseLinesSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderColor, width: 1.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.list_alt_rounded,
                  size: 16.sp, color: AppColors.secondary),
              AppSpaces.hSpace8,
              Text(
                'ITEMIZED EXPENSE LINES',
                style: AppTextStyles.text12.copyWith(
                  color: AppColors.textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 11.sp,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          AppSpaces.vSpace10,
          ...details.lines.map((line) => Container(
                margin: EdgeInsets.only(bottom: 6.h),
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: AppColors.borderColor, width: 1.w),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            line.spentOn,
                            style: AppTextStyles.text12.copyWith(
                              color: AppColors.subTextColor,
                              fontSize: 11.sp,
                            ),
                          ),
                          if (line.note != null && line.note!.isNotEmpty)
                            Text(
                              line.note!,
                              style: AppTextStyles.text14.copyWith(
                                color: AppColors.textColor,
                                fontSize: 13.sp,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          line.amountText,
                          style: AppTextStyles.text14.copyWith(
                            color: AppColors.textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (line.hasReceipt) ...[
                          AppSpaces.hSpace6,
                          Icon(
                            Icons.attach_file_rounded,
                            size: 15.sp,
                            color: AppColors.secondary,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildRecoveriesSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderColor, width: 1.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_outline_rounded,
                  size: 16.sp, color: AppColors.success),
              AppSpaces.hSpace8,
              Text(
                'PAYROLL RECOVERIES',
                style: AppTextStyles.text12.copyWith(
                  color: AppColors.textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 11.sp,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          AppSpaces.vSpace10,
          ...details.recoveries.map((rec) => Padding(
                padding: EdgeInsets.symmetric(vertical: 4.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${rec.period ?? "Deduction"} (${rec.sourceLabel})',
                      style: AppTextStyles.text12.copyWith(
                        color: AppColors.textColor,
                      ),
                    ),
                    Text(
                      rec.amountText,
                      style: AppTextStyles.text14.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    final reasonCtrl = TextEditingController();

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: AppColors.borderColor, width: 1.w),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20.r,
                offset: Offset(0, 8.h),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Warning Icon & Close
              Row(
                children: [
                  Container(
                    width: 40.r,
                    height: 40.r,
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      size: 22.sp,
                      color: AppColors.error,
                    ),
                  ),
                  AppSpaces.hSpace12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Withdraw Request?',
                          style: AppTextStyles.text16.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                        AppSpaces.vSpace2,
                        Text(
                          'Action cannot be reversed',
                          style: AppTextStyles.text10.copyWith(
                            color: AppColors.subTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => Get.back(),
                    borderRadius: BorderRadius.circular(16.r),
                    child: Container(
                      padding: EdgeInsets.all(6.r),
                      decoration: BoxDecoration(
                        color: AppColors.inputFill,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.borderColor,
                          width: 1.w,
                        ),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 16.sp,
                        color: AppColors.subTextColor,
                      ),
                    ),
                  ),
                ],
              ),

              AppSpaces.vSpace16,

              Text(
                'Are you sure you want to withdraw this pending money request from review?',
                style: AppTextStyles.text12.copyWith(
                  color: AppColors.textColor,
                  height: 1.4,
                ),
              ),

              AppSpaces.vSpace14,

              Text(
                'Reason for Cancellation',
                style: AppTextStyles.text10.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: AppColors.subTextColor,
                ),
              ),
              AppSpaces.vSpace6,

              CustomTextField(
                controller: reasonCtrl,
                hintText: 'Enter reason (optional, max 500 chars)...',
                maxLines: 3,
                maxLength: 500,
                keyboardType: TextInputType.multiline,
              ),

              AppSpaces.vSpace16,

              // Action Buttons Row
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Keep Request',
                      isOutlined: true,
                      height: 44.h,
                      borderRadius: 12.r,
                      onPressed: () => Get.back(),
                    ),
                  ),
                  AppSpaces.hSpace10,
                  Expanded(
                    child: CustomButton(
                      text: 'Withdraw',
                      backgroundColor: AppColors.error,
                      textColor: AppColors.white,
                      height: 44.h,
                      borderRadius: 12.r,
                      onPressed: () async {
                        final reason = reasonCtrl.text.trim();
                        Get.back(); // close dialog
                        Get.back(); // close details bottom sheet
                        if (onCancelRequest != null) {
                          await onCancelRequest!(reason);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
