import 'package:ams_2/app/core/utils/app_colors.dart';
import 'package:ams_2/app/core/utils/app_spaces.dart';
import 'package:ams_2/app/core/utils/app_text_styles.dart';
import 'package:ams_2/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';


import '../../model/department_employee_model.dart';

class EmployeeDetailSheet extends StatelessWidget {
  final DepartmentEmployeeModel employee;
  final bool canViewSensitive;
  final bool canPrintCard;

  const EmployeeDetailSheet({
    super.key,
    required this.employee,
    required this.canViewSensitive,
    required this.canPrintCard,
  });

  @override
  Widget build(BuildContext context) {
       final heroParts = [
                          if (employee.designation.trim().isNotEmpty)
                            employee.designation.trim(),
                          if (employee.employeeCode.trim().isNotEmpty)
                            employee.employeeCode.trim(),
                        ];
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        border: Border.all(color: AppColors.borderColor, width: 1.w),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bottom Sheet Grabber
              Center(
                child: Container(
                  width: 44.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: AppColors.borderColor,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),

              // 1. Employee Hero Header
              Row(
                children: [
                  Container(
                    width: 54.r,
                    height: 54.r,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.secondary,
                        width: 2.w,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        employee.name.isNotEmpty ? employee.name[0].toUpperCase() : 'E',
                        style: AppTextStyles.text20.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  AppSpaces.hSpace12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                employee.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.text16.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ),
                            AppSpaces.hSpace8,
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: (employee.status == 'Active'
                                        ? AppColors.success
                                        : AppColors.warning)
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                employee.status,
                                style: AppTextStyles.text10.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: employee.status == 'Active'
                                      ? AppColors.success
                                      : AppColors.warning,
                                ),
                              ),
                            ),
                          ],
                        ),
                     
                        if (heroParts.isNotEmpty) ...[
                          AppSpaces.vSpace2,
                          Text(
                            heroParts.join(' • '),
                            style: AppTextStyles.text12.copyWith(
                              color: AppColors.subTextColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              AppSpaces.vSpace16,
              Container(height: 1.h, color: AppColors.borderColor),
              AppSpaces.vSpace14,

              // 2. Employment & Corporate Overview (Only non-empty rows)
              Builder(
                builder: (context) {
                  final employmentRows = <Widget>[];
                  if (employee.department.trim().isNotEmpty) {
                    employmentRows.add(_buildInfoRow(
                        Icons.business_rounded, 'Department', employee.department));
                  }
                  if (employee.email.trim().isNotEmpty) {
                    if (employmentRows.isNotEmpty) employmentRows.add(AppSpaces.vSpace6);
                    employmentRows.add(_buildInfoRow(
                        Icons.alternate_email_rounded, 'Official Email', employee.email));
                  }
                  if (employee.joiningDate.trim().isNotEmpty) {
                    if (employmentRows.isNotEmpty) employmentRows.add(AppSpaces.vSpace6);
                    employmentRows.add(_buildInfoRow(
                        Icons.event_available_rounded, 'Joining Date', employee.joiningDate));
                  }

                  if (employmentRows.isEmpty) return const SizedBox.shrink();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('EMPLOYMENT PROFILE'),
                      AppSpaces.vSpace8,
                      ...employmentRows,
                    ],
                  );
                },
              ),

              // 3. Sensitive Data Section (Strictly gated & only non-empty fields)
              if (canViewSensitive) ...[
                Builder(
                  builder: (context) {
                    final sensitiveRows = <Widget>[];
                    if (employee.personalPhone != null &&
                        employee.personalPhone!.trim().isNotEmpty) {
                      sensitiveRows.add(_buildInfoRow(
                        Icons.phone_iphone_rounded,
                        'Personal Phone',
                        employee.personalPhone!,
                      ));
                    }
                    if (employee.residentialAddress != null &&
                        employee.residentialAddress!.trim().isNotEmpty) {
                      if (sensitiveRows.isNotEmpty) sensitiveRows.add(AppSpaces.vSpace6);
                      sensitiveRows.add(_buildInfoRow(
                        Icons.home_rounded,
                        'Residential Address',
                        employee.residentialAddress!,
                      ));
                    }
                    if (employee.emergencyContact != null &&
                        employee.emergencyContact!.trim().isNotEmpty) {
                      if (sensitiveRows.isNotEmpty) sensitiveRows.add(AppSpaces.vSpace6);
                      sensitiveRows.add(_buildInfoRow(
                        Icons.contact_phone_rounded,
                        'Emergency Contact',
                        employee.emergencyContact!,
                      ));
                    }
                    if (employee.passportOrCnicExpiry != null &&
                        employee.passportOrCnicExpiry!.trim().isNotEmpty) {
                      if (sensitiveRows.isNotEmpty) sensitiveRows.add(AppSpaces.vSpace6);
                      sensitiveRows.add(_buildInfoRow(
                        Icons.badge_rounded,
                        'Passport / CNIC Expiry',
                        employee.passportOrCnicExpiry!,
                      ));
                    }

                    if (sensitiveRows.isEmpty) return const SizedBox.shrink();

                    return Padding(
                      padding: EdgeInsets.only(top: 18.h),
                      child: Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: AppColors.inputFill.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(15.r),
                          border: Border.all(
                            color: AppColors.secondary.withValues(alpha: 0.25),
                            width: 1.w,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.shield_rounded,
                                    size: 16.sp, color: AppColors.secondary),
                                AppSpaces.hSpace6,
                                Text(
                                  'CONFIDENTIAL / SENSITIVE DATA',
                                  style: AppTextStyles.text10.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.secondary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            AppSpaces.vSpace10,
                            ...sensitiveRows,
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],

              // 4. Print / Export ID Card Button (Gated strictly by 'employees.cards.print')
              if (canPrintCard) ...[
                AppSpaces.vSpace18,
                SizedBox(
                  width: double.infinity,
                  height: 46.h,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.back();
                      Get.toNamed(Routes.EMPLOYEE_CARD);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    icon: Icon(Icons.print_rounded, size: 18.sp, color: AppColors.liteSecondary),
                    label: Text(
                      'Print / Export ID Card',
                      style: AppTextStyles.text14.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.text10.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.subTextColor,
        letterSpacing: 0.7,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15.sp, color: AppColors.subTextColor),
        AppSpaces.hSpace8,
        SizedBox(
          width: 120.w,
          child: Text(
            label,
            style: AppTextStyles.text12.copyWith(
              color: AppColors.subTextColor,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.text12.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textColor,
            ),
          ),
        ),
      ],
    );
  }
}
