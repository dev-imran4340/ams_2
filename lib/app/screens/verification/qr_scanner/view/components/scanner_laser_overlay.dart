import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_spaces.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../controller/qr_scan_controller.dart';

class ScannerLaserOverlay extends GetView<QRScanController> {
  const ScannerLaserOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenW = constraints.maxWidth;
        final screenH = constraints.maxHeight;

        // Viewfinder Dimensions (Responsive)
        final boxSize = 250.w;
        final borderRadius = 24.r;

        // Perfectly centered in the visible viewport between header and bottom controls
        final centerX = screenW / 2;
        final centerY = screenH * 0.44;

        final boxRect = Rect.fromCenter(
          center: Offset(centerX, centerY),
          width: boxSize,
          height: boxSize,
        );

        return Stack(
          children: [
            // 1. Unified Mathematical Painter:
            // Combines dark surround mask cutout, border frame, and 4 corner HUD brackets
            // using the EXACT same coordinates so they can NEVER be misaligned or off-level.
            Positioned.fill(
              child: Obx(() {
                final reticleColor = controller.scanSuccess.value
                    ? AppColors.success
                    : AppColors.secondary;

                return CustomPaint(
                  painter: _UnifiedScannerOverlayPainter(
                    boxRect: boxRect,
                    borderRadius: borderRadius,
                    overlayColor: AppColors.primary.withValues(alpha: 0.65),
                    reticleColor: reticleColor,
                    cornerLength: 30.w,
                    strokeWidth: 3.5.w,
                  ),
                );
              }),
            ),

            // 2. Viewfinder Interior: Laser line, subtle grid, and status indicators
            Positioned.fromRect(
              rect: boxRect,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(borderRadius),
                child: Stack(
                  children: [
                    // Subtle Tech Grid
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _ScannerGridPainter(
                          gridColor: AppColors.white.withValues(alpha: 0.05),
                        ),
                      ),
                    ),

                    // Animated Gliding Laser Line with Glow
                    Obx(() {
                      if (controller.scanSuccess.value) {
                        return const SizedBox.shrink();
                      }

                      return AnimatedBuilder(
                        animation: controller.laserAnimation,
                        builder: (context, child) {
                          final double topPosition =
                              boxSize * controller.laserAnimation.value;
                          return Positioned(
                            top: topPosition,
                            left: 8.w,
                            right: 8.w,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Glowing Laser Trail Gradient
                                Container(
                                  height: 14.h,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        AppColors.secondary.withValues(
                                          alpha: 0.0,
                                        ),
                                        AppColors.secondary.withValues(
                                          alpha: 0.25,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Glowing Solid Core Beam
                                Container(
                                  height: 3.h,
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary,
                                    borderRadius: BorderRadius.circular(2.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.secondary
                                            .withValues(alpha: 0.9),
                                        blurRadius: 14.r,
                                        spreadRadius: 2.r,
                                      ),
                                      BoxShadow(
                                        color: AppColors.liteSecondary
                                            .withValues(alpha: 0.8),
                                        blurRadius: 6.r,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }),

                    // Processing State Loader Overlay
                    Obx(() {
                      if (!controller.isProcessing.value) {
                        return const SizedBox.shrink();
                      }
                      return Container(
                        color: AppColors.primary.withValues(alpha: 0.5),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 38.r,
                                height: 38.r,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3.w,
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    AppColors.secondary,
                                  ),
                                ),
                              ),
                              AppSpaces.vSpace10,
                              Text(
                                'Verifying...',
                                style: AppTextStyles.text12.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    // Success Checkmark Badge
                    Obx(() {
                      if (!controller.scanSuccess.value) {
                        return const SizedBox.shrink();
                      }
                      return Center(
                        child: AnimatedScale(
                          scale: controller.scanSuccess.value ? 1.0 : 0.4,
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutBack,
                          child: Container(
                            padding: EdgeInsets.all(18.r),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(
                                alpha: 0.25,
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.success,
                                width: 2.5.w,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.success.withValues(
                                    alpha: 0.45,
                                  ),
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
                      );
                    }),
                  ],
                ),
              ),
            ),

            // 3. Status Feedback Capsule (Positioned cleanly right below the viewfinder box)
            Positioned(
              top: boxRect.bottom + 18.h,
              left: 20.w,
              right: 20.w,
              child: Center(
                child: Obx(() {
                  final isSuccess = controller.scanSuccess.value;
                  final isProcessing = controller.isProcessing.value;

                  Color iconColor = AppColors.secondary;
                  IconData iconData = Icons.qr_code_scanner_rounded;

                  if (isSuccess) {
                    iconColor = AppColors.success;
                    iconData = Icons.check_circle_rounded;
                  } else if (isProcessing) {
                    iconColor = AppColors.liteSecondary;
                    iconData = Icons.sync_rounded;
                  }

                  return Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: AppColors.white.withValues(alpha: 0.15),
                        width: 1.w,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 12.r,
                          offset: Offset(0, 4.h),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          iconData,
                          size: 16.sp,
                          color: iconColor,
                        ),
                        AppSpaces.hSpace8,
                        Flexible(
                          child: Text(
                            controller.scanFeedbackMessage.value,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.text12.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Unified painter ensuring 100% mathematical alignment between:
/// 1. The dark surround mask cutout
/// 2. The viewfinder border frame
/// 3. The 4 HUD corner brackets
class _UnifiedScannerOverlayPainter extends CustomPainter {
  final Rect boxRect;
  final double borderRadius;
  final Color overlayColor;
  final Color reticleColor;
  final double cornerLength;
  final double strokeWidth;

  const _UnifiedScannerOverlayPainter({
    required this.boxRect,
    required this.borderRadius,
    required this.overlayColor,
    required this.reticleColor,
    required this.cornerLength,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Full Screen Mask with Transparent Rounded Cutout
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final cutoutRRect = RRect.fromRectAndRadius(
      boxRect,
      Radius.circular(borderRadius),
    );

    final holePath = Path()..addRRect(cutoutRRect);

    final combinedPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      holePath,
    );

    final maskPaint = Paint()..color = overlayColor;
    canvas.drawPath(combinedPath, maskPaint);

    // 2. Viewfinder Outline Border (matching exact cutout boundary)
    final frameBorderPaint = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(cutoutRRect, frameBorderPaint);

    // 3. Four HUD Corner Reticles (exact alignment around boxRect corners)
    final reticlePaint = Paint()
      ..color = reticleColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final l = boxRect.left;
    final t = boxRect.top;
    final r = boxRect.right;
    final b = boxRect.bottom;
    final rad = borderRadius;
    final cl = cornerLength;

    // Top-Left Corner
    final tlPath = Path()
      ..moveTo(l, t + cl)
      ..lineTo(l, t + rad)
      ..arcToPoint(
        Offset(l + rad, t),
        radius: Radius.circular(rad),
      )
      ..lineTo(l + cl, t);
    canvas.drawPath(tlPath, reticlePaint);

    // Top-Right Corner
    final trPath = Path()
      ..moveTo(r - cl, t)
      ..lineTo(r - rad, t)
      ..arcToPoint(
        Offset(r, t + rad),
        radius: Radius.circular(rad),
      )
      ..lineTo(r, t + cl);
    canvas.drawPath(trPath, reticlePaint);

    // Bottom-Left Corner
    final blPath = Path()
      ..moveTo(l, b - cl)
      ..lineTo(l, b - rad)
      ..arcToPoint(
        Offset(l + rad, b),
        radius: Radius.circular(rad),
      )
      ..lineTo(l + cl, b);
    canvas.drawPath(blPath, reticlePaint);

    // Bottom-Right Corner
    final brPath = Path()
      ..moveTo(r - cl, b)
      ..lineTo(r - rad, b)
      ..arcToPoint(
        Offset(r, b - rad),
        radius: Radius.circular(rad),
      )
      ..lineTo(r, b - cl);
    canvas.drawPath(brPath, reticlePaint);
  }

  @override
  bool shouldRepaint(covariant _UnifiedScannerOverlayPainter oldDelegate) {
    return oldDelegate.boxRect != boxRect ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.reticleColor != reticleColor ||
        oldDelegate.overlayColor != overlayColor;
  }
}

/// Subtle grid lines inside scanner viewfinder
class _ScannerGridPainter extends CustomPainter {
  final Color gridColor;

  const _ScannerGridPainter({required this.gridColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0;

    const step = 26.0;
    for (double x = step; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = step; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ScannerGridPainter oldDelegate) => false;
}
