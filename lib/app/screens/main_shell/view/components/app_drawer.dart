import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/services/permission_service.dart';
import '../../../../routes/app_routes.dart';
import '../../../index/controller/index_controller.dart';
import '../../controller/session_me_controller.dart';
import 'drawer_footer_section.dart';
import 'drawer_module_card.dart';
import 'drawer_profile_header.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _navigateToRoute(String routeName, {String? tabKey}) {
    Get.back(); // Dismiss drawer smoothly
    if (Get.currentRoute == Routes.INDEX &&
        Get.isRegistered<IndexController>()) {
      final indexCtrl = Get.find<IndexController>();
      if (tabKey != null && indexCtrl.openTabByKey(tabKey)) {
        return;
      }
      if (routeName == Routes.PROFILE && indexCtrl.openTabByKey('profile')) {
        return;
      }
      if (routeName == Routes.APPROVALS && indexCtrl.openTabByKey('requests')) {
        return;
      }
      if (routeName == Routes.ATTENDANCE_HISTORY && indexCtrl.openTabByKey('attendance')) {
        return;
      }
      if (routeName == Routes.SCHEDULE && indexCtrl.openTabByKey('schedule')) {
        return;
      }
      if (routeName == Routes.EMPLOYEES && indexCtrl.openTabByKey('employees')) {
        return;
      }
    }
    Get.toNamed(routeName);
  }

  Widget? _buildDrawerCardByKey(String key, SessionMeController sessionController) {
    switch (key) {
      case 'requests':
      case 'approvals':
        return DrawerModuleCard(
          title: 'Requests & Approvals',
          subtitle: 'Leave, attendance, overtime & loan requests',
          icon: Icons.inbox_rounded,
          accentTint: AppColors.secondary,
          badgeCount: sessionController.getBadge('requests'),
          onTap: () => _navigateToRoute(Routes.APPROVALS, tabKey: 'requests'),
        );

      case 'employees':
        if (!sessionController.hasPermission('employees.view')) return null;
        return DrawerModuleCard(
          title: 'Employees Directory',
          subtitle: 'Department staff directory & contacts',
          icon: Icons.badge_outlined,
          accentTint: AppColors.primary,
          onTap: () => _navigateToRoute(Routes.EMPLOYEES, tabKey: 'employees'),
        );

      case 'attendance':
        if (!sessionController.hasModule('attendance') ||
            !sessionController.hasPermission('attendance.view')) {
          return null;
        }
        return DrawerModuleCard(
          title: 'Attendance',
          subtitle: 'Punch history, shift logs & daily hours',
          icon: Icons.calendar_today_outlined,
          accentTint: AppColors.warning,
          onTap: () => _navigateToRoute(Routes.ATTENDANCE_HISTORY, tabKey: 'attendance'),
        );

      case 'schedule':
        if (!sessionController.hasModule('attendance')) return null;
        if (!sessionController.hasPermission('schedules.view') &&
            !sessionController.hasPermission('attendance.view')) {
          return null;
        }
        return DrawerModuleCard(
          title: 'Work Schedule & Rota',
          subtitle: 'Assigned shift pattern & holidays roster',
          icon: Icons.schedule_rounded,
          accentTint: AppColors.secondary,
          onTap: () => _navigateToRoute(Routes.SCHEDULE, tabKey: 'schedule'),
        );

      case 'leave':
      case 'leaves':
        if (!sessionController.hasModule('leave') ||
            !sessionController.hasPermission('leave.view')) {
          return null;
        }
        return DrawerModuleCard(
          title: 'Leave Management',
          subtitle: 'Annual quota balance & absence requests',
          icon: Icons.beach_access_outlined,
          accentTint: AppColors.secondary,
          onTap: () => _navigateToRoute(Routes.LEAVE),
        );

      case 'payroll':
      case 'payslips':
        if (!sessionController.hasModule('payroll') ||
            !sessionController.hasPermission('pay.view')) {
          return null;
        }
        return DrawerModuleCard(
          title: 'Payroll & Payslips',
          subtitle: 'Monthly salary breakdown & tax slips',
          icon: Icons.receipt_long_outlined,
          accentTint: AppColors.secondary,
          onTap: () => _navigateToRoute(Routes.PAYROLL),
        );

      case 'money':
      case 'loans':
        if (!sessionController.hasModule('loans_expenses') ||
            !sessionController.hasPermission('money.view')) {
          return null;
        }
        return DrawerModuleCard(
          title: 'Money Requests',
          subtitle: 'Advance money requests & installments',
          icon: Icons.account_balance_wallet_outlined,
          accentTint: AppColors.warning,
          onTap: () => _navigateToRoute(Routes.LOANS),
        );

      case 'performance':
      case 'evaluation':
        if (!sessionController.hasModule('performance') ||
            !sessionController.hasPermission('performance.view')) {
          return null;
        }
        return DrawerModuleCard(
          title: 'Evaluation',
          subtitle: 'Performance reviews & evaluations',
          icon: Icons.trending_up_rounded,
          accentTint: AppColors.accentNavy,
          onTap: () => _navigateToRoute(Routes.EVALUATION),
        );

      case 'documents':
        if (!sessionController.hasModule('documents') ||
            !sessionController.hasPermission('documents.view')) {
          return null;
        }
        return DrawerModuleCard(
          title: 'Documents & Letters',
          subtitle: 'Handbooks, notices & legal documents',
          icon: Icons.menu_book_outlined,
          accentTint: AppColors.info,
          badgeCount: sessionController.getBadge('documents'),
          onTap: () => _navigateToRoute(Routes.DOCUMENTS),
        );

      case 'news':
        if (!sessionController.hasModule('documents') ||
            !sessionController.hasPermission('documents.view')) {
          return null;
        }
        return DrawerModuleCard(
          title: 'News & Events',
          subtitle: 'Announcements, events & milestones',
          icon: Icons.campaign_outlined,
          accentTint: AppColors.secondary,
          onTap: () => _navigateToRoute(Routes.NEWS),
        );

      case 'tasks':
        if (!sessionController.hasModule('onboarding')) return null;
        return DrawerModuleCard(
          title: 'Daily Tasks',
          subtitle: 'Assigned tasks, duties & checklists',
          icon: Icons.check_circle_outline_rounded,
          accentTint: AppColors.secondary,
          badgeCount: sessionController.getBadge('tasks'),
          onTap: () => _navigateToRoute(Routes.TASKS),
        );

      case 'assets':
        if (!sessionController.hasModule('assets') &&
            !sessionController.hasModule('onboarding') &&
            !sessionController.hasPermission('assets.view')) {
          return null;
        }
        return DrawerModuleCard(
          title: 'Company Assets',
          subtitle: 'Assigned hardware, equipment & inventory',
          icon: Icons.devices_other_rounded,
          accentTint: AppColors.accentNavy,
          onTap: () => _navigateToRoute(Routes.ASSETS),
        );

      case 'training':
        if (!sessionController.hasModule('training') &&
            !sessionController.hasModule('onboarding') &&
            !sessionController.hasPermission('training.view')) {
          return null;
        }
        return DrawerModuleCard(
          title: 'Training & Development',
          subtitle: 'Courses, compliance & certifications',
          icon: Icons.school_outlined,
          accentTint: AppColors.secondary,
          onTap: () => _navigateToRoute(Routes.TRAINING),
        );

      case 'checklists':
      case 'onboarding':
        if (!sessionController.hasModule('onboarding') ||
            !sessionController.hasPermission(AppPermissions.onboardingManage)) {
          return null;
        }
        return DrawerModuleCard(
          title: 'Checklists',
          subtitle: 'Onboarding & offboarding workflows',
          icon: Icons.checklist_rounded,
          accentTint: AppColors.primary,
          onTap: () => _navigateToRoute(Routes.CHECKLISTS),
        );

      case 'helpdesk':
        return DrawerModuleCard(
          title: 'HR Helpdesk',
          subtitle: 'HR inquiries, requests & ticket discussion',
          icon: Icons.forum_outlined,
          accentTint: AppColors.secondary,
          badgeCount: sessionController.getBadge('helpdesk'),
          onTap: () => _navigateToRoute(Routes.HELPDESK),
        );

      case 'support':
        if (!sessionController.hasPermission(AppPermissions.supportView) &&
            !sessionController.hasMenuItem('support')) {
          return null;
        }
        return DrawerModuleCard(
          title: 'App Support & Guides',
          subtitle: 'Technical app issues & video tutorials',
          icon: Icons.video_library_outlined,
          accentTint: AppColors.primary,
          onTap: () => _navigateToRoute(Routes.SUPPORT_TICKETS),
        );

      case 'home':
      case 'profile':
      default:
        return null;
    }
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
                  final List<Widget> dynamicCards = [];
                  final Set<String> renderedKeys = {};

                  // Render strictly matching the server's menu list & order
                  if (sessionController.menu.isNotEmpty) {
                    for (final item in sessionController.menu) {
                      if (renderedKeys.contains(item.key)) continue;
                      final card = _buildDrawerCardByKey(item.key, sessionController);
                      if (card != null) {
                        renderedKeys.add(item.key);
                        dynamicCards.add(card);
                      }
                    }
                  } else {
                    // Fallback order when menu is temporarily unpopulated
                    const fallbackOrder = [
                      'requests',
                      'employees',
                      'attendance',
                      'schedule',
                      'leave',
                      'payroll',
                      'money',
                      'performance',
                      'documents',
                      'news',
                      'tasks',
                      'assets',
                      'training',
                      'checklists',
                      'support',
                    ];
                    for (final key in fallbackOrder) {
                      final card = _buildDrawerCardByKey(key, sessionController);
                      if (card != null) {
                        dynamicCards.add(card);
                      }
                    }
                  }

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

                      // Dynamic Cards strictly according to server menu list
                      ...dynamicCards,

                      // Core Self-Service: Job Description (Phase 18)
                      DrawerModuleCard(
                        title: 'Job Description',
                        subtitle: 'Role overview, duties & scope',
                        icon: Icons.assignment_outlined,
                        accentTint: AppColors.secondary,
                        onTap: () => _navigateToRoute(Routes.JOB_DESCRIPTION),
                      ),

                      // Enterprise Kiosk Terminal (only for admins with kiosks.manage)
                      if (sessionController.hasPermission('kiosks.manage'))
                        DrawerModuleCard(
                          title: 'Kiosk Terminal',
                          subtitle: 'Tablet terminal station setup',
                          icon: Icons.tablet_mac_rounded,
                          accentTint: AppColors.secondary,
                          onTap: () => _navigateToRoute(Routes.KIOSK),
                        ),

                      // App Support & Guides (if not already included from menu)
                      if (!renderedKeys.contains('support') &&
                          !renderedKeys.contains('helpdesk') &&
                          (sessionController.hasPermission('support.view') || sessionController.hasMenuItem('support')))
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
