import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final double? borderRadius;
  final Widget? icon;
  final bool isOutlined;
  final Color? borderColor;
  final bool isGradient;
  final Gradient? gradient;
  final TextStyle? textStyle;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.borderRadius,
    this.icon,
    this.isOutlined = false,
    this.borderColor,
    this.isGradient = false,
    this.gradient,
    this.textStyle,
    this.fontSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    // Built-in duplicate tap lock when loading or disabled
    final bool isDisabled = onPressed == null || isLoading;

    // Background color
    Color? finalBackgroundColor;
    if (isOutlined) {
      finalBackgroundColor = backgroundColor ?? Colors.transparent;
    } else {
      finalBackgroundColor = backgroundColor ?? AppColors.primary;
    }

    // Corporate Navy gradient fallback
    Gradient? finalGradient;
    if (!isOutlined && isGradient) {
      finalGradient =
          gradient ??
          const LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          );
    }

    // Text & Icon color
    Color finalTextColor =
        textColor ?? (isOutlined ? AppColors.primary : AppColors.white);

    // Border
    Border? finalBorder;
    if (isOutlined) {
      finalBorder = Border.all(
        color: borderColor ?? AppColors.primary,
        width: 1.5.w,
      );
    }

    final buttonContent = Container(
      width: width,
      height: height ?? 52.h,
      decoration: BoxDecoration(
        color: finalGradient == null ? finalBackgroundColor : null,
        gradient: finalGradient,
        borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
        border: finalBorder,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
          child: _buildChild(finalTextColor),
        ),
      ),
    );

    final Widget buttonWidget = width != null
        ? buttonContent
        : _AdaptiveWidthBox(child: buttonContent);

    return Opacity(
      opacity: isDisabled ? 0.6 : 1.0,
      child: buttonWidget,
    );
  }

  Widget _buildChild(Color color) {
    if (isLoading) {
      return Center(
        child: SizedBox(
          width: 24.w,
          height: 24.w,
          child: CircularProgressIndicator(color: color, strokeWidth: 2.5),
        ),
      );
    }

    final effectiveStyle =
        textStyle ??
        AppTextStyles.text16.copyWith(
          fontWeight: FontWeight.w600,
          color: color,
          fontSize: fontSize,
        );

    return Padding(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 8.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[icon!, SizedBox(width: 8.w)],
          Flexible(
            child: Text(
              text,
              style: effectiveStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// Adaptive width wrapper that expands to fill bounded width (e.g. in Columns)
/// or hugs content width when unbounded (e.g. in Rows), while supporting
/// intrinsic dimension calculations without throwing LayoutBuilder exceptions.
class _AdaptiveWidthBox extends SingleChildRenderObjectWidget {
  const _AdaptiveWidthBox({super.child});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderAdaptiveWidthBox();
}

class _RenderAdaptiveWidthBox extends RenderProxyBox {
  _RenderAdaptiveWidthBox();

  @override
  void performLayout() {
    if (child == null) {
      size = constraints.smallest;
      return;
    }
    final targetWidth =
        constraints.hasBoundedWidth ? constraints.maxWidth : null;
    final childConstraints = constraints.copyWith(
      minWidth: targetWidth ?? 0.0,
      maxWidth: targetWidth ?? constraints.maxWidth,
    );
    child!.layout(childConstraints, parentUsesSize: true);
    size = child!.size;
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return child?.getMinIntrinsicWidth(height) ?? 0.0;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return child?.getMaxIntrinsicWidth(height) ?? 0.0;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return child?.getMinIntrinsicHeight(width) ?? 0.0;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return child?.getMaxIntrinsicHeight(width) ?? 0.0;
  }
}
