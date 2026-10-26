import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../routes/app_routes.dart';
import '../../../index/controller/index_controller.dart';
import '../../controller/session_me_controller.dart';
import 'drawer_footer_section.dart';
import 'drawer_module_card.dart';
import 'drawer_profile_header.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _navigateToRoute(String routeName) {
    Get.back(); // Dismiss drawer smoothly
    if (routeName == Routes.PROFILE &&
        Get.currentRoute == Routes.INDEX &&
        Get.isRegistered<IndexController>()) {
      final indexCtrl = Get.find<IndexController>();
      final profileIdx = indexCtrl.navTabs.indexWhere((t) => t.id == 'profile');
      if (profileIdx != -1) {
        indexCtrl.changeTab(profileIdx);
        return;
      }
    }
    Get.toNamed(routeName);
  }

  @override
  Widget build(BuildContext context) {
    final SessionMeController sessionController =
        Get.isRegistered<SessionMeController>()
        ? Get.find<SessionMeController>()
        : Get.put(SessionMeController(), permanent: true);

    final double drawerWidth = MediaQuery.of(context).size.width * 0.84;

    return Drawer(
      width: drawerWidth.clamp(280.w, 360.w),
      backgroundColor: AppColors.backgroundColor,
      elevation: 16,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: SafeArea(
        top: false,
        bottom: true,
        child: Column(
          children: [
            // 1. Signature Corporate Navy Profile Header (Interactive on Tap)
            const DrawerProfileHeader(),

            // 2. Scrollable Workplace Services Module List
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
                child: Obx(() {
                  // Module visibility booleans dynamically driven by sessionController
                  final bool hasAttendance = sessionController.hasModule(
                    'attendance',
                  );
                  final bool hasDevices = sessionController.hasModule(
                    'devices',
                  );
                  final bool hasLeave = sessionController.hasModule('leave');
                  final bool hasPayroll = sessionController.hasModule(
                    'payroll',
                  );
                  final bool hasLoans = sessionController.hasModule(
                    'loans_expenses',
                  );
                  final bool hasPerformance = sessionController.hasModule(
                    'performance',
                  );
                  final bool hasDocuments = sessionController.hasModule(
                    'documents',
                  );
                  final bool hasOnboarding =
                      sessionController.hasModule('onboarding') &&
                      sessionController.hasPermission('employees.view');

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section Heading
                      Padding(
                        padding: EdgeInsets.only(left: 4.w, bottom: 12.h),
                        child: Text(
                          'WORKPLACE SERVICES',
                          style: AppTextStyles.text12.copyWith(
                            color: AppColors.subTextColor,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      // Card 0: Employee Profile (Module: core - Always Visible)
                      DrawerModuleCard(
                        title: 'Employee Profile',
                        subtitle: 'Personal details, contract, bank & history',
                        icon: Icons.person_outline_rounded,
                        accentTint: AppColors.primary,
                        onTap: () => _navigateToRoute(Routes.PROFILE_DETAILS),
                      ),

                      // Card 1: Digital ID Card (Module: core - Always Visible)
                      DrawerModuleCard(
                        title: 'Digital ID Card',
                        subtitle: 'Smart NFC & QR employee identity badge',
                        icon: Icons.badge_outlined,
                        accentTint: AppColors.secondary,
                        onTap: () => _navigateToRoute(Routes.EMPLOYEE_CARD),
                      ),

                      // Card 2: Attendance History (Module: attendance)
                      if (hasAttendance)
                        DrawerModuleCard(
                          title: 'Attendance',
                          subtitle: 'Punch history, shift logs & daily hours',
                          icon: Icons.calendar_today_outlined,
                          accentTint: AppColors.warning,
                          onTap: () =>
                              _navigateToRoute(Routes.ATTENDANCE_HISTORY),
                        ),

                      // Card 3: Biometric Verification (Module: devices)
                      if (hasDevices)
                        DrawerModuleCard(
                          title: 'Biometric Verification',
                          subtitle: 'AI face match & liveness check gate',
                          icon: Icons.fingerprint_rounded,
                          accentTint: const Color(0xFF6366F1), // Indigo accent
                          onTap: () =>
                              _navigateToRoute(Routes.FACE_RECOGNITION),
                        ),

                      // Card 4: Leave Management (Module: leave)
                      if (hasLeave)
                        DrawerModuleCard(
                          title: 'Leave Management',
                          subtitle: 'Annual quota balance & absence requests',
                          icon: Icons.beach_access_outlined,
                          accentTint: AppColors.secondary,
                          onTap: () {
                            Get.back();
                            if (Get.isRegistered<IndexController>()) {
                              Get.find<IndexController>().changeTab(1);
                            }
                          },
                        ),

                      // Card 5: Payroll & Payslips (Module: payroll)
                      if (hasPayroll)
                        DrawerModuleCard(
                          title: 'Payroll & Payslips',
                          subtitle: 'Monthly salary breakdown & tax slips',
                          icon: Icons.receipt_long_outlined,
                          accentTint: AppColors.success,
                          onTap: () {
                            Get.back();
                            CustomSnackbar.showInfo(
                              message: 'Your personal salary slips are available in your Profile.',
                            );
                          },
                        ),

                      // Card 6: Loans & Advances (Module: loans_expenses)
                      if (hasLoans)
                        DrawerModuleCard(
                          title: 'Loans & Advances',
                          subtitle: 'Advance money requests & installments',
                          icon: Icons.account_balance_wallet_outlined,
                          accentTint: const Color(0xFFF97316), // Orange accent
                          onTap: () {
                            Get.back();
                            CustomSnackbar.showInfo(
                              message: 'Loans & advances portal is accessible to active employees.',
                            );
                          },
                        ),

                      // Card 7: Performance & KPIs (Module: performance)
                      if (hasPerformance)
                        DrawerModuleCard(
                          title: 'Performance & KPIs',
                          subtitle:
                              'Reviews, KPI criteria & manager appraisals',
                          icon: Icons.trending_up_rounded,
                          accentTint: const Color(0xFF64748B), // Slate accent
                          onTap: () => _navigateToRoute(Routes.EVALUATION),
                        ),

                      // Card 8: Company Policies (Module: documents)
                      if (hasDocuments)
                        DrawerModuleCard(
                          title: 'Company Policies',
                          subtitle: 'Handbooks, notices & legal documents',
                          icon: Icons.menu_book_outlined,
                          accentTint: AppColors.info, // Blue accent
                          onTap: () {
                            Get.back();
                            CustomSnackbar.showInfo(
                              message: 'Company policies and letters are up to date.',
                            );
                          },
                        ),

                      // Card 9: Staff Onboarding (Module: onboarding && permission: employees.view)
                      if (hasOnboarding)
                        DrawerModuleCard(
                          title: 'Staff Onboarding',
                          subtitle: 'Register new staff & capture AI face',
                          icon: Icons.person_add_alt_1_outlined,
                          accentTint: const Color(0xFF8B5CF6), // Purple accent
                          onTap: () => _navigateToRoute(Routes.ADD_EMPLOYEE),
                        ),

                      // Card 10: Terminal Kiosk Portal (Module: devices / Global)
                      if (hasDevices)
                        DrawerModuleCard(
                          title: 'Verification Terminal',
                          subtitle: 'Employee verification',
                          icon: Icons.storefront_outlined,
                          accentTint: AppColors.primary,
                          onTap: () {},
                        ),

                      AppSpaces.vSpace8,
                    ],
                  );
                }),
              ),
            ),

            // 3. Drawer Footer Section with Sign Out & Branding
            const DrawerFooterSection(),
          ],
        ),
      ),
    );
  }
}
