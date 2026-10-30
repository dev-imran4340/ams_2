import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/network_boundary_wrapper.dart';
import '../controller/face_recognition_controller.dart';
import 'components/biometric_oval_viewfinder.dart';
import 'components/face_matching_telemetry_card.dart';

class FaceRecognitionView extends GetView<FaceRecognitionController> {
  const FaceRecognitionView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkBoundaryWrapper(
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          await controller.cleanupAndExit();
        },
        child: Scaffold(
        backgroundColor: AppColors.primary,
        body: Stack(
          children: [
            // 1. Full-screen Camera Ambient Background
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.2,
                    colors: [
                      AppColors.accentNavy,
                      AppColors.primary,
                    ],
                  ),
                ),
              ),
            ),

            // 2. Center Biometric Oval Viewfinder with Live Front Camera & Radar Rings
            const Positioned.fill(
              child: BiometricOvalViewfinder(),
            ),

            // 3. Signature Curved Ambient Gradient Header (240.h) with Floating Rings
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildCurvedAmbientHeader(context),
            ),

            // 4. Floating Bottom AI Telemetry & Progress Card
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                top: false,
                child: FaceMatchingTelemetryCard(),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  /// Executive Signature Curved Ambient Gradient Header with Floating Translucent Rings
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
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        await controller.cleanupAndExit();
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
                        // Subtitle Capsule: Step 2 of 2 • Liveness Check
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: AppColors.success.withValues(alpha: 0.45),
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
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              AppSpaces.hSpace6,
                              Obx(
                                () => Text(
                                  controller.isPunchMode.value
                                      ? 'Attendance Punch • Face Verification'
                                      : 'AI Biometrics • Liveness Gate',
                                  style: AppTextStyles.text10.copyWith(
                                    color: AppColors.liteSecondary,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        AppSpaces.vSpace6,

                        // Title: Facial Biometric Match
                        Text(
                          'Facial Biometric Match',
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
}
