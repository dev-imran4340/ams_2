import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_spaces.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../controller/qr_scan_controller.dart';

class ScannerControlBar extends GetView<QRScanController> {
  const ScannerControlBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.15),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 1. Torch Toggle Button
          Obx(() {
            final active = controller.torchEnabled.value;
            return _buildActionButton(
              icon: active ? Icons.flashlight_on_rounded : Icons.flashlight_off_rounded,
              label: 'Flashlight',
              isActive: active,
              onTap: controller.toggleTorch,
            );
          }),

          // Divider
          Container(
            width: 1.w,
            height: 32.h,
            color: AppColors.white.withValues(alpha: 0.15),
          ),

          // 2. Camera Lens Flip
          Obx(() {
            final isFront = controller.cameraFacingFront.value;
            return _buildActionButton(
              icon: Icons.flip_camera_ios_rounded,
              label: isFront ? 'Front Lens' : 'Rear Lens',
              isActive: isFront,
              onTap: controller.toggleCamera,
            );
          }),

          // Divider
          Container(
            width: 1.w,
            height: 32.h,
            color: AppColors.white.withValues(alpha: 0.15),
          ),

          // 3. Manual Entry Helper
          _buildActionButton(
            icon: Icons.keyboard_alt_outlined,
            label: 'Enter Code',
            isActive: false,
            onTap: () => _openManualEntrySheet(context),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38.r,
                height: 38.r,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.secondary
                      : AppColors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: AppColors.secondary.withValues(alpha: 0.5),
                            blurRadius: 10.r,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  icon,
                  size: 18.sp,
                  color: isActive ? AppColors.white : AppColors.white.withValues(alpha: 0.85),
                ),
              ),
              AppSpaces.vSpace4,
              Text(
                label,
                style: AppTextStyles.text10.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Opens the manual Employee ID entry bottom sheet
  void _openManualEntrySheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          border: Border.all(
            color: AppColors.borderColor,
            width: 1.w,
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bottom Sheet Handle
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.subTextColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              AppSpaces.vSpace14,

              Row(
                children: [
                  Container(
                    width: 32.r,
                    height: 32.r,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.badge_outlined,
                      size: 17.sp,
                      color: AppColors.secondary,
                    ),
                  ),
                  AppSpaces.hSpace10,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Manual Badge Code',
                        style: AppTextStyles.text14.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                      Text(
                        'Enter Employee ID if QR code is damaged',
                        style: AppTextStyles.text10.copyWith(
                          color: AppColors.subTextColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              AppSpaces.vSpace18,

              CustomTextField(
                controller: controller.manualCodeController,
                focusNode: controller.manualCodeFocusNode,
                labelText: 'Employee ID',
                hintText: 'e.g. EMP-0428',
                prefixIcon: const Icon(Icons.fingerprint_rounded),
              ),

              AppSpaces.vSpace20,

              CustomButton(
                text: 'Verify Badge Code',
                isGradient: true,
                onPressed: controller.submitManualCode,
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
