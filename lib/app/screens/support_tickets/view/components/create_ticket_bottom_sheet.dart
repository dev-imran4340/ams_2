import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../controller/support_ticket_controller.dart';

/// Modal bottom sheet for opening a new Support Ticket (Phase 10)
class CreateTicketBottomSheet extends StatefulWidget {
  final SupportTicketController controller;

  const CreateTicketBottomSheet({
    super.key,
    required this.controller,
  });

  static void show(BuildContext context, SupportTicketController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreateTicketBottomSheet(controller: controller),
    );
  }

  @override
  State<CreateTicketBottomSheet> createState() =>
      _CreateTicketBottomSheetState();
}

class _CreateTicketBottomSheetState extends State<CreateTicketBottomSheet> {
  final _picker = ImagePicker();

  Future<void> _pickAttachment(ImageSource source) async {
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
        widget.controller.addNewTicketAttachment(file);
      }
    } catch (_) {
      CustomSnackbar.showError(message: 'Failed to select attachment.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 60.h),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          AppSpaces.vSpace12,

          // Header Row
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Open Support Ticket',
                      style: AppTextStyles.text18.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textColor,
                      ),
                    ),
                    AppSpaces.vSpace2,
                    Text(
                      'Questions or issues for the AMS operations team',
                      style: AppTextStyles.text12.copyWith(
                        color: AppColors.subTextColor,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(
                    Icons.close_rounded,
                    color: AppColors.subTextColor,
                    size: 22.sp,
                  ),
                ),
              ],
            ),
          ),

          Divider(color: AppColors.borderColor, height: 16.h),

          // Scrollable Form
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Selection
                  Text(
                    'Ticket Category',
                    style: AppTextStyles.text12.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor,
                    ),
                  ),
                  AppSpaces.vSpace6,
                  DropdownButtonFormField<String>(
                    initialValue: widget.controller.selectedCategory.value,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 10.h,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide(color: AppColors.borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide(color: AppColors.borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide(color: AppColors.secondary),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'technical',
                        child: Text('Technical Issue'),
                      ),
                      DropdownMenuItem(
                        value: 'account',
                        child: Text('Account & Access'),
                      ),
                      DropdownMenuItem(
                        value: 'billing',
                        child: Text('Billing & Invoicing'),
                      ),
                      DropdownMenuItem(
                        value: 'feature_request',
                        child: Text('Feature Request'),
                      ),
                      DropdownMenuItem(
                        value: 'other',
                        child: Text('General Inquiry'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        widget.controller.selectedCategory.value = val;
                      }
                    },
                  ),

                  AppSpaces.vSpace14,

                  // Priority Chips
                  Text(
                    'Priority Level',
                    style: AppTextStyles.text12.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor,
                    ),
                  ),
                  AppSpaces.vSpace8,
                  Obx(() {
                    final current = widget.controller.selectedPriority.value;
                    final priorities = [
                      {'key': 'low', 'label': 'Low'},
                      {'key': 'normal', 'label': 'Normal'},
                      {'key': 'high', 'label': 'High'},
                      {'key': 'urgent', 'label': 'Urgent'},
                    ];

                    return Row(
                      children: priorities.map((p) {
                        final isSelected = current == p['key'];
                        Color chipColor = AppColors.secondary;
                        if (p['key'] == 'urgent' || p['key'] == 'high') {
                          chipColor = AppColors.error;
                        }

                        return Expanded(
                          child: GestureDetector(
                            onTap: () => widget.controller
                                .selectedPriority.value = p['key']!,
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 3.w),
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? chipColor.withValues(alpha: 0.12)
                                    : AppColors.cardBackground,
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: isSelected
                                      ? chipColor
                                      : AppColors.borderColor,
                                  width: isSelected ? 1.5.w : 1.w,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  p['label']!,
                                  style: AppTextStyles.text10.copyWith(
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? chipColor
                                        : AppColors.subTextColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }),

                  AppSpaces.vSpace14,

                  // Subject Input
                  Text(
                    'Subject *',
                    style: AppTextStyles.text12.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor,
                    ),
                  ),
                  AppSpaces.vSpace6,
                  CustomTextField(
                    controller: widget.controller.subjectController,
                    hintText: 'Brief summary of the issue (max 150 chars)',
                    maxLength: 150,
                  ),

                  AppSpaces.vSpace14,

                  // Description Body
                  Text(
                    'Message Description *',
                    style: AppTextStyles.text12.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor,
                    ),
                  ),
                  AppSpaces.vSpace6,
                  CustomTextField(
                    controller: widget.controller.bodyController,
                    hintText:
                        'Detailed description of what happened, device info, error messages...',
                    maxLines: 4,
                  ),

                  AppSpaces.vSpace14,

                  // Attachments Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Attachments (Up to 5 files, max 5 MB each)',
                        style: AppTextStyles.text12.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor,
                        ),
                      ),
                      Obx(() => Text(
                            '${widget.controller.newTicketAttachments.length}/5',
                            style: AppTextStyles.text10.copyWith(
                              color: AppColors.subTextColor,
                            ),
                          )),
                    ],
                  ),
                  AppSpaces.vSpace8,

                  // Attached files preview chips
                  Obx(() {
                    final files = widget.controller.newTicketAttachments;
                    if (files.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Wrap(
                        spacing: 8.w,
                        runSpacing: 6.h,
                        children: List.generate(files.length, (index) {
                          final f = files[index];
                          final name = f.path.split('/').last;

                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(6.r),
                              border: Border.all(
                                color: AppColors.borderColor,
                                width: 1.w,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.attach_file_rounded,
                                  size: 13.sp,
                                  color: AppColors.primary,
                                ),
                                AppSpaces.hSpace4,
                                ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: 160.w),
                                  child: Text(
                                    name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.text10.copyWith(
                                      color: AppColors.textColor,
                                    ),
                                  ),
                                ),
                                AppSpaces.hSpace4,
                                GestureDetector(
                                  onTap: () => widget.controller
                                      .removeNewTicketAttachment(index),
                                  child: Icon(
                                    Icons.cancel_rounded,
                                    size: 14.sp,
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

                  // Add Attachment Buttons
                  Obx(() {
                    if (widget.controller.newTicketAttachments.length >= 5) {
                      return const SizedBox.shrink();
                    }

                    return Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () =>
                              _pickAttachment(ImageSource.camera),
                          icon: Icon(
                            Icons.camera_alt_outlined,
                            size: 16.sp,
                            color: AppColors.primary,
                          ),
                          label: Text(
                            'Camera',
                            style: AppTextStyles.text12.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.borderColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                        ),
                        AppSpaces.hSpace8,
                        OutlinedButton.icon(
                          onPressed: () =>
                              _pickAttachment(ImageSource.gallery),
                          icon: Icon(
                            Icons.photo_library_outlined,
                            size: 16.sp,
                            color: AppColors.primary,
                          ),
                          label: Text(
                            'Gallery',
                            style: AppTextStyles.text12.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.borderColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),

                  AppSpaces.vSpace20,

                  // Submit Button
                  Obx(() => CustomButton(
                        text: widget.controller.isSubmitting.value
                            ? 'Submitting Ticket...'
                            : 'Submit Support Ticket',
                        isGradient: true,
                        isLoading: widget.controller.isSubmitting.value,
                        onPressed: () async {
                          if (widget.controller.isSubmitting.value) return;
                          final success =
                              await widget.controller.submitNewTicket();
                          if (success) {
                            Get.back();
                          }
                        },
                      )),

                  AppSpaces.vSpace16,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
