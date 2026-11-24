import 'package:ams_2/app/api/app_preferences.dart';
import 'package:ams_2/app/screens/employees/model/department_employee_model.dart';
import 'package:ams_2/app/screens/kiosk/model/kiosk_model.dart';

/// Presentation model representing Company account metadata, badges, employees and kiosk station state
class CompanyDashboardData {
  final String companyId;
  final String companyName;
  final String companyCode;
  final String adminName;
  final String adminEmail;
  final bool canManageKiosks;
  final bool canViewEmployees;
  final bool isKioskProvisioned;
  final KioskConfigModel? kioskConfig;
  final int totalEmployees;
  final int presentEmployees;
  final int absentEmployees;
  final int onLeaveEmployees;
  final int leaveRequestsBadge;
  final int waitingApprovalsBadge;
  final int totalRequestsBadge;
  final List<DepartmentEmployeeModel> employees;

  const CompanyDashboardData({
    required this.companyId,
    required this.companyName,
    required this.companyCode,
    required this.adminName,
    required this.adminEmail,
    required this.canManageKiosks,
    required this.canViewEmployees,
    required this.isKioskProvisioned,
    this.kioskConfig,
    this.totalEmployees = 0,
    this.presentEmployees = 0,
    this.absentEmployees = 0,
    this.onLeaveEmployees = 0,
    this.leaveRequestsBadge = 0,
    this.waitingApprovalsBadge = 0,
    this.totalRequestsBadge = 0,
    this.employees = const [],
  });

  factory CompanyDashboardData.fromPreferences({
    KioskConfigModel? activeKiosk,
    List<DepartmentEmployeeModel> employeesList = const [],
  }) {
    final company = AppPreferences.company;
    final user = AppPreferences.user;
    final badges = AppPreferences.badges;

    final compId = company?['id']?.toString() ?? AppPreferences.companyId ?? '';
    final compName = company?['name']?.toString() ?? AppPreferences.companyName ?? 'Organization';
    final compCode = company?['code']?.toString() ?? AppPreferences.companyCode ?? '';

    final uName = user?['name']?.toString() ?? AppPreferences.userName ?? 'Administrator';
    final uEmail = user?['email']?.toString() ?? AppPreferences.userEmail ?? '';

    final canManageK = AppPreferences.hasPermission('kiosks.manage');
    final canViewEmp = AppPreferences.hasPermission('employees.view');
    final isProv = AppPreferences.isKioskProvisioned;

    // Badges from /me
    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    final leaveBadge = parseInt(badges?['leave'] ?? badges?['leaves']);
    final waitingBadge = parseInt(badges?['waiting'] ?? badges?['approvals']);
    final reqBadge = parseInt(badges?['requests'] ?? (leaveBadge + waitingBadge));

    // Calculate status counts from employees if available
    int activeCount = 0;
    int onLeaveCount = 0;
    int absentCount = 0;
    for (final emp in employeesList) {
      final st = emp.status.toLowerCase();
      if (st == 'active' || st == 'present' || st == 'joining') {
        activeCount++;
      } else if (st.contains('leave')) {
        onLeaveCount++;
      } else {
        absentCount++;
      }
    }

    return CompanyDashboardData(
      companyId: compId,
      companyName: compName,
      companyCode: compCode,
      adminName: uName,
      adminEmail: uEmail,
      canManageKiosks: canManageK,
      canViewEmployees: canViewEmp,
      isKioskProvisioned: isProv,
      kioskConfig: activeKiosk,
      totalEmployees: employeesList.isNotEmpty ? employeesList.length : 0,
      presentEmployees: activeCount,
      absentEmployees: absentCount,
      onLeaveEmployees: onLeaveCount,
      leaveRequestsBadge: leaveBadge,
      waitingApprovalsBadge: waitingBadge,
      totalRequestsBadge: reqBadge,
      employees: employeesList,
    );
  }
}
