import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../controller/profile_controller.dart';

class ProfileBankTab extends GetView<ProfileController> {
  const ProfileBankTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final p = controller.profile.value;
      final accountTitle = p?.name ?? 'Maryam Malik';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32.r,
                          height: 32.r,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.account_balance_outlined,
                            size: 16.sp,
                            color: AppColors.primary,
                          ),
                        ),
                        AppSpaces.hSpace8,
                        Text(
                          'Salary Disbursal Account',
                          style: AppTextStyles.text14.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        'Active',
                        style: AppTextStyles.text10.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpaces.vSpace14,
                _buildInfoRow('Account Title', accountTitle, Icons.badge_outlined),
                _buildDivider(),
                _buildInfoRow('Payroll Bank', 'Corporate Partner Bank', Icons.account_balance_rounded),
                _buildDivider(),
                _buildInfoRow('IBAN / Account', 'PK82 •••• •••• 9284', Icons.credit_card_outlined),
                _buildDivider(),
                _buildInfoRow('Disbursal Schedule', 'Monthly Automated Deposit', Icons.calendar_month_outlined),
                _buildDivider(),
                _buildInfoRow('Salary Currency', 'PKR (Pakistani Rupee)', Icons.payments_outlined),
              ],
            ),
          ),

          AppSpaces.vSpace14,

          // Security Notice Card
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.25),
                width: 1.w,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.shield_outlined,
                  size: 18.sp,
                  color: AppColors.secondary,
                ),
                AppSpaces.hSpace8,
                Expanded(
                  child: Text(
                    'Salary account modifications require two-factor verification and HR approval. To update your bank account details, please contact Finance.',
                    style: AppTextStyles.text10.copyWith(
                      color: AppColors.textColor,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 15.sp, color: AppColors.secondary),
        AppSpaces.hSpace8,
        Text(
          label,
          style: AppTextStyles.text12.copyWith(
            color: AppColors.subTextColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        AppSpaces.hSpace8,
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 3,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.text12.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Divider(
        height: 1.h,
        color: AppColors.borderColor.withValues(alpha: 0.6),
      ),
    );
  }
}
