import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../api/app_preferences.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../routes/app_routes.dart';
import '../../../profile/controller/profile_controller.dart';
import '../../controller/index_controller.dart';

class ExecutiveAppDrawer extends StatelessWidget {
  const ExecutiveAppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AppPreferences.getUser();
    final String name = user?.name ?? 'Malik Muhammad Imran';
    final String designation = user?.designation ?? 'Senior Software Engineer';
    final String department = user?.department ?? 'Engineering';
    final String employeeId = user?.employeeId ?? 'SFT-094';

    return Drawer(
      backgroundColor: AppColors.cardBackground,
      surfaceTintColor: Colors.transparent,
      elevation: 16,
      width: 300.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Signature Executive Header with Ambient Gradient
          _buildDrawerHeader(
            name: name,
            designation: designation,
            department: department,
            employeeId: employeeId,
          ),

          // 2. Scrollable Navigation Sections
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Operations Section Header
                  _buildSectionLabel('OPERATIONAL SUITE'),
                  AppSpaces.vSpace8,

                  // Highlighted Daily Tasks Item
                  _buildDrawerItem(
                    icon: Icons.checklist_rounded,
                    title: 'Daily Task Management',
                    subtitle: 'Operational milestones & roster',
                    badge: 'Active',
                    badgeColor: AppColors.secondary,
                    iconColor: AppColors.secondary,
                    onTap: () {
                      Get.back(); // Close drawer
                      Get.toNamed(Routes.TASKS);
                    },
                  ),

                  AppSpaces.vSpace8,

                  // Regularization & Overtime
                  _buildDrawerItem(
                    icon: Icons.edit_calendar_rounded,
                    title: 'Regularization & Overtime',
                    subtitle: 'Missed punches & claims',
                    iconColor: AppColors.warning,
                    onTap: () {
                      Get.back();
                      Get.toNamed(Routes.REGULARIZATION);
                    },
                  ),

                  AppSpaces.vSpace8,

                  // Digital Smart Employee ID Card
                  _buildDrawerItem(
                    icon: Icons.badge_rounded,
                    title: 'Digital Employee ID Card',
                    subtitle: 'Smart NFC & QR badge credential',
                    iconColor: AppColors.secondary,
                    badge: 'NFC',
                    badgeColor: AppColors.secondary,
                    onTap: () {
                      Get.back();
                      Get.toNamed(Routes.EMPLOYEE_CARD);
                    },
                  ),

                  AppSpaces.vSpace8,

                  // Employee Card QR Scanner
                  _buildDrawerItem(
                    icon: Icons.qr_code_scanner_rounded,
                    title: 'Employee QR Scanner',
                    subtitle: 'Card badge verification',
                    iconColor: AppColors.info,
                    onTap: () {
                      Get.back();
                      Get.toNamed(Routes.QR_SCANNER);
                    },
                  ),

                  AppSpaces.vSpace8,

                  // AI Face Recognition
                  _buildDrawerItem(
                    icon: Icons.face_retouching_natural_rounded,
                    title: 'Face Biometrics',
                    subtitle: 'AI 3D anti-spoofing match',
                    iconColor: AppColors.success,
                    onTap: () {
                      Get.back();
                      Get.toNamed(Routes.FACE_RECOGNITION);
                    },
                  ),

                  AppSpaces.vSpace8,

                  // Performance & KPI Appraisal
                  _buildDrawerItem(
                    icon: Icons.trending_up_rounded,
                    title: 'Performance & KPIs',
                    subtitle: 'Quarterly scores & appraisal',
                    iconColor: AppColors.primary,
                    badge: 'Q3',
                    badgeColor: AppColors.success,
                    onTap: () {
                      Get.back();
                      Get.toNamed(Routes.EVALUATION);
                    },
                  ),

                  AppSpaces.vSpace8,

                  // Organization Portal Hub
                  _buildDrawerItem(
                    icon: Icons.corporate_fare_rounded,
                    title: 'Organization Portal Hub',
                    subtitle: 'Visitor Kiosk, Gate & HR Intake',
                    iconColor: AppColors.primary,
                    badge: 'Terminal',
                    badgeColor: AppColors.secondary,
                    onTap: () {
                      Get.back();
                      Get.toNamed(Routes.ORG_HUB);
                    },
                  ),

                  AppSpaces.vSpace18,
                  _buildDivider(),
                  AppSpaces.vSpace14,

                  // Main Navigation Tabs Section
                  _buildSectionLabel('CORE WORKSPACE'),
                  AppSpaces.vSpace8,

                  _buildTabItem(
                    tabIndex: 0,
                    icon: Icons.grid_view_rounded,
                    title: 'Dashboard Overview',
                  ),
                  AppSpaces.vSpace4,
                  _buildTabItem(
                    tabIndex: 1,
                    icon: Icons.history_rounded,
                    title: 'Attendance Punch History',
                  ),
                  AppSpaces.vSpace4,
                  _buildTabItem(
                    tabIndex: 2,
                    icon: Icons.event_note_rounded,
                    title: 'Leave Applications',
                  ),
                  AppSpaces.vSpace4,
                  _buildTabItem(
                    tabIndex: 3,
                    icon: Icons.person_outline_rounded,
                    title: 'My Profile & Settings',
                  ),
                ],
              ),
            ),
          ),

          // 3. Drawer Footer: Version & Logout
          _buildFooter(context),
        ],
      ),
    );
  }

  /// Ambient Curved Drawer Header
  Widget _buildDrawerHeader({
    required String name,
    required String designation,
    required String department,
    required String employeeId,
  }) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 48.h, 16.w, 18.h),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.r),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary,
            AppColors.accentNavy,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Ambient Translucent Halo
          Positioned(
            top: -20.h,
            right: -20.w,
            child: Container(
              width: 110.r,
              height: 110.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withValues(alpha: 0.08),
                border: Border.all(
                  color: AppColors.liteSecondary.withValues(alpha: 0.15),
                  width: 1.w,
                ),
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Row with Online Dot & ID Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 52.r,
                        height: 52.r,
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.secondary,
                            width: 2.w,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : 'M',
                            style: AppTextStyles.text20.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 1.r,
                        right: 1.r,
                        child: Container(
                          width: 13.r,
                          height: 13.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.success,
                            border: Border.all(
                              color: AppColors.primary,
                              width: 2.w,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Employee ID Capsule
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 9.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: AppColors.white.withValues(alpha: 0.2),
                        width: 1.w,
                      ),
                    ),
                    child: Text(
                      employeeId,
                      style: AppTextStyles.text10.copyWith(
                        color: AppColors.liteSecondary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),

              AppSpaces.vSpace12,

              // User Name
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.text16.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              AppSpaces.vSpace2,

              // Designation & Dept
              Text(
                '$designation • $department',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.text12.copyWith(
                  color: AppColors.white.withValues(alpha: 0.75),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Section Label
  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w),
      child: Text(
        label,
        style: AppTextStyles.text10.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.subTextColor,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  /// Operational Drawer Item Tile
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
    String? badge,
    Color? badgeColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: AppColors.inputFill.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: AppColors.borderColor,
              width: 1.w,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 19.sp,
                    color: iconColor,
                  ),
                ),
              ),
              AppSpaces.hSpace10,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.text12.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor,
                            ),
                          ),
                        ),
                        if (badge != null) ...[
                          AppSpaces.hSpace6,
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: (badgeColor ?? AppColors.secondary)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              badge,
                              style: AppTextStyles.text10.copyWith(
                                fontWeight: FontWeight.bold,
                                color: badgeColor ?? AppColors.secondary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    AppSpaces.vSpace2,
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.text10.copyWith(
                        color: AppColors.subTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 18.sp,
                color: AppColors.subTextColor.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Core Workspace Tab Item
  Widget _buildTabItem({
    required int tabIndex,
    required IconData icon,
    required String title,
  }) {
    if (!Get.isRegistered<IndexController>()) {
      return const SizedBox.shrink();
    }
    final indexCtrl = Get.find<IndexController>();

    return Obx(() {
      final isSelected = indexCtrl.currentIndex.value == tabIndex;

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            Get.back(); // Close drawer
            indexCtrl.changeTab(tabIndex);
          },
          borderRadius: BorderRadius.circular(10.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18.sp,
                  color: isSelected ? AppColors.primary : AppColors.subTextColor,
                ),
                AppSpaces.hSpace10,
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.text12.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textColor,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 6.r,
                    height: 6.r,
                    decoration: const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildDivider() {
    return Container(
      height: 1.h,
      color: AppColors.borderColor,
    );
  }

  /// Drawer Footer
  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.inputFill.withValues(alpha: 0.3),
        border: Border(
          top: BorderSide(
            color: AppColors.borderColor,
            width: 1.w,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'AMS 2.0 Enterprise',
                    style: AppTextStyles.text10.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  Text(
                    'SoftGenie Solutions',
                    style: AppTextStyles.text10.copyWith(
                      color: AppColors.subTextColor,
                    ),
                  ),
                ],
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Get.back(); // Close drawer
                  if (Get.isRegistered<ProfileController>()) {
                    Get.find<ProfileController>()
                        .showLogoutConfirmation(context);
                  }
                },
                borderRadius: BorderRadius.circular(8.r),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.logout_rounded,
                        size: 16.sp,
                        color: AppColors.error,
                      ),
                      AppSpaces.hSpace4,
                      Text(
                        'Exit',
                        style: AppTextStyles.text12.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
