import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../api/app_preferences.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../routes/app_routes.dart';
import '../model/org_hub_model.dart';
import '../repo/org_hub_repo.dart';

class OrgHubController extends GetxController {
  final OrgHubRepo repo;

  OrgHubController({required this.repo});

  // Observables
  final RxBool isLoading = false.obs;
  final RxBool isNavigating = false.obs;
  final RxBool isLoggingOut = false.obs;
  final Rxn<OrgPortalSummaryModel> summary = Rxn<OrgPortalSummaryModel>();

  @override
  void onInit() {
    super.onInit();
    loadOrgSummary();
  }

  /// Loads organization metrics and gateway status with try-finally standard
  Future<void> loadOrgSummary() async {
    try {
      isLoading.value = true;
      final result = await repo.fetchOrgSummary();
      if (result != null) {
        summary.value = result;
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Pathway 1: Launches Visitor Management Kiosk
  void navigateToVisitorManagement() {
    if (isNavigating.value) return;

    HapticFeedback.lightImpact();
    isNavigating.value = true;

    final hasRoute = Get.routeTree.routes.any(
      (r) => r.name == Routes.VISITOR_MANAGEMENT,
    );

    if (hasRoute) {
      Get.toNamed(Routes.VISITOR_MANAGEMENT);
    } else {
      CustomSnackbar.showInfo(
        message:
            'Visitor Management Kiosk is being prepared for reception deployment.',
      );
    }

    Future.delayed(const Duration(milliseconds: 400), () {
      isNavigating.value = false;
    });
  }

  /// Pathway 2: Launches Employee Attendance Gate Terminal (QR Scanner & Biometrics)
  void navigateToEmployeeTerminal() {
    if (isNavigating.value) return;

    HapticFeedback.lightImpact();
    isNavigating.value = true;

    Get.toNamed(Routes.QR_SCANNER);

    Future.delayed(const Duration(milliseconds: 400), () {
      isNavigating.value = false;
    });
  }

  /// Pathway 3: Launches Staff Onboarding & HR Enrollment
  void navigateToAddEmployee() {
    if (isNavigating.value) return;

    HapticFeedback.lightImpact();
    isNavigating.value = true;

    final hasRoute = Get.routeTree.routes.any(
      (r) => r.name == Routes.ADD_EMPLOYEE,
    );

    if (hasRoute) {
      Get.toNamed(Routes.ADD_EMPLOYEE);
    } else {
      CustomSnackbar.showInfo(
        message:
            'Employee Registration Portal is ready for staff intake and credential creation.',
      );
    }

    Future.delayed(const Duration(milliseconds: 400), () {
      isNavigating.value = false;
    });
  }

  /// Displays executive options sheet for switching mode or logging out
  void showSwitchOrLogoutSheet(BuildContext context) {
    HapticFeedback.lightImpact();
    Get.bottomSheet(
      Obx(
        () => PopScope(
          canPop: !isLoggingOut.value,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              border: Border.all(
                color: AppColors.borderColor,
                width: 1.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 36.r,
                  offset: Offset(0, -10.h),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag Handle
                  Container(
                    width: 44.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColors.subTextColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),

                  AppSpaces.vSpace16,

                  // Title & Emblem
                  Row(
                    children: [
                      Container(
                        width: 40.r,
                        height: 40.r,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.admin_panel_settings_rounded,
                            size: 22.sp,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      AppSpaces.hSpace12,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Terminal Gateway Controls',
                              style: AppTextStyles.text16.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                            ),
                            AppSpaces.vSpace2,
                            Text(
                              'Switch workplace profile or terminate station session',
                              style: AppTextStyles.text12.copyWith(
                                color: AppColors.subTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  AppSpaces.vSpace20,

                  // Action 1: Switch to Employee Workspace Mode
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      side: BorderSide(color: AppColors.borderColor, width: 1.w),
                    ),
                    tileColor: AppColors.inputFill,
                    leading: Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person_rounded,
                        size: 20.sp,
                        color: AppColors.secondary,
                      ),
                    ),
                    title: Text(
                      'Switch to Employee Mode',
                      style: AppTextStyles.text14.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                    subtitle: Text(
                      'Access personal attendance, shifts, leave balances & requests',
                      style: AppTextStyles.text10.copyWith(
                        color: AppColors.subTextColor,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14.sp,
                      color: AppColors.subTextColor,
                    ),
                    onTap: isLoggingOut.value
                        ? null
                        : () {
                            Get.back();
                            Get.offAllNamed(Routes.INDEX);
                          },
                  ),

                  AppSpaces.vSpace12,

                  // Action 2: Sign Out of Enterprise Station
                  CustomButton(
                    text: 'Sign Out Station Session',
                    isLoading: isLoggingOut.value,
                    backgroundColor: AppColors.error,
                    textColor: AppColors.white,
                    icon: Icon(
                      Icons.logout_rounded,
                      size: 16.sp,
                      color: AppColors.white,
                    ),
                    onPressed: isLoggingOut.value
                        ? null
                        : () async {
                            try {
                              isLoggingOut.value = true;
                              await AppPreferences.clearSession();
                              Get.back();
                              Get.offAllNamed(Routes.LOGIN);
                              CustomSnackbar.showSuccess(
                                title: 'Station Closed',
                                message:
                                    'Organization gateway session cleared securely.',
                              );
                            } finally {
                              isLoggingOut.value = false;
                            }
                          },
                  ),

                  AppSpaces.vSpace10,
                ],
              ),
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: !isLoggingOut.value,
    );
  }

  @override
  void onClose() {
    // Guaranteed zero memory leak contract
    super.onClose();
  }
}
