import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../model/payroll_model.dart';

/// Signature Floating Card for a finalized payslip in the employee list.
/// Uses centralized CustomCard with 3.w Teal bottom accent and 15.r border radius.
class PayslipCard extends StatelessWidget {
  final PayslipSummaryModel payslip;
  final VoidCallback onTap;
  final VoidCallback onDownloadPdf;
  final bool isDownloading;

  const PayslipCard({
    super.key,
    required this.payslip,
    required this.onTap,
    required this.onDownloadPdf,
    this.isDownloading = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      showBottomAccent: true,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Header: Period, Finalized badge & Quick PDF Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(7.w),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.receipt_long_rounded,
                      size: 18.sp,
                      color: AppColors.secondary,
                    ),
                  ),
                  AppSpaces.hSpace8,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payslip.period.isNotEmpty
                            ? payslip.period
                            : 'Payslip',
                        style: AppTextStyles.text14.copyWith(
                          color: AppColors.textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15.sp,
                        ),
                      ),
                      if (payslip.employer.isNotEmpty)
                        Text(
                          payslip.employer,
                          style: AppTextStyles.text12.copyWith(
                            color: AppColors.subTextColor,
                            fontSize: 11.sp,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              // PDF Download Action
              InkWell(
                onTap: onDownloadPdf,
                borderRadius: BorderRadius.circular(8.r),
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 8.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isDownloading)
                        SizedBox(
                          width: 14.w,
                          height: 14.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.w,
                            color: AppColors.primary,
                          ),
                        )
                      else
                        Icon(
                          Icons.download_rounded,
                          size: 15.sp,
                          color: AppColors.primary,
                        ),
                      AppSpaces.hSpace4,
                      Text(
                        'PDF',
                        style: AppTextStyles.text12.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          AppSpaces.vSpace12,
          Divider(color: AppColors.borderColor, height: 1.h),
          AppSpaces.vSpace12,

          // Middle: Gross Pay, Net Pay Breakdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Gross Pay
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GROSS PAY',
                    style: AppTextStyles.text10.copyWith(
                      color: AppColors.subTextColor,
                      fontSize: 10.sp,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AppSpaces.vSpace2,
                  Text(
                    payslip.grossText.isNotEmpty
                        ? payslip.grossText
                        : '—',
                    style: AppTextStyles.text14.copyWith(
                      color: AppColors.textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),

              // Net Take-Home Pay (Prominent)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'NET TAKE-HOME',
                    style: AppTextStyles.text10.copyWith(
                      color: AppColors.secondary,
                      fontSize: 10.sp,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  AppSpaces.vSpace2,
                  Text(
                    payslip.netText.isNotEmpty
                        ? payslip.netText
                        : '—',
                    style: AppTextStyles.text16.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),

          AppSpaces.vSpace10,

          // Bottom row: Pay date & View Details cue
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 13.sp,
                    color: AppColors.subTextColor,
                  ),
                  AppSpaces.hSpace4,
                  Text(
                    payslip.paysOn.isNotEmpty
                        ? 'Paid: ${payslip.paysOn}'
                        : 'Finalised',
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
                    'View Breakdown',
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
    );
  }
}
