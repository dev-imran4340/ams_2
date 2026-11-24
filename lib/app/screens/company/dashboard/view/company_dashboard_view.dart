import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:ams_2/app/core/utils/app_colors.dart';
import 'package:ams_2/app/core/utils/app_spaces.dart';
import 'package:ams_2/app/core/utils/app_text_styles.dart';
import 'package:ams_2/app/core/widgets/custom_button.dart';
import 'package:ams_2/app/core/widgets/custom_state_view.dart';
import 'package:ams_2/app/core/widgets/custom_text_field.dart';
import 'package:ams_2/app/core/widgets/employee_ambient_header.dart';
import 'package:ams_2/app/core/widgets/network_boundary_wrapper.dart';
import 'package:ams_2/app/screens/employees/model/department_employee_model.dart';

import '../controller/company_dashboard_controller.dart';
import '../model/company_dashboard_model.dart';

class CompanyDashboardView extends GetView<CompanyDashboardController> {
  const CompanyDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkBoundaryWrapper(
      onRetry: controller.loadDashboard,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Stack(
          children: [
            // Ambient curved header with inverted gradient (dark to light)
            Obx(() {
              if (controller.dashboardData.value != null) {
                return EmployeeAmbientHeader(
                  height: 240.h,
                  borderRadius: 20.r,
                  gradientColors: const [
                    AppColors.primary,
                    AppColors.primary,
                    AppColors.primary,
                    AppColors.primary,
                    AppColors.primary,
                    AppColors.secondary,
                    AppColors.liteSecondary,
                  ],
                );
              }
              return const SizedBox.shrink();
            }),

            SafeArea(
              bottom: false,
              child: RefreshIndicator(
                onRefresh: controller.loadDashboard,
                color: AppColors.secondary,
                child: Obx(() {
                  if (controller.isLoading.value &&
                      controller.dashboardData.value == null) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: AppColors.secondary,
                      ),
                    );
                  }

                  final data = controller.dashboardData.value;
                  if (data == null) {
                    return Center(
                      child: CustomStateView.empty(
                        title: 'Organization Data Unavailable',
                        message: 'Could not load company dashboard profile.',
                        buttonText: 'Retry',
                        onAction: controller.loadDashboard,
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    controller: controller.scrollController,
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
                        // Executive Top Header built custom like Employee Dashboard
                        _buildExecutiveTopHeader(data),

                        AppSpaces.vSpace14,

                        // 1. Company Info Card (Light theme, existing AppColors, with small counts)
                        _buildCompanyInfoCard(data),

                        AppSpaces.vSpace16,

                        // 2. Kiosk PIN Entry & Station Container (Using CustomTextField & No gradient on buttons)
                        _buildKioskPinCard(data),

                        AppSpaces.vSpace16,

                        // 3. Company Employees Section
                        _buildEmployeesSection(data),

                        SizedBox(height: 60.h),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Top Executive Header custom built matching Employee Dashboard (`dashboard_view.dart`)
  /// Features:
  /// - User avatar circle with online indicator dot
  /// - Dynamic time-based greeting ('Good Morning,', 'Good Afternoon,', etc.)
  /// - User / Admin Name with bold contrast
  /// - Circular glass sign out / logout action button
  Widget _buildExecutiveTopHeader(CompanyDashboardData data) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : (hour < 17 ? 'Good Afternoon' : 'Good Evening');

    final name = data.adminName.isNotEmpty ? data.adminName : 'Administrator';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // User Profile & Greeting
        Expanded(
          child: Row(
            children: [
              // User Avatar with Online Status Indicator
              Stack(
                children: [
                  Container(
                    width: 46.r,
                    height: 46.r,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 2.w),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          blurRadius: 10.r,
                          offset: Offset(0, 4.h),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'A',
                      style: AppTextStyles.text18.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 1.r,
                    right: 1.r,
                    child: Container(
                      width: 12.r,
                      height: 12.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.onTimeColor,
                        border: Border.all(color: AppColors.white, width: 2.w),
                      ),
                    ),
                  ),
                ],
              ),
              AppSpaces.hSpace12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: AppTextStyles.text18.copyWith(
                        color: AppColors.white.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    AppSpaces.vSpace2,
                    Text(
                      greeting,

                      style: AppTextStyles.text12.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        AppSpaces.hSpace8,

        // Circular Glass Sign Out Button
        IconButton(
          style: IconButton.styleFrom(
            backgroundColor: AppColors.white,
            shape: const CircleBorder(),
            shadowColor: AppColors.primary.withValues(alpha: 0.08),
            elevation: 10,
          ),
          icon: Icon(
            Icons.power_settings_new_rounded,
            color: AppColors.error,
            size: 20.sp,
          ),
          tooltip: 'Sign Out',
          onPressed: () {
            HapticFeedback.lightImpact();
            controller.logout();
          },
        ),
      ],
    );
  }

  /// 1. Company Info Container (Light card in existing colors with company name, subtitle, code, and small count cards)
  Widget _buildCompanyInfoCard(CompanyDashboardData data) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(15.r),
        border: Border(
          bottom: BorderSide(color: AppColors.secondary, width: 3.w),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Row: Company Name + Code Pill
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      data.companyName,
                      style: AppTextStyles.text16.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                      maxLines: 1,
                    ),
                    AppSpaces.vSpace2,
                    Text(
                      'Everything at ${data.companyName}, in one place.',
                      style: AppTextStyles.text12.copyWith(
                        color: AppColors.subTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              AppSpaces.hSpace8,
              if (data.companyCode.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      width: 1.w,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.qr_code_rounded,
                        size: 13.sp,
                        color: AppColors.primary,
                      ),
                      AppSpaces.hSpace4,
                      Text(
                        data.companyCode.toUpperCase(),
                        style: AppTextStyles.text12.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          AppSpaces.vSpace14,
          Divider(color: AppColors.borderColor, height: 1),
          AppSpaces.vSpace12,

          // Small Count Cards inside company info container
          Row(
            children: [
              // Total Employees
              Expanded(
                child: _buildSmallCountTile(
                  icon: Icons.groups_rounded,
                  iconColor: AppColors.primary,
                  label: 'Employees',
                  count: '${data.totalEmployees}',
                  subtext: '${data.presentEmployees} Active',
                  onTap: controller.navigateToEmployees,
                ),
              ),
              AppSpaces.hSpace8,
              // Leave Requests
              Expanded(
                child: _buildSmallCountTile(
                  icon: Icons.beach_access_rounded,
                  iconColor: Colors.orange.shade800,
                  label: 'Leaves',
                  count: '${data.leaveRequestsBadge}',
                  subtext: 'Pending',
                  onTap: controller.navigateToLeaves,
                ),
              ),
              AppSpaces.hSpace8,
              // Waiting Approvals
              Expanded(
                child: _buildSmallCountTile(
                  icon: Icons.inbox_rounded,
                  iconColor: AppColors.secondary,
                  label: 'Waiting',
                  count: '${data.waitingApprovalsBadge}',
                  subtext: 'Approval',
                  onTap: controller.navigateToRequests,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Small count tile inside the company info container
  Widget _buildSmallCountTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String count,
    required String subtext,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.borderColor, width: 1.w),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 16.sp, color: iconColor),
                Text(
                  count,
                  style: AppTextStyles.text16.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
            AppSpaces.vSpace4,
            Text(
              label,
              style: AppTextStyles.text10.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textColor,
              ),
            ),
            Text(
              subtext,
              style: AppTextStyles.text10.copyWith(
                fontSize: 9.sp,
                color: AppColors.subTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 2. Kiosk PIN Entry & Station Container (Using CustomTextField & No gradient on buttons)
  Widget _buildKioskPinCard(CompanyDashboardData data) {
    final isProv = data.isKioskProvisioned;
    final kiosk = data.kioskConfig;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(15.r),
        border: Border(
          bottom: BorderSide(color: AppColors.secondary, width: 3.w),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.dialpad_rounded,
                  color: AppColors.secondary,
                  size: 18.sp,
                ),
              ),
              AppSpaces.hSpace10,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Attendance Kiosk Terminal',
                      style: AppTextStyles.text14.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                    Text(
                      isProv
                          ? 'Active: ${kiosk?.name ?? "Provisioned"}'
                          : 'Enter Kiosk PIN to unlock / configure terminal',
                      style: AppTextStyles.text12.copyWith(
                        color: isProv
                            ? AppColors.success
                            : AppColors.subTextColor,
                        fontWeight: isProv
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isProv
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(
                    color: isProv
                        ? AppColors.success.withValues(alpha: 0.3)
                        : AppColors.warning.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  isProv ? 'ONLINE' : 'UNPROVISIONED',
                  style: AppTextStyles.text10.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isProv ? AppColors.success : AppColors.warning,
                  ),
                ),
              ),
            ],
          ),

          AppSpaces.vSpace14,

          // PIN Input Field using centralized CustomTextField
          CustomTextField(
            controller: controller.kioskPinController,
            focusNode: controller.kioskPinFocusNode,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 6,
            labelText: 'Kiosk Access PIN',
            hintText: 'Enter 4-6 digit PIN',
            prefixIcon: Icon(
              Icons.lock_outline_rounded,
              size: 18.sp,
              color: AppColors.secondary,
            ),
            suffixIcon: SizedBox(
              width: 100.w,
              child: Padding(
                padding: EdgeInsets.all(4.r),
                child: CustomButton(
                  borderRadius: 8,
                  fontSize: 14,
                  text: isProv ? 'Launch' : 'Set PIN',
                  isGradient: false,
                  backgroundColor: AppColors.primary,
                  height: 30.h,
                  icon: Icon(
                    isProv
                        ? Icons.play_arrow_rounded
                        : Icons.check_circle_outline_rounded,
                    size: 16.sp,
                    color: AppColors.white,
                  ),
                  onPressed: controller.submitKioskPin,
                ),
              ),
            ),
            onFieldSubmitted: (_) => controller.submitKioskPin(),
          ),

          AppSpaces.vSpace14,

          // Solid color action buttons (Gradient OFF)
          if (isProv) ...[
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Launch Kiosk Mode',
                    isGradient: false,
                    backgroundColor: AppColors.secondary,
                    icon: Icon(
                      Icons.tablet_mac_rounded,
                      size: 18.sp,
                      color: AppColors.white,
                    ),
                    onPressed: controller.enterKioskMode,
                  ),
                ),
                if (data.canManageKiosks) ...[
                  AppSpaces.hSpace8,
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(
                        color: AppColors.error.withValues(alpha: 0.3),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 12.h,
                        horizontal: 10.w,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    icon: Icon(Icons.delete_outline_rounded, size: 16.sp),
                    label: Text(
                      'Reset',
                      style: AppTextStyles.text12.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                    onPressed: controller.deProvisionKiosk,
                  ),
                ],
              ],
            ),
          ] else ...[
            if (data.canManageKiosks) ...[
              CustomButton(
                text: 'Provision This Tablet as Kiosk Station',
                isGradient: false,
                backgroundColor: AppColors.primary,
                icon: Icon(
                  Icons.add_to_home_screen_rounded,
                  size: 18.sp,
                  color: AppColors.white,
                ),
                onPressed: controller.navigateToKioskSetup,
              ),
            ],
          ],
        ],
      ),
    );
  }

  /// 3. Company Employees Section
  Widget _buildEmployeesSection(CompanyDashboardData data) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(15.r),
        border: Border(
          bottom: BorderSide(color: AppColors.secondary, width: 3.w),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(7.r),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.badge_rounded,
                      color: AppColors.primary,
                      size: 18.sp,
                    ),
                  ),
                  AppSpaces.hSpace8,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Company Employees',
                        style: AppTextStyles.text14.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                      Text(
                        '${data.employees.length} team members registered',
                        style: AppTextStyles.text10.copyWith(
                          color: AppColors.subTextColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                width: 100.w,
                child: Padding(
                  padding: EdgeInsets.all(4.r),
                  child: CustomButton(
                    fontSize: 14,
                    borderRadius: 8,
                    text: "See All",
                    isGradient: false,
                    backgroundColor: AppColors.primary,
                    height: 30.h,
                    icon: Icon(
                      Icons.arrow_forward_rounded,
                      size: 14.sp,
                      color: AppColors.white,
                    ),
                    onPressed: controller.navigateToEmployees,
                  ),
                ),
              ),
            ],
          ),

          AppSpaces.vSpace12,

          // List of employees directly on dashboard (modern compact cards)
          if (data.employees.isEmpty) ...[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Center(
                child: Text(
                  data.canViewEmployees
                      ? 'No employees registered yet.'
                      : 'Account lacks permission to view staff directory.',
                  style: AppTextStyles.text12.copyWith(
                    color: AppColors.subTextColor,
                  ),
                ),
              ),
            ),
          ] else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.employees.length > 6 ? 6 : data.employees.length,
              separatorBuilder: (ctx, idx) => AppSpaces.vSpace8,
              itemBuilder: (context, index) {
                final emp = data.employees[index];
                return _buildModernEmployeeCard(emp);
              },
            ),
            if (data.employees.length > 6) ...[
              AppSpaces.vSpace10,
              Center(
                child: TextButton.icon(
                  onPressed: controller.navigateToEmployees,
                  icon: Icon(
                    Icons.arrow_forward_rounded,
                    size: 14.sp,
                    color: AppColors.secondary,
                  ),
                  label: Text(
                    'View all ${data.employees.length} team members',
                    style: AppTextStyles.text12.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  /// Modern Compact Employee Card for Company Dashboard (Display only — no tap/details)
  Widget _buildModernEmployeeCard(DepartmentEmployeeModel employee) {
    final statusColor =
        employee.status.toLowerCase() == 'active' ||
            employee.status.toLowerCase() == 'present'
        ? AppColors.success
        : (employee.status.toLowerCase().contains('leave')
              ? AppColors.primary
              : AppColors.error);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.borderColor,
          width: 0.8.w,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.03),
            blurRadius: 6.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar with secondary border ring
          Container(
            width: 38.r,
            height: 38.r,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.35),
                width: 1.2.w,
              ),
            ),
            child: Center(
              child: Text(
                employee.name.isNotEmpty ? employee.name[0].toUpperCase() : 'E',
                style: AppTextStyles.text14.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          AppSpaces.hSpace10,
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        employee.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.text12.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                    ),
                    AppSpaces.hSpace6,
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 1.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        employee.statusLabel,
                        style: AppTextStyles.text10.copyWith(
                          fontSize: 8.5.sp,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpaces.vSpace2,
                Text(
                  '${employee.designation.isNotEmpty ? employee.designation : "Staff"}${employee.department.isNotEmpty ? " • ${employee.department}" : ""}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.text10.copyWith(
                    color: AppColors.subTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (employee.employeeCode.isNotEmpty) ...[
                  AppSpaces.vSpace2,
                  Text(
                    '#${employee.employeeCode}',
                    style: AppTextStyles.text10.copyWith(
                      fontSize: 9.sp,
                      color: AppColors.subTextColor.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
