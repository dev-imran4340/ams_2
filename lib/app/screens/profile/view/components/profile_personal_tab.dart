import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../controller/profile_controller.dart';

class ProfilePersonalTab extends GetView<ProfileController> {
  const ProfilePersonalTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final p = controller.profile.value;
      final personal = p?.personal;
      final address = personal?.address;
      final emergencies = p?.emergencyContacts ?? [];

      final gender = personal?.gender;
      final dob = personal?.dateOfBirth;
      final bloodGroup = personal?.bloodGroup;
      final maritalStatus = personal?.maritalStatus;
      final nationality = personal?.nationality;
      final personalPhone = personal?.personalPhone;
      final personalEmail = personal?.personalEmail;

      // Filter only present (non-null and non-empty) personal fields
      final personalRows = <_PersonalRowData>[];
      if (nationality != null && nationality.trim().isNotEmpty) {
        personalRows.add(_PersonalRowData(Icons.flag_outlined, 'Nationality', nationality));
      }
      if (gender != null && gender.trim().isNotEmpty) {
        personalRows.add(_PersonalRowData(Icons.male_rounded, 'Gender', gender));
      }
      if (dob != null && dob.trim().isNotEmpty) {
        personalRows.add(_PersonalRowData(Icons.cake_outlined, 'Date of Birth', dob));
      }
      if (bloodGroup != null && bloodGroup.trim().isNotEmpty) {
        personalRows.add(_PersonalRowData(Icons.bloodtype_outlined, 'Blood Group', bloodGroup));
      }
      if (maritalStatus != null && maritalStatus.trim().isNotEmpty) {
        personalRows.add(_PersonalRowData(Icons.favorite_border_rounded, 'Marital Status', maritalStatus));
      }
      if (personalPhone != null && personalPhone.trim().isNotEmpty) {
        personalRows.add(_PersonalRowData(Icons.phone_android_rounded, 'Personal Phone', personalPhone));
      }
      if (personalEmail != null && personalEmail.trim().isNotEmpty) {
        personalRows.add(_PersonalRowData(Icons.alternate_email_rounded, 'Personal Email', personalEmail));
      }

      // Filter only present address fields
      final line1 = address?.line1;
      final line2 = address?.line2;
      final city = address?.city;
      final postcode = address?.postcode;
      final country = address?.country;

      final addressRows = <_PersonalRowData>[];
      if (line1 != null && line1.trim().isNotEmpty) {
        addressRows.add(_PersonalRowData(Icons.signpost_outlined, 'Address Line 1', line1));
      }
      if (line2 != null && line2.trim().isNotEmpty) {
        addressRows.add(_PersonalRowData(Icons.apartment_outlined, 'Address Line 2', line2));
      }
      if (city != null && city.trim().isNotEmpty) {
        addressRows.add(_PersonalRowData(Icons.location_city_outlined, 'City', city));
      }
      if (postcode != null && postcode.trim().isNotEmpty) {
        addressRows.add(_PersonalRowData(Icons.markunread_mailbox_outlined, 'Postal Code', postcode));
      }
      if (country != null && country.trim().isNotEmpty) {
        addressRows.add(_PersonalRowData(Icons.public_outlined, 'Country', country));
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Personal Demographics Card (Only non-null values)
          if (personalRows.isNotEmpty) ...[
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
                          Icons.person_pin_rounded,
                          size: 17.sp,
                          color: AppColors.secondary,
                        ),
                      ),
                      AppSpaces.hSpace8,
                      Text(
                        'Personal Details',
                        style: AppTextStyles.text14.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                    ],
                  ),
                  AppSpaces.vSpace14,
                  for (int i = 0; i < personalRows.length; i++) ...[
                    _buildInfoRow(
                      icon: personalRows[i].icon,
                      label: personalRows[i].label,
                      value: personalRows[i].value,
                    ),
                    if (i < personalRows.length - 1) _buildDivider(),
                  ],
                ],
              ),
            ),
            AppSpaces.vSpace14,
          ],

          // 2. Residential Address Card (Only if address data exists)
          if (addressRows.isNotEmpty) ...[
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
                          Icons.home_work_outlined,
                          size: 16.sp,
                          color: AppColors.primary,
                        ),
                      ),
                      AppSpaces.hSpace8,
                      Text(
                        'Residential Address',
                        style: AppTextStyles.text14.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                    ],
                  ),
                  AppSpaces.vSpace14,
                  for (int i = 0; i < addressRows.length; i++) ...[
                    _buildInfoRow(
                      icon: addressRows[i].icon,
                      label: addressRows[i].label,
                      value: addressRows[i].value,
                    ),
                    if (i < addressRows.length - 1) _buildDivider(),
                  ],
                ],
              ),
            ),
            AppSpaces.vSpace14,
          ],

          // 3. Emergency Contacts Card
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32.r,
                          height: 32.r,
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.emergency_outlined,
                            size: 16.sp,
                            color: AppColors.error,
                          ),
                        ),
                        AppSpaces.hSpace8,
                        Text(
                          'Emergency Contacts',
                          style: AppTextStyles.text14.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                      ],
                    ),
                    if (emergencies.isEmpty)
                      InkWell(
                        onTap: controller.navigateToEditProfile,
                        borderRadius: BorderRadius.circular(8.r),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          child: Text(
                            '+ Add',
                            style: AppTextStyles.text12.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                AppSpaces.vSpace14,
                if (emergencies.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 14.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.inputFill,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: AppColors.borderColor,
                        width: 0.8.w,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.contact_phone_outlined,
                          size: 24.sp,
                          color: AppColors.subTextColor,
                        ),
                        AppSpaces.vSpace6,
                        Text(
                          'No Emergency Contacts Listed',
                          style: AppTextStyles.text12.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                        AppSpaces.vSpace2,
                        Text(
                          'Add emergency contact details for urgent workplace notices.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.text10.copyWith(
                            color: AppColors.subTextColor,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...emergencies.map((contact) {
                    final cName = contact.name ?? '';
                    final cRel = contact.relationship ?? '';
                    final cPhone = contact.phone ?? '';

                    return Container(
                      margin: EdgeInsets.only(bottom: 8.h),
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.inputFill,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.phone_rounded,
                            size: 16.sp,
                            color: AppColors.secondary,
                          ),
                          AppSpaces.hSpace8,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cName,
                                  style: AppTextStyles.text12.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textColor,
                                  ),
                                ),
                                if (cRel.isNotEmpty)
                                  Text(
                                    cRel,
                                    style: AppTextStyles.text10.copyWith(
                                      color: AppColors.subTextColor,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (cPhone.isNotEmpty)
                            Text(
                              cPhone,
                              style: AppTextStyles.text12.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
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

class _PersonalRowData {
  final IconData icon;
  final String label;
  final String value;
  const _PersonalRowData(this.icon, this.label, this.value);
}
