import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../controller/schedule_controller.dart';
import 'schedule_date_range_sheet.dart';

/// Interactive top row displaying From & To date selection fields for Work Schedule
/// Matches GET /me/schedule?from=YYYY-MM-DD&to=YYYY-MM-DD API requirements.
class ScheduleDateRangeBar extends StatelessWidget {
  final ScheduleController controller;

  const ScheduleDateRangeBar({
    super.key,
    required this.controller,
  });

  String _formatPrettyDate(String isoDate) {
    if (isoDate.isEmpty) return '--';
    final dt = DateTime.tryParse(isoDate);
    if (dt == null) return isoDate;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpaces.horizontalPadding,
      child: Obx(() {
        final from = controller.fromDate.value;
        final to = controller.toDate.value;

        return Row(
          children: [
            // From Field Box
            Expanded(
              child: _buildPickerCard(
                label: 'FROM DATE',
                value: _formatPrettyDate(from),
                icon: Icons.calendar_today_rounded,
                onTap: () => ScheduleDateRangeSheet.show(context, controller),
              ),
            ),
            AppSpaces.hSpace8,

            // Arrow Divider
            Container(
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_rounded,
                size: 13.sp,
                color: AppColors.secondary,
              ),
            ),
            AppSpaces.hSpace8,

            // To Field Box
            Expanded(
              child: _buildPickerCard(
                label: 'TO DATE',
                value: _formatPrettyDate(to),
                icon: Icons.event_available_rounded,
                onTap: () => ScheduleDateRangeSheet.show(context, controller),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildPickerCard({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppColors.borderColor,
              width: 1.w,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.04),
                blurRadius: 6.r,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(5.r),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Icon(
                  icon,
                  size: 13.sp,
                  color: AppColors.secondary,
                ),
              ),
              AppSpaces.hSpace8,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.text10.copyWith(
                        fontSize: 8.5.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.subTextColor,
                        letterSpacing: 0.4,
                      ),
                    ),
                    AppSpaces.vSpace2,
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.text12.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

