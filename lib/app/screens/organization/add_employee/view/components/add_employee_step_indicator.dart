import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_spaces.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../controller/add_employee_controller.dart';

class AddEmployeeStepIndicator extends GetView<AddEmployeeController> {
  const AddEmployeeStepIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final current = controller.activeStep.value;

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
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
              blurRadius: 18.r,
              offset: Offset(0, 6.h),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildStepItem(
              index: 0,
              label: 'Personal',
              icon: Icons.person_rounded,
              isActive: current == 0,
              isCompleted: current > 0,
            ),
            _buildDivider(current > 0),
            _buildStepItem(
              index: 1,
              label: 'Address',
              icon: Icons.location_on_rounded,
              isActive: current == 1,
              isCompleted: current > 1,
            ),
            _buildDivider(current > 1),
            _buildStepItem(
              index: 2,
              label: 'Biometrics',
              icon: Icons.face_retouching_natural_rounded,
              isActive: current == 2,
              isCompleted: controller.isFaceCaptured.value,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStepItem({
    required int index,
    required String label,
    required IconData icon,
    required bool isActive,
    required bool isCompleted,
  }) {
    final Color color = isCompleted
        ? AppColors.success
        : isActive
            ? AppColors.secondary
            : AppColors.subTextColor.withValues(alpha: 0.5);

    return Expanded(
      child: InkWell(
        onTap: () => controller.setStep(index),
        borderRadius: BorderRadius.circular(10.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36.r,
              height: 36.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? AppColors.success.withValues(alpha: 0.12)
                    : isActive
                        ? AppColors.secondary.withValues(alpha: 0.15)
                        : AppColors.borderColor.withValues(alpha: 0.5),
                border: Border.all(
                  color: color,
                  width: isActive ? 2.w : 1.w,
                ),
              ),
              child: Center(
                child: Icon(
                  isCompleted ? Icons.check_rounded : icon,
                  size: 18.sp,
                  color: color,
                ),
              ),
            ),
            AppSpaces.vSpace4,
            Text(
              label,
              style: AppTextStyles.text10.copyWith(
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? AppColors.textColor : AppColors.subTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(bool isPassed) {
    return Container(
      width: 24.w,
      height: 2.h,
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: isPassed ? AppColors.success : AppColors.borderColor,
        borderRadius: BorderRadius.circular(1.r),
      ),
    );
  }
}
