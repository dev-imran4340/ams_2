import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_spaces.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../controller/face_recognition_controller.dart';

class FaceMatchingTelemetryCard extends GetView<FaceRecognitionController> {
  const FaceMatchingTelemetryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.18),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.5),
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
                  width: 34.r,
                  height: 34.r,
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
                            size: 18.sp,
                            color: AppColors.success,
                          )
                        : (isVerifying
                            ? SizedBox(
                                width: 14.r,
                                height: 14.r,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2.w,
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    AppColors.secondary,
                                  ),
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
                                : (controller.isAllChecksPassed.value
                                    ? 'Checks Passed • Ready to Match'
                                    : 'Awaiting Face Alignment')),
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
                              : (controller.isAllChecksPassed.value
                                  ? AppColors.secondary
                                  : AppColors.liteSecondary),
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
                    controller.isMatchSuccess.value
                        ? '${controller.confidenceReadout.value.toStringAsFixed(1)}%'
                        : '$percent%',
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

          AppSpaces.vSpace8,

          // 2. Animated Progress Bar
          Obx(() {
            final isSuccess = controller.isMatchSuccess.value;
            final progress = controller.matchProgress.value;

            return ClipRRect(
              borderRadius: BorderRadius.circular(3.r),
              child: Stack(
                children: [
                  Container(
                    height: 4.h,
                    color: AppColors.white.withValues(alpha: 0.12),
                  ),
                  FractionallySizedBox(
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(
                      height: 4.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isSuccess
                              ? [AppColors.success, AppColors.successMint]
                              : [AppColors.secondary, AppColors.liteSecondary],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          AppSpaces.vSpace10,

          // 3. Five Real-Time Biometric Quality Checks Strip
          Obx(() {
            final res = controller.checkResult.value;

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildQualityChip(
                  label: '1 Face',
                  passed: res.hasExactlyOneFace,
                ),
                _buildQualityChip(
                  label: 'Eyes Open',
                  passed: res.eyesOpen,
                ),
                _buildQualityChip(
                  label: 'Straight',
                  passed: res.headStraight,
                ),
                _buildQualityChip(
                  label: 'Centered',
                  passed: res.isCentered,
                ),
                _buildQualityChip(
                  label: 'Distance',
                  passed: res.isScaleValid,
                ),
              ],
            );
          }),

          AppSpaces.vSpace10,

          // 4. Action Buttons (Save Baseline / Match with AI / Submit Punch)
          Obx(() {
            final isSuccess = controller.isMatchSuccess.value;
            final isVerifying = controller.isVerifying.value;
            final isSaving = controller.isSavingReference.value;
            final isChecksPassed = controller.isAllChecksPassed.value;
            final hasRef = controller.hasReferenceFace.value;

            if (isSuccess) {
              return CustomButton(
                text: 'Done • Proceed',
                isGradient: true,
                onPressed: controller.proceedToDashboard,
              );
            }

            return Row(
              children: [
                // Enrollment Button: Save Reference Face
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: (isChecksPassed && !isSaving && !isVerifying)
                        ? controller.saveReferenceFace
                        : null,
                    icon: isSaving
                        ? SizedBox(
                            width: 14.r,
                            height: 14.r,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.w,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.liteSecondary,
                              ),
                            ),
                          )
                        : Icon(
                            hasRef
                                ? Icons.bookmark_added_rounded
                                : Icons.face_retouching_natural,
                            size: 15.sp,
                            color: isChecksPassed
                                ? AppColors.liteSecondary
                                : AppColors.subTextColor,
                          ),
                    label: Text(
                      hasRef ? 'Update Face' : 'Save Baseline',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.text12.copyWith(
                        color: isChecksPassed
                            ? AppColors.white
                            : AppColors.subTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 9.h),
                      side: BorderSide(
                        color: isChecksPassed
                            ? AppColors.secondary.withValues(alpha: 0.6)
                            : AppColors.white.withValues(alpha: 0.15),
                        width: 1.w,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                ),

                AppSpaces.hSpace8,

                // Matching Action Button
                Expanded(
                  flex: 1,
                  child: CustomButton(
                    text: controller.isPunchMode.value
                        ? 'Confirm Punch'
                        : 'Match AI',
                    isGradient: true,
                    isLoading: isVerifying,
                    onPressed: (isChecksPassed && !isVerifying)
                        ? controller.verifyFaceMatch
                        : null,
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  /// Builds a micro quality checklist chip
  Widget _buildQualityChip({
    required String label,
    required bool passed,
  }) {
    final Color color = passed ? AppColors.secondary : AppColors.subTextColor;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: passed
            ? AppColors.secondary.withValues(alpha: 0.15)
            : AppColors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: passed
              ? AppColors.secondary.withValues(alpha: 0.45)
              : AppColors.white.withValues(alpha: 0.1),
          width: 0.8.w,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            passed ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            size: 10.sp,
            color: color,
          ),
          AppSpaces.hSpace4,
          Text(
            label,
            style: AppTextStyles.text10.copyWith(
              color: passed ? AppColors.white : AppColors.subTextColor,
              fontSize: 9.sp,
              fontWeight: passed ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
