import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ams_2/app/screens/helpdesk/model/helpdesk_model.dart';
import 'package:ams_2/app/screens/helpdesk/repo/helpdesk_repo.dart';
import 'package:ams_2/app/screens/helpdesk/controller/helpdesk_controller.dart';

class MockHelpdeskRepo extends HelpdeskRepo {
  final List<HelpdeskTicketModel>? mockTickets;
  final List<HelpdeskCategoryModel>? mockCategories;
  final HelpdeskTicketModel? mockDetails;
  final bool shouldFail;

  MockHelpdeskRepo({
    this.mockTickets,
    this.mockCategories,
    this.mockDetails,
    this.shouldFail = false,
  });

  @override
  Future<List<HelpdeskTicketModel>?> fetchTickets() async {
    if (shouldFail) return null;
    return mockTickets ?? [];
  }

  @override
  Future<List<HelpdeskCategoryModel>?> fetchCategories() async {
    if (shouldFail) return null;
    return mockCategories ?? [];
  }

  @override
  Future<HelpdeskTicketModel?> fetchTicketDetails(String id) async {
    if (shouldFail) return null;
    return mockDetails;
  }

  @override
  Future<HelpdeskTicketModel?> createTicket({
    required String categoryId,
    required String subject,
    required String message,
    String priority = 'normal',
    bool isConfidential = false,
  }) async {
    if (shouldFail) return null;
    return HelpdeskTicketModel(
      id: '01m_new_ticket_123456789',
      reference: 'HD-2026-9999',
      subject: subject,
      category: 'Payroll and tax',
      priority: priority,
      isConfidential: isConfidential,
      status: 'open',
      statusLabel: 'Open',
      statusTone: 'amber',
      createdAt: DateTime.now().toIso8601String(),
    );
  }

  @override
  Future<HelpdeskMessageModel?> postMessage({
    required String ticketId,
    required String body,
    dynamic files,
  }) async {
    if (shouldFail) return null;
    return HelpdeskMessageModel(
      id: '01m_new_msg_123456789',
      author: 'Test Employee',
      fromRaiser: true,
      body: body,
      createdAt: DateTime.now().toIso8601String(),
    );
  }

  @override
  Future<bool> cancelTicket(String ticketId, {String? reason}) async {
    return !shouldFail;
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
  });

  group('Helpdesk Models & Deserialization Tests', () {
    test('parses live server ticket payload with messages accurately', () {
      final json = {
        'id': '01m6ra6raxy15s1dwkjtrdqg61',
        'reference': 'HD-2026-0026',
        'subject': 'for testing',
        'category': 'Documents and letters',
        'is_confidential': false,
        'status': 'open',
        'status_label': 'Open',
        'status_tone': 'amber',
        'priority': 'normal',
        'raised_by': {'id': '1', 'name': 'Malik Muhammad Imran'},
        'assignee': null,
        'created_at': '2026-11-06T11:34:19+00:00',
        'last_activity_at': '2026-11-06T11:34:19+00:00',
        'resolved_at': null,
        'messages': [
          {
            'id': '01m6ra6razskefvwqs57mwbbjt',
            'author': 'Malik Muhammad Imran',
            'from_raiser': true,
            'is_internal': false,
            'body': 'for testing',
            'created_at': '2026-11-06T11:34:19+00:00',
            'files': [],
          }
        ]
      };

      final ticket = HelpdeskTicketModel.fromJson(json);

      expect(ticket.id, '01m6ra6raxy15s1dwkjtrdqg61');
      expect(ticket.reference, 'HD-2026-0026');
      expect(ticket.subject, 'for testing');
      expect(ticket.category, 'Documents and letters');
      expect(ticket.isConfidential, isFalse);
      expect(ticket.isOpen, isTrue);
      expect(ticket.isInProgress, isFalse);
      expect(ticket.isResolved, isFalse);
      expect(ticket.raisedByName, 'Malik Muhammad Imran');
      expect(ticket.assigneeName, isNull);
      expect(ticket.messages.length, 1);
      expect(ticket.messages.first.author, 'Malik Muhammad Imran');
      expect(ticket.messages.first.fromRaiser, isTrue);
    });

    test('parses categories payload accurately', () {
      final jsonList = [
        {'id': '01m6jjtedbgr94r957vmej697j', 'name': 'Documents and letters'},
        {'id': '01m6jjtedd9z0t4mmapfs9v84q', 'name': 'Grievance'},
        {'id': '01m6jjted45wjcaxajw2pkwya0', 'name': 'Payroll and tax'},
      ];

      final categories = jsonList.map((j) => HelpdeskCategoryModel.fromJson(j)).toList();

      expect(categories.length, 3);
      expect(categories[0].id, '01m6jjtedbgr94r957vmej697j');
      expect(categories[0].name, 'Documents and letters');
      expect(categories[2].name, 'Payroll and tax');
    });
  });

  group('HelpdeskController Operations & Telemetry Tests', () {
    late HelpdeskController controller;

    setUp(() {
      Get.reset();
      Get.testMode = true;
    });

    tearDown(() {
      Get.reset();
    });

    test('computes telemetry counts and handles category / status filtering', () async {
      final mockTickets = [
        const HelpdeskTicketModel(
          id: '1',
          reference: 'HD-001',
          subject: 'Tax deduction query',
          category: 'Payroll and tax',
          status: 'open',
          statusTone: 'amber',
          priority: 'high',
          createdAt: '2026-11-01',
        ),
        const HelpdeskTicketModel(
          id: '2',
          reference: 'HD-002',
          subject: 'Laptop screen flicker',
          category: 'IT and equipment',
          status: 'in_progress',
          statusTone: 'brand',
          priority: 'normal',
          createdAt: '2026-11-02',
        ),
        const HelpdeskTicketModel(
          id: '3',
          reference: 'HD-003',
          subject: 'Old payroll slip',
          category: 'Payroll and tax',
          status: 'resolved',
          statusTone: 'emerald',
          priority: 'low',
          createdAt: '2026-11-03',
        ),
      ];

      final mockCategories = [
        const HelpdeskCategoryModel(id: 'c1', name: 'Payroll and tax'),
        const HelpdeskCategoryModel(id: 'c2', name: 'IT and equipment'),
      ];

      final repo = MockHelpdeskRepo(
        mockTickets: mockTickets,
        mockCategories: mockCategories,
      );

      controller = HelpdeskController(repo: repo);
      await controller.loadInitialData();

      // Telemetry verification
      expect(controller.totalCount, 3);
      expect(controller.openCount, 1);
      expect(controller.inProgressCount, 1);
      expect(controller.resolvedCount, 1);

      // Filtering: open
      controller.setFilter('open');
      expect(controller.filteredTickets.length, 1);
      expect(controller.filteredTickets.first.reference, 'HD-001');

      // Category filter: Payroll and tax
      controller.setFilter('all');
      controller.setCategoryFilter('Payroll and tax');
      expect(controller.filteredTickets.length, 2);
      expect(controller.filteredTickets.every((t) => t.category == 'Payroll and tax'), isTrue);
    });

    test('creates new ticket and inserts at top of list', () async {
      final repo = MockHelpdeskRepo(
        mockTickets: [],
        mockCategories: [
          const HelpdeskCategoryModel(id: 'c1', name: 'Payroll and tax'),
        ],
      );

      controller = HelpdeskController(repo: repo);
      await controller.loadInitialData();

      controller.subjectController.text = 'Urgent salary query';
      controller.descriptionController.text = 'My allowance is missing from current payroll';
      controller.selectedCategoryId.value = 'c1';
      controller.selectedPriority.value = 'urgent';

      final success = await controller.submitNewTicket();
      expect(success, isTrue);
      expect(controller.tickets.length, 1);
      expect(controller.tickets.first.subject, 'Urgent salary query');
    });

    test('posts reply message to active ticket', () async {
      const ticket = HelpdeskTicketModel(
        id: '1',
        reference: 'HD-001',
        subject: 'Tax query',
        category: 'Payroll and tax',
        status: 'open',
        createdAt: '2026-11-01',
      );

      final repo = MockHelpdeskRepo(mockTickets: [ticket]);
      controller = HelpdeskController(repo: repo);
      await controller.loadInitialData();

      controller.selectedTicket.value = ticket;
      controller.messageController.text = 'Here are more details about my query';

      final success = await controller.sendReplyMessage();
      expect(success, isTrue);
      expect(controller.selectedTicket.value!.messages.length, 1);
      expect(controller.selectedTicket.value!.messages.first.body, 'Here are more details about my query');
      expect(controller.messageController.text, isEmpty);
    });

    test('loadTicketById loads ticket details into selectedTicket', () async {
      const detailedTicket = HelpdeskTicketModel(
        id: 'ticket_deep_link_123',
        reference: 'HD-2026-0099',
        subject: 'Deep link subject',
        category: 'IT Support',
        status: 'open',
        createdAt: '2026-11-20T10:00:00Z',
        messages: [
          HelpdeskMessageModel(
            id: 'm1',
            author: 'HR Admin',
            fromRaiser: false,
            body: 'Hello, how can we help?',
            createdAt: '2026-11-20T10:05:00Z',
          ),
        ],
      );

      final repo = MockHelpdeskRepo(mockDetails: detailedTicket);
      controller = HelpdeskController(repo: repo);

      await controller.loadTicketById('ticket_deep_link_123');
      expect(controller.selectedTicket.value, isNotNull);
      expect(controller.selectedTicket.value!.id, 'ticket_deep_link_123');
      expect(controller.selectedTicket.value!.messages.length, 1);
      expect(controller.selectedTicket.value!.messages.first.author, 'HR Admin');
    });

    test('polls and syncs new incoming chat messages silently', () async {
      const initialTicket = HelpdeskTicketModel(
        id: 'poll_1',
        reference: 'HD-001',
        subject: 'Realtime test',
        category: 'General',
        status: 'open',
        createdAt: '2026-11-20T10:00:00Z',
        messages: [],
      );

      const updatedWithReply = HelpdeskTicketModel(
        id: 'poll_1',
        reference: 'HD-001',
        subject: 'Realtime test',
        category: 'General',
        status: 'open',
        createdAt: '2026-11-20T10:00:00Z',
        messages: [
          HelpdeskMessageModel(
            id: 'm_incoming',
            author: 'HR Agent',
            fromRaiser: false,
            body: 'Hello from HR, we received your message!',
            createdAt: '2026-11-20T10:01:00Z',
          ),
        ],
      );

      final repo = MockHelpdeskRepo(mockDetails: updatedWithReply);
      controller = HelpdeskController(repo: repo);
      controller.selectedTicket.value = initialTicket;

      await controller.syncTicketDetailsSilently('poll_1');
      expect(controller.selectedTicket.value!.messages.length, 1);
      expect(controller.selectedTicket.value!.messages.first.author, 'HR Agent');

      controller.startChatPolling('poll_1');
      controller.stopChatPolling();
    });

    test('manages ScrollController, chatScrollController and resources disposal cleanly', () {
      final repo = MockHelpdeskRepo();
      controller = HelpdeskController(repo: repo);
      controller.onInit();

      expect(controller.scrollOffset.value, 0.0);
      expect(controller.scrollController.hasClients, isFalse);
      expect(controller.chatScrollController.hasClients, isFalse);

      controller.onClose();
    });
  });
}
