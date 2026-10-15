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

class VisitorEntryView extends GetView<VisitorController> {
  const VisitorEntryView({super.key});

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
              // 1. Curved Primary Corporate Header
              _buildHeader(context),

              // 2. Overlapping Interactive Body Content
              Transform.translate(
                offset: Offset(0, -32.h),
                child: Padding(
                  padding: AppSpaces.horizontalPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Step Indicator (Photo -> Details -> Submit)
                      _buildStepIndicator(),

                      AppSpaces.vSpace16,

                      // Section Card 1: Visitor Photo
                      _buildSectionCard(
                        title: 'Visitor photo',
                        subtitle:
                            'Capture a clear front-facing photo for check-in',
                        icon: Icons.camera_alt_rounded,
                        accentColor: AppColors.primary,
                        child: _buildCameraContent(),
                      ),

                      // Hint Banner or Section Card 2: Entry Details Form
                      Obx(() {
                        if (!controller.hasCapturedPhoto) {
                          return Column(
                            children: [
                              AppSpaces.vSpace14,
                              _buildHintBanner(
                                icon: Icons.touch_app_rounded,
                                message: 'Start the camera and capture a photo to unlock the entry form.',
                              ),
                            ],
                          );
                        }

                        return Column(
                          children: [
                            AppSpaces.vSpace16,
                            _buildSectionCard(
                              title: 'Entry details',
                              subtitle: 'Add visitor information before submitting check-in',
                              icon: Icons.edit_note_rounded,
                              accentColor: AppColors.secondary,
                              child: _buildFormContent(),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  /// Executive Curved Header with Back Pill and Screen Title
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
          // Ambient Circles
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
                  // Top Back Pill & Badge
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
                          'CHECK-IN TERMINAL',
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

                  // Title Section
                  Row(
                    children: [
                      Container(
                        width: 48.r,
                        height: 48.r,
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: AppColors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Icon(
                          Icons.login_rounded,
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
                              'Reception Check-In',
                              style: AppTextStyles.text12.copyWith(
                                color: AppColors.litePrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            AppSpaces.vSpace2,
                            Text(
                              'Visitor Entry',
                              style: AppTextStyles.text22.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
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

  /// Step Indicator matching smart_attendance Photo -> Details -> Submit
  Widget _buildStepIndicator() {
    return Obx(() {
      final photoDone = controller.hasCapturedPhoto;
      final detailsActive = photoDone;

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
            _StepChip(
              label: 'Photo',
              icon: Icons.camera_alt_rounded,
              isActive: !photoDone,
              isDone: photoDone,
            ),
            Expanded(
              child: Container(
                height: 2.h,
                margin: EdgeInsets.symmetric(horizontal: 8.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      photoDone
                          ? AppColors.success
                          : AppColors.borderColor.withValues(alpha: 0.8),
                      detailsActive
                          ? AppColors.secondary
                          : AppColors.borderColor.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            _StepChip(
              label: 'Details',
              icon: Icons.assignment_outlined,
              isActive: detailsActive && !controller.isSubmitting.value,
              isDone: false,
            ),
            Expanded(
              child: Container(
                height: 2.h,
                margin: EdgeInsets.symmetric(horizontal: 8.w),
                color: AppColors.borderColor.withValues(alpha: 0.8),
              ),
            ),
            const _StepChip(
              label: 'Submit',
              icon: Icons.send_rounded,
              isActive: false,
              isDone: false,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildHintBanner({required IconData icon, required String message}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.25),
          width: 1.w,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18.sp, color: AppColors.secondary),
          AppSpaces.hSpace10,
          Expanded(
            child: Text(
              message,
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

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required Widget child,
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
          // Section Card Header
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
                      Text(
                        title,
                        style: AppTextStyles.text16.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
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
              ],
            ),
          ),
          // Section Card Body
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
            child: child,
          ),
          // 3.w Bottom Accent Border Stripe
          Container(height: 3.h, color: accentColor),
        ],
      ),
    );
  }

  /// Camera Viewfinder and Action Buttons
  Widget _buildCameraContent() {
    return Obx(() {
      final photo = controller.capturedSelfie.value;
      final isCameraActive = controller.isCameraActive.value;
      final isInitializing = controller.isInitializingCamera.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Viewfinder Container
          Container(
            height: 250.h,
            decoration: BoxDecoration(
              color: const Color(0xFF131B2E),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: photo != null
                    ? AppColors.success.withValues(alpha: 0.6)
                    : (isCameraActive
                          ? AppColors.secondary
                          : AppColors.borderColor.withValues(alpha: 0.4)),
                width: 1.5.w,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. Photo Captured State
                if (photo != null)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100.r,
                          height: 100.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.success,
                              width: 3.w,
                            ),
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.accentNavy],
                            ),
                          ),
                          child: Icon(
                            Icons.person_rounded,
                            size: 54.sp,
                            color: AppColors.white,
                          ),
                        ),
                        AppSpaces.vSpace12,
                        Text(
                          'Guest Photo Captured',
                          style: AppTextStyles.text14.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        AppSpaces.vSpace4,
                        Text(
                          'Verified biometric intake token active',
                          style: AppTextStyles.text10.copyWith(
                            color: AppColors.litePrimary,
                          ),
                        ),
                      ],
                    ),
                  )
                // 2. Active Simulated Camera Viewfinder
                else if (isCameraActive)
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Active Viewfinder Simulated Feed
                      Container(
                        color: const Color(0xFF0F172A),
                        child: Center(
                          child: Icon(
                            Icons.face_retouching_natural_rounded,
                            size: 80.sp,
                            color: AppColors.secondary.withValues(alpha: 0.35),
                          ),
                        ),
                      ),
                      // Viewfinder Focus Frame
                      Container(
                        width: 160.r,
                        height: 180.r,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: AppColors.secondary,
                            width: 2.w,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(6.r),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: 8.r,
                                    height: 8.r,
                                    decoration: const BoxDecoration(
                                      color: AppColors.secondary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  Text(
                                    'AI ALIGN',
                                    style: AppTextStyles.text8.copyWith(
                                      color: AppColors.secondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'Center Face in Frame',
                              style: AppTextStyles.text10.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 6.h),
                          ],
                        ),
                      ),
                    ],
                  )
                // 3. Initializing Spinner
                else if (isInitializing)
                  Center(
                    child: CircularProgressIndicator(
                      color: AppColors.secondary,
                      strokeWidth: 2.5.w,
                    ),
                  )
                // 4. Idle / No Photo State
                else
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(14.r),
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.white.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Icon(
                            Icons.face_retouching_natural_rounded,
                            size: 38.sp,
                            color: AppColors.white.withValues(alpha: 0.7),
                          ),
                        ),
                        AppSpaces.vSpace12,
                        Text(
                          'No photo captured yet',
                          style: AppTextStyles.text14.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        AppSpaces.vSpace4,
                        Text(
                          'Position visitor facing the camera',
                          style: AppTextStyles.text12.copyWith(
                            color: AppColors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Top-Right "Photo ready" Badge
                if (photo != null)
                  Positioned(
                    top: 10.h,
                    right: 10.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.white,
                            size: 13.sp,
                          ),
                          AppSpaces.hSpace4,
                          Text(
                            'Photo ready',
                            style: AppTextStyles.text10.copyWith(
                              color: AppColors.white,
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

          AppSpaces.vSpace14,

          // Camera Action Buttons
          if (photo == null)
            (!isCameraActive
                ? CustomButton(
                    text: 'Start camera',
                    icon: Icon(
                      Icons.camera_alt_rounded,
                      size: 18.sp,
                      color: AppColors.white,
                    ),
                    isGradient: true,
                    onPressed: controller.startCamera,
                  )
                : Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: CustomButton(
                          text: 'Capture',
                          icon: Icon(
                            Icons.camera_rounded,
                            size: 18.sp,
                            color: AppColors.white,
                          ),
                          backgroundColor: AppColors.success,
                          textColor: AppColors.white,
                          onPressed: controller.capturePhoto,
                        ),
                      ),
                      AppSpaces.hSpace10,
                      Expanded(
                        flex: 2,
                        child: CustomButton(
                          text: 'Stop',
                          isOutlined: true,
                          borderColor: AppColors.borderColor,
                          textColor: AppColors.subTextColor,
                          onPressed: controller.stopCamera,
                        ),
                      ),
                    ],
                  ))
          else
            CustomButton(
              text: 'Retake photo',
              icon: Icon(
                Icons.refresh_rounded,
                size: 18.sp,
                color: AppColors.primary,
              ),
              isOutlined: true,
              borderColor: AppColors.primary,
              textColor: AppColors.primary,
              onPressed: controller.retakePhoto,
            ),
        ],
      );
    });
  }

  /// Entry Details Form Content
  Widget _buildFormContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Visitor Name Field
        CustomTextField(
          controller: controller.nameController,
          focusNode: controller.nameFocusNode,
          labelText: 'Visitor name',
          hintText: "Enter visitor's full name",
          prefixIcon: Icon(
            Icons.person_outline_rounded,
            color: AppColors.primary,
            size: 20.sp,
          ),
        ),

        AppSpaces.vSpace14,

        // 2. Host Employee Dropdown
        _buildEmployeeDropdown(),

        AppSpaces.vSpace14,

        // 3. Check-In Time Picker
        CustomTextField(
          controller: controller.startTimeController,
          labelText: 'Check-in time',
          hintText: 'Select date and time',
          readOnly: true,
          onTap: controller.selectEntryDateTime,
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

        // 4. Remarks Field
        CustomTextField(
          controller: controller.remarksController,
          labelText: 'Remarks',
          hintText: 'Any additional visit notes (optional)',
          maxLines: 3,
          prefixIcon: Icon(
            Icons.note_alt_outlined,
            color: AppColors.primary,
            size: 20.sp,
          ),
        ),

        AppSpaces.vSpace20,

        // 5. Submit Check-in Button
        Obx(
          () => CustomButton(
            text: 'Submit check-in',
            icon: Icon(
              Icons.login_rounded,
              size: 18.sp,
              color: AppColors.white,
            ),
            isGradient: true,
            isLoading: controller.isSubmitting.value,
            onPressed: controller.isSubmitting.value
                ? null
                : controller.submitEntry,
          ),
        ),
      ],
    );
  }

  Widget _buildEmployeeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Host employee',
          style: AppTextStyles.text12.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textColor,
          ),
        ),
        AppSpaces.vSpace6,
        Obx(() {
          if (controller.hostEmployees.isEmpty) {
            return Container(
              height: 48.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: SizedBox(
                width: 18.r,
                height: 18.r,
                child: CircularProgressIndicator(
                  strokeWidth: 2.w,
                  color: AppColors.primary,
                ),
              ),
            );
          }

          return DropdownButtonFormField<HostEmployeeOption>(
            initialValue: controller.selectedHost.value,
            isExpanded: true,
            dropdownColor: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12.r),
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.primary,
              size: 22.sp,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.inputFill,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 12.h,
              ),
              prefixIcon: Icon(
                Icons.badge_outlined,
                color: AppColors.primary,
                size: 20.sp,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(
                  color: AppColors.borderColor,
                  width: 1.w,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(
                  color: AppColors.borderColor,
                  width: 1.w,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(
                  color: AppColors.secondary,
                  width: 1.5.w,
                ),
              ),
            ),
            items: controller.hostEmployees.map((HostEmployeeOption emp) {
              return DropdownMenuItem<HostEmployeeOption>(
                value: emp,
                child: Text(
                  emp.displayName,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.text12.copyWith(
                    color: AppColors.textColor,
                  ),
                ),
              );
            }).toList(),
            onChanged: (HostEmployeeOption? val) {
              if (val != null) {
                controller.selectedHost.value = val;
              }
            },
          );
        }),
      ],
    );
  }
}

class _StepChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final bool isDone;

  const _StepChip({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.isDone,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDone
        ? AppColors.success
        : (isActive
              ? AppColors.primary
              : AppColors.subTextColor.withValues(alpha: 0.6));

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
