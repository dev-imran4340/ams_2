import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../repo/profile_repo.dart';

class KioskPinBottomSheet extends StatefulWidget {
  final ProfileRepo repo;

  const KioskPinBottomSheet({super.key, required this.repo});

  static Future<bool?> show(BuildContext context, {required ProfileRepo repo}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => KioskPinBottomSheet(repo: repo),
    );
  }

  @override
  State<KioskPinBottomSheet> createState() => _KioskPinBottomSheetState();
}

class _KioskPinBottomSheetState extends State<KioskPinBottomSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();

  final FocusNode _pinFocusNode = FocusNode();
  final FocusNode _confirmPinFocusNode = FocusNode();

  final GlobalKey _pinFieldKey = GlobalKey();
  final GlobalKey _confirmPinFieldKey = GlobalKey();

  bool _isLoading = false;
  bool _isPinObscured = true;
  bool _isConfirmPinObscured = true;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    _pinFocusNode.dispose();
    _confirmPinFocusNode.dispose();
    super.dispose();
  }

  String? _validatePin(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter 4-6 digit numeric PIN';
    }
    final clean = value.trim();
    if (clean.length < 4 || clean.length > 6) {
      return 'PIN must be between 4 and 6 digits';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(clean)) {
      return 'PIN must contain only numbers';
    }
    // Prohibit all identical digits (e.g. 1111, 2222)
    if (RegExp(r'^(\d)\1+$').hasMatch(clean)) {
      return 'PIN cannot be all identical digits';
    }
    // Prohibit sequential runs (e.g. 1234, 4321)
    const sequentialAsc = '0123456789';
    const sequentialDesc = '9876543210';
    if (sequentialAsc.contains(clean) || sequentialDesc.contains(clean)) {
      return 'PIN cannot be sequential digits (e.g. 1234)';
    }
    return null;
  }

  String? _validateConfirmPin(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please confirm your kiosk PIN';
    }
    if (value.trim() != _pinController.text.trim()) {
      return 'PIN confirmation does not match';
    }
    return null;
  }

  Future<void> _submitPin() async {
    HapticFeedback.lightImpact();

    if (!_formKey.currentState!.validate()) {
      // Auto-scroll to first error field and request focus
      final pinError = _validatePin(_pinController.text);
      if (pinError != null) {
        Scrollable.ensureVisible(
          _pinFieldKey.currentContext ?? context,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        _pinFocusNode.requestFocus();
        return;
      }

      final confirmError = _validateConfirmPin(_confirmPinController.text);
      if (confirmError != null) {
        Scrollable.ensureVisible(
          _confirmPinFieldKey.currentContext ?? context,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        _confirmPinFocusNode.requestFocus();
        return;
      }
      return;
    }

    try {
      setState(() => _isLoading = true);

      final success = await widget.repo.setKioskPin(
        pin: _pinController.text.trim(),
        pinConfirmation: _confirmPinController.text.trim(),
      );

      if (success) {
        CustomSnackbar.showSuccess(
          message: 'Kiosk fallback PIN successfully updated.',
        );
        Get.back(result: true);
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

                  // Header Row
                  Row(
                    children: [
                      Container(
                        width: 42.r,
                        height: 42.r,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.secondary.withValues(alpha: 0.3),
                            width: 1.w,
                          ),
                        ),
                        child: Icon(
                          Icons.pin_rounded,
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
                              'Kiosk Backup PIN',
                              style: AppTextStyles.text16.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                            ),
                            AppSpaces.vSpace2,
                            Text(
                              'Configure 4-6 digit PIN for badge-less terminal punching',
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

                  // PIN Field
                  Container(
                    key: _pinFieldKey,
                    child: CustomTextField(
                      controller: _pinController,
                      focusNode: _pinFocusNode,
                      labelText: 'New 4-6 Digit PIN',
                      hintText: 'Enter 4 to 6 numbers',
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
                      validator: _validatePin,
                    ),
                  ),

                  AppSpaces.vSpace12,

                  // Confirm PIN Field
                  Container(
                    key: _confirmPinFieldKey,
                    child: CustomTextField(
                      controller: _confirmPinController,
                      focusNode: _confirmPinFocusNode,
                      labelText: 'Confirm PIN',
                      hintText: 'Re-enter same PIN',
                      obscureText: _isConfirmPinObscured,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icon(
                        Icons.check_circle_outline_rounded,
                        size: 18.sp,
                        color: AppColors.subTextColor,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPinObscured ? Icons.visibility_off : Icons.visibility,
                          size: 18.sp,
                          color: AppColors.subTextColor,
                        ),
                        onPressed: () => setState(() => _isConfirmPinObscured = !_isConfirmPinObscured),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      validator: _validateConfirmPin,
                    ),
                  ),

                  AppSpaces.vSpace14,

                  // Security Rules Info Pill
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: AppColors.liteSecondary.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: AppColors.secondary.withValues(alpha: 0.35),
                        width: 1.w,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 16.sp,
                          color: AppColors.secondary,
                        ),
                        AppSpaces.hSpace8,
                        Expanded(
                          child: Text(
                            'Must be 4 to 6 numeric digits. Identical sequences (1111) or ascending/descending runs (1234, 4321) are prohibited by security policy.',
                            style: AppTextStyles.text12.copyWith(
                              color: AppColors.textColor,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  AppSpaces.vSpace20,

                  // Action Buttons
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
                          text: 'Save PIN',
                          isGradient: true,
                          isLoading: _isLoading,
                          onPressed: _isLoading ? null : _submitPin,
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
