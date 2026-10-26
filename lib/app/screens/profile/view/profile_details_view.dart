import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_spaces.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/widgets/custom_screen_header.dart';
import '../../../core/widgets/employee_ambient_header.dart';
import '../../../core/widgets/network_boundary_wrapper.dart';
import '../controller/profile_controller.dart';
import 'components/profile_account_tab.dart';
import 'components/profile_attendance_tab.dart';
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
        body: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2.5.w,
              ),
            );
          }

          return Stack(
            children: [
              // 1. Curved Ambient Gradient Header
              EmployeeAmbientHeader(height: 230.h),

              // 2. Main Scrollable Content Overlapping the Header
              SafeArea(
                child: RefreshIndicator(
                  onRefresh: controller.refreshActiveProfile,
                  color: AppColors.primary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 10.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Bar with Back (if route), Title, and Edit Profile Action
                        CustomScreenHeader(
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
                                final subtitle = isOther
                                    ? '${p?.designation ?? "Employee"}${p?.department.isNotEmpty == true ? " • ${p!.department}" : ""}'
                                    : 'Employment credentials & service records';
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
                              if (controller.isViewingOtherEmployee.value) {
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

                        AppSpaces.vSpace14,

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
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  /// Builds the view corresponding to the active section tab
  Widget _buildSectionContent(String key) {
    switch (key.toLowerCase()) {
      case 'overview':
        return const ProfileOverviewTab(key: ValueKey('tab_overview'));
      case 'personal':
        return const ProfilePersonalTab(key: ValueKey('tab_personal'));
      case 'job':
        return const ProfileJobTab(key: ValueKey('tab_job'));
      case 'attendance':
        return const ProfileAttendanceTab(key: ValueKey('tab_attendance'));
      case 'documents':
        return const ProfileDocumentsTab(key: ValueKey('tab_documents'));
      case 'bank':
        return const ProfileBankTab(key: ValueKey('tab_bank'));
      case 'account':
        return const ProfileAccountTab(key: ValueKey('tab_account'));
      case 'history':
        return const ProfileHistoryTab(key: ValueKey('tab_history'));
      default:
        return const ProfileOverviewTab(key: ValueKey('tab_default'));
    }
  }


}
