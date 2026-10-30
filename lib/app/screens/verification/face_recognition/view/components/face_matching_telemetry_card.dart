import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_spaces.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../controller/face_recognition_controller.dart';
import '../../model/face_recognition_model.dart';

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
            final isSuccess = controller.isMatchSuccess.value;            final progress = controller.matchProgress.value;

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

          // 3. Six Real-Time Biometric Quality Checks Strip (2 Rows of 3)
          Obx(() {
            final res = controller.checkResult.value;

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildQualityChip(
                        label: '1 Face',
                        passed: res.hasExactlyOneFace,
                      ),
                    ),
                    AppSpaces.hSpace8,
                    Expanded(
                      child: _buildQualityChip(
                        label: 'Eyes Open',
                        passed: res.eyesOpen,
                      ),
                    ),
                    AppSpaces.hSpace8,
                    Expanded(
                      child: _buildQualityChip(
                        label: 'Straight',
                        passed: res.headStraight,
                      ),
                    ),
                  ],
                ),
                AppSpaces.vSpace6,
                Row(
                  children: [
                    Expanded(
                      child: _buildQualityChip(
                        label: 'Centered',
                        passed: res.isCentered,
                      ),
                    ),
                    AppSpaces.hSpace8,
                    Expanded(
                      child: _buildQualityChip(
                        label: 'Distance',
                        passed: res.isScaleValid,
                      ),
                    ),
                    AppSpaces.hSpace8,
                    Expanded(
                      child: _buildQualityChip(
                        label: 'In Oval',
                        passed: res.isInsideOval,
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),

          AppSpaces.vSpace10,

          // 4. Comparison Outcome Banner (when a report exists)
          Obx(() {
            final report = controller.comparisonReport.value;
            if (report == null) return const SizedBox.shrink();

            return Container(
              margin: EdgeInsets.only(bottom: 8.h),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: report.matched
                    ? AppColors.success.withValues(alpha: 0.15)
                    : AppColors.error.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: report.matched ? AppColors.success : AppColors.error,
                  width: 1.w,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    report.matched
                        ? Icons.verified_rounded
                        : Icons.cancel_rounded,
                    size: 15.sp,
                    color: report.matched ? AppColors.success : AppColors.error,
                  ),
                  AppSpaces.hSpace6,
                  Text(
                    report.matched ? 'MATCH' : 'NOT MATCH',
                    style: AppTextStyles.text12.copyWith(
                      color:
                          report.matched ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    ' • ${(report.score * 100).toStringAsFixed(1)}% (Threshold: ${(controller.repo.matchThreshold * 100).toInt()}%)',
                    style: AppTextStyles.text12.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }),

          // 5. Action Buttons (Register Face vs Verify Face)
          Obx(() {
            final isSuccess = controller.isMatchSuccess.value;
            final isVerifying = controller.isVerifying.value;
            final isSaving = controller.isSavingReference.value;
            final hasRef = controller.hasReferenceFace.value;
            final activeMode = controller.actionMode.value;

            if (isSuccess) {
              return CustomButton(
                text: 'Done • Proceed',
                isGradient: true,
                onPressed: () async => await controller.proceedToDashboard(),
              );
            }

            final isRegisterActive = activeMode == FaceActionMode.register;
            final isVerifyActive = activeMode == FaceActionMode.verify;

            return Row(
              children: [
                // Register Face Mode Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isSaving || isVerifying
                        ? null
                        : () {
                            controller.setMode(FaceActionMode.register);
                          },
                    icon: isSaving
                        ? SizedBox(
                            width: 13.r,
                            height: 13.r,
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
                            size: 14.sp,
                            color: isRegisterActive
                                ? AppColors.white
                                : AppColors.liteSecondary,
                          ),
                    label: Text(
                      hasRef ? 'Re-Register' : 'Register Face',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.text12.copyWith(
                        color: isRegisterActive
                            ? AppColors.white
                            : AppColors.liteSecondary,
                        fontWeight: isRegisterActive
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 9.h),
                      backgroundColor: isRegisterActive
                          ? AppColors.secondary.withValues(alpha: 0.35)
                          : Colors.transparent,
                      side: BorderSide(
                        color: isRegisterActive
                            ? AppColors.secondary
                            : AppColors.white.withValues(alpha: 0.18),
                        width: isRegisterActive ? 1.5.w : 1.w,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                ),

                AppSpaces.hSpace8,

                // Verify Face Action Button
                Expanded(
                  child: CustomButton(
                    text: 'Verify Face',
                    isGradient: isVerifyActive,
                    isLoading: isVerifying,
                    onPressed: hasRef && !isSaving && !isVerifying
                        ? () {
                            controller.setMode(FaceActionMode.verify);
                          }
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
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.5.h),
      alignment: Alignment.center,
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            passed ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            size: 10.sp,
            color: color,
          ),
          AppSpaces.hSpace4,
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.text10.copyWith(
                color: passed ? AppColors.white : AppColors.subTextColor,
                fontSize: 9.sp,
                fontWeight: passed ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
