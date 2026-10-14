import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_spaces.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../controller/qr_scan_controller.dart';

class ScannerControlBar extends GetView<QRScanController> {
  const ScannerControlBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.18),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.45),
            blurRadius: 20.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 1. Flashlight Torch Toggle Button (Rear sensor only)
          Expanded(
            child: Obx(() {
              final active = controller.isTorchOn.value;
              return _buildControlCapsule(
                icon: active
                    ? Icons.flashlight_on_rounded
                    : Icons.flashlight_off_rounded,
                label: active ? 'Torch Active' : 'Flashlight',
                isActive: active,
                onTap: controller.toggleTorch,
              );
            }),
          ),

          // Elegant Vertical Separator
          Container(
            width: 1.w,
            height: 38.h,
            color: AppColors.white.withValues(alpha: 0.15),
          ),

          // 2. Enter Code Manually Button (Keyboard Fallback)
          Expanded(
            child: _buildControlCapsule(
              icon: Icons.keyboard_alt_outlined,
              label: 'Enter Code',
              isActive: false,
              onTap: () => controller.openManualCodeModal(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlCapsule({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.secondary
                      : AppColors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isActive
                        ? AppColors.liteSecondary
                        : AppColors.white.withValues(alpha: 0.2),
                    width: 1.w,
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: AppColors.secondary.withValues(alpha: 0.6),
                            blurRadius: 14.r,
                            spreadRadius: 1.r,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 20.sp,
                    color: isActive
                        ? AppColors.white
                        : AppColors.white.withValues(alpha: 0.85),
                  ),
                ),
              ),
              AppSpaces.vSpace4,
              Text(
                label,
                style: AppTextStyles.text10.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isActive
                      ? AppColors.liteSecondary
                      : AppColors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
