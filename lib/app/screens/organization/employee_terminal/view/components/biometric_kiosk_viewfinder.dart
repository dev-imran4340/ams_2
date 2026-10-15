import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_spaces.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../controller/employee_terminal_controller.dart';

class BiometricKioskViewfinder extends GetView<EmployeeTerminalController> {
  const BiometricKioskViewfinder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 20.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.r),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            border: Border(
              bottom: BorderSide(
                color: AppColors.secondary,
                width: 3.w,
              ),
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top Status Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.face_retouching_natural_rounded,
                          size: 13.sp,
                          color: AppColors.secondary,
                        ),
                        AppSpaces.hSpace4,
                        Text(
                          '1:N AI Face Stream',
                          style: AppTextStyles.text10.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 6.r,
                        height: 6.r,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      AppSpaces.hSpace4,
                      Text(
                        'Continuous Scan',
                        style: AppTextStyles.text10.copyWith(
                          color: AppColors.subTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              AppSpaces.vSpace16,

              // Oval Viewfinder with Animated Pulsing Concentric Radar Rings
              SizedBox(
                width: 220.w,
                height: 220.h,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer Pulsing Radar Ring
                    AnimatedBuilder(
                      animation: controller.pulseAnimation,
                      builder: (context, child) {
                        final scale = controller.pulseAnimation.value;
                        return Transform.scale(
                          scale: scale,
                          child: Container(
                            width: 175.w,
                            height: 215.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.elliptical(87.5.w, 107.5.h),
                              ),
                              border: Border.all(
                                color: AppColors.secondary.withValues(
                                  alpha: (0.4 * (1.1 - scale)).clamp(0.08, 0.4),
                                ),
                                width: 1.5.w,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // Main Viewfinder Oval Camera Frame
                    Container(
                      width: 160.w,
                      height: 200.h,
                      decoration: BoxDecoration(
                        color: AppColors.inputFill,
                        borderRadius: BorderRadius.all(
                          Radius.elliptical(80.w, 100.h),
                        ),
                        border: Border.all(
                          color: AppColors.secondary,
                          width: 2.w,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondary.withValues(alpha: 0.16),
                            blurRadius: 18.r,
                            spreadRadius: 2.r,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Face Silhouette Guide
                          Icon(
                            Icons.person_rounded,
                            size: 94.sp,
                            color: AppColors.primary.withValues(alpha: 0.12),
                          ),

                          // Biometric Guide Grid
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.center_focus_strong_rounded,
                                size: 36.sp,
                                color: AppColors.secondary,
                              ),
                              AppSpaces.vSpace6,
                              Text(
                                'AI Vision Active',
                                style: AppTextStyles.text8.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.secondary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),

                          // Top Scanner Indicator
                          Positioned(
                            top: 10.h,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                'STATION 01',
                                style: AppTextStyles.text6.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              AppSpaces.vSpace12,

              // Status Chip
              Obx(
                () => Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: AppColors.borderColor, width: 1.w),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (controller.isPunchProcessing.value) ...[
                        SizedBox(
                          width: 12.r,
                          height: 12.r,
                          child: CircularProgressIndicator(
                            color: AppColors.secondary,
                            strokeWidth: 2.w,
                          ),
                        ),
                        AppSpaces.hSpace6,
                      ] else ...[
                        Icon(
                          Icons.radar_rounded,
                          size: 14.sp,
                          color: AppColors.secondary,
                        ),
                        AppSpaces.hSpace6,
                      ],
                      Text(
                        controller.kioskStatusMessage.value,
                        style: AppTextStyles.text10.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              AppSpaces.vSpace16,

              // Action Trigger Button for Prototyping
              Obx(
                () => CustomButton(
                  text: 'Simulate Live Face Punch',
                  isGradient: true,
                  isLoading: controller.isPunchProcessing.value,
                  icon: Icon(
                    Icons.face_unlock_rounded,
                    size: 18.sp,
                    color: AppColors.white,
                  ),
                  onPressed: controller.isPunchProcessing.value
                      ? null
                      : controller.simulateBiometricDetection,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
