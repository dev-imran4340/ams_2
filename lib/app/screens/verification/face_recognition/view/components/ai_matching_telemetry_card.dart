import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_spaces.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../controller/face_recognition_controller.dart';

class AiMatchingTelemetryCard extends GetView<FaceRecognitionController> {
  const AiMatchingTelemetryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.15),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 18.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Status Row with Spinner or Checkmark
          Row(
            children: [
              Obx(() {
                final isSuccess = controller.matchSuccess.value;
                return Container(
                  width: 32.r,
                  height: 32.r,
                  decoration: BoxDecoration(
                    color: isSuccess
                        ? AppColors.success.withValues(alpha: 0.2)
                        : AppColors.secondary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isSuccess
                        ? Icon(
                            Icons.check_rounded,
                            size: 18.sp,
                            color: AppColors.success,
                          )
                        : (controller.isVerifying.value
                            ? SizedBox(
                                width: 14.r,
                                height: 14.r,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.w,
                                  color: AppColors.secondary,
                                ),
                              )
                            : Icon(
                                Icons.face_rounded,
                                size: 18.sp,
                                color: AppColors.secondary,
                              )),
                  ),
                );
              }),

              AppSpaces.hSpace10,

              // Status Title & Subtitle with flex protection
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(
                      () => Text(
                        controller.matchSuccess.value
                            ? 'Identity Confirmed'
                            : (controller.isVerifying.value
                                ? 'Analyzing Facial Biometrics'
                                : 'Awaiting Face Alignment'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.text14.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    AppSpaces.vSpace2,
                    Obx(
                      () => Text(
                        controller.statusText.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.text10.copyWith(
                          color: AppColors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Percentage readout badge
              Obx(() {
                final percent = (controller.matchProgress.value * 100).toInt();
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    controller.matchSuccess.value ? '100%' : '$percent%',
                    style: AppTextStyles.text12.copyWith(
                      fontWeight: FontWeight.bold,
                      color: controller.matchSuccess.value
                          ? AppColors.success
                          : AppColors.liteSecondary,
                    ),
                  ),
                );
              }),
            ],
          ),

          AppSpaces.vSpace12,

          // 2. Animated Progress Bar
          Obx(() {
            final progress = controller.matchProgress.value;
            final isSuccess = controller.matchSuccess.value;

            return ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                value: isSuccess ? 1.0 : progress,
                minHeight: 5.h,
                backgroundColor: AppColors.white.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isSuccess ? AppColors.success : AppColors.secondary,
                ),
              ),
            );
          }),

          AppSpaces.vSpace12,

          // 3. Telemetry Metadata & Action Link
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.security_rounded,
                    size: 12.sp,
                    color: AppColors.white.withValues(alpha: 0.6),
                  ),
                  AppSpaces.hSpace4,
                  Text(
                    'ISO/IEC 19794-5 Biometric Standard',
                    style: AppTextStyles.text10.copyWith(
                      color: AppColors.white.withValues(alpha: 0.6),
                      fontSize: 9.sp,
                    ),
                  ),
                ],
              ),

              // Retry Trigger
              GestureDetector(
                onTap: controller.retryVerification,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  child: Row(
                    children: [
                      Icon(
                        Icons.refresh_rounded,
                        size: 12.sp,
                        color: AppColors.liteSecondary,
                      ),
                      AppSpaces.hSpace4,
                      Text(
                        'Restart Scan',
                        style: AppTextStyles.text10.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.liteSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
