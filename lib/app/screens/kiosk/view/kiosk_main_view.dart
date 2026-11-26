import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:ams_2/app/core/utils/app_colors.dart';
import 'package:ams_2/app/core/utils/app_spaces.dart';
import 'package:ams_2/app/core/utils/app_text_styles.dart';
import 'package:ams_2/app/core/widgets/custom_button.dart';
import 'package:ams_2/app/core/widgets/custom_card.dart';
import 'package:ams_2/app/core/widgets/custom_text_field.dart';
import 'package:ams_2/app/core/widgets/employee_ambient_header.dart';
import 'package:ams_2/app/core/widgets/network_boundary_wrapper.dart';
import '../controller/kiosk_controller.dart';
import 'components/kiosk_live_punch_card.dart';
// import 'components/kiosk_quick_actions.dart';

class KioskMainView extends GetView<KioskController> {
  const KioskMainView({super.key});

  static const List<String> _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  String _formatTime(DateTime dt) {
    final int h = dt.hour;
    final int hour12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    final String hourStr = hour12.toString().padLeft(2, '0');
    final String minuteStr = dt.minute.toString().padLeft(2, '0');
    final String secondStr = dt.second.toString().padLeft(2, '0');
    final String period = h >= 12 ? 'PM' : 'AM';
    return '$hourStr:$minuteStr:$secondStr $period';
  }

  String _formatDate(DateTime dt) {
    final String dayName = _weekdays[dt.weekday - 1];
    final String monthName = _months[dt.month - 1];
    return '$dayName, ${dt.day} $monthName ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return NetworkBoundaryWrapper(
      allowOffline: true,
      onRetry: controller.loadKioskState,
      child: PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: Stack(
            children: [
              // Signature Curved Ambient Gradient Header matching CompanyDashboardView
              EmployeeAmbientHeader(
                height: 230.h,
                borderRadius: 20.r,
                gradientColors: const [
                  AppColors.primary,
                  AppColors.primary,
                  AppColors.primary,
                  AppColors.primary,
                  AppColors.primary,
                  AppColors.secondary,
                  AppColors.liteSecondary,
                ],
              ),

              SafeArea(
                bottom: false,
                child: Obx(() {
                  if (controller.isLoading.value &&
                      controller.activeKioskConfig.value == null) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: AppColors.secondary,
                      ),
                    );
                  }

                  final session = controller.identifiedSession.value;
                  final isSuccess = controller.showSuccessCard.value;

                  return Column(
                    children: [
                      // 1. Top Station Header on Ambient Gradient
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 8.h,
                        ),
                        child: _buildStationHeader(context),
                      ),

                      // 2. Scrollable Main Content
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: controller.loadKioskState,
                          color: AppColors.secondary,
                          child: SingleChildScrollView(
                            controller: controller.scrollController,
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 6.h,
                            ),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: 580.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Live Digital Clock Floating Card
                                    _buildDigitalClockCard(),

                                    AppSpaces.vSpace14,

                                    // Offline Queue Banner (if any queued punches)
                                    if (controller.offlineQueueCount.value >
                                        0) ...[
                                      _buildOfflineQueueBanner(),
                                      AppSpaces.vSpace14,
                                    ],

                                    // Active Interactive Card
                                    if (isSuccess) ...[
                                      _buildPunchSuccessCard(),
                                    ] else if (session != null) ...[
                                      KioskLivePunchCard(
                                        controller: controller,
                                        session: session,
                                      ),
                                      // AppSpaces.vSpace14,
                                      // KioskQuickActions(controller: controller),
                                    ] else ...[
                                      _buildIdentificationCard(context),
                                    ],

                                    SizedBox(height: 28.h),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // 3. Footer
                      _buildStationFooter(),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _capitalizeFirst(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return trimmed;
    return '${trimmed[0].toUpperCase()}${trimmed.substring(1)}';
  }

  /// Top Header matching CompanyDashboardView executive header style
  Widget _buildStationHeader(BuildContext context) {
    return Obx(() {
      final config = controller.activeKioskConfig.value;
      final rawName = config?.name ?? 'Attendance Terminal';
      final stationName = _capitalizeFirst(
        rawName.isNotEmpty ? rawName : 'Attendance Terminal',
      );
      final locName = config?.locationName ?? 'Worksite Station';

      return Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.25),
              ),
            ),
            child: Icon(
              Icons.tablet_mac_rounded,
              color: AppColors.white,
              size: 22.sp,
            ),
          ),
          AppSpaces.hSpace12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stationName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.text16.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                AppSpaces.vSpace2,
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 13.sp,
                      color: AppColors.liteSecondary,
                    ),
                    AppSpaces.hSpace4,
                    Flexible(
                      child: Text(
                        locName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.text12.copyWith(
                          color: AppColors.litePrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: (controller.isOnline.value
                      ? AppColors.secondary
                      : AppColors.warning)
                  .withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: (controller.isOnline.value
                        ? AppColors.liteSecondary
                        : AppColors.warning)
                    .withValues(alpha: 0.6),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7.r,
                  height: 7.r,
                  decoration: BoxDecoration(
                    color: controller.isOnline.value
                        ? AppColors.liteSecondary
                        : AppColors.warning,
                    shape: BoxShape.circle,
                  ),
                ),
                AppSpaces.hSpace6,
                Text(
                  controller.isOnline.value ? 'ONLINE' : 'OFFLINE',
                  style: AppTextStyles.text10.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
          AppSpaces.hSpace8,
          Material(
            color: AppColors.white.withValues(alpha: 0.14),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: controller.handleHeaderLogout,
              child: Padding(
                padding: EdgeInsets.all(9.r),
                child: Icon(
                  Icons.logout_rounded,
                  color: AppColors.white,
                  size: 20.sp,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  /// Signature Floating Card for Live Digital Clock
  Widget _buildDigitalClockCard() {
    return Obx(() {
      final now = controller.liveClock.value;
      final timeStr = _formatTime(now);
      final dateStr = _formatDate(now);

      return CustomCard(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        borderRadius: 15.r,
        accentColor: AppColors.secondary,
        accentWidth: 3.w,
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.access_time_filled_rounded,
                color: AppColors.secondary,
                size: 24.sp,
              ),
            ),
            AppSpaces.hSpace12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    timeStr,
                    style: AppTextStyles.text24.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textColor,
                      letterSpacing: 0.8,
                    ),
                  ),
                  AppSpaces.vSpace2,
                  Text(
                    dateStr,
                    style: AppTextStyles.text12.copyWith(
                      color: AppColors.subTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  /// Offline Queue Banner with Sync Button
  Widget _buildOfflineQueueBanner() {
    return Obx(() {
      final count = controller.offlineQueueCount.value;
      final syncing = controller.isSyncingOffline.value;

      return CustomCard(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        borderRadius: 15.r,
        accentColor: AppColors.warning,
        accentWidth: 3.w,
        child: Row(
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              color: AppColors.warning,
              size: 20.sp,
            ),
            AppSpaces.hSpace10,
            Expanded(
              child: Text(
                '$count offline punch${count == 1 ? '' : 'es'} queued for sync',
                style: AppTextStyles.text12.copyWith(
                  color: AppColors.textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: syncing ? null : controller.syncOfflinePunches,
              child: syncing
                  ? SizedBox(
                      width: 16.r,
                      height: 16.r,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.w,
                        color: AppColors.secondary,
                      ),
                    )
                  : Text(
                      'Sync Now',
                      style: AppTextStyles.text12.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      );
    });
  }

  /// State 1: Idle Identification Card (QR Badge Only)
  Widget _buildIdentificationCard(BuildContext context) {
    return Obx(() {
      return CustomCard(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        borderRadius: 15.r,
        accentColor: AppColors.secondary,
        accentWidth: 3.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(9.r),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.qr_code_scanner_rounded,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                ),
                AppSpaces.hSpace10,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Employee Identification',
                        style: AppTextStyles.text16.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                      AppSpaces.vSpace2,
                      Text(
                        'Scan your digital QR badge to punch attendance',
                        style: AppTextStyles.text12.copyWith(
                          color: AppColors.subTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            AppSpaces.vSpace16,

            // Error Message Banner
            if (controller.idErrorMessage.value.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: AppColors.error,
                      size: 18.sp,
                    ),
                    AppSpaces.hSpace8,
                    Expanded(
                      child: Text(
                        controller.idErrorMessage.value,
                        style: AppTextStyles.text12.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AppSpaces.vSpace14,
            ],

            // QR Badge Scanner Action
            Center(
              child: Column(
                children: [
                  Container(
                    height: 150.h,
                    width: 150.h,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundColor,
                      borderRadius: BorderRadius.circular(15.r),
                      border: Border.all(
                        color: AppColors.secondary,
                        width: 2.w,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.qr_code_2_rounded,
                          size: 64.sp,
                          color: AppColors.primary,
                        ),
                        AppSpaces.vSpace8,
                        Text(
                          'Tap below to scan',
                          style: AppTextStyles.text12.copyWith(
                            color: AppColors.subTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSpaces.vSpace14,
                  CustomButton(
                    text: 'Scan QR Badge',
                    isGradient: true,
                    isLoading: controller.isSubmitting.value,
                    icon: Icon(
                      Icons.qr_code_scanner_rounded,
                      size: 20.sp,
                      color: AppColors.white,
                    ),
                    onPressed: controller.isSubmitting.value
                        ? null
                        : controller.scanQrBadgeAndIdentify,
                  ),
                  AppSpaces.vSpace6,
                  TextButton(
                    onPressed: controller.isSubmitting.value
                        ? null
                        : () => _showManualBadgePrompt(context),
                    child: Text(
                      'Enter Badge Code Manually',
                      style: AppTextStyles.text12.copyWith(
                        color: AppColors.subTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  /// State 3: Punch Success Confirmation Card
  Widget _buildPunchSuccessCard() {
    return Obx(() {
      final punch = controller.lastPunchResult.value;
      final role = punch?.role ?? 'Attendance Punch';
      final time = punch?.time ?? _formatTime(DateTime.now());
      final name = punch?.personName ?? 'Employee';

      return CustomCard(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 20.h),
        borderRadius: 15.r,
        accentColor: AppColors.success,
        accentWidth: 3.w,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 52.sp,
              ),
            ),
            AppSpaces.vSpace14,
            Text(
              'Punch Recorded Successfully',
              textAlign: TextAlign.center,
              style: AppTextStyles.text18.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            AppSpaces.vSpace6,
            Text(
              '$role • $time',
              style: AppTextStyles.text14.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.secondary,
              ),
            ),
            AppSpaces.vSpace4,
            Text(
              'Recorded for $name',
              style: AppTextStyles.text12.copyWith(
                color: AppColors.subTextColor,
              ),
            ),
            AppSpaces.vSpace18,
            CustomButton(
              text: 'Done (Next Employee)',
              isGradient: true,
              onPressed: controller.resetToMainScreen,
            ),
            AppSpaces.vSpace10,
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.secondary,
                  side: BorderSide(
                    color: AppColors.secondary.withValues(alpha: 0.5),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                icon: Icon(
                  Icons.refresh_rounded,
                  size: 18.sp,
                  color: AppColors.secondary,
                ),
                label: Text(
                  'Continue (Break / Check Out)',
                  style: AppTextStyles.text14.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: controller.isSubmitting.value
                    ? null
                    : controller.continueAfterPunch,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStationFooter() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Text(
        'AMS 2 Enterprise Kiosk Terminal • v2.0.0',
        style: AppTextStyles.text10.copyWith(color: AppColors.subTextColor),
      ),
    );
  }

  void _showManualBadgePrompt(BuildContext context) {
    final TextEditingController badgeInputController = TextEditingController();

    Get.dialog(
      Dialog(
        backgroundColor: AppColors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 420.w),
          child: CustomCard(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
            borderRadius: 15.r,
            accentColor: AppColors.secondary,
            accentWidth: 3.w,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(9.r),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.qr_code_scanner_rounded,
                        color: AppColors.secondary,
                        size: 20.sp,
                      ),
                    ),
                    AppSpaces.hSpace10,
                    Expanded(
                      child: Text(
                        'Scan / Enter Badge Value',
                        style: AppTextStyles.text16.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(
                        Icons.close_rounded,
                        color: AppColors.subTextColor,
                        size: 20.sp,
                      ),
                    ),
                  ],
                ),
                AppSpaces.vSpace8,
                Text(
                  'Input the QR badge code as scanned from the employee digital ID card.',
                  style: AppTextStyles.text12.copyWith(
                    color: AppColors.subTextColor,
                  ),
                ),
                AppSpaces.vSpace12,
                CustomTextField(
                  controller: badgeInputController,
                  hintText: 'Badge Code (e.g. 01jb2x9k4m7q8r3t5v6w8y0z1a)',
                  prefixIcon: Icon(
                    Icons.qr_code_rounded,
                    size: 20.sp,
                    color: AppColors.subTextColor,
                  ),
                ),
                AppSpaces.vSpace16,
                CustomButton(
                  text: 'Identify',
                  isGradient: true,
                  onPressed: () {
                    final code = badgeInputController.text.trim();
                    Get.back();
                    if (code.isNotEmpty) {
                      controller.identifyViaBadge(code);
                    }
                  },
                ),
                AppSpaces.vSpace6,
                Center(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'Cancel',
                      style: AppTextStyles.text12.copyWith(
                        color: AppColors.subTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).whenComplete(badgeInputController.dispose);
  }
}
