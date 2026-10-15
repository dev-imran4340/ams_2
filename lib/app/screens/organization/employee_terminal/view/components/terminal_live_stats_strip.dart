import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_spaces.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../model/employee_terminal_model.dart';

class TerminalLiveStatsStrip extends StatelessWidget {
  final TerminalTelemetryModel? telemetry;

  const TerminalLiveStatsStrip({
    super.key,
    required this.telemetry,
  });

  @override
  Widget build(BuildContext context) {
    final stats = telemetry ??
        const TerminalTelemetryModel(
          totalStaff: 160,
          presentToday: 142,
          absentToday: 14,
          unmarked: 4,
        );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 18.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.r),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            border: Border(
              bottom: BorderSide(
                color: AppColors.secondary,
                width: 3.w,
              ),
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          child: Row(
            children: [
              // 1. Total Staff
              Expanded(
                child: _buildCapsule(
                  label: 'Total Staff',
                  count: '${stats.totalStaff}',
                  color: AppColors.primary,
                  icon: Icons.people_alt_rounded,
                ),
              ),
              _buildDivider(),
              // 2. Present / In
              Expanded(
                child: _buildCapsule(
                  label: 'Present In',
                  count: '${stats.presentToday}',
                  color: AppColors.success,
                  icon: Icons.login_rounded,
                ),
              ),
              _buildDivider(),
              // 3. Absent / Out
              Expanded(
                child: _buildCapsule(
                  label: 'Absent',
                  count: '${stats.absentToday}',
                  color: AppColors.error,
                  icon: Icons.person_off_rounded,
                ),
              ),
              _buildDivider(),
              // 4. Pending
              Expanded(
                child: _buildCapsule(
                  label: 'Pending',
                  count: '${stats.unmarked}',
                  color: AppColors.warning,
                  icon: Icons.pending_actions_rounded,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCapsule({
    required String label,
    required String count,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 12.sp, color: color),
            AppSpaces.hSpace4,
            Text(
              count,
              style: AppTextStyles.text14.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        AppSpaces.vSpace2,
        Text(
          label,
          style: AppTextStyles.text8.copyWith(
            color: AppColors.subTextColor,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1.w,
      height: 24.h,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      color: AppColors.borderColor,
    );
  }
}
