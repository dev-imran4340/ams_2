import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ams_2/app/core/utils/app_colors.dart';
import 'package:ams_2/app/core/utils/app_spaces.dart';
import 'package:ams_2/app/core/utils/app_text_styles.dart';


import 'package:ams_2/app/screens/employees/model/department_employee_model.dart';

class DepartmentStaffCard extends StatelessWidget {
  final DepartmentEmployeeModel employee;
  final VoidCallback onTap;

  const DepartmentStaffCard({
    super.key,
    required this.employee,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(15.r),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(
              color: AppColors.borderColor,
              width: 1.w,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.04),
                blurRadius: 10.r,
                offset: Offset(0, 3.h),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar with online / active status
              Container(
                width: 46.r,
                height: 46.r,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.4),
                    width: 1.5.w,
                  ),
                ),
                child: Center(
                  child: Text(
                    employee.name.isNotEmpty ? employee.name[0].toUpperCase() : 'E',
                    style: AppTextStyles.text18.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),

              AppSpaces.hSpace12,

              // Name, Role, and Department
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
                            style: AppTextStyles.text14.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor,
                            ),
                          ),
                        ),
                        AppSpaces.hSpace6,
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: (employee.status == 'Active'
                                    ? AppColors.success
                                    : AppColors.warning)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4.r),
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
                    AppSpaces.vSpace2,
                    Text(
                      employee.designation,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.text12.copyWith(
                        color: AppColors.subTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    AppSpaces.vSpace2,
                    Text(
                      '#${employee.employeeCode} • ${employee.department}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.text10.copyWith(
                        color: AppColors.subTextColor.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),

              // Chevron action
              Icon(
                Icons.chevron_right_rounded,
                size: 20.sp,
                color: AppColors.subTextColor.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
