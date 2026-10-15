import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_spaces.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../controller/kiosk_employee_controller.dart';

class KioskSecurityTimerBar extends GetView<KioskEmployeeController> {
  const KioskSecurityTimerBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final seconds = controller.remainingSeconds.value;
      final progress = seconds / KioskEmployeeController.totalIdleDurationSeconds;
      final isUrgent = seconds <= 15;

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isUrgent
              ? AppColors.error.withValues(alpha: 0.12)
              : AppColors.secondary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isUrgent ? AppColors.error : AppColors.secondary,
            width: 1.w,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.timer_rounded,
                      size: 16.sp,
                      color: isUrgent ? AppColors.error : AppColors.secondary,
                    ),
                    AppSpaces.hSpace6,
                    Text(
                      'Terminal Auto-Clear Timer',
                      style: AppTextStyles.text12.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isUrgent ? AppColors.error : AppColors.secondary,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${seconds}s remaining',
                  style: AppTextStyles.text12.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isUrgent ? AppColors.error : AppColors.textColor,
                  ),
                ),
              ],
            ),
            AppSpaces.vSpace8,
            ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4.h,
                backgroundColor: AppColors.borderColor,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isUrgent ? AppColors.error : AppColors.secondary,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
