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

class ProvisionKioskSheet extends StatefulWidget {
  final EmployeeTerminalController controller;

  const ProvisionKioskSheet({super.key, required this.controller});

  static Future<void> show(
    BuildContext context, {
    required EmployeeTerminalController controller,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProvisionKioskSheet(controller: controller),
    );
  }

  @override
  State<ProvisionKioskSheet> createState() => _ProvisionKioskSheetState();
}

class _ProvisionKioskSheetState extends State<ProvisionKioskSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController(text: 'Front Reception Tablet');
  final TextEditingController _locationController = TextEditingController();

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _locationFocusNode = FocusNode();

  final GlobalKey _nameKey = GlobalKey();
  final GlobalKey _locationKey = GlobalKey();

  bool _isLoading = false;
  bool _replaceExisting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _nameFocusNode.dispose();
    _locationFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleProvision() async {
    HapticFeedback.lightImpact();

    if (!_formKey.currentState!.validate()) {
      if (_nameController.text.trim().isEmpty) {
        Scrollable.ensureVisible(_nameKey.currentContext ?? context);
        _nameFocusNode.requestFocus();
        return;
      }
      if (_locationController.text.trim().isEmpty) {
        Scrollable.ensureVisible(_locationKey.currentContext ?? context);
        _locationFocusNode.requestFocus();
        return;
      }
      return;
    }

    try {
      setState(() => _isLoading = true);

      final success = await widget.controller.provisionKioskTerminal(
        name: _nameController.text.trim(),
        location: _locationController.text.trim(),
        replace: _replaceExisting,
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
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.secondary.withValues(alpha: 0.3),
                            width: 1.w,
                          ),
                        ),
                        child: Icon(
                          Icons.tablet_mac_rounded,
                          color: AppColors.primary,
                          size: 22.sp,
                        ),
                      ),
                      AppSpaces.hSpace12,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Provision Kiosk Terminal',
                              style: AppTextStyles.text16.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                            ),
                            AppSpaces.vSpace2,
                            Text(
                              'Register this device as a reception terminal (POST /kiosks)',
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

                  // Kiosk Name
                  Container(
                    key: _nameKey,
                    child: CustomTextField(
                      controller: _nameController,
                      focusNode: _nameFocusNode,
                      labelText: 'Terminal Station Name',
                      hintText: 'e.g. Front Reception Kiosk',
                      prefixIcon: Icon(
                        Icons.badge_outlined,
                        size: 18.sp,
                        color: AppColors.subTextColor,
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter kiosk station name';
                        }
                        if (val.trim().length < 2 || val.trim().length > 60) {
                          return 'Name must be between 2 and 60 characters';
                        }
                        return null;
                      },
                    ),
                  ),

                  AppSpaces.vSpace12,

                  // Location ID (ULID)
                  Container(
                    key: _locationKey,
                    child: CustomTextField(
                      controller: _locationController,
                      focusNode: _locationFocusNode,
                      labelText: 'Work Location ULID',
                      hintText: '26-character location ID',
                      prefixIcon: Icon(
                        Icons.location_on_outlined,
                        size: 18.sp,
                        color: AppColors.subTextColor,
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter 26-character location ULID';
                        }
                        return null;
                      },
                    ),
                  ),

                  AppSpaces.vSpace12,

                  // Replace Switch
                  Row(
                    children: [
                      Checkbox(
                        value: _replaceExisting,
                        activeColor: AppColors.secondary,
                        onChanged: (val) => setState(() => _replaceExisting = val ?? false),
                      ),
                      Expanded(
                        child: Text(
                          'Replace existing kiosk secret if already registered',
                          style: AppTextStyles.text12.copyWith(
                            color: AppColors.textColor,
                          ),
                        ),
                      ),
                    ],
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
                          text: 'Provision',
                          isGradient: true,
                          isLoading: _isLoading,
                          onPressed: _isLoading ? null : _handleProvision,
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
