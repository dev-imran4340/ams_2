import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../model/payroll_model.dart';

/// Modal bottom sheet providing comprehensive itemized audit of a finalized payslip.
/// Adheres strictly to .agents/rules/ams.md and doc/api.md Phase 12 schema.
class PayslipDetailsBottomSheet extends StatelessWidget {
  final PayslipDetailsModel details;
  final VoidCallback onDownloadPdf;
  final bool isDownloadingPdf;

  const PayslipDetailsBottomSheet({
    super.key,
    required this.details,
    required this.onDownloadPdf,
    this.isDownloadingPdf = false,
  });

  static void show(
    BuildContext context, {
    required PayslipDetailsModel details,
    required VoidCallback onDownloadPdf,
    bool isDownloadingPdf = false,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PayslipDetailsBottomSheet(
        details: details,
        onDownloadPdf: onDownloadPdf,
        isDownloadingPdf: isDownloadingPdf,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
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
                        details.period?.label.isNotEmpty == true
                            ? details.period!.label
                            : 'Payslip Breakdown',
                        style: AppTextStyles.text18.copyWith(
                          color: AppColors.textColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        details.employer,
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
                    color: AppColors.secondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    details.runStatus.toUpperCase(),
                    style: AppTextStyles.text10.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(color: AppColors.borderColor, height: 1.h),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Employee Info & Payment Method
                  if (details.employee != null)
                    _buildEmployeeCard(details.employee!, details.paymentMethod),

                  AppSpaces.vSpace14,

                  // 2. Attendance & Calendar Days
                  if (details.days != null) _buildDaysCard(details.days!),

                  AppSpaces.vSpace14,

                  // 3. Itemized Earnings
                  _buildSectionCard(
                    title: 'EARNINGS & ALLOWANCES',
                    icon: Icons.add_circle_outline_rounded,
                    iconColor: AppColors.secondary,
                    items: details.earnings,
                    totalText: details.totals?.gross?.text,
                    totalLabel: 'Total Gross Pay',
                  ),

                  AppSpaces.vSpace14,

                  // 4. Itemized Deductions
                  _buildSectionCard(
                    title: 'DEDUCTIONS & TAXES',
                    icon: Icons.remove_circle_outline_rounded,
                    iconColor: AppColors.error,
                    items: details.deductions,
                    totalText: details.totals?.deductions?.text,
                    totalLabel: 'Total Deductions',
                  ),

                  // 5. Employer Contributions (if any)
                  if (details.employerContributions.isNotEmpty) ...[
                    AppSpaces.vSpace14,
                    _buildSectionCard(
                      title: 'EMPLOYER CONTRIBUTIONS',
                      icon: Icons.corporate_fare_rounded,
                      iconColor: AppColors.primary,
                      items: details.employerContributions,
                      totalText: details.totals?.employerCost?.text,
                      totalLabel: 'Employer Cost',
                      subNote:
                          'Paid directly by employer (not subtracted from salary)',
                    ),
                  ],

                  AppSpaces.vSpace14,

                  // 6. Net Take-Home Highlight Card
                  _buildNetSummaryCard(),

                  AppSpaces.vSpace20,
                ],
              ),
            ),
          ),

          // Bottom Action Bar: Download PDF
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
                isGradient: true,
                isLoading: isDownloadingPdf,
                text: 'Download Official PDF',
                icon: Icon(
                  Icons.download_rounded,
                  color: Colors.white,
                  size: 18.sp,
                ),
                onPressed: onDownloadPdf,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard(
      PayslipEmployeeModel emp, String paymentMethod) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderColor, width: 1.w),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                emp.name,
                style: AppTextStyles.text14.copyWith(
                  color: AppColors.textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                emp.number,
                style: AppTextStyles.text12.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          AppSpaces.vSpace6,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${emp.designation} • ${emp.department}',
                style: AppTextStyles.text12.copyWith(
                  color: AppColors.subTextColor,
                  fontSize: 11.sp,
                ),
              ),
              Text(
                paymentMethod,
                style: AppTextStyles.text12.copyWith(
                  color: AppColors.subTextColor,
                  fontSize: 11.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDaysCard(PayslipDaysModel days) {
    final double workedHours = days.workedMinutes / 60.0;

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
            'PERIOD TIME & ATTENDANCE',
            style: AppTextStyles.text10.copyWith(
              color: AppColors.subTextColor,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          AppSpaces.vSpace10,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetric('Calendar Days', '${days.period}'),
              _buildMetric('Paid Days', '${days.paid}'),
              _buildMetric('Unpaid Days', '${days.unpaid}'),
              _buildMetric(
                'Worked Hours',
                workedHours.toStringAsFixed(1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.text14.copyWith(
            color: AppColors.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        AppSpaces.vSpace2,
        Text(
          label,
          style: AppTextStyles.text10.copyWith(
            color: AppColors.subTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<PayslipLineItemModel> items,
    String? totalText,
    required String totalLabel,
    String? subNote,
  }) {
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
              Icon(icon, size: 16.sp, color: iconColor),
              AppSpaces.hSpace8,
              Text(
                title,
                style: AppTextStyles.text12.copyWith(
                  color: AppColors.textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 11.sp,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          if (subNote != null) ...[
            AppSpaces.vSpace4,
            Text(
              subNote,
              style: AppTextStyles.text10.copyWith(
                color: AppColors.subTextColor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          AppSpaces.vSpace8,
          Divider(color: AppColors.borderColor, height: 1.h),
          AppSpaces.vSpace8,

          if (items.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Text(
                'No line items recorded',
                style: AppTextStyles.text12.copyWith(
                  color: AppColors.subTextColor,
                  fontSize: 11.sp,
                ),
              ),
            )
          else
            ...items.map((line) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              line.name,
                              style: AppTextStyles.text14.copyWith(
                                color: AppColors.textColor,
                                fontSize: 13.sp,
                              ),
                            ),
                            if (line.explanation != null &&
                                line.explanation!.isNotEmpty)
                              Text(
                                line.explanation!,
                                style: AppTextStyles.text10.copyWith(
                                  color: AppColors.subTextColor,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        line.amountText,
                        style: AppTextStyles.text14.copyWith(
                          color: AppColors.textColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.sp,
                        ),
                      ),
                    ],
                  ),
                )),

          if (totalText != null) ...[
            AppSpaces.vSpace8,
            Divider(color: AppColors.borderColor, height: 1.h),
            AppSpaces.vSpace8,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  totalLabel,
                  style: AppTextStyles.text12.copyWith(
                    color: AppColors.textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  totalText,
                  style: AppTextStyles.text14.copyWith(
                    color: AppColors.textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNetSummaryCard() {
    final netText = details.totals?.net?.text ?? '—';
    final grossText = details.totals?.gross?.text ?? '—';
    final taxText = details.totals?.tax?.text ?? '—';
    final deductionsText = details.totals?.deductions?.text ?? '—';

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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'NET TAKE-HOME PAY',
                style: AppTextStyles.text12.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 11.sp,
                  letterSpacing: 0.6,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  details.currency,
                  style: AppTextStyles.text10.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          AppSpaces.vSpace6,
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              netText,
              style: AppTextStyles.text22.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          AppSpaces.vSpace10,
          Divider(color: Colors.white.withValues(alpha: 0.15), height: 1.h),
          AppSpaces.vSpace10,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryPill('Gross', grossText),
              _buildSummaryPill('Tax', taxText),
              _buildSummaryPill('Deductions', deductionsText),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryPill(String label, String value) {
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
            fontSize: 11.sp,
          ),
        ),
      ],
    );
  }
}
