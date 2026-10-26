import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_spaces.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/widgets/custom_screen_header.dart';
import '../../../core/widgets/custom_state_view.dart';
import '../../../core/widgets/employee_ambient_header.dart';
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
            // 1. Curved Ambient Gradient Header (240.h)
            EmployeeAmbientHeader(height: 240.h),

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
                      const CustomScreenHeader(
                        title: 'Performance & KPIs',
                        subtitle: 'Quarterly Appraisal & Skill Score',
                      ),

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
