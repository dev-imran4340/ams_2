import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_spaces.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../../../core/widgets/custom_button.dart';

class VisitorCameraCaptureCard extends StatelessWidget {
  final VoidCallback onCapture;

  const VisitorCameraCaptureCard({
    super.key,
    required this.onCapture,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 20.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.r),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            border: Border(
              bottom: BorderSide(
                color: AppColors.secondary,
                width: 3.w,
              ),
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Badge Pill & Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.face_retouching_natural_rounded,
                          size: 13.sp,
                          color: AppColors.secondary,
                        ),
                        AppSpaces.hSpace4,
                        Text(
                          'Step 1 • Facial Intake',
                          style: AppTextStyles.text10.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Biometric Pass ID',
                    style: AppTextStyles.text10.copyWith(
                      color: AppColors.subTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              AppSpaces.vSpace16,

              // Oval Viewfinder Preview Frame
              Container(
                width: 170.w,
                height: 210.h,
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.all(
                    Radius.elliptical(85.w, 105.h),
                  ),
                  border: Border.all(
                    color: AppColors.secondary,
                    width: 2.w,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.15),
                      blurRadius: 16.r,
                      spreadRadius: 2.r,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Subtle Background Silhouette
                    Icon(
                      Icons.person_rounded,
                      size: 96.sp,
                      color: AppColors.primary.withValues(alpha: 0.15),
                    ),

                    // Centered Face Guide Crosshairs
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          size: 32.sp,
                          color: AppColors.secondary,
                        ),
                        AppSpaces.vSpace8,
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Text(
                            'Look straight into the kiosk camera',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.text10.copyWith(
                              color: AppColors.textColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Live Indicator Pill
                    Positioned(
                      top: 14.h,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: AppColors.success.withValues(alpha: 0.4),
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
                                color: AppColors.success,
                                shape: BoxShape.circle,
                              ),
                            ),
                            AppSpaces.hSpace4,
                            Text(
                              'READY',
                              style: AppTextStyles.text8.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              AppSpaces.vSpace16,

              // Guidance text
              Text(
                'Selfie will be imprinted onto the official digital entry badge for checkout verification.',
                textAlign: TextAlign.center,
                style: AppTextStyles.text12.copyWith(
                  color: AppColors.subTextColor,
                  height: 1.4,
                ),
              ),

              AppSpaces.vSpace20,

              // Action Button
              CustomButton(
                text: 'Take Visitor Photo',
                isGradient: true,
                icon: Icon(
                  Icons.camera_alt_rounded,
                  size: 18.sp,
                  color: AppColors.white,
                ),
                onPressed: onCapture,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
