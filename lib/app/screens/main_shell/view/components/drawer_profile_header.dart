import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../api/app_preferences.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../routes/app_routes.dart';
import '../../../index/controller/index_controller.dart';
import '../../controller/session_me_controller.dart';

class DrawerProfileHeader extends StatelessWidget {
  const DrawerProfileHeader({super.key});

  void _openProfileScreen() {
    HapticFeedback.lightImpact();
    Get.back(); // Dismiss drawer smoothly

    if (Get.currentRoute == Routes.INDEX &&
        Get.isRegistered<IndexController>()) {
      final indexCtrl = Get.find<IndexController>();
      final profileIdx = indexCtrl.navTabs.indexWhere((t) => t.id == 'profile');
      if (profileIdx != -1) {
        indexCtrl.changeTab(profileIdx);
        return;
      }
    }

    Get.toNamed(Routes.PROFILE);
  }

  @override
  Widget build(BuildContext context) {
    final SessionMeController sessionController =
        Get.isRegistered<SessionMeController>()
        ? Get.find<SessionMeController>()
        : Get.put(SessionMeController(), permanent: true);

    return Obx(() {
      final user = sessionController.user.value;
      final company = sessionController.company.value;

      final String fullName = (user?.name != null && user!.name.isNotEmpty)
          ? user.name
          : (AppPreferences.userName ?? '');

      final String email = (user?.email != null && user!.email.isNotEmpty)
          ? user.email
          : (AppPreferences.userEmail ?? '');

      final String companyName =
          (company?.name != null && company!.name.isNotEmpty)
          ? company.name
          : (AppPreferences.companyName ?? '');

      final String companyCode =
          (company?.code != null && company!.code.isNotEmpty)
          ? company.code
          : (AppPreferences.companyCode ?? '');

      final String fallbackLetter =
          fullName.trim().isNotEmpty ? fullName.trim()[0].toUpperCase() : 'E';
      final Uint8List? mePhotoBytes = Get.isRegistered<IndexController>()
          ? Get.find<IndexController>().mePhotoBytes.value
          : null;
      final bool hasMePhoto = mePhotoBytes != null && mePhotoBytes.isNotEmpty;
      final bool hasCompanyInfo =
          companyName.isNotEmpty || companyCode.isNotEmpty;
      final String companyLabel = [
        if (companyName.isNotEmpty) companyName,
        if (companyCode.isNotEmpty) companyCode,
      ].join(' • ');

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _openProfileScreen,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16.r),
            bottomRight: Radius.circular(16.r),
          ),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16.w, 55.h, 16.w, 20.h),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.accentNavy,
                  AppColors.accentNavy,
                  AppColors.accentNavy,
                  AppColors.accentNavy,
                  AppColors.primary,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16.r),
                bottomRight: Radius.circular(16.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  blurRadius: 16.r,
                  offset: Offset(0, 6.h),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // User circular avatar badge ('MM')
                    Container(
                      width: 52.r,
                      height: 52.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.white.withValues(alpha: 0.14),
                        border: Border.all(
                          color: AppColors.secondary.withValues(alpha: 0.45),
                          width: 2.w,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.12),
                            blurRadius: 8.r,
                            offset: Offset(0, 3.h),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: hasMePhoto
                          ? ClipOval(
                              child: Image.memory(
                                mePhotoBytes,
                                width: 52.r,
                                height: 52.r,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Text(
                                  fallbackLetter,
                                  style: AppTextStyles.text18.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.white,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            )
                          : Text(
                              fallbackLetter,
                              style: AppTextStyles.text18.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                                letterSpacing: 0.8,
                              ),
                            ),
                    ),

                    AppSpaces.hSpace12,

                    // User name and company capsule
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Full Name & View Profile prompt
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  fullName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.text16.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6.w,
                                  vertical: 3.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.white.withValues(
                                    alpha: 0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'View',
                                      style: AppTextStyles.text10.copyWith(
                                        color: AppColors.liteSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      size: 13.sp,
                                      color: AppColors.secondary,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          if (hasCompanyInfo) ...[
                            AppSpaces.vSpace4,
                            // Company title & code capsule
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 3.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.white.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: AppColors.secondary.withValues(
                                    alpha: 0.35,
                                  ),
                                  width: 1.w,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.business_rounded,
                                    size: 11.sp,
                                    color: AppColors.liteSecondary,
                                  ),
                                  AppSpaces.hSpace4,
                                  Flexible(
                                    child: Text(
                                      companyLabel,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.text10.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.white,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),

                AppSpaces.vSpace12,

                // Email with icon
                Row(
                  children: [
                    Icon(
                      Icons.mail_outline_rounded,
                      size: 13.sp,
                      color: AppColors.liteSecondary.withValues(alpha: 0.85),
                    ),
                    AppSpaces.hSpace6,
                    Expanded(
                      child: Text(
                        email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.text10.copyWith(
                          color: AppColors.white.withValues(alpha: 0.82),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
