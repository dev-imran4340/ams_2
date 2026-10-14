import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_spaces.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../controller/face_recognition_controller.dart';

class FaceMatchingTelemetryCard extends GetView<FaceRecognitionController> {
  const FaceMatchingTelemetryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.18),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.45),
            blurRadius: 20.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Status Indicator Row
          Row(
            children: [
              Obx(() {
                final isSuccess = controller.isMatchSuccess.value;
                final isVerifying = controller.isVerifying.value;

                return Container(
                  width: 36.r,
                  height: 36.r,
                  decoration: BoxDecoration(
                    color: isSuccess
                        ? AppColors.success.withValues(alpha: 0.22)
                        : AppColors.secondary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSuccess
                          ? AppColors.success.withValues(alpha: 0.4)
                          : AppColors.secondary.withValues(alpha: 0.3),
                      width: 1.w,
                    ),
                  ),
                  child: Center(
                    child: isSuccess
                        ? Icon(
                            Icons.check_rounded,
                            size: 20.sp,
                            color: AppColors.success,
                          )
                        : (isVerifying
                            ? SizedBox(
                                width: 16.r,
                                height: 16.r,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5.w,
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    AppColors.secondary,
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.face_rounded,
                                size: 20.sp,
                                color: AppColors.secondary,
                              )),
                  ),
                );
              }),

              AppSpaces.hSpace12,

              // Status Title & Dynamic Step Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(
                      () => Text(
                        controller.isMatchSuccess.value
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
                          color: controller.isMatchSuccess.value
                              ? AppColors.success
                              : AppColors.liteSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Percentage Badge Readout
              Obx(() {
                final percent = (controller.matchProgress.value * 100).toInt();
                return Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: controller.isMatchSuccess.value
                        ? AppColors.success.withValues(alpha: 0.2)
                        : AppColors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    '$percent%',
                    style: AppTextStyles.text10.copyWith(
                      color: controller.isMatchSuccess.value
                          ? AppColors.success
                          : AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }),
            ],
          ),

          AppSpaces.vSpace12,

          // 2. Animated Progress Bar
          Obx(() {
            final isSuccess = controller.isMatchSuccess.value;
            final progress = controller.matchProgress.value;

            return ClipRRect(
              borderRadius: BorderRadius.circular(3.r),
              child: Stack(
                children: [
                  // Track
                  Container(
                    height: 5.h,
                    color: AppColors.white.withValues(alpha: 0.12),
                  ),
                  // Animated Fill
                  FractionallySizedBox(
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(
                      height: 5.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isSuccess
                              ? [AppColors.success, AppColors.successMint]
                              : [AppColors.secondary, AppColors.liteSecondary],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSuccess
                                ? AppColors.success.withValues(alpha: 0.6)
                                : AppColors.secondary.withValues(alpha: 0.6),
                            blurRadius: 6.r,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          AppSpaces.vSpace14,

          // 3. Telemetry Metrics Matrix Row
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.08),
                width: 0.8.w,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Metric 1: Confidence Score
                Obx(() {
                  final score = controller.isMatchSuccess.value
                      ? controller.confidenceReadout.value
                      : (controller.matchProgress.value * 99.4)
                          .toStringAsFixed(1);
                  return _buildTelemetryItem(
                    label: 'Confidence',
                    value: '$score%',
                    valueColor: controller.isMatchSuccess.value
                        ? AppColors.success
                        : AppColors.liteSecondary,
                  );
                }),

                _buildVerticalDivider(),

                // Metric 2: Liveness Protocol
                _buildTelemetryItem(
                  label: 'Liveness',
                  value: 'Active 3D',
                  valueColor: AppColors.liteSecondary,
                ),

                _buildVerticalDivider(),

                // Metric 3: Employee Code
                Obx(
                  () => _buildTelemetryItem(
                    label: 'Badge ID',
                    value: controller.employeeId.value,
                    valueColor: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryItem({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTextStyles.text10.copyWith(
            color: AppColors.white.withValues(alpha: 0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
        AppSpaces.vSpace2,
        Text(
          value,
          style: AppTextStyles.text12.copyWith(
            color: valueColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1.w,
      height: 24.h,
      color: AppColors.white.withValues(alpha: 0.12),
    );
  }
}
