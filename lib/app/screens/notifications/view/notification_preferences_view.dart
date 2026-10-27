import 'package:ams_2/app/core/widgets/custom_screen_header.dart';
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

        body: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            child: Column(
              children: [
                CustomScreenHeader(
                  title: 'Notification Preferences',
                  subtitle: 'Manage your preferences for different notification channels',

                  onBack: () => Get.back(),
                ),
                AppSpaces.vSpace12,
                Expanded(
                  child: Obx(() {
                    final prefs = controller.preferences.value;

                    if (controller.isLoadingPreferences.value &&
                        prefs.categories.isEmpty) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2.5.w,
                        ),
                      );
                    }

                    if (prefs.categories.isEmpty) {
                      return Center(
                        child: CustomStateView.empty(
                          title: 'No Settings Available',
                          message:
                              'Failed to retrieve notification channel preferences from server.',
                          buttonText: 'Retry',
                          onAction: controller.loadPreferences,
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

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (controller.isLoadingPreferences.value) ...[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(2.r),
                                child: LinearProgressIndicator(
                                  backgroundColor:
                                      AppColors.primary.withValues(alpha: 0.1),
                                  color: AppColors.secondary,
                                  minHeight: 2.5.h,
                                ),
                              ),
                              AppSpaces.vSpace10,
                            ],

                            // 1. Corporate Policy Informational Banner
                            _buildPolicyInfoBanner(),

                            AppSpaces.vSpace16,

                            // 2. Dynamic Categories delivered by backend
                            ...prefs.categories.entries.map((entry) {
                              return PreferenceCategoryCard(
                                kind: entry.key,
                                preference: entry.value,
                                onToggle: (channel, val) =>
                                    controller.togglePreferenceChannel(
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
              ],
            ),
          ),
        ),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 14.h,
            ), // Signature padding
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
        ],
      ),
    );
  }
}
