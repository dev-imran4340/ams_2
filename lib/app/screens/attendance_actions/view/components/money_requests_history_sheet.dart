import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../controller/attendance_actions_controller.dart';
import '../../model/attendance_actions_model.dart';

class MoneyRequestsHistorySheet extends GetView<AttendanceActionsController> {
  const MoneyRequestsHistorySheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: 0.85.sh),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 30.r,
            offset: Offset(0, -10.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 44.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.borderColor,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),

          AppSpaces.vSpace14,

          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Financial Requests Log',
                    style: AppTextStyles.text18.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  AppSpaces.vSpace2,
                  Text(
                    'Past salary advances, loans & approvals',
                    style: AppTextStyles.text10.copyWith(
                      color: AppColors.subTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Get.back(),
                icon: Icon(
                  Icons.close_rounded,
                  color: AppColors.subTextColor,
                  size: 22.sp,
                ),
              ),
            ],
          ),

          AppSpaces.vSpace12,

          // List of Requests
          Expanded(
            child: Obx(() {
              if (controller.isLoadingMoneyRequests.value) {
                return Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5.w,
                    color: AppColors.primary,
                  ),
                );
              }

              final list = controller.moneyRequests;
              if (list.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 48.sp,
                        color: AppColors.hintColor,
                      ),
                      AppSpaces.vSpace12,
                      Text(
                        'No Requests Found',
                        style: AppTextStyles.text14.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                      AppSpaces.vSpace4,
                      Text(
                        'You have not submitted any financial requests yet.',
                        style: AppTextStyles.text10.copyWith(
                          color: AppColors.subTextColor,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                itemCount: list.length,
                separatorBuilder: (context, index) => AppSpaces.vSpace12,
                itemBuilder: (context, index) {
                  final item = list[index];
                  return _buildRequestItem(item);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestItem(MoneyRequestItem item) {
    Color statusColor;
    Color statusBgColor;

    switch (item.status.toLowerCase()) {
      case 'approved':
        statusColor = AppColors.onTimeColor;
        statusBgColor = AppColors.onTimeColor.withValues(alpha: 0.12);
        break;
      case 'disbursed':
        statusColor = AppColors.info;
        statusBgColor = AppColors.info.withValues(alpha: 0.12);
        break;
      case 'rejected':
        statusColor = AppColors.absentColor;
        statusBgColor = AppColors.absentColor.withValues(alpha: 0.12);
        break;
      default:
        statusColor = AppColors.warning;
        statusBgColor = AppColors.warning.withValues(alpha: 0.12);
    }

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.borderColor, width: 1.w),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Category, Reference ID & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(7.r),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 16.sp,
                      color: AppColors.secondary,
                    ),
                  ),
                  AppSpaces.hSpace8,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.type,
                        style: AppTextStyles.text14.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                      Text(
                        item.id,
                        style: AppTextStyles.text10.copyWith(
                          color: AppColors.subTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Status Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  item.status,
                  style: AppTextStyles.text10.copyWith(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),

          AppSpaces.vSpace12,

          // Details Row: Amount, Tenure, Monthly Deduction
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.inputFill.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Requested',
                      style: AppTextStyles.text10.copyWith(
                        color: AppColors.subTextColor,
                      ),
                    ),
                    AppSpaces.vSpace2,
                    Text(
                      '${item.currency} ${item.amount.toStringAsFixed(0)}',
                      style: AppTextStyles.text12.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tenure',
                      style: AppTextStyles.text10.copyWith(
                        color: AppColors.subTextColor,
                      ),
                    ),
                    AppSpaces.vSpace2,
                    Text(
                      '${item.tenureMonths} Months',
                      style: AppTextStyles.text12.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Date',
                      style: AppTextStyles.text10.copyWith(
                        color: AppColors.subTextColor,
                      ),
                    ),
                    AppSpaces.vSpace2,
                    Text(
                      item.requestDate,
                      style: AppTextStyles.text12.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (item.reason.isNotEmpty) ...[
            AppSpaces.vSpace8,
            Text(
              item.reason,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.text10.copyWith(
                color: AppColors.subTextColor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
