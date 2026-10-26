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
            // 1. Signature Curved Ambient Gradient Header (240.h)
            EmployeeAmbientHeader(height: 240.h),

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
                      CustomScreenHeader(
                        title: 'Task Operations',
                        subtitle: 'Daily Deliverables & Milestones',
                        actions: [
                          CustomScreenHeader.actionButton(
                            icon: Icons.add_rounded,
                            onTap: () => controller.openCreateTaskModal(context),
                            tooltip: 'New Task',
                          ),
                        ],
                      ),

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

  /// Top executive navigation bar with Back Button, Title/Subtitle, and New Task Pill


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
