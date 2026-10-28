import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../model/notification_preferences_model.dart';

/// Floating Card representing an individual Notification Category and its 3 channels (Bell, Push, Email)
class PreferenceCategoryCard extends StatelessWidget {
  final String kind;
  final ChannelPreferenceModel preference;
  final Function(String channel, bool value) onToggle;

  const PreferenceCategoryCard({
    super.key,
    required this.kind,
    required this.preference,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final title = NotificationPreferencesModel.getKindLabel(kind);
    final description = NotificationPreferencesModel.getKindDescription(kind);
    final icon = NotificationPreferencesModel.getKindIcon(kind);

    return CustomCard(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 14.h,
            ), // Signature padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Category Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(icon, size: 20.sp, color: AppColors.primary),
                    ),
                    AppSpaces.hSpace10,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTextStyles.text14.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor,
                            ),
                          ),
                          AppSpaces.vSpace4,
                          Text(
                            description,
                            style: AppTextStyles.text12.copyWith(
                              color: AppColors.subTextColor,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                AppSpaces.vSpace14,
                Divider(color: AppColors.borderColor, height: 1.h),
                AppSpaces.vSpace10,

                // 2. Channel 1: In-App Bell (Server Invariant: Locked ON)
                _buildChannelRow(
                  title: 'In-App Notifications (Bell)',
                  subtitle: 'Core inbox alerts; cannot be switched off',
                  icon: Icons.notifications_active_outlined,
                  value: true,
                  isLocked: true,
                  onChanged: (val) {},
                ),

                AppSpaces.vSpace8,

                // 3. Channel 2: Push Notifications (FCM)
                _buildChannelRow(
                  title: 'Push Notifications',
                  subtitle: 'Real-time banners sent directly to this device',
                  icon: Icons.phone_android_rounded,
                  value: preference.push,
                  isLocked: false,
                  onChanged: (val) => onToggle('push', val),
                ),

                AppSpaces.vSpace8,

                // 4. Channel 3: Email Notifications
                _buildChannelRow(
                  title: 'Email Notifications',
                  subtitle: 'Formal email alerts delivered to company inbox',
                  icon: Icons.mail_outline_rounded,
                  value: preference.mail,
                  isLocked: false,
                  onChanged: (val) => onToggle('mail', val),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChannelRow({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required bool isLocked,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18.sp,
          color: isLocked ? AppColors.secondary : AppColors.primary,
        ),
        AppSpaces.hSpace10,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: AppTextStyles.text12.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor,
                    ),
                  ),
                  if (isLocked) ...[
                    AppSpaces.hSpace6,
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 5.w,
                        vertical: 1.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.liteSecondary.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.lock_outline_rounded,
                            size: 10.sp,
                            color: AppColors.secondary,
                          ),
                          AppSpaces.hSpace2,
                          Text(
                            'Always On',
                            style: AppTextStyles.text10.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              AppSpaces.vSpace2,
              Text(
                subtitle,
                style: AppTextStyles.text10.copyWith(
                  color: AppColors.subTextColor,
                ),
              ),
            ],
          ),
        ),
        CupertinoSwitch(
          value: value,
          activeTrackColor: AppColors.secondary,
          onChanged: isLocked ? null : onChanged,
        ),
      ],
    );
  }
}
