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
                  // Module & Permission visibility strictly driven by sessionController
                  final bool hasAttendance =
                      sessionController.hasModule('attendance') &&
                      sessionController.hasPermission('attendance.view');
                  final bool hasDevices = sessionController.hasModule('devices');
                  final bool hasLeave = sessionController.hasModule('leave');
                  final bool hasPayroll =
                      sessionController.hasModule('payroll') &&
                      sessionController.hasPermission('pay.view');
                  final bool hasLoans =
                      sessionController.hasModule('loans_expenses') &&
                      sessionController.hasPermission('money.view');
                  final bool hasPerformance = sessionController.hasModule(
                    'performance',
                  );
                  final bool hasDocuments = sessionController.hasModule(
                    'documents',
                  );
                  final bool hasOnboarding =
                      sessionController.hasModule('onboarding') &&
                      sessionController.hasPermission('employees.view');
                  final bool hasSupport =
                      sessionController.hasPermission('support.view');

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

                      // Card 2b: Work Schedule & Rota (Module: attendance & Permission: attendance.view)
                      if (hasAttendance &&
                          sessionController.hasPermission('attendance.view'))
                        DrawerModuleCard(
                          title: 'Work Schedule & Rota',
                          subtitle: 'Assigned shift pattern & holidays roster',
                          icon: Icons.schedule_rounded,
                          accentTint: AppColors.secondary,
                          onTap: () => _navigateToRoute(Routes.SCHEDULE),
                        ),

                      // Card 3: AI Face Recognition (Module: devices)
                      if (hasDevices)
                        DrawerModuleCard(
                          title: 'AI Face Recognition',
                          subtitle: 'Biometric verification, liveness & match',
                          icon: Icons.face_retouching_natural,
                          accentTint: AppColors.secondary,
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
                          onTap: () => _navigateToRoute(Routes.LEAVE),
                        ),

                      // Card 5: Payroll & Payslips (Module: payroll)
                      if (hasPayroll)
                        DrawerModuleCard(
                          title: 'Payroll & Payslips',
                          subtitle: 'Monthly salary breakdown & tax slips',
                          icon: Icons.receipt_long_outlined,
                          accentTint: AppColors.secondary,
                          onTap: () => _navigateToRoute(Routes.PAYROLL),
                        ),

                      // Card 6: Loans & Advances (Module: loans_expenses)
                      if (hasLoans)
                        DrawerModuleCard(
                          title: 'Loans & Advances',
                          subtitle: 'Advance money requests & installments',
                          icon: Icons.account_balance_wallet_outlined,
                          accentTint: AppColors.warning,
                          onTap: () => _navigateToRoute(Routes.LOANS),
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

                      // Card 10: Helpdesk & Support (Permission: support.view)
                      if (hasSupport)
                        DrawerModuleCard(
                          title: 'Helpdesk & Support',
                          subtitle: 'Ticket inquiries, issues & assistance',
                          icon: Icons.support_agent_rounded,
                          accentTint: AppColors.secondary,
                          onTap: () =>
                              _navigateToRoute(Routes.SUPPORT_TICKETS),
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
