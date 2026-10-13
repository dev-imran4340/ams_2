import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../controller/attendance_history_controller.dart';
import '../../model/attendance_history_model.dart';

class AttendanceCalendarStrip extends StatefulWidget {
  const AttendanceCalendarStrip({super.key});

  @override
  State<AttendanceCalendarStrip> createState() =>
      _AttendanceCalendarStripState();
}

class _AttendanceCalendarStripState extends State<AttendanceCalendarStrip> {
  final AttendanceHistoryController controller =
      Get.find<AttendanceHistoryController>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Scroll to active day once rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToActiveDay();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToActiveDay() {
    final selected = controller.selectedDate.value;
    if (selected != null && controller.logs.isNotEmpty) {
      final index = controller.logs.indexWhere(
        (log) =>
            log.date.year == selected.year &&
            log.date.month == selected.month &&
            log.date.day == selected.day,
      );
      if (index >= 0 && _scrollController.hasClients) {
        final double targetOffset = (index * 58.w) - 100.w;
        _scrollController.animateTo(
          targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final logs = controller.logs;
      final selectedDate = controller.selectedDate.value;

      if (logs.isEmpty) {
        return const SizedBox.shrink();
      }

      return SizedBox(
        height: 76.h,
        child: ListView.separated(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          itemCount: logs.length,
          separatorBuilder: (_, index) => AppSpaces.hSpace8,
          itemBuilder: (context, index) {
            final log = logs[index];
            final isSelected = selectedDate != null &&
                selectedDate.year == log.date.year &&
                selectedDate.month == log.date.month &&
                selectedDate.day == log.date.day;

            return _buildDateCapsule(log, isSelected);
          },
        ),
      );
    });
  }

  Widget _buildDateCapsule(AttendanceDayLog log, bool isSelected) {
    Color dotColor;
    switch (log.status) {
      case 'On-Time':
        dotColor = AppColors.onTimeColor;
        break;
      case 'Late':
        dotColor = AppColors.warning;
        break;
      case 'Absent':
        dotColor = AppColors.absentColor;
        break;
      case 'Leave':
        dotColor = AppColors.info;
        break;
      case 'Holiday':
        dotColor = AppColors.subTextColor.withValues(alpha: 0.5);
        break;
      default:
        dotColor = Colors.transparent;
    }

    return GestureDetector(
      onTap: () {
        controller.selectDate(log.date);
        _scrollToActiveDay();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52.w,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderColor,
            width: 1.w,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.25)
                  : AppColors.primary.withValues(alpha: 0.04),
              blurRadius: isSelected ? 12.r : 6.r,
              offset: Offset(0, isSelected ? 4.h : 2.h),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Day Name
            Text(
              log.dayName,
              style: AppTextStyles.text10.copyWith(
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? AppColors.white.withValues(alpha: 0.8)
                    : AppColors.subTextColor,
              ),
            ),
            AppSpaces.vSpace4,

            // Day Number
            Text(
              log.date.day.toString().padLeft(2, '0'),
              style: AppTextStyles.text14.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.white : AppColors.textColor,
              ),
            ),
            AppSpaces.vSpace4,

            // Status Indicator Dot
            Container(
              width: 5.r,
              height: 5.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.white : dotColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
