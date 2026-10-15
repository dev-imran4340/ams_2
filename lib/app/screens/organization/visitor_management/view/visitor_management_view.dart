import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/network_boundary_wrapper.dart';
import '../../../../routes/app_routes.dart';
import '../controller/visitor_controller.dart';

class VisitorManagementView extends GetView<VisitorController> {
  const VisitorManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkBoundaryWrapper(
      onRetry: controller.loadData,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Curved Primary Corporate Navy Gradient Header
              _buildHeader(context),

              // 2. Overlapping Interactive Body Content
              Transform.translate(
                offset: Offset(0, -32.h),
                child: Padding(
                  padding: AppSpaces.horizontalPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Reception Workflow Banner
                      _buildInfoBanner(context),

                      AppSpaces.vSpace20,

                      // Section Title
                      Text(
                        'Choose action',
                        style: AppTextStyles.text18.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                      AppSpaces.vSpace4,
                      Text(
                        'Select whether the visitor is arriving or leaving',
                        style: AppTextStyles.text12.copyWith(
                          color: AppColors.subTextColor,
                        ),
                      ),

                      AppSpaces.vSpace16,

                      // Action Card 1: Entry
                      _VisitorActionCard(
                        title: 'Entry',
                        subtitle:
                            'Register check-in with visitor details and photo',
                        icon: Icons.login_rounded,
                        accent: AppColors.primary,
                        badge: 'Check in',
                        onTap: () => Get.toNamed(Routes.VISITOR_ENTRY),
                      ),

                      AppSpaces.vSpace14,

                      // Action Card 2: Exit
                      _VisitorActionCard(
                        title: 'Exit',
                        subtitle:
                            'Find active visitors and mark their departure',
                        icon: Icons.logout_rounded,
                        accent: AppColors.warning,
                        badge: 'Check out',
                        onTap: () => Get.toNamed(Routes.VISITOR_EXIT),
                      ),

                      AppSpaces.vSpace24,

                      // Quick Workflow Guide
                      _buildQuickGuide(context),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  /// Executive Curved Header with Back Glass Pill, Titles, Ambient Circles
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary,
            AppColors.primary,
            AppColors.secondary,
          ],

          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(18.r),
          bottomRight: Radius.circular(18.r),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 18.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Ambient Decorative Circle 1 (Top-Right)
          Positioned(
            top: -40.r,
            right: -30.r,
            child: Container(
              width: 150.r,
              height: 150.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white.withValues(alpha: 0.05),
              ),
            ),
          ),

          // Ambient Decorative Circle 2 (Bottom-Left)
          Positioned(
            bottom: 20.r,
            left: -40.r,
            child: Container(
              width: 140.r,
              height: 140.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withValues(alpha: 0.05),
              ),
            ),
          ),

          // Header Foreground Content
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 52.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Back Glass Pill & Station Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back Glass Pill Button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Get.back(),
                          borderRadius: BorderRadius.circular(20.r),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: AppColors.white.withValues(alpha: 0.25),
                                width: 1.w,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  size: 13.sp,
                                  color: AppColors.white,
                                ),
                                AppSpaces.hSpace4,
                                Text(
                                  'Back',
                                  style: AppTextStyles.text12.copyWith(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Station Badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: AppColors.white.withValues(alpha: 0.2),
                            width: 1.w,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6.r,
                              height: 6.r,
                              decoration: const BoxDecoration(
                                color: AppColors.successMint,
                                shape: BoxShape.circle,
                              ),
                            ),
                            AppSpaces.hSpace4,
                            Text(
                              'KIOSK STATION 01',
                              style: AppTextStyles.text8.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  AppSpaces.vSpace16,

                  // Desk Identity Section (Icon + Titles)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 58.r,
                        height: 58.r,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.white.withValues(alpha: 0.2),
                              AppColors.secondary.withValues(alpha: 0.25),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: AppColors.white.withValues(alpha: 0.25),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              blurRadius: 10.r,
                              offset: Offset(0, 4.h),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.groups_rounded,
                          size: 28.sp,
                          color: AppColors.white,
                        ),
                      ),
                      AppSpaces.hSpace14,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Visitor desk',
                              style: AppTextStyles.text12.copyWith(
                                color: AppColors.litePrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            AppSpaces.vSpace2,
                            Text(
                              'Manage arrivals & departures',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.text20.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                                height: 1.15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Reception Workflow Information Banner
  Widget _buildInfoBanner(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(15.r),
        border: Border(
          bottom: BorderSide(color: AppColors.primary, width: 2.w),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 14.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(14.r),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(9.r),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.info_outline_rounded,
                color: AppColors.primary,
                size: 20.sp,
              ),
            ),
            AppSpaces.hSpace12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reception workflow',
                    style: AppTextStyles.text14.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppSpaces.vSpace4,
                  Text(
                    'Use Entry for new visitors. Use Exit when a visitor is leaving and their session should be closed.',
                    style: AppTextStyles.text12.copyWith(
                      color: AppColors.subTextColor,
                      height: 1.45,
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

  /// Horizontal Quick Guide Flow (Entry ---> Exit)
  Widget _buildQuickGuide(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(
          color: AppColors.borderColor.withValues(alpha: 0.8),
          width: 1.w,
        ),
      ),
      child: Row(
        children: [
          _GuideStep(
            icon: Icons.login_rounded,
            label: 'Entry',
            color: AppColors.primary,
          ),
          Expanded(
            child: Container(
              height: 2.h,
              margin: EdgeInsets.symmetric(horizontal: 10.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.4),
                    AppColors.warning.withValues(alpha: 0.4),
                  ],
                ),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          _GuideStep(
            icon: Icons.logout_rounded,
            label: 'Exit',
            color: AppColors.warning,
          ),
        ],
      ),
    );
  }
}

class _GuideStep extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _GuideStep({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16.sp, color: color),
        ),
        AppSpaces.vSpace6,
        Text(
          label,
          style: AppTextStyles.text12.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _VisitorActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final String badge;
  final VoidCallback onTap;

  const _VisitorActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardBackground,
      borderRadius: BorderRadius.circular(15.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15.r),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(
              color: accent.withValues(alpha: 0.25),
              width: 1.2.w,
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.08),
                blurRadius: 14.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
                child: Row(
                  children: [
                    // Icon Box
                    Container(
                      width: 50.r,
                      height: 50.r,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [accent.withValues(alpha: 0.85), accent],
                        ),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Icon(icon, color: AppColors.white, size: 24.sp),
                    ),
                    AppSpaces.hSpace14,
                    // Titles and Badge
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                title,
                                style: AppTextStyles.text16.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textColor,
                                ),
                              ),
                              AppSpaces.hSpace8,
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 3.h,
                                ),
                                decoration: BoxDecoration(
                                  color: accent.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Text(
                                  badge,
                                  style: AppTextStyles.text10.copyWith(
                                    color: accent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          AppSpaces.vSpace4,
                          Text(
                            subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.text12.copyWith(
                              color: AppColors.subTextColor,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppSpaces.hSpace8,
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 15.sp,
                      color: accent,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
