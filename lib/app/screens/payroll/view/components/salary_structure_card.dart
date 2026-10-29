import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/string_extensions.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../model/payroll_model.dart';

/// Signature Floating Card displaying active salary structure and formula lines
/// from GET /api/v1/me/salary. Adheres strictly to .agents/rules/ams.md.
class SalaryStructureCard extends StatelessWidget {
  final SalaryStructureModel salary;

  const SalaryStructureCard({super.key, required this.salary});

  @override
  Widget build(BuildContext context) {
    return Container(
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Overview Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(7.w),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(
                              Icons.account_balance_wallet_rounded,
                              size: 18.sp,
                              color: AppColors.secondary,
                            ),
                          ),
                          AppSpaces.hSpace8,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Active Salary Structure',
                                style: AppTextStyles.text14.copyWith(
                                  color: AppColors.textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.sp,
                                ),
                              ),
                              Text(
                                'Effective from: ${salary.effectiveFrom.isNotEmpty ? salary.effectiveFrom : "Current"}',
                                style: AppTextStyles.text12.copyWith(
                                  color: AppColors.subTextColor,
                                  fontSize: 11.sp,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Currency Pill
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          salary.currency,
                          style: AppTextStyles.text12.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 11.sp,
                          ),
                        ),
                      ),
                    ],
                  ),

                  AppSpaces.vSpace12,
                  Divider(color: AppColors.borderColor, height: 1.h),
                  AppSpaces.vSpace12,

                  // Terms & Disbursement Details Grid
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoTile('Schedule', salary.schedule),
                      _buildInfoTile('Basis', salary.basis),
                      _buildInfoTile('Disbursement', salary.paymentMethod),
                    ],
                  ),

                  AppSpaces.vSpace12,

                  // Social Security Enrollment Banner
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: salary.socialSecurityEnrolled
                          ? AppColors.secondary.withValues(alpha: 0.08)
                          : AppColors.borderColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          salary.socialSecurityEnrolled
                              ? Icons.verified_user_rounded
                              : Icons.info_outline_rounded,
                          size: 16.sp,
                          color: salary.socialSecurityEnrolled
                              ? AppColors.secondary
                              : AppColors.subTextColor,
                        ),
                        AppSpaces.hSpace8,
                        Expanded(
                          child: Text(
                            salary.socialSecurityEnrolled
                                ? 'Enrolled in Social Security (EOBI & Pension Coverage)'
                                : 'Not currently enrolled in Social Security',
                            style: AppTextStyles.text12.copyWith(
                              color: salary.socialSecurityEnrolled
                                  ? AppColors.textColor
                                  : AppColors.subTextColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 11.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  AppSpaces.vSpace14,
                  Text(
                    'FORMULA & SALARY COMPONENTS',
                    style: AppTextStyles.text12.copyWith(
                      color: AppColors.subTextColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 11.sp,
                      letterSpacing: 0.5,
                    ),
                  ),
                  AppSpaces.vSpace8,

                  // Formula Lines List
                  if (salary.lines.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      child: Center(
                        child: Text(
                          'No formula lines configured',
                          style: AppTextStyles.text12.copyWith(
                            color: AppColors.subTextColor,
                          ),
                        ),
                      ),
                    )
                  else
                    ...salary.lines.map(
                      (line) => Container(
                        margin: EdgeInsets.only(bottom: 8.h),
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundColor,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: AppColors.borderColor,
                            width: 1.w,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6.w,
                                    vertical: 2.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: line.kind == 'earning'
                                        ? AppColors.secondary.withValues(
                                            alpha: 0.12,
                                          )
                                        : AppColors.error.withValues(
                                            alpha: 0.12,
                                          ),
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: Text(
                                    line.code,
                                    style: AppTextStyles.text10.copyWith(
                                      color: line.kind == 'earning'
                                          ? AppColors.secondary
                                          : AppColors.error,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                AppSpaces.hSpace8,
                                Text(
                                  line.name,
                                  style: AppTextStyles.text14.copyWith(
                                    color: AppColors.textColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13.sp,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              line.percent != null && line.percent!.isNotEmpty
                                  ? '${line.percent}%'
                                  : (line.amountText ?? '—'),
                              style: AppTextStyles.text14.copyWith(
                                color: AppColors.textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  AppSpaces.vSpace8,
                  Text(
                    '* Percentage components are computed on active basis lines during monthly finalisation.',
                    style: AppTextStyles.text10.copyWith(
                      color: AppColors.subTextColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 3.w, color: AppColors.secondary),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTextStyles.text10.copyWith(
            color: AppColors.subTextColor,
            fontSize: 9.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        AppSpaces.vSpace2,
        Text(
          value.isNotEmpty ? value.capitalizeFirst ?? "N/A" : '—',
          style: AppTextStyles.text12.copyWith(
            color: AppColors.textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
