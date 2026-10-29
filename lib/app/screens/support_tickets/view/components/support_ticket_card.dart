import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../model/support_ticket_model.dart';

/// Signature Floating Card for a Support Ticket (Phase 10)
/// Strictly adheres to .agents/rules/ams.md:
/// - Inside padding: strictly 12.w horizontal, 14.h vertical
/// - Border radius: 15.r
/// - Signature status tone bottom border accent: 3.w
class SupportTicketCard extends StatelessWidget {
  final SupportTicketItemModel ticket;
  final VoidCallback onTap;

  const SupportTicketCard({
    super.key,
    required this.ticket,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = ticket.statusColor;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: AppColors.borderColor, width: 1.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.r),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: AppColors.primary.withValues(alpha: 0.06),
            highlightColor: AppColors.secondary.withValues(alpha: 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 14.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Ticket # + Category + Status Chip
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Ticket Number Badge
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              '#${ticket.number}',
                              style: AppTextStyles.text12.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          AppSpaces.hSpace8,

                          // Category Chip
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 7.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.borderColor.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              ticket.formattedCategory,
                              style: AppTextStyles.text10.copyWith(
                                color: AppColors.subTextColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          const Spacer(),

                          // Status Tone Badge
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: statusColor.withValues(alpha: 0.4),
                                width: 1.w,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6.r,
                                  height: 6.r,
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                AppSpaces.hSpace6,
                                Text(
                                  ticket.status.toUpperCase(),
                                  style: AppTextStyles.text10.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      AppSpaces.vSpace10,

                      // Subject Title
                      Text(
                        ticket.subject,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.text14.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor,
                          height: 1.3,
                        ),
                      ),

                      AppSpaces.vSpace10,

                      // Footer Row: Priority, Raised By & Date
                      Row(
                        children: [
                          // Priority indicator
                          Icon(
                            Icons.flag_rounded,
                            size: 13.sp,
                            color: ticket.priority == 'urgent' ||
                                    ticket.priority == 'high'
                                ? AppColors.error
                                : AppColors.subTextColor,
                          ),
                          AppSpaces.hSpace4,
                          Text(
                            ticket.formattedPriority,
                            style: AppTextStyles.text10.copyWith(
                              color: ticket.priority == 'urgent' ||
                                      ticket.priority == 'high'
                                  ? AppColors.error
                                  : AppColors.subTextColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          if (ticket.raisedBy != null &&
                              ticket.raisedBy!.isNotEmpty) ...[
                            AppSpaces.hSpace8,
                            Text(
                              '•',
                              style: TextStyle(
                                color: AppColors.subTextColor,
                                fontSize: 10.sp,
                              ),
                            ),
                            AppSpaces.hSpace8,
                            Expanded(
                              child: Text(
                                ticket.raisedBy!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.text10.copyWith(
                                  color: AppColors.subTextColor,
                                ),
                              ),
                            ),
                          ] else
                            const Spacer(),

                          // Updated Date
                          if (ticket.formattedDate.isNotEmpty) ...[
                            Icon(
                              Icons.access_time_rounded,
                              size: 12.sp,
                              color: AppColors.subTextColor,
                            ),
                            AppSpaces.hSpace4,
                            Text(
                              ticket.formattedDate,
                              style: AppTextStyles.text10.copyWith(
                                color: AppColors.subTextColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Signature Bottom Accent Border (3.w)
                Container(
                  height: 3.w,
                  width: double.infinity,
                  color: statusColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
