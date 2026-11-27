import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:ams_2/app/core/utils/app_colors.dart';
import 'package:ams_2/app/core/utils/app_spaces.dart';
import 'package:ams_2/app/core/utils/app_text_styles.dart';
import 'package:ams_2/app/core/widgets/custom_card.dart';
import 'package:ams_2/app/core/widgets/custom_snackbar.dart';
import '../../controller/kiosk_controller.dart';
import '../../model/kiosk_model.dart';

/// Employee Dashboard-style Live Punch & Swipe Card for Kiosk Mode.
/// Driven strictly by `POST /kiosk/identify` (`state` and `requires`).
class KioskLivePunchCard extends StatelessWidget {
  final KioskController controller;
  final KioskIdentifyResponseModel session;

  const KioskLivePunchCard({
    super.key,
    required this.controller,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final activeSession = controller.identifiedSession.value ?? session;
      final isOffline =
          !controller.isOnline.value || activeSession.isOfflineSession;
      final isCheckedIn = activeSession.checkedIn;
      final isOnBreak = activeSession.onBreak;
      final countdown = controller.ticketCountdown.value;

      final Color statusColor = isOnBreak
          ? AppColors.warning
          : (isCheckedIn ? AppColors.onTimeColor : AppColors.subTextColor);
      final String statusLabel = isOnBreak
          ? 'On Break'
          : (isCheckedIn ? 'Checked In' : 'Not in yet');

      return CustomCard(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        borderRadius: 15.r,
        accentColor: AppColors.secondary,
        accentWidth: 3.w,
        child: Column(
          children: [
            // 1. Employee Identity + Status Badge + 120s Ticket Timer
            Row(
              children: [
                CircleAvatar(
                  radius: 22.r,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    session.person.name.isNotEmpty
                        ? session.person.name[0].toUpperCase()
                        : 'E',
                    style: AppTextStyles.text16.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                ),
                AppSpaces.hSpace10,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.person.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.text16.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                      AppSpaces.vSpace2,
                      Text(
                        session.person.employeeNumber,
                        style: AppTextStyles.text12.copyWith(
                          color: AppColors.subTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.35),
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
                AppSpaces.hSpace6,
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: (isOffline
                            ? AppColors.warning
                            : (countdown < 30
                                  ? AppColors.error
                                  : AppColors.secondary))
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: isOffline
                          ? AppColors.warning
                          : (countdown < 30
                                ? AppColors.error
                                : AppColors.secondary),
                    ),
                  ),
                  child: Text(
                    isOffline
                        ? 'OFFLINE • ${countdown}s'
                        : '${countdown}s',
                    style: AppTextStyles.text10.copyWith(
                      fontWeight: FontWeight.bold,
                      color: countdown < 30
                          ? AppColors.error
                          : (isOffline
                                ? AppColors.warning
                                : AppColors.secondary),
                    ),
                  ),
                ),
              ],
            ),

            AppSpaces.vSpace10,

            // 2. Requirements Strip matching LiveShiftClockCard
            Row(
              children: [
                Expanded(
                  child: _buildRequirementCapsule(
                    icon: Icons.tablet_mac_rounded,
                    label: 'Kiosk Mode',
                    isActive: true,
                  ),
                ),
                AppSpaces.hSpace6,
                Expanded(
                  child: _buildRequirementCapsule(
                    icon: Icons.camera_alt_rounded,
                    label: session.requiresPhoto ? 'Selfie Req' : 'Photo: Off',
                    isActive: session.requiresPhoto,
                  ),
                ),
                AppSpaces.hSpace6,
                Expanded(
                  child: _buildRequirementCapsule(
                    icon: Icons.face_rounded,
                    label: session.requiresFace != 'off'
                        ? 'Face: ${session.requiresFace}'
                        : 'Face: Off',
                    isActive: session.requiresFace != 'off',
                  ),
                ),
              ],
            ),

            AppSpaces.vSpace10,

            // 3. Combined Timer & Break Action Card (matching Employee Dashboard)
            _buildCombinedTimerAndBreakCard(
              isCheckedIn: isCheckedIn,
              isOnBreak: isOnBreak,
            ),

            AppSpaces.vSpace12,

            // 4. Interactive Swipe-to-Confirm Slider (matching AttendanceSliderButton)
            // Face verification / selfie capture runs automatically on punch tap/swipe (same as Employee flow).
            _KioskAttendanceSlider(
              controller: controller,
              session: session,
            ),

            AppSpaces.vSpace8,

            TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.subTextColor,
              ),
              icon: Icon(Icons.close_rounded, size: 16.sp),
              label: Text(
                'Cancel Identification',
                style: AppTextStyles.text12.copyWith(
                  color: AppColors.subTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () => controller.cancelSession(),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildRequirementCapsule({
    required IconData icon,
    required String label,
    required bool isActive,
  }) {
    final Color color = isActive ? AppColors.secondary : AppColors.subTextColor;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
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

  Widget _buildCombinedTimerAndBreakCard({
    required bool isCheckedIn,
    required bool isOnBreak,
  }) {
    final Color activeTimerColor = isOnBreak
        ? AppColors.warning
        : (isCheckedIn ? AppColors.onTimeColor : AppColors.subTextColor);

    final String statusSubtitle = isOnBreak
        ? 'On Break${session.since != null ? ' • In at ${session.since}' : ''}'
        : (isCheckedIn
              ? 'Active since ${session.since ?? '--:--'}'
              : 'Ready to Check In');

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
          // Background Watermark Seconds
          Obx(() {
            final sec = controller.elapsedSeconds.value;
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
              child: Text(
                sec,
                style: AppTextStyles.text12.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 130.sp,
                  height: 0.85,
                  color: activeTimerColor.withValues(alpha: 0.1),
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            );
          }),

          // Foreground Centered Elapsed Timer
          Positioned.fill(
            right: session.usesBreaks ? 94.w : 12.w,
            left: 12.w,
            child: Center(
              child: Obx(() {
                final displayHm = isOnBreak
                    ? controller.elapsedBreakHoursMinutes.value
                    : controller.elapsedHoursMinutes.value;
                final dynamicSubtitle = isOnBreak
                    ? 'Break Timer • Work paused at ${controller.pausedWorkHoursMinutes.value}'
                    : statusSubtitle;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayHm,
                      style: AppTextStyles.text28.copyWith(
                        fontSize: 44.sp,
                        fontWeight: FontWeight.w800,
                        height: 0.95,
                        color: isCheckedIn || isOnBreak
                            ? (isOnBreak
                                  ? AppColors.warning
                                  : AppColors.secondary)
                            : AppColors.subTextColor,
                        letterSpacing: 1.2,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    AppSpaces.vSpace6,
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
                            dynamicSubtitle,
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
                );
              }),
            ),
          ),

          // Right Circular Break Action Button (matches LiveShiftClockCard)
          if (session.usesBreaks)
            Positioned(
              right: 12.w,
              top: 0,
              bottom: 0,
              child: Center(
                child: _buildInlineBreakButton(
                  isCheckedIn: isCheckedIn,
                  isOnBreak: isOnBreak,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInlineBreakButton({
    required bool isCheckedIn,
    required bool isOnBreak,
  }) {
    final bool isPermittedByServer = isOnBreak
        ? session.canEndBreak
        : session.canStartBreak;
    final bool canInteract = (isCheckedIn || isOnBreak) && isPermittedByServer;

    final Color ringColor = isOnBreak
        ? (canInteract
              ? AppColors.warning
              : AppColors.warning.withValues(alpha: 0.4))
        : (canInteract
              ? AppColors.secondary
              : AppColors.subTextColor.withValues(alpha: 0.4));
    final String label = isOnBreak ? 'STOP' : 'BREAK';
    final IconData icon = isOnBreak ? Icons.stop_rounded : Icons.coffee_rounded;

    final String breakKind = isOnBreak ? 'break_end' : 'break_start';

    return Obx(() {
      final isSubmitting = controller.isSubmitting.value;
      final isBreakLoading =
          isSubmitting && controller.activePunchKind.value == breakKind;
      return Material(
        color: AppColors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: isSubmitting
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  if (!canInteract) {
                    final kind = isOnBreak ? 'break_end' : 'break_start';
                    final msg = session.refusalMessageFor(kind) ??
                        'Break action is not available right now.';
                    CustomSnackbar.showWarning(
                      title: 'Break Unavailable',
                      message: msg,
                    );
                    return;
                  }
                  controller.handleBreakPunch();
                },
          child: Container(
            width: 72.r,
            height: 72.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ringColor.withValues(alpha: canInteract ? 0.14 : 0.06),
              border: Border.all(
                color: ringColor,
                width: 2.w,
              ),
            ),
            child: isBreakLoading
                ? Center(
                    child: SizedBox(
                      width: 20.r,
                      height: 20.r,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2.w,
                        color: ringColor,
                      ),
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: ringColor, size: 22.sp),
                      AppSpaces.vSpace2,
                      Text(
                        label,
                        style: AppTextStyles.text10.copyWith(
                          color: ringColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 9.sp,
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

class _KioskAttendanceSlider extends StatefulWidget {
  final KioskController controller;
  final KioskIdentifyResponseModel session;

  const _KioskAttendanceSlider({
    required this.controller,
    required this.session,
  });

  @override
  State<_KioskAttendanceSlider> createState() => _KioskAttendanceSliderState();
}

class _KioskAttendanceSliderState extends State<_KioskAttendanceSlider>
    with SingleTickerProviderStateMixin {
  double _dragPosition = 0.0;
  late AnimationController _animController;
  late Animation<double> _resetAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _resetSlider() {
    if (!mounted) return;
    _resetAnimation = Tween<double>(begin: _dragPosition, end: 0.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    )..addListener(() {
        if (!mounted) return;
        setState(() {
          _dragPosition = _resetAnimation.value;
        });
      });
    _animController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double trackWidth = constraints.maxWidth;
        final double buttonHeight = 52.h;
        final double thumbSize = buttonHeight - 8.h;
        final double maxDrag = trackWidth - thumbSize - 8.w;

        return Obx(() {
          final isCheckedIn = widget.session.checkedIn;
          final swipeKind = isCheckedIn ? 'out' : 'in';
          final isAnySubmitting = widget.controller.isSubmitting.value;
          final isSwipeLoading =
              isAnySubmitting &&
              widget.controller.activePunchKind.value == swipeKind;
          final bool canPunch = isCheckedIn
              ? widget.session.canCheckOut
              : widget.session.canCheckIn;

          final Color activeColor = !canPunch
              ? AppColors.subTextColor
              : (isCheckedIn ? AppColors.absentColor : AppColors.secondary);
          final Color trackColor = !canPunch
              ? AppColors.subTextColor.withValues(alpha: 0.08)
              : (isCheckedIn
                    ? AppColors.absentColor.withValues(alpha: 0.08)
                    : AppColors.liteSecondary.withValues(alpha: 0.3));
          final String labelText = !canPunch
              ? (isCheckedIn ? 'Check Out Disabled' : 'Check In Disabled')
              : (isCheckedIn ? 'Swipe to Check Out' : 'Swipe to Check In');
          final IconData thumbIcon = !canPunch
              ? Icons.lock_outline_rounded
              : (isCheckedIn ? Icons.logout_rounded : Icons.login_rounded);

          return Opacity(
            opacity: canPunch ? 1.0 : 0.5,
            child: Container(
              width: trackWidth,
              height: buttonHeight,
              decoration: BoxDecoration(
                color: trackColor,
                borderRadius: BorderRadius.circular(26.r),
                border: Border.all(
                  color: activeColor.withValues(alpha: canPunch ? 0.3 : 0.15),
                  width: 1.2.w,
                ),
              ),
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          labelText,
                          style: AppTextStyles.text14.copyWith(
                            fontWeight: FontWeight.bold,
                            color: !canPunch
                                ? AppColors.subTextColor
                                : (isCheckedIn
                                      ? AppColors.absentColor
                                      : AppColors.textColor),
                            letterSpacing: 0.4,
                          ),
                        ),
                        if (canPunch) ...[
                          AppSpaces.hSpace8,
                          Icon(
                            Icons.keyboard_double_arrow_right_rounded,
                            size: 18.sp,
                            color: activeColor.withValues(alpha: 0.7),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Positioned(
                    left: 4.w + _dragPosition,
                    child: GestureDetector(
                      onTap: () {
                        if (!canPunch) {
                          HapticFeedback.lightImpact();
                          final kind = isCheckedIn ? 'out' : 'in';
                          final refusal =
                              widget.session.refusalMessageFor(kind) ??
                              'Action is not allowed right now.';
                          CustomSnackbar.showWarning(
                            title: 'Action Disabled',
                            message: refusal,
                          );
                        }
                      },
                      onHorizontalDragUpdate: (details) {
                        if (!canPunch || isAnySubmitting) return;
                        setState(() {
                          _dragPosition = (_dragPosition + details.delta.dx)
                              .clamp(0.0, maxDrag);
                        });
                      },
                      onHorizontalDragEnd: (details) async {
                        if (!canPunch || isAnySubmitting) return;
                        if (_dragPosition >= maxDrag * 0.75) {
                          setState(() {
                            _dragPosition = maxDrag;
                          });
                          await widget.controller.handleSwipePunch();
                          _resetSlider();
                        } else {
                          _resetSlider();
                        }
                      },
                      child: Container(
                        width: thumbSize,
                        height: thumbSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: isCheckedIn
                                ? [AppColors.absentColor, AppColors.error]
                                : [AppColors.secondary, AppColors.primary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: activeColor.withValues(alpha: 0.35),
                              blurRadius: 10.r,
                              offset: Offset(0, 3.h),
                            ),
                          ],
                        ),
                        child: Center(
                          child: isSwipeLoading
                              ? SizedBox(
                                  width: 18.r,
                                  height: 18.r,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2.w,
                                    color: AppColors.white,
                                  ),
                                )
                              : Icon(
                                  thumbIcon,
                                  color: AppColors.white,
                                  size: 20.sp,
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}
