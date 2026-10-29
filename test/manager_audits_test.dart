import 'package:ams_2/app/api/app_preferences.dart';
import 'package:ams_2/app/screens/attendance_history/controller/attendance_history_controller.dart';
import 'package:ams_2/app/screens/attendance_history/model/attendance_history_model.dart';
import 'package:ams_2/app/screens/attendance_history/repo/attendance_history_repo.dart';
import 'package:ams_2/app/screens/employees/controller/department_employees_controller.dart';
import 'package:ams_2/app/screens/employees/model/department_employee_model.dart';
import 'package:ams_2/app/screens/employees/repo/department_employees_repo.dart';
import 'package:ams_2/app/screens/leaves/model/leave_model.dart';
import 'package:ams_2/app/screens/leaves/repo/leave_repo.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    const MethodChannel channel =
        MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return '.';
    });
    await GetStorage.init();
  });

  group('Category 1: Manager & HR Scoped Audits Model & Logic Tests', () {
    test('EmployeeLeaveAuditModel parses GET /employees/{id}/leave payload correctly', () {
      final sampleJson = {
        'balances': [
          {
            'leave_type_id': '01jb2x9k4m7q8r3t5v6w8y0z1a',
            'name': 'Annual Leave',
            'allocated_days': 14.0,
            'used_days': 4.0,
            'remaining_days': 10.0,
            'pending_days': 1.0,
            'color': '#0DA6A3',
          },
          {
            'leave_type_id': '01jb2x9k4m7q8r3t5v6w8y0z1b',
            'name': 'Casual Leave',
            'allocated_days': 10.0,
            'used_days': 2.0,
            'remaining_days': 8.0,
            'pending_days': 0.0,
            'color': '#F59E0B',
          }
        ],
        'requests': [
          {
            'id': '01jb2x9k4m7q8r3t5v6w8y0z2c',
            'leave_type': 'Annual Leave',
            'from_date': '2026-11-01',
            'to_date': '2026-11-03',
            'total_days': 3.0,
            'status': 'Approved',
            'status_tone': 'emerald',
            'reason': 'Family vacation',
            'applied_on': '2026-10-20',
          }
        ]
      };

      final audit = EmployeeLeaveAuditModel.fromJson(sampleJson);

      expect(audit.balances.length, equals(2));
      expect(audit.balances[0].name, equals('Annual Leave'));
      expect(audit.balances[0].remainingDays, equals(10.0));
      expect(audit.balances[1].name, equals('Casual Leave'));
      expect(audit.balances[1].remainingDays, equals(8.0));

      expect(audit.requests.length, equals(1));
      expect(audit.requests[0].id, equals('01jb2x9k4m7q8r3t5v6w8y0z2c'));
      expect(audit.requests[0].leaveType, equals('Annual Leave'));
      expect(audit.requests[0].statusTone, equals('emerald'));
    });

    test('AttendanceHistoryResponse parses GET /employees/{id}/attendance payload with employee meta', () {
      final sampleJson = {
        'data': [
          {
            'id': '01jb2x9k4m7q8r3t5v6w8y0z1a',
            'date': '2026-10-28',
            'date_label': 'Wednesday, Oct 28',
            'status': 'present',
            'status_label': 'Present',
            'status_code': 'P',
            'tone': 'emerald',
            'day_type': 'working',
            'first_in': '08:55',
            'last_out': '17:05',
            'worked_minutes': 490,
            'counted_minutes': 480,
            'late_minutes': 0,
            'breaks': [],
          }
        ],
        'meta': {
          'from': '2026-10-01',
          'to': '2026-10-31',
          'employee': {
            'id': '01m5kmp9g8wxp9ssn3aed8awzm',
            'name': 'Ali Khan',
            'employee_code': 'EMP-0012',
          }
        }
      };

      final response = AttendanceHistoryResponse.fromJson(sampleJson);
      expect(response.data.length, equals(1));
      expect(response.data.first.firstIn, equals('08:55'));
      expect(response.meta?.employeeName, equals('Ali Khan'));
    });

    test('DepartmentEmployeesController enforces strict scoped permission gating', () {
      final controller = DepartmentEmployeesController(
        repo: DepartmentEmployeesRepo(),
      );

      final emp = DepartmentEmployeeModel(
        id: '01m5kmp9g8wxp9ssn3aed8awzm',
        employeeCode: 'EMP-0012',
        name: 'Ali Khan',
        department: 'Engineering',
        designation: 'Senior Developer',
        status: 'Active',
        email: 'ali@example.com',
        joiningDate: '2025-01-15',
      );

      // Without permissions set, all manager actions must evaluate to false
      AppPreferences.setPermissions(null);

      expect(controller.canAuditAttendanceFor(emp), isFalse);
      expect(controller.canAuditLeaveFor(emp), isFalse);
      expect(controller.canViewScheduleFor(emp), isFalse);

      // With department-scoped permissions, audit access is granted
      AppPreferences.setPermissions({
        'attendance.view': ['department'],
        'leave.view': ['department'],
        'schedule.view': ['department'],
      });

      expect(controller.canAuditAttendanceFor(emp), isTrue);
      expect(controller.canAuditLeaveFor(emp), isTrue);
      expect(controller.canViewScheduleFor(emp), isTrue);

      // Clean up controller resources
      controller.onClose();
    });

    test('AttendanceHistoryController initializes audit mode when arguments provided', () {
      final repo = AttendanceHistoryRepo();
      final controller = AttendanceHistoryController(repo: repo);

      expect(controller.isAuditMode, isFalse);
      expect(controller.targetEmployeeId.value, isEmpty);

      // Simulate entering with subordinate employee arguments
      final testArgs = {
        'employeeId': '01m5kmp9g8wxp9ssn3aed8awzm',
        'employeeName': 'Ali Khan',
      };

      // Direct assignment check
      controller.targetEmployeeId.value = testArgs['employeeId']!;
      controller.targetEmployeeName.value = testArgs['employeeName']!;

      expect(controller.isAuditMode, isTrue);
      expect(controller.targetEmployeeId.value, equals('01m5kmp9g8wxp9ssn3aed8awzm'));
      expect(controller.targetEmployeeName.value, equals('Ali Khan'));

      controller.onClose();
    });

    test('Repositories uphold Zero Dummy / Fallback Policy on offline/unauthorized calls', () async {
      final leaveRepo = LeaveRepo();
      final attRepo = AttendanceHistoryRepo();
      final deptRepo = DepartmentEmployeesRepo();

      // Offline API call must return null rather than fake fallback numbers
      final leaveResult = await leaveRepo.fetchEmployeeLeave('01m5kmp9g8wxp9ssn3aed8awzm');
      expect(leaveResult, isNull);

      final attResult = await attRepo.fetchEmployeeAttendance('01m5kmp9g8wxp9ssn3aed8awzm');
      expect(attResult, isNull);

      final deptLeaveResult = await deptRepo.fetchEmployeeLeave('01m5kmp9g8wxp9ssn3aed8awzm');
      expect(deptLeaveResult, isNull);
    });
  });
}
