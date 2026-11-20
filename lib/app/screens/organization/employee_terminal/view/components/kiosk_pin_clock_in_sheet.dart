import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_spaces.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../controller/employee_terminal_controller.dart';

class KioskPinClockInSheet extends StatefulWidget {
  final EmployeeTerminalController controller;

  const KioskPinClockInSheet({super.key, required this.controller});

  static Future<void> show(
    BuildContext context, {
    required EmployeeTerminalController controller,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => KioskPinClockInSheet(controller: controller),
    );
  }

  @override
  State<KioskPinClockInSheet> createState() => _KioskPinClockInSheetState();
}

class _KioskPinClockInSheetState extends State<KioskPinClockInSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _empNumberController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  final FocusNode _empNumberFocusNode = FocusNode();
  final FocusNode _pinFocusNode = FocusNode();

  final GlobalKey _empNumberKey = GlobalKey();
  final GlobalKey _pinKey = GlobalKey();

  bool _isLoading = false;
  bool _isPinObscured = true;

  @override
  void dispose() {
    _empNumberController.dispose();
    _pinController.dispose();
    _empNumberFocusNode.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleClockIn() async {
    HapticFeedback.lightImpact();

    if (!_formKey.currentState!.validate()) {
      if (_empNumberController.text.trim().isEmpty) {
        Scrollable.ensureVisible(_empNumberKey.currentContext ?? context);
        _empNumberFocusNode.requestFocus();
        return;
      }
      if (_pinController.text.trim().isEmpty) {
        Scrollable.ensureVisible(_pinKey.currentContext ?? context);
        _pinFocusNode.requestFocus();
        return;
      }
      return;
    }

    try {
      setState(() => _isLoading = true);

      final success = await widget.controller.clockInWithPin(
        employeeNumber: _empNumberController.text.trim(),
        pin: _pinController.text.trim(),
      );

      if (success) {
        Get.back();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return PopScope(
      canPop: !_isLoading,
      child: Container(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
            border: Border(
              bottom: BorderSide(
                color: AppColors.secondary,
                width: 3.w,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.15),
                blurRadius: 24.r,
                offset: Offset(0, -6.h),
              ),
            ],
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: AppColors.borderColor,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),

                  AppSpaces.vSpace16,

                  // Header
                  Row(
                    children: [
                      Container(
                        width: 42.r,
                        height: 42.r,
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.secondary.withValues(alpha: 0.3),
                            width: 1.w,
                          ),
                        ),
                        child: Icon(
                          Icons.pin_outlined,
                          color: AppColors.secondary,
                          size: 22.sp,
                        ),
                      ),
                      AppSpaces.hSpace12,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PIN Clock-In Fallback',
                              style: AppTextStyles.text16.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                            ),
                            AppSpaces.vSpace2,
                            Text(
                              'Enter Employee ID and 4-6 digit backup PIN',
                              style: AppTextStyles.text12.copyWith(
                                color: AppColors.subTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  AppSpaces.vSpace18,

                  // Employee Number
                  Container(
                    key: _empNumberKey,
                    child: CustomTextField(
                      controller: _empNumberController,
                      focusNode: _empNumberFocusNode,
                      labelText: 'Employee ID',
                      hintText: 'e.g. EMP-0001',
                      prefixIcon: Icon(
                        Icons.badge_outlined,
                        size: 18.sp,
                        color: AppColors.subTextColor,
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter your Employee ID';
                        }
                        return null;
                      },
                    ),
                  ),

                  AppSpaces.vSpace12,

                  // PIN Input
                  Container(
                    key: _pinKey,
                    child: CustomTextField(
                      controller: _pinController,
                      focusNode: _pinFocusNode,
                      labelText: 'Kiosk Backup PIN',
                      hintText: 'Enter 4-6 digits',
                      obscureText: _isPinObscured,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icon(
                        Icons.lock_outline_rounded,
                        size: 18.sp,
                        color: AppColors.subTextColor,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPinObscured ? Icons.visibility_off : Icons.visibility,
                          size: 18.sp,
                          color: AppColors.subTextColor,
                        ),
                        onPressed: () => setState(() => _isPinObscured = !_isPinObscured),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter your kiosk PIN';
                        }
                        if (val.trim().length < 4 || val.trim().length > 6) {
                          return 'PIN must be 4 to 6 numbers';
                        }
                        return null;
                      },
                    ),
                  ),

                  AppSpaces.vSpace20,

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Cancel',
                          isOutlined: true,
                          borderColor: AppColors.borderColor,
                          textColor: AppColors.textColor,
                          backgroundColor: Colors.transparent,
                          onPressed: _isLoading ? null : () => Get.back(),
                        ),
                      ),
                      AppSpaces.hSpace12,
                      Expanded(
                        child: CustomButton(
                          text: 'Clock In',
                          isGradient: true,
                          isLoading: _isLoading,
                          onPressed: _isLoading ? null : _handleClockIn,
                        ),
                      ),
                    ],
                  ),

                  AppSpaces.vSpace10,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
