import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/network_boundary_wrapper.dart';
import '../controller/qr_scan_controller.dart';
import 'components/scanner_control_bar.dart';
import 'components/scanner_laser_overlay.dart';

class QRScannerView extends GetView<QRScanController> {
  const QRScannerView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkBoundaryWrapper(
      child: Scaffold(
        backgroundColor: const Color(0xFF031422), // Deep corporate dark backdrop
        body: Stack(
          children: [
            // 1. Full-screen Camera Viewfinder Background with Ambient Gradients
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.0,
                    colors: [
                      Color(0xFF0A2238),
                      Color(0xFF031422),
                      Color(0xFF010A12),
                    ],
                  ),
                ),
              ),
            ),

            // 2. Center Scanning Laser Overlay with Viewfinder
            const Positioned.fill(
              child: ScannerLaserOverlay(),
            ),

            // 3. Signature Ambient Curved Header
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildCurvedHeader(context),
            ),

            // 4. Floating Bottom Action Controls & Demo Trigger
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Demo Instant Scan Quick Action
                    _buildDemoScanPill(),

                    AppSpaces.vSpace8,

                    // Bottom Control Bar
                    const ScannerControlBar(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Ambient Curved Gradient Header matching executive style
  Widget _buildCurvedHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8.h,
        left: 16.w,
        right: 16.w,
        bottom: 18.h,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.95),
            AppColors.primary.withValues(alpha: 0.75),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          // Glass Back Button Pill
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                Get.back();
              },
              borderRadius: BorderRadius.circular(20.r),
              child: Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.3),
                    width: 1.w,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 15.sp,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ),

          AppSpaces.hSpace12,

          // Title & Step Progress Capsule
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Step Capsule Badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 3.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppColors.secondary.withValues(alpha: 0.4),
                      width: 0.8.w,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6.r,
                        height: 6.r,
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      AppSpaces.hSpace6,
                      Text(
                        'Step 1 of 2 • Identity Verification',
                        style: AppTextStyles.text10.copyWith(
                          color: AppColors.liteSecondary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),

                AppSpaces.vSpace4,

                Text(
                  'Employee Card Scan',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.text18.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Quick pill to simulate scan for testing and demoing
  Widget _buildDemoScanPill() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          controller.simulateSampleScan();
        },
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppColors.secondary.withValues(alpha: 0.5),
              width: 1.w,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.touch_app_rounded,
                size: 13.sp,
                color: AppColors.liteSecondary,
              ),
              AppSpaces.hSpace6,
              Text(
                'Simulate Quick Scan (EMP-0428)',
                style: AppTextStyles.text10.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
