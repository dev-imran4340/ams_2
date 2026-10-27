import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/custom_state_view.dart';
import '../../../../routes/app_routes.dart';
import '../../controller/profile_controller.dart';

class ProfileAttendanceTab extends GetView<ProfileController> {
  const ProfileAttendanceTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final p = controller.profile.value;
      final shiftName = p?.shiftName;
      final shiftTime = p?.shiftTime;
      final grace = p?.graceMinutes;
      final score = p?.attendanceScore;

      final shiftRows = <_AttendanceRowData>[];
      if (shiftName != null && shiftName.trim().isNotEmpty) {
        shiftRows.add(_AttendanceRowData('Shift Name', shiftName, Icons.work_history_outlined));
      }
      if (shiftTime != null && shiftTime.trim().isNotEmpty) {
        shiftRows.add(_AttendanceRowData('Working Hours', shiftTime, Icons.access_time_rounded));
      }
      if (grace != null && grace > 0) {
        shiftRows.add(_AttendanceRowData('Grace Period', '$grace Minutes', Icons.timer_outlined));
      }

      final hasShift = shiftRows.isNotEmpty;
      final hasScore = score != null;

      if (!hasShift && !hasScore) {
        return CustomStateView.empty(
          title: 'No Attendance Data',
          message: 'No assigned shift or attendance health metrics are available for this profile.',
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Shift Schedule Card (Only if shift rows exist)
          if (hasShift) ...[
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32.r,
                        height: 32.r,
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.schedule_rounded,
                          size: 16.sp,
                          color: AppColors.secondary,
                        ),
                      ),
                      AppSpaces.hSpace8,
                      Text(
                        'Assigned Shift & Rules',
                        style: AppTextStyles.text14.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                    ],
                  ),
                  AppSpaces.vSpace14,
                  for (int i = 0; i < shiftRows.length; i++) ...[
                    _buildInfoRow(shiftRows[i].label, shiftRows[i].value, shiftRows[i].icon),
                    if (i < shiftRows.length - 1) _buildDivider(),
                  ],
                ],
              ),
            ),
            AppSpaces.vSpace14,
          ],

          // 2. Performance & Score Card (Only if score is provided by backend)
          if (hasScore) ...[
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32.r,
                            height: 32.r,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.insights_rounded,
                              size: 16.sp,
                              color: AppColors.primary,
                            ),
                          ),
                          AppSpaces.hSpace8,
                          Text(
                            'Attendance Health',
                            style: AppTextStyles.text14.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          'Active',
                          style: AppTextStyles.text10.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                  AppSpaces.vSpace14,
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$score%',
                              style: AppTextStyles.text24.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              'Punctuality & Presence',
                              style: AppTextStyles.text10.copyWith(
                                color: AppColors.subTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Get.toNamed(Routes.ATTENDANCE_HISTORY),
                        borderRadius: BorderRadius.circular(10.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'View Logs',
                                style: AppTextStyles.text12.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.white,
                                ),
                              ),
                              AppSpaces.hSpace4,
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 11.sp,
                                color: AppColors.secondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],]
      );
    });
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 15.sp, color: AppColors.secondary),
        AppSpaces.hSpace8,
        Text(
          label,
          style: AppTextStyles.text12.copyWith(
            color: AppColors.subTextColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        AppSpaces.hSpace8,
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 3,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.text12.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Divider(
        height: 1.h,
        color: AppColors.borderColor.withValues(alpha: 0.6),
      ),
    );
  }
}

class _AttendanceRowData {
  final String label;
  final String value;
  final IconData icon;
  const _AttendanceRowData(this.label, this.value, this.icon);
}
