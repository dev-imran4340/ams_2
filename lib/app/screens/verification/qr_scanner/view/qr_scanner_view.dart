import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

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
        backgroundColor: AppColors.primary,
        body: Stack(
          children: [
            // 1. Live Hardware Camera Preview with MobileScanner
            Positioned.fill(
              child: MobileScanner(
                controller: controller.scannerController,
                onDetect: controller.onBarcodeDetected,
                fit: BoxFit.cover,
                errorBuilder: (context, error) {
                  return _buildCameraFallbackView();
                },
              ),
            ),

            // 2. High-Tech Laser Reticle & Cinematic Cutout Viewfinder Overlay
            const Positioned.fill(child: ScannerLaserOverlay()),

            // 3. Signature Curved Ambient Gradient Header (240.h) with Floating Rings
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildCurvedAmbientHeader(context),
            ),

            // 4. Floating Bottom Action Controls & Fast Testing Pill
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Fast Simulator Demo Pill
                    _buildDemoScanPill(),

                    AppSpaces.vSpace8,

                    // Bottom Floating Control Bar (Torch, Camera Flip, Manual Input)
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

  /// Executive Signature Curved Ambient Gradient Header with floating translucent rings
  Widget _buildCurvedAmbientHeader(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      height: 240.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.r),
          bottomRight: Radius.circular(24.r),
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.95),
            AppColors.accentNavy.withValues(alpha: 0.85),
            AppColors.primary.withValues(alpha: 0.4),
            Colors.transparent,
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.r),
          bottomRight: Radius.circular(24.r),
        ),
        child: Stack(
          children: [
            // Ambient Floating Translucent Ring 1 (Top Right)
            Positioned(
              top: -30.h,
              right: -35.w,
              child: Container(
                width: 150.r,
                height: 150.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary.withValues(alpha: 0.05),
                  border: Border.all(
                    color: AppColors.liteSecondary.withValues(alpha: 0.12),
                    width: 1.5.w,
                  ),
                ),
              ),
            ),

            // Ambient Floating Translucent Ring 2 (Left)
            Positioned(
              top: 25.h,
              left: -40.w,
              child: Container(
                width: 120.r,
                height: 120.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.08),
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    width: 1.2.w,
                  ),
                ),
              ),
            ),

            // Header Content Layout
            Padding(
              padding: EdgeInsets.only(
                top: topPadding + 8.h,
                left: 16.w,
                right: 16.w,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Glass Pill Button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Get.back();
                      },
                      borderRadius: BorderRadius.circular(20.r),
                      child: Container(
                        width: 38.r,
                        height: 38.r,
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.14),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.white.withValues(alpha: 0.28),
                            width: 1.w,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              blurRadius: 8.r,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 16.sp,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  AppSpaces.hSpace14,

                  // Title and Subtitle Capsule Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Subtitle Capsule: Step 1 of 2 • Scan Employee ID Card
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: AppColors.secondary.withValues(
                                alpha: 0.45,
                              ),
                              width: 1.w,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6.r,
                                height: 6.r,
                                decoration: const BoxDecoration(
                                  color: AppColors.secondary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              AppSpaces.hSpace6,
                              Text(
                                'Step 1 of 2 • Scan Employee ID Card',
                                style: AppTextStyles.text10.copyWith(
                                  color: AppColors.liteSecondary,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),

                        AppSpaces.vSpace6,

                        // Title: Card Verification
                        Text(
                          'Card Verification',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.text22.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Elegant Camera Fallback View for Simulator & Restricted Camera Permissions
  Widget _buildCameraFallbackView() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [AppColors.accentNavy, AppColors.primary],
        ),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72.r,
                height: 72.r,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.3),
                    width: 1.5.w,
                  ),
                ),
                child: Icon(
                  Icons.camera_alt_outlined,
                  size: 34.sp,
                  color: AppColors.liteSecondary,
                ),
              ),
              AppSpaces.vSpace14,
              Text(
                'Camera Hardware Standby',
                style: AppTextStyles.text16.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppSpaces.vSpace6,
              Text(
                'Point camera at your corporate badge, or enter your code manually below.',
                textAlign: TextAlign.center,
                style: AppTextStyles.text12.copyWith(
                  color: AppColors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Quick testing pill to trigger instant verification during development & review
  Widget _buildDemoScanPill() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: controller.simulateSampleScan,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.22),
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
                Icons.bolt_rounded,
                size: 14.sp,
                color: AppColors.liteSecondary,
              ),
              AppSpaces.hSpace6,
              Text(
                'Quick Scan Demo (SFT-094)',
                style: AppTextStyles.text10.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
