import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_spaces.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_screen_header.dart';
import '../../../core/widgets/custom_state_view.dart';
import '../../../core/widgets/employee_ambient_header.dart';
import '../../../core/widgets/network_boundary_wrapper.dart';
import '../controller/money_request_controller.dart';
import '../model/money_request_model.dart';
import 'components/apply_money_request_bottom_sheet.dart';
import 'components/money_request_card.dart';
import 'components/money_request_details_bottom_sheet.dart';

/// Screen: Dedicated Loans, Advances & Expenses Feature (Phase 13)
/// Strictly adheres to .agents/rules/ams.md and doc/api.md Phase 13 contracts:
/// - GET /api/v1/me/money-request-types
/// - POST /api/v1/me/money-requests
/// - GET /api/v1/me/money-requests
/// - GET /api/v1/me/money-requests/{id}
/// - POST /api/v1/me/money-requests/{id}/cancel
class MoneyRequestsView extends GetView<MoneyRequestController> {
  const MoneyRequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkBoundaryWrapper(
      onRetry: () => controller.loadLoansData(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Stack(
          children: [
            // 1. Signature Curved Ambient Background
            EmployeeAmbientHeader(height: 230.h),

            // 2. Main Foreground Layout
            SafeArea(
              child: Column(
                children: [
                  // Top Header: Title, Subtitle & Request Action Button
                  Padding(
                    padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 0),
                    child: Obx(() {
                      final hasModule = controller.isLoansModuleActive.value;
                      final isRestricted = controller.isAccessRestricted.value;

                      return CustomScreenHeader(
                        title: 'Money Requests',
                        subtitle:
                            'Staff loans, salary advances & expense claims',
                        actions: (hasModule && !isRestricted)
                            ? [
                                CustomScreenHeader.actionButton(
                                  icon: Icons.add_rounded,
                                  tooltip: 'Apply Money Request',
                                  onTap: () => ApplyMoneyRequestBottomSheet.show(
                                      context, controller),
                                ),
                              ]
                            : null,
                      );
                    }),
                  ),

                  AppSpaces.vSpace10,

                  // Filter Pills Strip (All, Loans, Advances, Expenses)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Obx(() => _buildFilterPills()),
                  ),

                  AppSpaces.vSpace12,

                  // Scrollable Content
                  Expanded(
                    child: Obx(() {
                      // Gate 1: Module Disabled for Company
                      if (!controller.isLoansModuleActive.value) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: CustomStateView.empty(
                              title: 'Money Requests Module Disabled',
                              message:
                                  'Money Requests is not included in your company subscription.',
                            ),
                          ),
                        );
                      }

                      // Gate 2: Access Restricted (403 Forbidden)
                      if (controller.isAccessRestricted.value) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: CustomStateView.empty(
                              title: 'Access Restricted',
                              message: controller
                                      .accessRestrictedMessage.value.isNotEmpty
                                  ? controller.accessRestrictedMessage.value
                                  : 'You do not have permission to access Money Requests.',
                              buttonText: 'Back to Home',
                              onAction: () => Get.back(),
                            ),
                          ),
                        );
                      }

                      // Loading State
                      if (controller.isLoading.value &&
                          controller.moneyRequests.isEmpty) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppColors.secondary,
                            strokeWidth: 2.8.w,
                          ),
                        );
                      }

                      // Empty State
                      final requests = controller.filteredRequests;
                      if (requests.isEmpty) {
                        return RefreshIndicator(
                          onRefresh: controller.loadLoansData,
                          color: AppColors.primary,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20.w, vertical: 60.h),
                              child: CustomStateView.empty(
                                title: 'No Requests Found',
                                message:
                                    'You have no submitted money requests under this filter.',
                              ),
                            ),
                          ),
                        );
                      }

                      // Request Cards List
                      return RefreshIndicator(
                        onRefresh: controller.loadLoansData,
                        color: AppColors.primary,
                        child: ListView.builder(
                          controller: controller.scrollController,
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 6.h),
                          itemCount: requests.length,
                          itemBuilder: (ctx, index) {
                            final req = requests[index];
                            return MoneyRequestCard(
                              request: req,
                              onTap: () => _openRequestDetails(context, req),
                            );
                          },
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            // 3. Screen-Level Cancelling Indicator Overlay
            Obx(() {
              if (!controller.isCancelling.value) return const SizedBox.shrink();

              return Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.35),
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 24.w, vertical: 16.h),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                            color: AppColors.borderColor, width: 1.w),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 16.r,
                            offset: Offset(0, 4.h),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 22.r,
                            height: 22.r,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5.w,
                              color: AppColors.error,
                            ),
                          ),
                          AppSpaces.hSpace12,
                          Text(
                            'Withdrawing Request...',
                            style: AppTextStyles.text12.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
        bottomNavigationBar: Obx(() {
          final hasModule = controller.isLoansModuleActive.value;
          final isRestricted = controller.isAccessRestricted.value;

          if (!hasModule || isRestricted) return const SizedBox.shrink();

          return Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              border: Border(
                top: BorderSide(color: AppColors.borderColor, width: 1.w),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 16.r,
                  offset: Offset(0, -4.h),
                ),
              ],
            ),
            child: SafeArea(
              child: CustomButton(
                text: 'Apply Money Request',
                isGradient: true,
                onPressed: () =>
                    ApplyMoneyRequestBottomSheet.show(context, controller),
                icon: Icon(
                  Icons.add_rounded,
                  size: 18.sp,
                  color: AppColors.white,
                ),
                height: 48.h,
                borderRadius: 14.r,
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Horizontal pill filter (All, Loans, Advances, Expenses)
  Widget _buildFilterPills() {
    final filters = [
      {'key': 'all', 'label': 'All Requests'},
      {'key': 'loan', 'label': 'Loans'},
      {'key': 'advance', 'label': 'Advances'},
      {'key': 'expense', 'label': 'Expenses'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((f) {
          final isSelected = controller.selectedFilterKind.value == f['key'];
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: InkWell(
              onTap: () => controller.setFilterKind(f['key']!),
              borderRadius: BorderRadius.circular(20.r),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding:
                    EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.borderColor,
                    width: 1.w,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  f['label']!,
                  style: AppTextStyles.text12.copyWith(
                    color: isSelected ? Colors.white : AppColors.textColor,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Opens detailed modal sheet for a specific money request
  Future<void> _openRequestDetails(
    BuildContext context,
    MoneyRequestItemModel req,
  ) async {
    // Show non-blocking minimal spinner dialog (no text label)
    Get.dialog(
      PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: EdgeInsets.all(18.r),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.borderColor, width: 1.w),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 16.r,
                  offset: Offset(0, 4.h),
                ),
              ],
            ),
            child: SizedBox(
              width: 32.r,
              height: 32.r,
              child: CircularProgressIndicator(
                strokeWidth: 2.8.w,
                color: AppColors.secondary,
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    MoneyRequestItemModel? fullDetails;
    try {
      fullDetails = await controller.fetchDetails(req.id);
    } finally {
      if (Get.isDialogOpen == true) {
        Get.back(); // Dismiss loading spinner
      }
    }

    if (fullDetails != null && context.mounted) {
      MoneyRequestDetailsBottomSheet.show(
        context,
        details: fullDetails,
        isCancelling: controller.isCancelling.value,
        onCancelRequest: (reason) async {
          controller.cancelReasonController.text = reason;
          await controller.cancelRequest(fullDetails!.id);
        },
      );
    }
  }
}
