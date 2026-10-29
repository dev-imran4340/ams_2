import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/custom_state_view.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../controller/approval_controller.dart';
import '../../model/approval_model.dart';

class ApprovalDetailsBottomSheet extends GetView<ApprovalController> {
  const ApprovalDetailsBottomSheet({super.key});

  static String _formatTimestamp(String? isoString) {
    if (isoString == null || isoString.trim().isEmpty) return '';
    final dt = DateTime.tryParse(isoString)?.toLocal();
    if (dt == null) return isoString;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isActionLocked = controller.isActionLoading.value;
      final isLoadingDetails = controller.isLoadingDetails.value;
      final item = controller.selectedApproval.value;

      return PopScope(
        canPop: !isActionLocked && !isLoadingDetails,
        child: Container(
          constraints: BoxConstraints(maxHeight: 0.9.sh),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.r),
              topRight: Radius.circular(24.r),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.15),
                blurRadius: 20.r,
                offset: Offset(0, -4.h),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Drag Handle
              Center(
                child: Container(
                  width: 44.w,
                  height: 4.h,
                  margin: EdgeInsets.only(top: 10.h, bottom: 8.h),
                  decoration: BoxDecoration(
                    color: AppColors.borderColor,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),

              // 2. Header Bar
              if (item != null)
                _buildHeaderBar(item, isActionLocked || isLoadingDetails)
              else
                _buildSimpleHeaderBar(isActionLocked || isLoadingDetails),

              // Animated linear progress indicator while fetching detailed audit history
              if (isLoadingDetails)
                LinearProgressIndicator(
                  minHeight: 2.5.h,
                  color: AppColors.secondary,
                  backgroundColor: AppColors.secondary.withValues(alpha: 0.15),
                )
              else
                const Divider(height: 1),

              // 3. Scrollable Detail Audit Content OR Full Loading State
              Expanded(
                child: isLoadingDetails && (item == null || (item.steps.isEmpty && item.changes.isEmpty))
                    ? _buildLoadingView()
                    : item == null
                        ? _buildNotFoundView()
                        : _buildDetailContent(item),
              ),

              // 4. Action Buttons Footer (only render when loaded and action is available)
              if (!isLoadingDetails && item != null && item.can.hasAnyAction) ...[
                const Divider(height: 1),
                _buildActionFooter(context, item, isActionLocked),
              ],
            ],
          ),
        ),
      );
    });
  }

  /// Header bar displaying type pill, copyable ULID and close button
  Widget _buildHeaderBar(ApprovalItemModel item, bool isLocked) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (item.typeLabel.isNotEmpty || item.type.isNotEmpty) ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: item.toneBackgroundColor,
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(
                            color: item.toneColor.withValues(alpha: 0.35),
                            width: 0.8.w,
                          ),
                        ),
                        child: Text(
                          item.typeLabel.isNotEmpty ? item.typeLabel : item.type,
                          style: AppTextStyles.text10.copyWith(
                            fontWeight: FontWeight.bold,
                            color: item.toneColor,
                          ),
                        ),
                      ),
                      AppSpaces.hSpace8,
                    ],
                    if (item.id.isNotEmpty)
                      InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: item.id));
                          HapticFeedback.lightImpact();
                          CustomSnackbar.showInfo(
                            message: 'Request ID copied to clipboard',
                          );
                        },
                        borderRadius: BorderRadius.circular(6.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.copy_rounded,
                                size: 10.sp,
                                color: AppColors.primary,
                              ),
                              AppSpaces.hSpace4,
                              Text(
                                '#${item.id.length > 8 ? '${item.id.substring(0, 8)}...' : item.id}',
                                style: AppTextStyles.text10.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                if (item.title.isNotEmpty) ...[
                  AppSpaces.vSpace6,
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.text16.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                      height: 1.25,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close_rounded,
              size: 20.sp,
              color: AppColors.subTextColor,
            ),
            onPressed: isLocked ? null : () => Get.back(),
          ),
        ],
      ),
    );
  }

  /// Simple header bar when request item is not yet available
  Widget _buildSimpleHeaderBar(bool isLocked) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Request Details',
            style: AppTextStyles.text16.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close_rounded,
              size: 20.sp,
              color: AppColors.subTextColor,
            ),
            onPressed: isLocked ? null : () => Get.back(),
          ),
        ],
      ),
    );
  }

  /// Dedicated executive loading state while fetching detailed audit history
  Widget _buildLoadingView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 48.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56.r,
              height: 56.r,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SizedBox(
                  width: 28.r,
                  height: 28.r,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5.w,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            AppSpaces.vSpace16,
            Text(
              'Loading Request Details...',
              textAlign: TextAlign.center,
              style: AppTextStyles.text14.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            AppSpaces.vSpace6,
            Text(
              'Fetching approval journey, field changes & workflow audit',
              textAlign: TextAlign.center,
              style: AppTextStyles.text12.copyWith(
                color: AppColors.subTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Detail scrollable content view
  Widget _buildDetailContent(ApprovalItemModel item) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 12.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Employee Identification Card (only if employee data exists)
          if (item.employee != null &&
              (item.employee!.name.isNotEmpty ||
                  item.employee!.number.isNotEmpty ||
                  item.employee!.department.isNotEmpty)) ...[
            _buildEmployeeInfoCard(item.employee!, item.requestedBy),
            AppSpaces.vSpace12,
          ],

          // Status & Overview Card
          _buildStatusOverviewCard(item),

          // HR Override Notice
          if (item.can.asOverride) ...[
            AppSpaces.vSpace12,
            _buildOverrideAlertCard(),
          ],

          // Section: Proposed Changes (hide completely if changes are empty)
          if (item.changes.isNotEmpty) ...[
            AppSpaces.vSpace16,
            Row(
              children: [
                Icon(
                  Icons.published_with_changes_rounded,
                  size: 16.sp,
                  color: AppColors.secondary,
                ),
                AppSpaces.hSpace6,
                Text(
                  'Proposed Changes (${item.changes.length})',
                  style: AppTextStyles.text14.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
            AppSpaces.vSpace8,
            ...item.changes
                .where((c) => c.label.isNotEmpty)
                .map((change) => _buildChangeRow(change)),
          ],

          // Section: Key Facts (hide completely if facts are empty)
          if (item.facts.isNotEmpty &&
              item.facts.any((f) => f.label.isNotEmpty && f.value.isNotEmpty)) ...[
            AppSpaces.vSpace16,
            Row(
              children: [
                Icon(
                  Icons.fact_check_outlined,
                  size: 16.sp,
                  color: AppColors.secondary,
                ),
                AppSpaces.hSpace6,
                Text(
                  'Request Details',
                  style: AppTextStyles.text14.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
            AppSpaces.vSpace8,
            _buildFactsCard(
              item.facts.where((f) => f.label.isNotEmpty && f.value.isNotEmpty).toList(),
            ),
          ],

          // Section: Multi-tier Approval Journey (hide completely if steps are empty)
          if (item.steps.isNotEmpty) ...[
            AppSpaces.vSpace16,
            Row(
              children: [
                Icon(
                  Icons.alt_route_rounded,
                  size: 16.sp,
                  color: AppColors.secondary,
                ),
                AppSpaces.hSpace6,
                Text(
                  'Approval Journey (${item.steps.length} Steps)',
                  style: AppTextStyles.text14.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
            AppSpaces.vSpace10,
            _buildStepsTimeline(item.steps),
          ],

          // Section: Decisions History (hide completely if decisions are empty)
          if (item.decisions.isNotEmpty) ...[
            AppSpaces.vSpace16,
            Row(
              children: [
                Icon(
                  Icons.history_rounded,
                  size: 16.sp,
                  color: AppColors.secondary,
                ),
                AppSpaces.hSpace6,
                Text(
                  'Decisions History (${item.decisions.length})',
                  style: AppTextStyles.text14.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
            AppSpaces.vSpace8,
            ...item.decisions
                .where((d) => d.by.isNotEmpty)
                .map((dec) => _buildDecisionTile(dec)),
          ],

          AppSpaces.vSpace20,
        ],
      ),
    );
  }

  /// Empty / Not Found view using centralized CustomStateView
  Widget _buildNotFoundView([String? id]) {
    return Padding(
      padding: EdgeInsets.all(24.r),
      child: Center(
        child: CustomStateView.empty(
          title: 'Details Unavailable',
          message: 'Unable to retrieve full approval audit details.',
          buttonText: id != null ? 'Retry' : 'Close',
          onAction: () {
            if (id != null) {
              controller.reloadApprovalDetails(id);
            } else {
              Get.back();
            }
          },
        ),
      ),
    );
  }

  /// Employee summary card showing employee designation & requesting author
  Widget _buildEmployeeInfoCard(ApprovalEmployeeSummary emp, String requestedBy) {
    final subItems = <String>[];
    if (emp.number.isNotEmpty) subItems.add(emp.number);
    if (emp.department.isNotEmpty) subItems.add(emp.department);
    final isRequestedByOther = requestedBy.isNotEmpty &&
        requestedBy.trim().toLowerCase() != emp.name.trim().toLowerCase();

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderColor, width: 0.8.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18.r,
                backgroundColor: AppColors.primary,
                child: Text(
                  emp.name.isNotEmpty ? emp.name[0].toUpperCase() : 'E',
                  style: AppTextStyles.text14.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ),
              AppSpaces.hSpace10,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (emp.name.isNotEmpty)
                      Text(
                        emp.name,
                        style: AppTextStyles.text14.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                    if (subItems.isNotEmpty) ...[
                      AppSpaces.vSpace2,
                      Text(
                        subItems.join(' • '),
                        style: AppTextStyles.text10.copyWith(
                          color: AppColors.subTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (isRequestedByOther) ...[
            AppSpaces.vSpace8,
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.assignment_ind_outlined,
                    size: 13.sp,
                    color: AppColors.primary,
                  ),
                  AppSpaces.hSpace6,
                  Text(
                    'Submitted on behalf by: $requestedBy',
                    style: AppTextStyles.text10.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Status and Waiting-on overview container with complete timestamps
  Widget _buildStatusOverviewCard(ApprovalItemModel item) {
    final hasWaitingOn = item.waitingOn != null && item.waitingOn!.trim().isNotEmpty;
    final formattedSubmitted = _formatTimestamp(item.submittedAt);
    final formattedDecided = _formatTimestamp(item.decidedAt);

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: item.toneBackgroundColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: item.toneColor.withValues(alpha: 0.35),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(item.statusIcon, size: 18.sp, color: item.toneColor),
                  AppSpaces.hSpace8,
                  Text(
                    item.statusLabel,
                    style: AppTextStyles.text14.copyWith(
                      fontWeight: FontWeight.bold,
                      color: item.toneColor,
                    ),
                  ),
                ],
              ),
              if (item.submittedAgo != null && item.submittedAgo!.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: item.toneColor.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    item.submittedAgo!,
                    style: AppTextStyles.text10.copyWith(
                      fontWeight: FontWeight.w600,
                      color: item.toneColor,
                    ),
                  ),
                ),
            ],
          ),
          if (hasWaitingOn) ...[
            AppSpaces.vSpace8,
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.cardBackground.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: item.toneColor.withValues(alpha: 0.3),
                  width: 0.8.w,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.pending_actions_rounded,
                    size: 14.sp,
                    color: item.toneColor,
                  ),
                  AppSpaces.hSpace6,
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Waiting on: ',
                            style: AppTextStyles.text10.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor,
                            ),
                          ),
                          TextSpan(
                            text: item.waitingOn!,
                            style: AppTextStyles.text10.copyWith(
                              color: AppColors.textColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          AppSpaces.vSpace8,
          Divider(
            height: 1,
            thickness: 0.5,
            color: item.toneColor.withValues(alpha: 0.25),
          ),
          AppSpaces.vSpace8,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (formattedSubmitted.isNotEmpty)
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 12.sp,
                        color: AppColors.subTextColor,
                      ),
                      AppSpaces.hSpace4,
                      Expanded(
                        child: Text(
                          'Submitted: $formattedSubmitted',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.text10.copyWith(
                            color: AppColors.subTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (item.requestedBy.isNotEmpty)
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        size: 12.sp,
                        color: AppColors.subTextColor,
                      ),
                      AppSpaces.hSpace4,
                      Flexible(
                        child: Text(
                          'By: ${item.requestedBy}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.text10.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (formattedDecided.isNotEmpty) ...[
            AppSpaces.vSpace4,
            Row(
              children: [
                Icon(
                  Icons.done_all_rounded,
                  size: 12.sp,
                  color: AppColors.secondary,
                ),
                AppSpaces.hSpace4,
                Text(
                  'Decided at: $formattedDecided',
                  style: AppTextStyles.text10.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Informational alert banner for HR Override permissions
  Widget _buildOverrideAlertCard() {
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
          width: 0.8.w,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, size: 16.sp, color: AppColors.primary),
          AppSpaces.hSpace8,
          Expanded(
            child: Text(
              'HR Override: You may decide this request for HR. Your decision will conclude the entire approval pipeline.',
              style: AppTextStyles.text10.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Row showing high-contrast before vs after changes (handles null/empty before values)
  Widget _buildChangeRow(ApprovalChangeModel change) {
    final hasBefore = change.before != null && change.before!.trim().isNotEmpty;
    final hasAfter = change.after != null && change.after!.trim().isNotEmpty;

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderColor, width: 1.w),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 4.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.edit_note_rounded,
                size: 15.sp,
                color: AppColors.secondary,
              ),
              AppSpaces.hSpace6,
              Text(
                change.label,
                style: AppTextStyles.text12.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
            ],
          ),
          AppSpaces.vSpace8,
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Before Box
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: AppColors.borderColor,
                      width: 0.8.w,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PREVIOUS',
                        style: AppTextStyles.text10.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.subTextColor,
                          letterSpacing: 0.4,
                        ),
                      ),
                      AppSpaces.vSpace2,
                      Text(
                        hasBefore ? change.before! : '(Not set / empty)',
                        style: AppTextStyles.text12.copyWith(
                          color: hasBefore ? AppColors.error : AppColors.subTextColor,
                          fontStyle: hasBefore ? FontStyle.normal : FontStyle.italic,
                          decoration: hasBefore ? TextDecoration.lineThrough : null,
                          fontWeight: hasBefore ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Arrow
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Container(
                  padding: EdgeInsets.all(4.r),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 14.sp,
                    color: AppColors.secondary,
                  ),
                ),
              ),
              // After Box
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.3),
                      width: 0.8.w,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NEW VALUE',
                        style: AppTextStyles.text10.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                          letterSpacing: 0.4,
                        ),
                      ),
                      AppSpaces.vSpace2,
                      Text(
                        hasAfter ? change.after! : '(Cleared)',
                        style: AppTextStyles.text12.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Key/value facts card
  Widget _buildFactsCard(List<ApprovalFactModel> facts) {
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.borderColor, width: 0.8.w),
      ),
      child: Column(
        children: facts.map((f) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 4.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  f.label,
                  style: AppTextStyles.text10.copyWith(
                    color: AppColors.subTextColor,
                  ),
                ),
                Text(
                  f.value,
                  style: AppTextStyles.text10.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Complete multi-tier approval stepper journey
  Widget _buildStepsTimeline(List<ApprovalStepModel> steps) {
    return Column(
      children: [
        for (int i = 0; i < steps.length; i++)
          _buildStepTimelineTile(steps[i], i == steps.length - 1),
      ],
    );
  }

  /// Step tile in approval journey connected with vertical timeline line
  Widget _buildStepTimelineTile(ApprovalStepModel step, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Node & Vertical Connector Line
          SizedBox(
            width: 28.w,
            child: Column(
              children: [
                Container(
                  width: 24.r,
                  height: 24.r,
                  decoration: BoxDecoration(
                    color: step.isCurrent
                        ? step.toneColor.withValues(alpha: 0.2)
                        : step.toneColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: step.toneColor,
                      width: step.isCurrent ? 2.w : 1.2.w,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      step.stepIcon,
                      size: 13.sp,
                      color: step.toneColor,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2.w,
                      margin: EdgeInsets.symmetric(vertical: 4.h),
                      color: step.isApproved
                          ? AppColors.success.withValues(alpha: 0.4)
                          : AppColors.borderColor,
                    ),
                  ),
              ],
            ),
          ),
          AppSpaces.hSpace8,
          // Step Information Card
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: isLast ? 0 : 10.h),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: step.isCurrent ? step.toneColor : AppColors.borderColor,
                  width: step.isCurrent ? 1.5.w : 0.8.w,
                ),
                boxShadow: step.isCurrent
                    ? [
                        BoxShadow(
                          color: step.toneColor.withValues(alpha: 0.15),
                          blurRadius: 8.r,
                          offset: Offset(0, 3.h),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          step.approver,
                          style: AppTextStyles.text12.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 7.w,
                          vertical: 2.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: step.toneColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          step.statusLabel,
                          style: AppTextStyles.text10.copyWith(
                            fontWeight: FontWeight.bold,
                            color: step.toneColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (step.approvers.isNotEmpty) ...[
                    AppSpaces.vSpace4,
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline_rounded,
                          size: 13.sp,
                          color: AppColors.secondary,
                        ),
                        AppSpaces.hSpace4,
                        Expanded(
                          child: Text(
                            'Assigned: ${step.approvers.join(', ')}',
                            style: AppTextStyles.text10.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (step.skippedReason != null &&
                      step.skippedReason!.trim().isNotEmpty) ...[
                    AppSpaces.vSpace6,
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.subTextColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 12.sp,
                            color: AppColors.subTextColor,
                          ),
                          AppSpaces.hSpace4,
                          Expanded(
                            child: Text(
                              'Reason: ${step.skippedReason}',
                              style: AppTextStyles.text10.copyWith(
                                fontStyle: FontStyle.italic,
                                color: AppColors.subTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Decision history tile (hides null/empty comments)
  Widget _buildDecisionTile(ApprovalDecisionModel dec) {
    final isApproved = dec.decision.toLowerCase() == 'approved';
    final color = isApproved ? AppColors.success : AppColors.error;

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.borderColor, width: 0.8.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dec.by,
                style: AppTextStyles.text12.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  dec.decisionLabel,
                  style: AppTextStyles.text10.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          if (dec.comment != null && dec.comment!.trim().isNotEmpty) ...[
            AppSpaces.vSpace4,
            Text(
              '"${dec.comment}"',
              style: AppTextStyles.text10.copyWith(
                fontStyle: FontStyle.italic,
                color: AppColors.textColor,
              ),
            ),
          ],
          if (dec.ago.isNotEmpty) ...[
            AppSpaces.vSpace4,
            Text(
              dec.ago,
              style: AppTextStyles.text10.copyWith(
                color: AppColors.subTextColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Action buttons footer (Approve, Reject, Cancel / Withdraw)
  Widget _buildActionFooter(
    BuildContext context,
    ApprovalItemModel item,
    bool isActionLocked,
  ) {
    final canApproveOrReject = item.can.approve || item.can.reject;
    final canCancel = item.can.cancel;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (canApproveOrReject)
              Row(
                children: [
                  // 1. Reject Button (if allowed)
                  if (item.can.reject) ...[
                    Expanded(
                      child: CustomButton(
                        text: 'Reject',
                        backgroundColor: AppColors.error,
                        textColor: AppColors.white,
                        isLoading: isActionLocked,
                        icon: Icon(
                          Icons.close_rounded,
                          size: 16.sp,
                          color: AppColors.white,
                        ),
                        onPressed: isActionLocked
                            ? null
                            : () => _showRejectReasonDialog(context, item.id),
                      ),
                    ),
                    if (item.can.approve) AppSpaces.hSpace10,
                  ],

                  // 2. Approve Button (if allowed)
                  if (item.can.approve)
                    Expanded(
                      child: CustomButton(
                        isGradient: true,
                        text: item.can.asOverride ? 'Override & Approve' : 'Approve',
                        isLoading: isActionLocked,
                        icon: Icon(
                          Icons.check_circle_rounded,
                          size: 16.sp,
                          color: AppColors.white,
                        ),
                        onPressed: isActionLocked
                            ? null
                            : () => _showApproveCommentDialog(context, item.id),
                      ),
                    ),
                ],
              ),

            // 3. Withdraw Request Button (if allowed)
            if (canCancel) ...[
              if (canApproveOrReject) AppSpaces.vSpace8,
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  isOutlined: true,
                  text: 'Withdraw Request',
                  borderColor: AppColors.error,
                  textColor: AppColors.error,
                  backgroundColor: AppColors.cardBackground,
                  isLoading: isActionLocked,
                  icon: Icon(
                    Icons.cancel_outlined,
                    size: 16.sp,
                    color: AppColors.error,
                  ),
                  onPressed: isActionLocked
                      ? null
                      : () => _showCancelConfirmDialog(context, item.id),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Dialog to collect optional approval comment
  void _showApproveCommentDialog(BuildContext context, String id) {
    controller.actionCommentController.clear();

    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          'Approve Request',
          style: AppTextStyles.text16.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You are granting approval for this request. You can optionally include review remarks below (up to 1000 characters).',
              style: AppTextStyles.text12.copyWith(color: AppColors.subTextColor),
            ),
            AppSpaces.vSpace12,
            CustomTextField(
              controller: controller.actionCommentController,
              focusNode: controller.actionCommentFocusNode,
              hintText: 'Optional comment / approval remarks...',
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Back',
              style: AppTextStyles.text12.copyWith(color: AppColors.subTextColor),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            onPressed: () {
              final comment = controller.actionCommentController.text.trim();
              Get.back();
              controller.approveRequest(id, comment: comment);
            },
            child: Text(
              'Confirm Approval',
              style: AppTextStyles.text12.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Dialog to collect mandatory rejection reason
  void _showRejectReasonDialog(BuildContext context, String id) {
    controller.actionCommentController.clear();
    controller.rejectionError.value = null;

    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          'Reject Request',
          style: AppTextStyles.text16.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.error,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A rejection terminates the entire workflow and notifies the employee. A reason is mandatory.',
              style: AppTextStyles.text12.copyWith(color: AppColors.subTextColor),
            ),
            AppSpaces.vSpace12,
            CustomTextField(
              controller: controller.actionCommentController,
              focusNode: controller.actionCommentFocusNode,
              hintText: 'State reason for rejection (required, 5-1000 characters)...',
              maxLines: 3,
              maxLength: 1000,
            ),
            Obx(() {
              if (controller.rejectionError.value == null) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: EdgeInsets.only(top: 6.h),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 13.sp,
                      color: AppColors.error,
                    ),
                    AppSpaces.hSpace4,
                    Expanded(
                      child: Text(
                        controller.rejectionError.value!,
                        style: AppTextStyles.text10.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: AppTextStyles.text12.copyWith(color: AppColors.subTextColor),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            onPressed: () {
              final comment = controller.actionCommentController.text.trim();
              if (comment.isEmpty) {
                controller.rejectionError.value = 'Rejection reason is mandatory.';
                controller.actionCommentFocusNode.requestFocus();
                return;
              }
              if (comment.length < 5) {
                controller.rejectionError.value =
                    'Reason must be at least 5 characters long.';
                controller.actionCommentFocusNode.requestFocus();
                return;
              }
              if (comment.length > 1000) {
                controller.rejectionError.value =
                    'Reason cannot exceed 1000 characters.';
                controller.actionCommentFocusNode.requestFocus();
                return;
              }
              Get.back();
              controller.rejectRequest(id, comment: comment);
            },
            child: Text(
              'Confirm Rejection',
              style: AppTextStyles.text12.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Confirmation dialog to withdraw request
  void _showCancelConfirmDialog(BuildContext context, String id) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          'Withdraw Request',
          style: AppTextStyles.text16.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
        ),
        content: Text(
          'Are you sure you want to withdraw this pending request? This action cannot be undone.',
          style: AppTextStyles.text12.copyWith(color: AppColors.subTextColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'No, Keep It',
              style: AppTextStyles.text12.copyWith(color: AppColors.subTextColor),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            onPressed: () {
              Get.back();
              controller.cancelRequest(id);
            },
            child: Text(
              'Yes, Withdraw',
              style: AppTextStyles.text12.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
