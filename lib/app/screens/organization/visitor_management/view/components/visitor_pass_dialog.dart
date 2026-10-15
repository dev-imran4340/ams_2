import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/assets/app_images.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_spaces.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../model/visitor_model.dart';

class VisitorPassDialog extends StatelessWidget {
  final VisitorModel visitor;

  const VisitorPassDialog({
    super.key,
    required this.visitor,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.25),
              blurRadius: 32.r,
              offset: Offset(0, 10.h),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Executive Pass Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.accentNavy,
                      AppColors.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32.r,
                      height: 32.r,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      padding: EdgeInsets.all(4.r),
                      child: Image.asset(
                        AppImages.whiteLogo,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.business_rounded,
                          color: AppColors.white,
                          size: 16.sp,
                        ),
                      ),
                    ),
                    AppSpaces.hSpace10,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Softech Business Services',
                            style: AppTextStyles.text12.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                          Text(
                            'OFFICIAL DIGITAL VISITOR PASS',
                            style: AppTextStyles.text8.copyWith(
                              color: AppColors.liteSecondary,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        visitor.id,
                        style: AppTextStyles.text10.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Pass Body
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: Column(
                  children: [
                    // Photo & Name Spotlight
                    Row(
                      children: [
                        // Biometric Photo Frame
                        Container(
                          width: 64.r,
                          height: 64.r,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: AppColors.secondary,
                              width: 2.w,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.face_rounded,
                              size: 40.sp,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                        AppSpaces.hSpace14,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                visitor.fullName,
                                style: AppTextStyles.text16.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textColor,
                                ),
                              ),
                              AppSpaces.vSpace2,
                              Text(
                                'CNIC: ${visitor.cnic}',
                                style: AppTextStyles.text12.copyWith(
                                  color: AppColors.subTextColor,
                                ),
                              ),
                              AppSpaces.vSpace4,
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Text(
                                  'Purpose: ${visitor.purpose}',
                                  style: AppTextStyles.text10.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    AppSpaces.vSpace16,

                    // Pass Metadata Table
                    Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: AppColors.inputFill,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: AppColors.borderColor,
                          width: 1.w,
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow(
                            icon: Icons.person_pin_rounded,
                            label: 'Host Contact',
                            value: visitor.hostEmployee,
                          ),
                          AppSpaces.vSpace8,
                          _buildDetailRow(
                            icon: Icons.phone_android_rounded,
                            label: 'Guest Mobile',
                            value: visitor.phone,
                          ),
                          AppSpaces.vSpace8,
                          _buildDetailRow(
                            icon: Icons.access_time_filled_rounded,
                            label: 'Check-In Time',
                            value:
                                '${visitor.formattedCheckInDate} • ${visitor.formattedCheckInTime}',
                          ),
                        ],
                      ),
                    ),

                    AppSpaces.vSpace14,

                    // Digital Security Barcode & Hash
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: AppColors.borderColor,
                          width: 1.w,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'DIGITAL GATE CLEARANCE',
                                style: AppTextStyles.text8.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.subTextColor,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              AppSpaces.vSpace2,
                              Text(
                                'SEC-HASH: #8892-SBS-VERIFIED',
                                style: AppTextStyles.text10.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            Icons.qr_code_2_rounded,
                            size: 36.sp,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),

                    AppSpaces.vSpace18,

                    // Action Button
                    CustomButton(
                      text: 'Done & Close',
                      isGradient: true,
                      onPressed: () => Get.back(),
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

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14.sp, color: AppColors.secondary),
        AppSpaces.hSpace8,
        Text(
          '$label: ',
          style: AppTextStyles.text10.copyWith(
            color: AppColors.subTextColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.text10.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
