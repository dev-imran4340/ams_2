import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../controller/support_ticket_controller.dart';
import '../../model/support_ticket_model.dart';

/// Modal bottom sheet showing full discussion thread of a Support Ticket
class TicketThreadBottomSheet extends StatefulWidget {
  final SupportTicketController controller;

  const TicketThreadBottomSheet({
    super.key,
    required this.controller,
  });

  static void show(BuildContext context, SupportTicketController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TicketThreadBottomSheet(controller: controller),
    );
  }

  @override
  State<TicketThreadBottomSheet> createState() =>
      _TicketThreadBottomSheetState();
}

class _TicketThreadBottomSheetState extends State<TicketThreadBottomSheet> {
  final _picker = ImagePicker();

  Future<void> _pickReplyAttachment(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (picked != null) {
        final file = File(picked.path);
        final bytes = await file.length();
        if (bytes > 5 * 1024 * 1024) {
          CustomSnackbar.showError(
            message: 'Attachment file size exceeds 5 MB limit.',
          );
          return;
        }
        widget.controller.addReplyAttachment(file);
      }
    } catch (_) {
      CustomSnackbar.showError(message: 'Failed to select attachment.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.92.sh,
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Obx(() {
        final ticket = widget.controller.selectedTicket.value;
        if (ticket == null) {
          return Center(
            child: CircularProgressIndicator(
              color: AppColors.secondary,
            ),
          );
        }

        final statusColor = ticket.statusColor;

        return Column(
          children: [
            // Drag Handle
            AppSpaces.vSpace12,
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.borderColor,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            AppSpaces.vSpace8,

            // Ticket Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Ticket # Badge
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

                      // Status Badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: statusColor.withValues(alpha: 0.4),
                            width: 1.w,
                          ),
                        ),
                        child: Text(
                          ticket.status.toUpperCase(),
                          style: AppTextStyles.text10.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Close / Reopen Action Button
                      if (ticket.isOpen)
                        TextButton.icon(
                          onPressed:
                              widget.controller.isChangingStatus.value
                                  ? null
                                  : widget.controller.closeTicket,
                          icon: Icon(
                            Icons.check_circle_outline_rounded,
                            size: 15.sp,
                            color: AppColors.error,
                          ),
                          label: Text(
                            'Close',
                            style: AppTextStyles.text12.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        )
                      else if (ticket.canReopen)
                        TextButton.icon(
                          onPressed:
                              widget.controller.isChangingStatus.value
                                  ? null
                                  : widget.controller.reopenTicket,
                          icon: Icon(
                            Icons.refresh_rounded,
                            size: 15.sp,
                            color: AppColors.secondary,
                          ),
                          label: Text(
                            'Reopen',
                            style: AppTextStyles.text12.copyWith(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),

                      IconButton(
                        onPressed: () => Get.back(),
                        icon: Icon(
                          Icons.close_rounded,
                          color: AppColors.subTextColor,
                          size: 22.sp,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  AppSpaces.vSpace8,

                  // Subject Title
                  Text(
                    ticket.subject,
                    style: AppTextStyles.text16.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textColor,
                    ),
                  ),

                  AppSpaces.vSpace6,

                  // Category & Priority
                  Row(
                    children: [
                      Text(
                        'Category: ${ticket.category.toUpperCase()}',
                        style: AppTextStyles.text10.copyWith(
                          color: AppColors.subTextColor,
                        ),
                      ),
                      AppSpaces.hSpace8,
                      Text(
                        '•',
                        style: TextStyle(
                          color: AppColors.subTextColor,
                          fontSize: 10.sp,
                        ),
                      ),
                      AppSpaces.hSpace8,
                      Text(
                        'Priority: ${ticket.priority.toUpperCase()}',
                        style: AppTextStyles.text10.copyWith(
                          color: ticket.priority == 'urgent' ||
                                  ticket.priority == 'high'
                              ? AppColors.error
                              : AppColors.subTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Divider(color: AppColors.borderColor, height: 16.h),

            // Discussion Thread Messages
            Expanded(
              child: ListView.builder(
                controller: widget.controller.threadScrollController,
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 8.h,
                ),
                itemCount: ticket.messages.length,
                itemBuilder: (ctx, index) {
                  final msg = ticket.messages[index];
                  return _buildMessageBubble(msg);
                },
              ),
            ),

            // Bottom Reply Bar or Status Notice
            _buildBottomReplyBar(ticket),
          ],
        );
      }),
    );
  }

  Widget _buildMessageBubble(SupportMessageModel msg) {
    final isFromUs = msg.fromUs;

    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Column(
        crossAxisAlignment:
            isFromUs ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          // Author Header
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isFromUs) ...[
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 6.w,
                    vertical: 2.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    'SUPPORT TEAM',
                    style: AppTextStyles.text10.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 8.sp,
                    ),
                  ),
                ),
                AppSpaces.hSpace6,
              ],
              Text(
                msg.author,
                style: AppTextStyles.text12.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
              AppSpaces.hSpace8,
              Text(
                msg.formattedTime,
                style: AppTextStyles.text10.copyWith(
                  color: AppColors.subTextColor,
                ),
              ),
            ],
          ),
          AppSpaces.vSpace4,

          // Message Container
          Container(
            constraints: BoxConstraints(maxWidth: 0.78.sw),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: isFromUs
                  ? AppColors.cardBackground
                  : AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
                bottomLeft: Radius.circular(isFromUs ? 0 : 12.r),
                bottomRight: Radius.circular(isFromUs ? 12.r : 0),
              ),
              border: Border.all(
                color: isFromUs
                    ? AppColors.borderColor
                    : AppColors.primary.withValues(alpha: 0.2),
                width: 1.w,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  msg.body,
                  style: AppTextStyles.text12.copyWith(
                    color: AppColors.textColor,
                    height: 1.35,
                  ),
                ),

                // Attachments inside Message
                if (msg.attachments.isNotEmpty) ...[
                  AppSpaces.vSpace8,
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 6.h,
                    children: msg.attachments.map((att) {
                      return Obx(() {
                        final isDownloading =
                            widget.controller.isDownloadingFile.value &&
                                widget.controller.downloadingFileId.value ==
                                    att.id;

                        return InkWell(
                          onTap: isDownloading
                              ? null
                              : () => widget.controller.openAttachment(att),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundColor,
                              borderRadius: BorderRadius.circular(6.r),
                              border: Border.all(
                                color: AppColors.borderColor,
                                width: 1.w,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isDownloading)
                                  SizedBox(
                                    width: 12.r,
                                    height: 12.r,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.w,
                                      color: AppColors.secondary,
                                    ),
                                  )
                                else
                                  Icon(
                                    Icons.file_present_rounded,
                                    size: 13.sp,
                                    color: AppColors.secondary,
                                  ),
                                AppSpaces.hSpace4,
                                ConstrainedBox(
                                  constraints:
                                      BoxConstraints(maxWidth: 130.w),
                                  child: Text(
                                    att.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.text10.copyWith(
                                      color: AppColors.secondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                AppSpaces.hSpace4,
                                Text(
                                  '(${att.formattedSize})',
                                  style: AppTextStyles.text10.copyWith(
                                    color: AppColors.subTextColor,
                                    fontSize: 8.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      });
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomReplyBar(SupportTicketDetailsModel ticket) {
    if (ticket.isClosed) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.borderColor.withValues(alpha: 0.3),
          border: Border(top: BorderSide(color: AppColors.borderColor)),
        ),
        child: Text(
          'This ticket is closed. Reopen this ticket or raise a new inquiry.',
          textAlign: TextAlign.center,
          style: AppTextStyles.text12.copyWith(
            color: AppColors.subTextColor,
          ),
        ),
      );
    }

    if (!widget.controller.canRaise) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.borderColor.withValues(alpha: 0.3),
          border: Border(top: BorderSide(color: AppColors.borderColor)),
        ),
        child: Text(
          'You do not have permission to reply to support tickets.',
          textAlign: TextAlign.center,
          style: AppTextStyles.text12.copyWith(
            color: AppColors.subTextColor,
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.only(
        left: 12.w,
        right: 12.w,
        top: 8.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 12.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(top: BorderSide(color: AppColors.borderColor)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6.r,
            offset: Offset(0, -2.h),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Reply Attachments Chips
          Obx(() {
            final atts = widget.controller.replyAttachments;
            if (atts.isEmpty) return const SizedBox.shrink();

            return Padding(
              padding: EdgeInsets.only(bottom: 6.h),
              child: Wrap(
                spacing: 6.w,
                runSpacing: 4.h,
                children: List.generate(atts.length, (idx) {
                  final f = atts[idx];
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.attach_file_rounded,
                          size: 12.sp,
                          color: AppColors.primary,
                        ),
                        AppSpaces.hSpace4,
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 130.w),
                          child: Text(
                            f.path.split('/').last,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.text10,
                          ),
                        ),
                        AppSpaces.hSpace4,
                        GestureDetector(
                          onTap: () =>
                              widget.controller.removeReplyAttachment(idx),
                          child: Icon(
                            Icons.cancel_rounded,
                            size: 13.sp,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            );
          }),

          // Input Row
          Row(
            children: [
              // Attachment Picker Button
              PopupMenuButton<ImageSource>(
                icon: Icon(
                  Icons.attach_file_rounded,
                  color: AppColors.secondary,
                  size: 22.sp,
                ),
                padding: EdgeInsets.zero,
                onSelected: (source) => _pickReplyAttachment(source),
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: ImageSource.camera,
                    child: Row(
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          size: 18.sp,
                          color: AppColors.primary,
                        ),
                        AppSpaces.hSpace8,
                        Text('Camera', style: AppTextStyles.text12),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: ImageSource.gallery,
                    child: Row(
                      children: [
                        Icon(
                          Icons.photo_library_outlined,
                          size: 18.sp,
                          color: AppColors.primary,
                        ),
                        AppSpaces.hSpace8,
                        Text('Gallery', style: AppTextStyles.text12),
                      ],
                    ),
                  ),
                ],
              ),

              // Text Field
              Expanded(
                child: TextField(
                  controller: widget.controller.replyController,
                  maxLines: 3,
                  minLines: 1,
                  style: AppTextStyles.text12.copyWith(
                    color: AppColors.textColor,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Type your reply message...',
                    hintStyle: AppTextStyles.text12.copyWith(
                      color: AppColors.subTextColor,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    filled: true,
                    fillColor: AppColors.backgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.r),
                      borderSide: BorderSide(color: AppColors.borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.r),
                      borderSide: BorderSide(color: AppColors.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.r),
                      borderSide: BorderSide(color: AppColors.secondary),
                    ),
                  ),
                ),
              ),

              AppSpaces.hSpace8,

              // Send Button
              Obx(() {
                final isReplying = widget.controller.isReplying.value;
                return InkWell(
                  onTap: isReplying ? null : widget.controller.sendReply,
                  borderRadius: BorderRadius.circular(24.r),
                  child: Container(
                    width: 38.r,
                    height: 38.r,
                    decoration: BoxDecoration(
                      gradient: isReplying
                          ? null
                          : LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.secondary,
                              ],
                            ),
                      color: isReplying ? AppColors.subTextColor : null,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isReplying
                          ? SizedBox(
                              width: 16.r,
                              height: 16.r,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.w,
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 18.sp,
                            ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}
