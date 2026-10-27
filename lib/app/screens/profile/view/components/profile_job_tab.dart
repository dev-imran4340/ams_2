import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/custom_state_view.dart';
import '../../controller/profile_controller.dart';

class ProfileJobTab extends GetView<ProfileController> {
  const ProfileJobTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final p = controller.profile.value;
      final job = p?.job;

      final legalEntity = job?.legalEntity;
      final location = job?.workLocation ?? p?.workLocation;
      final department = job?.department ?? p?.department;
      final subDept = job?.subDepartment;
      final designation = job?.designation ?? p?.designation;
      final grade = job?.grade;

      final empType = job?.employmentType != null
          ? job!.employmentType!.replaceAll('_', ' ').capitalizeFirst
          : null;
      final contractType = job?.contractType != null
          ? job!.contractType!.replaceAll('_', ' ').capitalizeFirst
          : null;
      final joinedOn = job?.joinedOn;
      final lengthOfService = job?.lengthOfService;
      final contractEnds = job?.contractEndsOn;
      final probationStatus = job?.probationEndsOn != null
          ? 'Ends on ${job!.probationEndsOn}'
          : (job?.confirmedOn != null ? 'Confirmed on ${job!.confirmedOn}' : null);

      // Build placement rows strictly for non-null fields
      final placementRows = <_JobRowData>[];
      if (legalEntity != null && legalEntity.trim().isNotEmpty) {
        placementRows.add(_JobRowData(Icons.business_rounded, 'Legal Entity', legalEntity));
      }
      if (designation != null && designation.trim().isNotEmpty) {
        placementRows.add(_JobRowData(Icons.work_outline_rounded, 'Designation', designation));
      }
      if (department != null && department.trim().isNotEmpty) {
        placementRows.add(_JobRowData(Icons.lan_outlined, 'Department', department));
      }
      if (subDept != null && subDept.trim().isNotEmpty) {
        placementRows.add(_JobRowData(Icons.account_tree_outlined, 'Sub-Department', subDept));
      }
      if (location != null && location.trim().isNotEmpty) {
        placementRows.add(_JobRowData(Icons.location_on_outlined, 'Work Location', location));
      }
      if (grade != null && grade.trim().isNotEmpty) {
        placementRows.add(_JobRowData(Icons.military_tech_outlined, 'Role Grade', grade));
      }

      // Build contract rows strictly for non-null fields
      final contractRows = <_JobRowData>[];
      if (empType != null && empType.trim().isNotEmpty) {
        contractRows.add(_JobRowData(Icons.badge_outlined, 'Employment Nature', empType));
      }
      if (contractType != null && contractType.trim().isNotEmpty) {
        contractRows.add(_JobRowData(Icons.handshake_outlined, 'Contract Type', contractType));
      }
      if (joinedOn != null && joinedOn.trim().isNotEmpty) {
        contractRows.add(_JobRowData(Icons.event_available_rounded, 'Official Joining Date', joinedOn));
      }
      if (lengthOfService != null && lengthOfService.trim().isNotEmpty) {
        contractRows.add(_JobRowData(Icons.access_time_rounded, 'Length of Service', lengthOfService));
      }
      if (probationStatus != null && probationStatus.trim().isNotEmpty) {
        contractRows.add(_JobRowData(Icons.verified_user_outlined, 'Probation Status', probationStatus));
      }
      if (contractEnds != null && contractEnds.trim().isNotEmpty) {
        contractRows.add(_JobRowData(Icons.event_busy_rounded, 'Contract Expiry', contractEnds));
      }

      if (placementRows.isEmpty && contractRows.isEmpty) {
        return CustomStateView.empty(
          title: 'No Job Details',
          message: 'No corporate employment records are available for this profile.',
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Placement & Hierarchy (Only non-null values)
          if (placementRows.isNotEmpty) ...[
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32.r,
                        height: 32.r,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.apartment_rounded,
                          size: 16.sp,
                          color: AppColors.primary,
                        ),
                      ),
                      AppSpaces.hSpace8,
                      Text(
                        'Corporate Placement',
                        style: AppTextStyles.text14.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                    ],
                  ),
                  AppSpaces.vSpace14,
                  for (int i = 0; i < placementRows.length; i++) ...[
                    _buildInfoRow(
                      icon: placementRows[i].icon,
                      label: placementRows[i].label,
                      value: placementRows[i].value,
                    ),
                    if (i < placementRows.length - 1) _buildDivider(),
                  ],
                ],
              ),
            ),
            AppSpaces.vSpace14,
          ],

          // 2. Contract Terms & Tenure (Only non-null values)
          if (contractRows.isNotEmpty) ...[
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32.r,
                        height: 32.r,
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.history_edu_rounded,
                          size: 16.sp,
                          color: AppColors.secondary,
                        ),
                      ),
                      AppSpaces.hSpace8,
                      Text(
                        'Contract & Service Record',
                        style: AppTextStyles.text14.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                    ],
                  ),
                  AppSpaces.vSpace14,
                  for (int i = 0; i < contractRows.length; i++) ...[
                    _buildInfoRow(
                      icon: contractRows[i].icon,
                      label: contractRows[i].label,
                      value: contractRows[i].value,
                    ),
                    if (i < contractRows.length - 1) _buildDivider(),
                  ],
                ],
              ),
            ),
          ],
        ],
      );
    });
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 15.sp, color: AppColors.secondary),
        AppSpaces.hSpace8,
        Text(
          label,
          style: AppTextStyles.text12.copyWith(
            color: AppColors.subTextColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        AppSpaces.hSpace8,
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 3,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.text12.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Divider(
        height: 1.h,
        color: AppColors.borderColor.withValues(alpha: 0.6),
      ),
    );
  }
}

class _JobRowData {
  final IconData icon;
  final String label;
  final String value;
  const _JobRowData(this.icon, this.label, this.value);
}
