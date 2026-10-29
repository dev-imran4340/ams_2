import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ams_2/app/api/app_preferences.dart';
import 'package:ams_2/app/screens/support_tickets/model/support_ticket_model.dart';
import 'package:ams_2/app/screens/support_tickets/controller/support_ticket_controller.dart';
import 'package:ams_2/app/screens/support_tickets/repo/support_ticket_repo.dart';

class MockSupportTicketRepo extends SupportTicketRepo {
  @override
  Future<List<SupportTicketItemModel>> fetchTickets({
    int page = 1,
    int perPage = 25,
    bool finished = false,
  }) async {
    return [
      SupportTicketItemModel(
        id: '01jb2x9k4m7q8r3t5v6w8y0z1a',
        number: 1042,
        subject: 'Fingerprint scanner not recognising thumb',
        status: finished ? 'Resolved' : 'Open',
        statusTone: finished ? 'emerald' : 'amber',
        statusValue: finished ? 'resolved' : 'open',
        raisedBy: 'Ayesha Khan',
        updatedAt: '2026-10-23T11:45:00Z',
        priority: 'high',
        category: 'technical',
      ),
    ];
  }

  @override
  Future<SupportTicketDetailsModel?> fetchTicketDetails(String id) async {
    return SupportTicketDetailsModel(
      id: id,
      number: 1042,
      subject: 'Fingerprint scanner not recognising thumb',
      status: 'Open',
      statusValue: 'open',
      priority: 'high',
      category: 'technical',
      openedAt: '2026-10-23T11:45:00Z',
      messages: [
        SupportMessageModel(
          id: '01jb2x9k4m7q8r3t5v6w8y0z1b',
          fromUs: false,
          author: 'Ayesha Khan',
          body: 'The front reception scanner keeps rejecting my thumb.',
          at: '2026-10-23T11:45:00Z',
          attachments: [
            SupportAttachmentModel(
              id: '01jb2x9k4m7q8r3t5v6w8y0z1c',
              name: 'error_screen.jpg',
              sizeKb: 240,
            ),
          ],
        ),
      ],
    );
  }

  @override
  Future<SupportTicketDetailsModel?> closeTicket(String ticketId) async {
    return SupportTicketDetailsModel(
      id: ticketId,
      number: 1042,
      subject: 'Fingerprint scanner not recognising thumb',
      status: 'Closed',
      statusValue: 'closed',
      priority: 'high',
      category: 'technical',
      openedAt: '2026-10-23T11:45:00Z',
      messages: [],
    );
  }
}

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
    await AppPreferences.setPermissions({
      'support.view': ['own'],
      'support.raise': null,
    });
  });

  group('Support Tickets Model Tests (Phase 10)', () {
    test('SupportTicketItemModel deserializes correctly', () {
      final json = {
        'id': '01jb2x9k4m7q8r3t5v6w8y0z1a',
        'number': 1042,
        'subject': 'Biometric verification failing',
        'status': 'Open',
        'status_tone': 'amber',
        'status_value': 'open',
        'raised_by': 'Bilal Khan',
        'updated_at': '2026-10-23T11:45:00Z',
        'priority': 'high',
        'category': 'technical',
      };

      final ticket = SupportTicketItemModel.fromJson(json);

      expect(ticket.id, '01jb2x9k4m7q8r3t5v6w8y0z1a');
      expect(ticket.number, 1042);
      expect(ticket.subject, 'Biometric verification failing');
      expect(ticket.statusTone, 'amber');
      expect(ticket.formattedCategory, 'Technical');
      expect(ticket.formattedPriority, 'High');
      expect(ticket.statusColor, isNotNull);
    });

    test('SupportTicketDetailsModel deserializes discussion thread correctly', () {
      final json = {
        'id': '01jb2x9k4m7q8r3t5v6w8y0z1a',
        'number': 1042,
        'subject': 'Biometric verification failing',
        'status': 'Resolved',
        'status_value': 'resolved',
        'priority': 'normal',
        'category': 'technical',
        'opened_at': '2026-10-23T11:45:00Z',
        'messages': [
          {
            'id': '01jb2x9k4m7q8r3t5v6w8y0z1b',
            'from_us': true,
            'author': 'Support Agent (AMS)',
            'body': 'Issue has been fixed on reader #2.',
            'at': '2026-10-23T12:00:00Z',
            'attachments': [
              {
                'id': '01jb2x9k4m7q8r3t5v6w8y0z1c',
                'name': 'diagnostic.pdf',
                'size_kb': 1200,
              }
            ],
          }
        ],
      };

      final details = SupportTicketDetailsModel.fromJson(json);

      expect(details.id, '01jb2x9k4m7q8r3t5v6w8y0z1a');
      expect(details.isResolved, isTrue);
      expect(details.canReopen, isTrue);
      expect(details.messages.length, 1);
      expect(details.messages.first.fromUs, isTrue);
      expect(details.messages.first.attachments.first.formattedSize, '1.2 MB');
    });
  });

  group('SupportTicketController Tests', () {
    late SupportTicketController controller;
    late MockSupportTicketRepo mockRepo;

    setUp(() {
      Get.testMode = true;
      mockRepo = MockSupportTicketRepo();
      controller = SupportTicketController(repo: mockRepo);
    });

    tearDown(() {
      controller.onClose();
      Get.reset();
    });

    test('Loads active tickets and switches filter', () async {
      await controller.loadTickets();

      expect(controller.tickets.length, 1);
      expect(controller.tickets.first.number, 1042);
      expect(controller.tickets.first.status, 'Open');

      // Switch to resolved/closed
      controller.setFilter(true);
      expect(controller.showFinished.value, isTrue);
      await controller.loadTickets();
      expect(controller.tickets.first.status, 'Resolved');
    });

    test('Opens ticket thread and closes ticket', () async {
      await controller.openTicketThread('01jb2x9k4m7q8r3t5v6w8y0z1a');

      expect(controller.selectedTicket.value, isNotNull);
      expect(controller.selectedTicket.value!.messages.length, 1);

      await controller.closeTicket();
      expect(controller.selectedTicket.value!.isClosed, isTrue);
    });
  });
}
