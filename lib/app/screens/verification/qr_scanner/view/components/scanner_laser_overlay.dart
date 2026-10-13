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
    final boxSize = 260.w;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Viewfinder Frame Container
          GestureDetector(
            onTap: () {
              // Allows convenient tap-to-verify for instant testing
              controller.simulateSampleScan();
            },
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Viewfinder Box
                Container(
                  width: boxSize,
                  height: boxSize,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.2),
                      width: 1.w,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.r),
                    child: Stack(
                      children: [
                        // Subtle grid background effect
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _ScannerGridPainter(
                              gridColor:
                                  AppColors.white.withValues(alpha: 0.04),
                            ),
                          ),
                        ),

                        // Moving Laser Sweep Line
                        Obx(() {
                          if (controller.scanSuccess.value) {
                            return const SizedBox.shrink();
                          }

                          return AnimatedBuilder(
                            animation: controller.laserAnimation,
                            builder: (context, child) {
                              return Positioned(
                                top: boxSize * controller.laserAnimation.value,
                                left: 12.w,
                                right: 12.w,
                                child: Container(
                                  height: 3.h,
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary,
                                    borderRadius: BorderRadius.circular(2.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.secondary.withValues(
                                          alpha: 0.8,
                                        ),
                                        blurRadius: 12.r,
                                        spreadRadius: 2.r,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }),

                        // Center Verified Badge on Scan Success
                        Obx(() {
                          if (!controller.scanSuccess.value) {
                            return const SizedBox.shrink();
                          }

                          return Center(
                            child: AnimatedScale(
                              scale: controller.scanSuccess.value ? 1.0 : 0.5,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutBack,
                              child: Container(
                                padding: EdgeInsets.all(16.r),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withValues(
                                    alpha: 0.2,
                                  ),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.success,
                                    width: 2.w,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.success.withValues(
                                        alpha: 0.4,
                                      ),
                                      blurRadius: 20.r,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.check_rounded,
                                  size: 40.sp,
                                  color: AppColors.success,
                                ),
                              ),
                            ),
                          );
                        }),

                        // Loading Spinner overlay while verifying
                        Obx(() {
                          if (controller.isVerifying.value) {
                            return Container(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.secondary,
                                  strokeWidth: 2.5.w,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        }),
                      ],
                    ),
                  ),
                ),

                // 4 Modern Corner Reticles (Top-Left, Top-Right, Bottom-Left, Bottom-Right)
                Obx(() {
                  final reticleColor = controller.scanSuccess.value
                      ? AppColors.success
                      : AppColors.secondary;

                  return SizedBox(
                    width: boxSize + 12.w,
                    height: boxSize + 12.w,
                    child: CustomPaint(
                      painter: _CornerReticlesPainter(
                        color: reticleColor,
                        cornerLength: 28.w,
                        strokeWidth: 3.5.w,
                        borderRadius: 20.r,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          AppSpaces.vSpace20,

          // Instruction Pill
          Obx(
            () => Container(
              margin: EdgeInsets.symmetric(horizontal: 24.w),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.12),
                  width: 1.w,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    controller.scanSuccess.value
                        ? Icons.check_circle_rounded
                        : Icons.qr_code_scanner_rounded,
                    size: 15.sp,
                    color: controller.scanSuccess.value
                        ? AppColors.success
                        : AppColors.secondary,
                  ),
                  AppSpaces.hSpace8,
                  Flexible(
                    child: Text(
                      controller.statusMessage.value,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.text12.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for the 4 corner viewfinder reticles
class _CornerReticlesPainter extends CustomPainter {
  final Color color;
  final double cornerLength;
  final double strokeWidth;
  final double borderRadius;

  const _CornerReticlesPainter({
    required this.color,
    required this.cornerLength,
    required this.strokeWidth,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    // Top-Left Corner
    final tlPath = Path()
      ..moveTo(0, cornerLength)
      ..lineTo(0, borderRadius)
      ..arcToPoint(Offset(borderRadius, 0), radius: Radius.circular(borderRadius))
      ..lineTo(cornerLength, 0);
    canvas.drawPath(tlPath, paint);

    // Top-Right Corner
    final trPath = Path()
      ..moveTo(w - cornerLength, 0)
      ..lineTo(w - borderRadius, 0)
      ..arcToPoint(Offset(w, borderRadius), radius: Radius.circular(borderRadius))
      ..lineTo(w, cornerLength);
    canvas.drawPath(trPath, paint);

    // Bottom-Left Corner
    final blPath = Path()
      ..moveTo(0, h - cornerLength)
      ..lineTo(0, h - borderRadius)
      ..arcToPoint(Offset(borderRadius, h), radius: Radius.circular(borderRadius))
      ..lineTo(cornerLength, h);
    canvas.drawPath(blPath, paint);

    // Bottom-Right Corner
    final brPath = Path()
      ..moveTo(w - cornerLength, h)
      ..lineTo(w - borderRadius, h)
      ..arcToPoint(Offset(w, h - borderRadius), radius: Radius.circular(borderRadius))
      ..lineTo(w, h - cornerLength);
    canvas.drawPath(brPath, paint);
  }

  @override
  bool shouldRepaint(covariant _CornerReticlesPainter oldDelegate) {
    return oldDelegate.color != color;
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
