import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../model/approval_model.dart';

class ApprovalRequestTile extends StatelessWidget {
  final ApprovalItemModel item;
  final VoidCallback onTap;

  const ApprovalRequestTile({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Check non-empty employee details
    final empSubItems = <String>[];
    if (item.employee != null) {
      if (item.employee!.name.trim().isNotEmpty) {
        empSubItems.add(item.employee!.name.trim());
      }
      if (item.employee!.number.trim().isNotEmpty) {
        empSubItems.add(item.employee!.number.trim());
      }
      if (item.employee!.department.trim().isNotEmpty) {
        empSubItems.add(item.employee!.department.trim());
      }
    }

    final hasWaitingOn =
        item.waitingOn != null && item.waitingOn!.trim().isNotEmpty;
    final hasSubmittedAgo =
        item.submittedAgo != null && item.submittedAgo!.trim().isNotEmpty;
    final hasDecidedAt =
        item.decidedAt != null && item.decidedAt!.trim().isNotEmpty;
    final hasBottomRow = hasWaitingOn || hasSubmittedAgo || hasDecidedAt;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: AppColors.borderColor, width: 0.8.w),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 10.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Type Tag & ULID vs Server Status Pill
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (item.typeLabel.isNotEmpty ||
                          item.type.isNotEmpty) ...[
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: item.toneBackgroundColor,
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(
                              color: item.toneColor.withValues(alpha: 0.3),
                              width: 0.8.w,
                            ),
                          ),
                          child: Text(
                            item.typeLabel.isNotEmpty
                                ? item.typeLabel
                                : item.type,
                            style: AppTextStyles.text10.copyWith(
                              fontWeight: FontWeight.bold,
                              color: item.toneColor,
                            ),
                          ),
                        ),
                        AppSpaces.hSpace8,
                      ],
                      if (item.id.isNotEmpty)
                        Text(
                          '#${item.id.length > 8 ? item.id.substring(0, 8) : item.id}',
                          style: AppTextStyles.text10.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.subTextColor,
                          ),
                        ),
                    ],
                  ),

                  // Status Pill with Icon
                  if (item.statusLabel.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: item.toneBackgroundColor,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: item.toneColor.withValues(alpha: 0.25),
                          width: 0.8.w,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.statusIcon,
                            size: 11.sp,
                            color: item.toneColor,
                          ),
                          AppSpaces.hSpace4,
                          Text(
                            item.statusLabel,
                            style: AppTextStyles.text10.copyWith(
                              fontWeight: FontWeight.bold,
                              color: item.toneColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              // Title
              if (item.title.isNotEmpty) ...[
                AppSpaces.vSpace8,
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.text14.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
              ],

              // Employee subtitle (only if non-empty)
              if (empSubItems.isNotEmpty) ...[
                AppSpaces.vSpace4,
                Row(
                  children: [
                    Icon(
                      Icons.person_outline_rounded,
                      size: 13.sp,
                      color: AppColors.subTextColor,
                    ),
                    AppSpaces.hSpace4,
                    Expanded(
                      child: Text(
                        empSubItems.join(' • '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.text10.copyWith(
                          color: AppColors.subTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              // Changes Preview (only if non-empty)
              if (item.changes.isNotEmpty &&
                  item.changes.first.label.isNotEmpty) ...[
                AppSpaces.vSpace8,
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.swap_horiz_rounded,
                        size: 14.sp,
                        color: AppColors.secondary,
                      ),
                      AppSpaces.hSpace6,
                      Expanded(
                        child: Text(
                          'Change: ${item.changes.first.label}'
                          '${item.changes.first.after != null && item.changes.first.after!.isNotEmpty ? ' (${item.changes.first.after})' : ''}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.text10.copyWith(
                            color: AppColors.textColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (item.facts.isNotEmpty &&
                  item.facts.any(
                    (f) => f.label.isNotEmpty && f.value.isNotEmpty,
                  )) ...[
                AppSpaces.vSpace8,
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    item.facts
                        .where((f) => f.label.isNotEmpty && f.value.isNotEmpty)
                        .map((f) => '${f.label}: ${f.value}')
                        .join('  •  '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.text10.copyWith(
                      color: AppColors.textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],

              // Bottom Row: Submitted ago + Waiting On (hides if both are absent)
              if (hasBottomRow) ...[
                AppSpaces.vSpace8,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (hasSubmittedAgo)
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 12.sp,
                            color: AppColors.subTextColor,
                          ),
                          AppSpaces.hSpace4,
                          Text(
                            item.submittedAgo!,
                            style: AppTextStyles.text10.copyWith(
                              color: AppColors.subTextColor,
                            ),
                          ),
                        ],
                      )
                    else
                      const SizedBox.shrink(),
                    if (hasWaitingOn)
                      Row(
                        children: [
                          Icon(
                            Icons.pending_actions_rounded,
                            size: 12.sp,
                            color: AppColors.secondary,
                          ),
                          AppSpaces.hSpace4,
                          Text(
                            'Waiting on: ${item.waitingOn}',
                            style: AppTextStyles.text10.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      )
                    else if (hasDecidedAt)
                      Text(
                        'Decided',
                        style: AppTextStyles.text10.copyWith(
                          fontWeight: FontWeight.w600,
                          color: item.toneColor,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
