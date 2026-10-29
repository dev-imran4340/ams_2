import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ams_2/app/screens/leaves/model/leave_model.dart';
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

  tearDown(() {
    Get.reset();
  });

  group('LeaveTypeModel Tests', () {
    test('Correctly parses leave type JSON with business rule invariants', () {
      final json = {
        'id': '01jb2x9k4m7q8r3t5v6w8y0z1a',
        'name': 'Casual Leave',
        'code': 'CL',
        'colour': 'sky',
        'category': 'annual',
        'is_paid': true,
        'unit': 'day',
        'allow_half_days': true,
        'min_notice_days': 1,
        'max_days_in_row': 5,
        'attachment_after_days': 2,
        'allow_past_days': false,
        'has_balance': true,
      };

      final type = LeaveTypeModel.fromJson(json);

      expect(type.id, '01jb2x9k4m7q8r3t5v6w8y0z1a');
      expect(type.name, 'Casual Leave');
      expect(type.code, 'CL');
      expect(type.allowHalfDays, isTrue);
      expect(type.attachmentAfterDays, 2);
      expect(type.isPaid, isTrue);
      expect(type.hasBalance, isTrue);
      expect(type.resolvedColor, isNotNull);
    });
  });

  group('LeaveBalanceModel Tests', () {
    test('Parses leave balance JSON and supports backwards compatible getters', () {
      final json = {
        'type': {
          'id': '01jb2x9k4m7q8r3t5v6w8y0z1a',
          'name': 'Annual Leave',
          'code': 'AL',
          'colour': 'sky',
        },
        'entitlement': 20.0,
        'earned': 20.0,
        'adjusted': 0.0,
        'carried': 2.0,
        'carried_left': 2.0,
        'expired': 0.0,
        'taken': 5.0,
        'booked': 0.0,
        'pending': 1.0,
        'holidays': 0.0,
        'unpaid': 0.0,
        'available': 15.0,
        'total': 22.0,
        'text': {},
      };

      final balance = LeaveBalanceModel.fromJson(json);

      expect(balance.leaveType, 'Annual Leave');
      expect(balance.totalQuota, 20);
      expect(balance.usedCount, 5);
      expect(balance.remainingCount, 15);
      expect(balance.utilizationRatio, closeTo(0.25, 0.01));
      expect(balance.accentColor, isNotNull);
    });
  });

  group('LeavePreviewModel Tests', () {
    test('Parses dry-run preview JSON with calculations', () {
      final json = {
        'ok': true,
        'message': 'Preview calculated successfully',
        'days': 3.0,
        'amount': 3.0,
        'amount_text': '3 days',
        'available_text': '15 days',
        'after_text': '12 days',
        'fields': {},
      };

      final preview = LeavePreviewModel.fromJson(json);

      expect(preview.ok, isTrue);
      expect(preview.days, 3.0);
      expect(preview.amount, 3.0);
      expect(preview.amountText, '3 days');
      expect(preview.availableText, '15 days');
      expect(preview.afterText, '12 days');
    });
  });

  group('LeaveRequestItemModel Tests', () {
    test('Parses leave request item with backwards-compatible date getters', () {
      final json = {
        'id': '01jb2x9k4m7q8r3t5v6w8y0z99',
        'type': {
          'id': '01jb2x9k4m7q8r3t5v6w8y0z1a',
          'name': 'Sick Leave',
          'code': 'SL',
          'colour': 'rose',
        },
        'starts_on': '2026-11-10',
        'ends_on': '2026-11-12',
        'start_part': 'full',
        'end_part': 'full',
        'amount': 3.0,
        'amount_text': '3 days',
        'summary': 'Sick Leave - 3 days',
        'reason': 'Medical checkup and flu recovery',
        'has_attachment': false,
        'status': 'pending',
        'status_label': 'Pending Approval',
        'status_tone': 'amber',
        'source': 'self',
      };

      final request = LeaveRequestItemModel.fromJson(json);

      expect(request.id, '01jb2x9k4m7q8r3t5v6w8y0z99');
      expect(request.leaveType, 'Sick Leave');
      expect(request.totalDays, 3.0);
      expect(request.reason, 'Medical checkup and flu recovery');
      expect(request.isPending, isTrue);
      expect(request.isApproved, isFalse);
      expect(request.isRejected, isFalse);
      expect(request.startDate, isNotNull);
      expect(request.endDate, isNotNull);
    });
  });

  group('LeaveController Logic & State Tests', () {
    test('Filter pills filter requests correctly', () {
      final repo = LeaveRepo();
      final controller = LeaveController(repo: repo);

      controller.leaveRequests.assignAll([
        const LeaveRequestItemModel(
          id: '1',
          leaveType: 'Annual',
          startsOn: '2026-11-01',
          endsOn: '2026-11-02',
          amount: 2.0,
          amountText: '2 days',
          summary: '2 days',
          reason: 'Holiday',
          status: 'approved',
          statusLabel: 'Approved',
          statusTone: 'emerald',
        ),
        const LeaveRequestItemModel(
          id: '2',
          leaveType: 'Sick',
          startsOn: '2026-11-05',
          endsOn: '2026-11-05',
          amount: 1.0,
          amountText: '1 day',
          summary: '1 day',
          reason: 'Fever',
          status: 'pending',
          statusLabel: 'Pending',
          statusTone: 'amber',
        ),
        const LeaveRequestItemModel(
          id: '3',
          leaveType: 'Casual',
          startsOn: '2026-11-08',
          endsOn: '2026-11-08',
          amount: 1.0,
          amountText: '1 day',
          summary: '1 day',
          reason: 'Personal',
          status: 'rejected',
          statusLabel: 'Rejected',
          statusTone: 'rose',
        ),
      ]);

      controller.setLeaveFilter('all');
      expect(controller.filteredLeaveRequests.length, 3);

      controller.setLeaveFilter('pending');
      expect(controller.filteredLeaveRequests.length, 1);
      expect(controller.filteredLeaveRequests.first.id, '2');

      controller.setLeaveFilter('approved');
      expect(controller.filteredLeaveRequests.length, 1);
      expect(controller.filteredLeaveRequests.first.id, '1');

      controller.setLeaveFilter('rejected');
      expect(controller.filteredLeaveRequests.length, 1);
      expect(controller.filteredLeaveRequests.first.id, '3');
    });
  });
}
