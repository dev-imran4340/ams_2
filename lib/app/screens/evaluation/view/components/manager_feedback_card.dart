import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../controller/evaluation_controller.dart';

class ManagerFeedbackCard extends GetView<EvaluationController> {
  const ManagerFeedbackCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final report = controller.reportData.value;
      if (report == null || report.managerFeedback.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.borderColor,
            width: 1.w,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.05),
              blurRadius: 16.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Reviewer Avatar, Name, Role & Verified Signature Pill
            Row(
              children: [
                // Avatar
                Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.secondary,
                      width: 1.5.w,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      report.evaluatedBy.isNotEmpty ? report.evaluatedBy[0] : 'H',
                      style: AppTextStyles.text14.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                AppSpaces.hSpace10,

                // Name & Role
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.evaluatedBy,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.text12.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                      AppSpaces.vSpace2,
                      Text(
                        'Engineering Appraisal Committee',
                        style: AppTextStyles.text10.copyWith(
                          color: AppColors.subTextColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Digital Signature Pill
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 3.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: AppColors.secondary.withValues(alpha: 0.3),
                      width: 0.8.w,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_user_rounded,
                        size: 11.sp,
                        color: AppColors.secondary,
                      ),
                      AppSpaces.hSpace4,
                      Text(
                        'Signed',
                        style: AppTextStyles.text10.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            AppSpaces.vSpace14,

            // Quote Box
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.inputFill.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12.r),
                border: Border(
                  left: BorderSide(
                    color: AppColors.secondary,
                    width: 3.w,
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.format_quote_rounded,
                    size: 20.sp,
                    color: AppColors.secondary,
                  ),
                  AppSpaces.hSpace8,
                  Expanded(
                    child: Text(
                      report.managerFeedback,
                      style: AppTextStyles.text12.copyWith(
                        fontStyle: FontStyle.italic,
                        color: AppColors.textColor,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
