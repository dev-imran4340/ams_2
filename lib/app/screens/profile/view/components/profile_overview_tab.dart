import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/custom_state_view.dart';
import '../../controller/profile_controller.dart';

class ProfileOverviewTab extends GetView<ProfileController> {
  const ProfileOverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final p = controller.profile.value;
      final job = p?.job;
      final contact = p?.contact;

      final legalEntity = job?.legalEntity;
      final department = p?.department ?? job?.department;
      final designation = p?.designation ?? job?.designation;
      final location = p?.workLocation ?? job?.workLocation;
      final serviceLength = job?.lengthOfService;
      final joinedOn = job?.joinedOn;
      final workEmail =
          contact?.workEmail ?? (p?.email.isNotEmpty == true ? p!.email : null);
      final workPhone = contact?.workPhone;

      // Filter rows that are non-null and non-empty
      final employmentRows = <_OverviewRowData>[];
      if (legalEntity != null && legalEntity.trim().isNotEmpty) {
        employmentRows.add(
          _OverviewRowData(
            Icons.apartment_rounded,
            'Legal Entity',
            legalEntity,
          ),
        );
      }
      if (designation != null && designation.trim().isNotEmpty) {
        employmentRows.add(
          _OverviewRowData(
            Icons.work_outline_rounded,
            'Designation',
            designation,
          ),
        );
      }
      if (department != null && department.trim().isNotEmpty) {
        employmentRows.add(
          _OverviewRowData(Icons.lan_outlined, 'Department', department),
        );
      }
      if (location != null && location.trim().isNotEmpty) {
        employmentRows.add(
          _OverviewRowData(
            Icons.location_on_outlined,
            'Work Location',
            location,
          ),
        );
      }
      if (joinedOn != null && joinedOn.trim().isNotEmpty) {
        employmentRows.add(
          _OverviewRowData(Icons.calendar_today_rounded, 'Joined On', joinedOn),
        );
      }
      if (serviceLength != null && serviceLength.trim().isNotEmpty) {
        employmentRows.add(
          _OverviewRowData(
            Icons.timelapse_rounded,
            'Length of Service',
            serviceLength,
          ),
        );
      }

      final contactRows = <_OverviewRowData>[];
      if (workEmail != null && workEmail.trim().isNotEmpty) {
        contactRows.add(
          _OverviewRowData(
            Icons.mail_outline_rounded,
            'Corporate Email',
            workEmail,
          ),
        );
      }
      if (workPhone != null && workPhone.trim().isNotEmpty) {
        contactRows.add(
          _OverviewRowData(
            Icons.phone_in_talk_outlined,
            'Work Phone',
            workPhone,
          ),
        );
      }

      if (employmentRows.isEmpty && contactRows.isEmpty) {
        return CustomStateView.empty(
          title: 'No Overview Details',
          message:
              'No employment or contact details are available for this profile.',
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Employment Overview Card (Only showing non-null fields)
          if (employmentRows.isNotEmpty) ...[
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
                          Icons.business_center_rounded,
                          size: 16.sp,
                          color: AppColors.primary,
                        ),
                      ),
                      AppSpaces.hSpace8,
                      Expanded(
                        child: Text(
                          'Employment Overview',
                          style: AppTextStyles.text14.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  AppSpaces.vSpace14,
                  for (int i = 0; i < employmentRows.length; i++) ...[
                    _buildInfoRow(
                      icon: employmentRows[i].icon,
                      label: employmentRows[i].label,
                      value: employmentRows[i].value,
                    ),
                    if (i < employmentRows.length - 1) _buildDivider(),
                  ],
                ],
              ),
            ),
            AppSpaces.vSpace14,
          ],

          // 2. Contact Channels Card (Only showing non-null channels)
          if (contactRows.isNotEmpty) ...[
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
                          Icons.contact_mail_outlined,
                          size: 16.sp,
                          color: AppColors.secondary,
                        ),
                      ),
                      AppSpaces.hSpace8,
                      Text(
                        'Workplace Contact',
                        style: AppTextStyles.text14.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                    ],
                  ),
                  AppSpaces.vSpace14,
                  for (int i = 0; i < contactRows.length; i++) ...[
                    _buildInfoRow(
                      icon: contactRows[i].icon,
                      label: contactRows[i].label,
                      value: contactRows[i].value,
                    ),
                    if (i < contactRows.length - 1) _buildDivider(),
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

class _OverviewRowData {
  final IconData icon;
  final String label;
  final String value;
  const _OverviewRowData(this.icon, this.label, this.value);
}
