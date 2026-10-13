import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../controller/leave_controller.dart';
import '../../model/leave_model.dart';

class LeaveBalanceCardStrip extends GetView<LeaveController> {
  const LeaveBalanceCardStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.balances;
      if (items.isEmpty) return const SizedBox.shrink();

      return SizedBox(
        height: 122.h,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          itemCount: items.length,
          separatorBuilder: (context, index) => AppSpaces.hSpace12,
          itemBuilder: (context, index) {
            return _buildBalanceCard(items[index]);
          },
        ),
      );
    });
  }

  Widget _buildBalanceCard(LeaveBalanceModel item) {
    final accent = item.accentColor;
    final remainingFormatted = item.remainingCount.toString().padLeft(2, '0');
    final totalFormatted = item.totalQuota.toString().padLeft(2, '0');

    IconData icon;
    if (item.leaveType.toLowerCase().contains('casual')) {
      icon = Icons.beach_access_rounded;
    } else if (item.leaveType.toLowerCase().contains('annual')) {
      icon = Icons.flight_takeoff_rounded;
    } else {
      icon = Icons.local_hospital_rounded;
    }

    return Container(
      width: 190.w,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.borderColor,
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 12.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Row: Category Icon & Remaining/Total Ratio Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 32.r,
                height: 32.r,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16.sp, color: accent),
              ),

              // Utilization percentage badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: accent.withValues(alpha: 0.2),
                    width: 0.8.w,
                  ),
                ),
                child: Text(
                  '${((1 - item.utilizationRatio) * 100).toInt()}% left',
                  style: AppTextStyles.text10.copyWith(
                    fontWeight: FontWeight.bold,
                    color: accent,
                  ),
                ),
              ),
            ],
          ),

          // Middle: Category Name
          Text(
            item.leaveType,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.text12.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.subTextColor,
            ),
          ),

          // Bottom: Large Bold Numbers & Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    remainingFormatted,
                    style: AppTextStyles.text18.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textColor,
                    ),
                  ),
                  Text(
                    ' / $totalFormatted Days',
                    style: AppTextStyles.text10.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.subTextColor,
                    ),
                  ),
                ],
              ),
              AppSpaces.vSpace4,

              // Sleek Linear Indicator showing percentage
              ClipRRect(
                borderRadius: BorderRadius.circular(3.r),
                child: LinearProgressIndicator(
                  value: item.remainingRatio,
                  minHeight: 4.h,
                  backgroundColor: AppColors.borderColor.withValues(alpha: 0.6),
                  valueColor: AlwaysStoppedAnimation<Color>(accent),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
