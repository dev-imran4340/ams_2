import 'package:ams_2/app/screens/organization/add_employee/controller/add_employee_controller.dart';
import 'package:ams_2/app/screens/organization/add_employee/model/add_employee_model.dart';
import 'package:ams_2/app/screens/organization/add_employee/repo/add_employee_repo.dart';
import 'package:ams_2/app/screens/organization/company_dashboard/controller/company_dashboard_controller.dart';
import 'package:ams_2/app/screens/organization/company_dashboard/repo/company_dashboard_repo.dart';
import 'package:ams_2/app/screens/organization/employee_kiosk_dashboard/controller/kiosk_employee_controller.dart';
import 'package:ams_2/app/screens/organization/employee_kiosk_dashboard/repo/kiosk_employee_repo.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('PonnamKarthik/fluttertoast'),
      (MethodCall methodCall) async => true,
    );
  });

  group('Add Employee Tests', () {
    late AddEmployeeRepo repo;
    late AddEmployeeController controller;

    setUp(() {
      repo = AddEmployeeRepo();
      controller = AddEmployeeController(repo: repo);
      controller.onInit();
    });

    tearDown(() {
      controller.onClose();
    });

    test('AddEmployeeRepo fetches lookup datasets properly', () async {
      final lookups = await repo.fetchLookupData();
      expect(lookups.departments.isNotEmpty, isTrue);
      expect(lookups.shifts.isNotEmpty, isTrue);
      expect(lookups.cities.contains('Islamabad'), isTrue);
    });

    test('AddEmployeeRepo registers employee with mock id generated', () async {
      const request = AddEmployeeRequestModel(
        fullName: 'Hamza Farooq',
        email: 'hamza@softech.com',
        phoneCountryCode: '+92',
        phoneNumber: '3001234567',
        gender: 'Male',
        cnic: '37405-1234567-1',
        dob: '1995-04-12',
        houseNo: '12',
        street: 'Street 4',
        city: 'Islamabad',
        postcode: '44000',
        department: 'Software Engineering',
        designation: 'Senior Flutter Developer',
        shift: 'Morning General (09:00 AM - 06:00 PM)',
        joiningDate: '2026-10-15',
        emergencyContactName: 'Dr. Tariq',
        emergencyPhone: '+923009876543',
        relationship: 'Father',
        isFaceEnrolled: true,
      );

      final response = await repo.registerEmployee(request);
      expect(response, isNotNull);
      expect(response!.success, isTrue);
      expect(response.employeeId?.startsWith('EMP-'), isTrue);
    });

    test('AddEmployeeController simulates face capture and updates status', () {
      expect(controller.isFaceCaptured.value, isFalse);
      controller.simulateCaptureFace();
      expect(controller.isFaceCaptured.value, isTrue);
      expect(controller.faceLivenessScore.value, greaterThan(0.95));

      controller.resetCapturedFace();
      expect(controller.isFaceCaptured.value, isFalse);
    });
  });

  group('Company Dashboard Tests', () {
    late CompanyDashboardRepo repo;
    late CompanyDashboardController controller;

    setUp(() {
      repo = CompanyDashboardRepo();
      controller = CompanyDashboardController(repo: repo);
      controller.onInit();
    });

    tearDown(() {
      controller.onClose();
    });

    test('CompanyDashboardRepo fetches valid telemetry data', () async {
      final data = await repo.fetchCompanyDashboard();
      expect(data, isNotNull);
      expect(data!.totalEmployees, 160);
      expect(data.presentToday, 138);
      expect(data.recentActivities.isNotEmpty, isTrue);
      expect(data.recentLeaves.isNotEmpty, isTrue);
    });

    test('CompanyDashboardController filters activity stream', () async {
      await controller.loadDashboard();
      controller.selectedActivityFilter.value = 'Check-In';
      final checkIns = controller.filteredActivities;
      expect(checkIns.every((a) => a.isCheckIn), isTrue);

      controller.selectedActivityFilter.value = 'Breaks';
      final breaks = controller.filteredActivities;
      expect(breaks.every((a) => !a.isCheckIn), isTrue);
    });
  });

  group('Kiosk Employee Dashboard Tests', () {
    late KioskEmployeeRepo repo;
    late KioskEmployeeController controller;

    setUp(() {
      repo = KioskEmployeeRepo();
      controller = KioskEmployeeController(repo: repo);
      controller.onInit();
    });

    tearDown(() {
      controller.onClose();
    });

    test('KioskEmployeeRepo fetches identified profile', () async {
      final profile = await repo.fetchKioskProfile();
      expect(profile, isNotNull);
      expect(profile!.id, 'EMP-0482');
      expect(profile.isCheckedIn, isTrue);
    });

    test('KioskEmployeeController resets idle timer on user touch interaction', () {
      controller.remainingSeconds.value = 12;
      controller.resetIdleTimer();
      expect(controller.remainingSeconds.value, 60);
    });
  });
}
