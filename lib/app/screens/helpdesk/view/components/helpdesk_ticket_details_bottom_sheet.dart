import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../controller/helpdesk_controller.dart';
import '../../model/helpdesk_model.dart';

class HelpdeskTicketDetailsBottomSheet extends StatelessWidget {
  final HelpdeskTicketModel ticket;

  const HelpdeskTicketDetailsBottomSheet({
    super.key,
    required this.ticket,
  });

  static Future<void> show(
    BuildContext context, {
    required HelpdeskTicketModel ticket,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HelpdeskTicketDetailsBottomSheet(ticket: ticket),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HelpdeskController>();

    return Container(
      height: 0.88.sh,
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 10.h, bottom: 8.h),
              width: 38.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.borderColor,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
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
                          AppSpaces.hSpace8,
                          Text(
                            ticket.category,
                            style: AppTextStyles.text10.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                      AppSpaces.vSpace4,
                      Text(
                        ticket.subject,
                        style: AppTextStyles.text16.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, size: 22.sp, color: AppColors.subTextColor),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
          ),

          Divider(color: AppColors.borderColor, height: 1.h),

          // Ticket Status & Action Strip
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            color: AppColors.cardBackground,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8.r,
                      height: 8.r,
                      decoration: BoxDecoration(
                        color: ticket.statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    AppSpaces.hSpace6,
                    Text(
                      ticket.statusLabel,
                      style: AppTextStyles.text12.copyWith(
                        fontWeight: FontWeight.bold,
                        color: ticket.statusColor,
                      ),
                    ),
                    AppSpaces.hSpace12,
                    Text(
                      '${ticket.priority.capitalizeFirst} Priority',
                      style: AppTextStyles.text10.copyWith(
                        color: ticket.priorityColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (ticket.isOpen || ticket.isInProgress)
                  Obx(() {
                    if (controller.isCancelling.value) {
                      return SizedBox(
                        width: 16.r,
                        height: 16.r,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.w,
                          color: AppColors.error,
                        ),
                      );
                    }
                    return InkWell(
                      onTap: () => controller.cancelTicket(ticket.id),
                      borderRadius: BorderRadius.circular(6.r),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                        child: Text(
                          'Cancel Ticket',
                          style: AppTextStyles.text10.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),

          Divider(color: AppColors.borderColor, height: 1.h),

          // Message Thread List
          Expanded(
            child: Obx(() {
              if (controller.isDetailsLoading.value) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AppColors.secondary,
                    strokeWidth: 2.5.w,
                  ),
                );
              }

              final activeTicket = controller.selectedTicket.value ?? ticket;
              final messages = activeTicket.messages;

              if (messages.isEmpty) {
                return Center(
                  child: Text(
                    'No messages in this conversation yet.',
                    style: AppTextStyles.text12.copyWith(
                      color: AppColors.subTextColor,
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                itemCount: messages.length,
                separatorBuilder: (_, _) => AppSpaces.vSpace12,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  return _buildMessageBubble(msg);
                },
              );
            }),
          ),

          // Reply Bar
          if (ticket.isOpen || ticket.isInProgress || ticket.isWaitingOnUser)
            _buildReplyInput(controller),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(HelpdeskMessageModel msg) {
    final isMe = msg.fromRaiser;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: 0.78.sw),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isMe ? AppColors.secondary : AppColors.cardBackground,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(14.r),
            topRight: Radius.circular(14.r),
            bottomLeft: isMe ? Radius.circular(14.r) : Radius.circular(2.r),
            bottomRight: isMe ? Radius.circular(2.r) : Radius.circular(14.r),
          ),
          border: Border.all(
            color: isMe ? Colors.transparent : AppColors.borderColor,
            width: 0.8.w,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Author Name
            Text(
              msg.author,
              style: AppTextStyles.text10.copyWith(
                fontWeight: FontWeight.bold,
                color: isMe ? Colors.white.withValues(alpha: 0.85) : AppColors.primary,
              ),
            ),
            AppSpaces.vSpace4,

            // Message Body
            Text(
              msg.body,
              style: AppTextStyles.text12.copyWith(
                color: isMe ? Colors.white : AppColors.textColor,
                height: 1.35,
              ),
            ),
            AppSpaces.vSpace4,

            // Timestamp
            Text(
              _formatTime(msg.createdAt),
              style: AppTextStyles.text10.copyWith(
                fontSize: 8.5.sp,
                color: isMe
                    ? Colors.white.withValues(alpha: 0.7)
                    : AppColors.subTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyInput(HelpdeskController controller) {
    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 14.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(top: BorderSide(color: AppColors.borderColor, width: 0.8.w)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: AppColors.borderColor, width: 0.8.w),
                ),
                child: TextField(
                  controller: controller.messageController,
                  focusNode: controller.messageFocusNode,
                  style: AppTextStyles.text12.copyWith(color: AppColors.textColor),
                  decoration: InputDecoration(
                    hintText: 'Type your reply message...',
                    hintStyle: AppTextStyles.text12.copyWith(color: AppColors.subTextColor),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                  ),
                  maxLines: 4,
                  minLines: 1,
                ),
              ),
            ),
            AppSpaces.hSpace8,
            Obx(() {
              final isSending = controller.isPostingMessage.value;
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isSending ? null : controller.sendReplyMessage,
                  borderRadius: BorderRadius.circular(20.r),
                  child: Container(
                    width: 40.r,
                    height: 40.r,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isSending
                          ? SizedBox(
                              width: 18.r,
                              height: 18.r,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              Icons.send_rounded,
                              size: 18.sp,
                              color: Colors.white,
                            ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _formatTime(String isoString) {
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } catch (_) {
      return '';
    }
  }
}
