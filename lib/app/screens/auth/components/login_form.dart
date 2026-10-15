import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_spaces.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../controller/auth_controller.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email Address Field
          CustomTextField(
            labelText: 'Email Address',
            hintText: 'Enter Email Address',
            controller: controller.emailController,

            keyboardType: TextInputType.emailAddress,

            textInputAction: TextInputAction.next,

            prefixIcon: Icon(
              Icons.mail_outline_rounded,
              color: AppColors.hintColor,
              size: 20.sp,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email address';
              }
              return null;
            },
          ),
          AppSpaces.vSpace12,

          // Password Field
          Obx(
            () => CustomTextField(
              labelText: 'Password',
              hintText: 'Enter Your Password',
              controller: controller.passwordController,
              keyboardType: TextInputType.visiblePassword,

              obscureText: !controller.isPasswordVisible.value,

              onFieldSubmitted: (_) {
                // if (_formKey.currentState?.validate() ?? false) {
                controller.login();
                // }
              },

              prefixIcon: Icon(
                Icons.lock_outline_rounded,
                color: AppColors.hintColor,
                size: 20.sp,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  controller.isPasswordVisible.value
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.hintColor,
                  size: 20.sp,
                ),
                onPressed: controller.togglePasswordVisibility,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (value.length < 6) {
                  return 'Password must contain at least 6 characters';
                }
                return null;
              },
            ),
          ),
          AppSpaces.vSpace12,

          // Remember Me & Forgot Password Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(
                () => InkWell(
                  onTap: () =>
                      controller.toggleRememberMe(!controller.rememberMe.value),
                  borderRadius: BorderRadius.circular(6.r),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: Checkbox(
                          value: controller.rememberMe.value,
                          activeColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          side: BorderSide(
                            color: AppColors.borderColor,
                            width: 1.5.w,
                          ),
                          onChanged: controller.toggleRememberMe,
                        ),
                      ),
                      AppSpaces.hSpace8,
                      Text(
                        'Remember Me',
                        style: AppTextStyles.text12.copyWith(
                          color: AppColors.textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Password recovery action
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  child: Text(
                    'Forgot Password ?',
                    style: AppTextStyles.text12.copyWith(
                      color: AppColors.textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          AppSpaces.vSpace24,

          // Pill-shaped Corporate "Sign In" Button
          Obx(
            () => CustomButton(
              isGradient: true,
              text: 'Sign In',
              isLoading: controller.isLoading.value,
              onPressed: () {
                // if (_formKey.currentState?.validate() ?? false) {
                controller.login();
                // }
              },
            ),
          ),
        ],
      ),
    );
  }
}
