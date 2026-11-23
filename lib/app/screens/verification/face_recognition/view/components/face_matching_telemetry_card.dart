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
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.16),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.35),
            blurRadius: 20.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 0. Consent Notice Capsule (when requires.face_saved == false per api.md Phase 10)
                  Obx(() {
                    final consentText = controller.punchRequires?.consentText;
                    if (controller.isPunchMode.value &&
                        controller.punchRequires?.faceSaved == false &&
                        consentText != null &&
                        consentText.isNotEmpty) {
                      return Container(
                        margin: EdgeInsets.only(bottom: 10.h),
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.secondary.withValues(alpha: 0.45),
                            width: 1.w,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.shield_outlined,
                              size: 16.sp,
                              color: AppColors.secondary,
                            ),
                            AppSpaces.hSpace8,
                            Expanded(
                              child: Text(
                                consentText,
                                style: AppTextStyles.text10.copyWith(
                                  color: AppColors.white.withValues(alpha: 0.9),
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),

                  // 1. Employee Identity Card Header (Modern Glassmorphic Dark-Light Mix)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: AppColors.white.withValues(alpha: 0.12),
                        width: 1.w,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Avatar Circle with Vibrant Modern Teal Tint
                        Container(
                          width: 38.r,
                          height: 38.r,
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.22),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.secondary.withValues(alpha: 0.5),
                              width: 1.2.w,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.person_rounded,
                              size: 20.sp,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                        AppSpaces.hSpace10,
                        // Employee Details Column
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Obx(
                                () => Text(
                                  controller.employeeName.value.isNotEmpty
                                      ? controller.employeeName.value
                                      : 'Employee',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.text14.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                              AppSpaces.vSpace2,
                              Obx(() {
                                final id = controller.employeeId.value;
                                final company = controller.companyName.value;
                                final details = [
                                  if (id.isNotEmpty) 'ID: $id',
                                  if (company.isNotEmpty) company,
                                ].join(' • ');

                                return Text(
                                  details.isNotEmpty
                                      ? details
                                      : 'Biometric Face Verification',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.text10.copyWith(
                                    color: AppColors.liteSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                        // Clean Status Badge
                        Obx(() {
                          final isSuccess = controller.isMatchSuccess.value;
                          final isVerifying = controller.isVerifying.value;

                          final Color statusColor = isSuccess
                              ? AppColors.success
                              : (isVerifying
                                  ? AppColors.secondary
                                  : AppColors.liteSecondary);

                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: statusColor.withValues(alpha: 0.4),
                                width: 0.8.w,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isSuccess
                                      ? Icons.check_circle_rounded
                                      : (isVerifying
                                          ? Icons.face_retouching_natural_rounded
                                          : Icons.face_rounded),
                                  size: 12.sp,
                                  color: statusColor,
                                ),
                                AppSpaces.hSpace4,
                                Text(
                                  isSuccess
                                      ? 'Verified'
                                      : (isVerifying ? 'Checking' : 'Ready'),
                                  style: AppTextStyles.text10.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 9.5.sp,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  AppSpaces.vSpace8,

                  // 2. Dynamic Friendly Guidance Banner
                  Obx(() {
                    final isSuccess = controller.isMatchSuccess.value;

                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 7.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSuccess
                            ? AppColors.success.withValues(alpha: 0.15)
                            : AppColors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: isSuccess
                              ? AppColors.success.withValues(alpha: 0.35)
                              : AppColors.white.withValues(alpha: 0.1),
                          width: 0.8.w,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSuccess
                                ? Icons.check_circle_outline_rounded
                                : Icons.info_outline_rounded,
                            size: 14.sp,
                            color: isSuccess
                                ? AppColors.success
                                : AppColors.secondary,
                          ),
                          AppSpaces.hSpace8,
                          Expanded(
                            child: Text(
                              controller.statusText.value,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.text12.copyWith(
                                color: isSuccess
                                    ? AppColors.success
                                    : AppColors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  AppSpaces.vSpace8,

                  // 3. Alignment Posture Hints Strip (6 micro quality chips)
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
                            AppSpaces.hSpace6,
                            Expanded(
                              child: _buildQualityChip(
                                label: 'Eyes Open',
                                passed: res.eyesOpen,
                              ),
                            ),
                            AppSpaces.hSpace6,
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
                            AppSpaces.hSpace6,
                            Expanded(
                              child: _buildQualityChip(
                                label: 'Distance',
                                passed: res.isScaleValid,
                              ),
                            ),
                            AppSpaces.hSpace6,
                            Expanded(
                              child: _buildQualityChip(
                                label: res.isMaskOrCovered ? 'Remove Mask' : 'In Oval',
                                passed: res.isInsideOval && !res.isMaskOrCovered,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }),

                  // 4. Comparison Outcome Banner (when a report exists, Clean, NO % and NO Thresholds)
                  Obx(() {
                    final report = controller.comparisonReport.value;
                    if (report == null) return const SizedBox.shrink();

                    final bool matched = report.matched;

                    return Container(
                      margin: EdgeInsets.only(top: 8.h),
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: matched
                            ? AppColors.success.withValues(alpha: 0.16)
                            : AppColors.error.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: matched ? AppColors.success : AppColors.error,
                          width: 1.w,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            matched
                                ? Icons.verified_rounded
                                : Icons.cancel_outlined,
                            size: 15.sp,
                            color: matched ? AppColors.success : AppColors.error,
                          ),
                          AppSpaces.hSpace6,
                          Text(
                            matched
                                ? 'Face Recognized'
                                : 'Face Not Recognized • Please try again',
                            style: AppTextStyles.text12.copyWith(
                              color:
                                  matched ? AppColors.success : AppColors.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  AppSpaces.vSpace10,

                  // 5. Action Status / Guidance
                  Obx(() {
                    final isSuccess = controller.isMatchSuccess.value;
                    final isVerifying = controller.isVerifying.value;
                    final isSaving = controller.isSavingReference.value;
                    final hasRef = controller.hasReferenceFace.value;
                    final isPunch = controller.isPunchMode.value;

                    // In punch mode: Auto verification and instant return (Never show Done / Proceed button)
                    if (isPunch) {
                      if (isSuccess) {
                        return CustomButton(
                          text: 'Verified • Returning to Dashboard...',
                          isGradient: true,
                          isLoading: true,
                          onPressed: null,
                        );
                      }
                      return CustomButton(
                        text: isVerifying
                            ? 'Verifying Face...'
                            : (hasRef
                                ? 'Align Face to Auto-Verify'
                                : 'Align Face to Enroll'),
                        isGradient: true,
                        isLoading: isVerifying || isSaving,
                        onPressed: null,
                      );
                    }

                    if (isSuccess) {
                      return CustomButton(
                        text: 'Done • Proceed',
                        isGradient: true,
                        onPressed: () async =>
                            await controller.proceedToDashboard(),
                      );
                    }

                    // Standalone mode: explicit Verify button
                    return CustomButton(
                      text: 'Verify Face',
                      isGradient: true,
                      isLoading: isVerifying,
                      onPressed: hasRef && !isSaving && !isVerifying
                          ? () => controller.verifyFaceMatch()
                          : null,
                    );
                  }),
                ],
              ),
            ),

            // Signature Bottom Accent Border Bar
            Container(
              height: 3.h,
              color: AppColors.secondary,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a micro quality checklist chip
  Widget _buildQualityChip({required String label, required bool passed}) {
    final Color color =
        passed ? AppColors.secondary : AppColors.liteSecondary.withValues(alpha: 0.5);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.5.h),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: passed
            ? AppColors.secondary.withValues(alpha: 0.18)
            : AppColors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: passed
              ? AppColors.secondary.withValues(alpha: 0.45)
              : AppColors.white.withValues(alpha: 0.08),
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
                color: passed
                    ? AppColors.white
                    : AppColors.liteSecondary.withValues(alpha: 0.6),
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
