import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../controller/face_recognition_controller.dart';

class BiometricOvalViewfinder extends GetView<FaceRecognitionController> {
  const BiometricOvalViewfinder({super.key});

  @override
  Widget build(BuildContext context) {
    final ovalWidth = 240.w;
    final ovalHeight = 310.h;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Concentric Animated Pulsing Radar Rings
          Obx(() {
            if (controller.matchSuccess.value) {
              return const SizedBox.shrink();
            }

            return AnimatedBuilder(
              animation: controller.pulseAnimation,
              builder: (context, child) {
                final scale = controller.pulseAnimation.value;
                return Container(
                  width: ovalWidth * scale + 24.w,
                  height: ovalHeight * scale + 24.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.elliptical(
                        (ovalWidth * scale + 24.w) / 2,
                        (ovalHeight * scale + 24.h) / 2,
                      ),
                    ),
                    border: Border.all(
                      color: AppColors.secondary.withValues(
                        alpha: (0.35 * (1.2 - scale)).clamp(0.05, 0.4),
                      ),
                      width: 1.5.w,
                    ),
                  ),
                );
              },
            );
          }),

          // 2. Main Oval Viewfinder Frame
          Obx(() {
            final isSuccess = controller.matchSuccess.value;
            final borderColor = isSuccess ? AppColors.success : AppColors.secondary;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              width: ovalWidth,
              height: ovalHeight,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.18),
                borderRadius: BorderRadius.all(
                  Radius.elliptical(ovalWidth / 2, ovalHeight / 2),
                ),
                border: Border.all(
                  color: borderColor,
                  width: isSuccess ? 3.5.w : 2.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSuccess
                        ? AppColors.success.withValues(alpha: 0.5)
                        : AppColors.secondary.withValues(alpha: 0.25),
                    blurRadius: isSuccess ? 24.r : 16.r,
                    spreadRadius: isSuccess ? 4.r : 1.r,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.all(
                  Radius.elliptical(ovalWidth / 2, ovalHeight / 2),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Subtle background gradient representing live optical camera
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withValues(alpha: 0.3),
                              const Color(0xFF071F33).withValues(alpha: 0.4),
                              AppColors.primary.withValues(alpha: 0.6),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),

                    // Biometric Face Silhouette Landmark
                    Icon(
                      Icons.face_retouching_natural_rounded,
                      size: 110.sp,
                      color: isSuccess
                          ? AppColors.success.withValues(alpha: 0.7)
                          : AppColors.white.withValues(alpha: 0.25),
                    ),

                    // Biometric Crosshair Mesh Target Painter
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _BiometricMeshPainter(
                          color: isSuccess
                              ? AppColors.success
                              : AppColors.secondary,
                          progress: controller.matchProgress.value,
                        ),
                      ),
                    ),

                    // Success Celebration Overlay
                    if (isSuccess)
                      Positioned(
                        bottom: 30.h,
                        child: AnimatedScale(
                          scale: 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              borderRadius: BorderRadius.circular(20.r),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.success.withValues(alpha: 0.6),
                                  blurRadius: 12.r,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified_rounded,
                                  size: 14.sp,
                                  color: AppColors.white,
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  '99.4% MATCH',
                                  style: AppTextStyles.text10.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Custom painter for AI facial landmark scanning mesh
class _BiometricMeshPainter extends CustomPainter {
  final Color color;
  final double progress;

  const _BiometricMeshPainter({
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Crosshairs
    canvas.drawLine(Offset(cx - 20, cy), Offset(cx + 20, cy), paint);
    canvas.drawLine(Offset(cx, cy - 20), Offset(cx, cy + 20), paint);

    // Eye target boxes
    final eyePaint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // Left Eye Target Box
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx - 40, cy - 35), width: 28, height: 20),
      eyePaint,
    );

    // Right Eye Target Box
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx + 40, cy - 35), width: 28, height: 20),
      eyePaint,
    );

    // Mouth / Chin line
    canvas.drawLine(
      Offset(cx - 24, cy + 50),
      Offset(cx + 24, cy + 50),
      eyePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _BiometricMeshPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.progress != progress;
  }
}
