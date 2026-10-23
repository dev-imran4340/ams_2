import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:ams_2/app/api/app_preferences.dart';
import 'package:ams_2/app/core/widgets/custom_snackbar.dart';
import '../model/department_employee_model.dart';
import '../repo/department_employees_repo.dart';
import '../view/components/employee_detail_sheet.dart';

class DepartmentEmployeesController extends GetxController {
  final DepartmentEmployeesRepo repo;

  DepartmentEmployeesController({required this.repo});

  final RxBool isLoading = false.obs;
  final RxList<DepartmentEmployeeModel> allStaff = <DepartmentEmployeeModel>[].obs;
  final RxList<DepartmentEmployeeModel> filteredStaff = <DepartmentEmployeeModel>[].obs;
  final TextEditingController searchController = TextEditingController();

  // Strict Permission Flags (Computed directly from /me saved session)
  bool get canViewDepartment => AppPreferences.hasPermission('employees.view', 'department') || AppPreferences.hasPermission('employees.view');
  bool get canViewSensitive => AppPreferences.hasPermission('employees.sensitive.view');
  bool get canPrintCards => AppPreferences.hasPermission('employees.cards.print');
  bool get canExport => AppPreferences.hasPermission('employees.export');

  @override
  void onInit() {
    super.onInit();
    loadDepartmentStaff();
  }

  Future<void> loadDepartmentStaff() async {
    try {
      isLoading.value = true;
      final staff = await repo.fetchDepartmentEmployees();
      allStaff.assignAll(staff);
      filteredStaff.assignAll(staff);
    } finally {
      isLoading.value = false;
    }
  }

  void filterStaff(String query) {
    if (query.trim().isEmpty) {
      filteredStaff.assignAll(allStaff);
    } else {
      final q = query.trim().toLowerCase();
      filteredStaff.assignAll(
        allStaff.where((e) {
          return e.name.toLowerCase().contains(q) ||
              e.employeeCode.toLowerCase().contains(q) ||
              e.designation.toLowerCase().contains(q);
        }).toList(),
      );
    }
  }

  /// Triggers CSV/Excel export strictly if 'employees.export' permission is granted
  void triggerExport(String format) {
    if (!canExport) {
      CustomSnackbar.showError(
        message: 'Permission denied: employees.export required.',
      );
      return;
    }

    HapticFeedback.mediumImpact();
    CustomSnackbar.showSuccess(
      message: 'Exporting ${filteredStaff.length} department records to $format...',
    );
  }

  /// Opens the Employee Profile Bottom Sheet with sensitive attributes gated by permission
  void showEmployeeDetails(BuildContext context, DepartmentEmployeeModel employee) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EmployeeDetailSheet(
        employee: employee,
        canViewSensitive: canViewSensitive,
        canPrintCard: canPrintCards,
      ),
    );
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
