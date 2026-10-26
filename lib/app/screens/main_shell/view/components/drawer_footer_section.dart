import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_state_view.dart';
import '../../controller/session_me_controller.dart';

class DrawerFooterSection extends StatelessWidget {
  const DrawerFooterSection({super.key});

  void _showLogoutDialog(BuildContext context, SessionMeController sessionController) {
    HapticFeedback.mediumImpact();
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        backgroundColor: AppColors.cardBackground,
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomStateView(
                icon: Icons.logout_rounded,
                iconColor: AppColors.error,
                iconBackgroundColor: AppColors.error.withValues(alpha: 0.12),
                title: 'Sign Out Session',
                message:
                    'Are you sure you want to end your active workplace session and return to the login screen?',
                padding: EdgeInsets.zero,
              ),
              AppSpaces.vSpace20,
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Cancel',
                      isOutlined: true,
                      borderColor: AppColors.borderColor,
                      textColor: AppColors.subTextColor,
                      height: 42.h,
                      borderRadius: 12.r,
                      onPressed: () => Get.back(),
                    ),
                  ),
                  AppSpaces.hSpace12,
                  Expanded(
                    child: Obx(() {
                      return CustomButton(
                        text: 'Sign Out',
                        backgroundColor: AppColors.error,
                        textColor: AppColors.white,
                        isLoading: sessionController.isLoggingOut.value,
                        height: 42.h,
                        borderRadius: 12.r,
                        onPressed: sessionController.logout,
                      );
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final SessionMeController sessionController = Get.isRegistered<SessionMeController>()
        ? Get.find<SessionMeController>()
        : Get.put(SessionMeController(), permanent: true);

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        border: Border(
          top: BorderSide(
            color: AppColors.borderColor.withValues(alpha: 0.6),
            width: 1.w,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Red Accent Exit / Sign Out Button
          CustomButton(
            text: 'Sign Out Session',
            isOutlined: true,
            borderColor: AppColors.error.withValues(alpha: 0.35),
            textColor: AppColors.error,
            height: 44.h,
            borderRadius: 12.r,
            icon: Icon(
              Icons.logout_rounded,
              size: 16.sp,
              color: AppColors.error,
            ),
            onPressed: () => _showLogoutDialog(context, sessionController),
          ),

          AppSpaces.vSpace12,

          // App Version & Company Branding
          Center(
            child: Text(
              'AMS 2.0 Enterprise • Softech Business Services Solutions',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.text10.copyWith(
                color: AppColors.subTextColor,
                letterSpacing: 0.3,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
