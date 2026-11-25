import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:ams_2/app/core/utils/app_colors.dart';
import 'package:ams_2/app/core/utils/app_spaces.dart';
import 'package:ams_2/app/core/utils/app_text_styles.dart';
import 'package:ams_2/app/core/widgets/custom_button.dart';
import 'package:ams_2/app/core/widgets/custom_text_field.dart';
import '../../controller/kiosk_controller.dart';

class KioskPinCard extends StatelessWidget {
  final KioskController controller;

  const KioskPinCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(15.r),
        border: Border(
          bottom: BorderSide(color: AppColors.secondary, width: 3.w),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Icon & Status Pill
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.password_rounded,
                  color: AppColors.secondary,
                  size: 22.sp,
                ),
              ),
              AppSpaces.hSpace10,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Self-Service Kiosk PIN',
                      style: AppTextStyles.text14.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                    Text(
                      'Fallback for office tablet terminal clock-in',
                      style: AppTextStyles.text12.copyWith(
                        color: AppColors.subTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Obx(() {
                final configured = controller.isPinConfigured.value;
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: configured
                        ? AppColors.success.withValues(alpha: 0.12)
                        : AppColors.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        configured ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                        color: configured ? AppColors.success : AppColors.amberDark,
                        size: 14.sp,
                      ),
                      AppSpaces.hSpace4,
                      Text(
                        configured ? 'Configured' : 'Not Set',
                        style: AppTextStyles.text12.copyWith(
                          fontWeight: FontWeight.bold,
                          color: configured ? AppColors.success : AppColors.amberDark,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),

          AppSpaces.vSpace12,

          Text(
            'Configure your 4 to 6 digit backup PIN to quickly clock in or out at office reception tablets when you do not have your physical RFID card.',
            style: AppTextStyles.text12.copyWith(
              color: AppColors.subTextColor,
              height: 1.35,
            ),
          ),

          AppSpaces.vSpace12,

          // PIN Policy Badges (Phase 10 Invariant)
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PIN Security Requirements:',
                  style: AppTextStyles.text12.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                AppSpaces.vSpace8,
                _buildRuleItem('4 to 6 numeric digits only'),
                AppSpaces.vSpace4,
                _buildRuleItem('Cannot be identical digits (e.g. 1111, 2222)'),
                AppSpaces.vSpace4,
                _buildRuleItem('Cannot be sequential runs (e.g. 1234, 4321)'),
              ],
            ),
          ),

          AppSpaces.vSpace16,

          // Form Fields
          Form(
            key: controller.pinFormKey,
            child: Column(
              children: [
                Obx(() => CustomTextField(
                      controller: controller.pinController,
                      focusNode: controller.pinFocusNode,
                      labelText: 'New 4-6 Digit PIN',
                      hintText: 'Enter numeric PIN (e.g. 5829)',
                      keyboardType: TextInputType.number,
                      obscureText: controller.isPinObscured.value,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.isPinObscured.value
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20.sp,
                        ),
                        onPressed: () {
                          controller.isPinObscured.toggle();
                        },
                      ),
                      validator: controller.validatePin,
                    )),

                AppSpaces.vSpace12,

                Obx(() => CustomTextField(
                      controller: controller.confirmPinController,
                      focusNode: controller.confirmPinFocusNode,
                      labelText: 'Confirm PIN',
                      hintText: 'Re-enter same numeric PIN',
                      keyboardType: TextInputType.number,
                      obscureText: controller.isConfirmPinObscured.value,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      prefixIcon: const Icon(Icons.lock_reset_rounded),
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.isConfirmPinObscured.value
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20.sp,
                        ),
                        onPressed: () {
                          controller.isConfirmPinObscured.toggle();
                        },
                      ),
                      validator: controller.validateConfirmPin,
                    )),
              ],
            ),
          ),

          AppSpaces.vSpace16,

          // Submission Action
          Obx(() => CustomButton(
                text: controller.isPinConfigured.value ? 'Update Kiosk PIN' : 'Save Kiosk PIN',
                isGradient: true,
                isLoading: controller.isSubmitting.value,
                onPressed: controller.isSubmitting.value ? null : controller.submitKioskPin,
              )),
        ],
      ),
    );
  }

  Widget _buildRuleItem(String text) {
    return Row(
      children: [
        Icon(
          Icons.check_circle_outline_rounded,
          size: 14.sp,
          color: AppColors.secondary,
        ),
        AppSpaces.hSpace8,
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.text10.copyWith(
              color: AppColors.subTextColor,
            ),
          ),
        ),
      ],
    );
  }
}
