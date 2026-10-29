import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:ams_2/app/api/app_preferences.dart';
import 'package:ams_2/app/core/widgets/custom_snackbar.dart';
import '../../../routes/app_routes.dart';
import '../../leaves/model/leave_model.dart';
import '../model/department_employee_model.dart';
import '../repo/department_employees_repo.dart';
import '../view/components/employee_detail_sheet.dart';
import '../view/components/employee_leave_audit_sheet.dart';

class DepartmentEmployeesController extends GetxController {
  final DepartmentEmployeesRepo repo;

  DepartmentEmployeesController({required this.repo});

  final RxBool isLoading = false.obs;
  final RxList<DepartmentEmployeeModel> allStaff = <DepartmentEmployeeModel>[].obs;
  final RxList<DepartmentEmployeeModel> filteredStaff = <DepartmentEmployeeModel>[].obs;
  final RxBool isAccessRestricted = false.obs;
  final TextEditingController searchController = TextEditingController();

  // Observables for Employee Leave Audit (GET /employees/{id}/leave)
  final RxBool isLoadingLeaveAudit = false.obs;
  final Rxn<EmployeeLeaveAuditModel> leaveAuditData = Rxn<EmployeeLeaveAuditModel>();
  final RxString leaveAuditError = ''.obs;

  // Strict Permission Flags (Computed directly from /me saved session with strict scopes)
  bool get canViewDepartment => AppPreferences.hasPermission('employees.view');
  bool get canPrintCards => AppPreferences.hasPermission('employees.cards.print', 'department');
  bool get canExport => AppPreferences.hasPermission('employees.export', 'department');

  /// Strict evaluation of sensitive information visibility per employee
  bool canViewSensitiveFor(DepartmentEmployeeModel emp) {
    final loggedInUserId = AppPreferences.userId;
    final loggedInEmpCode = AppPreferences.employeeNumber;
    // Viewing self: allowed if holding 'own' scope
    if ((loggedInUserId != null && emp.id == loggedInUserId) ||
        (loggedInEmpCode != null && emp.employeeCode == loggedInEmpCode)) {
      return AppPreferences.hasPermission('employees.sensitive.view', 'own');
    }
    // Viewing another employee: strictly requires 'department' (or company) scope
    return AppPreferences.hasPermission('employees.sensitive.view', 'department');
  }

  /// Manager/HR Scope: View Work Schedule Rota (Module: attendance && Permission: attendance.view)
  bool canViewScheduleFor(DepartmentEmployeeModel emp) {
    if (!AppPreferences.hasModule('attendance')) return false;
    final isSelf = emp.id == AppPreferences.userId || emp.employeeCode == AppPreferences.employeeNumber;
    if (isSelf) return AppPreferences.hasPermission('attendance.view', 'own');
    return AppPreferences.hasPermission('attendance.view', 'department');
  }

  /// Manager/HR Scope: Audit Employee Attendance Logs (GET /employees/{id}/attendance)
  bool canAuditAttendanceFor(DepartmentEmployeeModel emp) {
    if (!AppPreferences.hasModule('attendance')) return false;
    final isSelf = emp.id == AppPreferences.userId || emp.employeeCode == AppPreferences.employeeNumber;
    if (isSelf) return AppPreferences.hasPermission('attendance.view', 'own');
    return AppPreferences.hasPermission('attendance.view', 'department');
  }

  /// Manager/HR Scope: Audit Employee Leave Balances & History (GET /employees/{id}/leave)
  bool canAuditLeaveFor(DepartmentEmployeeModel emp) {
    if (!AppPreferences.hasModule('leave')) return false;
    final isSelf = emp.id == AppPreferences.userId || emp.employeeCode == AppPreferences.employeeNumber;
    if (isSelf) return AppPreferences.hasPermission('leave.view', 'own');
    return AppPreferences.hasPermission('leave.view', 'department');
  }

  @override
  void onInit() {
    super.onInit();
    loadDepartmentStaff();
  }

  Future<void> loadDepartmentStaff() async {
    if (!canViewDepartment) {
      isAccessRestricted.value = true;
      return;
    }
    isAccessRestricted.value = false;
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

  /// Navigates to Detailed Employee Profile Screen with all server-driven tabs via GET /employees/{id}
  void openEmployeeProfile(DepartmentEmployeeModel employee) {
    HapticFeedback.lightImpact();
    Get.toNamed(
      Routes.PROFILE_DETAILS,
      arguments: {
        'employeeId': employee.id,
        'employeeName': employee.name,
        'employeeCode': employee.employeeCode,
        'department': employee.department,
        'designation': employee.designation,
        'isViewingEmployee': true,
      },
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
        controller: this,
        employee: employee,
        canViewSensitive: canViewSensitiveFor(employee),
        canPrintCard: canPrintCards,
      ),
    );
  }

  /// Manager Action 1: Navigates to Work Schedule Rota for this employee (GET /employees/{id}/schedule)
  void openEmployeeSchedule(DepartmentEmployeeModel employee) {
    HapticFeedback.lightImpact();
    Get.toNamed(
      Routes.SCHEDULE,
      arguments: {
        'employeeId': employee.id,
        'employeeName': employee.name,
      },
    );
  }

  /// Manager Action 2: Navigates to Attendance Logs Audit for this employee (GET /employees/{id}/attendance)
  void openEmployeeAttendance(DepartmentEmployeeModel employee) {
    HapticFeedback.lightImpact();
    Get.toNamed(
      Routes.ATTENDANCE_HISTORY,
      arguments: {
        'employeeId': employee.id,
        'employeeName': employee.name,
      },
    );
  }

  /// Manager Action 3: Fetches and displays Leave Balances & Applications Audit (GET /employees/{id}/leave)
  Future<void> fetchEmployeeLeaveAudit(String employeeId) async {
    try {
      isLoadingLeaveAudit.value = true;
      leaveAuditError.value = '';
      leaveAuditData.value = null;
      final result = await repo.fetchEmployeeLeave(employeeId);
      leaveAuditData.value = result;
    } catch (e) {
      leaveAuditError.value = 'Failed to load employee leave records.';
    } finally {
      isLoadingLeaveAudit.value = false;
    }
  }

  /// Opens the Leave Audit Modal Sheet for this employee
  void openEmployeeLeaveAudit(BuildContext context, DepartmentEmployeeModel employee) {
    HapticFeedback.lightImpact();
    fetchEmployeeLeaveAudit(employee.id);
    EmployeeLeaveAuditSheet.show(context, this, employee);
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
