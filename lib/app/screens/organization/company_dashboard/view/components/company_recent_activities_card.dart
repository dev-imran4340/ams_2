import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_spaces.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../controller/company_dashboard_controller.dart';
import '../../model/company_dashboard_model.dart';

class CompanyRecentActivitiesCard extends GetView<CompanyDashboardController> {
  const CompanyRecentActivitiesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Header with Icon, Title and Filter Segment
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
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
                          Icons.history_rounded,
                          color: AppColors.primary,
                          size: 20.sp,
                        ),
                      ),
                    ),
                    AppSpaces.hSpace10,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recent Activities',
                          style: AppTextStyles.text14.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                        AppSpaces.vSpace2,
                        Text(
                          'Live punch feed • Tap row to expand details',
                          style: AppTextStyles.text10.copyWith(
                            color: AppColors.subTextColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. Filter Tabs
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            child: Obx(() {
              final filters = ['All', 'Check-In', 'Check-Out'];
              return Row(
                children: filters.map((f) {
                  final isSelected = controller.selectedActivityFilter.value == f;
                  return Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: InkWell(
                      onTap: () => controller.selectedActivityFilter.value = f,
                      borderRadius: BorderRadius.circular(8.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.secondary
                              : AppColors.inputFill,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          f,
                          style: AppTextStyles.text10.copyWith(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? AppColors.white : AppColors.subTextColor,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            }),
          ),

          AppSpaces.vSpace8,

          // 3. Table Column Headers (Expanded flex - Fits Phone & Tablet, No Horizontal Scroll)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            color: AppColors.primary.withValues(alpha: 0.05),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    'STAFF MEMBER',
                    style: AppTextStyles.text10.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'STATUS',
                    style: AppTextStyles.text10.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'PUNCH TIME',
                    style: AppTextStyles.text10.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                SizedBox(width: 24.w), // Space for expand chevron
              ],
            ),
          ),

          // 4. Responsive & Expandable Rows (Zero Horizontal Scroll!)
          Obx(() {
            final activities = controller.filteredActivities;

            if (activities.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.history_toggle_off_rounded,
                        size: 32.sp,
                        color: AppColors.subTextColor.withValues(alpha: 0.5),
                      ),
                      AppSpaces.vSpace8,
                      Text(
                        'No recent check-in activity recorded for this filter.',
                        style: AppTextStyles.text12.copyWith(color: AppColors.subTextColor),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activities.length,
              separatorBuilder: (context, index) => Divider(
                color: AppColors.borderColor.withValues(alpha: 0.6),
                height: 1.h,
              ),
              itemBuilder: (context, index) {
                final item = activities[index];
                final isExpanded = controller.expandedActivityIndex.value == index;

                return _buildExpandableRow(item, index, isExpanded);
              },
            );
          }),

          AppSpaces.vSpace6,
        ],
      ),
    );
  }

  Widget _buildExpandableRow(
    CompanyRecentActivityModel item,
    int index,
    bool isExpanded,
  ) {
    final statusColor = item.isCheckIn ? AppColors.success : AppColors.warning;

    return InkWell(
      onTap: () => controller.toggleActivityExpanded(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        color: isExpanded
            ? AppColors.primary.withValues(alpha: 0.03)
            : Colors.transparent,
        child: Column(
          children: [
            // Main Responsive Row
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  // 1. Employee Avatar & Name
                  Expanded(
                    flex: 4,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14.r,
                          backgroundColor: statusColor.withValues(alpha: 0.12),
                          child: Text(
                            item.name.isNotEmpty ? item.name[0] : 'E',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ),
                        AppSpaces.hSpace8,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.text12.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textColor,
                                ),
                              ),
                              AppSpaces.vSpace2,
                              Text(
                                item.department,
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

                  // 2. Type Badge
                  Expanded(
                    flex: 3,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              item.isCheckIn
                                  ? Icons.login_rounded
                                  : Icons.logout_rounded,
                              size: 11.sp,
                              color: statusColor,
                            ),
                            AppSpaces.hSpace4,
                            Text(
                              item.type,
                              style: AppTextStyles.text10.copyWith(
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 3. Punch Time
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.inTime != '—' ? item.inTime : item.time,
                          style: AppTextStyles.text12.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                        AppSpaces.vSpace2,
                        Text(
                          item.dated,
                          style: AppTextStyles.text10.copyWith(
                            color: AppColors.subTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 4. Expand Chevron
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20.sp,
                      color: AppColors.subTextColor,
                    ),
                  ),
                ],
              ),
            ),

            // Expandable Detail Drawer ("expand wala functionality")
            if (isExpanded)
              Container(
                margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: AppColors.borderColor.withValues(alpha: 0.8),
                    width: 1.w,
                  ),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      icon: Icons.access_time_rounded,
                      label: 'Punch In / Out',
                      value: 'In: ${item.inTime}  •  Out: ${item.outTime}',
                      valueColor: AppColors.textColor,
                    ),
                    Divider(height: 12.h, color: AppColors.borderColor.withValues(alpha: 0.5)),
                    _buildDetailRow(
                      icon: Icons.apartment_rounded,
                      label: 'Department',
                      value: item.department,
                      valueColor: AppColors.textColor,
                    ),
                    Divider(height: 12.h, color: AppColors.borderColor.withValues(alpha: 0.5)),
                    _buildDetailRow(
                      icon: Icons.badge_outlined,
                      label: 'Station & Method',
                      value: 'Kiosk Station 01 • AI Facial Biometric (99.6%)',
                      valueColor: AppColors.secondary,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14.sp, color: AppColors.subTextColor),
        AppSpaces.hSpace8,
        Text(
          label,
          style: AppTextStyles.text10.copyWith(
            color: AppColors.subTextColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTextStyles.text10.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
