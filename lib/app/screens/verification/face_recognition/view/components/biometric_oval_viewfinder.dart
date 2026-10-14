import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../controller/face_recognition_controller.dart';

class BiometricOvalViewfinder extends GetView<FaceRecognitionController> {
  const BiometricOvalViewfinder({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenW = constraints.maxWidth;
        final screenH = constraints.maxHeight;

        final ovalWidth = 240.w;
        final ovalHeight = 310.h;

        // Centered in visible window below header
        final centerX = screenW / 2;
        final centerY = screenH * 0.43;

        final ovalRect = Rect.fromCenter(
          center: Offset(centerX, centerY),
          width: ovalWidth,
          height: ovalHeight,
        );

        return Stack(
          children: [
            // 1. Dark Surround Mask with Oval Cutout
            Positioned.fill(
              child: CustomPaint(
                painter: _OvalCutoutOverlayPainter(
                  ovalRect: ovalRect,
                  overlayColor: AppColors.primary.withValues(alpha: 0.65),
                ),
              ),
            ),

            // 2. Concentric Animated Pulsing Radar Rings
            Obx(() {
              if (controller.isMatchSuccess.value) {
                return const SizedBox.shrink();
              }

              return AnimatedBuilder(
                animation: controller.pulseAnimation,
                builder: (context, child) {
                  final scale = controller.pulseAnimation.value;
                  final ringWidth = ovalWidth * scale + 24.w;
                  final ringHeight = ovalHeight * scale + 24.h;

                  return Positioned(
                    left: centerX - (ringWidth / 2),
                    top: centerY - (ringHeight / 2),
                    width: ringWidth,
                    height: ringHeight,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.elliptical(ringWidth / 2, ringHeight / 2),
                        ),
                        border: Border.all(
                          color: AppColors.secondary.withValues(
                            alpha: (0.35 * (1.15 - scale)).clamp(0.06, 0.4),
                          ),
                          width: 1.5.w,
                        ),
                      ),
                    ),
                  );
                },
              );
            }),

            // 3. Main Oval Viewfinder Interior & Live Camera Feed
            Positioned.fromRect(
              rect: ovalRect,
              child: Obx(() {
                final isSuccess = controller.isMatchSuccess.value;
                final borderColor =
                    isSuccess ? AppColors.success : AppColors.secondary;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.elliptical(ovalWidth / 2, ovalHeight / 2),
                    ),
                    border: Border.all(
                      color: borderColor,
                      width: isSuccess ? 3.5.w : 2.5.w,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSuccess
                            ? AppColors.success.withValues(alpha: 0.5)
                            : AppColors.secondary.withValues(alpha: 0.3),
                        blurRadius: isSuccess ? 24.r : 16.r,
                        spreadRadius: isSuccess ? 3.r : 1.r,
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
                        // Live Camera Feed if Hardware Initialized, else ambient fallback
                        Positioned.fill(
                          child: controller.isCameraInitialized.value &&
                                  controller.cameraController != null
                              ? FittedBox(
                                  fit: BoxFit.cover,
                                  child: SizedBox(
                                    width: controller.cameraController!.value
                                        .previewSize?.height ??
                                        ovalWidth,
                                    height: controller.cameraController!.value
                                        .previewSize?.width ??
                                        ovalHeight,
                                    child: CameraPreview(
                                      controller.cameraController!,
                                    ),
                                  ),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    gradient: RadialGradient(
                                      colors: [
                                        AppColors.accentNavy,
                                        AppColors.primary,
                                      ],
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.face_retouching_natural_rounded,
                                      size: 72.sp,
                                      color: AppColors.liteSecondary
                                          .withValues(alpha: 0.35),
                                    ),
                                  ),
                                ),
                        ),

                        // Subtle Face Geometry Mesh Grid Overlay
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _FaceMeshGridPainter(
                              color: AppColors.white.withValues(alpha: 0.08),
                            ),
                          ),
                        ),

                        // Animated Center Verified Checkmark on Biometric Match
                        if (isSuccess)
                          Center(
                            child: AnimatedScale(
                              scale: isSuccess ? 1.0 : 0.4,
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeOutBack,
                              child: Container(
                                padding: EdgeInsets.all(18.r),
                                decoration: BoxDecoration(
                                  color: AppColors.success
                                      .withValues(alpha: 0.25),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.success,
                                    width: 3.w,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.success
                                          .withValues(alpha: 0.5),
                                      blurRadius: 24.r,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.check_rounded,
                                  size: 42.sp,
                                  color: AppColors.success,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }
}

/// Paints the dark surround mask with transparent elliptical cutout
class _OvalCutoutOverlayPainter extends CustomPainter {
  final Rect ovalRect;
  final Color overlayColor;

  _OvalCutoutOverlayPainter({
    required this.ovalRect,
    required this.overlayColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final holePath = Path()..addOval(ovalRect);

    final combinedPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      holePath,
    );

    final paint = Paint()..color = overlayColor;
    canvas.drawPath(combinedPath, paint);
  }

  @override
  bool shouldRepaint(covariant _OvalCutoutOverlayPainter oldDelegate) {
    return oldDelegate.ovalRect != ovalRect ||
        oldDelegate.overlayColor != overlayColor;
  }
}

/// Subtle concentric elliptical mesh grid simulating biometric depth mapping
class _FaceMeshGridPainter extends CustomPainter {
  final Color color;

  const _FaceMeshGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);

    // Draw inner concentric face target ovals
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: size.width * 0.75,
        height: size.height * 0.75,
      ),
      paint,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: size.width * 0.5,
        height: size.height * 0.5,
      ),
      paint,
    );

    // Crosshairs
    canvas.drawLine(
      Offset(center.dx - 18, center.dy),
      Offset(center.dx + 18, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - 18),
      Offset(center.dx, center.dy + 18),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _FaceMeshGridPainter oldDelegate) => false;
}
