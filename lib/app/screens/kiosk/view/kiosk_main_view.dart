import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:ams_2/app/core/utils/app_colors.dart';
import 'package:ams_2/app/core/utils/app_spaces.dart';
import 'package:ams_2/app/core/utils/app_text_styles.dart';
import 'package:ams_2/app/core/widgets/custom_button.dart';
import 'package:ams_2/app/core/widgets/custom_text_field.dart';
import 'package:ams_2/app/routes/app_routes.dart';
import '../controller/kiosk_controller.dart';
import '../model/kiosk_model.dart';

class KioskMainView extends GetView<KioskController> {
  const KioskMainView({super.key});

  static const List<String> _weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  static const List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
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
    return PopScope(
      canPop: false, // Prevents Android back button from popping kiosk station
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _showAdminExitDialog(context);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF011A29), // Deep Corporate Navy
        body: SafeArea(
          child: Obx(() {
            final session = controller.identifiedSession.value;
            final isSuccess = controller.showSuccessCard.value;

            return Column(
              children: [
                // 1. Tablet Header (Station Telemetry & Exit Lock)
                _buildStationHeader(context),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 580.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 2. High-Visibility Digital Clock & Calendar
                            _buildDigitalClock(),

                            AppSpaces.vSpace20,

                            // 3. Dynamic Interactive State
                            if (isSuccess) ...[
                              _buildPunchSuccessCard(),
                            ] else if (session != null) ...[
                              _buildIdentifiedActionCard(session),
                            ] else ...[
                              _buildIdentificationCard(context),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // 4. Station Footer
                _buildStationFooter(context),
              ],
            );
          }),
        ),
      ),
    );
  }

  /// Top Bar: Branding, Location, Online Badge & Admin Exit Lock
  Widget _buildStationHeader(BuildContext context) {
    return Obx(() {
      final config = controller.activeKioskConfig.value;
      final stationName = config?.name ?? 'Attendance Terminal';
      final locName = config?.locationName ?? 'Worksite Station';

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.85),
          border: Border(bottom: BorderSide(color: AppColors.secondary, width: 2.w)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(Icons.tablet_mac_rounded, color: AppColors.secondary, size: 22.sp),
            ),
            AppSpaces.hSpace12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stationName,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                  Text(
                    locName,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.litePrimary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(color: Colors.tealAccent.shade400),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7.r,
                    height: 7.r,
                    decoration: const BoxDecoration(
                      color: Colors.tealAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  AppSpaces.hSpace6,
                  Text(
                    'ONLINE',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.tealAccent,
                    ),
                  ),
                ],
              ),
            ),
            AppSpaces.hSpace10,
            IconButton(
              icon: Icon(Icons.admin_panel_settings_outlined, color: Colors.white70, size: 22.sp),
              tooltip: 'Admin Settings',
              onPressed: () => _showAdminExitDialog(context),
            ),
          ],
        ),
      );
    });
  }

  /// Digital Clock Card
  Widget _buildDigitalClock() {
    return Obx(() {
      final now = controller.liveClock.value;
      final timeStr = _formatTime(now);
      final dateStr = _formatDate(now);

      return Column(
        children: [
          Text(
            timeStr,
            style: TextStyle(
              fontSize: 38.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 1.5,
              fontFamily: 'monospace',
            ),
          ),
          AppSpaces.vSpace4,
          Text(
            dateStr,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.liteSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      );
    });
  }

  /// State 1: Idle Identification Form (PIN Entry & QR Badge)
  Widget _buildIdentificationCard(BuildContext context) {
    return Obx(() {
      final config = controller.activeKioskConfig.value;
      final pinAllowed = config?.pinAllowed ?? true;
      final mode = controller.identifyMode.value;

      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: const Color(0xFF022A40),
          borderRadius: BorderRadius.circular(18.r),
          border: Border(
            bottom: BorderSide(color: AppColors.secondary, width: 3.w),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              'Employee Attendance Identification',
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            AppSpaces.vSpace4,
            Text(
              'Scan your digital QR badge or enter your employee PIN',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.litePrimary,
              ),
            ),

            AppSpaces.vSpace16,

            // Identification Mode Switcher
            Row(
              children: [
                Expanded(
                  child: _buildModeTab(
                    title: 'Employee PIN',
                    icon: Icons.pin_outlined,
                    isSelected: mode == 'pin',
                    onTap: () {
                      controller.identifyMode.value = 'pin';
                      controller.idErrorMessage.value = '';
                    },
                  ),
                ),
                AppSpaces.hSpace10,
                Expanded(
                  child: _buildModeTab(
                    title: 'QR Badge',
                    icon: Icons.qr_code_scanner_rounded,
                    isSelected: mode == 'qr',
                    onTap: () {
                      controller.identifyMode.value = 'qr';
                      controller.idErrorMessage.value = '';
                    },
                  ),
                ),
              ],
            ),

            AppSpaces.vSpace18,

            // Error Message Display
            if (controller.idErrorMessage.value.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: Colors.red.shade900.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: Colors.red.shade400),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded, color: Colors.red.shade300, size: 18.sp),
                    AppSpaces.hSpace8,
                    Expanded(
                      child: Text(
                        controller.idErrorMessage.value,
                        style: TextStyle(color: Colors.red.shade200, fontSize: 12.sp),
                      ),
                    ),
                  ],
                ),
              ),
              AppSpaces.vSpace14,
            ],

            // Body: PIN Mode vs QR Mode
            if (mode == 'pin') ...[
              if (!pinAllowed) ...[
                Container(
                  padding: EdgeInsets.all(14.r),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade900.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: Colors.amber.shade400),
                  ),
                  child: Text(
                    'PIN entry is disabled for this worksite. Please use your QR badge.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.amber.shade200, fontSize: 13.sp),
                  ),
                ),
              ] else ...[
                Form(
                  key: controller.clockInFormKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: controller.empNumController,
                        focusNode: controller.empNumFocusNode,
                        hintText: 'Employee Number (e.g. EMP-0001)',
                        prefixIcon: Icon(Icons.badge_outlined, size: 20.sp, color: AppColors.subTextColor),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter your employee number';
                          }
                          return null;
                        },
                      ),
                      AppSpaces.vSpace12,
                      CustomTextField(
                        controller: controller.terminalPinController,
                        focusNode: controller.terminalPinFocusNode,
                        hintText: '4-6 Digit Kiosk PIN',
                        prefixIcon: Icon(Icons.password_rounded, size: 20.sp, color: AppColors.subTextColor),
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter your kiosk PIN';
                          }
                          return null;
                        },
                      ),
                      AppSpaces.vSpace16,
                      CustomButton(
                        text: 'Identify & Continue',
                        isGradient: true,
                        isLoading: controller.isSubmitting.value,
                        icon: Icon(Icons.arrow_forward_rounded, size: 20.sp, color: Colors.white),
                        onPressed: controller.identifyViaEmployeeNumberAndPin,
                      ),
                    ],
                  ),
                ),
              ],
            ] else ...[
              // QR Badge Scanner Option
              Column(
                children: [
                  Container(
                    height: 160.h,
                    width: 160.h,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: AppColors.secondary, width: 2.w),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.qr_code_2_rounded,
                            size: 64.sp,
                            color: AppColors.liteSecondary,
                          ),
                          AppSpaces.vSpace8,
                          Text(
                            'Align QR Badge in view',
                            style: TextStyle(fontSize: 11.sp, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                  AppSpaces.vSpace14,
                  CustomButton(
                    text: 'Scan Badge / Test Verification',
                    isGradient: true,
                    isLoading: controller.isSubmitting.value,
                    icon: Icon(Icons.camera_alt_outlined, size: 20.sp, color: Colors.white),
                    onPressed: () {
                      _showManualBadgePrompt(context);
                    },
                  ),
                ],
              ),
            ],
          ],
        ),
      );
    });
  }

  /// State 2: Employee Identified Session (Allowed Actions & Face Check)
  Widget _buildIdentifiedActionCard(KioskIdentifyResponseModel session) {
    return Obx(() {
      final reqFace = controller.isFaceVerificationRequired.value;
      final isFaceOk = controller.isFaceVerified.value;
      final countdown = controller.ticketCountdown.value;
      final allowed = session.allowedActions;

      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: const Color(0xFF022A40),
          borderRadius: BorderRadius.circular(18.r),
          border: Border(
            bottom: BorderSide(color: AppColors.secondary, width: 3.w),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            // Welcome Header
            Row(
              children: [
                CircleAvatar(
                  radius: 24.r,
                  backgroundColor: AppColors.secondary,
                  child: Text(
                    session.person.name.isNotEmpty ? session.person.name[0] : 'E',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                AppSpaces.hSpace12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.person.name,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'ID: ${session.person.employeeNumber} • ${session.person.department ?? "Staff"}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.litePrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: countdown < 30 ? Colors.red.shade900 : Colors.black45,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: countdown < 30 ? Colors.redAccent : AppColors.secondary,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 14.sp,
                        color: countdown < 30 ? Colors.redAccent : AppColors.liteSecondary,
                      ),
                      AppSpaces.hSpace4,
                      Text(
                        '${countdown}s',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: countdown < 30 ? Colors.redAccent : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            AppSpaces.vSpace16,
            Divider(color: Colors.white24, height: 1),
            AppSpaces.vSpace16,

            // Face Verification Step (if required)
            if (reqFace && !isFaceOk) ...[
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: Colors.orange.shade900.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.orange.shade400),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.face_retouching_natural_rounded, color: Colors.orange.shade300),
                        AppSpaces.hSpace10,
                        Expanded(
                          child: Text(
                            'Facial Verification Required',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    AppSpaces.vSpace8,
                    Text(
                      'This workplace requires facial matching before recording your punch.',
                      style: TextStyle(fontSize: 11.sp, color: Colors.white70),
                    ),
                    AppSpaces.vSpace12,
                    CustomButton(
                      text: 'Complete Face Verification',
                      isGradient: true,
                      isLoading: controller.isVerifyingFace.value,
                      icon: Icon(Icons.camera_front_rounded, size: 20.sp, color: Colors.white),
                      onPressed: () => controller.verifyLiveFace(),
                    ),
                  ],
                ),
              ),
              AppSpaces.vSpace16,
            ],

            // Allowed Attendance Actions Grid
            Text(
              'Select Attendance Action',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
            AppSpaces.vSpace12,

            if (allowed.isEmpty) ...[
              Container(
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  'No attendance actions are currently permitted for your shift schedule.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                ),
              ),
            ] else ...[
              Wrap(
                spacing: 12.w,
                runSpacing: 12.h,
                alignment: WrapAlignment.center,
                children: [
                  if (allowed.contains('in'))
                    _buildActionButton(
                      label: 'Check In',
                      kind: 'in',
                      icon: Icons.login_rounded,
                      color: const Color(0xFF10B981),
                      enabled: !reqFace || isFaceOk,
                    ),
                  if (allowed.contains('out'))
                    _buildActionButton(
                      label: 'Check Out',
                      kind: 'out',
                      icon: Icons.logout_rounded,
                      color: Colors.redAccent,
                      enabled: !reqFace || isFaceOk,
                    ),
                  if (allowed.contains('break_start'))
                    _buildActionButton(
                      label: 'Start Break',
                      kind: 'break_start',
                      icon: Icons.coffee_rounded,
                      color: Colors.amber.shade700,
                      enabled: !reqFace || isFaceOk,
                    ),
                  if (allowed.contains('break_end'))
                    _buildActionButton(
                      label: 'End Break',
                      kind: 'break_end',
                      icon: Icons.work_history_rounded,
                      color: AppColors.secondary,
                      enabled: !reqFace || isFaceOk,
                    ),
                ],
              ),
            ],

            AppSpaces.vSpace18,

            // Cancel / Exit Session Button
            TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white60,
              ),
              icon: Icon(Icons.close_rounded, size: 16.sp),
              label: Text('Cancel Identification', style: TextStyle(fontSize: 12.sp)),
              onPressed: () => controller.cancelSession(),
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

      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 26.h),
        decoration: BoxDecoration(
          color: const Color(0xFF022A40),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: Colors.tealAccent, width: 2.w),
          boxShadow: [
            BoxShadow(
              color: Colors.tealAccent.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.tealAccent.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle_rounded, color: Colors.tealAccent, size: 54.sp),
            ),
            AppSpaces.vSpace14,
            Text(
              'Punch Recorded Successfully',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            AppSpaces.vSpace6,
            Text(
              '$role • $time',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: Colors.tealAccent,
              ),
            ),
            AppSpaces.vSpace4,
            Text(
              'Recorded for $name',
              style: TextStyle(fontSize: 13.sp, color: AppColors.litePrimary),
            ),
            AppSpaces.vSpace20,
            CustomButton(
              text: 'Done (Reset Now)',
              isGradient: true,
              onPressed: controller.resetToMainScreen,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildActionButton({
    required String label,
    required String kind,
    required IconData icon,
    required Color color,
    required bool enabled,
  }) {
    return Obx(() {
      final isBusy = controller.isSubmitting.value;

      return SizedBox(
        width: 140.w,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade800,
            disabledForegroundColor: Colors.white38,
            padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 10.w),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            elevation: 4,
          ),
          onPressed: (enabled && !isBusy) ? () => controller.punchAttendanceAction(kind) : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 28.sp),
              AppSpaces.vSpace6,
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildModeTab({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary : Colors.black26,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isSelected ? AppColors.secondary : Colors.white24,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16.sp, color: Colors.white),
            AppSpaces.hSpace8,
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStationFooter(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Text(
        'AMS 2 Enterprise Kiosk Terminal • Version 2.0.0',
        style: TextStyle(fontSize: 10.sp, color: Colors.white38),
      ),
    );
  }

  /// Secret dialog allowing authorized administrators to exit or reset Kiosk Mode
  void _showAdminExitDialog(BuildContext context) {
    final TextEditingController adminPinController = TextEditingController();

    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
        title: Row(
          children: [
            Icon(Icons.lock_rounded, color: AppColors.primary),
            AppSpaces.hSpace10,
            Text('Kiosk Station Administration', style: TextStyle(fontSize: 16.sp)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter administrator authorization to exit or de-provision this kiosk station.',
              style: AppTextStyles.text12.copyWith(color: AppColors.subTextColor),
            ),
            AppSpaces.vSpace14,
            CustomTextField(
              controller: adminPinController,
              hintText: 'Enter Admin / Station PIN',
              obscureText: true,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Get.back(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text('Exit & Reset Station'),
            onPressed: () async {
              Get.back();
              await controller.deProvisionKiosk();
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Return to Login'),
            onPressed: () {
              Get.back();
              Get.offAllNamed(Routes.LOGIN);
            },
          ),
        ],
      ),
    );
  }

  void _showManualBadgePrompt(BuildContext context) {
    final TextEditingController badgeInputController = TextEditingController();

    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
        title: Text('Scan / Enter Badge Value', style: TextStyle(fontSize: 16.sp)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Input the QR badge code as scanned from the employee digital ID card.',
              style: AppTextStyles.text12.copyWith(color: AppColors.subTextColor),
            ),
            AppSpaces.vSpace12,
            CustomTextField(
              controller: badgeInputController,
              hintText: 'Badge Code (e.g. 01jb2x9k4m7q8r3t5v6w8y0z1a)',
              prefixIcon: Icon(Icons.qr_code_rounded, size: 20.sp, color: AppColors.subTextColor),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Get.back(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Identify'),
            onPressed: () {
              final code = badgeInputController.text.trim();
              Get.back();
              if (code.isNotEmpty) {
                controller.identifyViaBadge(code);
              }
            },
          ),
        ],
      ),
    );
  }
}
