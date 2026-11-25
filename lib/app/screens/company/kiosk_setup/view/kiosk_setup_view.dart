import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:ams_2/app/core/utils/app_colors.dart';
import 'package:ams_2/app/core/utils/app_spaces.dart';
import 'package:ams_2/app/core/utils/app_text_styles.dart';
import 'package:ams_2/app/core/widgets/custom_button.dart';
import 'package:ams_2/app/core/widgets/custom_card.dart';
import 'package:ams_2/app/core/widgets/custom_screen_header.dart';
import 'package:ams_2/app/core/widgets/custom_state_view.dart';
import 'package:ams_2/app/core/widgets/custom_text_field.dart';
import 'package:ams_2/app/core/widgets/employee_ambient_header.dart';
import 'package:ams_2/app/core/widgets/network_boundary_wrapper.dart';
import 'package:ams_2/app/screens/company/dashboard/controller/company_dashboard_controller.dart';
import 'package:ams_2/app/screens/kiosk/model/kiosk_model.dart';

class KioskSetupView extends GetView<CompanyDashboardController> {
  const KioskSetupView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkBoundaryWrapper(
      onRetry: controller.loadDashboard,
      child: Obx(
        () => PopScope(
          canPop: !controller.isProvisioning.value,
          child: Scaffold(
            backgroundColor: AppColors.backgroundColor,
            body: Stack(
              children: [
                // 1. Standard Signature Curved Ambient Gradient Header
                EmployeeAmbientHeader(
                  height: 230.h,
                  gradientColors: [
                    AppColors.primary,
                    AppColors.primary,
                    AppColors.primary,
                    AppColors.primary,
                    AppColors.primary,
                    AppColors.secondary,
                    AppColors.liteSecondary,
                  ],
                ),

                // 2. Main Scrollable Content
                SafeArea(
                  bottom: false,
                  child: SingleChildScrollView(
                    controller: controller.scrollController,
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 8.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Header matching all AMS 2 screens
                        CustomScreenHeader(
                          titleColor: AppColors.white,
                          title: 'Kiosk Provisioning',
                          subtitle:
                              'Provision this tablet as an attendance terminal',
                          showBackButton: true,
                          onBack: () {
                            if (!controller.isProvisioning.value) {
                              Get.back();
                            }
                          },
                        ),

                        AppSpaces.vSpace14,

                        if (!controller.canManageKiosks)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 40.h),
                            child: Center(
                              child: CustomStateView.error(
                                title: 'Access Restricted',
                                message: 'Your account lacks the "kiosks.manage" permission required to provision kiosk tablets.',
                                buttonText: 'Go Back',
                                onRetry: () => Get.back(),
                              ),
                            ),
                          )
                        else
                          Form(
                            key: controller.provisionFormKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Main Signature Floating Card
                                CustomCard(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 14.h,
                                  ),
                                  borderRadius: 15.r,
                                  accentColor: AppColors.secondary,
                                  accentWidth: 3.w,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Card Section Header
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(9.r),
                                            decoration: BoxDecoration(
                                              color: AppColors.secondary
                                                  .withValues(alpha: 0.12),
                                              borderRadius:
                                                  BorderRadius.circular(10.r),
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
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Terminal Configuration',
                                                  style: AppTextStyles.text14
                                                      .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            AppColors.textColor,
                                                      ),
                                                ),
                                                AppSpaces.vSpace2,
                                                Text(
                                                  'Registers hardware tablet with AMS 2 backend',
                                                  style: AppTextStyles.text12
                                                      .copyWith(
                                                        color: AppColors
                                                            .subTextColor,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                      AppSpaces.vSpace16,

                                      // Field 1: Terminal / Kiosk Name
                                      Text(
                                        'Terminal / Kiosk Name *',
                                        style: AppTextStyles.text12.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textColor,
                                        ),
                                      ),
                                      AppSpaces.vSpace6,
                                      CustomTextField(
                                        controller:
                                            controller.kioskNameController,
                                        focusNode:
                                            controller.kioskNameFocusNode,
                                        enabled:
                                            !controller.isProvisioning.value,
                                        hintText:
                                            'e.g. Front Desk Reception, Gate 2',
                                        prefixIcon: Icon(
                                          Icons.badge_outlined,
                                          size: 20.sp,
                                          color: AppColors.subTextColor,
                                        ),
                                        validator: (val) {
                                          if (val == null ||
                                              val.trim().isEmpty) {
                                            return 'Please enter a kiosk name (2-60 characters)';
                                          }
                                          if (val.trim().length < 2 ||
                                              val.trim().length > 60) {
                                            return 'Name must be between 2 and 60 characters';
                                          }
                                          return null;
                                        },
                                      ),

                                      AppSpaces.vSpace14,

                                      // Field 2: Work Location (from GET /kiosks/locations)
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Work Location *',
                                            style: AppTextStyles.text12
                                                .copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.textColor,
                                                ),
                                          ),
                                          if (!controller
                                              .isLoadingLocations.value)
                                            InkWell(
                                              onTap:
                                                  controller.isProvisioning.value
                                                      ? null
                                                      : controller
                                                          .loadKioskLocations,
                                              borderRadius:
                                                  BorderRadius.circular(6.r),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 6.w,
                                                  vertical: 2.h,
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.refresh_rounded,
                                                      size: 14.sp,
                                                      color:
                                                          AppColors.secondary,
                                                    ),
                                                    AppSpaces.hSpace4,
                                                    Text(
                                                      'Refresh',
                                                      style: AppTextStyles
                                                          .text10
                                                          .copyWith(
                                                            color: AppColors
                                                                .secondary,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      AppSpaces.vSpace6,
                                      if (controller.isLoadingLocations.value)
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12.w,
                                            vertical: 14.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.backgroundColor,
                                            borderRadius: BorderRadius.circular(
                                              12.r,
                                            ),
                                            border: Border.all(
                                              color: AppColors.borderColor,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width: 18.r,
                                                height: 18.r,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2.w,
                                                  color: AppColors.secondary,
                                                ),
                                              ),
                                              AppSpaces.hSpace10,
                                              Text(
                                                'Loading work locations...',
                                                style: AppTextStyles.text12
                                                    .copyWith(
                                                      color: AppColors
                                                          .subTextColor,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        )
                                      else if (controller
                                              .locationsError.value !=
                                          null)
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12.w,
                                            vertical: 12.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.error.withValues(
                                              alpha: 0.08,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12.r,
                                            ),
                                            border: Border.all(
                                              color: AppColors.error.withValues(
                                                alpha: 0.3,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.error_outline_rounded,
                                                size: 18.sp,
                                                color: AppColors.error,
                                              ),
                                              AppSpaces.hSpace8,
                                              Expanded(
                                                child: Text(
                                                  controller
                                                      .locationsError.value!,
                                                  style: AppTextStyles.text12
                                                      .copyWith(
                                                        color: AppColors.error,
                                                      ),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: controller
                                                    .loadKioskLocations,
                                                child: Text(
                                                  'Retry',
                                                  style: AppTextStyles.text12
                                                      .copyWith(
                                                        color:
                                                            AppColors.secondary,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      else
                                        DropdownButtonFormField<
                                            KioskLocationModel>(
                                          focusNode:
                                              controller.locationFocusNode,
                                          initialValue: controller
                                              .selectedKioskLocation.value,
                                          isExpanded: true,
                                          dropdownColor:
                                              AppColors.cardBackground,
                                          icon: Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            color: AppColors.subTextColor,
                                            size: 22.sp,
                                          ),
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor:
                                                AppColors.backgroundColor,
                                            hintText:
                                                controller
                                                        .kioskLocations.isEmpty
                                                    ? 'No work locations available'
                                                    : 'Select work location',
                                            hintStyle: AppTextStyles.text12
                                                .copyWith(
                                                  color: AppColors.subTextColor,
                                                ),
                                            prefixIcon: Icon(
                                              Icons.location_on_outlined,
                                              size: 20.sp,
                                              color: AppColors.subTextColor,
                                            ),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  horizontal: 12.w,
                                                  vertical: 12.h,
                                                ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12.r),
                                              borderSide: BorderSide(
                                                color: AppColors.borderColor,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12.r),
                                              borderSide: BorderSide(
                                                color: AppColors.borderColor,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12.r),
                                              borderSide: BorderSide(
                                                color: AppColors.secondary,
                                                width: 1.5.w,
                                              ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12.r),
                                              borderSide: BorderSide(
                                                color: AppColors.error,
                                              ),
                                            ),
                                          ),
                                          items: controller.kioskLocations
                                              .map(
                                                (loc) => DropdownMenuItem<
                                                    KioskLocationModel>(
                                                  value: loc,
                                                  child: Text(
                                                    loc.name,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: AppTextStyles.text14
                                                        .copyWith(
                                                          color: AppColors
                                                              .textColor,
                                                        ),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                          onChanged:
                                              controller.isProvisioning.value
                                                  ? null
                                                  : (val) {
                                                      controller
                                                          .selectedKioskLocation
                                                          .value = val;
                                                    },
                                          validator: (val) {
                                            if (val == null) {
                                              return 'Please select a work location';
                                            }
                                            return null;
                                          },
                                        ),

                                      AppSpaces.vSpace12,

                                      // Option: Replace Existing Secret
                                      Material(
                                        color: AppColors.transparent,
                                        child: SwitchListTile.adaptive(
                                          contentPadding: EdgeInsets.zero,
                                          activeThumbColor: AppColors.secondary,
                                          title: Text(
                                            'Replace Existing Kiosk Secret',
                                            style: AppTextStyles.text12
                                                .copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.textColor,
                                                ),
                                          ),
                                          subtitle: Text(
                                            'Check this option if resetting an existing kiosk of the same name to issue a new secret.',
                                            style: AppTextStyles.text10
                                                .copyWith(
                                                  color: AppColors.subTextColor,
                                                ),
                                          ),
                                          value:
                                              controller.replaceExisting.value,
                                          onChanged:
                                              controller.isProvisioning.value
                                              ? null
                                              : (val) {
                                                  controller
                                                          .replaceExisting
                                                          .value =
                                                      val;
                                                },
                                        ),
                                      ),

                                      AppSpaces.vSpace14,

                                      // Security Invariant Notice Banner
                                      Container(
                                        padding: EdgeInsets.all(10.r),
                                        decoration: BoxDecoration(
                                          color: AppColors.info.withValues(
                                            alpha: 0.08,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10.r,
                                          ),
                                          border: Border.all(
                                            color: AppColors.info.withValues(
                                              alpha: 0.25,
                                            ),
                                            width: 1.w,
                                          ),
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                                style: AppTextStyles.text12
                                                    .copyWith(
                                                      color: AppColors.primary,
                                                      height: 1.35,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      AppSpaces.vSpace18,

                                      // Primary Gradient Action Button
                                      CustomButton(
                                        text: 'Provision Kiosk & Activate Terminal',
                                        isGradient: true,
                                        isLoading:
                                            controller.isProvisioning.value,
                                        icon: Icon(
                                          Icons.check_circle_outline_rounded,
                                          size: 20.sp,
                                          color: AppColors.white,
                                        ),
                                        onPressed:
                                            controller.provisionTabletKiosk,
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 60.h),
                              ],
                            ),
                          ),
                      ],
                    ),
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
