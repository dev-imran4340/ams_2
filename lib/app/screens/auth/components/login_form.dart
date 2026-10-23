import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_spaces.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../routes/app_routes.dart';
import '../controller/auth_controller.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 0. Saved Account Quick-Fill Card
      

        // Dual-Mode Selector: Email vs Employee Number
        Obx(
          () => Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: AppColors.borderColor, width: 1.w),
            ),
            padding: EdgeInsets.all(4.r),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (controller.isEmployeeNumberMode.value) {
                        controller.toggleLoginMode();
                      }
                    },
                    borderRadius: BorderRadius.circular(8.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      decoration: BoxDecoration(
                        color: !controller.isEmployeeNumberMode.value
                            ? AppColors.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Email Address',
                        style: AppTextStyles.text12.copyWith(
                          color: !controller.isEmployeeNumberMode.value
                              ? Colors.white
                              : AppColors.textColor,
                          fontWeight: !controller.isEmployeeNumberMode.value
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
                AppSpaces.hSpace4,
                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (!controller.isEmployeeNumberMode.value) {
                        controller.toggleLoginMode();
                      }
                    },
                    borderRadius: BorderRadius.circular(8.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      decoration: BoxDecoration(
                        color: controller.isEmployeeNumberMode.value
                            ? AppColors.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Employee ID',
                        style: AppTextStyles.text12.copyWith(
                          color: controller.isEmployeeNumberMode.value
                              ? Colors.white
                              : AppColors.textColor,
                          fontWeight: controller.isEmployeeNumberMode.value
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        AppSpaces.vSpace14,

        // Mode B: Company Code (Only when logging in with Employee ID)
        Obx(
          () => controller.isEmployeeNumberMode.value
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      labelText: 'Company Code',
                      hintText: 'e.g. K7MP2Q (6 characters)',
                      controller: controller.companyCodeController,
                      focusNode: controller.companyCodeFocusNode,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z0-9]'),
                        ),
                        LengthLimitingTextInputFormatter(6),
                      ],
                      prefixIcon: Icon(
                        Icons.business_rounded,
                        color: AppColors.hintColor,
                        size: 20.sp,
                      ),
                    ),
                    if (controller.companyCodeError.value != null) ...[
                      AppSpaces.vSpace4,
                      Text(
                        controller.companyCodeError.value!,
                        style: AppTextStyles.text10.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    AppSpaces.vSpace12,
                  ],
                )
              : const SizedBox.shrink(),
        ),

        // Login Identifier Field (Email Address OR Employee ID)
        Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                labelText: controller.isEmployeeNumberMode.value
                    ? 'Employee ID'
                    : 'Email Address',
                hintText: controller.isEmployeeNumberMode.value
                    ? 'e.g. EMP-0001'
                    : 'e.g. ayesha@acme.pk',
                controller: controller.emailController,
                focusNode: controller.emailFocusNode,
                keyboardType: controller.isEmployeeNumberMode.value
                    ? TextInputType.text
                    : TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                prefixIcon: Icon(
                  controller.isEmployeeNumberMode.value
                      ? Icons.badge_outlined
                      : Icons.mail_outline_rounded,
                  color: AppColors.hintColor,
                  size: 20.sp,
                ),
              ),
              if (controller.loginError.value != null) ...[
                AppSpaces.vSpace4,
                Text(
                  controller.loginError.value!,
                  style: AppTextStyles.text10.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
        AppSpaces.vSpace12,

        // Password Field
        Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                labelText: 'Password',
                hintText: 'Enter Your Password',
                controller: controller.passwordController,
                focusNode: controller.passwordFocusNode,
                keyboardType: TextInputType.visiblePassword,
                obscureText: !controller.isPasswordVisible.value,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => controller.login(),
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
              ),
              if (controller.passwordError.value != null) ...[
                AppSpaces.vSpace4,
                Text(
                  controller.passwordError.value!,
                  style: AppTextStyles.text10.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
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
                Get.toNamed(Routes.FORGOT_PASSWORD);
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

        // Rate Limit Active Notice
        Obx(
          () => controller.retryAfterSeconds.value > 0
              ? Padding(
                  padding: EdgeInsets.only(top: 12.h),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          color: AppColors.error,
                          size: 16.sp,
                        ),
                        AppSpaces.hSpace8,
                        Expanded(
                          child: Text(
                            'Too many attempts. Please wait ${controller.retryAfterSeconds.value}s',
                            style: AppTextStyles.text12.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),

        AppSpaces.vSpace20,

        // Pill-shaped Corporate "Sign In" Button
        Obx(
          () => CustomButton(
            isGradient: true,
            text: controller.retryAfterSeconds.value > 0
                ? 'Retry in ${controller.retryAfterSeconds.value}s'
                : 'Sign In',
            isLoading: controller.isLoading.value,
            onPressed: controller.retryAfterSeconds.value > 0
                ? null
                : () => controller.login(),
          ),
        ),
      ],
    );
  }
}

