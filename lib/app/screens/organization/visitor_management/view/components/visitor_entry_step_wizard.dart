import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_spaces.dart';
import '../../../../../core/utils/app_text_styles.dart';

class VisitorEntryStepWizard extends StatelessWidget {
  final int currentStep; // 0 = Capture Selfie, 1 = Fill Details, 2 = Pass Generated

  const VisitorEntryStepWizard({
    super.key,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderColor, width: 1.w),
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
          // Step 1: Selfie
          _buildStepNode(
            stepNumber: 1,
            title: 'Capture Selfie',
            isActive: currentStep >= 0,
            isCompleted: currentStep > 0,
          ),
          _buildConnector(isCompleted: currentStep > 0),
          // Step 2: Information
          _buildStepNode(
            stepNumber: 2,
            title: 'Guest Details',
            isActive: currentStep >= 1,
            isCompleted: currentStep > 1,
          ),
          _buildConnector(isCompleted: currentStep > 1),
          // Step 3: Pass
          _buildStepNode(
            stepNumber: 3,
            title: 'Pass Issued',
            isActive: currentStep >= 2,
            isCompleted: currentStep >= 2,
          ),
        ],
      ),
    );
  }

  Widget _buildStepNode({
    required int stepNumber,
    required String title,
    required bool isActive,
    required bool isCompleted,
  }) {
    Color circleColor;
    Color textColor;
    Widget iconOrText;

    if (isCompleted) {
      circleColor = AppColors.secondary;
      textColor = AppColors.textColor;
      iconOrText = Icon(
        Icons.check_rounded,
        size: 13.sp,
        color: AppColors.white,
      );
    } else if (isActive) {
      circleColor = AppColors.primary;
      textColor = AppColors.primary;
      iconOrText = Text(
        '$stepNumber',
        style: AppTextStyles.text10.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
        ),
      );
    } else {
      circleColor = AppColors.borderColor;
      textColor = AppColors.subTextColor;
      iconOrText = Text(
        '$stepNumber',
        style: AppTextStyles.text10.copyWith(
          color: AppColors.subTextColor,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22.r,
          height: 22.r,
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle,
          ),
          child: Center(child: iconOrText),
        ),
        AppSpaces.hSpace6,
        Text(
          title,
          style: AppTextStyles.text10.copyWith(
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildConnector({required bool isCompleted}) {
    return Expanded(
      child: Container(
        height: 2.h,
        margin: EdgeInsets.symmetric(horizontal: 6.w),
        decoration: BoxDecoration(
          color: isCompleted ? AppColors.secondary : AppColors.borderColor,
          borderRadius: BorderRadius.circular(1.r),
        ),
      ),
    );
  }
}
