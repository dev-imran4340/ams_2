import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_spaces.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/widgets/custom_screen_header.dart';
import '../../../core/widgets/custom_state_view.dart';
import '../../../core/widgets/employee_ambient_header.dart';
import '../../../core/widgets/network_boundary_wrapper.dart';
import '../../../routes/app_routes.dart';
import '../controller/profile_controller.dart';
import 'components/profile_account_tab.dart';
import 'components/profile_bank_tab.dart';
import 'components/profile_documents_tab.dart';
import 'components/profile_header_card.dart';
import 'components/profile_history_tab.dart';
import 'components/profile_job_tab.dart';
import 'components/profile_overview_tab.dart';
import 'components/profile_personal_tab.dart';
import 'components/profile_section_tabs_bar.dart';

/// Unified Comprehensive Profile Screen:
/// Handles both self profile (/me/profile) and any selected employee (/employees/{id})
/// with strict identity isolation, server-driven dynamic sections, and zero state conflict.
class ProfileDetailsView extends StatefulWidget {
  final bool isBottomNavTab;

  const ProfileDetailsView({
    super.key,
    this.isBottomNavTab = false,
  });

  @override
  State<ProfileDetailsView> createState() => _ProfileDetailsViewState();
}

class _ProfileDetailsViewState extends State<ProfileDetailsView> {
  late final ProfileController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ProfileController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isBottomNavTab) {
        controller.handleViewEntry(null);
      } else {
        controller.handleViewEntry(Get.arguments);
      }
    });
  }

  @override
  void didUpdateWidget(covariant ProfileDetailsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isBottomNavTab) {
        controller.handleViewEntry(null);
      } else {
        controller.handleViewEntry(Get.arguments);
      }
    });
  }

  @override
  void dispose() {
    if (!widget.isBottomNavTab) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.isRegistered<ProfileController>()) {
          final c = Get.find<ProfileController>();
          if (!c.isClosed) {
            c.handleViewExit();
          }
        }
      });
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NetworkBoundaryWrapper(
      onRetry: controller.refreshActiveProfile,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Stack(
          children: [
            // 1. Curved Ambient Gradient Header (Always visible)
            EmployeeAmbientHeader(height: 230.h),

            // 2. Sticky Header + Scrollable Body
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 0),
                    child: CustomScreenHeader(
                      title: '',
                      showBackButton: !widget.isBottomNavTab,
                      customTitleWidget: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Obx(() {
                            final isOther =
                                controller.isViewingOtherEmployee.value;
                            final name = controller.profile.value?.name;
                            final title = isOther
                                ? (name != null && name.isNotEmpty
                                      ? name
                                      : 'Employee Profile')
                                : 'My Profile';
                            return Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.text16.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                            );
                          }),
                          AppSpaces.vSpace2,
                          Obx(() {
                            final isOther =
                                controller.isViewingOtherEmployee.value;
                            final p = controller.profile.value;
                            final desig =
                                p?.designation ?? p?.job?.designation ?? '';
                            final dept =
                                p?.department ?? p?.job?.department ?? '';
                            final parts = [
                              if (desig.trim().isNotEmpty) desig.trim(),
                              if (dept.trim().isNotEmpty) dept.trim(),
                            ];
                            final subtitle = isOther
                                ? (parts.isNotEmpty ? parts.join(' • ') : '')
                                : 'Employment credentials & service records';
                            if (subtitle.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.text10.copyWith(
                                color: AppColors.textColor
                                    .withValues(alpha: 0.75),
                              ),
                            );
                          }),
                        ],
                      ),
                      actions: [
                        Obx(() {
                          if (controller.isViewingOtherEmployee.value ||
                              controller.isAccessRestricted.value) {
                            return const SizedBox.shrink();
                          }
                          return CustomScreenHeader.actionButton(
                            icon: Icons.edit_outlined,
                            onTap: controller.navigateToEditProfile,
                            tooltip: 'Edit Profile',
                          );
                        }),
                      ],
                    ),
                  ),
                  AppSpaces.vSpace14,
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: controller.refreshActiveProfile,
                      color: AppColors.primary,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 4.h,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(() {
                        if (controller.isLoading.value) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 48.h),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 2.5.w,
                              ),
                            ),
                          );
                        }

                        if (controller.isAccessRestricted.value &&
                            controller.profile.value == null) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 24.h),
                            child: Center(
                              child: CustomStateView.error(
                                title: 'Access Restricted',
                                message: controller
                                        .accessRestrictedMessage.value.isNotEmpty
                                    ? controller.accessRestrictedMessage.value
                                    : 'Personal profile details are not enabled for your role.',
                                buttonText: 'Refresh',
                                onRetry: controller.refreshActiveProfile,
                              ),
                            ),
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Component 1: Primary Employee Header Card (Static / non-clickable)
                            const ProfileHeaderCard(isClickable: false),

                            AppSpaces.vSpace14,

                            // Component 2: Dynamic Horizontal Section Tabs Bar (Server Driven from sections)
                            const ProfileSectionTabsBar(),

                            AppSpaces.vSpace14,

                            // Component 3: Reactive Section Tab Content (Supports left/right swipe between tabs)
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onHorizontalDragEnd: (details) {
                                if (details.primaryVelocity == null) return;
                                if (details.primaryVelocity! < -250) {
                                  // Swiped left -> next section tab
                                  controller.selectNextSection();
                                } else if (details.primaryVelocity! > 250) {
                                  // Swiped right -> previous section tab
                                  controller.selectPreviousSection();
                                }
                              },
                              child: Obx(() {
                                final currentKey =
                                    controller.selectedSectionKey.value;
                                return AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  switchInCurve: Curves.easeInOut,
                                  switchOutCurve: Curves.easeInOut,
                                  child: _buildSectionContent(currentKey),
                                );
                              }),
                            ),

                            AppSpaces.vSpace18,

                            // Corporate Version Stamp
                            Center(
                              child: Text(
                                'AMS 2.0 • Powered by Softech Business Services',
                                style: AppTextStyles.text10.copyWith(
                                  letterSpacing: 0.5,
                                  color: AppColors.subTextColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                            // Safe clearance for bottom edge
                            SizedBox(height: 30.h),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
                  ],
                ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the view corresponding to the active section tab
  Widget _buildSectionContent(String key) {
    final isOther = controller.isViewingOtherEmployee.value;

    switch (key.toLowerCase()) {
      case 'overview':
        return const ProfileOverviewTab(key: ValueKey('tab_overview'));

      case 'personal':
        return const ProfilePersonalTab(key: ValueKey('tab_personal'));

      case 'job':
        return const ProfileJobTab(key: ValueKey('tab_job'));

      case 'documents':
        if (isOther) {
          return const ProfileDocumentsTab(key: ValueKey('tab_documents'));
        }
        return CustomStateView.empty(
          key: const ValueKey('tab_empty_documents'),
          icon: Icons.description_outlined,
          title: 'Company Documents & Policies',
          message: 'Browse company HR policies, handbooks, guidelines, and official compliance documents.',
          buttonText: 'Open Documents & Policies',
          onAction: () => Get.toNamed(Routes.DOCUMENTS, arguments: {'tab': 0}),
        );

      case 'files':
        if (isOther) {
          return const ProfileDocumentsTab(key: ValueKey('tab_files'));
        }
        return CustomStateView.empty(
          key: const ValueKey('tab_empty_files'),
          icon: Icons.folder_shared_outlined,
          title: 'Employee Personal Files',
          message: 'Access your personal employee files, credentials, contracts, and issued letters.',
          buttonText: 'Open Employee Files',
          onAction: () => Get.toNamed(Routes.DOCUMENTS, arguments: {'tab': 1}),
        );

      case 'bank':
        return const ProfileBankTab(key: ValueKey('tab_bank'));

      case 'account':
        return const ProfileAccountTab(key: ValueKey('tab_account'));

      case 'history':
        return const ProfileHistoryTab(key: ValueKey('tab_history'));

      case 'schedule':
        return CustomStateView.empty(
          key: const ValueKey('tab_empty_schedule'),
          icon: Icons.calendar_month_outlined,
          title: 'Schedule Access Restricted',
          message: isOther
              ? 'You do not have department/company permission to audit this employee’s work schedule.'
              : 'Your assigned shift rota and working hours are managed under Attendance.',
          buttonText: isOther ? null : 'Open Schedule',
          onAction: isOther ? null : () => Get.toNamed(Routes.SCHEDULE),
        );

      case 'attendance':
        return CustomStateView.empty(
          key: const ValueKey('tab_empty_attendance'),
          icon: Icons.history_rounded,
          title: 'Attendance Access Restricted',
          message: isOther
              ? 'You do not have department/company permission to view this employee’s timesheet logs.'
              : 'Attendance punch logs and shifts can be viewed directly from Attendance History.',
          buttonText: isOther ? null : 'Open Attendance History',
          onAction: isOther ? null : () => Get.toNamed(Routes.ATTENDANCE_HISTORY),
        );

      case 'leave':
        return CustomStateView.empty(
          key: const ValueKey('tab_empty_leave'),
          icon: Icons.beach_access_outlined,
          title: 'Leave Records Access',
          message: isOther
              ? 'You do not have permission to audit leave records for this employee.'
              : 'Your leave balance and applications are managed in Leave Management.',
          buttonText: isOther ? null : 'Open Leave Management',
          onAction: isOther ? null : () => Get.toNamed(Routes.LEAVE),
        );

      case 'pay':
        return CustomStateView.empty(
          key: const ValueKey('tab_empty_pay'),
          icon: Icons.receipt_long_outlined,
          title: 'Payroll Details',
          message: isOther
              ? 'Confidential: Salary and payslip records are strictly confidential and restricted to authorized payroll officers.'
              : 'Access your salary structure and monthly payslips via Payroll & Payslips.',
          buttonText: isOther ? null : 'Open Payroll & Payslips',
          onAction: isOther ? null : () => Get.toNamed(Routes.PAYROLL),
        );

      case 'money':
        return CustomStateView.empty(
          key: const ValueKey('tab_empty_money'),
          icon: Icons.account_balance_wallet_outlined,
          title: 'Loans & Money Requests',
          message: isOther
              ? 'Confidential: Employee loans, advance requests, and expense claims are private to the employee and finance department.'
              : 'Submit and track staff loans, salary advances, and expenses via Money Requests.',
          buttonText: isOther ? null : 'Open Loans & Money Requests',
          onAction: isOther ? null : () => Get.toNamed(Routes.LOANS),
        );

      case 'performance':
        return CustomStateView.empty(
          key: const ValueKey('tab_empty_performance'),
          icon: Icons.trending_up_rounded,
          title: 'Performance & Appraisals',
          message: isOther
              ? 'No active appraisal review or KPI criteria report is currently open for this profile cycle.'
              : 'Review your appraisal cycles, KPIs, and performance evaluations in Performance.',
          buttonText: isOther ? null : 'Open Performance & Evaluations',
          onAction: isOther ? null : () => Get.toNamed(Routes.EVALUATION),
        );

      case 'onboarding':
        return CustomStateView.empty(
          key: const ValueKey('tab_empty_onboarding'),
          icon: Icons.checklist_rounded,
          title: 'Onboarding & Checklists',
          message: isOther
              ? 'Confidential: Joining & leaving checklists are restricted to the employee and HR managers.'
              : 'Review your active and completed onboarding and offboarding checklist tasks.',
          buttonText: isOther ? null : 'Open Checklists',
          onAction: isOther ? null : () => Get.toNamed(Routes.CHECKLISTS),
        );

      case 'assets':
        return CustomStateView.empty(
          key: const ValueKey('tab_empty_assets'),
          icon: Icons.devices_other_rounded,
          title: 'Company Assets & Equipment',
          message: isOther
              ? 'Confidential: Equipment and hardware inventory is restricted to the assigned employee and IT asset officers.'
              : 'View, track, and acknowledge laptops, monitors, SIM cards, and company hardware assigned to you.',
          buttonText: isOther ? null : 'Open Company Assets',
          onAction: isOther ? null : () => Get.toNamed(Routes.ASSETS),
        );

      case 'training':
        return CustomStateView.empty(
          key: const ValueKey('tab_empty_training'),
          icon: Icons.school_outlined,
          title: 'Training & Development',
          message: isOther
              ? 'Confidential: Enrolled training records and development certifications are restricted to employee and HR officers.'
              : 'Review your required compliance courses, training records, and earned certifications.',
          buttonText: isOther ? null : 'Open Training & Certifications',
          onAction: isOther ? null : () => Get.toNamed(Routes.TRAINING),
        );

      default:
        return CustomStateView.empty(
          key: ValueKey('tab_empty_$key'),
          title: 'No Data Available',
          message: 'There are no active records for this profile section.',
        );
    }
  }


}
