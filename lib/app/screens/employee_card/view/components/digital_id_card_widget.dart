import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

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

      return AnimatedBuilder(
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
      );
    });
  }

  /// Front Face: Executive Metallic Deep Navy Smart ID
  Widget _buildFrontFace(EmployeeCardDetails card) {
    return Container(
      width: 340.w,
      height: 216.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.accentNavy,
            AppColors.primary,
          ],
        ),
        border: Border.all(
          color: AppColors.liteSecondary.withValues(alpha: 0.25),
          width: 1.2.w,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 24.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Stack(
          children: [
            // Ambient Geometric Background Rings
            Positioned(
              top: -40.r,
              right: -30.r,
              child: Container(
                width: 150.r,
                height: 150.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary.withValues(alpha: 0.06),
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.12),
                    width: 1.5.w,
                  ),
                ),
              ),
            ),

            // Card Content
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: SoftGenie Enterprise Brand & NFC Waves
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 16.r,
                            height: 16.r,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.secondary,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.shield_rounded,
                                size: 10.sp,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                          AppSpaces.hSpace8,
                          Text(
                            'SOFTGENIE ENTERPRISE',
                            style: AppTextStyles.text10.copyWith(
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.contactless_rounded,
                            size: 18.sp,
                            color: AppColors.secondary,
                          ),
                          AppSpaces.hSpace4,
                          Text(
                            'NFC',
                            style: AppTextStyles.text10.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary,
                              fontSize: 9.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  AppSpaces.vSpace10,

                  // EMV Smart Chip Emblem
                  _buildSmartChip(),

                  AppSpaces.vSpace10,

                  // Employee Avatar & Info Row
                  Row(
                    children: [
                      // Avatar with verified online ring
                      Stack(
                        children: [
                          Container(
                            width: 52.r,
                            height: 52.r,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.secondary.withValues(alpha: 0.2),
                              border: Border.all(
                                color: AppColors.white,
                                width: 2.w,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                card.name.isNotEmpty ? card.name[0] : 'M',
                                style: AppTextStyles.text20.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 1.r,
                            right: 1.r,
                            child: Container(
                              width: 12.r,
                              height: 12.r,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.success,
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 1.5.w,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      AppSpaces.hSpace12,

                      // Name, Designation & ID
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              card.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.text16.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                                letterSpacing: -0.2,
                              ),
                            ),
                            AppSpaces.vSpace2,
                            Text(
                              card.designation,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.text10.copyWith(
                                color: AppColors.liteSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            AppSpaces.vSpace4,
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                '#${card.employeeId}',
                                style: AppTextStyles.text10.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.white,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Corner Hologram QR Badge
                      Container(
                        width: 44.r,
                        height: 44.r,
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: AppColors.white.withValues(alpha: 0.25),
                            width: 1.w,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.qr_code_2_rounded,
                            size: 32.sp,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Bottom Subtitle & Flip Hint
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        card.department.toUpperCase(),
                        style: AppTextStyles.text10.copyWith(
                          fontSize: 8.5.sp,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white.withValues(alpha: 0.7),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.sync_rounded,
                            size: 11.sp,
                            color: AppColors.secondary,
                          ),
                          AppSpaces.hSpace4,
                          Text(
                            'Tap to flip',
                            style: AppTextStyles.text10.copyWith(
                              fontSize: 9.sp,
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Back Face: Security Magnetic Stripe, Barcode & Emergency Contacts
  Widget _buildBackFace(EmployeeCardDetails card) {
    return Container(
      width: 340.w,
      height: 216.h,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.borderColor,
          width: 1.2.w,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 24.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Dark Magnetic Security Stripe
            Container(
              height: 32.h,
              color: AppColors.darkStripe,
            ),

            AppSpaces.vSpace10,

            // 2. Metadata Columns
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildBackInfo(
                        label: 'EMERGENCY CONTACT',
                        value: card.emergencyContact,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.3),
                            width: 0.8.w,
                          ),
                        ),
                        child: Text(
                          'BLOOD ${card.bloodGroup}',
                          style: AppTextStyles.text10.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),

                  AppSpaces.vSpace8,

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildBackInfo(
                        label: 'JOINED DATE',
                        value: card.joiningDate,
                      ),
                      _buildBackInfo(
                        label: 'VALID UNTIL',
                        value: card.validTill,
                        alignRight: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(),

            // 3. Simulated Barcode & Official Signature
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Barcode
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBarcodeLines(),
                      AppSpaces.vSpace2,
                      Text(
                        '* ${card.employeeId} *',
                        style: AppTextStyles.text10.copyWith(
                          fontSize: 8.sp,
                          letterSpacing: 2,
                          color: AppColors.subTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  // Signature Stamp
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'SoftGenie Security',
                        style: AppTextStyles.text10.copyWith(
                          fontSize: 9.sp,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        'AUTHORIZED OFFICER',
                        style: AppTextStyles.text10.copyWith(
                          fontSize: 7.5.sp,
                          letterSpacing: 0.5,
                          color: AppColors.subTextColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// EMV Gold Smart Chip Graphic
  Widget _buildSmartChip() {
    return Container(
      width: 38.w,
      height: 28.h,
      decoration: BoxDecoration(
        color: AppColors.metallicGold, // Metallic gold
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(
          color: AppColors.metallicGoldDark,
          width: 0.8.w,
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Container(
              width: 24.w,
              height: 16.h,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.metallicGoldPath,
                  width: 0.8.w,
                ),
                borderRadius: BorderRadius.circular(3.r),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 13.h,
            child: Container(
              height: 0.8.h,
              color: AppColors.metallicGoldPath,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackInfo({
    required String label,
    required String value,
    bool alignRight = false,
  }) {
    return Column(
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.text10.copyWith(
            fontSize: 8.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.subTextColor,
            letterSpacing: 0.4,
          ),
        ),
        AppSpaces.vSpace2,
        Text(
          value,
          style: AppTextStyles.text12.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
        ),
      ],
    );
  }

  /// Clean procedural barcode strip
  Widget _buildBarcodeLines() {
    final pattern = [
      3, 1, 2, 1, 4, 1, 2, 3, 1, 2, 4, 1, 3, 2, 1, 4, 2, 1, 3, 1, 2, 4, 1
    ];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: pattern.map((width) {
        return Container(
          width: (width * 1.2).w,
          height: 18.h,
          margin: EdgeInsets.only(right: 1.2.w),
          color: AppColors.textColor,
        );
      }).toList(),
    );
  }
}
