import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/app_colors.dart';

/// Corporate floating card container adhering to AMS 2.0 design blueprint.
/// Features signature 3.w Teal bottom accent border, 15.r border radius,
/// and prevents non-uniform border assertion errors.
class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? accentColor;
  final double? accentWidth;
  final bool showBottomAccent;
  final Color? borderColor;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.accentColor,
    this.accentWidth,
    this.showBottomAccent = true,
    this.borderColor,
    this.boxShadow,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? 15.r;
    final effectiveAccentWidth = showBottomAccent ? (accentWidth ?? 3.w) : 0.0;
    final effectiveAccentColor = accentColor ?? AppColors.secondary;
    final effectiveBgColor = backgroundColor ?? AppColors.cardBackground;
    final effectiveBorderColor = borderColor ?? AppColors.borderColor;

    Widget cardBody = Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: effectiveAccentWidth > 0 ? effectiveAccentColor : effectiveBgColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: effectiveBorderColor,
          width: 1.w,
        ),
        boxShadow: boxShadow ??
            [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 24.r,
                offset: Offset(0, 10.h),
              ),
            ],
      ),
      padding: EdgeInsets.only(bottom: effectiveAccentWidth),
      child: Container(
        padding: padding ??
            EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 14.h,
            ),
        decoration: BoxDecoration(
          color: effectiveBgColor,
          borderRadius: effectiveAccentWidth > 0
              ? BorderRadius.only(
                  topLeft: Radius.circular((radius - 1.r).clamp(0, 50)),
                  topRight: Radius.circular((radius - 1.r).clamp(0, 50)),
                  bottomLeft: Radius.circular((radius - 3.r).clamp(0, 50)),
                  bottomRight: Radius.circular((radius - 3.r).clamp(0, 50)),
                )
              : BorderRadius.circular(radius),
        ),
        child: child,
      ),
    );

    Widget result = cardBody;

    if (onTap != null) {
      result = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: result,
        ),
      );
    }

    if (margin != null) {
      result = Padding(padding: margin!, child: result);
    }

    return result;
  }
}
