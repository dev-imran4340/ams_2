import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../../firebase_options.dart';
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
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
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

  bool _isInitialized = false;

  /// Initializes Firebase Cloud Messaging and Flutter Local Notifications
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
    const originTag = '$_tag -> initialize()';
    try {
      // 1. Initialize Firebase Core with safe fallback
      try {
        if (Firebase.apps.isNotEmpty) {
          _isFirebaseInitialized = true;
          Get.log('🔥 [$originTag] Firebase Core is already initialized.');
        } else {
          await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          );
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
        _printTokenBanner(cachedToken, source: 'Cached Local Storage (Startup)');
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

      // 7. Register Initial FCM Device Token (Asynchronous background task)
      registerDevicePushToken();
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
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
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
      );
      // On iOS, explicitly configure foreground notification presentation options
      // so that Apple's native heads-up banner and sound play even when app is open
      if (Platform.isIOS) {
        await messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      // On Android 13+, request POST_NOTIFICATIONS runtime permission
      if (Platform.isAndroid) {
        final androidImplementation = _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        final granted = await androidImplementation?.requestNotificationsPermission();
        Get.log('🤖 [$originTag] Android POST_NOTIFICATIONS permission granted: $granted');
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
      final title = notification?.title ?? message.data['title']?.toString();
      final body = notification?.body ?? message.data['body']?.toString() ?? message.data['message']?.toString();

      // Show native heads-up banner via flutter_local_notifications
      if (title != null || body != null) {
        _localNotifications.show(
          id: message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: title ?? 'Workplace Notification',
          body: body ?? '',
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              _channel.id,
              _channel.name,
              channelDescription: _channel.description,
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
              enableVibration: true,
              icon: android?.smallIcon ?? '@mipmap/ic_launcher',
              styleInformation: BigTextStyleInformation(
                body ?? '',
                contentTitle: title ?? 'Workplace Notification',
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

  bool _isRegisteringToken = false;

  /// Registers the device's FCM token with the AMS 2 backend (POST /push-tokens)
  Future<void> registerDevicePushToken({String? token}) async {
    const originTag = '$_tag -> registerDevicePushToken()';
    if (!_isFirebaseInitialized) return;
    if (_isRegisteringToken && token == null) return;
    _isRegisteringToken = true;

    try {
      String? fcmToken = token;

      if (fcmToken == null || fcmToken.isEmpty) {
        // On iOS, APNs token MUST be delivered by Apple before calling getToken()
        if (Platform.isIOS) {
          int apnsAttempts = 0;
          const maxApnsAttempts = 8;
          while (apnsAttempts < maxApnsAttempts) {
            final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
            if (apnsToken != null && apnsToken.isNotEmpty) {
              Get.log('🍏 [$originTag] APNs device token acquired from iOS.');
              break;
            }
            apnsAttempts++;
            if (apnsAttempts < maxApnsAttempts) {
              await Future.delayed(const Duration(milliseconds: 1000));
            }
          }
        }

        // Attempt to fetch FCM Token (with retries for asynchronous APNs handshake)
        int tokenAttempts = 0;
        const maxTokenAttempts = 6;
        while (tokenAttempts < maxTokenAttempts && (fcmToken == null || fcmToken.isEmpty)) {
          try {
            // ignore: deprecated_member_use
            fcmToken = await FirebaseMessaging.instance.getToken();
            if (fcmToken != null && fcmToken.isNotEmpty) {
              break;
            }
          } catch (e) {
            tokenAttempts++;
            if (e.toString().contains('apns-token-not-set')) {
              Get.log('⏳ [$originTag] APNs token still synchronizing with Apple (attempt $tokenAttempts/$maxTokenAttempts)...');
              if (tokenAttempts < maxTokenAttempts) {
                await Future.delayed(const Duration(seconds: 1));
                continue;
              }
            } else {
              Get.log('⚠️ [$originTag] Error calling getToken(): $e');
              break;
            }
          }
        }
      }

      if (fcmToken != null && fcmToken.isNotEmpty) {
        _backgroundRetryCount = 0;
        await _processAndSaveToken(fcmToken, originTag: originTag);
      } else {
        final cached = AppPreferences.fcmToken;
        if (cached != null && cached.isNotEmpty) {
          Get.log('💾 [$originTag] Using cached FCM token for session.');
          _printTokenBanner(cached, source: 'Cached Local (Fallback)');
        } else {
          Get.log('⚠️ [$originTag] FCM token not yet available. Waiting for APNs delivery / onTokenRefresh.');
          _scheduleBackgroundRetry();
        }
      }
    } catch (e) {
      Get.log('❌ [$originTag] Exception during push token registration: $e');
    } finally {
      _isRegisteringToken = false;
    }
  }

  int _backgroundRetryCount = 0;

  /// Periodically attempts to fetch the FCM token in background if APNs was delayed
  void _scheduleBackgroundRetry() {
    if (_backgroundRetryCount >= 6) return;
    _backgroundRetryCount++;
    final delaySeconds = 3 * _backgroundRetryCount;
    Future.delayed(Duration(seconds: delaySeconds), () {
      if (AppPreferences.fcmToken == null && !_isRegisteringToken) {
        Get.log('🔄 [PushNotificationService] Background retry pass $_backgroundRetryCount/6 for FCM token...');
        registerDevicePushToken();
      }
    });
  }

  /// Prominently outputs the FCM token in a clean, high-visibility console box for testing
  void _printTokenBanner(String token, {String source = 'Firebase Live'}) {
    debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🔥 [AMS FCM DEVICE TOKEN CAPTURED]');
    debugPrint('   • Source   : $source');
    debugPrint('   • Platform : ${Platform.isIOS ? "iOS" : (Platform.isAndroid ? "Android" : defaultTargetPlatform.name)}');
    debugPrint('   • Token    :');
    debugPrint(token);
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
  }

  /// Saves FCM token locally, prints it prominently to console, and syncs to backend if logged in
  Future<void> _processAndSaveToken(String token, {required String originTag}) async {
    // 1. Persist locally to AppPreferences
    await AppPreferences.setFcmToken(token);

    // 2. Print prominently to console for easy developer inspection
    Get.log('🔑 [$originTag] FCM Token acquired successfully.');
    _printTokenBanner(token, source: originTag);

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
