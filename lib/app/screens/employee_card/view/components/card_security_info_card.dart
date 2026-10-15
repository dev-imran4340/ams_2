import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../controller/employee_card_controller.dart';

class CardSecurityInfoCard extends GetView<EmployeeCardController> {
  const CardSecurityInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final card = controller.cardData.value;
      if (card == null) return const SizedBox.shrink();

      return Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.borderColor, width: 1.w),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.05),
              blurRadius: 16.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Title Row
                    Row(
                      children: [
                        Container(
                          width: 32.r,
                          height: 32.r,
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.verified_user_rounded,
                              size: 17.sp,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                        AppSpaces.hSpace10,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Security & Hardware Telemetry',
                                style: AppTextStyles.text14.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textColor,
                                ),
                              ),
                              AppSpaces.vSpace2,
                              Text(
                                'Hardware-bound cryptographic access credentials',
                                style: AppTextStyles.text10.copyWith(
                                  color: AppColors.subTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Status capsule
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: AppColors.success.withValues(alpha: 0.3),
                              width: 0.8.w,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6.r,
                                height: 6.r,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.success,
                                ),
                              ),
                              AppSpaces.hSpace4,
                              Text(
                                'Active',
                                style: AppTextStyles.text10.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    AppSpaces.vSpace14,
                    Container(height: 1.h, color: AppColors.borderColor),
                    AppSpaces.vSpace12,

                    // Key Security Properties Grid
                    _buildSecurityRow(
                      icon: Icons.business_rounded,
                      title: 'Issuing Authority',
                      value: 'Softech Business Services Global HQ • Cryptographic Keystore',
                    ),
                    AppSpaces.vSpace10,
                    _buildSecurityRow(
                      icon: Icons.vpn_key_rounded,
                      title: 'Encryption Standard',
                      value: 'AES-256 GCM • ISO/IEC 14443 Type A',
                    ),
                    AppSpaces.vSpace10,
                    _buildSecurityRow(
                      icon: Icons.event_available_rounded,
                      title: 'Access Expiry',
                      value: card.validTill,
                    ),
                    AppSpaces.vSpace10,
                    _buildSecurityRow(
                      icon: Icons.tag_rounded,
                      title: 'Hardware NFC UID',
                      value: '04:A2:8B:1F:7C:3D:E0 (Verified)',
                    ),
                  ],
                ),
              ),

              // Bottom Signature Accent Strip (3.h)
              Container(height: 3.h, color: AppColors.secondary),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSecurityRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15.sp, color: AppColors.secondary),
        AppSpaces.hSpace10,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.text10.copyWith(
                  color: AppColors.subTextColor,
                  fontWeight: FontWeight.w500,
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
          ),
        ),
      ],
    );
  }
}
