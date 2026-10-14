import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_spaces.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../controller/qr_scan_controller.dart';

class ManualCodeBottomSheet extends GetView<QRScanController> {
  const ManualCodeBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => PopScope(
        canPop: !controller.isLoading.value,
        child: Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        border: Border.all(
          color: AppColors.borderColor,
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 30.r,
            offset: Offset(0, -8.h),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Drag Handle
            Center(
              child: Container(
                width: 44.w,
                height: 4.5.h,
                decoration: BoxDecoration(
                  color: AppColors.subTextColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
            ),

            AppSpaces.vSpace16,

            // Header Icon & Title Row
            Row(
              children: [
                Container(
                  width: 38.r,
                  height: 38.r,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.secondary.withValues(alpha: 0.25),
                      width: 1.w,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.badge_outlined,
                      size: 20.sp,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
                AppSpaces.hSpace12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Manual Badge Code',
                        style: AppTextStyles.text16.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                      AppSpaces.vSpace2,
                      Text(
                        'Enter Employee ID if QR code is damaged or unreadable',
                        style: AppTextStyles.text12.copyWith(
                          color: AppColors.subTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: controller.isLoading.value ? null : () => Get.back(),
                  icon: Icon(
                    Icons.close_rounded,
                    color: AppColors.subTextColor,
                    size: 20.sp,
                  ),
                ),
              ],
            ),

            AppSpaces.vSpace20,

            // Text Input Field for Manual Code
            Padding(
              padding: AppSpaces.horizontalPadding12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomTextField(
                    controller: controller.manualCodeController,
                    focusNode: controller.manualCodeFocusNode,
                    labelText: 'Employee Code / ID',
                    hintText: 'e.g. SFT-094',
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => controller.submitManualCode(),
                    prefixIcon: Icon(
                      Icons.fingerprint_rounded,
                      size: 20.sp,
                      color: AppColors.secondary,
                    ),
                  ),

                  AppSpaces.vSpace20,

                  // Submit Button
                  Obx(
                    () => CustomButton(
                      text: 'Verify & Continue',
                      isGradient: true,
                      isLoading: controller.isLoading.value,
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.submitManualCode,
                    ),
                  ),

                  AppSpaces.vSpace14,

                  // Signature Brand 3.w Teal Bottom Accent Bar
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
          ],
        ),
      ),
    ),
    ),
    );
  }
}
