import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_spaces.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/widgets/custom_state_view.dart';
import '../../../core/widgets/network_boundary_wrapper.dart';
import '../controller/evaluation_controller.dart';
import 'components/kpi_metric_progress_tile.dart';
import 'components/manager_feedback_card.dart';
import 'components/overall_score_hero_card.dart';
import 'components/quarterly_cycle_selector.dart';

class EvaluationView extends GetView<EvaluationController> {
  const EvaluationView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkBoundaryWrapper(
      onRetry: () => controller.loadEvaluationData(controller.selectedCycle.value),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Stack(
          children: [
            // 1. Curved Ambient Gradient Header (240.h) with Floating Rings
            _buildCurvedAmbientHeader(context),

            // 2. Main Scrollable Content Overlapping the Header
            SafeArea(
              bottom: false,
              child: RefreshIndicator(
                onRefresh: () =>
                    controller.loadEvaluationData(controller.selectedCycle.value),
                color: AppColors.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 8.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Bar: Back Pill, Title/Subtitle Capsule
                      _buildTopBar(context),

                      AppSpaces.vSpace14,

                      // Component 1: Quarterly Review Cycle Selector
                      const QuarterlyCycleSelector(),

                      AppSpaces.vSpace14,

                      // Content Body (Loading / Empty / Loaded)
                      Obx(() {
                        if (controller.isLoading.value) {
                          return Container(
                            padding: EdgeInsets.symmetric(vertical: 60.h),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 2.5.w,
                              ),
                            ),
                          );
                        }

                        final report = controller.reportData.value;
                        if (report == null) {
                          return CustomStateView.empty(
                            title: 'No Evaluation Found',
                            message:
                                'No performance appraisal record found for "${controller.selectedCycle.value}".',
                            buttonText: 'Retry',
                            onAction: () => controller
                                .loadEvaluationData(controller.selectedCycle.value),
                            padding: EdgeInsets.symmetric(vertical: 40.h),
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Component 2: Overall Score Hero Card
                            const OverallScoreHeroCard(),

                            AppSpaces.vSpace20,

                            // Section Header: KPIs
                            _buildSectionHeader(
                              title: 'Key Performance Indicators (KPIs)',
                              count: report.kpis.length,
                            ),

                            AppSpaces.vSpace10,

                            // Component 3: KPI Metrics Progress Tiles List
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: report.kpis.length,
                              separatorBuilder: (_, _) => AppSpaces.vSpace10,
                              itemBuilder: (context, index) {
                                final kpi = report.kpis[index];
                                return KpiMetricProgressTile(kpi: kpi);
                              },
                            ),

                            AppSpaces.vSpace20,

                            // Section Header: Leadership Review
                            _buildSectionHeader(
                              title: 'Executive Appraisal Assessment',
                            ),

                            AppSpaces.vSpace10,

                            // Component 4: Manager Feedback Card
                            const ManagerFeedbackCard(),

                            // Bottom safe clearance
                            SizedBox(height: 70.h),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Signature Curved Ambient Gradient Header (240.h) with floating translucent rings
  Widget _buildCurvedAmbientHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 240.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.r),
          bottomRight: Radius.circular(24.r),
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary,
            AppColors.primary,
            AppColors.accentNavy,
            AppColors.primary.withValues(alpha: 0.85),
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.r),
          bottomRight: Radius.circular(24.r),
        ),
        child: Stack(
          children: [
            // Floating Translucent Ring 1 (Top Right)
            Positioned(
              top: -30.h,
              right: -30.w,
              child: Container(
                width: 150.r,
                height: 150.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary.withValues(alpha: 0.05),
                  border: Border.all(
                    color: AppColors.liteSecondary.withValues(alpha: 0.12),
                    width: 1.5.w,
                  ),
                ),
              ),
            ),

            // Floating Translucent Ring 2 (Bottom Left)
            Positioned(
              bottom: 15.h,
              left: -40.w,
              child: Container(
                width: 120.r,
                height: 120.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.08),
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    width: 1.2.w,
                  ),
                ),
              ),
            ),

            // Subtle Halo (Center)
            Positioned(
              top: 50.h,
              right: 90.w,
              child: Container(
                width: 70.r,
                height: 70.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withValues(alpha: 0.02),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Top executive navigation bar with Back Button, Title, and Subtitle Capsule
  Widget _buildTopBar(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Back Glass Pill Button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              Get.back();
            },
            borderRadius: BorderRadius.circular(20.r),
            child: Container(
              width: 38.r,
              height: 38.r,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.14),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.28),
                  width: 1.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 8.r,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 15.sp,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ),

        AppSpaces.hSpace12,

        // Title and Subtitle Capsule Column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Subtitle Capsule: Quarterly Appraisal & Skill Score
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 3.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.4),
                    width: 0.8.w,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5.r,
                      height: 5.r,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    AppSpaces.hSpace6,
                    Flexible(
                      child: Text(
                        'Quarterly Appraisal & Skill Score',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.text10.copyWith(
                          color: AppColors.liteSecondary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              AppSpaces.vSpace4,

              // Title: Performance & KPIs
              Text(
                'Performance & KPIs',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.text20.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Section Header with optional live item count
  Widget _buildSectionHeader({
    required String title,
    int? count,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.text14.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
        ),
        if (count != null)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              '$count metrics',
              style: AppTextStyles.text10.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }
}
