import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:ams_2/app/core/utils/app_colors.dart';
import 'package:ams_2/app/core/utils/app_spaces.dart';
import 'package:ams_2/app/core/utils/app_text_styles.dart';
import 'package:ams_2/app/core/widgets/custom_button.dart';
import 'package:ams_2/app/core/widgets/custom_text_field.dart';
import '../../controller/kiosk_controller.dart';
import 'kiosk_clock_in_dialog.dart';

class KioskProvisionCard extends StatelessWidget {
  final KioskController controller;

  const KioskProvisionCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isProvisioned = controller.isKioskProvisioned.value;
      final config = controller.activeKioskConfig.value;

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
            // Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.tablet_mac_rounded,
                    color: AppColors.primary,
                    size: 22.sp,
                  ),
                ),
                AppSpaces.hSpace10,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reception Tablet Terminal',
                        style: AppTextStyles.text14.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                      Text(
                        'Enterprise Kiosk Station (Phase 10)',
                        style: AppTextStyles.text12.copyWith(
                          color: AppColors.subTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: isProvisioned
                        ? const Color(0xFF10B981).withValues(alpha: 0.12)
                        : AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    isProvisioned ? 'ACTIVE KIOSK' : 'NOT PROVISIONED',
                    style: AppTextStyles.text10.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isProvisioned ? const Color(0xFF10B981) : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),

            AppSpaces.vSpace12,

            if (isProvisioned) ...[
              // Active Kiosk Details
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: Column(
                  children: [
                    _buildInfoRow('Terminal Name', config?.name ?? 'Main Reception Tablet'),
                    Divider(height: 14.h, color: AppColors.borderColor),
                    _buildInfoRow('Location', config?.locationName ?? 'Office Headquarter'),
                    Divider(height: 14.h, color: AppColors.borderColor),
                    _buildInfoRow('Timezone', config?.timezone ?? 'Asia/Karachi'),
                    Divider(height: 14.h, color: AppColors.borderColor),
                    _buildInfoRow('PIN Clock-in', config?.pinAllowed == true ? 'Allowed' : 'Disabled'),
                  ],
                ),
              ),

              AppSpaces.vSpace16,

              // Action Buttons
              CustomButton(
                text: 'Open Clock-In Terminal',
                isGradient: true,
                onPressed: () {
                  KioskClockInDialog.show(context, controller: controller);
                },
              ),

              AppSpaces.vSpace10,

              OutlinedButton.icon(
                onPressed: controller.deProvisionKiosk,
                icon: Icon(Icons.power_settings_new_rounded, color: AppColors.error, size: 18.sp),
                label: Text(
                  'De-provision Tablet',
                  style: AppTextStyles.text14.copyWith(color: AppColors.error),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, 44.h),
                  side: BorderSide(color: AppColors.error.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            ] else ...[
              // Provisioning Form
              Text(
                'Activate this tablet as an enterprise kiosk terminal. Once configured, staff can clock in via PIN or QR badge.',
                style: AppTextStyles.text12.copyWith(
                  color: AppColors.subTextColor,
                  height: 1.35,
                ),
              ),

              AppSpaces.vSpace16,

              Form(
                key: controller.provisionFormKey,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: controller.kioskNameController,
                      focusNode: controller.kioskNameFocusNode,
                      labelText: 'Kiosk Terminal Name',
                      hintText: 'e.g. Front Desk Kiosk 1',
                      prefixIcon: const Icon(Icons.badge_outlined),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter kiosk name (2-60 characters)';
                        }
                        if (val.trim().length < 2 || val.trim().length > 60) {
                          return 'Name must be between 2 and 60 characters';
                        }
                        return null;
                      },
                    ),

                    AppSpaces.vSpace12,

                    CustomTextField(
                      controller: controller.locationController,
                      focusNode: controller.locationFocusNode,
                      labelText: 'Location ID / Name',
                      hintText: 'e.g. Head Office / 01jb...',
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter location';
                        }
                        return null;
                      },
                    ),

                    AppSpaces.vSpace8,

                    Row(
                      children: [
                        Obx(() => Checkbox(
                              value: controller.replaceExisting.value,
                              activeColor: AppColors.secondary,
                              onChanged: (val) {
                                controller.replaceExisting.value = val ?? false;
                              },
                            )),
                        Expanded(
                          child: Text(
                            'Replace existing tablet with this name',
                            style: AppTextStyles.text12.copyWith(
                              color: AppColors.textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              AppSpaces.vSpace12,

              Obx(() => CustomButton(
                    text: 'Provision Tablet as Kiosk',
                    isGradient: true,
                    isLoading: controller.isSubmitting.value,
                    onPressed: controller.isSubmitting.value
                        ? null
                        : controller.provisionTabletKiosk,
                  )),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.text12.copyWith(
            color: AppColors.subTextColor,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.text12.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
        ),
      ],
    );
  }
}
