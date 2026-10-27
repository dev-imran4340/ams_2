import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../controller/dashboard_controller.dart';
import 'attendance_slider_button.dart';

class LiveShiftClockCard extends GetView<DashboardController> {
  const LiveShiftClockCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final today = controller.dashboardData.value?.todayAttendance;
      final shift = today?.shift;
      final shiftName = shift?.name ?? today?.shiftName ?? 'Day Shift';
      final shiftCode = shift?.code ?? 'DAY';
      final isCheckedIn = today?.isCheckedIn ?? false;
      final isOnBreak = today?.isOnBreak ?? false;
      final isCheckedOut =
          (today?.checkOutTime != null && today?.checkOutTime != '--:--');

      // Tone-driven status color mapping strictly adhering to corporate rules
      Color statusColor;
      if (isOnBreak) {
        statusColor = AppColors.warning;
      } else {
        switch (today?.statusTone) {
          case 'emerald':
            statusColor = AppColors.onTimeColor;
            break;
          case 'amber':
            statusColor = AppColors.warning;
            break;
          case 'rose':
            statusColor = AppColors.absentColor;
            break;
          case 'slate':
          default:
            statusColor = isCheckedIn
                ? AppColors.onTimeColor
                : AppColors.subTextColor;
        }
      }

      final statusLabel = isOnBreak
          ? 'On Break'
          : (today?.status ?? 'Not in yet');

      return CustomCard(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        child: Column(
          children: [
            // 1. Top Shift Title & Tone-Driven Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Shift Badge
                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.liteSecondary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: AppColors.secondary.withValues(alpha: 0.25),
                        width: 1.w,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 13.sp,
                          color: AppColors.secondary,
                        ),
                        AppSpaces.hSpace6,
                        Flexible(
                          child: Text(
                            '$shiftName ($shiftCode)',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.text10.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                AppSpaces.hSpace8,

                // Status Badge from server tone
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.3),
                      width: 1.w,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6.r,
                        height: 6.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: statusColor,
                        ),
                      ),
                      AppSpaces.hSpace6,
                      Text(
                        statusLabel,
                        style: AppTextStyles.text10.copyWith(
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            AppSpaces.vSpace8,

            // 2. Hardware / Policy Requirements Strip (requires: position, photo, face)
            _buildRequirementsStrip(today),

            AppSpaces.vSpace8,

            // 3. Compact Shift Timer with Dim Background Seconds & Right-Side Break Action
            _buildCombinedTimerAndBreakCard(
              today: today,
              isCheckedIn: isCheckedIn,
              isOnBreak: isOnBreak,
              isCheckedOut: isCheckedOut,
              statusColor: statusColor,
            ),

            AppSpaces.vSpace8,

            // 4. Shift Duration & Elapsed Counter Telemetry Bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.inputFill.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: AppColors.borderColor.withValues(alpha: 0.7),
                  width: 1.w,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left: Shift Timing & Planned hours
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Shift Timing',
                        style: AppTextStyles.text10.copyWith(
                          color: AppColors.subTextColor,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      AppSpaces.vSpace2,
                      Text(
                        '${today?.shiftTiming ?? "09:00 - 17:00"} (${today?.plannedHoursFormatted ?? "7h 00m"})',
                        style: AppTextStyles.text12.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                    ],
                  ),

                  // Right: Break Minutes Taken
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Break Status',
                        style: AppTextStyles.text10.copyWith(
                          color: AppColors.subTextColor,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      AppSpaces.vSpace2,
                      Text(
                        today != null && today.breakMinutes > 0
                            ? '${today.breakMinutes}m Logged'
                            : (today?.usesBreaks == true
                                  ? 'Allowed'
                                  : 'Disabled'),
                        style: AppTextStyles.text12.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isOnBreak
                              ? AppColors.warning
                              : AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            AppSpaces.vSpace10,

            // 5. Interactive Slide-to-Confirm Punch Button (Check-In / Check-Out)
            const AttendanceSliderButton(),
          ],
        ),
      );
    });
  }

  /// Verification Requirements Strip showing server-driven policy requirements
  Widget _buildRequirementsStrip(dynamic today) {
    final requires = today?.requires;
    final bool positionReq = requires?.position == true;
    final bool photoReq = requires?.photo == true;
    final String faceReq = requires?.face ?? 'off';

    return Row(
      children: [
        Expanded(
          child: _buildRequirementCapsule(
            icon: Icons.location_on_rounded,
            label: positionReq ? 'GPS Required' : 'GPS: Off',
            isActive: positionReq,
          ),
        ),
        AppSpaces.hSpace6,
        Expanded(
          child: _buildRequirementCapsule(
            icon: Icons.camera_alt_rounded,
            label: photoReq ? 'Selfie Req' : 'Photo: Off',
            isActive: photoReq,
          ),
        ),
        AppSpaces.hSpace6,
        Expanded(
          child: _buildRequirementCapsule(
            icon: Icons.face_rounded,
            label: faceReq != 'off' ? 'Face: $faceReq' : 'Face: Off',
            isActive: faceReq != 'off',
          ),
        ),
      ],
    );
  }

  Widget _buildRequirementCapsule({
    required IconData icon,
    required String label,
    required bool isActive,
  }) {
    final Color color = isActive ? AppColors.secondary : AppColors.subTextColor;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isActive ? 0.1 : 0.05),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(
          color: color.withValues(alpha: isActive ? 0.3 : 0.15),
          width: 0.8.w,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 11.sp, color: color),
          AppSpaces.hSpace4,
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.text10.copyWith(
                color: color,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                fontSize: 9.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Combined Timer and Break Action card
  /// In the background: Running seconds match container height in light dim watermark style
  /// Foreground Left: Hours & Minutes timer with micro live-clock & status
  /// Foreground Right: Sleek start/end break button
  Widget _buildCombinedTimerAndBreakCard({
    required dynamic today,
    required bool isCheckedIn,
    required bool isOnBreak,
    required bool isCheckedOut,
    required Color statusColor,
  }) {
    Color activeTimerColor;
    String statusSubtitle;

    if (isOnBreak) {
      activeTimerColor = AppColors.warning;
      statusSubtitle = 'On Break • Shift Paused';
    } else if (isCheckedIn) {
      activeTimerColor = AppColors.onTimeColor;
      statusSubtitle = 'Started at ${today?.checkInTime}';
    } else if (isCheckedOut) {
      activeTimerColor = AppColors.secondary;
      statusSubtitle = 'Ended at ${today?.checkOutTime}';
    } else {
      activeTimerColor = AppColors.subTextColor;
      statusSubtitle = 'Target: ${today?.plannedHoursFormatted ?? "7h 00m"}';
    }

    return Container(
      width: double.infinity,

      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isOnBreak
            ? AppColors.warning.withValues(alpha: 0.08)
            : AppColors.inputFill.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isOnBreak
              ? AppColors.warning.withValues(alpha: 0.35)
              : AppColors.borderColor.withValues(alpha: 0.8),
          width: 1.w,
        ),
      ),
      child: Stack(
        children: [
          // Background: Centered Large Running Seconds Watermark (as shown in reference image)
          Obx(() {
            final sec = controller.elapsedSeconds.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSpaces.vSpace8,
                Align(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 10.sp,
                        color: AppColors.secondary,
                      ),
                      AppSpaces.hSpace4,
                      Text(
                        controller.liveClock.value.isEmpty
                            ? '--:--'
                            : controller.liveClock.value,
                        style: AppTextStyles.text10.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.subTextColor,
                        ),
                      ),
                      AppSpaces.hSpace6,
                      Text(
                        '•',
                        style: TextStyle(
                          color: AppColors.borderColor,
                          fontSize: 9.sp,
                        ),
                      ),
                      AppSpaces.hSpace6,
                      Flexible(
                        child: Text(
                          controller.liveDate.value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.text10.copyWith(
                            color: AppColors.subTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpaces.vSpace8,
                Text(
                  sec,

                  style: AppTextStyles.text12.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 170.sp,
                    height: 0.8,
                    // letterSpacing: -2,
                    color: (isOnBreak ? AppColors.warning : activeTimerColor)
                        .withValues(alpha: 0.12),
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                AppSpaces.vSpace8,
              ],
            );
          }),

          // Foreground: Perfectly Centered Timer Display (Hours : Minutes)
          Positioned(
            top: 95.h,
            left: 35.w,

            child: Center(
              child: Column(
                children: [
                  // Micro Live Real-Time Wall Clock & Date header

                  // Prominent Centered Hours & Minutes Timer Display
                  Text(
                    controller.elapsedHoursMinutes.value,

                    style: AppTextStyles.text28.copyWith(
                      fontSize: 60.sp,
                      fontWeight: FontWeight.w800,
                      height: 0.8,
                      color: isCheckedIn || isOnBreak
                          ? (isOnBreak
                                ? AppColors.warning
                                : AppColors.secondary)
                          : AppColors.secondary,
                      letterSpacing: 1.5,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),

                  // Shift Status Subtitle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5.r,
                        height: 5.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: activeTimerColor,
                        ),
                      ),
                      AppSpaces.hSpace6,
                      Flexible(
                        child: Text(
                          statusSubtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.text10.copyWith(
                            color: activeTimerColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Right: Modern Circular Sci-Fi Radar Break Action Button (Matching Reference Screenshot)
          if (today != null && today.usesBreaks)
            Positioned(
              right: 14.w,
              top: 0,
              bottom: 0,
              child: Center(
                child: _buildInlineBreakButton(
                  today: today,
                  isCheckedIn: isCheckedIn,
                  isOnBreak: isOnBreak,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Modern Circular Break Action Disc (Built to match user reference screenshot)
  Widget _buildInlineBreakButton({
    required dynamic today,
    required bool isCheckedIn,
    required bool isOnBreak,
  }) {
    final bool canInteract = isCheckedIn || isOnBreak;
    final Color ringColor =
        isOnBreak ? AppColors.warning : AppColors.secondary;
    final String label = isOnBreak ? 'STOP' : 'BREAK';
    final IconData icon = isOnBreak ? Icons.stop_rounded : Icons.coffee_rounded;

    return Obx(() {
      final isLoading = controller.isBreakLoading.value;

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            if (!canInteract) {
              CustomSnackbar.showInfo(
                message: 'Please check in first to take a break.',
              );
              return;
            }
            if (!isLoading) {
              controller.handleBreakAction();
            }
          },
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 78.r,
            height: 78.r,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 1. Cyber Radar Arc & Guide Orbit Ring (matching user screenshot)
                CustomPaint(
                  size: Size(78.r, 78.r),
                  painter: _CyberRadarArcPainter(
                    color: ringColor,
                    isActive: canInteract,
                  ),
                ),

                // 2. Intermediate Translucent Disc
                Container(
                  width: 62.r,
                  height: 62.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: !canInteract
                        ? AppColors.cardBackground.withValues(alpha: 0.3)
                        : ringColor.withValues(alpha: 0.10),
                    border: Border.all(
                      color: !canInteract
                          ? AppColors.borderColor.withValues(alpha: 0.25)
                          : ringColor.withValues(alpha: 0.25),
                      width: 1.w,
                    ),
                  ),
                ),

                // 3. Inner Solid Core Action Disc (with high-tech gradient & depth)
                Container(
                  width: 50.r,
                  height: 50.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: canInteract
                        ? (isOnBreak
                            ? const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFFFF9100),
                                  Color(0xFFE65100),
                                ],
                              )
                            : LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.secondary,
                                  AppColors.accentNavy,
                                ],
                              ))
                        : null,
                    color: !canInteract
                        ? AppColors.subTextColor.withValues(alpha: 0.15)
                        : null,
                    boxShadow: canInteract
                        ? [
                            BoxShadow(
                              color: ringColor.withValues(
                                  alpha: isOnBreak ? 0.4 : 0.25),
                              blurRadius: 10.r,
                              spreadRadius: 1.r,
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 6.r,
                              offset: Offset(0, 2.h),
                            ),
                          ]
                        : null,
                  ),
                  child: isLoading
                      ? Center(
                          child: SizedBox(
                            width: 16.r,
                            height: 16.r,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2.w,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              icon,
                              size: 15.sp,
                              color: canInteract
                                  ? Colors.white
                                  : AppColors.subTextColor
                                      .withValues(alpha: 0.45),
                            ),
                            AppSpaces.vSpace2,
                            Text(
                              label,
                              style: TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                                fontSize: 8.5.sp,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.1,
                                color: canInteract
                                    ? Colors.white
                                    : AppColors.subTextColor
                                        .withValues(alpha: 0.45),
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

/// Custom Painter that accurately renders the futuristic Cyber Radar Arc
/// from the reference screenshot: outer circular orbit track, micro cardinal ticks,
/// and a luminous neon curved arc segment with glowing rounded caps and tip dot.
class _CyberRadarArcPainter extends CustomPainter {
  final Color color;
  final bool isActive;

  const _CyberRadarArcPainter({
    required this.color,
    required this.isActive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 3.w;

    // 1. Faint Outer Orbit Track (circular guide line)
    final trackPaint = Paint()
      ..color = isActive
          ? color.withValues(alpha: 0.22)
          : AppColors.borderColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2.w;

    canvas.drawCircle(center, radius, trackPaint);

    // 2. Micro Ticks at Cardinal Points (Futuristic HUD feel)
    final tickPaint = Paint()
      ..color = isActive
          ? color.withValues(alpha: 0.35)
          : AppColors.borderColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.w;

    const tickLen = 3.0;
    canvas.drawLine(
      Offset(center.dx, center.dy - radius - tickLen),
      Offset(center.dx, center.dy - radius + tickLen),
      tickPaint,
    );
    canvas.drawLine(
      Offset(center.dx + radius - tickLen, center.dy),
      Offset(center.dx + radius + tickLen, center.dy),
      tickPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy + radius - tickLen),
      Offset(center.dx, center.dy + radius + tickLen),
      tickPaint,
    );

    if (!isActive) return;

    // 3. Glowing Cyber Neon Arc (matching bright cyan curved arc in screenshot)
    // Curves along the left / bottom-left sector:
    const double startAngle = 2.1;
    const double sweepAngle = 2.2;

    // Outer Soft Neon Glow
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.6.w
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3.r);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      glowPaint,
    );

    // Sharp Core Neon Arc
    final coreArcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.4.w;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      coreArcPaint,
    );

    // 4. Glowing Pulse Tip Dot at the head of the arc
    final headAngle = startAngle + sweepAngle;
    final tipCenter = Offset(
      center.dx + radius * math.cos(headAngle),
      center.dy + radius * math.sin(headAngle),
    );

    final tipGlow = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2.r);
    canvas.drawCircle(tipCenter, 3.r, tipGlow);

    final tipDot = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(tipCenter, 1.8.r, tipDot);
  }

  @override
  bool shouldRepaint(covariant _CyberRadarArcPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isActive != isActive;
  }
}
