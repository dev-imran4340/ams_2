import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/network_boundary_wrapper.dart';
import '../controller/org_hub_controller.dart';
import 'components/org_action_hero_card.dart';
import 'components/org_telemetry_banner.dart';
import 'components/terminal_status_footer.dart';

class OrgHubView extends GetView<OrgHubController> {
  const OrgHubView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkBoundaryWrapper(
      onRetry: controller.loadOrgSummary,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Stack(
          children: [
            // 1. Curved Ambient Multi-Stop Gradient Header
            Container(
              width: double.infinity,
              height: 260.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.liteSecondary,
                    AppColors.liteSecondary,
                    AppColors.liteSecondary,
                    AppColors.liteSecondary,
                    AppColors.secondary,
                    AppColors.primary,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24.r),
                  bottomRight: Radius.circular(24.r),
                ),
              ),
              child: Stack(
                children: [
                  // Ambient Translucent Rings
                  Positioned(
                    top: -70.r,
                    right: -50.r,
                    child: Container(
                      width: 170.r,
                      height: 170.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 40.r,
                    left: -60.r,
                    child: Container(
                      width: 140.r,
                      height: 140.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.secondary.withValues(alpha: 0.06),
                      ),
                    ),
                  ),

                  // Header Foreground Content
                  SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Row: Corporate Brand Shield & Action Switch
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Corporate Shield & Title
                              Row(
                                children: [
                                  Container(
                                    width: 44.r,
                                    height: 44.r,
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius:
                                          BorderRadius.circular(12.r),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.15),
                                          blurRadius: 10.r,
                                          offset: Offset(0, 3.h),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.corporate_fare_rounded,
                                        size: 26.sp,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  AppSpaces.hSpace12,
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Obx(
                                        () => Text(
                                          controller.summary.value
                                                  ?.organizationName ??
                                              'SoftGenie Technologies',
                                          style: AppTextStyles.text16.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.white,
                                          ),
                                        ),
                                      ),
                                      AppSpaces.vSpace2,
                                      // Location Badge Pill
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8.w,
                                          vertical: 2.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.white
                                              .withValues(alpha: 0.18),
                                          borderRadius:
                                              BorderRadius.circular(10.r),
                                        ),
                                        child: Obx(
                                          () => Text(
                                            controller.summary.value
                                                    ?.branchLocation ??
                                                'HQ Campus • Islamabad',
                                            style:
                                                AppTextStyles.text10.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              // Right Glass Button: Terminal Gateway Options
                              InkWell(
                                onTap: () => controller
                                    .showSwitchOrLogoutSheet(context),
                                borderRadius: BorderRadius.circular(12.r),
                                child: Container(
                                  padding: EdgeInsets.all(8.r),
                                  decoration: BoxDecoration(
                                    color: AppColors.white
                                        .withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: AppColors.white
                                          .withValues(alpha: 0.25),
                                      width: 1.w,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.tune_rounded,
                                    size: 20.sp,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          AppSpaces.vSpace18,

                          // Subtitle Capsule
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 5.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(18.r),
                              border: Border.all(
                                color:
                                    AppColors.white.withValues(alpha: 0.18),
                                width: 0.8.w,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.shield_rounded,
                                  size: 13.sp,
                                  color: AppColors.liteSecondary,
                                ),
                                AppSpaces.hSpace6,
                                Text(
                                  'Enterprise Terminal & Operational Gateway',
                                  style: AppTextStyles.text10.copyWith(
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                    color: AppColors.white,
                                  ),
                                ),
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

            // 2. Main Scrollable Gateway Body
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Space for curved header top section
                    SizedBox(height: 125.h),

                    // 1. Real-Time Facilities Telemetry Banner
                    const OrgTelemetryBanner(),

                    AppSpaces.vSpace20,

                    // Operational Hub Section Label
                    Row(
                      children: [
                        Container(
                          width: 4.w,
                          height: 16.h,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                        AppSpaces.hSpace8,
                        Text(
                          'OPERATIONAL STATIONS',
                          style: AppTextStyles.text12.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                            color: AppColors.textColor,
                          ),
                        ),
                      ],
                    ),

                    AppSpaces.vSpace12,

                    // Card 1: Visitor Management (Reception Kiosk)
                    OrgActionHeroCard(
                      title: 'Visitor Management',
                      tag: 'Reception Kiosk',
                      description:
                          'Digital guest onboarding, selfie verification, entry pass generation & facial exit clearance.',
                      buttonText: 'Launch Visitor Kiosk',
                      icon: Icons.badge_rounded,
                      accentColor: AppColors.secondary,
                      onTap: controller.navigateToVisitorManagement,
                    ),

                    AppSpaces.vSpace14,

                    // Card 2: Employee Gate Terminal (Biometric Portal)
                    OrgActionHeroCard(
                      title: 'Employee Gate Terminal',
                      tag: 'Biometric Portal',
                      description:
                          'High-speed employee ID card QR scanner paired with AI facial liveness recognition.',
                      buttonText: 'Open Attendance Gate',
                      icon: Icons.qr_code_scanner_rounded,
                      accentColor: AppColors.info,
                      onTap: controller.navigateToEmployeeTerminal,
                    ),

                    AppSpaces.vSpace14,

                    // Card 3: Staff Onboarding (Admin & HR)
                    OrgActionHeroCard(
                      title: 'Staff Onboarding',
                      tag: 'Admin & HR',
                      description:
                          'Enroll new staff, configure assigned shift roster, and capture biometric facial templates.',
                      buttonText: 'Register New Employee',
                      icon: Icons.person_add_alt_1_rounded,
                      accentColor: AppColors.warning,
                      onTap: controller.navigateToAddEmployee,
                    ),

                    AppSpaces.vSpace16,

                    // 3. Encrypted Terminal Status Footer
                    const TerminalStatusFooter(),

                    AppSpaces.vSpace16,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
