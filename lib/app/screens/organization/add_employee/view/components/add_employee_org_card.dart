import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_spaces.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../controller/add_employee_controller.dart';
import 'add_employee_section_header.dart';

class AddEmployeeOrgCard extends GetView<AddEmployeeController> {
  const AddEmployeeOrgCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.borderColor,
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 18.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section 4 Header Banner
          const AddEmployeeSectionHeader(
            title: 'Organization Placement',
            icon: Icons.business_outlined,
          ),

          AppSpaces.vSpace16,

          // Department Dropdown
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Department',
                style: AppTextStyles.text14.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
              AppSpaces.vSpace8,
              Obx(() {
                final departments = controller.lookups.value?.departments ??
                    [
                      'Software Engineering',
                      'Quality Assurance',
                      'Product Design',
                      'Human Resources',
                    ];
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.borderColor, width: 1.w),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.selectedDepartment.value.isNotEmpty
                          ? controller.selectedDepartment.value
                          : null,
                      hint: Text(
                        '--Select department--',
                        style: AppTextStyles.text14.copyWith(color: AppColors.hintColor),
                      ),
                      isExpanded: true,
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.secondary,
                        size: 20.sp,
                      ),
                      items: departments.map((d) {
                        return DropdownMenuItem<String>(
                          value: d,
                          child: Row(
                            children: [
                              Icon(
                                Icons.apartment_rounded,
                                size: 18.sp,
                                color: AppColors.secondary,
                              ),
                              AppSpaces.hSpace10,
                              Expanded(
                                child: Text(
                                  d,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.text14.copyWith(color: AppColors.textColor),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) controller.selectedDepartment.value = val;
                      },
                    ),
                  ),
                );
              }),
            ],
          ),

          AppSpaces.vSpace14,

          // Designation Dropdown
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Designation / Role',
                style: AppTextStyles.text14.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
              AppSpaces.vSpace8,
              Obx(() {
                final roles = controller.lookups.value?.designations ??
                    [
                      'Associate Software Engineer',
                      'Senior Flutter Developer',
                      'Lead Architect',
                    ];
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.borderColor, width: 1.w),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.selectedDesignation.value.isNotEmpty
                          ? controller.selectedDesignation.value
                          : null,
                      hint: Text(
                        '--Select designation--',
                        style: AppTextStyles.text14.copyWith(color: AppColors.hintColor),
                      ),
                      isExpanded: true,
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.secondary,
                        size: 20.sp,
                      ),
                      items: roles.map((r) {
                        return DropdownMenuItem<String>(
                          value: r,
                          child: Row(
                            children: [
                              Icon(
                                Icons.badge_outlined,
                                size: 18.sp,
                                color: AppColors.secondary,
                              ),
                              AppSpaces.hSpace10,
                              Expanded(
                                child: Text(
                                  r,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.text14.copyWith(color: AppColors.textColor),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) controller.selectedDesignation.value = val;
                      },
                    ),
                  ),
                );
              }),
            ],
          ),

          AppSpaces.vSpace14,

          // Shift Dropdown
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Work Shift Schedule',
                style: AppTextStyles.text14.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
              AppSpaces.vSpace8,
              Obx(() {
                final shifts = controller.lookups.value?.shifts ??
                    [
                      'Morning General (09:00 AM - 06:00 PM)',
                      'Night Shift (08:00 PM - 05:00 AM)',
                    ];
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.borderColor, width: 1.w),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.selectedShift.value.isNotEmpty
                          ? controller.selectedShift.value
                          : null,
                      hint: Text(
                        '--Select shift--',
                        style: AppTextStyles.text14.copyWith(color: AppColors.hintColor),
                      ),
                      isExpanded: true,
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.secondary,
                        size: 20.sp,
                      ),
                      items: shifts.map((s) {
                        return DropdownMenuItem<String>(
                          value: s,
                          child: Row(
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                size: 18.sp,
                                color: AppColors.secondary,
                              ),
                              AppSpaces.hSpace10,
                              Expanded(
                                child: Text(
                                  s,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.text14.copyWith(color: AppColors.textColor),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) controller.selectedShift.value = val;
                      },
                    ),
                  ),
                );
              }),
            ],
          ),

          AppSpaces.vSpace14,

          // Joining Date
          InkWell(
            onTap: () => controller.selectDate(context, controller.joiningDateController),
            child: IgnorePointer(
              child: CustomTextField(
                labelText: 'Joining Date',
                hintText: 'YYYY-MM-DD',
                prefixIcon: Icon(
                  Icons.calendar_today_rounded,
                  size: 20.sp,
                  color: AppColors.secondary,
                ),
                controller: controller.joiningDateController,
                focusNode: controller.joiningDateFocusNode,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
