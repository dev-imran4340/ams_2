import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../api/app_preferences.dart';
import '../screens/notifications/controller/notification_controller.dart';
import '../screens/notifications/model/push_token_payload_model.dart';
import '../screens/notifications/repo/notification_repo.dart';
import 'notification_payload_handler.dart';

/// Top-level background message handler required by Firebase Cloud Messaging.
/// Must be outside of any class and annotated with @pragma('vm:entry-point').
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // If native default app already exists or config not available
  }
  Get.log(
    '🌙 [PushNotificationService / Background -> handler] Message ID: ${message.messageId}\n'
    'Data: ${message.data}\n'
    'Notification: ${message.notification?.title} - ${message.notification?.body}',
  );
}

/// Production-grade enterprise Push Notification Service for AMS 2.
/// Handles FCM tokens, background and foreground messages, local heads-up banners,
/// and routes clicks seamlessly to the target screens.
class PushNotificationService {
  static const String _tag = 'PushNotificationService';

  static final PushNotificationService instance = PushNotificationService._internal();
  PushNotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final NotificationRepo _repo = NotificationRepo();

  bool _isFirebaseInitialized = false;

  /// High importance notification channel for Android 8.0+ (API 26+)
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'ams_high_importance_channel',
    'AMS Work Alerts',
    description: 'Critical approvals, attendance updates, and workplace requests.',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
    showBadge: true,
  );

  /// Initializes Firebase Cloud Messaging and Flutter Local Notifications
  Future<void> initialize() async {
    const originTag = '$_tag -> initialize()';
    try {
      // 1. Initialize Firebase Core with safe fallback
      try {
        if (Firebase.apps.isNotEmpty) {
          _isFirebaseInitialized = true;
          Get.log('🔥 [$originTag] Firebase Core is already initialized.');
        } else {
          await Firebase.initializeApp();
          _isFirebaseInitialized = true;
          Get.log('🔥 [$originTag] Firebase Core initialized successfully.');
        }
      } catch (e) {
        _isFirebaseInitialized = Firebase.apps.isNotEmpty;
        Get.log('⚠️ [$originTag] Firebase Core initialization: $e');
      }

      // Print cached token if already present from previous sessions
      final cachedToken = AppPreferences.fcmToken;
      if (cachedToken != null && cachedToken.isNotEmpty) {
        Get.log('💾 [$originTag] Stored Local FCM Token: $cachedToken');
      }

      // 2. Initialize Local Notifications Plugin
      await _initializeLocalNotifications();

      if (!_isFirebaseInitialized) {
        Get.log('ℹ️ [$originTag] Running in local notifications mode without live Firebase.');
        return;
      }

      // 3. Register Background Message Handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // 4. Request System Notification Permissions
      await requestPermissions();

      // 5. Setup Notification Listeners
      _setupForegroundListener();
      _setupMessageOpenedAppListener();
      _setupTokenRefreshListener();

      // 6. Check for Terminated App Launch via Push Notification Tap
      await _checkInitialMessage();

      // 7. Register Initial FCM Device Token
      await registerDevicePushToken();
    } catch (e) {
      Get.log('❌ [$originTag] Error initializing push notifications: $e');
    }
  }

  /// Configures local notification channels and handlers for foreground alerts
  Future<void> _initializeLocalNotifications() async {
    const originTag = '$_tag -> _initializeLocalNotifications()';
    try {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          Get.log('🔔 [$originTag] Local notification tapped with payload: ${response.payload}');
          if (response.payload != null && response.payload!.isNotEmpty) {
            try {
              final Map<String, dynamic> data = jsonDecode(response.payload!);
              NotificationPayloadHandler.handleRemoteMessage(data, origin: 'LocalNotificationTap');
            } catch (e) {
              Get.log('❌ [$originTag] Error decoding payload: $e');
              NotificationPayloadHandler.handleTarget(origin: 'LocalNotificationTapFallback');
            }
          }
        },
      );

      // Create Android Notification Channel
      final androidPlatform = _localNotifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlatform != null) {
        await androidPlatform.createNotificationChannel(_channel);
      }
      Get.log('✅ [$originTag] Local notifications initialized.');
    } catch (e) {
      Get.log('❌ [$originTag] Failed to initialize local notifications: $e');
    }
  }

  /// Requests notification permission on iOS and Android 13+
  Future<void> requestPermissions() async {
    if (!_isFirebaseInitialized) return;
    const originTag = '$_tag -> requestPermissions()';
    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      // On Android 13+, request POST_NOTIFICATIONS runtime permission
      if (Platform.isAndroid) {
        final androidImplementation = _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        await androidImplementation?.requestNotificationsPermission();
      }

      Get.log('📱 [$originTag] Notification authorization status: ${settings.authorizationStatus}');
    } catch (e) {
      Get.log('⚠️ [$originTag] Error requesting permissions: $e');
    }
  }

  /// Listens for foreground push messages and presents a heads-up local banner
  void _setupForegroundListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      Get.log(
        '🔔 [$_tag / Foreground -> onMessage] Received foreground push notification\n'
        'Title: ${message.notification?.title}\n'
        'Body: ${message.notification?.body}\n'
        'Data: ${message.data}',
      );

      final notification = message.notification;
      final android = message.notification?.android;

      // Show native heads-up banner via flutter_local_notifications
      if (notification != null) {
        _localNotifications.show(
          id: notification.hashCode,
          title: notification.title,
          body: notification.body,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              _channel.id,
              _channel.name,
              channelDescription: _channel.description,
              importance: Importance.max,
              priority: Priority.high,
              icon: android?.smallIcon ?? '@mipmap/ic_launcher',
              styleInformation: BigTextStyleInformation(
                notification.body ?? '',
                contentTitle: notification.title,
              ),
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          payload: jsonEncode(message.data),
        );
      }

      // If NotificationController is active, trigger real-time refresh
      if (Get.isRegistered<NotificationController>()) {
        Get.find<NotificationController>().onPushReceived();
      }
    });
  }

  /// Listens for notification click events when the app is in the background
  void _setupMessageOpenedAppListener() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Get.log('📲 [$_tag / BackgroundClick -> onMessageOpenedApp] User clicked notification: ${message.data}');
      NotificationPayloadHandler.handleRemoteMessage(message.data, origin: 'FCM_BackgroundClick');
    });
  }

  /// Listens for FCM token rotations and syncs with AMS 2 backend
  void _setupTokenRefreshListener() {
    // ignore: deprecated_member_use
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      Get.log('🔄 [$_tag / TokenRefresh] New FCM token received from Firebase');
      await _processAndSaveToken(newToken, originTag: '$_tag / TokenRefresh');
    });
  }

  /// Checks if the app was opened from terminated state by tapping a notification
  Future<void> _checkInitialMessage() async {
    try {
      final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        Get.log('🚀 [$_tag / TerminatedLaunch -> getInitialMessage] App opened from push: ${initialMessage.data}');
        // Wait for widget tree to mount before navigating
        WidgetsBinding.instance.addPostFrameCallback((_) {
          NotificationPayloadHandler.handleRemoteMessage(initialMessage.data, origin: 'FCM_TerminatedLaunch');
        });
      }
    } catch (e) {
      Get.log('⚠️ [$_tag] Error checking initial message: $e');
    }
  }

  /// Registers the device's FCM token with the AMS 2 backend (POST /push-tokens)
  Future<void> registerDevicePushToken({String? token}) async {
    const originTag = '$_tag -> registerDevicePushToken()';
    if (!_isFirebaseInitialized) return;

    try {
      String? fcmToken = token;

      if (fcmToken == null || fcmToken.isEmpty) {
        // On iOS, APNs token MUST be available before calling getToken()
        if (Platform.isIOS) {
          String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
          int retry = 0;
          while (apnsToken == null && retry < 3) {
            await Future.delayed(const Duration(milliseconds: 800));
            apnsToken = await FirebaseMessaging.instance.getAPNSToken();
            retry++;
          }

          if (apnsToken == null) {
            final cached = AppPreferences.fcmToken;
            Get.log(
              'ℹ️ [$originTag] APNs token has not been assigned by iOS yet (common on simulator or fresh launch).\n'
              '${cached != null ? "💾 Loaded Cached FCM Token: $cached" : "Token will be acquired automatically via onTokenRefresh when APNs delivers it."}',
            );
            return;
          }
        }

        try {
          // ignore: deprecated_member_use
          fcmToken = await FirebaseMessaging.instance.getToken();
        } catch (e) {
          if (e.toString().contains('apns-token-not-set')) {
            final cached = AppPreferences.fcmToken;
            Get.log(
              'ℹ️ [$originTag] APNs token still initializing asynchronously by iOS.\n'
              '${cached != null ? "💾 Loaded Cached FCM Token: $cached" : "Waiting for onTokenRefresh..."}',
            );
            return;
          }
          rethrow;
        }
      }

      if (fcmToken != null && fcmToken.isNotEmpty) {
        await _processAndSaveToken(fcmToken, originTag: originTag);
      }
    } catch (e) {
      Get.log('❌ [$originTag] Exception during push token registration: $e');
    }
  }

  /// Saves FCM token locally, prints it prominently to console, and syncs to backend if logged in
  Future<void> _processAndSaveToken(String token, {required String originTag}) async {
    // 1. Persist locally to AppPreferences
    await AppPreferences.setFcmToken(token);

    // 2. Print prominently to console for easy developer inspection
    Get.log(
      '===============================================================\n'
      '🔑 [FCM Device Token] ($originTag):\n'
      '$token\n'
      '===============================================================',
    );
    debugPrint(
      '\n===============================================================\n'
      '🔑 [FCM Device Token]:\n$token\n'
      '===============================================================\n',
    );

    // 3. Sync with backend if user is logged in
    if (AppPreferences.isLoggedIn) {
      final platform = defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';
      final payload = PushTokenPayloadModel(
        token: token,
        platform: platform,
        appVersion: '2.0.0',
      );

      final success = await _repo.registerPushToken(payload);
      if (success) {
        Get.log('✅ [$originTag] FCM token registered with AMS 2 server successfully.');
      } else {
        Get.log('⚠️ [$originTag] Server rejected push token registration.');
      }
    } else {
      Get.log('ℹ️ [$originTag] Token saved locally; will register with backend upon login.');
    }
  }

  /// Deregisters the device's FCM token from AMS 2 backend (DELETE /push-tokens)
  Future<void> unregisterDevicePushToken() async {
    const originTag = '$_tag -> unregisterDevicePushToken()';
    try {
      final token = AppPreferences.fcmToken;
      if (token != null && token.isNotEmpty) {
        await _repo.deletePushToken(token);
        await AppPreferences.setFcmToken(null);
        Get.log('✅ [$originTag] FCM token deleted from backend.');
      }
    } catch (e) {
      Get.log('❌ [$originTag] Failed to unregister push token: $e');
    }
  }
}
