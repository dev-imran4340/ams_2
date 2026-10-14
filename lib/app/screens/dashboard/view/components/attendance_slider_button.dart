import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../controller/dashboard_controller.dart';

class AttendanceSliderButton extends StatefulWidget {
  const AttendanceSliderButton({super.key});

  @override
  State<AttendanceSliderButton> createState() => _AttendanceSliderButtonState();
}

class _AttendanceSliderButtonState extends State<AttendanceSliderButton>
    with SingleTickerProviderStateMixin {
  final DashboardController controller = Get.find<DashboardController>();

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
    _resetAnimation = Tween<double>(begin: _dragPosition, end: 0.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    )..addListener(() {
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
          final isCheckedIn = controller.dashboardData.value
                  ?.todayAttendance.isCheckedIn ??
              false;
          final isPunching = controller.isPunching.value;

          final Color activeColor =
              isCheckedIn ? AppColors.absentColor : AppColors.secondary;
          final Color trackColor = isCheckedIn
              ? AppColors.absentColor.withValues(alpha: 0.08)
              : AppColors.liteSecondary.withValues(alpha: 0.3);
          final String labelText =
              isCheckedIn ? 'Swipe to Check Out' : 'Swipe to Check In';
          final IconData thumbIcon = isCheckedIn
              ? Icons.logout_rounded
              : Icons.login_rounded;

          return Container(
            width: trackWidth,
            height: buttonHeight,
            decoration: BoxDecoration(
              color: trackColor,
              borderRadius: BorderRadius.circular(26.r),
              border: Border.all(
                color: activeColor.withValues(alpha: 0.3),
                width: 1.2.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: activeColor.withValues(alpha: 0.06),
                  blurRadius: 12.r,
                  offset: Offset(0, 3.h),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Centered Hint Text with Directional Chevrons
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        labelText,
                        style: AppTextStyles.text14.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isCheckedIn
                              ? AppColors.absentColor
                              : AppColors.textColor,
                          letterSpacing: 0.4,
                        ),
                      ),
                      AppSpaces.hSpace8,
                      Icon(
                        Icons.keyboard_double_arrow_right_rounded,
                        size: 18.sp,
                        color: activeColor.withValues(alpha: 0.7),
                      ),
                    ],
                  ),
                ),

                // Drag Thumb Pill
                Positioned(
                  left: 4.w + _dragPosition,
                  child: GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      if (isPunching || controller.isLoading.value) return;
                      setState(() {
                        _dragPosition = (_dragPosition + details.delta.dx)
                            .clamp(0.0, maxDrag);
                      });
                    },
                    onHorizontalDragEnd: (details) async {
                      if (isPunching || controller.isLoading.value) return;
                      if (_dragPosition >= maxDrag * 0.75) {
                        setState(() {
                          _dragPosition = maxDrag;
                        });
                        await controller.handlePunchAction();
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
                              ? [
                                  AppColors.absentColor,
                                  AppColors.error,
                                ]
                              : [
                                  AppColors.secondary,
                                  AppColors.primary,
                                ],
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
                        child: isPunching
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
          );
        });
      },
    );
  }
}

