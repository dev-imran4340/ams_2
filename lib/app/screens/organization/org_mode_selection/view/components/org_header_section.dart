import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/assets/app_images.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_spaces.dart';
import '../../../../../core/utils/app_text_styles.dart';

class OrgHeaderSection extends StatelessWidget {
  final VoidCallback onLogout;

  const OrgHeaderSection({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 235.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primary, // Deep Corporate Navy 0xFF012B43
            AppColors.primary, // 0xFF023E61
            AppColors.primary, // Corporate Navy
            AppColors.secondary,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(15.r),
          bottomRight: Radius.circular(15.r),
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
          // Ambient Translucent Ring 1 (Top-Right)
          Positioned(
            top: -50.r,
            right: -40.r,
            child: Container(
              width: 170.r,
              height: 170.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withValues(alpha: 0.08),
              ),
            ),
          ),

          // Ambient Translucent Ring 2 (Bottom-Left)
          Positioned(
            bottom: -30.r,
            left: -40.r,
            child: Container(
              width: 150.r,
              height: 150.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white.withValues(alpha: 0.05),
              ),
            ),
          ),

          // Ambient Translucent Ring 3 (Center-Right Accent)
          Positioned(
            top: 70.r,
            right: 50.r,
            child: Container(
              width: 90.r,
              height: 90.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withValues(alpha: 0.04),
              ),
            ),
          ),

          // Header Foreground Content
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Bar: Branding & Top-Right Glass Action Pill
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Company Branding: Softech Business Services (Flexible to prevent horizontal overflow)
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 38.r,
                              height: 38.r,
                              decoration: BoxDecoration(
                                color: AppColors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: AppColors.white.withValues(alpha: 0.2),
                                  width: 1.w,
                                ),
                              ),
                              padding: EdgeInsets.all(6.r),
                              child: Image.asset(
                                AppImages.whiteLogo,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    Image.asset(
                                      AppImages.logo1,
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, stackTrace) => Icon(
                                            Icons.business_rounded,
                                            color: AppColors.white,
                                            size: 18.sp,
                                          ),
                                    ),
                              ),
                            ),
                            AppSpaces.hSpace8,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Softech Business Services',
                                    style: AppTextStyles.text14.copyWith(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  AppSpaces.vSpace2,
                                  Text(
                                    'Enterprise Workspace',
                                    style: AppTextStyles.text10.copyWith(
                                      color: AppColors.litePrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      AppSpaces.hSpace8,

                      // Top-Right Circular Glass Action Button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onLogout,
                          borderRadius: BorderRadius.circular(19.r),
                          child: Container(
                            width: 38.r,
                            height: 38.r,
                            decoration: BoxDecoration(
                              color: AppColors.white.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.white.withValues(alpha: 0.25),
                                width: 1.w,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.logout,
                                size: 19.sp,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  AppSpaces.vSpace16,

                  // Headline Text: "Organization Portal"
                  Text(
                    'Organization Portal',
                    style: AppTextStyles.text24.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),

                  AppSpaces.vSpace6,

                  // Subtitle Pill
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: AppColors.secondary.withValues(alpha: 0.4),
                        width: 1.w,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.dashboard_customize_rounded,
                          size: 13.sp,
                          color: AppColors.liteSecondary,
                        ),
                        AppSpaces.hSpace6,
                        Flexible(
                          child: Text(
                            'Select an operational module to proceed',
                            style: AppTextStyles.text12.copyWith(
                              color: AppColors.liteSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
