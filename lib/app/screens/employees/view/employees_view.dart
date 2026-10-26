import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:ams_2/app/core/utils/app_colors.dart';
import 'package:ams_2/app/core/utils/app_spaces.dart';
import 'package:ams_2/app/core/utils/app_text_styles.dart';
import 'package:ams_2/app/core/widgets/custom_screen_header.dart';
import 'package:ams_2/app/core/widgets/custom_state_view.dart';
import 'package:ams_2/app/core/widgets/custom_text_field.dart';
import 'package:ams_2/app/core/widgets/employee_ambient_header.dart';
import 'package:ams_2/app/core/widgets/network_boundary_wrapper.dart';

import '../controller/department_employees_controller.dart';
import 'components/department_staff_card.dart';

typedef EmployeesView = DepartmentEmployeesView;

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
            // 1. Signature Curved Ambient Gradient Header
            EmployeeAmbientHeader(height: 230.h),

            // 2. Overlapping Scrollable Body Content
            SafeArea(
              child: Column(
                children: [
                  AppSpaces.vSpace16,
                  // Top Action Bar with Title, Scope Badge, and Optional Export Action
                  Padding(
                    padding: AppSpaces.horizontalPadding,
                    child: CustomScreenHeader(
                      title: 'Department Directory',
                      subtitle: 'SCOPE: DEPARTMENT',
                      actions: [
                        if (controller.canExport)
                          CustomScreenHeader.actionButton(
                            icon: Icons.file_download_outlined,
                            onTap: () => _showExportDialog(context),
                            tooltip: 'Export Staff',
                          ),
                      ],
                    ),
                  ),

                  AppSpaces.vSpace16,

                  // 2. Search Bar (reactive and stable)
                  Obx(() {
                    if (controller.allStaff.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    final hasFilter = controller.filteredStaff.length !=
                        controller.allStaff.length;

                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: Padding(
                        padding: AppSpaces.horizontalPadding,
                        child: CustomTextField(
                          controller: controller.searchController,
                          hintText:
                              'Search department staff by name or code...',
                          onChanged: controller.filterStaff,
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            size: 20.sp,
                            color: AppColors.subTextColor,
                          ),
                          suffixIcon: hasFilter
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear_rounded,
                                    size: 18.sp,
                                    color: AppColors.subTextColor,
                                  ),
                                  onPressed: () {
                                    controller.searchController.clear();
                                    controller.filterStaff('');
                                  },
                                )
                              : null,
                        ),
                      ),
                    );
                  }),

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
                        return CustomStateView.empty(
                          title: 'No department staff found',
                          message: 'Try searching with another name, code or designation.',
                          buttonText: 'Reset Search',
                          onAction: () {
                            controller.searchController.clear();
                            controller.filterStaff('');
                          },
                        );
                      }

                      return RefreshIndicator(
                        color: AppColors.secondary,
                        onRefresh: controller.loadDepartmentStaff,
                        child: ListView.separated(
                          padding: EdgeInsets.fromLTRB(12.w, 4.h, 12.w, 80.h),
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          itemCount: staffList.length,
                          separatorBuilder: (_, index) => AppSpaces.vSpace10,
                          itemBuilder: (context, index) {
                            final employee = staffList[index];
                            return DepartmentStaffCard(
                              employee: employee,
                              onTap: () =>
                                  controller.openEmployeeProfile(employee),
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

  void _showExportDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 18.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: AppColors.borderColor,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
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
                style: AppTextStyles.text12.copyWith(
                  color: AppColors.subTextColor,
                ),
              ),
              AppSpaces.vSpace16,
              Material(
                color: AppColors.inputFill.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10.r),
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  leading: Icon(
                    Icons.table_chart_rounded,
                    color: AppColors.secondary,
                  ),
                  title: Text(
                    'CSV Format (.csv)',
                    style: AppTextStyles.text14.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Comma-separated standard format',
                    style: AppTextStyles.text10.copyWith(
                      color: AppColors.subTextColor,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  onTap: () {
                    Get.back();
                    controller.triggerExport('CSV');
                  },
                ),
              ),
              AppSpaces.vSpace8,
              Material(
                color: AppColors.inputFill.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10.r),
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  leading: Icon(
                    Icons.grid_on_rounded,
                    color: AppColors.success,
                  ),
                  title: Text(
                    'Excel Spreadsheet (.xlsx)',
                    style: AppTextStyles.text14.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Formatted Microsoft Excel workbook',
                    style: AppTextStyles.text10.copyWith(
                      color: AppColors.subTextColor,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  onTap: () {
                    Get.back();
                    controller.triggerExport('Excel (.xlsx)');
                  },
                ),
              ),
              AppSpaces.vSpace12,
            ],
          ),
        ),
      ),
    );
  }
}
