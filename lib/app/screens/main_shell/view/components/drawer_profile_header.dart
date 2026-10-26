import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../routes/app_routes.dart';
import '../../../index/controller/index_controller.dart';
import '../../controller/session_me_controller.dart';

class DrawerProfileHeader extends StatelessWidget {
  const DrawerProfileHeader({super.key});

  String _extractInitials(String name) {
    if (name.trim().isEmpty) return 'MM';
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

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
          : 'Maryam Malik';

      final String email = (user?.email != null && user!.email.isNotEmpty)
          ? user.email
          : 'maryam@example.com';

      final String companyName =
          (company?.name != null && company!.name.isNotEmpty)
          ? company.name
          : 'Kumash';

      final String companyCode =
          (company?.code != null && company!.code.isNotEmpty)
          ? company.code
          : 'ZDTT3V';

      final String initials = _extractInitials(fullName);

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
                      child: Text(
                        initials,
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

                          AppSpaces.vSpace4,

                          // Company title & code capsule ("Kumash • ZDTT3V")
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
                                    '$companyName • $companyCode',
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
