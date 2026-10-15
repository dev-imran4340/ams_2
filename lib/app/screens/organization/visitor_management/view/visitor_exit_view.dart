import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/network_boundary_wrapper.dart';
import '../controller/visitor_controller.dart';
import '../model/visitor_model.dart';

class VisitorExitView extends GetView<VisitorController> {
  const VisitorExitView({super.key});

  @override
  Widget build(BuildContext context) {
    final exitAccent = AppColors.warning;

    return NetworkBoundaryWrapper(
      onRetry: controller.loadActiveVisitors,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Obx(
          () => Stack(
            children: [
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Executive Curved Header with Real-Time Clock Pill
                    _buildHeader(context, exitAccent),

                    // 2. Overlapping Interactive Body Content
                    Transform.translate(
                      offset: Offset(0, -32.h),
                      child: Padding(
                        padding: AppSpaces.horizontalPadding,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Step Indicator (Select -> Verify -> Exit)
                            _buildStepIndicator(exitAccent),

                            AppSpaces.vSpace16,

                            // Hint Banner
                            _buildHintBanner(exitAccent),

                            AppSpaces.vSpace16,

                            // Section Card 1: Active Visitors Carousel
                            _buildSectionCard(
                              title: 'Active visitors',
                              subtitle: 'Tap a visitor to verify identity and check out',
                              icon: Icons.people_outline_rounded,
                              accentColor: exitAccent,
                              trailing: _buildRefreshButton(),
                              child: _buildVisitorsCarousel(exitAccent),
                            ),

                            // Selected Visitor & Exit Form (Unlocked after Selection)
                            if (controller.selectedVisitor.value != null) ...[
                              AppSpaces.vSpace16,
                              _buildSelectedBanner(),
                              AppSpaces.vSpace16,
                              _buildSectionCard(
                                title: 'Exit details',
                                subtitle: 'Confirm departure time and optional remarks',
                                icon: Icons.edit_note_rounded,
                                accentColor: AppColors.primary,
                                child: _buildExitForm(),
                              ),
                              AppSpaces.vSpace20,
                              _buildSubmitButton(),
                            ],
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 28.h),
                  ],
                ),
              ),

              // Full-Screen Preparing Face Verification Overlay
              if (controller.preparingVisitorId.value != null)
                _buildLoadingOverlay(exitAccent),
            ],
          ),
        ),
      ),
    );
  }

  /// Executive Curved Header with Back Pill and Live Clock
  Widget _buildHeader(BuildContext context, Color exitAccent) {
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
          Positioned(
            top: -40.r,
            right: -30.r,
            child: Container(
              width: 140.r,
              height: 140.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 52.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Back Button & Terminal Pill
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
                                  'Visitor Desk',
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
                        child: Text(
                          'CHECK-OUT DESK',
                          style: AppTextStyles.text8.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),

                  AppSpaces.vSpace16,

                  // Desk Identity
                  Row(
                    children: [
                      Container(
                        width: 48.r,
                        height: 48.r,
                        decoration: BoxDecoration(
                          color: exitAccent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: exitAccent.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Icon(
                          Icons.logout_rounded,
                          color: AppColors.white,
                          size: 24.sp,
                        ),
                      ),
                      AppSpaces.hSpace14,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Check-out desk',
                              style: AppTextStyles.text12.copyWith(
                                color: AppColors.litePrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            AppSpaces.vSpace2,
                            Text(
                              'Verify & mark departure',
                              style: AppTextStyles.text20.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  AppSpaces.vSpace12,

                  // Live Ticking Clock Pill
                  const _CurrentTimePillWidget(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Step Indicator matching smart_attendance Select -> Verify -> Exit
  Widget _buildStepIndicator(Color exitAccent) {
    return Obx(() {
      final hasSelection = controller.selectedVisitor.value != null;
      final isVerifying = controller.preparingVisitorId.value != null;

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(
            color: AppColors.borderColor.withValues(alpha: 0.7),
            width: 1.w,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.04),
              blurRadius: 10.r,
              offset: Offset(0, 3.h),
            ),
          ],
        ),
        child: Row(
          children: [
            _ExitStepChip(
              label: 'Select',
              icon: Icons.person_search_rounded,
              isActive: !hasSelection && !isVerifying,
              isDone: hasSelection || isVerifying,
              accent: exitAccent,
            ),
            Expanded(
              child: Container(
                height: 2.h,
                margin: EdgeInsets.symmetric(horizontal: 8.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      (hasSelection || isVerifying)
                          ? exitAccent
                          : AppColors.borderColor.withValues(alpha: 0.8),
                      hasSelection
                          ? AppColors.success
                          : AppColors.borderColor.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            _ExitStepChip(
              label: 'Verify',
              icon: Icons.face_retouching_natural_rounded,
              isActive: isVerifying,
              isDone: hasSelection,
              accent: exitAccent,
            ),
            Expanded(
              child: Container(
                height: 2.h,
                margin: EdgeInsets.symmetric(horizontal: 8.w),
                color: hasSelection
                    ? AppColors.success
                    : AppColors.borderColor.withValues(alpha: 0.8),
              ),
            ),
            _ExitStepChip(
              label: 'Exit',
              icon: Icons.check_circle_outline_rounded,
              isActive: hasSelection && !controller.isSubmittingExit.value,
              isDone: false,
              accent: AppColors.success,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildHintBanner(Color exitAccent) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: exitAccent.withValues(alpha: 0.3),
          width: 1.w,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.touch_app_rounded, size: 18.sp, color: exitAccent),
          AppSpaces.hSpace10,
          Expanded(
            child: Text(
              'Select a visitor below. Face verification will open automatically to confirm identity before checkout.',
              style: AppTextStyles.text12.copyWith(
                color: AppColors.subTextColor,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRefreshButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: controller.isLoadingVisitors.value
            ? null
            : controller.loadActiveVisitors,
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          padding: EdgeInsets.all(7.r),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: controller.isLoadingVisitors.value
              ? SizedBox(
                  width: 16.r,
                  height: 16.r,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.w,
                    color: AppColors.primary,
                  ),
                )
              : Icon(
                  Icons.refresh_rounded,
                  size: 18.sp,
                  color: AppColors.primary,
                ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.22),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.08),
            blurRadius: 14.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.cardBackground,
                  accentColor.withValues(alpha: 0.08),
                ],
              ),
              border: Border(
                bottom: BorderSide(color: AppColors.borderColor, width: 1.w),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(icon, color: accentColor, size: 18.sp),
                ),
                AppSpaces.hSpace10,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: AppTextStyles.text16.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                            ),
                          ),
                          if (!controller.isLoadingVisitors.value &&
                              controller.activeVisitors.isNotEmpty)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                '${controller.activeVisitors.length}',
                                style: AppTextStyles.text10.copyWith(
                                  color: accentColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      AppSpaces.vSpace2,
                      Text(
                        subtitle,
                        style: AppTextStyles.text12.copyWith(
                          color: AppColors.subTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailing != null) ...[AppSpaces.hSpace8, trailing],
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
            child: child,
          ),
          Container(height: 3.h, color: accentColor),
        ],
      ),
    );
  }

  /// Horizontal Active Visitors Carousel
  Widget _buildVisitorsCarousel(Color exitAccent) {
    if (controller.isLoadingVisitors.value) {
      return SizedBox(
        height: 180.h,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(strokeWidth: 2.5.w, color: exitAccent),
              AppSpaces.vSpace12,
              Text(
                'Loading active visitors...',
                style: AppTextStyles.text12.copyWith(
                  color: AppColors.subTextColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (controller.activeVisitors.isEmpty) {
      return Container(
        height: 180.h,
        alignment: Alignment.center,
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_outline_rounded,
                size: 32.sp,
                color: AppColors.subTextColor,
              ),
            ),
            AppSpaces.vSpace10,
            Text(
              'No active visitors',
              style: AppTextStyles.text14.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            AppSpaces.vSpace4,
            Text(
              'All visitors have checked out or none checked in today.',
              style: AppTextStyles.text12.copyWith(
                color: AppColors.subTextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 195.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: controller.activeVisitors.length,
        separatorBuilder: (_, _) => AppSpaces.hSpace12,
        itemBuilder: (context, index) {
          final visitor = controller.activeVisitors[index];
          return _buildVisitorCard(visitor, exitAccent);
        },
      ),
    );
  }

  Widget _buildVisitorCard(VisitorModel visitor, Color exitAccent) {
    final selectedVisitor = controller.selectedVisitor.value;
    final isSelected =
        selectedVisitor != null && selectedVisitor.id == visitor.id;
    final isPreparing = controller.preparingVisitorId.value == visitor.id;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: controller.preparingVisitorId.value != null
            ? null
            : () => controller.startVisitorFaceVerification(visitor),
        borderRadius: BorderRadius.circular(14.r),
        child: Stack(
          children: [
            Container(
              width: 142.w,
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? exitAccent.withValues(alpha: 0.08)
                    : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: isSelected ? exitAccent : AppColors.borderColor,
                  width: isSelected ? 2.w : 1.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? exitAccent.withValues(alpha: 0.15)
                        : Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10.r,
                    offset: Offset(0, 3.h),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Avatar with Verified Badge
                  Stack(
                    children: [
                      Container(
                        width: 68.r,
                        height: 68.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? exitAccent
                                : AppColors.primary.withValues(alpha: 0.2),
                            width: 2.w,
                          ),
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.accentNavy],
                          ),
                        ),
                        child: Icon(
                          Icons.person_rounded,
                          size: 36.sp,
                          color: AppColors.white,
                        ),
                      ),
                      if (isSelected)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(3.r),
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.cardBackground,
                                width: 2.w,
                              ),
                            ),
                            child: Icon(
                              Icons.check_rounded,
                              color: AppColors.white,
                              size: 11.sp,
                            ),
                          ),
                        ),
                    ],
                  ),

                  AppSpaces.vSpace10,

                  // Visitor Name
                  Text(
                    visitor.fullName,
                    style: AppTextStyles.text12.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? exitAccent : AppColors.textColor,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  AppSpaces.vSpace6,

                  // Check-In Time Pill
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      'In ${visitor.formattedCheckInTime}',
                      style: AppTextStyles.text10.copyWith(
                        color: AppColors.subTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // In-Card Preparing Overlay
            if (isPreparing)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 22.r,
                        height: 22.r,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5.w,
                          color: exitAccent,
                        ),
                      ),
                      AppSpaces.vSpace8,
                      Text(
                        'Verifying...',
                        style: AppTextStyles.text12.copyWith(
                          color: exitAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Banner displayed when visitor is verified
  Widget _buildSelectedBanner() {
    final selectedVisitor = controller.selectedVisitor.value;
    if (selectedVisitor == null) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.4),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withValues(alpha: 0.08),
            blurRadius: 10.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.verified_rounded,
              color: AppColors.success,
              size: 20.sp,
            ),
          ),
          AppSpaces.hSpace12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Identity verified',
                  style: AppTextStyles.text12.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
                AppSpaces.vSpace2,
                Text(
                  '${selectedVisitor.fullName} (${selectedVisitor.id})',
                  style: AppTextStyles.text14.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                AppSpaces.vSpace2,
                Text(
                  'Host: ${selectedVisitor.hostEmployee}',
                  style: AppTextStyles.text12.copyWith(
                    color: AppColors.subTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Exit Details Form
  Widget _buildExitForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomTextField(
          controller: controller.exitTimeController,
          labelText: 'Exit time',
          hintText: 'Select exit date and time',
          readOnly: true,
          onTap: controller.selectExitDateTime,
          prefixIcon: Icon(
            Icons.access_time_rounded,
            color: AppColors.primary,
            size: 20.sp,
          ),
          suffixIcon: Icon(
            Icons.calendar_today_rounded,
            color: AppColors.secondary,
            size: 18.sp,
          ),
        ),

        AppSpaces.vSpace14,

        CustomTextField(
          controller: controller.exitRemarksController,
          labelText: 'Remarks (optional)',
          hintText: 'Any departure remarks or pass return notes...',
          maxLines: 3,
          prefixIcon: Icon(
            Icons.edit_note_rounded,
            color: AppColors.primary,
            size: 20.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Obx(
      () => CustomButton(
        text: 'Mark exit',
        icon: Icon(Icons.logout_rounded, size: 18.sp, color: AppColors.white),
        isGradient: true,
        isLoading: controller.isSubmittingExit.value,
        onPressed: controller.isSubmittingExit.value
            ? null
            : controller.submitExit,
      ),
    );
  }

  Widget _buildLoadingOverlay(Color exitAccent) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.45),
        child: Center(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 36.w),
            padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 24.h),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(18.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 24.r,
                  offset: Offset(0, 8.h),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 32.r,
                  height: 32.r,
                  child: CircularProgressIndicator(
                    strokeWidth: 3.w,
                    color: exitAccent,
                  ),
                ),
                AppSpaces.vSpace16,
                Text(
                  'Preparing face verification',
                  style: AppTextStyles.text14.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                AppSpaces.vSpace4,
                Text(
                  'Matching visitor profile with intake record...',
                  style: AppTextStyles.text12.copyWith(
                    color: AppColors.subTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CurrentTimePillWidget extends StatelessWidget {
  const _CurrentTimePillWidget();

  static String _format(DateTime now) {
    final day = now.day.toString().padLeft(2, '0');
    final month = now.month.toString().padLeft(2, '0');
    final year = now.year;
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    final second = now.second.toString().padLeft(2, '0');
    return '$day/$month/$year, $hour:$minute:$second';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.2),
          width: 1.w,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule_rounded,
            size: 14.sp,
            color: AppColors.litePrimary,
          ),
          AppSpaces.hSpace6,
          StreamBuilder<DateTime>(
            stream: Stream<DateTime>.periodic(
              const Duration(seconds: 1),
              (_) => DateTime.now(),
            ),
            initialData: DateTime.now(),
            builder: (context, snapshot) {
              return Text(
                _format(snapshot.data ?? DateTime.now()),
                style: AppTextStyles.text12.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ExitStepChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final bool isDone;
  final Color accent;

  const _ExitStepChip({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.isDone,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDone
        ? AppColors.success
        : (isActive ? accent : AppColors.subTextColor.withValues(alpha: 0.55));

    return Column(
      children: [
        Container(
          width: 32.r,
          height: 32.r,
          decoration: BoxDecoration(
            color: (isActive || isDone)
                ? color.withValues(alpha: 0.12)
                : AppColors.borderColor.withValues(alpha: 0.3),
            shape: BoxShape.circle,
            border: Border.all(
              color: (isActive || isDone)
                  ? color.withValues(alpha: 0.45)
                  : AppColors.borderColor,
              width: 1.5.w,
            ),
          ),
          child: Icon(
            isDone ? Icons.check_rounded : icon,
            size: 15.sp,
            color: color,
          ),
        ),
        AppSpaces.vSpace4,
        Text(
          label,
          style: AppTextStyles.text10.copyWith(
            color: color,
            fontWeight: isActive || isDone ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
