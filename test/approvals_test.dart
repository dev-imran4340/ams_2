import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ams_2/app/screens/leaves/model/approval_model.dart';
import 'package:ams_2/app/screens/leaves/repo/leave_repo.dart';
import 'package:ams_2/app/screens/leaves/controller/leave_controller.dart';

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

    test('Parses full audit details from GET /approvals/{id} accurately', () {
      final detailJson = {
        'id': '01jb2x9k4m7q8r3t5v6w8y0z1a',
        'type': 'employee_details_change',
        'type_label': 'Change of my details',
        'title': 'Change of my details: personal phone',
        'requested_by': 'Ayesha Khan',
        'status': 'pending',
        'status_label': 'Waiting',
        'status_tone': 'amber',
        'changes': [
          {
            'label': 'Personal phone',
            'before': '0300 1111111',
            'after': '0300 2222222',
          }
        ],
        'facts': [
          {'label': 'Location', 'value': 'Head office'}
        ],
        'steps': [
          {
            'position': 1,
            'approver': 'Department manager',
            'status': 'approved',
            'status_label': 'Approved',
            'status_tone': 'emerald',
            'skipped_reason': null,
            'approvers': <String>[],
          },
          {
            'position': 2,
            'approver': 'Role: HR officer',
            'status': 'current',
            'status_label': 'Waiting for approval',
            'status_tone': 'amber',
            'skipped_reason': null,
            'approvers': ['Sara Ahmed', 'Usman Ali'],
          }
        ],
        'decisions': [
          {
            'step': 1,
            'by': 'Maryam Siddiqui',
            'decision': 'approved',
            'decision_label': 'Approved',
            'comment': 'Fine',
            'was_override': false,
            'at': '2026-10-22T10:00:00+00:00',
            'ago': '1 hour ago',
          }
        ],
        'can': {
          'approve': true,
          'reject': true,
          'as_override': false,
          'cancel': false,
        }
      };

      final item = ApprovalItemModel.fromJson(detailJson);

      expect(item.changes.length, 1);
      expect(item.changes.first.label, 'Personal phone');
      expect(item.changes.first.before, '0300 1111111');
      expect(item.changes.first.after, '0300 2222222');

      expect(item.facts.length, 1);
      expect(item.facts.first.label, 'Location');
      expect(item.facts.first.value, 'Head office');

      expect(item.steps.length, 2);
      expect(item.steps[0].isApproved, isTrue);
      expect(item.steps[1].isCurrent, isTrue);
      expect(item.steps[1].approvers, contains('Sara Ahmed'));

      expect(item.decisions.length, 1);
      expect(item.decisions.first.by, 'Maryam Siddiqui');

      expect(item.can.approve, isTrue);
      expect(item.can.reject, isTrue);
      expect(item.can.asOverride, isFalse);
      expect(item.can.cancel, isFalse);
    });
  });

  group('LeaveRepo Approvals Tests', () {
    late LeaveRepo repo;

    setUp(() {
      repo = LeaveRepo();
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

  group('LeaveController Logic Tests', () {
    late LeaveRepo repo;
    late LeaveController controller;

    setUp(() {
      Get.testMode = true;
      repo = LeaveRepo();
      controller = LeaveController(repo: repo);
    });

    tearDown(() {
      controller.onClose();
      Get.reset();
    });

    test('Initializes with default box waiting and handles empty inbox without crash', () async {
      expect(controller.selectedBox.value, 'waiting');
      await controller.loadLeaveData();

      expect(controller.approvalsList, isEmpty);
      expect(controller.balances, isEmpty);
    });

    test('changeBox switches box and refreshes inbox items', () async {
      await controller.changeBox('decided');
      expect(controller.selectedBox.value, 'decided');
      expect(controller.approvalsList, isEmpty);
    });

    test('validateApplyLeaveForm enforces required dates and reason length >= 5', () {
      controller.startDate.value = null;
      controller.endDate.value = null;
      controller.reasonController.text = '';

      final isValid = controller.validateApplyLeaveForm();

      expect(isValid, isFalse);
      expect(controller.startDateError.value, isNotNull);
      expect(controller.endDateError.value, isNotNull);
      expect(controller.reasonError.value, isNotNull);

      // Now set start date and end date before start date
      final now = DateTime.now();
      controller.startDate.value = now;
      controller.endDate.value = now.subtract(const Duration(days: 1));
      controller.reasonController.text = 'Hi'; // Too short (< 5 chars)

      final isValid2 = controller.validateApplyLeaveForm();

      expect(isValid2, isFalse);
      expect(controller.startDateError.value, isNull);
      expect(controller.endDateError.value, contains('earlier than start date'));
      expect(controller.reasonError.value, contains('at least 5 characters'));

      // Now set valid values
      controller.endDate.value = now.add(const Duration(days: 2));
      controller.reasonController.text = 'Family medical emergency appointment';

      final isValid3 = controller.validateApplyLeaveForm();

      expect(isValid3, isTrue);
      expect(controller.startDateError.value, isNull);
      expect(controller.endDateError.value, isNull);
      expect(controller.reasonError.value, isNull);
    });

    test('rejectRequest sets rejectionError when comment is empty or short', () async {
      await controller.rejectRequest('01jb2x9k4m7q8r3t5v6w8y0z1a', comment: '');
      expect(controller.rejectionError.value, isNotNull);

      await controller.rejectRequest('01jb2x9k4m7q8r3t5v6w8y0z1a', comment: 'No');
      expect(controller.rejectionError.value, contains('at least 5 characters'));
    });
  });
}
