import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:ams_2/app/core/utils/app_colors.dart';
import 'package:ams_2/app/core/utils/app_spaces.dart';
import 'package:ams_2/app/core/utils/app_text_styles.dart';
import 'package:ams_2/app/core/widgets/network_boundary_wrapper.dart';
import '../controller/department_employees_controller.dart';
import 'components/department_staff_card.dart';

class DepartmentEmployeesView extends GetView<DepartmentEmployeesController> {
  const DepartmentEmployeesView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkBoundaryWrapper(
      onRetry: controller.loadDepartmentStaff,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Stack(
          children: [
            // 1. Signature Curved Ambient Gradient Navy Header
            _buildCurvedHeader(context),

            // 2. Overlapping Scrollable Body Content
            SafeArea(
              child: Column(
                children: [
                  AppSpaces.vSpace16,
                  // Top Action Bar with Title, Scope Badge, and Optional Export Action
                  Padding(
                    padding: AppSpaces.horizontalPadding,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Department Directory',
                              style: AppTextStyles.text20.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                              ),
                            ),
                            AppSpaces.vSpace2,
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(6.r),
                                    border: Border.all(
                                      color: AppColors.secondary.withValues(alpha: 0.5),
                                      width: 1.w,
                                    ),
                                  ),
                                  child: Text(
                                    'SCOPE: DEPARTMENT',
                                    style: AppTextStyles.text10.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.liteSecondary,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Export Button (Strictly gated by 'employees.export')
                        if (controller.canExport)
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _showExportDialog(context),
                              borderRadius: BorderRadius.circular(10.r),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                                decoration: BoxDecoration(
                                  color: AppColors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(
                                    color: AppColors.white.withValues(alpha: 0.2),
                                    width: 1.w,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.file_download_outlined, size: 16.sp, color: AppColors.liteSecondary),
                                    AppSpaces.hSpace4,
                                    Text(
                                      'Export',
                                      style: AppTextStyles.text12.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  AppSpaces.vSpace16,

                  // Search Bar
                  Padding(
                    padding: AppSpaces.horizontalPadding,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: AppColors.borderColor, width: 1.w),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.05),
                            blurRadius: 10.r,
                            offset: Offset(0, 3.h),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: controller.searchController,
                        onChanged: controller.filterStaff,
                        style: AppTextStyles.text14.copyWith(color: AppColors.textColor),
                        decoration: InputDecoration(
                          hintText: 'Search department staff by name or code...',
                          hintStyle: AppTextStyles.text12.copyWith(color: AppColors.subTextColor),
                          prefixIcon: Icon(Icons.search_rounded, size: 20.sp, color: AppColors.subTextColor),
                          suffixIcon: Obx(() {
                            if (controller.filteredStaff.length != controller.allStaff.length) {
                              return IconButton(
                                icon: Icon(Icons.clear_rounded, size: 18.sp, color: AppColors.subTextColor),
                                onPressed: () {
                                  controller.searchController.clear();
                                  controller.filterStaff('');
                                },
                              );
                            }
                            return const SizedBox.shrink();
                          }),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                        ),
                      ),
                    ),
                  ),

                  AppSpaces.vSpace12,

                  // 3. Department Staff List
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppColors.secondary,
                            strokeWidth: 2.5.w,
                          ),
                        );
                      }

                      final staffList = controller.filteredStaff;

                      if (staffList.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.people_outline_rounded, size: 48.sp, color: AppColors.subTextColor),
                              AppSpaces.vSpace8,
                              Text(
                                'No department staff found',
                                style: AppTextStyles.text14.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        color: AppColors.secondary,
                        onRefresh: controller.loadDepartmentStaff,
                        child: ListView.separated(
                          padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 80.h),
                          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                          itemCount: staffList.length,
                          separatorBuilder: (_, index) => AppSpaces.vSpace10,
                          itemBuilder: (context, index) {
                            final employee = staffList[index];
                            return DepartmentStaffCard(
                              employee: employee,
                              onTap: () => controller.showEmployeeDetails(context, employee),
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

  Widget _buildCurvedHeader(BuildContext context) {
    return Container(
      height: 180.h,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28.r),
          bottomRight: Radius.circular(28.r),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary,
            AppColors.accentNavy,
          ],
        ),
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Export Department Staff',
              style: AppTextStyles.text16.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            AppSpaces.vSpace4,
            Text(
              'Select format to export current department records',
              style: AppTextStyles.text12.copyWith(color: AppColors.subTextColor),
            ),
            AppSpaces.vSpace16,
            ListTile(
              leading: Icon(Icons.table_chart_rounded, color: AppColors.secondary),
              title: Text('CSV Format (.csv)', style: AppTextStyles.text14.copyWith(fontWeight: FontWeight.bold)),
              subtitle: Text('Comma-separated standard format', style: AppTextStyles.text10.copyWith(color: AppColors.subTextColor)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              tileColor: AppColors.inputFill.withValues(alpha: 0.5),
              onTap: () {
                Get.back();
                controller.triggerExport('CSV');
              },
            ),
            AppSpaces.vSpace8,
            ListTile(
              leading: Icon(Icons.grid_on_rounded, color: AppColors.success),
              title: Text('Excel Spreadsheet (.xlsx)', style: AppTextStyles.text14.copyWith(fontWeight: FontWeight.bold)),
              subtitle: Text('Formatted Microsoft Excel workbook', style: AppTextStyles.text10.copyWith(color: AppColors.subTextColor)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              tileColor: AppColors.inputFill.withValues(alpha: 0.5),
              onTap: () {
                Get.back();
                controller.triggerExport('Excel (.xlsx)');
              },
            ),
            AppSpaces.vSpace12,
          ],
        ),
      ),
    );
  }
}
