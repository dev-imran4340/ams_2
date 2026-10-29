import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ams_2/app/screens/approvals/model/approval_model.dart';
import 'package:ams_2/app/screens/approvals/repo/approval_repo.dart';
import 'package:ams_2/app/screens/approvals/controller/approval_controller.dart';

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

  group('ApprovalItemModel Serialization & Helper Tests', () {
    test('Serializes and deserializes list row approval item accurately', () {
      final json = {
        'id': '01jb2x9k4m7q8r3t5v6w8y0z1a',
        'type': 'employee_details_change',
        'type_label': 'Change of my details',
        'title': 'Change of my details: personal phone',
        'employee': {
          'id': '01jb2x9k4m7q8r3t5v6w8y0z1a',
          'name': 'Ayesha Khan',
          'number': 'EMP-0001',
          'department': 'Sales'
        },
        'requested_by': 'Ayesha Khan',
        'status': 'pending',
        'status_label': 'Waiting',
        'status_tone': 'amber',
        'waiting_on': 'Department manager',
        'submitted_at': '2026-10-22T09:15:00+00:00',
        'submitted_ago': '2 hours ago',
        'decided_at': null,
      };

      final item = ApprovalItemModel.fromJson(json);

      expect(item.id, '01jb2x9k4m7q8r3t5v6w8y0z1a');
      expect(item.type, 'employee_details_change');
      expect(item.typeLabel, 'Change of my details');
      expect(item.title, 'Change of my details: personal phone');
      expect(item.employee?.name, 'Ayesha Khan');
      expect(item.employee?.number, 'EMP-0001');
      expect(item.employee?.department, 'Sales');
      expect(item.status, 'pending');
      expect(item.statusLabel, 'Waiting');
      expect(item.statusTone, 'amber');
      expect(item.isPending, isTrue);
      expect(item.isApproved, isFalse);
    });

    test('Serializes and deserializes full audit detail approval item accurately', () {
      final json = {
        'id': '01jb2x9k4m7q8r3t5v6w8y0z1a',
        'type': 'employee_details_change',
        'type_label': 'Change of my details',
        'title': 'Change of my details: personal phone',
        'employee': {
          'id': '01jb2x9k4m7q8r3t5v6w8y0z1a',
          'name': 'Ayesha Khan',
          'number': 'EMP-0001',
          'department': 'Sales'
        },
        'requested_by': 'Ayesha Khan',
        'status': 'pending',
        'status_label': 'Waiting',
        'status_tone': 'amber',
        'waiting_on': 'Department manager',
        'submitted_at': '2026-10-22T09:15:00+00:00',
        'submitted_ago': '2 hours ago',
        'decided_at': null,
        'changes': [
          {
            'label': 'Personal phone',
            'before': '+92 300 1234567',
            'after': '+92 321 7654321'
          }
        ],
        'steps': [
          {
            'position': 1,
            'approver': 'Ali Raza',
            'status': 'waiting',
            'status_label': 'Waiting',
            'status_tone': 'amber'
          },
          {
            'position': 2,
            'approver': 'HR Admin',
            'status': 'not_reached',
            'status_label': 'Upcoming',
            'status_tone': 'slate'
          }
        ],
        'can': {
          'approve': true,
          'reject': true,
          'as_override': false,
          'cancel': false
        }
      };

      final item = ApprovalItemModel.fromJson(json);

      expect(item.changes.length, 1);
      expect(item.changes.first.label, 'Personal phone');
      expect(item.changes.first.before, '+92 300 1234567');
      expect(item.changes.first.after, '+92 321 7654321');
      expect(item.steps.length, 2);
      expect(item.steps.first.position, 1);
      expect(item.steps.first.approver, 'Ali Raza');
      expect(item.can.approve, isTrue);
      expect(item.can.reject, isTrue);
      expect(item.can.asOverride, isFalse);
      expect(item.can.cancel, isFalse);
    });
  });

  group('ApprovalRepo Tests', () {
    late ApprovalRepo repo;

    setUp(() {
      repo = ApprovalRepo();
    });

    test('fetchApprovalsBox returns empty list without dummy mock fallback when offline', () async {
      final list = await repo.fetchApprovalsBox(box: 'waiting');
      expect(list, isEmpty);
    });

    test('fetchApprovalsBox returns empty list for decided box when offline', () async {
      final list = await repo.fetchApprovalsBox(box: 'decided');
      expect(list, isEmpty);
    });

    test('fetchApprovalDetails returns null without dummy mock fallback when offline', () async {
      final details = await repo.fetchApprovalDetails('01jb2x9k4m7q8r3t5v6w8y0z1a');
      expect(details, isNull);
    });
  });

  group('ApprovalController Logic Tests', () {
    late ApprovalRepo repo;
    late ApprovalController controller;

    setUp(() {
      Get.testMode = true;
      repo = ApprovalRepo();
      controller = ApprovalController(repo: repo);
    });

    tearDown(() {
      controller.onClose();
      Get.reset();
    });

    test('Initializes with default box waiting and handles empty inbox without crash', () async {
      expect(controller.selectedBox.value, 'waiting');
      await controller.fetchApprovals();

      expect(controller.approvalsList, isEmpty);
    });

    test('changeBox switches box and refreshes inbox items', () async {
      await controller.changeBox('decided');
      expect(controller.selectedBox.value, 'decided');
      expect(controller.approvalsList, isEmpty);
    });

    test('rejectRequest sets rejectionError when comment is empty or short', () async {
      await controller.rejectRequest('01jb2x9k4m7q8r3t5v6w8y0z1a', comment: '');
      expect(controller.rejectionError.value, isNotNull);

      await controller.rejectRequest('01jb2x9k4m7q8r3t5v6w8y0z1a', comment: 'No');
      expect(controller.rejectionError.value, contains('at least 5 characters'));
    });
  });
}
