import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../controller/attendance_history_controller.dart';

/// Corporate Modern Bottom Sheet Date Range Picker for Attendance History
/// Replaces clunky full-screen Material DateRangePicker with an executive-grade,
/// 2-field (From -> To) picker with quick duration shortcuts and 62-day API validation.
class AttendanceDateRangeSheet extends StatefulWidget {
  final AttendanceHistoryController controller;

  const AttendanceDateRangeSheet({
    super.key,
    required this.controller,
  });

  static Future<void> show(
    BuildContext context,
    AttendanceHistoryController controller,
  ) {
    HapticFeedback.lightImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AttendanceDateRangeSheet(controller: controller),
    );
  }

  @override
  State<AttendanceDateRangeSheet> createState() =>
      _AttendanceDateRangeSheetState();
}

class _AttendanceDateRangeSheetState extends State<AttendanceDateRangeSheet> {
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();

    // Initialize from controller's active range or default to current month / past 14 days
    if (widget.controller.customRange.value != null) {
      _startDate = widget.controller.customRange.value!.start;
      _endDate = widget.controller.customRange.value!.end;
    } else if (widget.controller.fromDate.value.isNotEmpty &&
        widget.controller.toDate.value.isNotEmpty) {
      _startDate =
          DateTime.tryParse(widget.controller.fromDate.value) ??
          DateTime(now.year, now.month, 1);
      _endDate =
          DateTime.tryParse(widget.controller.toDate.value) ?? now;
    } else {
      _startDate = DateTime(now.year, now.month, 1);
      _endDate = DateTime(now.year, now.month + 1, 0); // End of current month
    }
  }

  int get _daysCount {
    if (_endDate.isBefore(_startDate)) return 0;
    return _endDate.difference(_startDate).inDays + 1;
  }

  bool get _isValidRange =>
      !_endDate.isBefore(_startDate) && _daysCount > 0 && _daysCount <= 62;

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';
  }

  String _weekdayName(DateTime dt) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[dt.weekday - 1];
  }

  Future<void> _pickStartDate() async {
    HapticFeedback.selectionClick();
    final now = DateTime.now();
    final minDate = DateTime(2020, 1, 1);
    final maxDate = DateTime(now.year + 2, 12, 31);

    // Guaranteed assertion-safe initialDate
    final safeInitial = _startDate.isAfter(maxDate)
        ? maxDate
        : (_startDate.isBefore(minDate) ? minDate : _startDate);

    final picked = await showDatePicker(
      context: context,
      initialDate: safeInitial,
      firstDate: minDate,
      lastDate: maxDate,
      builder: _datePickerThemeBuilder,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        // If end date is now before start date, adjust end date automatically
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate;
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    HapticFeedback.selectionClick();
    final now = DateTime.now();
    final minDate = _startDate;
    final maxDate = DateTime(now.year + 2, 12, 31);

    // Guaranteed assertion-safe initialDate: must be within [minDate, maxDate]
    final safeInitial = _endDate.isAfter(maxDate)
        ? maxDate
        : (_endDate.isBefore(minDate) ? minDate : _endDate);

    final picked = await showDatePicker(
      context: context,
      initialDate: safeInitial,
      firstDate: minDate,
      lastDate: maxDate,
      builder: _datePickerThemeBuilder,
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Widget _datePickerThemeBuilder(BuildContext ctx, Widget? child) {
    return Theme(
      data: Theme.of(ctx).copyWith(
        colorScheme: ColorScheme.light(
          primary: AppColors.primary,
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

  void _applyPreset(int days) {
    HapticFeedback.selectionClick();
    final now = DateTime.now();
    setState(() {
      _endDate = now;
      _startDate = now.subtract(Duration(days: days - 1));
    });
  }

  void _applyMonthPreset(int year, int month) {
    HapticFeedback.selectionClick();
    final lastDay = DateTime(year, month + 1, 0).day;
    setState(() {
      _startDate = DateTime(year, month, 1);
      _endDate = DateTime(year, month, lastDay);
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
            // ─── 1. Top Drag Pill ───
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

            // ─── 2. Header: Icon, Title, and Close Button ───
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.r),
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
                          'Select Date Range',
                          style: AppTextStyles.text14.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                        Text(
                          'Filter attendance records by custom dates',
                          style: AppTextStyles.text10.copyWith(
                            color: AppColors.subTextColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(
                    Icons.close_rounded,
                    size: 20.sp,
                    color: AppColors.subTextColor,
                  ),
                  splashRadius: 20.r,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),

            AppSpaces.vSpace14,

            // ─── 3. Quick Shortcut Presets ───
            Text(
              'Quick Shortcuts',
              style: AppTextStyles.text10.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.subTextColor,
              ),
            ),
            AppSpaces.vSpace6,
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildShortcutChip('Last 7 Days', () => _applyPreset(7)),
                  _buildShortcutChip('Last 14 Days', () => _applyPreset(14)),
                  _buildShortcutChip('Last 30 Days', () => _applyPreset(30)),
                  _buildShortcutChip('This Month', () {
                    final n = DateTime.now();
                    _applyMonthPreset(n.year, n.month);
                  }),
                  _buildShortcutChip('Last Month', () {
                    final lm = DateTime(DateTime.now().year, DateTime.now().month - 1);
                    _applyMonthPreset(lm.year, lm.month);
                  }),
                ],
              ),
            ),

            AppSpaces.vSpace14,

            // ─── 4. Interactive Dual Date Pickers (From -> To) ───
            Row(
              children: [
                // Start Date Card
                Expanded(
                  child: _buildDateSelectCard(
                    title: 'FROM DATE',
                    date: _startDate,
                    onTap: _pickStartDate,
                    icon: Icons.calendar_today_rounded,
                  ),
                ),

                // Arrow Divider Indicator
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Container(
                    width: 28.r,
                    height: 28.r,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 14.sp,
                      color: AppColors.secondary,
                    ),
                  ),
                ),

                // End Date Card
                Expanded(
                  child: _buildDateSelectCard(
                    title: 'TO DATE',
                    date: _endDate,
                    onTap: _pickEndDate,
                    icon: Icons.event_available_rounded,
                  ),
                ),
              ],
            ),

            AppSpaces.vSpace12,

            // ─── 5. Dynamic Validation / Status Pill ───
            _buildStatusBanner(),

            AppSpaces.vSpace16,

            // ─── 6. Action Button: Apply Custom Range ───
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      side: BorderSide(color: AppColors.borderColor, width: 1.w),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: AppTextStyles.text12.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.subTextColor,
                      ),
                    ),
                  ),
                ),
                AppSpaces.hSpace10,
                Expanded(
                  flex: 2,
                  child: CustomButton(
                    text: 'Apply Range ($_daysCount Days)',
                    isGradient: true,
                    onPressed: _isValidRange
                        ? () {
                            Get.back();
                            widget.controller.applyCustomDateRange(
                              _startDate,
                              _endDate,
                            );
                          }
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShortcutChip(String label, VoidCallback onTap) {
    return Padding(
      padding: EdgeInsets.only(right: 6.w),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: AppColors.inputFill,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: AppColors.borderColor,
              width: 0.8.w,
            ),
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

  Widget _buildDateSelectCard({
    required String title,
    required DateTime date,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppColors.secondary.withValues(alpha: 0.4),
            width: 1.w,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.03),
              blurRadius: 6.r,
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
                  icon,
                  size: 11.sp,
                  color: AppColors.secondary,
                ),
                AppSpaces.hSpace4,
                Text(
                  title,
                  style: AppTextStyles.text10.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            AppSpaces.vSpace4,
            Text(
              _formatDate(date),
              style: AppTextStyles.text14.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            Text(
              _weekdayName(date),
              style: AppTextStyles.text10.copyWith(
                color: AppColors.subTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner() {
    if (_endDate.isBefore(_startDate)) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded,
                size: 13.sp, color: AppColors.error),
            AppSpaces.hSpace6,
            Text(
              'Start date must be on or before end date',
              style: AppTextStyles.text10.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ],
        ),
      );
    }

    if (_daysCount > 62) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                size: 13.sp, color: AppColors.warning),
            AppSpaces.hSpace6,
            Expanded(
              child: Text(
                '$_daysCount days selected. Server allows max 62 days per request.',
                style: AppTextStyles.text10.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.warning,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline_rounded,
              size: 13.sp, color: AppColors.secondary),
          AppSpaces.hSpace6,
          Expanded(
            child: Text(
              '$_daysCount Days Range (${_formatDate(_startDate)} — ${_formatDate(_endDate)})',
              style: AppTextStyles.text10.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
