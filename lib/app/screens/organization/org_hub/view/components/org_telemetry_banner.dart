import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_spaces.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../controller/org_hub_controller.dart';

class OrgTelemetryBanner extends GetView<OrgHubController> {
  const OrgTelemetryBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final summary = controller.summary.value;
      final visitorsCount = summary?.activeVisitorsCount ?? 8;
      final presentCount = summary?.todayEmployeesPresent ?? 142;
      final totalStaff = summary?.totalStaff ?? 160;
      final isLive = summary?.isGateTerminalActive ?? true;

      return Container(
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.12),
              blurRadius: 22.r,
              offset: Offset(0, 8.h),
            ),
          ],
        ),
        padding: EdgeInsets.only(bottom: 3.w),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.r),
              topRight: Radius.circular(16.r),
              bottomLeft: Radius.circular(13.r),
              bottomRight: Radius.circular(13.r),
            ),
            border: Border.all(
              color: AppColors.borderColor,
              width: 1.w,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row of Telemetry
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8.r,
                        height: 8.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isLive ? AppColors.success : AppColors.warning,
                          boxShadow: [
                            BoxShadow(
                              color: (isLive ? AppColors.success : AppColors.warning)
                                  .withValues(alpha: 0.6),
                              blurRadius: 6.r,
                              spreadRadius: 1.r,
                            ),
                          ],
                        ),
                      ),
                      AppSpaces.hSpace8,
                      Text(
                        'REAL-TIME FACILITY TELEMETRY',
                        style: AppTextStyles.text10.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: AppColors.subTextColor,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      'Station Node 01',
                      style: AppTextStyles.text10.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ],
              ),

              AppSpaces.vSpace14,

              // 3 Metric Capsules Row
              Row(
                children: [
                  // 1. Active Visitors Capsule
                  Expanded(
                    child: _buildMetricPill(
                      icon: Icons.people_alt_rounded,
                      iconColor: AppColors.secondary,
                      bgColor: AppColors.secondary.withValues(alpha: 0.08),
                      title: 'Visitors',
                      primaryValue: '$visitorsCount',
                      subtitle: 'On-Site Now',
                    ),
                  ),

                  AppSpaces.hSpace10,

                  // 2. Staff Attendance Capsule
                  Expanded(
                    child: _buildMetricPill(
                      icon: Icons.badge_rounded,
                      iconColor: AppColors.primary,
                      bgColor: AppColors.primary.withValues(alpha: 0.08),
                      title: 'Staff Present',
                      primaryValue: '$presentCount',
                      subtitle: 'of $totalStaff Total',
                    ),
                  ),

                  AppSpaces.hSpace10,

                  // 3. Gate Terminal Status
                  Expanded(
                    child: _buildMetricPill(
                      icon: Icons.wifi_tethering_rounded,
                      iconColor: isLive ? AppColors.success : AppColors.warning,
                      bgColor: (isLive ? AppColors.success : AppColors.warning)
                          .withValues(alpha: 0.08),
                      title: 'Gate Status',
                      primaryValue: isLive ? 'Online' : 'Standby',
                      subtitle: 'Cloud Sync 100%',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildMetricPill({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String primaryValue,
    required String subtitle,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: iconColor.withValues(alpha: 0.2),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14.sp, color: iconColor),
              AppSpaces.hSpace4,
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.text10.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.subTextColor,
                  ),
                ),
              ),
            ],
          ),
          AppSpaces.vSpace4,
          Text(
            primaryValue,
            style: AppTextStyles.text18.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          AppSpaces.vSpace2,
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.text10.copyWith(
              color: AppColors.subTextColor,
              fontSize: 9.sp,
            ),
          ),
        ],
      ),
    );
  }
}
