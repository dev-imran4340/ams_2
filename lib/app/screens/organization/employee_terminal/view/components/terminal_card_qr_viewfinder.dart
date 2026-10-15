import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_spaces.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../controller/employee_terminal_controller.dart';

class TerminalCardQrViewfinder extends GetView<EmployeeTerminalController> {
  const TerminalCardQrViewfinder({super.key});

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
                      color: AppColors.blue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.qr_code_scanner_rounded,
                          size: 13.sp,
                          color: AppColors.blue,
                        ),
                        AppSpaces.hSpace4,
                        Text(
                          'Hardware QR / Barcode',
                          style: AppTextStyles.text10.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'High-Speed Intake',
                    style: AppTextStyles.text10.copyWith(
                      color: AppColors.subTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              AppSpaces.vSpace16,

              // Rounded Rectangular Scanner Frame with Moving Laser Sweep Line
              Container(
                width: 220.w,
                height: 200.h,
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: AppColors.secondary,
                    width: 2.w,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.14),
                      blurRadius: 16.r,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Corner Reticle Guides
                    Padding(
                      padding: EdgeInsets.all(12.r),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.secondary.withValues(alpha: 0.3),
                            width: 1.w,
                          ),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),

                    // Central Card QR Emblem
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.credit_card_rounded,
                          size: 44.sp,
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                        AppSpaces.vSpace6,
                        Text(
                          'Align Employee Card QR',
                          style: AppTextStyles.text10.copyWith(
                            color: AppColors.subTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    // Animated Moving Cyan Laser Sweep Line
                    AnimatedBuilder(
                      animation: controller.pulseAnimation,
                      builder: (context, child) {
                        final progress = controller.pulseController.value;
                        final topOffset = 18.h + (160.h * progress);

                        return Positioned(
                          top: topOffset,
                          left: 20.w,
                          right: 20.w,
                          child: Container(
                            height: 2.5.h,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  AppColors.secondary,
                                  AppColors.liteSecondary,
                                  AppColors.secondary,
                                  Colors.transparent,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.secondary.withValues(alpha: 0.8),
                                  blurRadius: 8.r,
                                  spreadRadius: 1.r,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              AppSpaces.vSpace12,

              // Guidance Text
              Text(
                'Hold physical ID card steady in front of the lens for instant attendance logging.',
                textAlign: TextAlign.center,
                style: AppTextStyles.text12.copyWith(
                  color: AppColors.subTextColor,
                  height: 1.4,
                ),
              ),

              AppSpaces.vSpace16,

              // Action Trigger Button for Prototyping
              Obx(
                () => CustomButton(
                  text: 'Simulate Card QR Scan',
                  isGradient: true,
                  isLoading: controller.isPunchProcessing.value,
                  icon: Icon(
                    Icons.qr_code_2_rounded,
                    size: 18.sp,
                    color: AppColors.white,
                  ),
                  onPressed: controller.isPunchProcessing.value
                      ? null
                      : () => controller.handleQrScanned('EMP-QR-SAMPLE-TOKEN'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
