import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_spaces.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/widgets/custom_state_view.dart';
import '../../../core/widgets/network_boundary_wrapper.dart';
import '../controller/notification_controller.dart';
import 'components/preference_category_card.dart';

/// Notification Channels & Preferences Management Screen
/// Strictly obeys doc/api.md specifications (bell channel locked, 90-day retention policy).
class NotificationPreferencesView extends GetView<NotificationController> {
  const NotificationPreferencesView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkBoundaryWrapper(
      onRetry: controller.loadPreferences,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          elevation: 0,
          centerTitle: false,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textColor,
              size: 20.sp,
            ),
            onPressed: () => Get.back(),
          ),
          title: Text(
            'Notification Preferences',
            style: AppTextStyles.text18.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
        ),
        body: Obx(() {
          if (controller.isLoadingPreferences.value && controller.preferences.value == null) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2.5.w,
              ),
            );
          }

          final prefs = controller.preferences.value;
          if (prefs == null) {
            return Center(
              child: CustomStateView.error(
                title: 'Unable to Load Settings',
                message: 'Failed to retrieve notification channel preferences from server.',
                buttonText: 'Retry',
                onRetry: controller.loadPreferences,
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.loadPreferences,
            color: AppColors.secondary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Corporate Policy Informational Banner
                  _buildPolicyInfoBanner(),

                  AppSpaces.vSpace16,

                  // 2. Dynamic Categories delivered by backend
                  ...prefs.categories.entries.map((entry) {
                    return PreferenceCategoryCard(
                      kind: entry.key,
                      preference: entry.value,
                      onToggle: (channel, val) => controller.togglePreferenceChannel(
                        kind: entry.key,
                        channel: channel,
                        newValue: val,
                      ),
                    );
                  }),

                  AppSpaces.vSpace20,
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Informational Card explaining In-App Bell and push delivery policies
  Widget _buildPolicyInfoBanner() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: AppColors.borderColor, width: 1.w),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h), // Signature padding
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(7.r),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.secondary,
                      size: 20.sp,
                    ),
                  ),
                  AppSpaces.hSpace12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Corporate Delivery Policies',
                          style: AppTextStyles.text14.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        AppSpaces.vSpace4,
                        Text(
                          '• In-app bell alerts are mandatory and cannot be disabled.\n'
                          '• Notifications are securely retained in your inbox for 90 days.\n'
                          '• Push and email preferences update instantly across your devices.',
                          style: AppTextStyles.text12.copyWith(
                            color: AppColors.textColor.withValues(alpha: 0.8),
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 3.h,
              width: double.infinity,
              color: AppColors.secondary, // Signature bottom accent
            ),
          ],
        ),
      ),
    );
  }
}
