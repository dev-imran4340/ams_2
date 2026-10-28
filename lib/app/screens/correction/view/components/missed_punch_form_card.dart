import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../controller/correction_controller.dart';

/// Modern, to-the-point Attendance Correction Form
/// Designed for maximum ease of use with instant date/time selection,
/// punch type selector, quick-reason chips, and clean validation.
class MissedPunchFormCard extends GetView<CorrectionController> {
  const MissedPunchFormCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── 1. PUNCH KIND SELECTOR ───
            _buildSectionLabel(
              icon: Icons.touch_app_rounded,
              title: 'PUNCH TYPE',
            ),
            AppSpaces.vSpace8,
            _buildPunchKindGrid(),

            AppSpaces.vSpace16,

            // ─── 2. DATE & TIME (SIDE-BY-SIDE TILES) ───
            _buildSectionLabel(
              icon: Icons.calendar_month_rounded,
              title: 'DATE & TIME',
            ),
            AppSpaces.vSpace8,
            _buildDateTimeRow(context),

            AppSpaces.vSpace14,

            // ─── 3. OVERNIGHT SHIFT TOGGLE ───
            _buildOvernightToggle(),

            AppSpaces.vSpace16,

            // ─── 4. REASON & JUSTIFICATION ───
            _buildReasonHeader(),
            AppSpaces.vSpace8,
            _buildQuickReasonChips(),
            AppSpaces.vSpace10,
            _buildReasonInput(),

            AppSpaces.vSpace20,

            // ─── 5. SUBMIT ACTION BUTTON ───
            Obx(
              () => CustomButton(
                text: 'Submit Request',
                isLoading: controller.isSubmitting.value,
                isGradient: true,
                onPressed: controller.isSubmitting.value
                    ? null
                    : () => controller.submitForm(context),
                icon: Icon(
                  Icons.send_rounded,
                  size: 15.sp,
                  color: AppColors.white,
                ),
                height: 48.h,
                borderRadius: 12.r,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Minimal modern section label with icon
  Widget _buildSectionLabel({required IconData icon, required String title}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 12.sp,
          color: AppColors.secondary,
        ),
        AppSpaces.hSpace6,
        Text(
          title,
          style: AppTextStyles.text10.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
            color: AppColors.subTextColor,
          ),
        ),
      ],
    );
  }

  /// Modern 2x2 Punch Kind Selector with subtle hover/active state
  Widget _buildPunchKindGrid() {
    final kinds = [
      {'key': 'in', 'label': 'Check-In', 'icon': Icons.login_rounded},
      {'key': 'out', 'label': 'Check-Out', 'icon': Icons.logout_rounded},
      {'key': 'break_start', 'label': 'Break In', 'icon': Icons.coffee_rounded},
      {'key': 'break_end', 'label': 'Break Out', 'icon': Icons.work_outline_rounded},
    ];

    return Obx(() {
      final currentKind = controller.selectedKind.value;

      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
        childAspectRatio: 3.2,
        children: kinds.map((item) {
          final key = item['key'] as String;
          final label = item['label'] as String;
          final icon = item['icon'] as IconData;
          final isSelected = currentKind == key;

          return InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              controller.selectedKind.value = key;
            },
            borderRadius: BorderRadius.circular(10.r),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.inputFill,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.borderColor,
                  width: 1.w,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          blurRadius: 6.r,
                          offset: Offset(0, 2.h),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 14.sp,
                    color: isSelected ? AppColors.white : AppColors.secondary,
                  ),
                  AppSpaces.hSpace8,
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.text12.copyWith(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected ? AppColors.white : AppColors.textColor,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle_rounded,
                      size: 14.sp,
                      color: AppColors.secondary,
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  /// Compact, side-by-side Date & Time picker tiles
  Widget _buildDateTimeRow(BuildContext context) {
    return Row(
      children: [
        // ── Left: Date Tile ──
        Expanded(
          child: Obx(() {
            final dt = controller.selectedDate.value ?? DateTime.now();
            final relative = CorrectionController.formatRelativeDate(dt);
            final fullDate = CorrectionController.formatDate(dt);

            return InkWell(
              onTap: () => controller.pickDate(context),
              borderRadius: BorderRadius.circular(10.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: AppColors.borderColor,
                    width: 1.w,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28.r,
                      height: 28.r,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Icon(
                        Icons.calendar_today_rounded,
                        size: 13.sp,
                        color: AppColors.secondary,
                      ),
                    ),
                    AppSpaces.hSpace8,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            relative,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.text12.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor,
                            ),
                          ),
                          Text(
                            fullDate,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.text10.copyWith(
                              color: AppColors.subTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),

        AppSpaces.hSpace8,

        // ── Right: Time Tile ──
        Expanded(
          child: Obx(() {
            final t = controller.selectedTime.value;
            final time12 = CorrectionController.formatTime12h(t);
            final time24 = CorrectionController.formatTime24h(t);

            return InkWell(
              onTap: () => controller.pickTime(context),
              borderRadius: BorderRadius.circular(10.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: AppColors.borderColor,
                    width: 1.w,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28.r,
                      height: 28.r,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Icon(
                        Icons.schedule_rounded,
                        size: 13.sp,
                        color: AppColors.primary,
                      ),
                    ),
                    AppSpaces.hSpace8,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            time12,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.text12.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor,
                            ),
                          ),
                          Text(
                            '24h: $time24',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.text10.copyWith(
                              color: AppColors.subTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  /// Clean, compact Overnight toggle row
  Widget _buildOvernightToggle() {
    return Obx(() {
      final isNext = controller.isNextDay.value;

      return InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          controller.isNextDay.value = !isNext;
        },
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: isNext
                ? AppColors.secondary.withValues(alpha: 0.08)
                : AppColors.inputFill.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: isNext
                  ? AppColors.secondary.withValues(alpha: 0.4)
                  : AppColors.borderColor,
              width: 0.8.w,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.nightlight_outlined,
                size: 14.sp,
                color: isNext ? AppColors.secondary : AppColors.subTextColor,
              ),
              AppSpaces.hSpace8,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overnight Shift Punch',
                      style: AppTextStyles.text10.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                    Text(
                      'Check if punch falls on next morning',
                      style: AppTextStyles.text10.copyWith(
                        color: AppColors.subTextColor,
                        fontSize: 9.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isNext,
                activeThumbColor: AppColors.white,
                activeTrackColor: AppColors.secondary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (val) {
                  controller.isNextDay.value = val;
                },
              ),
            ],
          ),
        ),
      );
    });
  }

  /// Reason section header with live counter badge
  Widget _buildReasonHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSectionLabel(
          icon: Icons.chat_bubble_outline_rounded,
          title: 'REASON FOR ADJUSTMENT',
        ),
        Obx(() {
          final count = controller.reasonCharCount.value;
          final isOver = count > 500;
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: isOver
                  ? AppColors.error.withValues(alpha: 0.12)
                  : AppColors.borderColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              '$count / 500',
              style: AppTextStyles.text10.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 9.sp,
                color: isOver ? AppColors.error : AppColors.subTextColor,
              ),
            ),
          );
        }),
      ],
    );
  }

  /// Quick-select preset reason chips (single-line horizontal scroll)
  Widget _buildQuickReasonChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: controller.quickReasons.map((reason) {
          return Padding(
            padding: EdgeInsets.only(right: 6.w),
            child: InkWell(
              onTap: () => controller.setQuickReason(reason),
              borderRadius: BorderRadius.circular(8.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: AppColors.borderColor,
                    width: 0.8.w,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_rounded,
                      size: 11.sp,
                      color: AppColors.secondary,
                    ),
                    AppSpaces.hSpace4,
                    Text(
                      reason,
                      style: AppTextStyles.text10.copyWith(
                        color: AppColors.textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Clean, focused multi-line text input
  Widget _buildReasonInput() {
    return TextFormField(
      controller: controller.remarksController,
      focusNode: controller.remarksFocusNode,
      maxLines: 3,
      maxLength: 500,
      buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
          const SizedBox.shrink(),
      style: AppTextStyles.text12.copyWith(
        color: AppColors.textColor,
      ),
      decoration: InputDecoration(
        hintText: 'Briefly explain why this punch was missed or adjusted...',
        hintStyle: AppTextStyles.text10.copyWith(
          color: AppColors.subTextColor,
        ),
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12.w,
          vertical: 10.h,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(
            color: AppColors.borderColor,
            width: 1.w,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(
            color: AppColors.borderColor,
            width: 1.w,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(
            color: AppColors.primary,
            width: 1.2.w,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(
            color: AppColors.error,
            width: 1.w,
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Reason is required for correction approval.';
        }
        if (value.trim().length < 5) {
          return 'Please provide at least 5 characters.';
        }
        if (value.trim().length > 500) {
          return 'Reason cannot exceed 500 characters.';
        }
        return null;
      },
    );
  }
}
