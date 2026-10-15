import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_spaces.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../controller/kiosk_employee_controller.dart';

class KioskEmployeeProfileBanner extends GetView<KioskEmployeeController> {
  const KioskEmployeeProfileBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final p = controller.profile.value;
      final name = p?.name ?? 'Muhammad Zeeshan';
      final role = p?.designation ?? 'Senior Flutter Developer';
      final id = p?.id ?? 'EMP-0482';
      final dept = p?.department ?? 'Software Engineering';
      final shift = p?.shift ?? 'Morning General (09:00 AM - 06:00 PM)';
      final isCheckedIn = p?.isCheckedIn ?? true;

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(
            color: AppColors.borderColor.withValues(alpha: 0.8),
            width: 1.w,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 24.r,
              offset: Offset(0, 10.h),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Avatar with presence badge
                Stack(
                  children: [
                    Container(
                      width: 52.r,
                      height: 52.r,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            blurRadius: 10.r,
                            offset: Offset(0, 4.h),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join(),
                          style: AppTextStyles.text18.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 14.r,
                        height: 14.r,
                        decoration: BoxDecoration(
                          color: isCheckedIn ? AppColors.success : AppColors.error,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.white, width: 2.w),
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpaces.hSpace12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: AppTextStyles.text16.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              id,
                              style: AppTextStyles.text10.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      AppSpaces.vSpace2,
                      Text(
                        role,
                        style: AppTextStyles.text12.copyWith(
                          color: AppColors.subTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        dept,
                        style: AppTextStyles.text10.copyWith(
                          color: AppColors.subTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            AppSpaces.vSpace14,
            Divider(color: AppColors.borderColor, height: 1.h),
            AppSpaces.vSpace10,

            // Shift Capsule
            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 14.sp,
                  color: AppColors.secondary,
                ),
                AppSpaces.hSpace6,
                Expanded(
                  child: Text(
                    shift,
                    style: AppTextStyles.text10.copyWith(
                      color: AppColors.textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    'Checked-In: 08:54 AM',
                    style: AppTextStyles.text10.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
