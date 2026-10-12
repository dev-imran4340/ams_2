import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';

class LoginBottomBar extends StatelessWidget {
  const LoginBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      child: Center(
        child: GestureDetector(
          onTap: () {
            // Sign up / Contact registration
          },
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: "Don't Have An Account? ",
              style: AppTextStyles.text12.copyWith(
                color: AppColors.subTextColor,
                fontWeight: FontWeight.w400,
              ),
              children: [
                TextSpan(
                  text: 'Sign Up',
                  style: TextStyle(
                    color: AppColors.textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                    fontFamily: AppTextStyles.fontFamily,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
