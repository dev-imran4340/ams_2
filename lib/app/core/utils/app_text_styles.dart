import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const String fontFamily = 'Inter';

  static TextStyle get _base => TextStyle(
        fontFamily: fontFamily,
        color: AppColors.textColor,
      );

  // Size Getters
  static TextStyle get text4 => _base.copyWith(fontSize: 4.sp);
  static TextStyle get text6 => _base.copyWith(fontSize: 6.sp);
  static TextStyle get text8 => _base.copyWith(fontSize: 8.sp);
  static TextStyle get text10 => _base.copyWith(fontSize: 10.sp);
  static TextStyle get text12 => _base.copyWith(fontSize: 12.sp);
  static TextStyle get text14 => _base.copyWith(fontSize: 14.sp);
  static TextStyle get text16 => _base.copyWith(fontSize: 16.sp);
  static TextStyle get text18 => _base.copyWith(fontSize: 18.sp);
  static TextStyle get text20 => _base.copyWith(fontSize: 20.sp);
  static TextStyle get text22 => _base.copyWith(fontSize: 22.sp);
  static TextStyle get text24 => _base.copyWith(fontSize: 24.sp);
  static TextStyle get text26 => _base.copyWith(fontSize: 26.sp);
  static TextStyle get text28 => _base.copyWith(fontSize: 28.sp);
  static TextStyle get text30 => _base.copyWith(fontSize: 30.sp);
  static TextStyle get text32 => _base.copyWith(fontSize: 32.sp);
  static TextStyle get text34 => _base.copyWith(fontSize: 34.sp);

  // Convenience weights
  static TextStyle get regular => _base.copyWith(fontWeight: FontWeight.w400);
  static TextStyle get medium => _base.copyWith(fontWeight: FontWeight.w500);
  static TextStyle get semiBold => _base.copyWith(fontWeight: FontWeight.w600);
  static TextStyle get bold => _base.copyWith(fontWeight: FontWeight.w700);
}
