import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../controller/evaluation_controller.dart';

class OverallScoreHeroCard extends GetView<EvaluationController> {
  const OverallScoreHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final report = controller.reportData.value;
      if (report == null) return const SizedBox.shrink();

      return Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.borderColor,
            width: 1.w,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.06),
              blurRadius: 18.r,
              offset: Offset(0, 6.h),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    // Top Row: Appraisal Cycle Badge & Status Pill
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            report.cycleName,
                            style: AppTextStyles.text12.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),

                        // Status Badge
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: AppColors.success.withValues(alpha: 0.3),
                              width: 0.8.w,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_rounded,
                                size: 12.sp,
                                color: AppColors.success,
                              ),
                              AppSpaces.hSpace4,
                              Text(
                                report.appraisalStatus,
                                style: AppTextStyles.text10.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    AppSpaces.vSpace16,

                    // Hero Score Pill / Circle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Prominent Score Display
                        Container(
                          width: 80.r,
                          height: 80.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primary,
                                AppColors.accentNavy,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 14.r,
                                offset: Offset(0, 4.h),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                report.overallRating.toStringAsFixed(1),
                                style: AppTextStyles.text24.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.white,
                                  height: 1.1,
                                ),
                              ),
                              Text(
                                'OUT OF 5.0',
                                style: AppTextStyles.text10.copyWith(
                                  fontSize: 8.sp,
                                  color: AppColors.liteSecondary,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        AppSpaces.hSpace16,

                        // Rating Label & Performance Tier
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: AppColors.success.withValues(alpha: 0.4),
                                    width: 1.w,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.stars_rounded,
                                      size: 14.sp,
                                      color: AppColors.success,
                                    ),
                                    AppSpaces.hSpace4,
                                    Flexible(
                                      child: Text(
                                        report.ratingLabel,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.text10.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.success,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              AppSpaces.vSpace8,
                              Text(
                                'Comprehensive Skill & Productivity Evaluation',
                                style: AppTextStyles.text12.copyWith(
                                  color: AppColors.textColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              AppSpaces.vSpace2,
                              Text(
                                'Weighted score calculated across engineering, sprint velocity, and corporate attendance.',
                                style: AppTextStyles.text10.copyWith(
                                  color: AppColors.subTextColor,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    AppSpaces.vSpace16,
                    Container(
                      height: 1.h,
                      color: AppColors.borderColor,
                    ),
                    AppSpaces.vSpace12,

                    // Telemetry Sub-row: Reviewer & Date
                    Row(
                      children: [
                        Icon(
                          Icons.person_pin_rounded,
                          size: 14.sp,
                          color: AppColors.secondary,
                        ),
                        AppSpaces.hSpace6,
                        Expanded(
                          child: Text(
                            report.evaluatedBy,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.text10.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColor,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.event_available_rounded,
                          size: 13.sp,
                          color: AppColors.subTextColor,
                        ),
                        AppSpaces.hSpace4,
                        Text(
                          report.evaluationDate,
                          style: AppTextStyles.text10.copyWith(
                            color: AppColors.subTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Bottom Signature Accent Strip (3.h)
              Container(
                height: 3.h,
                color: AppColors.secondary,
              ),
            ],
          ),
        ),
      );
    });
  }
}
