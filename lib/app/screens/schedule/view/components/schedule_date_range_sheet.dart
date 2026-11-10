import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../controller/schedule_controller.dart';

/// Modal date range picker bottom sheet for Schedule Screen
/// Provides two interactive fields (From Date & To Date) along with quick shortcuts:
/// Current Week, Current Month, Previous Month, and Next 14 Days (all constrained to max 62 days API limit).
class ScheduleDateRangeSheet extends StatefulWidget {
  final ScheduleController controller;

  const ScheduleDateRangeSheet({
    super.key,
    required this.controller,
  });

  static Future<void> show(
    BuildContext context,
    ScheduleController controller,
  ) {
    HapticFeedback.lightImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ScheduleDateRangeSheet(controller: controller),
    );
  }

  @override
  State<ScheduleDateRangeSheet> createState() => _ScheduleDateRangeSheetState();
}

class _ScheduleDateRangeSheetState extends State<ScheduleDateRangeSheet> {
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();

    final parsedStart = DateTime.tryParse(widget.controller.fromDate.value);
    final parsedEnd = DateTime.tryParse(widget.controller.toDate.value);

    _startDate = parsedStart ?? now;
    _endDate = parsedEnd ?? now.add(const Duration(days: 13));
  }

  int get _daysCount {
    if (_endDate.isBefore(_startDate)) return 0;
    return _endDate.difference(_startDate).inDays + 1;
  }

  bool get _isValidRange =>
      !_endDate.isBefore(_startDate) && _daysCount > 0 && _daysCount <= 62;

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';
  }

  String _weekdayName(DateTime dt) {
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];
    return days[dt.weekday - 1];
  }

  Widget _buildDatePickerTheme(Widget? child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.light(
          primary: AppColors.secondary,
          onPrimary: AppColors.white,
          surface: AppColors.cardBackground,
          onSurface: AppColors.textColor,
          secondary: AppColors.secondary,
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.cardBackground,
        ),
      ),
      child: child!,
    );
  }

  Future<void> _pickStartDate() async {
    HapticFeedback.selectionClick();
    final now = DateTime.now();
    final first = DateTime(now.year - 1, 1, 1);
    final last = DateTime(now.year + 2, 12, 31);

    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: first,
      lastDate: last,
      helpText: 'SELECT FROM DATE',
      builder: (context, child) => _buildDatePickerTheme(child),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate.add(const Duration(days: 13));
        } else if (_endDate.difference(_startDate).inDays + 1 > 62) {
          _endDate = _startDate.add(const Duration(days: 61));
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    HapticFeedback.selectionClick();
    final first = _startDate;
    final last = _startDate.add(const Duration(days: 61)); // Strict 62 days limit

    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate.isBefore(first) ? first : (_endDate.isAfter(last) ? last : _endDate),
      firstDate: first,
      lastDate: last,
      helpText: 'SELECT TO DATE (MAX 62 DAYS)',
      builder: (context, child) => _buildDatePickerTheme(child),
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _applyCurrentWeek() {
    HapticFeedback.selectionClick();
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    setState(() {
      _startDate = DateTime(monday.year, monday.month, monday.day);
      _endDate = DateTime(sunday.year, sunday.month, sunday.day);
    });
  }

  void _applyNext14Days() {
    HapticFeedback.selectionClick();
    final now = DateTime.now();
    setState(() {
      _startDate = DateTime(now.year, now.month, now.day);
      _endDate = _startDate.add(const Duration(days: 13));
    });
  }

  void _applyCurrentMonth() {
    HapticFeedback.selectionClick();
    final now = DateTime.now();
    final lastDay = DateTime(now.year, now.month + 1, 0).day;
    setState(() {
      _startDate = DateTime(now.year, now.month, 1);
      _endDate = DateTime(now.year, now.month, lastDay);
    });
  }

  void _applyPreviousMonth() {
    HapticFeedback.selectionClick();
    final now = DateTime.now();
    final prevMonthDate = DateTime(now.year, now.month - 1, 1);
    final lastDay = DateTime(prevMonthDate.year, prevMonthDate.month + 1, 0).day;
    setState(() {
      _startDate = DateTime(prevMonthDate.year, prevMonthDate.month, 1);
      _endDate = DateTime(prevMonthDate.year, prevMonthDate.month, lastDay);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
        border: Border(
          bottom: BorderSide(color: AppColors.secondary, width: 3.w),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 18.r,
            offset: Offset(0, -4.h),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Drag Handle
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
            AppSpaces.vSpace12,

            // Header Row: Icon, Title & Close
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
                        size: 18.sp,
                        color: AppColors.secondary,
                      ),
                    ),
                    AppSpaces.hSpace10,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Schedule Date Range',
                          style: AppTextStyles.text16.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                        AppSpaces.vSpace2,
                        Text(
                          'Select query window (Server limit: 62 days)',
                          style: AppTextStyles.text10.copyWith(
                            color: AppColors.subTextColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Get.back(),
                    borderRadius: BorderRadius.circular(10.r),
                    child: Padding(
                      padding: EdgeInsets.all(4.r),
                      child: Icon(
                        Icons.close_rounded,
                        size: 20.sp,
                        color: AppColors.subTextColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            AppSpaces.vSpace12,
            Container(height: 0.8.h, color: AppColors.borderColor),
            AppSpaces.vSpace12,

            // Quick Shortcuts Row (Current Week, Current Month, Previous Month, Next 14 Days)
            Text(
              'QUICK SHORTCUTS',
              style: AppTextStyles.text10.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.subTextColor,
                letterSpacing: 0.6,
              ),
            ),
            AppSpaces.vSpace8,
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildShortcutChip('Current Week', _applyCurrentWeek),
                  AppSpaces.hSpace8,
                  _buildShortcutChip('Next 14 Days', _applyNext14Days),
                  AppSpaces.hSpace8,
                  _buildShortcutChip('Current Month', _applyCurrentMonth),
                  AppSpaces.hSpace8,
                  _buildShortcutChip('Previous Month', _applyPreviousMonth),
                ],
              ),
            ),

            AppSpaces.vSpace14,

            // Two Interactive Date Pickers in a Single Row
            Row(
              children: [
                Expanded(
                  child: _buildDateBox(
                    label: 'FROM DATE',
                    date: _startDate,
                    onTap: _pickStartDate,
                    icon: Icons.calendar_today_rounded,
                  ),
                ),
                AppSpaces.hSpace10,
                Expanded(
                  child: _buildDateBox(
                    label: 'TO DATE',
                    date: _endDate,
                    onTap: _pickEndDate,
                    icon: Icons.event_available_rounded,
                  ),
                ),
              ],
            ),

            AppSpaces.vSpace12,

            // Range Days Counter Banner
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: _isValidRange
                    ? AppColors.secondary.withValues(alpha: 0.08)
                    : AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: _isValidRange
                      ? AppColors.secondary.withValues(alpha: 0.25)
                      : AppColors.error.withValues(alpha: 0.3),
                  width: 0.8.w,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        _isValidRange
                            ? Icons.info_outline_rounded
                            : Icons.warning_amber_rounded,
                        size: 14.sp,
                        color: _isValidRange ? AppColors.secondary : AppColors.error,
                      ),
                      AppSpaces.hSpace6,
                      Text(
                        _isValidRange
                            ? 'Selected: $_daysCount Days'
                            : (_daysCount > 62
                                ? 'Exceeds limit: $_daysCount / 62 days max'
                                : 'Invalid date selection'),
                        style: AppTextStyles.text12.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _isValidRange ? AppColors.secondary : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Max 62 Days',
                    style: AppTextStyles.text10.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.subTextColor,
                    ),
                  ),
                ],
              ),
            ),

            AppSpaces.vSpace16,

            // Action Button: Apply Range
            CustomButton(
              isGradient: true,
              text: 'Apply Date Range',
              onPressed: !_isValidRange
                  ? null
                  : () {
                      HapticFeedback.mediumImpact();
                      Get.back();
                      widget.controller.setCustomDateRange(_startDate, _endDate);
                    },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShortcutChip(String label, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.borderColor, width: 0.8.w),
          ),
          child: Text(
            label,
            style: AppTextStyles.text10.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateBox({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.borderColor, width: 1.w),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.text10.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.subTextColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Icon(
                    icon,
                    size: 13.sp,
                    color: AppColors.secondary,
                  ),
                ],
              ),
              AppSpaces.vSpace6,
              Text(
                _formatDate(date),
                style: AppTextStyles.text12.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              AppSpaces.vSpace2,
              Text(
                _weekdayName(date),
                style: AppTextStyles.text10.copyWith(
                  color: AppColors.subTextColor,
                  fontSize: 9.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
