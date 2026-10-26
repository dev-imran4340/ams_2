import 'package:ams_2/app/screens/employees/model/department_employee_model.dart';
import 'package:ams_2/app/screens/employees/repo/department_employees_repo.dart';
import 'package:ams_2/app/screens/profile/controller/profile_controller.dart';
import 'package:ams_2/app/screens/profile/model/profile_model.dart';
import 'package:ams_2/app/screens/profile/repo/profile_repo.dart';
import 'package:ams_2/app/api/app_preferences.dart';
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

  group('Employees List & Details API Tests', () {
    test('DepartmentEmployeeModel correctly parses GET /employees payload', () {
      final json = {
        'id': '01m5kmp9g8wxp9ssn3aed8awzm',
        'employee_number': 'EMP-0002',
        'name': 'Maryam Malik',
        'designation': 'Sales Manager',
        'department': 'Sales',
        'work_location': 'Head office',
        'stage': 'active',
      };

      final employee = DepartmentEmployeeModel.fromJson(json);

      expect(employee.id, '01m5kmp9g8wxp9ssn3aed8awzm');
      expect(employee.employeeCode, 'EMP-0002');
      expect(employee.employeeNumber, 'EMP-0002');
      expect(employee.name, 'Maryam Malik');
      expect(employee.designation, 'Sales Manager');
      expect(employee.department, 'Sales');
      expect(employee.workLocation, 'Head office');
      expect(employee.status, 'active');
      expect(employee.statusLabel, 'Active');
      expect(employee.isActive, true);
    });

    test('DepartmentEmployeesRepo returns empty list without dummy mock fallback when offline', () async {
      final repo = DepartmentEmployeesRepo();
      final employees = await repo.fetchDepartmentEmployees();

      expect(employees, isEmpty);
    });

    final employeeDetailsJson = {
      'data': {
        'id': '01m5kmp9g8wxp9ssn3aed8awzm',
        'employee_number': 'EMP-0002',
        'name': 'Maryam Malik',
        'designation': 'Sales Manager',
        'department': 'Sales',
        'work_location': 'Head office',
        'stage': 'active',
        'first_name': 'Maryam',
        'last_name': 'Malik',
        'preferred_name': null,
        'has_photo': false,
        'stage_label': 'Active',
        'sections': [
          {'key': 'overview', 'label': 'Overview'},
          {'key': 'personal', 'label': 'Personal'},
          {'key': 'job', 'label': 'Job'},
          {'key': 'attendance', 'label': 'Attendance'},
          {'key': 'documents', 'label': 'Documents'},
          {'key': 'bank', 'label': 'Bank details'},
          {'key': 'account', 'label': 'Sign-in and card'},
          {'key': 'history', 'label': 'History'}
        ],
        'job': {
          'legal_entity': 'Kumash (Pvt) Ltd',
          'work_location': 'Head office',
          'department': 'Sales',
          'sub_department': null,
          'designation': 'Sales Manager',
          'grade': null,
          'employment_type': 'full_time',
          'contract_type': 'permanent',
          'contract_ends_on': null,
          'joined_on': '2023-07-15',
          'probation_ends_on': null,
          'confirmed_on': null,
          'last_working_day': null,
          'left_on': null,
          'length_of_service': '3 years 3 months'
        },
        'contact': {
          'work_email': 'maryam@example.com',
          'work_phone': null
        },
        'personal': {
          'gender': null,
          'date_of_birth': null,
          'blood_group': null,
          'marital_status': null,
          'nationality': 'PK',
          'personal_email': null,
          'personal_phone': null,
          'address': {
            'line1': null,
            'line2': null,
            'city': null,
            'postcode': null,
            'country': null
          }
        },
        'emergency_contacts': [],
        'documents': []
      }
    };

    test('EmployeeProfileModel parses full GET /employees/{id} response', () {
      final profile = EmployeeProfileModel.fromJson(employeeDetailsJson);

      expect(profile.name, 'Maryam Malik');
      expect(profile.employeeNumber, 'EMP-0002');
      expect(profile.designation, 'Sales Manager');
      expect(profile.department, 'Sales');
      expect(profile.workLocation, 'Head office');
      expect(profile.sections.length, 8);
      expect(profile.sections.first.key, 'overview');
      expect(profile.job?.legalEntity, 'Kumash (Pvt) Ltd');
      expect(profile.job?.joinedOn, '2023-07-15');
      expect(profile.contact?.workEmail, 'maryam@example.com');
      expect(profile.initials, 'MM');
    });

    test('ProfileController toggles between self profile and employee profile', () async {
      await AppPreferences.setProfileData(employeeDetailsJson);
      final repo = ProfileRepo();
      final controller = ProfileController(repo: repo);

      // 1. Initial state: loads self profile
      await controller.loadProfile();
      expect(controller.isViewingOtherEmployee.value, false);
      expect(controller.activeEmployeeId.value, isNull);
      expect(controller.profile.value, isNotNull);

      // 2. Open an employee profile (returns null cleanly when offline, with no dummy fallback)
      await controller.loadEmployeeProfile('01m5kmp9g8wxp9ssn3aed8awzm');
      expect(controller.isViewingOtherEmployee.value, true);
      expect(controller.activeEmployeeId.value, '01m5kmp9g8wxp9ssn3aed8awzm');

      // 3. Restore self profile
      controller.restoreSelfProfile();
      expect(controller.isViewingOtherEmployee.value, false);
      expect(controller.activeEmployeeId.value, isNull);
    });

    test('ProfileController advances and rewinds section tabs accurately', () async {
      final repo = ProfileRepo();
      final controller = ProfileController(repo: repo);
      await controller.loadProfile();

      expect(controller.activeSections.isNotEmpty, true);
      final firstKey = controller.activeSections.first.key;
      final secondKey = controller.activeSections[1].key;
      final thirdKey = controller.activeSections[2].key;

      controller.selectSection(firstKey);
      expect(controller.selectedSectionKey.value, firstKey);

      // Advance next
      controller.selectNextSection();
      expect(controller.selectedSectionKey.value, secondKey);

      controller.selectNextSection();
      expect(controller.selectedSectionKey.value, thirdKey);

      // Rewind previous
      controller.selectPreviousSection();
      expect(controller.selectedSectionKey.value, secondKey);

      controller.selectPreviousSection();
      expect(controller.selectedSectionKey.value, firstKey);
    });
  });
}
