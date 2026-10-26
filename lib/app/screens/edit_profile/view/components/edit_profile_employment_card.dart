import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../controller/edit_profile_controller.dart';

class EditProfileEmploymentCard extends GetView<EditProfileController> {
  const EditProfileEmploymentCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final p = controller.currentProfile.value;

      final items = <Widget>[];

      void addRow(IconData icon, String label, String? value) {
        if (value != null && value.trim().isNotEmpty && value.trim() != 'null') {
          if (items.isNotEmpty) {
            items.add(_buildDivider());
          }
          items.add(_buildReadOnlyRow(icon: icon, label: label, value: value.trim()));
        }
      }

      addRow(Icons.person_rounded, 'Legal Full Name', p?.name);
      addRow(
        Icons.badge_outlined,
        'Employee Code',
        p?.employeeNumber.isNotEmpty == true
            ? p!.employeeNumber
            : (p?.employeeId.isNotEmpty == true ? p!.employeeId : null),
      );
      addRow(
        Icons.work_outline_rounded,
        'Designation',
        p?.designation.isNotEmpty == true
            ? p!.designation
            : p?.job?.designation,
      );
      addRow(
        Icons.domain_rounded,
        'Department',
        p?.department.isNotEmpty == true
            ? p!.department
            : p?.job?.department,
      );
      addRow(
        Icons.location_city_rounded,
        'Work Location',
        p?.workLocation.isNotEmpty == true
            ? p!.workLocation
            : p?.job?.workLocation,
      );
      addRow(
        Icons.cake_outlined,
        'Date of Birth',
        p?.dob.isNotEmpty == true
            ? p!.dob
            : p?.personal?.dateOfBirth,
      );
      addRow(
        Icons.flag_outlined,
        'Nationality',
        p?.personal?.nationality,
      );
      addRow(
        Icons.phone_in_talk_rounded,
        'Work Phone',
        p?.contact?.workPhone,
      );
      addRow(
        Icons.alternate_email_rounded,
        'Official Work Email',
        p?.contact?.workEmail != null && p!.contact!.workEmail!.trim().isNotEmpty
            ? p.contact!.workEmail
            : (p?.email.isNotEmpty == true ? p!.email : null),
      );
      addRow(
        Icons.credit_card_rounded,
        'National Identity / CNIC',
        p?.cnic.isNotEmpty == true ? p!.cnic : null,
      );
      addRow(
        Icons.event_available_rounded,
        'Date of Joining',
        p?.joiningDate.isNotEmpty == true
            ? p!.joiningDate
            : p?.job?.joinedOn,
      );

      return CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Locked Badge
            Row(
              children: [
                Container(
                  width: 34.r,
                  height: 34.r,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_person_rounded,
                    size: 18.sp,
                    color: AppColors.primary,
                  ),
                ),
                AppSpaces.hSpace10,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Official HR Records',
                        style: AppTextStyles.text14.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                      AppSpaces.vSpace2,
                      Text(
                        'Read-only corporate employment records',
                        style: AppTextStyles.text10.copyWith(
                          color: AppColors.subTextColor,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpaces.hSpace8,
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.25),
                      width: 0.8.w,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock_rounded,
                        size: 10.sp,
                        color: AppColors.error,
                      ),
                      AppSpaces.hSpace4,
                      Text(
                        'HR ONLY',
                        style: AppTextStyles.text10.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.error,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            AppSpaces.vSpace12,

            // Informational Notice Banner
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: AppColors.borderColor,
                  width: 0.8.w,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16.sp,
                    color: AppColors.secondary,
                  ),
                  AppSpaces.hSpace8,
                  Expanded(
                    child: Text(
                      'Name, date of birth, nationality, work phone and job details are official corporate records managed strictly by HR administrators.',
                      style: AppTextStyles.text10.copyWith(
                        color: AppColors.textColor,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            AppSpaces.vSpace14,

            if (items.isNotEmpty)
              ...items
            else
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Center(
                  child: Text(
                    'No official records available',
                    style: AppTextStyles.text12.copyWith(
                      color: AppColors.subTextColor,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildReadOnlyRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 16.sp, color: AppColors.secondary),
          AppSpaces.hSpace10,
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: AppTextStyles.text12.copyWith(
                color: AppColors.subTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          AppSpaces.hSpace8,
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTextStyles.text12.copyWith(
                color: AppColors.textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 10.h,
      thickness: 0.8.w,
      color: AppColors.borderColor.withValues(alpha: 0.5),
    );
  }
}
