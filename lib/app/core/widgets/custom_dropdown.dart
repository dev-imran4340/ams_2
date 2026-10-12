import 'package:animated_custom_dropdown/custom_dropdown.dart' as animated;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/app_colors.dart';
import '../utils/app_spaces.dart';
import '../utils/app_text_styles.dart';

class CustomDropdown<T> extends StatelessWidget {
  final String? labelText;
  final String hintText;
  final List<T> items;
  final T? initialItem;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final Widget? prefixIcon;
  final Widget? closedSuffixIcon;
  final Widget? expandedSuffixIcon;
  final Color? fillColor;
  final Color? expandedFillColor;
  final Color? borderColor;
  final bool isRequired;
  final bool canClearSelection;
  final bool enabled;
  final bool isSearchable;
  final animated.SingleSelectController<T>? controller;
  final animated.CustomDropdownAnimation? animation;
  final animated.DropdownOverlayDirection overlayDirection;
  final Widget Function(BuildContext context, T item, bool isSelected, VoidCallback onItemSelect)? listItemBuilder;
  final Widget Function(BuildContext context, T selectedItem, bool enabled)? headerBuilder;
  final Widget Function(BuildContext context, String hint, bool enabled)? hintBuilder;

  const CustomDropdown({
    super.key,
    this.labelText,
    this.hintText = 'Select an option',
    required this.items,
    this.initialItem,
    required this.onChanged,
    this.validator,
    this.prefixIcon,
    this.closedSuffixIcon,
    this.expandedSuffixIcon,
    this.fillColor,
    this.expandedFillColor,
    this.borderColor,
    this.isRequired = false,
    this.canClearSelection = false,
    this.enabled = true,
    this.controller,
    this.animation,
    this.overlayDirection = animated.DropdownOverlayDirection.auto,
    this.listItemBuilder,
    this.headerBuilder,
    this.hintBuilder,
  }) : isSearchable = false;

  /// Named constructor for searchable dropdown
  const CustomDropdown.search({
    super.key,
    this.labelText,
    this.hintText = 'Search & select option',
    required this.items,
    this.initialItem,
    required this.onChanged,
    this.validator,
    this.prefixIcon,
    this.closedSuffixIcon,
    this.expandedSuffixIcon,
    this.fillColor,
    this.expandedFillColor,
    this.borderColor,
    this.isRequired = false,
    this.canClearSelection = false,
    this.enabled = true,
    this.controller,
    this.animation,
    this.overlayDirection = animated.DropdownOverlayDirection.auto,
    this.listItemBuilder,
    this.headerBuilder,
    this.hintBuilder,
  }) : isSearchable = true;

  @override
  Widget build(BuildContext context) {
    final effectiveFillColor = fillColor ?? AppColors.inputFill;
    final effectiveExpandedFill = expandedFillColor ?? AppColors.cardBackground;
    final effectiveBorderColor = borderColor ?? AppColors.borderColor;

    final defaultAnimation = animation ??
        const animated.CustomDropdownAnimation(
          type: animated.DropdownAnimationType.scaleFade,
          duration: Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
        );

    final decoration = animated.CustomDropdownDecoration(
      closedFillColor: effectiveFillColor,
      expandedFillColor: effectiveExpandedFill,
      prefixIcon: prefixIcon,
      closedSuffixIcon: closedSuffixIcon ??
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.subTextColor,
            size: 20.sp,
          ),
      expandedSuffixIcon: expandedSuffixIcon ??
          Icon(
            Icons.keyboard_arrow_up_rounded,
            color: AppColors.primary,
            size: 20.sp,
          ),
      closedBorder: Border.all(
        color: effectiveBorderColor,
        width: 1.w,
      ),
      closedBorderRadius: BorderRadius.circular(12.r),
      expandedBorder: Border.all(
        color: effectiveBorderColor,
        width: 1.w,
      ),
      expandedBorderRadius: BorderRadius.circular(12.r),
      closedErrorBorder: Border.all(
        color: AppColors.error,
        width: 1.w,
      ),
      closedErrorBorderRadius: BorderRadius.circular(12.r),
      headerStyle: AppTextStyles.text14.copyWith(
        color: AppColors.textColor,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: AppTextStyles.text14.copyWith(
        color: AppColors.hintColor,
        fontWeight: FontWeight.w400,
      ),
      listItemStyle: AppTextStyles.text14.copyWith(
        color: AppColors.textColor,
        fontWeight: FontWeight.w500,
      ),
      errorStyle: AppTextStyles.text12.copyWith(
        color: AppColors.error,
        fontWeight: FontWeight.w500,
      ),
      listItemDecoration: animated.ListItemDecoration(
        selectedColor: AppColors.litePrimary,
        highlightColor: AppColors.litePrimary.withValues(alpha: 0.5),
      ),
      searchFieldDecoration: animated.SearchFieldDecoration(
        fillColor: AppColors.inputFill,
        textStyle: AppTextStyles.text14.copyWith(
          color: AppColors.textColor,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: AppTextStyles.text14.copyWith(
          color: AppColors.hintColor,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: AppColors.hintColor,
          size: 20.sp,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(
            color: effectiveBorderColor,
            width: 1.w,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(
            color: AppColors.primary,
            width: 1.5.w,
          ),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null && labelText!.isNotEmpty) ...[
          RichText(
            text: TextSpan(
              text: labelText!,
              style: AppTextStyles.text14.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textColor,
              ),
              children: [
                if (isRequired)
                  TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
              ],
            ),
          ),
          AppSpaces.vSpace8,
        ],
        if (isSearchable)
          animated.CustomDropdown<T>.search(
            items: items,
            initialItem: initialItem,
            hintText: hintText,
            onChanged: onChanged,
            validator: validator,
            enabled: enabled,
            canClearSelection: canClearSelection,
            controller: controller,
            decoration: decoration,
            animation: defaultAnimation,
            overlayDirection: overlayDirection,
            headerBuilder: headerBuilder,
            listItemBuilder: listItemBuilder,
            hintBuilder: hintBuilder,
          )
        else
          animated.CustomDropdown<T>(
            items: items,
            initialItem: initialItem,
            hintText: hintText,
            onChanged: onChanged,
            validator: validator,
            enabled: enabled,
            canClearSelection: canClearSelection,
            controller: controller,
            decoration: decoration,
            animation: defaultAnimation,
            overlayDirection: overlayDirection,
            headerBuilder: headerBuilder,
            listItemBuilder: listItemBuilder,
            hintBuilder: hintBuilder,
          ),
      ],
    );
  }
}
