import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int? maxLines;
  final int? maxLength;
  final bool readOnly;
  final bool enabled;
  final VoidCallback? onTap;
  final Color? fillColor;
  final Color? borderColor;
  final double? borderRadius;
  final String? labelText;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final void Function(String)? onFieldSubmitted;
  final TextInputAction? textInputAction;
  final AutovalidateMode? autovalidateMode;
  final EdgeInsetsGeometry? contentPadding;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.maxLength,
    this.readOnly = false,
    this.enabled = true,
    this.onTap,
    this.fillColor,
    this.borderColor,
    this.borderRadius,
    this.labelText,
    this.inputFormatters,
    this.focusNode,
    this.onFieldSubmitted,
    this.textInputAction,
    this.autovalidateMode,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = BorderRadius.circular(borderRadius ?? 12.r);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null && labelText!.isNotEmpty) ...[
          Text(
            labelText!,
            style: AppTextStyles.text14.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textColor,
            ),
          ),
          SizedBox(height: 8.h),
        ],
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          onChanged: onChanged,
          maxLines: maxLines,
          maxLength: maxLength,
          readOnly: readOnly,
          enabled: enabled,
          onTap: onTap,
          inputFormatters: inputFormatters,
          focusNode: focusNode,
          onFieldSubmitted: onFieldSubmitted,
          textInputAction: textInputAction,
          autovalidateMode: autovalidateMode,
          style: AppTextStyles.text14.copyWith(
            color: AppColors.textColor,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTextStyles.text14.copyWith(
              color: AppColors.hintColor,
              fontWeight: FontWeight.w400,
            ),
            errorStyle: AppTextStyles.text12.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: fillColor ?? AppColors.inputFill,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            counterText: '',
            contentPadding: contentPadding ??
                EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 16.h,
                ),
            border: OutlineInputBorder(
              borderRadius: effectiveRadius,
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: effectiveRadius,
              borderSide: BorderSide(
                color: borderColor ?? AppColors.transparent,
                width: 1.w,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: effectiveRadius,
              borderSide: BorderSide(
                color: AppColors.primary,
                width: 1.5.w,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: effectiveRadius,
              borderSide: BorderSide(
                color: AppColors.error,
                width: 1.w,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: effectiveRadius,
              borderSide: BorderSide(
                color: AppColors.error,
                width: 1.5.w,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
