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
import '../controller/support_ticket_controller.dart';
import 'components/create_ticket_bottom_sheet.dart';
import 'components/support_ticket_card.dart';
import 'components/ticket_thread_bottom_sheet.dart';

/// Main View for Support Tickets & Helpdesk (Phase 10)
/// Strictly adheres to .agents/rules/ams.md:
/// - Root wrapped in NetworkBoundaryWrapper
/// - View only calls Controller methods and observes state via Obx
/// - Permission-driven access (support.view and support.raise)
class SupportTicketsView extends GetView<SupportTicketController> {
  const SupportTicketsView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkBoundaryWrapper(
      onRetry: () => controller.loadTickets(isRefresh: true),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Stack(
          children: [
            // 1. Signature Curved Ambient Background
            EmployeeAmbientHeader(height: 220.h),

            // 2. Main Foreground Layout
            SafeArea(
              child: Column(
                children: [
                  // Top Screen Header with Title & Action Button
                  Padding(
                    padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 0),
                    child: Obx(() {
                      final canRaise = controller.canRaise;
                      final isForbidden = controller.isForbidden.value;

                      return CustomScreenHeader(
                        title: 'Helpdesk & Support',
                        subtitle:
                            'Submit inquiries, report issues & get assistance',
                        actions: (canRaise && !isForbidden)
                            ? [
                                CustomScreenHeader.actionButton(
                                  icon: Icons.add_rounded,
                                  tooltip: 'New Ticket',
                                  onTap: () => CreateTicketBottomSheet.show(
                                    context,
                                    controller,
                                  ),
                                ),
                              ]
                            : null,
                      );
                    }),
                  ),

                  AppSpaces.vSpace10,

                  // Filter Pills (Active vs Finished)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Obx(() => _buildFilterPills()),
                  ),

                  AppSpaces.vSpace12,

                  // Tickets Body
                  Expanded(
                    child: Obx(() {
                      // Permission Forbidden State
                      if (controller.isForbidden.value) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                            child: CustomStateView.error(
                              title: 'Access Restricted',
                              message: controller.forbiddenMessage.value,
                            ),
                          ),
                        );
                      }

                      // Loading State
                      if (controller.isLoading.value &&
                          controller.tickets.isEmpty) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppColors.secondary,
                          ),
                        );
                      }

                      // Empty State
                      if (controller.tickets.isEmpty) {
                        return RefreshIndicator(
                          onRefresh: () =>
                              controller.loadTickets(isRefresh: true),
                          color: AppColors.secondary,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.w,
                              vertical: 60.h,
                            ),
                            child: CustomStateView.empty(
                              title: controller.showFinished.value
                                  ? 'No Closed Tickets'
                                  : 'No Open Tickets',
                              message: controller.showFinished.value
                                  ? 'You have no resolved or closed support inquiries on record.'
                                  : 'No pending support tickets found. Need assistance? Tap "New Ticket" to contact support.',
                            ),
                          ),
                        );
                      }

                      // Ticket List
                      return RefreshIndicator(
                        onRefresh: () =>
                            controller.loadTickets(isRefresh: true),
                        color: AppColors.secondary,
                        child: ListView.builder(
                          controller: controller.scrollController,
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 4.h,
                          ),
                          itemCount: controller.tickets.length,
                          itemBuilder: (ctx, index) {
                            final ticket = controller.tickets[index];
                            return SupportTicketCard(
                              ticket: ticket,
                              onTap: () async {
                                await controller.openTicketThread(ticket.id);
                                if (context.mounted) {
                                  TicketThreadBottomSheet.show(
                                    context,
                                    controller,
                                  );
                                }
                              },
                            );
                          },
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPills() {
    final isFinished = controller.showFinished.value;

    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderColor, width: 1.w),
      ),
      child: Row(
        children: [
          // Active Tickets Pill
          Expanded(
            child: GestureDetector(
              onTap: () => controller.setFilter(false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: 8.h),
                decoration: BoxDecoration(
                  color: !isFinished
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: Text(
                    'Active Tickets',
                    style: AppTextStyles.text12.copyWith(
                      color: !isFinished
                          ? Colors.white
                          : AppColors.subTextColor,
                      fontWeight:
                          !isFinished ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Finished / Closed Pill
          Expanded(
            child: GestureDetector(
              onTap: () => controller.setFilter(true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: 8.h),
                decoration: BoxDecoration(
                  color: isFinished
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: Text(
                    'Resolved & Closed',
                    style: AppTextStyles.text12.copyWith(
                      color: isFinished
                          ? Colors.white
                          : AppColors.subTextColor,
                      fontWeight:
                          isFinished ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
