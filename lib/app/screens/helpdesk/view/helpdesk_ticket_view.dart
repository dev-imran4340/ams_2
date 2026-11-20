import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_spaces.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/custom_screen_header.dart';
import '../../../core/widgets/custom_state_view.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/employee_ambient_header.dart';
import '../../../core/widgets/network_boundary_wrapper.dart';
import '../controller/helpdesk_controller.dart';
import '../model/helpdesk_model.dart';

class HelpdeskTicketView extends StatefulWidget {
  const HelpdeskTicketView({super.key});

  @override
  State<HelpdeskTicketView> createState() => _HelpdeskTicketViewState();
}

class _HelpdeskTicketViewState extends State<HelpdeskTicketView> {
  final HelpdeskController controller = Get.find<HelpdeskController>();
  String? _effectiveTicketId;

  @override
  void initState() {
    super.initState();
    final dynamic args = Get.arguments;
    _effectiveTicketId = args is String
        ? args
        : (args is Map ? args['ticketId']?.toString() : null);

    _effectiveTicketId ??= controller.selectedTicket.value?.id;

    if (_effectiveTicketId != null && _effectiveTicketId!.isNotEmpty) {
      controller.loadTicketById(_effectiveTicketId!);
      controller.startChatPolling(_effectiveTicketId!);
    }
  }

  @override
  void dispose() {
    controller.stopChatPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ticketId = _effectiveTicketId ?? controller.selectedTicket.value?.id;

    return NetworkBoundaryWrapper(
      onRetry: () async {
        final current = controller.selectedTicket.value;
        if (current != null) {
          await controller.loadTicketById(current.id);
        } else if (ticketId != null) {
          await controller.loadTicketById(ticketId);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Stack(
          children: [
            // 1. Signature Ambient Curved Gradient Header
            EmployeeAmbientHeader(height: 140.h),

            // 2. Foreground Layout
            SafeArea(
              child: Column(
                children: [
                  // Top Navigation Header
                  Padding(
                    padding: AppSpaces.horizontalPadding,
                    child: Obx(() {
                      final ticket = controller.selectedTicket.value;
                      final ref = ticket?.reference ?? 'Helpdesk Ticket';
                      final cat = ticket?.category ?? 'Inquiry';

                      return CustomScreenHeader(
                        title: ref,
                        subtitle: '$cat • Discussion',
                        showBackButton: true,
                        onBack: () => Get.back(),
                        actions:
                            (ticket != null &&
                                (ticket.isOpen || ticket.isInProgress))
                            ? [
                                CustomScreenHeader.actionButton(
                                  icon: Icons.cancel_outlined,
                                  iconColor: AppColors.error,
                                  tooltip: 'Cancel Ticket',
                                  onTap: () =>
                                      _confirmCancelTicket(context, ticket.id),
                                ),
                              ]
                            : null,
                      );
                    }),
                  ),

                  AppSpaces.vSpace8,

                  // Body Content with Ticket Details Banner & Chat Stream
                  Expanded(
                    child: Obx(() {
                      if (controller.isDetailsLoading.value &&
                          controller.selectedTicket.value == null) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppColors.secondary,
                            strokeWidth: 2.5.w,
                          ),
                        );
                      }

                      final ticket = controller.selectedTicket.value;
                      if (ticket == null) {
                        return Center(
                          child: CustomStateView.empty(
                            icon: Icons.confirmation_number_outlined,
                            title: 'Ticket Not Found',
                            message: 'Could not load details for this helpdesk ticket.',
                          ),
                        );
                      }

                      return Column(
                        children: [
                          // Ticket Summary Card
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14.w),
                            child: _buildTicketSummaryCard(ticket),
                          ),

                          AppSpaces.vSpace8,

                          // Messages Conversation Stream
                          Expanded(child: _buildMessagesList(ticket)),

                          // Sticky Bottom Reply Bar
                          _buildBottomReplyBar(context, ticket),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Compact header summary of ticket subject, status, and priority
  Widget _buildTicketSummaryCard(HelpdeskTicketModel ticket) {
    return CustomCard(
      accentColor: ticket.statusColor,
      accentWidth: 3.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Status Pill & Priority
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: ticket.statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8.r),
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
                  AppSpaces.hSpace8,
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 7.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: ticket.priorityColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      '${ticket.priority.capitalizeFirst} Priority',
                      style: AppTextStyles.text10.copyWith(
                        fontWeight: FontWeight.bold,
                        color: ticket.priorityColor,
                      ),
                    ),
                  ),
                ],
              ),

              // Right: Confidential Pill (if applicable)
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
                      Icon(
                        Icons.lock_rounded,
                        size: 10.sp,
                        color: AppColors.error,
                      ),
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

          AppSpaces.vSpace8,

          // Subject Line
          Text(
            ticket.subject,
            style: AppTextStyles.text14.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Messages List
  Widget _buildMessagesList(HelpdeskTicketModel ticket) {
    final messages = ticket.messages;

    if (messages.isEmpty) {
      return Center(
        child: Text(
          'No messages in this ticket thread yet.',
          style: AppTextStyles.text12.copyWith(color: AppColors.subTextColor),
        ),
      );
    }

    return ListView.separated(
      controller: controller.chatScrollController,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      itemCount: messages.length,
      separatorBuilder: (_, _) => AppSpaces.vSpace12,
      itemBuilder: (context, index) {
        final msg = messages[index];
        return _buildMessageBubble(msg);
      },
    );
  }

  /// Single message bubble (Raiser on Right vs HR/Handler on Left)
  Widget _buildMessageBubble(HelpdeskMessageModel msg) {
    final isMe = msg.fromRaiser;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: 0.80.sw),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isMe ? AppColors.secondary : AppColors.cardBackground,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: isMe ? Radius.circular(16.r) : Radius.circular(2.r),
            bottomRight: isMe ? Radius.circular(2.r) : Radius.circular(16.r),
          ),
          border: Border.all(
            color: isMe ? Colors.transparent : AppColors.borderColor,
            width: 0.8.w,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.05),
              blurRadius: 6.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            // Author Name
            Text(
              msg.author,
              style: AppTextStyles.text10.copyWith(
                fontWeight: FontWeight.bold,
                color: isMe
                    ? Colors.white.withValues(alpha: 0.85)
                    : AppColors.primary,
              ),
            ),
            AppSpaces.vSpace4,

            // Message Body Text
            Text(
              msg.body,
              style: AppTextStyles.text12.copyWith(
                color: isMe ? Colors.white : AppColors.textColor,
                height: 1.4,
              ),
            ),
            AppSpaces.vSpace4,

            // Timestamp
            Text(
              _formatTime(msg.createdAt),
              style: AppTextStyles.text10.copyWith(
                fontSize: 9.sp,
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

  /// Sticky Bottom Reply Input Bar with Reopen Notification Support
  Widget _buildBottomReplyBar(
    BuildContext context,
    HelpdeskTicketModel ticket,
  ) {
    final bool isCancelledOrClosed = ticket.isClosed;
    final bool isResolved = ticket.isResolved;

    if (isCancelledOrClosed) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          border: Border(
            top: BorderSide(color: AppColors.borderColor, width: 0.8.w),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Text(
            'This ticket is closed/cancelled and cannot receive new replies.',
            textAlign: TextAlign.center,
            style: AppTextStyles.text12.copyWith(
              color: AppColors.subTextColor,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 12.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(
          top: BorderSide(color: AppColors.borderColor, width: 0.8.w),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6.r,
            offset: Offset(0, -2.h),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // If resolved, indicate that replying reopens the ticket
            if (isResolved)
              Padding(
                padding: EdgeInsets.only(bottom: 6.h),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 12.sp,
                      color: AppColors.warning,
                    ),
                    AppSpaces.hSpace4,
                    Expanded(
                      child: Text(
                        'Ticket is marked resolved. Sending a message will automatically reopen it.',
                        style: AppTextStyles.text10.copyWith(
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: controller.messageController,
                    focusNode: controller.messageFocusNode,
                    hintText: 'Type your message to HR...',
                    maxLines: 4,
                    fillColor: AppColors.backgroundColor,
                    borderColor: AppColors.borderColor,
                    borderRadius: 20.r,
                    contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  ),
                ),
                AppSpaces.hSpace8,
                Obx(() {
                  final isSending = controller.isPostingMessage.value;
                  return Padding(
                    padding: EdgeInsets.only(bottom: 2.h),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: isSending ? null : controller.sendReplyMessage,
                        borderRadius: BorderRadius.circular(22.r),
                        child: Container(
                          width: 44.r,
                          height: 44.r,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.primary, AppColors.secondary],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.secondary.withValues(alpha: 0.3),
                                blurRadius: 6.r,
                                offset: Offset(0, 2.h),
                              ),
                            ],
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
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmCancelTicket(BuildContext context, String ticketId) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        backgroundColor: AppColors.cardBackground,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomStateView(
                icon: Icons.cancel_outlined,
                iconColor: AppColors.error,
                iconBackgroundColor: AppColors.error.withValues(alpha: 0.1),
                title: 'Cancel Ticket',
                message:
                    'Are you sure you want to withdraw and cancel this ticket?',
                padding: EdgeInsets.zero,
              ),
              AppSpaces.vSpace20,
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'No, Keep',
                      isOutlined: true,
                      borderColor: AppColors.borderColor,
                      textColor: AppColors.subTextColor,
                      height: 40.h,
                      borderRadius: 10.r,
                      onPressed: () => Get.back(),
                    ),
                  ),
                  AppSpaces.hSpace12,
                  Expanded(
                    child: CustomButton(
                      text: 'Yes, Cancel',
                      isGradient: true,
                      height: 40.h,
                      borderRadius: 10.r,
                      onPressed: () => controller.cancelTicket(ticketId),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(String isoString) {
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      return '$day/$month $hour:$minute';
    } catch (_) {
      return '';
    }
  }
}
