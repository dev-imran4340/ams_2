import 'package:flutter/material.dart';
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
      finalGradient = gradient ??
          const LinearGradient(
            colors: [Color(0xFF012B43), Color(0xFF023E61)],
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

    return Opacity(
      opacity: isDisabled ? 0.6 : 1.0,
      child: Container(
        width: width ?? double.infinity,
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
      ),
    );
  }

  Widget _buildChild(Color color) {
    if (isLoading) {
      return Center(
        child: SizedBox(
          width: 24.w,
          height: 24.w,
          child: CircularProgressIndicator(
            color: color,
            strokeWidth: 2.5,
          ),
        ),
      );
    }

    final effectiveStyle = textStyle ??
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
          if (icon != null) ...[
            icon!,
            SizedBox(width: 8.w),
          ],
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
