import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../controller/training_controller.dart';
import '../../model/training_model.dart';

class TrainingRequiredCard extends GetView<TrainingController> {
  final TrainingRequiredModel item;

  const TrainingRequiredCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final course = item.course;
    final accentColor = item.valid ? AppColors.secondary : AppColors.warning;

    return CustomCard(
      accentColor: accentColor,
      accentWidth: 3.w,
      onTap: () => controller.openCourseDetails(context, item),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
              // 1. Header: Icon, Course Name, Status Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40.r,
                    height: 40.r,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.25),
                        width: 1.w,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        item.valid
                            ? Icons.verified_rounded
                            : Icons.assignment_late_outlined,
                        size: 20.sp,
                        color: accentColor,
                      ),
                    ),
                  ),

                  AppSpaces.hSpace12,

                  // Course Title & Provider
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.text14.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                        AppSpaces.vSpace4,
                        Row(
                          children: [
                            Icon(
                              Icons.business_outlined,
                              size: 12.sp,
                              color: AppColors.subTextColor,
                            ),
                            AppSpaces.hSpace4,
                            Expanded(
                              child: Text(
                                course.provider,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.text10.copyWith(
                                  color: AppColors.subTextColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  AppSpaces.hSpace8,

                  // Compliance Badge
                  _buildComplianceBadge(),
                ],
              ),

              // 2. Course Description (if any)
              if (course.description != null &&
                  course.description!.isNotEmpty) ...[
                AppSpaces.vSpace10,
                Text(
                  course.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.text12.copyWith(
                    color: AppColors.subTextColor,
                    height: 1.35,
                  ),
                ),
              ],

              AppSpaces.vSpace12,

              // 3. Footer: Validity & Requirement Pills
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.inputFill,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timelapse_rounded,
                          size: 11.sp,
                          color: AppColors.subTextColor,
                        ),
                        AppSpaces.hSpace4,
                        Text(
                          'Valid for ${course.validityMonths} months',
                          style: AppTextStyles.text10.copyWith(
                            color: AppColors.subTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  if (course.isRequired)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 7.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        'MANDATORY',
                        style: AppTextStyles.text10.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
    );
  }

  Widget _buildComplianceBadge() {
    final color = item.valid ? AppColors.success : AppColors.warning;
    final label = item.valid ? 'Compliant' : 'Pending';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 0.8.w,
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.text10.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
