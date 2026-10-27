import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ams_2/app/screens/notifications/model/notification_item_model.dart';
import 'package:ams_2/app/screens/notifications/model/notification_preferences_model.dart';
import 'package:ams_2/app/screens/notifications/model/push_token_payload_model.dart';
import 'package:ams_2/app/screens/notifications/repo/notification_repo.dart';
import 'package:ams_2/app/screens/notifications/controller/notification_controller.dart';

class MockNotificationRepo extends NotificationRepo {
  @override
  Future<NotificationsResponseModel?> fetchNotifications({
    int page = 1,
    int perPage = 25,
    bool unreadOnly = false,
  }) async {
    final list = [
      NotificationItemModel(
        id: '01jb2x9k4m7q8r3t5v6w8y0z1a',
        kind: 'approval_needed',
        title: 'Request to approve',
        body: 'Ayesha Khan: Change of my details: personal phone',
        link: 'https://laravel.ams-hrpayroll.com/requests/01jb2x9k4m7q8r3t5v6w8y0z1a',
        target: const NotificationTargetModel(screen: 'request', id: '01jb2x9k4m7q8r3t5v6w8y0z1a'),
        read: false,
        createdAgo: '5 minutes ago',
      ),
      NotificationItemModel(
        id: '01jb2x9k4m7q8r3t5v6w8y0z1b',
        kind: 'request_approved',
        title: 'Leave Approved',
        body: 'Your Annual Leave request has been approved by HR.',
        target: const NotificationTargetModel(screen: 'requests'),
        read: true,
        createdAgo: '2 hours ago',
      ),
    ];

    final filtered = unreadOnly ? list.where((n) => !n.read).toList() : list;

    return NotificationsResponseModel(
      data: filtered,
      meta: NotificationMetaModel(
        page: page,
        perPage: perPage,
        total: filtered.length,
        lastPage: 1,
        unread: 1,
      ),
    );
  }

  @override
  Future<bool> markAsRead(String id) async => true;

  @override
  Future<bool> markAllAsRead() async => true;

  @override
  Future<NotificationPreferencesModel?> fetchPreferences() async {
    return const NotificationPreferencesModel(
      categories: {
        'approval_needed': ChannelPreferenceModel(mail: true, bell: true, push: true),
        'request_approved': ChannelPreferenceModel(mail: true, bell: true, push: true),
        'request_rejected': ChannelPreferenceModel(mail: true, bell: true, push: true),
        'approval_reminder': ChannelPreferenceModel(mail: true, bell: true, push: false),
      },
    );
  }

  @override
  Future<NotificationPreferencesModel?> updatePreferences({
    required String kind,
    required Map<String, bool> changedChannels,
  }) async {
    return const NotificationPreferencesModel(
      categories: {
        'approval_needed': ChannelPreferenceModel(mail: true, bell: true, push: false),
        'request_approved': ChannelPreferenceModel(mail: true, bell: true, push: true),
        'request_rejected': ChannelPreferenceModel(mail: true, bell: true, push: true),
        'approval_reminder': ChannelPreferenceModel(mail: true, bell: true, push: false),
      },
    );
  }

  @override
  Future<bool> registerPushToken(PushTokenPayloadModel payload) async => true;

  @override
  Future<bool> deletePushToken(String token) async => true;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    const MethodChannel channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async => '.');
    await GetStorage.init();
  });

  tearDown(() {
    Get.reset();
  });

  group('Notification Models Tests', () {
    test('NotificationItemModel correctly parses server JSON envelope', () {
      final json = {
        'id': '01jb2x9k4m7q8r3t5v6w8y0z1a',
        'kind': 'approval_needed',
        'title': 'Request to approve',
        'body': 'Ayesha Khan: Change of my details: personal phone',
        'link': 'https://laravel.ams-hrpayroll.com/requests/01jb2x9k4m7q8r3t5v6w8y0z1a',
        'target': {'screen': 'request', 'id': '01jb2x9k4m7q8r3t5v6w8y0z1a'},
        'read': false,
        'created_at': '2026-10-22T09:15:00+00:00',
        'created_ago': '5 minutes ago',
      };

      final item = NotificationItemModel.fromJson(json);

      expect(item.id, '01jb2x9k4m7q8r3t5v6w8y0z1a');
      expect(item.kind, 'approval_needed');
      expect(item.kindLabel, 'Approval Needed');
      expect(item.title, 'Request to approve');
      expect(item.target.screen, 'request');
      expect(item.target.id, '01jb2x9k4m7q8r3t5v6w8y0z1a');
      expect(item.read, isFalse);
      expect(item.createdAgo, '5 minutes ago');
    });

    test('NotificationPreferencesModel parses channel states and locks In-App bell', () {
      final json = {
        'data': {
          'approval_needed': {'mail': true, 'bell': true, 'push': true},
          'request_approved': {'mail': true, 'bell': true, 'push': true},
          'request_rejected': {'mail': true, 'bell': true, 'push': true},
          'approval_reminder': {'mail': true, 'bell': true, 'push': false},
        }
      };

      final prefs = NotificationPreferencesModel.fromJson(json);

      expect(prefs.approvalNeeded.bell, isTrue);
      expect(prefs.approvalNeeded.push, isTrue);
      expect(prefs.approvalReminder.push, isFalse);
      expect(NotificationPreferencesModel.getKindLabel('approval_needed'), 'A request needs my approval');
      expect(NotificationPreferencesModel.getKindLabel('request_approved'), 'My request was approved');
      expect(NotificationPreferencesModel.getKindLabel('request_rejected'), 'My request was rejected');
      expect(NotificationPreferencesModel.getKindLabel('approval_reminder'), 'Daily reminder of requests still waiting for me');
    });

    test('PushTokenPayloadModel serializes accurately for POST /push-tokens', () {
      const payload = PushTokenPayloadModel(
        token: 'fcm_test_token_123',
        platform: 'android',
        appVersion: '2.0.0',
      );

      final map = payload.toJson();
      expect(map['token'], 'fcm_test_token_123');
      expect(map['platform'], 'android');
      expect(map['app_version'], '2.0.0');
    });
  });

  group('NotificationController Flow Tests', () {
    test('Initializes, loads notifications and preferences', () async {
      final repo = MockNotificationRepo();
      final controller = NotificationController(repo: repo);

      await controller.loadNotifications();
      await controller.loadPreferences();

      expect(controller.notifications.length, 2);
      expect(controller.unreadCount.value, 1);
      expect(controller.preferences.value.approvalNeeded.push, isTrue);

      controller.onClose();
    });

    test('Marks all as read updates reactive state', () async {
      final repo = MockNotificationRepo();
      final controller = NotificationController(repo: repo);

      await controller.loadNotifications();
      expect(controller.unreadCount.value, 1);

      await controller.markAllAsRead();
      expect(controller.unreadCount.value, 0);
      expect(controller.notifications.every((n) => n.read), isTrue);

      controller.onClose();
    });

    test('Prevents turning off mandatory in-app bell channel', () async {
      final repo = MockNotificationRepo();
      final controller = NotificationController(repo: repo);

      await controller.loadPreferences();

      await controller.togglePreferenceChannel(
        kind: 'approval_needed',
        channel: 'bell',
        newValue: false,
      );

      // Bell remains locked on
      expect(controller.preferences.value.approvalNeeded.bell, isTrue);

      controller.onClose();
    });
  });
}
