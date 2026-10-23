import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_spaces.dart';
import '../../../core/utils/app_text_styles.dart';
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

class ProfileDetailsView extends GetView<ProfileController> {
  const ProfileDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkBoundaryWrapper(
      onRetry: () => controller.loadProfile(),
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
              _buildAmbientHeader(),

              // 2. Main Scrollable Content Overlapping the Header
              SafeArea(
                child: RefreshIndicator(
                  onRefresh: controller.loadProfile,
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
                        // Top Bar with Back to Profile Hub and Edit Profile Action
                        _buildTopBar(context),

                        AppSpaces.vSpace14,

                        // Component 1: Primary Employee Header Card (Static / non-clickable)
                        const ProfileHeaderCard(isClickable: false),

                        AppSpaces.vSpace14,

                        // Component 2: Dynamic Horizontal Section Tabs Bar (Server Driven from sections)
                        const ProfileSectionTabsBar(),

                        AppSpaces.vSpace14,

                        // Component 3: Reactive Section Tab Content (Hides null/empty fields)
                        Obx(() {
                          final currentKey =
                              controller.selectedSectionKey.value;
                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            switchInCurve: Curves.easeInOut,
                            switchOutCurve: Curves.easeInOut,
                            child: _buildSectionContent(currentKey),
                          );
                        }),

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

  /// Ambient Curved Gradient Header matching executive style
  Widget _buildAmbientHeader() {
    return Container(
      width: double.infinity,
      height: 220.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
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
          bottomLeft: Radius.circular(20.r),
          bottomRight: Radius.circular(20.r),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -60.r,
            right: -40.r,
            child: Container(
              width: 140.r,
              height: 140.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: 20.r,
            left: -50.r,
            child: Container(
              width: 120.r,
              height: 120.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withValues(alpha: 0.05),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Top navigation bar with Back Button, Title, and Edit Profile
  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        // 1. Back Button: Returns smoothly to Profile Hub
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              Get.back();
            },
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              padding: EdgeInsets.all(8.r),
              margin: EdgeInsets.only(right: 10.w),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.borderColor,
                  width: 0.8.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    blurRadius: 6.r,
                    offset: Offset(0, 2.h),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16.sp,
                color: AppColors.textColor,
              ),
            ),
          ),
        ),

        // 2. Title & Subtitle with flex protection
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Employee Profile',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.text18.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              AppSpaces.vSpace2,
              Text(
                'Employment credentials & service records',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.text10.copyWith(
                  color: AppColors.textColor.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
        ),

        AppSpaces.hSpace8,

        // 3. Action: Edit Profile Icon Button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: controller.navigateToEditProfile,
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.borderColor,
                  width: 0.8.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    blurRadius: 6.r,
                    offset: Offset(0, 2.h),
                  ),
                ],
              ),
              child: Icon(
                Icons.edit_outlined,
                size: 18.sp,
                color: AppColors.secondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
