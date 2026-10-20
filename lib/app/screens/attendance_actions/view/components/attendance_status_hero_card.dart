import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../controller/attendance_actions_controller.dart';

class AttendanceStatusHeroCard extends GetView<AttendanceActionsController> {
  const AttendanceStatusHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final t = controller.telemetry.value;
      final name = t?.employeeName ?? 'Malik Muhammad Imran';
      final designation = t?.designation ?? 'Senior Software Engineer';
      final isRemote = t?.isRemote ?? false;
      final isInside = t?.isInsidePerimeter ?? true;
      final shiftName = t?.shiftName ?? 'General Morning Shift';
      final shiftTiming = t?.shiftTiming ?? '09:00 AM - 06:00 PM';

      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.borderColor, width: 1.w),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 20.r,
              offset: Offset(0, 8.h),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Corporate Gradient Banner
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.accentNavy],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    // Avatar with Online Green Dot
                    Stack(
                      children: [
                        Container(
                          width: 46.r,
                          height: 46.r,
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.white.withValues(alpha: 0.35),
                              width: 1.5.w,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : 'M',
                            style: AppTextStyles.text20.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 12.r,
                            height: 12.r,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.successMint,
                              border: Border.all(
                                color: AppColors.primary,
                                width: 2.w,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    AppSpaces.hSpace12,

                    // Name & Designation
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.text16.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                          AppSpaces.vSpace2,
                          Text(
                            designation,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.text10.copyWith(
                              color: AppColors.white.withValues(alpha: 0.75),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    AppSpaces.hSpace8,

                    // On-Site / Remote Mode Toggle Pill
                    InkWell(
                      onTap: controller.toggleWorkMode,
                      borderRadius: BorderRadius.circular(20.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          color: isRemote
                              ? AppColors.secondary.withValues(alpha: 0.25)
                              : AppColors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: isRemote
                                ? AppColors.secondary
                                : AppColors.white.withValues(alpha: 0.35),
                            width: 1.w,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6.r,
                              height: 6.r,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isRemote
                                    ? AppColors.secondary
                                    : AppColors.successMint,
                              ),
                            ),
                            AppSpaces.hSpace6,
                            Text(
                              isRemote ? 'REMOTE' : 'ON-SITE',
                              style: AppTextStyles.text10.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.4,
                              ),
                            ),
                            AppSpaces.hSpace4,
                            Icon(
                              Icons.sync_alt_rounded,
                              size: 12.sp,
                              color: AppColors.white.withValues(alpha: 0.8),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Shift & Geofence Telemetry Row
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                color: AppColors.inputFill.withValues(alpha: 0.5),
                child: Row(
                  children: [
                    // Shift Details
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time_filled_rounded,
                            size: 14.sp,
                            color: AppColors.secondary,
                          ),
                          AppSpaces.hSpace6,
                          Expanded(
                            child: Text(
                              '$shiftName ($shiftTiming)',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.text12.copyWith(
                                color: AppColors.textColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    AppSpaces.hSpace8,

                    // Perimeter Status Radar
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: isInside
                            ? AppColors.onTimeColor.withValues(alpha: 0.1)
                            : AppColors.absentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 5.r,
                            height: 5.r,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isInside
                                  ? AppColors.onTimeColor
                                  : AppColors.absentColor,
                            ),
                          ),
                          AppSpaces.hSpace4,
                          Text(
                            isInside ? 'In Perimeter' : 'Out of Range',
                            style: AppTextStyles.text10.copyWith(
                              color: isInside
                                  ? AppColors.onTimeColor
                                  : AppColors.absentColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
