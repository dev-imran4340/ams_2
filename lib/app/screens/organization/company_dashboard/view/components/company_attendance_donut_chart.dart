import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_spaces.dart';
import '../../../../../core/utils/app_text_styles.dart';

/// Redesigned Today's Attendance Telemetry Card (Linear Segmented Distribution - No Circular Bar)
class CompanyAttendanceDonutChart extends StatelessWidget {
  final int totalEmployees;
  final int presentToday;
  final int absentToday;
  final int unmarkedToday;

  const CompanyAttendanceDonutChart({
    super.key,
    required this.totalEmployees,
    required this.presentToday,
    required this.absentToday,
    this.unmarkedToday = 0,
  });

  @override
  Widget build(BuildContext context) {
    final present = presentToday;
    final absent = absentToday;
    final unmarked = unmarkedToday;
    final total = totalEmployees > 0
        ? totalEmployees
        : (present + absent + unmarked);

    final presentPercent =
        total > 0 ? ((present / total) * 100).round() : 0;
    final absentPercent =
        total > 0 ? ((absent / total) * 100).round() : 0;
    final unmarkedPercent =
        total > 0 ? (100 - presentPercent - absentPercent).clamp(0, 100) : 0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.borderColor.withValues(alpha: 0.8),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 20.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header: Icon, Title, and Total Pill Badge
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 36.r,
                      height: 36.r,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.insights_rounded,
                          color: AppColors.primary,
                          size: 20.sp,
                        ),
                      ),
                    ),
                    AppSpaces.hSpace10,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Today\'s Attendance',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.text14.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor,
                            ),
                          ),
                          AppSpaces.vSpace2,
                          Text(
                            'Live shift presence',
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
              AppSpaces.hSpace8,

              // Total Staff Pill
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    width: 1.w,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6.r,
                      height: 6.r,
                      decoration: const BoxDecoration(
                        color: AppColors.successMint,
                        shape: BoxShape.circle,
                      ),
                    ),
                    AppSpaces.hSpace6,
                    Text(
                      'Total: $total',
                      style: AppTextStyles.text10.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          AppSpaces.vSpace16,

          // 2. Hero Ratio Display
          Row(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$presentPercent%',
                      style: AppTextStyles.text26.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    AppSpaces.hSpace6,
                    Flexible(
                      child: Text(
                        'Present',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.text12.copyWith(
                          color: AppColors.subTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AppSpaces.hSpace8,
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.trending_up_rounded,
                      color: AppColors.success,
                      size: 14.sp,
                    ),
                    AppSpaces.hSpace4,
                    Text(
                      '$present / $total marked',
                      style: AppTextStyles.text10.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          AppSpaces.vSpace12,

          // 3. Modern Multi-Segment Linear Attendance Bar (No Circular Bar)
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: Container(
              height: 10.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.borderColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  // Present Segment (Green)
                  if (present > 0)
                    Expanded(
                      flex: present,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.successMint, AppColors.success],
                          ),
                        ),
                      ),
                    ),

                  // Divider Gap
                  if (present > 0 && (absent > 0 || unmarked > 0))
                    Container(width: 2.w, color: AppColors.cardBackground),

                  // Absent Segment (Red)
                  if (absent > 0)
                    Expanded(
                      flex: absent,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.error, Color(0xFFDC2626)],
                          ),
                        ),
                      ),
                    ),

                  // Divider Gap
                  if (absent > 0 && unmarked > 0)
                    Container(width: 2.w, color: AppColors.cardBackground),

                  // Unmarked / Pending Segment (Neutral Amber/Gray)
                  if (unmarked > 0)
                    Expanded(
                      flex: unmarked,
                      child: Container(
                        color: AppColors.warning.withValues(alpha: 0.4),
                      ),
                    ),
                ],
              ),
            ),
          ),

          AppSpaces.vSpace16,

          // 4. Three Metric Breakdown Badges (Present, Absent, Unmarked)
          Row(
            children: [
              // Present Tile
              Expanded(
                child: _buildMetricTile(
                  label: 'Present',
                  count: '$present',
                  percentage: '$presentPercent%',
                  color: AppColors.success,
                  icon: Icons.check_circle_rounded,
                ),
              ),
              AppSpaces.hSpace8,

              // Absent Tile
              Expanded(
                child: _buildMetricTile(
                  label: 'Absent',
                  count: '$absent',
                  percentage: '$absentPercent%',
                  color: AppColors.error,
                  icon: Icons.cancel_rounded,
                ),
              ),
              AppSpaces.hSpace8,

              // Unmarked Tile
              Expanded(
                child: _buildMetricTile(
                  label: 'Unmarked',
                  count: '$unmarked',
                  percentage: '$unmarkedPercent%',
                  color: AppColors.warning,
                  icon: Icons.pending_actions_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String count,
    required String percentage,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 16.sp),
              Text(
                percentage,
                style: AppTextStyles.text10.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          AppSpaces.vSpace6,
          Text(
            count,
            style: AppTextStyles.text18.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textColor,
            ),
          ),
          AppSpaces.vSpace2,
          Text(
            label,
            style: AppTextStyles.text10.copyWith(
              color: AppColors.subTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
