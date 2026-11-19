import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../controller/helpdesk_controller.dart';
import '../../model/helpdesk_model.dart';
import 'helpdesk_ticket_details_bottom_sheet.dart';

class HelpdeskTicketCard extends GetView<HelpdeskController> {
  final HelpdeskTicketModel ticket;

  const HelpdeskTicketCard({
    super.key,
    required this.ticket,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      accentColor: ticket.statusColor,
      accentWidth: 3.w,
      onTap: () {
        controller.openTicketDetails(ticket);
        HelpdeskTicketDetailsBottomSheet.show(context, ticket: ticket);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Reference, Category, Confidential Badge & Status Chip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left: Reference & Category
              Expanded(
                child: Wrap(
                  spacing: 6.w,
                  runSpacing: 4.h,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        ticket.reference,
                        style: AppTextStyles.text10.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        ticket.category,
                        style: AppTextStyles.text10.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                    if (ticket.isConfidential)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lock_rounded, size: 10.sp, color: AppColors.error),
                            AppSpaces.hSpace4,
                            Text(
                              'Confidential',
                              style: AppTextStyles.text10.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // Right: Status Chip
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: ticket.statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6.r,
                      height: 6.r,
                      decoration: BoxDecoration(
                        color: ticket.statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    AppSpaces.hSpace6,
                    Text(
                      ticket.statusLabel,
                      style: AppTextStyles.text10.copyWith(
                        fontWeight: FontWeight.bold,
                        color: ticket.statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          AppSpaces.vSpace10,

          // 2. Subject Line
          Text(
            ticket.subject,
            style: AppTextStyles.text14.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          AppSpaces.vSpace12,

          // 3. Footer: Priority Badge, Date & Messages Counter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Priority Indicator
              Row(
                children: [
                  Icon(
                    Icons.flag_rounded,
                    size: 13.sp,
                    color: ticket.priorityColor,
                  ),
                  AppSpaces.hSpace4,
                  Text(
                    '${ticket.priority.capitalizeFirst} Priority',
                    style: AppTextStyles.text10.copyWith(
                      fontWeight: FontWeight.bold,
                      color: ticket.priorityColor,
                    ),
                  ),
                ],
              ),

              // Date / Activity
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 12.sp,
                    color: AppColors.subTextColor,
                  ),
                  AppSpaces.hSpace4,
                  Text(
                    _formatDate(ticket.lastActivityAt ?? ticket.createdAt),
                    style: AppTextStyles.text10.copyWith(
                      color: AppColors.subTextColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String isoString) {
    try {
      final dt = DateTime.parse(isoString).toLocal();
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return isoString.split('T').first;
    }
  }
}
