import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../controller/employee_card_controller.dart';
import '../../model/employee_card_model.dart';

class DigitalIdCardWidget extends GetView<EmployeeCardController> {
  const DigitalIdCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final card = controller.cardData.value;
      if (card == null) return const SizedBox.shrink();

      return Column(
        children: [
          // 1. Sleek Face Selector Pill: Front vs Back
          _buildFaceSelectorPill(),

          AppSpaces.vSpace14,

          // 2. 3D Flippable Vertical ID Card
          AnimatedBuilder(
            animation: controller.flipAnimation,
            builder: (context, _) {
              final value = controller.flipAnimation.value;
              final angle = value * math.pi;
              final isFront = angle <= (math.pi / 2);

              return GestureDetector(
                onTap: controller.flipCard,
                child: Center(
                  child: Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.0014)
                      ..rotateY(angle),
                    alignment: Alignment.center,
                    child: isFront
                        ? _buildFrontFace(card)
                        : Transform(
                            transform: Matrix4.identity()..rotateY(math.pi),
                            alignment: Alignment.center,
                            child: _buildBackFace(card),
                          ),
                  ),
                ),
              );
            },
          ),

          AppSpaces.vSpace10,

          // 3. Subtle Tap Hint
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.touch_app_outlined,
                size: 13.sp,
                color: AppColors.subTextColor,
              ),
              AppSpaces.hSpace4,
              Text(
                'Tap badge or toggle button to flip 3D card',
                style: AppTextStyles.text10.copyWith(
                  color: AppColors.subTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  /// Face Selector Pill (Front Badge / Back Side)
  Widget _buildFaceSelectorPill() {
    return Obx(() {
      final isBack = controller.isFlipped.value;
      return Container(
        padding: EdgeInsets.all(4.r),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: AppColors.borderColor,
            width: 0.8.w,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.05),
              blurRadius: 8.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPillTab(
              label: 'Front Badge',
              icon: Icons.badge_outlined,
              isSelected: !isBack,
              onTap: () {
                if (isBack) controller.flipCard();
              },
            ),
            AppSpaces.hSpace4,
            _buildPillTab(
              label: 'Back Side',
              icon: Icons.sync_rounded,
              isSelected: isBack,
              onTap: () {
                if (!isBack) controller.flipCard();
              },
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPillTab({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(16.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 13.sp,
                color: isSelected ? AppColors.white : AppColors.subTextColor,
              ),
              AppSpaces.hSpace6,
              Text(
                label,
                style: AppTextStyles.text10.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.white : AppColors.subTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Front Face: Exact Vertical Portrait ID formatted with Corporate Theme matching official PDF
  Widget _buildFrontFace(EmployeeCardDetails card) {
    return Container(
      width: 275.w,
      height: 450.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.borderColor.withValues(alpha: 0.8),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: card.cardColor.withValues(alpha: 0.12),
            blurRadius: 22.r,
            offset: Offset(0, 8.h),
          ),
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.06),
            blurRadius: 10.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Stack(
          children: [
            // Top Header Banner in Card Theme Color
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 42.h,
                color: card.cardColor,
                alignment: Alignment.center,
                child: Text(
                  'EMPLOYEE ID CARD',
                  style: AppTextStyles.text12.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
            ),

            // Card Body Content
            Positioned.fill(
              top: 42.h,
              bottom: 6.h,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Avatar & Employee Info Block
                    Column(
                      children: [
                        AppSpaces.vSpace6,

                        // Circular Avatar with Initials in Card Theme Color
                        Container(
                          width: 76.r,
                          height: 76.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: card.cardColor,
                            border: Border.all(
                              color: AppColors.white,
                              width: 2.5.w,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: card.cardColor.withValues(alpha: 0.25),
                                blurRadius: 10.r,
                                offset: Offset(0, 3.h),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            card.initials,
                            style: AppTextStyles.text24.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                        ),

                        AppSpaces.vSpace10,

                        // Employee Full Name
                        Text(
                          card.name.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.text16.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                            letterSpacing: 0.5,
                          ),
                        ),

                        AppSpaces.vSpace2,

                        // Designation
                        Text(
                          card.designation,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.text12.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppColors.subTextColor,
                          ),
                        ),

                        AppSpaces.vSpace6,

                        // Employee Number / ID Text
                        Text(
                          'ID: ${card.employeeNumber}',
                          style: AppTextStyles.text10.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),

                    // Authentic Scannable QR Code Container generated from card.qrValue
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: AppColors.borderColor.withValues(alpha: 0.8),
                          width: 0.8.w,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: card.cardColor.withValues(alpha: 0.05),
                            blurRadius: 8.r,
                            offset: Offset(0, 2.h),
                          ),
                        ],
                      ),
                      child: card.qrValue.isNotEmpty
                          ? QrImageView(
                              data: card.qrValue,
                              version: QrVersions.auto,
                              size: 88.sp,
                              padding: EdgeInsets.zero,
                              eyeStyle: const QrEyeStyle(
                                eyeShape: QrEyeShape.square,
                                color: Color(0xFF1E293B),
                              ),
                              dataModuleStyle: const QrDataModuleStyle(
                                dataModuleShape: QrDataModuleShape.square,
                                color: Color(0xFF1E293B),
                              ),
                            )
                          : Icon(
                              Icons.qr_code_2_rounded,
                              size: 88.sp,
                              color: card.cardColor,
                            ),
                    ),

                    // Company Name Footer
                    Padding(
                      padding: EdgeInsets.only(bottom: 4.h),
                      child: Text(
                        card.company.name.toUpperCase(),
                        style: AppTextStyles.text12.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Accent Bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 5.h,
                color: card.cardColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Back Face: Official Terms, Company Address & Contact Information matching official PDF
  Widget _buildBackFace(EmployeeCardDetails card) {
    final company = card.company;
    final address = company.address ?? 'test ad 1, Islamabad, 44000';
    final phone = company.phone ?? card.phone ?? '03155109822';

    return Container(
      width: 275.w,
      height: 450.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.borderColor.withValues(alpha: 0.8),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: card.cardColor.withValues(alpha: 0.12),
            blurRadius: 22.r,
            offset: Offset(0, 8.h),
          ),
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.06),
            blurRadius: 10.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Stack(
          children: [
            // Back Content
            Positioned.fill(
              bottom: 6.h,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 12.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Section: Company Name, Emblem & Address
                    Column(
                      children: [
                        Text(
                          company.name.toUpperCase(),
                          style: AppTextStyles.text16.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                            letterSpacing: 1.2,
                          ),
                        ),
                        AppSpaces.vSpace8,

                        // Corporate Building / Emblem Icon
                        Container(
                          width: 44.r,
                          height: 44.r,
                          decoration: BoxDecoration(
                            color: card.cardColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(
                            Icons.corporate_fare_rounded,
                            size: 26.sp,
                            color: card.cardColor,
                          ),
                        ),

                        AppSpaces.vSpace8,

                        // Location Address
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: 13.sp,
                              color: AppColors.subTextColor,
                            ),
                            AppSpaces.hSpace4,
                            Flexible(
                              child: Text(
                                address,
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.text10.copyWith(
                                  color: AppColors.subTextColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Middle Section: Official Card Holder Rules & Bullet Points
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.inputFill.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: AppColors.borderColor.withValues(alpha: 0.5),
                          width: 0.8.w,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBulletPoint(
                            'This card remains the property of ${company.name}.',
                          ),
                          AppSpaces.vSpace6,
                          _buildBulletPoint(
                            'If found, please return it to the address above.',
                          ),
                          AppSpaces.vSpace6,
                          _buildBulletPoint(
                            'The card holder is not authorised to collect company dues or payments.',
                          ),
                        ],
                      ),
                    ),

                    // Bottom Contact Footer Block
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.phone_rounded,
                              size: 12.sp,
                              color: AppColors.textColor,
                            ),
                            AppSpaces.hSpace6,
                            Text(
                              phone,
                              style: AppTextStyles.text10.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                            ),
                          ],
                        ),
                        AppSpaces.vSpace4,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.email_outlined,
                              size: 12.sp,
                              color: AppColors.subTextColor,
                            ),
                            AppSpaces.hSpace6,
                            Text(
                              'siddique.softech@gmail.com',
                              style: AppTextStyles.text10.copyWith(
                                color: AppColors.subTextColor,
                              ),
                            ),
                          ],
                        ),
                        AppSpaces.vSpace8,
                        Text(
                          card.cardSubtitle,
                          style: AppTextStyles.text10.copyWith(
                            color: AppColors.subTextColor.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Accent Bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 5.h,
                color: card.cardColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '• ',
          style: AppTextStyles.text10.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.text10.copyWith(
              color: AppColors.textColor.withValues(alpha: 0.85),
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
