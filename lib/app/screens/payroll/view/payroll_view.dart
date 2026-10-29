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
import '../controller/payroll_controller.dart';
import '../model/payroll_model.dart';
import 'components/payslip_card.dart';
import 'components/payslip_details_bottom_sheet.dart';
import 'components/salary_structure_card.dart';

/// Screen: Dedicated Payroll & Payslips Feature (Phase 12)
/// Adheres strictly to .agents/rules/ams.md and doc/api.md Phase 12 contracts:
/// - GET /api/v1/me/payslips
/// - GET /api/v1/me/payslips/{id}
/// - GET /api/v1/me/payslips/{id}/pdf
/// - GET /api/v1/me/salary
class PayrollView extends GetView<PayrollController> {
  const PayrollView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkBoundaryWrapper(
      onRetry: () => controller.loadPayrollData(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Stack(
          children: [
            // 1. Signature Curved Ambient Background Container
            EmployeeAmbientHeader(height: 230.h),

            // 2. Main Foreground Content
            SafeArea(
              child: Column(
                children: [
                  // Top Bar: Screen Title & Subtitle
                  Padding(
                    padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 0),
                    child: const CustomScreenHeader(
                      title: 'Payroll & Payslips',
                      subtitle:
                          'Monthly salary breakdown, tax slips & PDF download',
                    ),
                  ),

                  AppSpaces.vSpace10,

                  // Segmented Switcher (Payslips vs Salary Structure)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Obx(() => _buildSegmentedSelector()),
                  ),

                  AppSpaces.vSpace12,

                  // Scrollable Body Content
                  Expanded(
                    child: Obx(() {
                      // Gate 1: If company has not enabled payroll module
                      if (!controller.isPayrollModuleActive.value) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: CustomStateView.empty(
                              title: 'Payroll Module Disabled',
                              message: 'Payroll & Payslips is not enabled in your company subscription.',
                            ),
                          ),
                        );
                      }

                      // Gate 2: If server returned 403 Forbidden for this employee
                      if (controller.isAccessRestricted.value) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: CustomStateView.empty(
                              title: 'Access Restricted',
                              message:
                                  controller
                                      .accessRestrictedMessage
                                      .value
                                      .isNotEmpty
                                  ? controller.accessRestrictedMessage.value
                                  : 'You do not have permission to access Payroll & Payslips.',
                              buttonText: 'Back to Home',
                              onAction: () => Get.back(),
                            ),
                          ),
                        );
                      }

                      // Loading State
                      if (controller.isLoading.value &&
                          controller.payslips.isEmpty &&
                          controller.salaryStructure.value == null) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2.5.w,
                          ),
                        );
                      }

                      // Tab 0: Finalized Payslips List
                      if (controller.selectedTabIndex.value == 0) {
                        return _buildPayslipsTab(context);
                      }

                      // Tab 1: Active Salary Structure
                      return _buildSalaryStructureTab();
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

  /// Segmented pill tabs to switch between historical payslips and salary formula
  Widget _buildSegmentedSelector() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderColor, width: 1.w),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSegmentButton(
              label: 'My Payslips',
              count: controller.payslips.length,
              isSelected: controller.selectedTabIndex.value == 0,
              onTap: () => controller.switchTab(0),
            ),
          ),
          Expanded(
            child: _buildSegmentButton(
              label: 'Salary Structure',
              isSelected: controller.selectedTabIndex.value == 1,
              onTap: () => controller.switchTab(1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton({
    required String label,
    int? count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(9.r),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: AppTextStyles.text14.copyWith(
                color: isSelected ? Colors.white : AppColors.textColor,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            if (count != null && count > 0) ...[
              AppSpaces.hSpace6,
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.secondary
                      : AppColors.borderColor,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  '$count',
                  style: AppTextStyles.text10.copyWith(
                    color: isSelected ? Colors.white : AppColors.subTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// List of finalized payslips with pull-to-refresh
  Widget _buildPayslipsTab(BuildContext context) {
    if (controller.payslips.isEmpty) {
      return RefreshIndicator(
        onRefresh: controller.loadPayrollData,
        color: AppColors.primary,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 60.h),
          child: Center(
            child: CustomStateView.empty(
              title: 'No Finalised Payslips',
              message: 'Your monthly finalised payslips will appear here once processed by your employer.',
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.loadPayrollData,
      color: AppColors.primary,
      child: ListView.builder(
        controller: controller.payslipsScrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        itemCount: controller.payslips.length,
        itemBuilder: (ctx, index) {
          final payslip = controller.payslips[index];
          return Obx(() {
            final isDownloadingThis =
                controller.isDownloadingPdf.value &&
                controller.selectedPayslip.value?.id == payslip.id;

            return PayslipCard(
              payslip: payslip,
              isDownloading: isDownloadingThis,
              onTap: () => _openPayslipDetails(context, payslip),
              onDownloadPdf: () => controller.downloadAndOpenPdf(
                payslip.id,
                periodLabel: payslip.period,
              ),
            );
          });
        },
      ),
    );
  }

  /// Active salary structure card with formula lines
  Widget _buildSalaryStructureTab() {
    return RefreshIndicator(
      onRefresh: controller.loadPayrollData,
      color: AppColors.primary,
      child: SingleChildScrollView(
        controller: controller.salaryScrollController,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: controller.salaryStructure.value != null
            ? SalaryStructureCard(salary: controller.salaryStructure.value!)
            : Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 40.h),
                child: CustomStateView.empty(
                  title: 'No Active Salary Structure',
                  message: 'Active compensation terms are not configured for your employee profile.',
                ),
              ),
      ),
    );
  }

  /// Opens comprehensive itemized bottom sheet for a payslip
  Future<void> _openPayslipDetails(
    BuildContext context,
    PayslipSummaryModel summary,
  ) async {
    final details = await controller.fetchDetails(summary.id);
    if (details != null && context.mounted) {
      PayslipDetailsBottomSheet.show(
        context,
        details: details,
        isDownloadingPdf: controller.isDownloadingPdf.value,
        onDownloadPdf: () => controller.downloadAndOpenPdf(
          details.id,
          periodLabel: details.period?.label,
        ),
      );
    }
  }
}
