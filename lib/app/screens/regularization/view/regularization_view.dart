import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_spaces.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/widgets/custom_screen_header.dart';
import '../../../core/widgets/custom_state_view.dart';
import '../../../core/widgets/employee_ambient_header.dart';
import '../../../core/widgets/network_boundary_wrapper.dart';
import '../controller/regularization_controller.dart';
import 'components/adjustment_request_tile.dart';
import 'components/missed_punch_form_card.dart';
import 'components/overtime_claim_form_card.dart';
import 'components/regularization_telemetry_strip.dart';

class RegularizationView extends GetView<RegularizationController> {
  const RegularizationView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkBoundaryWrapper(
      onRetry: () => controller.loadData(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2.5.w,
              ),
            );
          }

          return Stack(
            children: [
              // 1. Curved Ambient Gradient Header
              EmployeeAmbientHeader(height: 230.h),

              // 2. Main Scrollable Content Overlapping the Header
              SafeArea(
                child: RefreshIndicator(
                  onRefresh: controller.loadData,
                  color: AppColors.primary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 10.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Executive Navigation Bar with Back Button
                        const CustomScreenHeader(
                          title: 'Attendance Adjustment',
                          subtitle: 'Regularize missed punch & claim overtime',
                        ),

                        AppSpaces.vSpace14,

                        // Modern Sliding Segment Switcher (Missed Punch vs Overtime)
                        _buildSegmentSwitcher(),

                        AppSpaces.vSpace14,

                        // Component 1: 3-Capsule Telemetry Strip
                        const RegularizationTelemetryStrip(),

                        AppSpaces.vSpace14,

                        // Component 2 & 3: Active Form Card (Missed Punch or Overtime Claim)
                        Obx(
                          () => controller.selectedSegmentIndex.value == 0
                              ? const MissedPunchFormCard()
                              : const OvertimeClaimFormCard(),
                        ),

                        AppSpaces.vSpace18,

                        // Section Header: Recent History
                        _buildSectionHeader(),

                        AppSpaces.vSpace10,

                        // Component 4: Adjustment Requests History List
                        _buildRequestsList(),

                        // Bottom safe clearance
                        SizedBox(height: 85.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }



  /// Modern Segmented Sliding Glass Switcher
  Widget _buildSegmentSwitcher() {
    return Obx(() {
      final selected = controller.selectedSegmentIndex.value;

      return Container(
        padding: EdgeInsets.all(4.r),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.borderColor, width: 1.w),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.05),
              blurRadius: 12.r,
              offset: Offset(0, 3.h),
            ),
          ],
        ),
        child: Row(
          children: [
            // Segment 0: Missed Punch
            Expanded(
              child: InkWell(
                onTap: () => controller.switchSegment(0),
                borderRadius: BorderRadius.circular(10.r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(vertical: 9.h),
                  decoration: BoxDecoration(
                    color: selected == 0
                        ? AppColors.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.fingerprint_rounded,
                        size: 15.sp,
                        color: selected == 0
                            ? AppColors.white
                            : AppColors.subTextColor,
                      ),
                      AppSpaces.hSpace6,
                      Text(
                        'Missed Punch',
                        style: AppTextStyles.text12.copyWith(
                          fontWeight: selected == 0
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: selected == 0
                              ? AppColors.white
                              : AppColors.subTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Segment 1: Overtime Claim
            Expanded(
              child: InkWell(
                onTap: () => controller.switchSegment(1),
                borderRadius: BorderRadius.circular(10.r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(vertical: 9.h),
                  decoration: BoxDecoration(
                    color: selected == 1
                        ? AppColors.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.more_time_rounded,
                        size: 15.sp,
                        color: selected == 1
                            ? AppColors.white
                            : AppColors.subTextColor,
                      ),
                      AppSpaces.hSpace6,
                      Text(
                        'Overtime Claim',
                        style: AppTextStyles.text12.copyWith(
                          fontWeight: selected == 1
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: selected == 1
                              ? AppColors.white
                              : AppColors.subTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  /// History Section Header
  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 4.w,
              height: 16.h,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            AppSpaces.hSpace8,
            Text(
              'Adjustment History',
              style: AppTextStyles.text16.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
          ],
        ),
        Obx(
          () => Text(
            '${controller.requests.length} Submissions',
            style: AppTextStyles.text12.copyWith(color: AppColors.subTextColor),
          ),
        ),
      ],
    );
  }

  /// Adjustment Requests List
  Widget _buildRequestsList() {
    return Obx(() {
      final items = controller.requests;

      if (items.isEmpty) {
        return Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(vertical: 20.h),
          child: CustomStateView.empty(
            title: 'No Adjustment Records',
            message: 'You have not submitted any missed punch or overtime claims yet.',
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return AdjustmentRequestTile(
            item: item,
            onTap: () {
              HapticFeedback.lightImpact();
            },
          );
        },
      );
    });
  }
}
