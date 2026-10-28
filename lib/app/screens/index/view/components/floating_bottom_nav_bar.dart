import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../controller/index_controller.dart';
import '../../model/nav_tab_model.dart';

/// Modern Animated Bottom Navigation Bar with a Sliding Top Surface Indicator Line
/// Replaces CustomPainter with a sleek, hardware-accelerated animated indicator line
/// that smoothly slides across the top surface of the active tab.
class FloatingBottomNavBar extends StatefulWidget {
  const FloatingBottomNavBar({super.key});

  @override
  State<FloatingBottomNavBar> createState() => _FloatingBottomNavBarState();
}

class _FloatingBottomNavBarState extends State<FloatingBottomNavBar>
    with SingleTickerProviderStateMixin {
  late final IndexController _controller;
  late final AnimationController _animController;
  late final Animation<double> _curveAnimation;
  Worker? _tabWorker;

  double _previousPosition = 0.0;
  double _targetPosition = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<IndexController>();

    final initial = _controller.currentIndex.value.toDouble();
    _previousPosition = initial;
    _targetPosition = initial;

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _curveAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );

    _animController.addListener(() {
      setState(() {});
    });

    // Reactive worker: smoothly animates top line whenever active tab changes
    _tabWorker = ever(_controller.currentIndex, (int newIndex) {
      if (!mounted) return;
      _previousPosition = _targetPosition;
      _targetPosition = newIndex.toDouble();
      _animController.forward(from: 0.0);
    });
  }

  @override
  void dispose() {
    _tabWorker?.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tabs = _controller.navTabs;
      final currentIdx = _controller.currentIndex.value;

      if (tabs.isEmpty) return const SizedBox.shrink();

      return Container(
        margin: EdgeInsets.only(left: 12.w, right: 12.w, bottom: 8.h, top: 5.h),
        height: 60.h,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.borderColor, width: 1.w),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 20.r,
              offset: Offset(0, 6.h),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth = constraints.maxWidth;
            final tabWidth = totalWidth / tabs.length;

            // Interpolated animated tab position (0.0 to tabs.length - 1)
            final currentProgress = _curveAnimation.value;
            final animatedPos = _previousPosition +
                (_targetPosition - _previousPosition) * currentProgress;

            // Standard line width with subtle liquid stretch during transit
            final stretch = math.sin(currentProgress * math.pi);
            final baseLineWidth = (tabWidth * 0.42).clamp(24.w, 42.w);
            final activeLineWidth = baseLineWidth + (stretch * 8.w);

            // Center X of the active tab
            final centerX = (animatedPos + 0.5) * tabWidth;
            final lineLeft = (centerX - (activeLineWidth / 2)).clamp(
              4.w,
              totalWidth - activeLineWidth - 4.w,
            );

            return Stack(
              children: [
                // Top Sliding Indicator Line
                Positioned(
                  top: 0,
                  left: lineLeft,
                  child: Container(
                    width: activeLineWidth,
                    height: 3.5.h,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(3.r),
                        bottomRight: Radius.circular(3.r),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withValues(alpha: 0.45),
                          blurRadius: 6.r,
                          offset: Offset(0, 1.5.h),
                        ),
                      ],
                    ),
                  ),
                ),

                // Equal Tab Items Row
                Row(
                  children: List.generate(tabs.length, (index) {
                    final tab = tabs[index];
                    final isSelected = currentIdx == index;
                    final hasBadge = tab.hasBadge?.call() ?? false;
                    final badgeCount = tab.badgeCount?.call() ?? 0;

                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (currentIdx != index) {
                            HapticFeedback.selectionClick();
                            _controller.changeTab(index);
                          }
                        },
                        child: Center(
                          child: _buildTabItem(
                            tab: tab,
                            isSelected: isSelected,
                            hasBadge: hasBadge,
                            badgeCount: badgeCount,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            );
          },
        ),
      );
    });
  }

  /// Builds individual navigation item with animated icon & label
  Widget _buildTabItem({
    required DynamicNavTab tab,
    required bool isSelected,
    required bool hasBadge,
    required int badgeCount,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedScale(
          scale: isSelected ? 1.12 : 1.0,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                transform: Matrix4.translationValues(
                  0,
                  isSelected ? -1.h : 0,
                  0,
                ),
                child: Icon(
                  tab.icon,
                  size: 21.sp,
                  color: isSelected
                      ? AppColors.secondary
                      : AppColors.subTextColor,
                ),
              ),

              // Notification Badge
              if (hasBadge)
                Positioned(
                  top: -2.r,
                  right: -4.r,
                  child: Container(
                    padding: badgeCount > 0
                        ? EdgeInsets.symmetric(
                            horizontal: 3.5.w,
                            vertical: 1.h,
                          )
                        : null,
                    width: badgeCount > 0 ? null : 6.5.r,
                    height: badgeCount > 0 ? null : 6.5.r,
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: badgeCount > 0
                          ? BorderRadius.circular(6.r)
                          : null,
                      shape: badgeCount > 0
                          ? BoxShape.rectangle
                          : BoxShape.circle,
                      border: Border.all(
                        color: AppColors.cardBackground,
                        width: 1.2.w,
                      ),
                    ),
                    child: badgeCount > 0
                        ? Text(
                            badgeCount > 99 ? '99+' : badgeCount.toString(),
                            style: AppTextStyles.text10.copyWith(
                              color: AppColors.white,
                              fontSize: 8.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                ),
            ],
          ),
        ),

        SizedBox(height: 3.h),

        // Animated Label
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: AppTextStyles.text10.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? AppColors.secondary
                : AppColors.subTextColor,
            letterSpacing: 0.2,
          ),
          child: Text(
            tab.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
