import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_spaces.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../controller/face_recognition_controller.dart';

class VerificationSuccessSheet extends GetView<FaceRecognitionController> {
  const VerificationSuccessSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        border: Border.all(
          color: AppColors.borderColor,
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 36.r,
            offset: Offset(0, -10.h),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                width: 44.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.subTextColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),

              AppSpaces.vSpace14,

              // Glowing Success Avatar Badge
              Container(
                width: 64.r,
                height: 64.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.success.withValues(alpha: 0.15),
                  border: Border.all(
                    color: AppColors.success,
                    width: 2.5.w,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withValues(alpha: 0.35),
                      blurRadius: 18.r,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.verified_user_rounded,
                    size: 34.sp,
                    color: AppColors.success,
                  ),
                ),
              ),

              AppSpaces.vSpace12,

              // Title: Authentication Successful
              Text(
                'Authentication Successful',
                style: AppTextStyles.text18.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),

              AppSpaces.vSpace4,

              Text(
                'Identity confirmed via multi-factor AI biometrics',
                textAlign: TextAlign.center,
                style: AppTextStyles.text12.copyWith(
                  color: AppColors.subTextColor,
                ),
              ),

              AppSpaces.vSpace16,

              // Employee Verification Credential Card
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: AppColors.borderColor,
                    width: 1.w,
                  ),
                ),
                child: Column(
                  children: [
                    // Row 1: Employee Name
                    _buildCredentialRow(
                      icon: Icons.person_outline_rounded,
                      label: 'Employee Name',
                      value: controller.employeeName.value,
                    ),

                    AppSpaces.vSpace8,
                    Divider(color: AppColors.borderColor, height: 1.h),
                    AppSpaces.vSpace8,

                    // Row 2: Badge ID
                    _buildCredentialRow(
                      icon: Icons.badge_outlined,
                      label: 'Employee Code',
                      value: controller.employeeId.value,
                    ),

                    AppSpaces.vSpace8,
                    Divider(color: AppColors.borderColor, height: 1.h),
                    AppSpaces.vSpace8,

                    // Row 3: Biometric Match Confidence
                    _buildCredentialRow(
                      icon: Icons.fingerprint_rounded,
                      label: 'Biometric Match',
                      value: '99.4% • Liveness Passed',
                      valueColor: AppColors.success,
                    ),
                  ],
                ),
              ),

              AppSpaces.vSpace18,

              // Primary Action Button: Proceed to Dashboard
              CustomButton(
                text: 'Proceed to Dashboard',
                isGradient: true,
                onPressed: controller.proceedToDashboard,
              ),

              AppSpaces.vSpace12,

              // Signature Brand 3.w Teal Bottom Accent Line
              Center(
                child: Container(
                  width: 80.w,
                  height: 3.5.h,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),

              AppSpaces.vSpace4,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCredentialRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16.sp,
          color: AppColors.subTextColor,
        ),
        AppSpaces.hSpace8,
        Text(
          label,
          style: AppTextStyles.text12.copyWith(
            color: AppColors.subTextColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTextStyles.text12.copyWith(
            color: valueColor ?? AppColors.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
