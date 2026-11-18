import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../model/document_model.dart';

class PolicyCard extends StatelessWidget {
  final CompanyDocumentListItemModel policy;
  final VoidCallback onTap;

  const PolicyCard({
    super.key,
    required this.policy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool needsAck = policy.requiresAcknowledgement && policy.acknowledged == false;
    final bool isAcked = policy.requiresAcknowledgement && policy.acknowledged == true;

    return CustomCard(
      onTap: onTap,
      margin: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Title & Version Pill
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  policy.title,
                  style: AppTextStyles.text14.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textColor,
                  ),
                ),
              ),
              AppSpaces.hSpace8,
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'v${policy.version}',
                  style: AppTextStyles.text10.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),

          if (policy.description != null && policy.description!.isNotEmpty) ...[
            AppSpaces.vSpace6,
            Text(
              policy.description!,
              style: AppTextStyles.text12.copyWith(
                color: AppColors.subTextColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          AppSpaces.vSpace10,

          // Footer Row: Published date & Acknowledgment Status Pill
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 13.w,
                color: AppColors.subTextColor,
              ),
              AppSpaces.hSpace6,
              Text(
                policy.publishedOn != null
                    ? 'Published: ${policy.publishedOn}'
                    : 'Active Policy',
                style: AppTextStyles.text10.copyWith(
                  color: AppColors.subTextColor,
                ),
              ),
              const Spacer(),
              if (needsAck)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.4),
                      width: 1.w,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.pending_actions_rounded,
                        size: 12.w,
                        color: AppColors.warning,
                      ),
                      AppSpaces.hSpace4,
                      Text(
                        'Action Required',
                        style: AppTextStyles.text10.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                )
              else if (isAcked)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.4),
                      width: 1.w,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 12.w,
                        color: AppColors.success,
                      ),
                      AppSpaces.hSpace4,
                      Text(
                        'Acknowledged',
                        style: AppTextStyles.text10.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
