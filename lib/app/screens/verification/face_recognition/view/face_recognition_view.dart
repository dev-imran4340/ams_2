import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/network_boundary_wrapper.dart';
import '../controller/face_recognition_controller.dart';
import 'components/ai_matching_telemetry_card.dart';
import 'components/biometric_oval_viewfinder.dart';

class FaceRecognitionView extends GetView<FaceRecognitionController> {
  const FaceRecognitionView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkBoundaryWrapper(
      child: Scaffold(
        backgroundColor: const Color(0xFF031422), // Deep corporate dark backdrop
        body: Stack(
          children: [
            // 1. Full-screen Camera Simulator Ambient Radial Background
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

            // 2. Center Biometric Oval Viewfinder with Concentric Pulse Rings
            const Positioned.fill(
              child: BiometricOvalViewfinder(),
            ),

            // 3. Signature Ambient Curved Header
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildCurvedHeader(context),
            ),

            // 4. Floating Bottom AI Telemetry & Progress Card
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                top: false,
                child: AiMatchingTelemetryCard(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Signature Ambient Curved Header with Back Button & Step Capsule
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
                    color: AppColors.success.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.4),
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
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      AppSpaces.hSpace6,
                      Text(
                        'Step 2 of 2 • Liveness Check',
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
                  'Facial Biometric Match',
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
}
