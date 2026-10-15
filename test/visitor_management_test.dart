import 'package:ams_2/app/screens/organization/visitor_management/controller/visitor_controller.dart';
import 'package:ams_2/app/screens/organization/visitor_management/model/visitor_model.dart';
import 'package:ams_2/app/screens/organization/visitor_management/repo/visitor_repo.dart';
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

  group('VisitorModel Tests', () {
    test('serializes and deserializes correctly', () {
      final now = DateTime.now();
      final model = VisitorModel(
        id: 'VIS-1001',
        fullName: 'Muhammad Usman',
        cnic: '42101-1234567-1',
        phone: '+92 300 1234567',
        purpose: 'Meeting',
        hostEmployee: 'Hamza Sheikh • Engineering',
        photoPath: 'mock_path.jpg',
        checkInTime: now,
        isActive: true,
      );

      final json = model.toJson();
      final fromJson = VisitorModel.fromJson(json);

      expect(fromJson.id, 'VIS-1001');
      expect(fromJson.fullName, 'Muhammad Usman');
      expect(fromJson.visitorName, 'Muhammad Usman');
      expect(fromJson.cnic, '42101-1234567-1');
      expect(fromJson.phone, '+92 300 1234567');
      expect(fromJson.purpose, 'Meeting');
      expect(fromJson.isActive, true);
    });

    test('elapsed time string returns friendly label', () {
      final now = DateTime.now();
      final modelJustNow = VisitorModel(
        id: 'VIS-1002',
        fullName: 'Ali Khan',
        cnic: '42101-0000000-1',
        phone: '1234567890',
        purpose: 'Guest',
        hostEmployee: 'Reception',
        checkInTime: now,
      );
      expect(modelJustNow.elapsedTimeString, 'Just checked in');

      final modelPastHour = VisitorModel(
        id: 'VIS-1003',
        fullName: 'Sara Ahmed',
        cnic: '42101-0000000-2',
        phone: '1234567890',
        purpose: 'Interview',
        hostEmployee: 'HR',
        checkInTime: now.subtract(const Duration(hours: 1, minutes: 15)),
      );
      expect(modelPastHour.elapsedTimeString.contains('1 hr 15 mins ago'), isTrue);
    });
  });

  group('VisitorRepo Tests', () {
    late VisitorRepo repo;

    setUp(() {
      repo = VisitorRepo();
    });

    test('fetchActiveVisitors returns pre-populated visitors', () async {
      final visitors = await repo.fetchActiveVisitors();
      expect(visitors.isNotEmpty, isTrue);
      expect(visitors.any((v) => v.id == 'VIS-9021'), isTrue);
    });

    test('fetchHostEmployees returns staff listing', () async {
      final employees = await repo.fetchHostEmployees();
      expect(employees.isNotEmpty, isTrue);
      expect(employees.any((e) => e.name == 'Hamza Sheikh'), isTrue);
    });

    test('submitVisitorEntry and markVisitorExit flow works correctly', () async {
      final newVisitor = await repo.submitVisitorEntry({
        'full_name': 'Zubair Shah',
        'cnic': '37405-9988776-5',
        'phone': '+92 333 1122334',
        'purpose': 'Delivery',
        'host_employee': 'Ali Raza • IT Operations',
      });

      expect(newVisitor, isNotNull);
      expect(newVisitor!.fullName, 'Zubair Shah');

      // Now verify visitor can be exited
      final exitSuccess = await repo.markVisitorExit(newVisitor.id);
      expect(exitSuccess, isTrue);
    });
  });

  group('VisitorController Tests', () {
    late VisitorRepo repo;
    late VisitorController controller;

    setUp(() {
      repo = VisitorRepo();
      controller = VisitorController(repo: repo);
      controller.onInit();
    });

    tearDown(() {
      controller.onClose();
    });

    test('loads initial data and host options', () async {
      await controller.loadData();
      expect(controller.activeVisitors.isNotEmpty, isTrue);
      expect(controller.hostEmployees.isNotEmpty, isTrue);
      expect(controller.selectedHost.value, isNotNull);
    });

    test('simulates camera capture and photo readiness', () async {
      expect(controller.hasCapturedPhoto, isFalse);
      controller.capturePhoto();
      expect(controller.hasCapturedPhoto, isTrue);
      expect(controller.capturedSelfie.value, isNotNull);

      await controller.retakePhoto();
      expect(controller.hasCapturedPhoto, isFalse);
      expect(controller.isCameraActive.value, isTrue);
    });

    test('simulates face verification and visitor checkout', () async {
      await controller.loadData();
      final targetVisitor = controller.activeVisitors.first;

      // Start verification
      final verificationFuture = controller.startVisitorFaceVerification(targetVisitor);
      expect(controller.preparingVisitorId.value, targetVisitor.id);

      await verificationFuture;
      expect(controller.preparingVisitorId.value, isNull);
      expect(controller.selectedVisitor.value?.id, targetVisitor.id);

      // Submit Exit
      await controller.submitExit();
      expect(controller.selectedVisitor.value, isNull);
      expect(controller.activeVisitors.any((v) => v.id == targetVisitor.id), isFalse);
    });

    test('search filter filters visitors accurately', () async {
      await controller.loadData();
      controller.searchQuery.value = 'bilal';

      final results = controller.filteredVisitors;
      expect(results.every((v) => v.fullName.toLowerCase().contains('bilal') || v.hostEmployee.toLowerCase().contains('bilal')), isTrue);
    });
  });
}
