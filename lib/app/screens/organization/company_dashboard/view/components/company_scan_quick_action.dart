import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_spaces.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../controller/company_dashboard_controller.dart';

class CompanyScanQuickAction extends GetView<CompanyDashboardController> {
  const CompanyScanQuickAction({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: controller.launchAttendanceScanner,
      borderRadius: BorderRadius.circular(15.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.secondary,
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(15.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.25),
              blurRadius: 18.r,
              offset: Offset(0, 8.h),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48.r,
              height: 48.r,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.3),
                  width: 1.w,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.qr_code_scanner_rounded,
                  color: AppColors.white,
                  size: 26.sp,
                ),
              ),
            ),
            AppSpaces.hSpace12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scan Employee QR',
                    style: AppTextStyles.text14.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                  AppSpaces.vSpace2,
                  Text(
                    'Scan employee QR code & face recognition for attendance',
                    style: AppTextStyles.text10.copyWith(
                      color: AppColors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.white,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }
}
