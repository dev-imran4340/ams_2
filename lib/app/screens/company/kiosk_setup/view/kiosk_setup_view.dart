import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:ams_2/app/core/utils/app_colors.dart';
import 'package:ams_2/app/core/utils/app_spaces.dart';
import 'package:ams_2/app/core/utils/app_text_styles.dart';
import 'package:ams_2/app/core/widgets/custom_button.dart';
import 'package:ams_2/app/core/widgets/custom_screen_header.dart';
import 'package:ams_2/app/core/widgets/custom_text_field.dart';
import 'package:ams_2/app/core/widgets/employee_ambient_header.dart';
import 'package:ams_2/app/core/widgets/network_boundary_wrapper.dart';
import 'package:ams_2/app/screens/company/dashboard/controller/company_dashboard_controller.dart';

class KioskSetupView extends GetView<CompanyDashboardController> {
  const KioskSetupView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkBoundaryWrapper(
      onRetry: controller.loadDashboard,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Stack(
          children: [
            EmployeeAmbientHeader(
              height: 240.h,
              borderRadius: 20.r,
              gradientColors: const [
                AppColors.primary,
                AppColors.primary,
                AppColors.primary,
                AppColors.primary,
                AppColors.primary,
                AppColors.secondary,
                AppColors.liteSecondary,
              ],
            ),
            SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                controller: controller.scrollController,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                child: Form(
                  key: controller.provisionFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomScreenHeader(
                        title: 'Kiosk Provisioning',
                        subtitle: 'Provision this tablet as an attendance terminal',
                        showBackButton: true,
                        onBack: () => Get.back(),
                      ),

                      AppSpaces.vSpace16,

                      // Floating Card: Setup Instructions & Form
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(15.r),
                          border: Border(
                            bottom: BorderSide(color: AppColors.secondary, width: 3.w),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8.r),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Icon(
                                    Icons.tablet_mac_rounded,
                                    color: AppColors.secondary,
                                    size: 20.sp,
                                  ),
                                ),
                                AppSpaces.hSpace10,
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Terminal Configuration',
                                        style: AppTextStyles.text14.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textColor,
                                        ),
                                      ),
                                      Text(
                                        'Registers hardware tablet with AMS 2 backend',
                                        style: AppTextStyles.text12.copyWith(
                                          color: AppColors.subTextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            AppSpaces.vSpace16,

                            // Field 1: Kiosk Name
                            Text(
                              'Terminal / Kiosk Name *',
                              style: AppTextStyles.text12.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textColor,
                              ),
                            ),
                            AppSpaces.vSpace6,
                            CustomTextField(
                              controller: controller.kioskNameController,
                              focusNode: controller.kioskNameFocusNode,
                              hintText: 'e.g. Front Desk Reception, Gate 2',
                              prefixIcon: Icon(Icons.badge_outlined, size: 20.sp, color: AppColors.subTextColor),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Please enter a kiosk name (2-60 characters)';
                                }
                                if (val.trim().length < 2 || val.trim().length > 60) {
                                  return 'Name must be between 2 and 60 characters';
                                }
                                return null;
                              },
                            ),

                            AppSpaces.vSpace14,

                            // Field 2: Work Location ID
                            Text(
                              'Work Location ID *',
                              style: AppTextStyles.text12.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textColor,
                              ),
                            ),
                            AppSpaces.vSpace6,
                            CustomTextField(
                              controller: controller.locationController,
                              focusNode: controller.locationFocusNode,
                              hintText: 'Work Location ULID (e.g. 01j...)',
                              prefixIcon: Icon(Icons.location_on_outlined, size: 20.sp, color: AppColors.subTextColor),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Please enter the work location ID';
                                }
                                return null;
                              },
                            ),

                            AppSpaces.vSpace14,

                            // Option: Replace Existing
                            Obx(() => SwitchListTile.adaptive(
                              contentPadding: EdgeInsets.zero,
                              activeThumbColor: AppColors.secondary,
                              title: Text(
                                'Replace Existing Kiosk Secret',
                                style: AppTextStyles.text12.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textColor,
                                ),
                              ),
                              subtitle: Text(
                                'Check this option if resetting an existing kiosk of the same name to issue a new secret.',
                                style: AppTextStyles.text10.copyWith(
                                  color: AppColors.subTextColor,
                                ),
                              ),
                              value: controller.replaceExisting.value,
                              onChanged: (val) {
                                controller.replaceExisting.value = val;
                              },
                            )),

                            AppSpaces.vSpace16,

                            // Security Warning Alert
                            Container(
                              padding: EdgeInsets.all(10.r),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.security_rounded,
                                    size: 18.sp,
                                    color: AppColors.primary,
                                  ),
                                  AppSpaces.hSpace8,
                                  Expanded(
                                    child: Text(
                                      'Strict Invariant: Once provisioned, the tablet stores its unique kiosk secret, logs out your administrator account, and transitions into shared Kiosk Mode.',
                                      style: AppTextStyles.text12.copyWith(
                                        color: AppColors.primary,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            AppSpaces.vSpace18,

                            // Submit Button
                            Obx(() => CustomButton(
                              text: 'Provision Kiosk & Activate Terminal',
                              isGradient: true,
                              isLoading: controller.isProvisioning.value,
                              icon: Icon(Icons.check_circle_outline_rounded, size: 20.sp, color: Colors.white),
                              onPressed: controller.provisionTabletKiosk,
                            )),
                          ],
                        ),
                      ),

                      SizedBox(height: 80.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
