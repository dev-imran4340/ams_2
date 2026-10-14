import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_spaces.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/widgets/custom_state_view.dart';
import '../../../core/widgets/network_boundary_wrapper.dart';
import '../controller/task_controller.dart';
import 'components/task_card_tile.dart';
import 'components/task_filter_tabs.dart';
import 'components/task_telemetry_strip.dart';

class TaskView extends GetView<TaskController> {
  const TaskView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkBoundaryWrapper(
      onRetry: controller.loadTasks,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Stack(
          children: [
            // 1. Signature Curved Ambient Gradient Header (240.h) with Floating Rings
            _buildCurvedAmbientHeader(context),

            // 2. Main Scrollable Content Overlapping the Header
            SafeArea(
              bottom: false,
              child: RefreshIndicator(
                onRefresh: controller.loadTasks,
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
                      // Top Bar: Back Pill, Title/Subtitle Capsule, New Task Glass Action Pill
                      _buildTopBar(context),

                      AppSpaces.vSpace14,

                      // Component 1: Task Telemetry Strip
                      const TaskTelemetryStrip(),

                      AppSpaces.vSpace14,

                      // Component 2: Status Filter Tabs
                      const TaskFilterTabs(),

                      AppSpaces.vSpace16,

                      // Section Header: Active Roster & Live Counter
                      _buildSectionHeader(),

                      AppSpaces.vSpace10,

                      // Component 3: Task Deliverables List or State View
                      _buildTasksList(context),

                      // Bottom clearance for floating navigation
                      SizedBox(height: 80.h),
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

  /// Curved Ambient Gradient Header (240.h) with floating translucent rings
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

            // Floating Subtle Halo (Center)
            Positioned(
              top: 40.h,
              right: 80.w,
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

  /// Top executive navigation bar with Back Button, Title/Subtitle, and New Task Pill
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
              // Subtitle Capsule: Daily Deliverables & Milestones
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
                        'Daily Deliverables & Milestones',
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

              // Title: Task Operations
              Text(
                'Task Operations',
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

        AppSpaces.hSpace8,

        // Action Icon: Glass pill button (+) for "New Task"
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => controller.openCreateTaskModal(context),
            borderRadius: BorderRadius.circular(20.r),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 7.h,
              ),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: AppColors.liteSecondary.withValues(alpha: 0.4),
                  width: 1.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 8.r,
                    offset: Offset(0, 2.h),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add_rounded,
                    size: 16.sp,
                    color: AppColors.white,
                  ),
                  AppSpaces.hSpace4,
                  Text(
                    'New Task',
                    style: AppTextStyles.text12.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Section Header with live item count
  Widget _buildSectionHeader() {
    return Obx(() {
      final count = controller.filteredTasks.length;
      final filter = controller.selectedFilter.value;

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            filter == 'All' ? 'All Deliverables' : '$filter Deliverables',
            style: AppTextStyles.text14.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              '$count ${count == 1 ? 'task' : 'tasks'}',
              style: AppTextStyles.text10.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      );
    });
  }

  /// Task Deliverables List with Loading and Empty States
  Widget _buildTasksList(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2.5.w,
            ),
          ),
        );
      }

      final tasks = controller.filteredTasks;

      if (tasks.isEmpty) {
        return CustomStateView.empty(
          icon: Icons.task_alt_rounded,
          title: 'No Deliverables Found',
          message:
              'There are no operational tasks currently matching the "${controller.selectedFilter.value}" status.',
          buttonText: 'New Task',
          onAction: () => controller.openCreateTaskModal(context),
          padding: EdgeInsets.symmetric(vertical: 36.h),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: tasks.length,
        separatorBuilder: (_, _) => AppSpaces.vSpace10,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return TaskCardTile(
            key: ValueKey(task.id),
            task: task,
          );
        },
      );
    });
  }
}
