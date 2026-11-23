import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:ams_2/app/core/utils/app_colors.dart';
import 'package:ams_2/app/core/utils/app_spaces.dart';
import 'package:ams_2/app/core/utils/app_text_styles.dart';
import 'package:ams_2/app/core/widgets/custom_button.dart';
import 'package:ams_2/app/core/widgets/custom_text_field.dart';
import '../../controller/kiosk_controller.dart';

class KioskClockInDialog extends StatelessWidget {
  final KioskController controller;

  const KioskClockInDialog({super.key, required this.controller});

  static Future<void> show(BuildContext context, {required KioskController controller}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => KioskClockInDialog(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          border: Border(
            top: BorderSide(color: AppColors.secondary, width: 3.w),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 38.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.borderColor,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),

              AppSpaces.vSpace16,

              // Modal Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kiosk Clock-In / Out',
                    style: AppTextStyles.text18.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),

              AppSpaces.vSpace8,

              Obx(() {
                final session = controller.identifiedSession.value;

                if (session == null) {
                  // Step 1: Identification Form (Emp # + PIN)
                  return Form(
                    key: controller.clockInFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enter your employee number and backup PIN to punch attendance.',
                          style: AppTextStyles.text12.copyWith(
                            color: AppColors.subTextColor,
                          ),
                        ),

                        AppSpaces.vSpace16,

                        CustomTextField(
                          controller: controller.empNumController,
                          focusNode: controller.empNumFocusNode,
                          labelText: 'Employee Number',
                          hintText: 'e.g. EMP-0001',
                          prefixIcon: const Icon(Icons.badge_outlined),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter employee number';
                            }
                            return null;
                          },
                        ),

                        AppSpaces.vSpace12,

                        CustomTextField(
                          controller: controller.terminalPinController,
                          focusNode: controller.terminalPinFocusNode,
                          labelText: 'Kiosk Backup PIN',
                          hintText: '4-6 digits',
                          obscureText: true,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter your 4-6 digit PIN';
                            }
                            return null;
                          },
                        ),

                        AppSpaces.vSpace20,

                        CustomButton(
                          text: 'Identify & Continue',
                          isGradient: true,
                          isLoading: controller.isSubmitting.value,
                          onPressed: controller.isSubmitting.value
                              ? null
                              : controller.identifyEmployeeAtKiosk,
                        ),
                      ],
                    ),
                  );
                } else {
                  // Step 2: Identified Employee Punch Actions
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20.r,
                              backgroundColor: AppColors.primary,
                              child: Text(
                                session.person.name.isNotEmpty
                                    ? session.person.name.substring(0, 1).toUpperCase()
                                    : 'E',
                                style: TextStyle(color: Colors.white, fontSize: 16.sp),
                              ),
                            ),
                            AppSpaces.hSpace12,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    session.person.name,
                                    style: AppTextStyles.text14.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textColor,
                                    ),
                                  ),
                                  Text(
                                    'ID: ${session.person.employeeNumber}',
                                    style: AppTextStyles.text12.copyWith(
                                      color: AppColors.subTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      AppSpaces.vSpace20,

                      Text(
                        'Select Attendance Action:',
                        style: AppTextStyles.text14.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),

                      AppSpaces.vSpace12,

                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: 'Check-In',
                              isGradient: true,
                              isLoading: controller.isSubmitting.value,
                              onPressed: controller.isSubmitting.value
                                  ? null
                                  : () async {
                                      await controller.punchAttendanceAction('in');
                                      Get.back();
                                    },
                            ),
                          ),
                          AppSpaces.hSpace12,
                          Expanded(
                            child: OutlinedButton(
                              onPressed: controller.isSubmitting.value
                                  ? null
                                  : () async {
                                      await controller.punchAttendanceAction('out');
                                      Get.back();
                                    },
                              style: OutlinedButton.styleFrom(
                                minimumSize: Size(double.infinity, 44.h),
                                side: BorderSide(color: AppColors.secondary, width: 1.5.w),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                              ),
                              child: Text(
                                'Check-Out',
                                style: AppTextStyles.text14.copyWith(
                                  color: AppColors.secondary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }
              }),

              AppSpaces.vSpace16,
            ],
          ),
        ),
      ),
    );
  }
}
