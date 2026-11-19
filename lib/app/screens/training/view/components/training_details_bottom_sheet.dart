import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../controller/training_controller.dart';
import '../../model/training_model.dart';

class TrainingDetailsBottomSheet extends GetView<TrainingController> {
  final TrainingRecordModel? record;
  final TrainingRequiredModel? requiredCourse;

  const TrainingDetailsBottomSheet({
    super.key,
    this.record,
    this.requiredCourse,
  });

  static void showRecord(BuildContext context,
      {required TrainingRecordModel record}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TrainingDetailsBottomSheet(record: record),
    );
  }

  static void showCourse(BuildContext context,
      {required TrainingRequiredModel item}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TrainingDetailsBottomSheet(requiredCourse: item),
    );
  }

  Future<void> _launchCertificate(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      CustomSnackbar.showError(
        title: 'Unable to Open',
        message: 'Could not launch certificate document.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRecord = record != null;
    final course = isRecord ? record!.course : requiredCourse!.course;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        children: [
          // 1. Drag Handle
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 10.h, bottom: 8.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.borderColor,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),

          // 2. Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              children: [
                Container(
                  width: 32.r,
                  height: 32.r,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.school_rounded,
                      size: 18.sp,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
                AppSpaces.hSpace10,
                Text(
                  isRecord ? 'Training Record' : 'Course Details',
                  style: AppTextStyles.text16.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Get.back();
                  },
                  icon: Icon(
                    Icons.close_rounded,
                    color: AppColors.subTextColor,
                    size: 20.sp,
                  ),
                ),
              ],
            ),
          ),

          Divider(
            color: AppColors.borderColor.withValues(alpha: 0.6),
            height: 1.h,
          ),

          // 3. Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 14.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course Title
                  Text(
                    course.name,
                    style: AppTextStyles.text18.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),

                  AppSpaces.vSpace8,

                  // Provider & Category Badges
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          course.provider,
                          style: AppTextStyles.text10.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      AppSpaces.hSpace6,
                      if (isRecord)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: (record!.isPassed
                                    ? AppColors.success
                                    : AppColors.secondary)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            record!.resultLabel.toUpperCase(),
                            style: AppTextStyles.text10.copyWith(
                              fontWeight: FontWeight.bold,
                              color: record!.isPassed
                                  ? AppColors.success
                                  : AppColors.secondary,
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: (requiredCourse!.valid
                                    ? AppColors.success
                                    : AppColors.warning)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            requiredCourse!.valid ? 'COMPLIANT' : 'PENDING',
                            style: AppTextStyles.text10.copyWith(
                              fontWeight: FontWeight.bold,
                              color: requiredCourse!.valid
                                  ? AppColors.success
                                  : AppColors.warning,
                            ),
                          ),
                        ),
                    ],
                  ),

                  AppSpaces.vSpace14,

                  // Overview Card (Signature 3.w Teal Accent)
                  CustomCard(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 14.h,
                    ),
                    child: Column(
                      children: [
                        _buildMetaRow(
                          icon: Icons.business_outlined,
                          label: 'Provider',
                          value: course.provider,
                        ),
                        AppSpaces.vSpace10,
                        _buildMetaRow(
                          icon: Icons.timelapse_rounded,
                          label: 'Validity Duration',
                          value: '${course.validityMonths} months',
                        ),
                        if (isRecord) ...[
                          if (record!.trainer != null &&
                              record!.trainer!.isNotEmpty) ...[
                            AppSpaces.vSpace10,
                            _buildMetaRow(
                              icon: Icons.person_outline_rounded,
                              label: 'Trainer',
                              value: record!.trainer!,
                            ),
                          ],
                          if (record!.completedOn != null) ...[
                            AppSpaces.vSpace10,
                            _buildMetaRow(
                              icon: Icons.event_available_rounded,
                              label: 'Completed On',
                              value: record!.completedOn!,
                            ),
                          ],
                          if (record!.durationMinutes != null) ...[
                            AppSpaces.vSpace10,
                            _buildMetaRow(
                              icon: Icons.schedule_rounded,
                              label: 'Duration',
                              value: '${record!.durationMinutes} mins',
                            ),
                          ],
                          if (record!.expiresOn != null) ...[
                            AppSpaces.vSpace10,
                            _buildMetaRow(
                              icon: Icons.event_busy_rounded,
                              label: 'Certificate Expiry',
                              value: record!.expiresOn!,
                            ),
                          ],
                          AppSpaces.vSpace10,
                          _buildMetaRow(
                            icon: Icons.verified_outlined,
                            label: 'Certification Status',
                            value: record!.isValid
                                ? 'Active & Valid'
                                : 'Expired / Needs Renewal',
                          ),
                        ] else ...[
                          AppSpaces.vSpace10,
                          _buildMetaRow(
                            icon: Icons.policy_outlined,
                            label: 'Mandatory Policy',
                            value: course.isRequired
                                ? 'Mandatory for Designation'
                                : 'Optional Development',
                          ),
                          AppSpaces.vSpace10,
                          _buildMetaRow(
                            icon: Icons.rule_rounded,
                            label: 'Current Compliance',
                            value: requiredCourse!.valid
                                ? 'Compliant with Policy'
                                : 'Pending Certification',
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Description
                  if (course.description != null &&
                      course.description!.isNotEmpty) ...[
                    AppSpaces.vSpace14,
                    Text(
                      'Course Overview',
                      style: AppTextStyles.text14.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textColor,
                      ),
                    ),
                    AppSpaces.vSpace8,
                    CustomCard(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 14.h,
                      ),
                      child: Text(
                        course.description!,
                        style: AppTextStyles.text12.copyWith(
                          color: AppColors.textColor,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],

                  // Notes (if any in record)
                  if (isRecord &&
                      record!.note != null &&
                      record!.note!.isNotEmpty) ...[
                    AppSpaces.vSpace14,
                    Text(
                      'Instructor Notes',
                      style: AppTextStyles.text14.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textColor,
                      ),
                    ),
                    AppSpaces.vSpace8,
                    CustomCard(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 14.h,
                      ),
                      child: Text(
                        record!.note!,
                        style: AppTextStyles.text12.copyWith(
                          color: AppColors.textColor,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],

                  // Certificate Action Button (if certificate available)
                  if (isRecord && record!.hasCertificate) ...[
                    AppSpaces.vSpace16,
                    CustomButton(
                      text: 'View Official Certificate',
                      icon: Icon(
                        Icons.open_in_new_rounded,
                        size: 16.sp,
                        color: AppColors.white,
                      ),
                      isGradient: true,
                      onPressed: () =>
                          _launchCertificate(record!.certificateUrl!),
                    ),
                  ],

                  AppSpaces.vSpace16,
                ],
              ),
            ),
          ),

          // 4. Action Button Footer
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              border: Border(
                top: BorderSide(
                  color: AppColors.borderColor,
                  width: 0.8.w,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: CustomButton(
                text: 'Close',
                isOutlined: true,
                borderColor: AppColors.borderColor,
                textColor: AppColors.subTextColor,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Get.back();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14.w, color: AppColors.secondary),
        AppSpaces.hSpace8,
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.text10.copyWith(
              color: AppColors.subTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: AppTextStyles.text12.copyWith(
              color: AppColors.textColor,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
