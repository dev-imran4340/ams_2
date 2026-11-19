import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
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
                  // Module, Permission & Dynamic Menu checks strictly driven by sessionController
                  final bool hasAttendance =
                      sessionController.hasModule('attendance') &&
                      sessionController.hasPermission('attendance.view') &&
                      sessionController.hasMenuItem('attendance');

                  final bool hasSchedule =
                      sessionController.hasModule('attendance') &&
                      (sessionController.hasPermission('schedules.view') ||
                          sessionController.hasPermission('attendance.view')) &&
                      sessionController.hasMenuItem('schedule');

                  final bool hasLeave = sessionController.hasModule('leave') &&
                      sessionController.hasPermission('leave.view') &&
                      sessionController.hasMenuItem('leave');

                  final bool hasPayroll =
                      sessionController.hasModule('payroll') &&
                      sessionController.hasPermission('pay.view') &&
                      sessionController.hasMenuItem('payslips');

                  final bool hasLoans =
                      sessionController.hasModule('loans_expenses') &&
                      sessionController.hasPermission('money.view') &&
                      sessionController.hasMenuItem('money');

                  final bool hasPerformance =
                      sessionController.hasModule('performance') &&
                      sessionController.hasPermission('performance.view') &&
                      sessionController.hasMenuItem('performance');

                  final bool hasDocuments =
                      sessionController.hasModule('documents') &&
                      sessionController.hasPermission('documents.view') &&
                      sessionController.hasMenuItem('documents');
                  final int docBadges = sessionController.getBadge('documents');

                  final bool hasNews =
                      sessionController.hasModule('documents') &&
                      sessionController.hasPermission('documents.view') &&
                      sessionController.hasMenuItem('news');

                  final bool hasTasks =
                      sessionController.hasModule('onboarding') &&
                      sessionController.hasMenuItem('tasks');
                  final int taskBadges = sessionController.getBadge('tasks');

                  final bool hasAssets =
                      sessionController.hasMenuItem('assets') ||
                      sessionController.hasPermission('assets.view') ||
                      sessionController.hasModule('assets') ||
                      sessionController.hasModule('onboarding');

                  final bool hasTraining =
                      sessionController.hasMenuItem('training') ||
                      sessionController.hasPermission('training.view') ||
                      sessionController.hasModule('training') ||
                      sessionController.hasModule('onboarding');

                  final bool hasChecklists =
                      sessionController.hasMenuItem('checklists') ||
                      sessionController.hasPermission('checklists.view') ||
                      sessionController.hasModule('onboarding');

                  // Staff Onboarding is strictly for Manager/HR/Admin with department or company scope
                  final bool hasOnboarding =
                      sessionController.hasModule('onboarding') &&
                      (sessionController.hasPermission('employees.view', 'department') ||
                          sessionController.hasPermission('employees.view', 'company'));

                  final bool hasSupport =
                      sessionController.hasMenuItem('support') ||
                      sessionController.hasPermission('support.view');

                  final bool hasHelpdesk =
                      sessionController.hasMenuItem('helpdesk') ||
                      sessionController.hasModule('onboarding');
                  final int helpdeskBadges = sessionController.getBadge('helpdesk');

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

                      // Card 2b: Work Schedule & Rota (Module: attendance & Permission: schedules.view / attendance.view)
                      if (hasSchedule)
                        DrawerModuleCard(
                          title: 'Work Schedule & Rota',
                          subtitle: 'Assigned shift pattern & holidays roster',
                          icon: Icons.schedule_rounded,
                          accentTint: AppColors.secondary,
                          onTap: () => _navigateToRoute(Routes.SCHEDULE),
                        ),

                      // Card 3: Leave Management (Module: leave)
                      if (hasLeave)
                        DrawerModuleCard(
                          title: 'Leave Management',
                          subtitle: 'Annual quota balance & absence requests',
                          icon: Icons.beach_access_outlined,
                          accentTint: AppColors.secondary,
                          onTap: () => _navigateToRoute(Routes.LEAVE),
                        ),

                      // Card 4: Payroll & Payslips (Module: payroll)
                      if (hasPayroll)
                        DrawerModuleCard(
                          title: 'Payroll & Payslips',
                          subtitle: 'Monthly salary breakdown & tax slips',
                          icon: Icons.receipt_long_outlined,
                          accentTint: AppColors.secondary,
                          onTap: () => _navigateToRoute(Routes.PAYROLL),
                        ),

                      // Card 5: Money Requests (Module: loans_expenses)
                      if (hasLoans)
                        DrawerModuleCard(
                          title: 'Money Requests',
                          subtitle: 'Advance money requests & installments',
                          icon: Icons.account_balance_wallet_outlined,
                          accentTint: AppColors.warning,
                          onTap: () => _navigateToRoute(Routes.LOANS),
                        ),

                      // Card 6: Evaluation (Module: performance)
                      if (hasPerformance)
                        DrawerModuleCard(
                          title: 'Evaluation',
                          subtitle: 'Performance reviews & evaluations',
                          icon: Icons.trending_up_rounded,
                          accentTint: AppColors.accentNavy,
                          onTap: () => _navigateToRoute(Routes.EVALUATION),
                        ),

                      // Card 7: Documents & Policies (Module: documents)
                      if (hasDocuments)
                        DrawerModuleCard(
                          title: 'Documents & Letters',
                          subtitle: 'Handbooks, notices & legal documents',
                          icon: Icons.menu_book_outlined,
                          accentTint: AppColors.info,
                          badgeCount: docBadges,
                          onTap: () => _navigateToRoute(Routes.DOCUMENTS),
                        ),

                      // Card 7b: News & Events (Module: documents, menu: news)
                      if (hasNews)
                        DrawerModuleCard(
                          title: 'News & Events',
                          subtitle: 'Announcements, events & milestones',
                          icon: Icons.campaign_outlined,
                          accentTint: AppColors.secondary,
                          onTap: () => _navigateToRoute(Routes.NEWS),
                        ),

                      // Card 8: Daily Tasks (Module: onboarding)
                      if (hasTasks)
                        DrawerModuleCard(
                          title: 'Daily Tasks',
                          subtitle: 'Assigned tasks, duties & checklists',
                          icon: Icons.check_circle_outline_rounded,
                          accentTint: AppColors.secondary,
                          badgeCount: taskBadges,
                          onTap: () => _navigateToRoute(Routes.TASKS),
                        ),

                      // Card 8b: Company Assets (Module: assets)
                      if (hasAssets)
                        DrawerModuleCard(
                          title: 'Company Assets',
                          subtitle: 'Assigned hardware, equipment & inventory',
                          icon: Icons.devices_other_rounded,
                          accentTint: AppColors.accentNavy,
                          onTap: () => _navigateToRoute(Routes.ASSETS),
                        ),

                      // Card 8c: Training & Certifications (Module: training)
                      if (hasTraining)
                        DrawerModuleCard(
                          title: 'Training & Development',
                          subtitle: 'Courses, compliance & certifications',
                          icon: Icons.school_outlined,
                          accentTint: AppColors.secondary,
                          onTap: () => _navigateToRoute(Routes.TRAINING),
                        ),

                      // Card 8d: Checklists (Module: onboarding)
                      if (hasChecklists)
                        DrawerModuleCard(
                          title: 'Checklists',
                          subtitle: 'Onboarding & offboarding workflows',
                          icon: Icons.checklist_rounded,
                          accentTint: AppColors.primary,
                          onTap: () => _navigateToRoute(Routes.CHECKLISTS),
                        ),

                      // Card 9: Staff Onboarding (Manager/HR with department/company scope)
                      if (hasOnboarding)
                        DrawerModuleCard(
                          title: 'Staff Onboarding',
                          subtitle: 'Register new staff & capture AI face',
                          icon: Icons.person_add_alt_1_outlined,
                          accentTint: AppColors.primary,
                          onTap: () => _navigateToRoute(Routes.ADD_EMPLOYEE),
                        ),

                      // Card 10a: HR Helpdesk (Corporate Service Desk & Inquiries)
                      if (hasHelpdesk)
                        DrawerModuleCard(
                          title: 'HR Helpdesk',
                          subtitle: 'Service desk, HR, IT & payroll inquiries',
                          icon: Icons.confirmation_number_outlined,
                          accentTint: AppColors.secondary,
                          badgeCount: helpdeskBadges,
                          onTap: () => _navigateToRoute(Routes.HELPDESK),
                        ),

                      // Card 10b: App Support & Guides (App Technical Issues & Videos)
                      if (hasSupport)
                        DrawerModuleCard(
                          title: 'App Support & Guides',
                          subtitle: 'Technical app issues & video tutorials',
                          icon: Icons.video_library_outlined,
                          accentTint: AppColors.primary,
                          onTap: () => _navigateToRoute(Routes.SUPPORT_TICKETS),
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
