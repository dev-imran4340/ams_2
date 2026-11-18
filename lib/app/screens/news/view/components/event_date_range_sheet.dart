import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../controller/news_controller.dart';

class EventDateRangeSheet extends StatefulWidget {
  final NewsController controller;

  const EventDateRangeSheet({
    super.key,
    required this.controller,
  });

  static Future<void> show(BuildContext context, NewsController controller) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EventDateRangeSheet(controller: controller),
    );
  }

  @override
  State<EventDateRangeSheet> createState() => _EventDateRangeSheetState();
}

class _EventDateRangeSheetState extends State<EventDateRangeSheet> {
  late DateTime _fromDate;
  late DateTime _toDate;
  String? _selectedPreset;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (widget.controller.eventFromDate.value.isNotEmpty) {
      _fromDate = DateTime.tryParse(widget.controller.eventFromDate.value) ?? today;
    } else {
      _fromDate = today;
    }

    if (widget.controller.eventToDate.value.isNotEmpty) {
      _toDate = DateTime.tryParse(widget.controller.eventToDate.value) ??
          today.add(const Duration(days: 60));
    } else {
      _toDate = today.add(const Duration(days: 60));
    }

    _selectedPreset = widget.controller.hasCustomEventDateFilter.value
        ? widget.controller.activeEventRangeLabel.value
        : 'Next 60 Days';
  }

  void _applyPreset(String label, int days) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    setState(() {
      _selectedPreset = label;
      _fromDate = today;
      _toDate = today.add(Duration(days: days));
    });
  }

  Future<void> _pickFromDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _fromDate,
      firstDate: DateTime(now.year - 1, 1, 1),
      lastDate: DateTime(now.year + 2, 12, 31),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: AppColors.cardBackground,
            onSurface: AppColors.textColor,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        _selectedPreset = 'Custom';
        _fromDate = picked;
        if (_toDate.isBefore(_fromDate)) {
          _toDate = _fromDate.add(const Duration(days: 30));
        }
      });
    }
  }

  Future<void> _pickToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _toDate.isAfter(_fromDate) ? _toDate : _fromDate,
      firstDate: _fromDate,
      lastDate: _fromDate.add(const Duration(days: 730)), // Max 2 years ahead per API spec
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.secondary,
            onPrimary: Colors.white,
            surface: AppColors.cardBackground,
            onSurface: AppColors.textColor,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        _selectedPreset = 'Custom';
        _toDate = picked;
      });
    }
  }

  void _submit() {
    if (_toDate.isBefore(_fromDate)) {
      CustomSnackbar.showWarning(
        title: 'Invalid Date Range',
        message: '"To" date cannot be earlier than "From" date.',
      );
      return;
    }

    final diffDays = _toDate.difference(_fromDate).inDays;
    if (diffDays > 730) {
      CustomSnackbar.showWarning(
        title: 'Range Too Large',
        message: 'The date range can be at most 2 years (730 days).',
      );
      return;
    }

    widget.controller.setEventDateFilter(
      _fromDate,
      _toDate,
      label: _selectedPreset == 'Custom'
          ? '${_formatDate(_fromDate)} - ${_formatDate(_toDate)}'
          : _selectedPreset,
    );
    Get.back();
  }

  void _reset() {
    widget.controller.resetEventDateFilter();
    Get.back();
  }

  String _formatDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Grabber Handle
              Center(
                child: Container(
                  width: 36.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.borderColor,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),

              AppSpaces.vSpace14,

              // 2. Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(7.r),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          Icons.date_range_rounded,
                          size: 18.w,
                          color: AppColors.secondary,
                        ),
                      ),
                      AppSpaces.hSpace10,
                      Text(
                        'Filter Events by Date',
                        style: AppTextStyles.text16.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      Icons.close_rounded,
                      size: 20.w,
                      color: AppColors.subTextColor,
                    ),
                  ),
                ],
              ),

              AppSpaces.vSpace14,

              // 3. Quick Presets
              Text(
                'Quick Presets',
                style: AppTextStyles.text12.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textColor,
                ),
              ),

              AppSpaces.vSpace8,

              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  _buildPresetChip('Next 30 Days', 30),
                  _buildPresetChip('Next 60 Days', 60),
                  _buildPresetChip('Next 3 Months', 90),
                  _buildPresetChip('Next 6 Months', 180),
                  _buildPresetChip('Next 1 Year', 365),
                ],
              ),

              AppSpaces.vSpace16,

              // 4. Custom From - To Date Pickers
              Text(
                'Custom Date Range',
                style: AppTextStyles.text12.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textColor,
                ),
              ),

              AppSpaces.vSpace8,

              Row(
                children: [
                  // From Date
                  Expanded(
                    child: _buildDateBox(
                      label: 'From Date',
                      dateStr: _formatDate(_fromDate),
                      icon: Icons.calendar_today_rounded,
                      onTap: _pickFromDate,
                    ),
                  ),

                  AppSpaces.hSpace10,

                  // To Date
                  Expanded(
                    child: _buildDateBox(
                      label: 'To Date',
                      dateStr: _formatDate(_toDate),
                      icon: Icons.event_rounded,
                      onTap: _pickToDate,
                    ),
                  ),
                ],
              ),

              AppSpaces.vSpace8,

              Text(
                'Server allows up to 2 years ahead (from today)',
                style: AppTextStyles.text10.copyWith(
                  color: AppColors.subTextColor,
                ),
              ),

              AppSpaces.vSpace20,

              // 5. Actions: Reset and Apply
              Row(
                children: [
                  if (widget.controller.hasCustomEventDateFilter.value) ...[
                    Expanded(
                      flex: 2,
                      child: CustomButton(
                        text: 'Reset',
                        isOutlined: true,
                        borderColor: AppColors.borderColor,
                        textColor: AppColors.subTextColor,
                        onPressed: _reset,
                      ),
                    ),
                    AppSpaces.hSpace10,
                  ],
                  Expanded(
                    flex: 3,
                    child: CustomButton(
                      text: 'Apply Filter',
                      isGradient: true,
                      onPressed: _submit,
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

  Widget _buildPresetChip(String label, int days) {
    final bool isSelected = _selectedPreset == label;

    return ChoiceChip(
      label: Text(
        label,
        style: AppTextStyles.text12.copyWith(
          color: isSelected ? Colors.white : AppColors.textColor,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.backgroundColor,
      checkmarkColor: AppColors.secondary,
      onSelected: (_) => _applyPreset(label, days),
    );
  }

  Widget _buildDateBox({
    required String label,
    required String dateStr,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: AppColors.borderColor,
            width: 1.w,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.text10.copyWith(
                color: AppColors.subTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            AppSpaces.vSpace4,
            Row(
              children: [
                Icon(
                  icon,
                  size: 14.w,
                  color: AppColors.secondary,
                ),
                AppSpaces.hSpace6,
                Text(
                  dateStr,
                  style: AppTextStyles.text12.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
