import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_spaces.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../controller/add_employee_controller.dart';

class EmployeeFaceEnrollmentCard extends GetView<AddEmployeeController> {
  const EmployeeFaceEnrollmentCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Card 1: Job Assignment & Department
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(
              color: AppColors.borderColor.withValues(alpha: 0.8),
              width: 1.w,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 24.r,
                offset: Offset(0, 10.h),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 32.r,
                    height: 32.r,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.work_history_rounded,
                        size: 18.sp,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  AppSpaces.hSpace8,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Job Assignment & Roster',
                          style: AppTextStyles.text14.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                        Text(
                          'Configure department placement and designated shift schedule',
                          style: AppTextStyles.text10.copyWith(
                            color: AppColors.subTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              AppSpaces.vSpace16,

              // Department Dropdown
              Text(
                'Department Placement *',
                style: AppTextStyles.text12.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
              AppSpaces.vSpace6,
              Obx(() {
                final depts = controller.lookups.value?.departments ?? ['Engineering', 'Design', 'Operations'];
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: AppColors.borderColor, width: 1.w),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.selectedDepartment.value,
                      isExpanded: true,
                      icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.secondary),
                      items: depts.map((d) {
                        return DropdownMenuItem<String>(
                          value: d,
                          child: Text(d, style: AppTextStyles.text12.copyWith(color: AppColors.textColor)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) controller.selectedDepartment.value = val;
                      },
                    ),
                  ),
                );
              }),

              AppSpaces.vSpace12,

              // Designation Dropdown
              Text(
                'Official Role / Designation *',
                style: AppTextStyles.text12.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
              AppSpaces.vSpace6,
              Obx(() {
                final roles = controller.lookups.value?.designations ?? ['Associate', 'Specialist', 'Lead'];
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: AppColors.borderColor, width: 1.w),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.selectedDesignation.value,
                      isExpanded: true,
                      icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.secondary),
                      items: roles.map((r) {
                        return DropdownMenuItem<String>(
                          value: r,
                          child: Text(r, style: AppTextStyles.text12.copyWith(color: AppColors.textColor)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) controller.selectedDesignation.value = val;
                      },
                    ),
                  ),
                );
              }),

              AppSpaces.vSpace12,

              // Shift Roster Dropdown
              Text(
                'Assigned Shift Roster *',
                style: AppTextStyles.text12.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
              AppSpaces.vSpace6,
              Obx(() {
                final shifts = controller.lookups.value?.shifts ?? ['Morning', 'Mid Shift', 'Night Shift'];
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: AppColors.borderColor, width: 1.w),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.selectedShift.value,
                      isExpanded: true,
                      icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.secondary),
                      items: shifts.map((s) {
                        return DropdownMenuItem<String>(
                          value: s,
                          child: Text(s, style: AppTextStyles.text12.copyWith(color: AppColors.textColor)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) controller.selectedShift.value = val;
                      },
                    ),
                  ),
                );
              }),

              AppSpaces.vSpace12,

              // Joining Date
              InkWell(
                onTap: () => controller.selectDate(context, controller.joiningDateController),
                child: IgnorePointer(
                  child: CustomTextField(
                    labelText: 'Date of Joining *',
                    hintText: 'YYYY-MM-DD',
                    prefixIcon: Icon(Icons.event_available_rounded, size: 18.sp, color: AppColors.secondary),
                    controller: controller.joiningDateController,
                    focusNode: controller.joiningDateFocusNode,
                  ),
                ),
              ),
            ],
          ),
        ),

        AppSpaces.vSpace16,

        // Card 2: AI Facial Biometric Enrollment Viewfinder
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(
              color: AppColors.borderColor.withValues(alpha: 0.8),
              width: 1.w,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 24.r,
                offset: Offset(0, 10.h),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32.r,
                        height: 32.r,
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.face_retouching_natural_rounded,
                            size: 18.sp,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                      AppSpaces.hSpace8,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI Facial Biometric Enrollment',
                            style: AppTextStyles.text14.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor,
                            ),
                          ),
                          Text(
                            'Generates 512-d FaceNet vector for terminal matching',
                            style: AppTextStyles.text10.copyWith(
                              color: AppColors.subTextColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Obx(
                    () => Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: controller.isFaceCaptured.value
                            ? AppColors.success.withValues(alpha: 0.1)
                            : AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        controller.isFaceCaptured.value ? 'Enrolled' : 'Pending',
                        style: AppTextStyles.text10.copyWith(
                          fontWeight: FontWeight.bold,
                          color: controller.isFaceCaptured.value ? AppColors.success : AppColors.warning,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              AppSpaces.vSpace16,

              // Viewfinder Mock Box
              Obx(() {
                final isEnrolled = controller.isFaceCaptured.value;

                return Container(
                  height: 200.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14.r),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.accentNavy,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.18),
                        blurRadius: 16.r,
                        offset: Offset(0, 6.h),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Ambient Grid lines
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.08,
                          child: GridPaper(
                            color: AppColors.white,
                            interval: 40.r,
                          ),
                        ),
                      ),

                      // Oval Biometric Face Contour Target
                      Container(
                        width: 120.w,
                        height: 155.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(60.r),
                          border: Border.all(
                            color: isEnrolled ? AppColors.success : AppColors.secondary,
                            width: 2.5.w,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (isEnrolled ? AppColors.success : AppColors.secondary).withValues(alpha: 0.3),
                              blurRadius: 20.r,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            isEnrolled ? Icons.check_circle_rounded : Icons.face_rounded,
                            size: 54.sp,
                            color: isEnrolled ? AppColors.success : AppColors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ),

                      // Floating Top Badge: Liveness Radar
                      Positioned(
                        top: 10.h,
                        left: 12.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: AppColors.black.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6.r,
                                height: 6.r,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isEnrolled ? AppColors.success : AppColors.secondary,
                                ),
                              ),
                              AppSpaces.hSpace6,
                              Text(
                                isEnrolled ? 'Anti-Spoof Liveness: 99.4%' : 'Center Face in Guide',
                                style: AppTextStyles.text10.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Floating Bottom Label
                      Positioned(
                        bottom: 10.h,
                        child: Text(
                          controller.capturedPhotoLabel.value,
                          style: AppTextStyles.text10.copyWith(
                            color: AppColors.white.withValues(alpha: 0.9),
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              AppSpaces.vSpace14,

              // Action Buttons Row
              Obx(() {
                if (controller.isFaceCaptured.value) {
                  return Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          isOutlined: true,
                          borderColor: AppColors.borderColor,
                          textColor: AppColors.subTextColor,
                          text: 'Reset Snapshot',
                          icon: Icon(Icons.refresh_rounded, size: 16.sp, color: AppColors.subTextColor),
                          onPressed: controller.resetCapturedFace,
                        ),
                      ),
                      AppSpaces.hSpace10,
                      Expanded(
                        child: CustomButton(
                          isGradient: true,
                          text: 'Re-Verify Biometric',
                          icon: Icon(Icons.camera_alt_rounded, size: 16.sp, color: AppColors.white),
                          onPressed: controller.simulateCaptureFace,
                        ),
                      ),
                    ],
                  );
                } else {
                  return CustomButton(
                    isGradient: true,
                    text: 'Capture Live Biometric Snapshot',
                    icon: Icon(Icons.camera_enhance_rounded, size: 18.sp, color: AppColors.white),
                    onPressed: controller.simulateCaptureFace,
                  );
                }
              }),
            ],
          ),
        ),
      ],
    );
  }
}
