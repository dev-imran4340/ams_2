import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../controller/employee_card_controller.dart';
import '../../model/employee_card_model.dart';

class InAppCardPdfViewer extends GetView<EmployeeCardController> {
  const InAppCardPdfViewer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.9.sh,
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        border: Border.all(color: AppColors.borderColor, width: 1.w),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 36.r,
            offset: Offset(0, -10.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Top Bar & Drag Handle
          _buildHeader(),

          // 2. High-Fidelity Zoomable PDF Document Canvas
          Expanded(
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 3.0,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                child: Center(
                  child: Obx(() {
                    final card = controller.cardData.value;
                    if (card == null) return const SizedBox.shrink();
                    return _buildPdfDocumentSheet(card);
                  }),
                ),
              ),
            ),
          ),

          // 3. Bottom Action Controls (Download & Print)
          _buildBottomActionBar(context),
        ],
      ),
    );
  }

  /// Top Bar with drag handle, title, page indicator & close button
  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Column(
              children: [
                // Drag handle
          Center(
            child: Container(
              width: 44.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.subTextColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          AppSpaces.vSpace10,
          Row(
            children: [
              Container(
                width: 34.r,
                height: 34.r,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Center(
                  child: Icon(
                    Icons.picture_as_pdf_rounded,
                    size: 18.sp,
                    color: AppColors.primary,
                  ),
                ),
              ),
              AppSpaces.hSpace10,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Official Smart ID Document',
                      style: AppTextStyles.text14.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                    AppSpaces.vSpace2,
                    Text(
                      'Digitally certified A4 official badge certificate',
                      style: AppTextStyles.text10.copyWith(
                        color: AppColors.subTextColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Page Capsule
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '1 / 1 PAGE',
                  style: AppTextStyles.text10.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    letterSpacing: 0.4,
                  ),
                ),
              ),

              AppSpaces.hSpace8,

              // Close button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Get.back(),
                  borderRadius: BorderRadius.circular(20.r),
                  child: Padding(
                    padding: EdgeInsets.all(4.r),
                    child: Icon(
                      Icons.close_rounded,
                      size: 20.sp,
                      color: AppColors.subTextColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    Divider(
      height: 1.w,
      thickness: 1.w,
      color: AppColors.borderColor,
    ),
  ],
),
);
}

  /// High-Fidelity A4 Document Canvas
  Widget _buildPdfDocumentSheet(EmployeeCardDetails card) {
    return Container(
      width: 330.w,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderColor, width: 1.w),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 20.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      padding: EdgeInsets.all(18.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Letterhead & Brand
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 22.r,
                    height: 22.r,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.shield_rounded,
                        size: 13.sp,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  AppSpaces.hSpace8,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Softech Business Services SOLUTIONS',
                        style: AppTextStyles.text12.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'Global Identity & Enterprise Access Registry',
                        style: AppTextStyles.text10.copyWith(
                          fontSize: 7.5.sp,
                          color: AppColors.subTextColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  'CONFIDENTIAL',
                  style: AppTextStyles.text10.copyWith(
                    fontSize: 7.5.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),

          AppSpaces.vSpace14,
          Container(height: 1.5.h, color: AppColors.primary),
          AppSpaces.vSpace12,

          // Document Title
          Center(
            child: Column(
              children: [
                Text(
                  'DIGITAL EMPLOYEE IDENTIFICATION CARD',
                  style: AppTextStyles.text12.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: AppColors.textColor,
                  ),
                ),
                AppSpaces.vSpace2,
                Text(
                  'ISO/IEC 7810 ID-1 • Hardware Cryptographic Token',
                  style: AppTextStyles.text10.copyWith(
                    fontSize: 8.5.sp,
                    color: AppColors.subTextColor,
                  ),
                ),
              ],
            ),
          ),

          AppSpaces.vSpace14,

          // Mini Embedded ID Badge
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.secondary.withValues(alpha: 0.3),
                    border: Border.all(color: AppColors.white, width: 1.5.w),
                  ),
                  child: Center(
                    child: Text(
                      card.name[0],
                      style: AppTextStyles.text16.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
                AppSpaces.hSpace12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.name,
                        style: AppTextStyles.text14.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                      Text(
                        card.designation,
                        style: AppTextStyles.text10.copyWith(
                          color: AppColors.liteSecondary,
                        ),
                      ),
                      Text(
                        'ID: ${card.employeeId}',
                        style: AppTextStyles.text10.copyWith(
                          color: AppColors.white.withValues(alpha: 0.8),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.qr_code_2_rounded,
                  size: 32.sp,
                  color: AppColors.white,
                ),
              ],
            ),
          ),

          AppSpaces.vSpace16,

          // Detailed Table Information
          _buildDocumentDataRow('Full Legal Name', card.name),
          _buildDocumentDataRow('Employee Reference ID', card.employeeId),
          _buildDocumentDataRow('Job Designation', card.designation),
          _buildDocumentDataRow('Assigned Department', card.department),
          _buildDocumentDataRow('Medical Blood Group', card.bloodGroup ?? 'N/A'),
          _buildDocumentDataRow('Emergency Contact', card.emergencyContact),
          _buildDocumentDataRow('Official Date of Joining', card.joiningDate),
          _buildDocumentDataRow('Credential Validity Period', card.validTill),
          _buildDocumentDataRow(
            'Security Protocol',
            'AES-256 Hardware Encrypted',
          ),

          AppSpaces.vSpace14,

          // Barcode Representation in Document
          Center(
            child: Column(
              children: [
                _buildPdfBarcodeLines(),
                AppSpaces.vSpace4,
                Text(
                  card.qrPayload,
                  style: AppTextStyles.text10.copyWith(
                    fontSize: 7.sp,
                    color: AppColors.subTextColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          AppSpaces.vSpace16,
          Container(height: 1.h, color: AppColors.borderColor),
          AppSpaces.vSpace12,

          // Verification Stamp & Signature
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SECURITY VERIFICATION SEAL',
                    style: AppTextStyles.text10.copyWith(
                      fontSize: 7.5.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.subTextColor,
                    ),
                  ),
                  AppSpaces.vSpace2,
                  Row(
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        size: 14.sp,
                        color: AppColors.success,
                      ),
                      AppSpaces.hSpace4,
                      Text(
                        'DIGITALLY SIGNED & VERIFIED',
                        style: AppTextStyles.text10.copyWith(
                          fontSize: 8.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.secondary, width: 1.5.w),
                ),
                child: Text(
                  'SG',
                  style: AppTextStyles.text10.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentDataRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.text10.copyWith(
              color: AppColors.subTextColor,
              fontSize: 9.sp,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.text10.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
              fontSize: 9.5.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfBarcodeLines() {
    final pattern = [
      2,
      1,
      3,
      1,
      2,
      4,
      1,
      3,
      1,
      2,
      4,
      1,
      2,
      3,
      1,
      4,
      1,
      2,
      3,
      1,
      2,
      4,
      1,
      2,
      3,
    ];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: pattern.map((w) {
        return Container(
          width: (w * 1.0).w,
          height: 16.h,
          margin: EdgeInsets.only(right: 1.w),
          color: AppColors.black,
        );
      }).toList(),
    );
  }

  /// Bottom action bar: Download & Print buttons
  Widget _buildBottomActionBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(
          top: BorderSide(color: AppColors.borderColor, width: 1.w),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Download PDF',
                isGradient: true,
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  Get.back();
                  CustomSnackbar.showSuccess(
                    title: 'PDF Saved to Storage',
                    message:
                        'Official ID badge document saved to Downloads folder.',
                  );
                },
              ),
            ),
            AppSpaces.hSpace12,
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  CustomSnackbar.showInfo(
                    message: 'AirPrint Active: Preparing document for high-resolution card printer.',
                  );
                },
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  width: 48.r,
                  height: 48.r,
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppColors.borderColor,
                      width: 1.w,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.print_rounded,
                      size: 20.sp,
                      color: AppColors.textColor,
                    ),
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
