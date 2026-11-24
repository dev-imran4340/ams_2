import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:ams_2/app/api/app_preferences.dart';
import 'package:ams_2/app/api/log_sanitizer.dart';
import 'package:ams_2/app/core/utils/secure_storage_service.dart';
import 'package:ams_2/app/routes/app_routes.dart';
import 'package:ams_2/app/routes/auth_guard_middleware.dart';
import 'package:ams_2/app/screens/auth/controller/auth_controller.dart';
import 'package:ams_2/app/screens/auth/model/auth_model.dart';
import 'package:ams_2/app/screens/auth/repo/auth_repo.dart';
import 'package:ams_2/app/screens/index/controller/index_controller.dart';
import 'package:ams_2/app/screens/index/model/me_model.dart';
import 'package:ams_2/app/screens/index/repo/index_repo.dart';

// --- Mocks ---

class MockAuthRepo extends AuthRepo {
  final bool hardwareAvailable;
  final bool biometricSuccess;
  final bool shouldThrowBiometrics;

  MockAuthRepo({
    this.hardwareAvailable = true,
    this.biometricSuccess = true,
    this.shouldThrowBiometrics = false,
  });

  @override
  Future<bool> isBiometricHardwareAvailable() async => hardwareAvailable;

  @override
  Future<bool> authenticateWithBiometricsLocally({String reason = ''}) async {
    if (shouldThrowBiometrics) {
      throw PlatformException(code: 'LockedOut', message: 'Too many attempts');
    }
    return biometricSuccess;
  }
}

class MockIndexRepoForAuth extends IndexRepo {
  MeResponseModel? mockMeResponse;
  int fetchMeCallCount = 0;
  Duration delay = Duration.zero;

  MockIndexRepoForAuth({this.mockMeResponse});

  @override
  Future<MeResponseModel?> fetchMe() async {
    fetchMeCallCount++;
    if (delay > Duration.zero) {
      await Future.delayed(delay);
    }
    return mockMeResponse;
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
    SecureStorageService.useMemoryFallback = true;
  });

  setUp(() async {
    Get.testMode = true;
    await AppPreferences.clearAll();
    SecureStorageService.resetMemoryFallback();
  });

  tearDown(() {
    Get.reset();
  });

  // =========================================================================
  // 1. Normal Login & Employee ID Login Serialization
  // =========================================================================
  group('1. Normal Login & Employee Number Login', () {
    test('Corporate email login request serializes without company_code', () {
      final req = LoginRequestModel(
        login: 'employee@company.com',
        password: 'Password123!',
        deviceName: 'Pixel 8',
      );
      final json = req.toJson();
      expect(json['login'], 'employee@company.com');
      expect(json['password'], 'Password123!');
      expect(json['device_name'], 'Pixel 8');
      expect(json.containsKey('company_code'), isFalse);
    });

    test('Employee number login request includes company_code', () {
      final req = LoginRequestModel(
        login: 'EMP-0042',
        password: 'Password123!',
        companyCode: 'ACME01',
        deviceName: 'iPhone 15',
      );
      final json = req.toJson();
      expect(json['login'], 'EMP-0042');
      expect(json['company_code'], 'ACME01');
      expect(json['password'], 'Password123!');
      expect(json['device_name'], 'iPhone 15');
    });
  });

  // =========================================================================
  // 2. 2FA Challenge & Verification
  // =========================================================================
  group('2. 2FA Challenge & Verification', () {
    test('2FA required login response deserializes challenge', () {
      final json = {
        'data': {
          'two_factor_required': true,
          'challenge': 'test_64_character_challenge_token_string',
        }
      };
      final response = LoginResponseModel.fromJson(json);
      expect(response.twoFactorRequired, isTrue);
      expect(response.challenge, 'test_64_character_challenge_token_string');
      expect(response.token, isNull);
    });

    test('TwoFactorRequestModel serializes TOTP code', () {
      final req = TwoFactorRequestModel(
        challenge: 'test_challenge',
        code: '123456',
      );
      final json = req.toJson();
      expect(json['challenge'], 'test_challenge');
      expect(json['code'], '123456');
      expect(json.containsKey('recovery_code'), isFalse);
    });

    test('TwoFactorRequestModel serializes Recovery Code', () {
      final req = TwoFactorRequestModel(
        challenge: 'test_challenge',
        recoveryCode: 'ABCD-1234',
      );
      final json = req.toJson();
      expect(json['challenge'], 'test_challenge');
      expect(json['recovery_code'], 'ABCD-1234');
      expect(json.containsKey('code'), isFalse);
    });
  });

  // =========================================================================
  // 3. Biometric Unlock (Security Requirement 1)
  // =========================================================================
  group('3. Biometric Unlock (No Independent Session Creation)', () {
    test('Biometric unlock without active session halts and does not navigate', () async {
      await AppPreferences.clearSession();
      final mockRepo = MockAuthRepo(biometricSuccess: true);
      final controller = AuthController(repo: mockRepo);

      await controller.loginWithBiometrics();

      expect(AppPreferences.isLoggedIn, isFalse);
      expect(controller.authResponse.value, isNull);
    });

    test('Biometric unlock with unavailable hardware halts safely', () async {
      await AppPreferences.setToken('valid_stored_token');
      await AppPreferences.setIsLoggedIn(true);

      final mockRepo = MockAuthRepo(hardwareAvailable: false);
      final controller = AuthController(repo: mockRepo);

      await controller.loginWithBiometrics();
      expect(AppPreferences.token, 'valid_stored_token');
    });

    test('Biometric user cancellation or mismatch halts without creating session', () async {
      await AppPreferences.setToken('valid_stored_token');
      await AppPreferences.setIsLoggedIn(true);

      final mockRepo = MockAuthRepo(biometricSuccess: false);
      final controller = AuthController(repo: mockRepo);

      await controller.loginWithBiometrics();
      expect(AppPreferences.token, 'valid_stored_token');
    });

    test('Biometric unlock with expired backend session purges stored session', () async {
      await AppPreferences.setToken('expired_jwt_token');
      await AppPreferences.setIsLoggedIn(true);

      final mockIndexRepo = MockIndexRepoForAuth(mockMeResponse: null);
      Get.put<IndexRepo>(mockIndexRepo);

      final mockAuthRepo = MockAuthRepo(biometricSuccess: true);
      final controller = AuthController(repo: mockAuthRepo);

      await controller.loginWithBiometrics();

      // Session must be purged on expired token
      expect(AppPreferences.token, isNull);
      expect(AppPreferences.isLoggedIn, isFalse);
    });

    test('Biometric unlock with valid session verifies with /me successfully', () async {
      await AppPreferences.setToken('valid_jwt_token');
      await AppPreferences.setIsLoggedIn(true);

      final mockMe = MeResponseModel(
        user: const MeUser(id: '01jb', name: 'Valid User', email: 'v@a.pk', twoFactorEnabled: false),
        company: const MeCompany(id: '01jc', name: 'Acme', code: 'ACM123'),
        permissions: {},
        modules: ['core'],
        menu: [],
        badges: {},
      );
      final mockIndexRepo = MockIndexRepoForAuth(mockMeResponse: mockMe);
      Get.put<IndexRepo>(mockIndexRepo);

      final mockAuthRepo = MockAuthRepo(biometricSuccess: true);
      final controller = AuthController(repo: mockAuthRepo);

      await controller.loginWithBiometrics();

      expect(AppPreferences.isLoggedIn, isTrue);
      expect(mockIndexRepo.fetchMeCallCount, equals(1));
    });
  });

  // =========================================================================
  // 4. Token & Sensitive Secret Redaction in Logging (Security Requirement 2)
  // =========================================================================
  group('4. Sensitive Token Logging Redaction', () {
    test('Redacts Authorization header Bearer token', () {
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer 01jb2x9k4m7q8r3t5v6w8y0z1a_secret_jwt',
        'X-Device-Id': 'device_secret_uuid',
      };

      final sanitized = LogSanitizer.sanitizeHeaders(headers);
      expect(sanitized['Authorization'], 'Bearer [REDACTED]');
      expect(sanitized['X-Device-Id'], '[REDACTED]');
      expect(sanitized['Content-Type'], 'application/json');
    });

    test('Redacts password, codes, tokens, and challenges from map body', () {
      final body = {
        'login': 'user@acme.pk',
        'password': 'SuperSecretPassword!',
        'code': '654321',
        'recovery_code': 'REC-9999',
        'challenge': '64_char_raw_challenge_secret',
        'token': 'jwt_access_token_value',
        'refresh_token': 'jwt_refresh_token_value',
        'kiosk_token': 'kiosk_bearer_token',
        'pin': '1234',
        'face_embedding': [0.12, 0.45, 0.99],
        'device_name': 'Pixel 8',
      };

      final sanitized = LogSanitizer.sanitizeData(body) as Map;
      expect(sanitized['login'], 'user@acme.pk');
      expect(sanitized['password'], '[REDACTED]');
      expect(sanitized['code'], '[REDACTED]');
      expect(sanitized['recovery_code'], '[REDACTED]');
      expect(sanitized['challenge'], '[REDACTED]');
      expect(sanitized['token'], '[REDACTED]');
      expect(sanitized['refresh_token'], '[REDACTED]');
      expect(sanitized['kiosk_token'], '[REDACTED]');
      expect(sanitized['pin'], '[REDACTED]');
      expect(sanitized['face_embedding'], '[REDACTED]');
      expect(sanitized['device_name'], 'Pixel 8');
    });

    test('Redacts sensitive tokens from raw JSON string payload', () {
      const rawJson = '{"token":"secret_jwt_token_123","user":"Ayesha"}';
      final sanitized = LogSanitizer.sanitizeData(rawJson) as String;
      expect(sanitized.contains('secret_jwt_token_123'), isFalse);
      expect(sanitized.contains('[REDACTED]'), isTrue);
    });
  });

  // =========================================================================
  // 5. Secure Remember Me & XOR Removal (Security Requirement 3)
  // =========================================================================
  group('5. Platform Secure Storage & Insecure XOR Migration', () {
    test('saveRememberedCredentials persists password in secure storage, NOT GetStorage', () async {
      await AppPreferences.saveRememberedCredentials(
        login: 'ayesha@acme.pk',
        password: 'SecurePassword123!',
        companyCode: null,
        isEmployeeNumberMode: false,
      );

      // Verify GetStorage does NOT have plaintext or XOR password
      final box = GetStorage();
      expect(box.hasData('enc_saved_password'), isFalse);
      expect(box.read('enc_saved_password'), isNull);

      // Verify SecureStorage contains the credentials
      final secPass = await SecureStorageService.read('ams_sec_password');
      expect(secPass, 'SecurePassword123!');

      final creds = AppPreferences.getDecryptedCredentials();
      expect(creds?['login'], 'ayesha@acme.pk');
      expect(creds?['password'], 'SecurePassword123!');
      expect(AppPreferences.hasRememberedCredentials(), isTrue);
    });

    test('clearRememberedCredentials purges secure storage and metadata', () async {
      await AppPreferences.saveRememberedCredentials(
        login: 'EMP-001',
        password: 'Password999!',
        companyCode: 'ACM001',
        isEmployeeNumberMode: true,
      );

      await AppPreferences.clearRememberedCredentials();

      final secPass = await SecureStorageService.read('ams_sec_password');
      expect(secPass, isNull);
      expect(AppPreferences.hasRememberedCredentials(), isFalse);
      expect(AppPreferences.getDecryptedCredentials(), isNull);
    });

    test('Migration cleans legacy XOR credentials from GetStorage', () async {
      final box = GetStorage();

      // Inject legacy XOR ciphertext
      await box.write('enc_saved_login', 'ams_enc::legacyLoginCipher');
      await box.write('enc_saved_password', 'ams_enc::dummyCipher');

      // Initialize should trigger migration and purge
      await AppPreferences.init();

      // Legacy XOR keys must be purged from GetStorage
      expect(box.hasData('enc_saved_login'), isFalse);
      expect(box.hasData('enc_saved_password'), isFalse);
    });
  });

  // =========================================================================
  // 6. Logout Storage Cleanup & Kiosk Isolation (Security Requirement 4)
  // =========================================================================
  group('6. Logout Storage Cleanup & Kiosk Separation', () {
    test('clearSession clears session data while preserving device configuration & theme', () async {
      // Set non-sensitive preferences
      await AppPreferences.setDarkMode(true);
      await AppPreferences.setDeviceName('Pixel 8 Pro');
      await AppPreferences.setSavedEmail('user@acme.pk');
      await AppPreferences.setKioskToken('kiosk_permanent_token_999');

      // Set session data
      await AppPreferences.setToken('auth_bearer_token');
      await AppPreferences.setIsLoggedIn(true);
      await AppPreferences.setUser({'id': '01jb', 'name': 'Test User'});
      await AppPreferences.setPermissions({'support.raise': null});

      // Execute personal logout
      await AppPreferences.clearSession();

      // Session data MUST be purged
      expect(AppPreferences.token, isNull);
      expect(AppPreferences.isLoggedIn, isFalse);
      expect(AppPreferences.user, isNull);
      expect(AppPreferences.permissions, isNull);

      // Non-sensitive preferences MUST be preserved
      expect(AppPreferences.isDarkMode, isTrue);
      expect(AppPreferences.deviceName, 'Pixel 8 Pro');
      expect(AppPreferences.savedEmail, 'user@acme.pk');

      // Kiosk provision token MUST be preserved across personal logout
      expect(AppPreferences.kioskToken, 'kiosk_permanent_token_999');
      expect(AppPreferences.isKioskProvisioned, isTrue);
    });

    test('clearKioskSession purges only kiosk credentials', () async {
      await AppPreferences.setToken('personal_auth_token');
      await AppPreferences.setIsLoggedIn(true);
      await AppPreferences.setKioskToken('kiosk_terminal_token_123');
      await AppPreferences.setKioskConfig({'name': 'Lobby Terminal'});

      await AppPreferences.clearKioskSession();

      // Kiosk data purged
      expect(AppPreferences.kioskToken, isNull);
      expect(AppPreferences.kioskConfig, isNull);
      expect(AppPreferences.isKioskProvisioned, isFalse);

      // Personal session preserved
      expect(AppPreferences.token, 'personal_auth_token');
      expect(AppPreferences.isLoggedIn, isTrue);
    });
  });

  // =========================================================================
  // 7. Permission Value Semantics & Scope Hierarchy (Requirements 5 & 9)
  // =========================================================================
  group('7. Permission Value Semantics & Scope Evaluation', () {
    test('Distinguishes binary null permissions from scoped permissions', () async {
      final json = {
        'data': {
          'user': {'id': '01jb', 'name': 'Ayesha', 'email': 'a@a.pk'},
          'company': {'id': '01jc', 'name': 'Acme', 'code': 'ACME'},
          'permissions': {
            'support.raise': null, // Binary allowed
            'employees.view': ['department', 'own'], // Scoped
            'empty.scope.list': [], // Empty scoped list -> Denied
          },
          'modules': ['core'],
          'menu': [],
          'badges': {},
        }
      };

      final model = MeResponseModel.fromJson(json);
      expect(model.permissions['support.raise'], isNull); // Kept null!
      expect(model.permissions['employees.view'], equals(['department', 'own']));
      expect(model.permissions['empty.scope.list'], isEmpty);

      await AppPreferences.setPermissions(model.permissions);

      // Missing permission
      expect(AppPreferences.hasPermission('non_existent_key'), isFalse);

      // Binary permission granted (null value)
      expect(AppPreferences.hasPermission('support.raise'), isTrue);

      // Empty scoped list is DENIED
      expect(AppPreferences.hasPermission('empty.scope.list'), isFalse);
    });

    test('Evaluates hierarchical scope inheritance: company > location > department > own', () async {
      // 1. Company scope grants all lower scopes
      await AppPreferences.setPermissions({
        'employees.view': ['company'],
      });
      expect(AppPreferences.hasPermission('employees.view', 'company'), isTrue);
      expect(AppPreferences.hasPermission('employees.view', 'location'), isTrue);
      expect(AppPreferences.hasPermission('employees.view', 'department'), isTrue);
      expect(AppPreferences.hasPermission('employees.view', 'own'), isTrue);

      // 2. Location scope grants department and own, but NOT company
      await AppPreferences.setPermissions({
        'employees.view': ['location'],
      });
      expect(AppPreferences.hasPermission('employees.view', 'company'), isFalse);
      expect(AppPreferences.hasPermission('employees.view', 'location'), isTrue);
      expect(AppPreferences.hasPermission('employees.view', 'department'), isTrue);
      expect(AppPreferences.hasPermission('employees.view', 'own'), isTrue);

      // 3. Department scope grants own, but NOT location or company
      await AppPreferences.setPermissions({
        'employees.view': ['department'],
      });
      expect(AppPreferences.hasPermission('employees.view', 'company'), isFalse);
      expect(AppPreferences.hasPermission('employees.view', 'location'), isFalse);
      expect(AppPreferences.hasPermission('employees.view', 'department'), isTrue);
      expect(AppPreferences.hasPermission('employees.view', 'own'), isTrue);

      // 4. Own scope grants only own
      await AppPreferences.setPermissions({
        'employees.view': ['own'],
      });
      expect(AppPreferences.hasPermission('employees.view', 'company'), isFalse);
      expect(AppPreferences.hasPermission('employees.view', 'location'), isFalse);
      expect(AppPreferences.hasPermission('employees.view', 'department'), isFalse);
      expect(AppPreferences.hasPermission('employees.view', 'own'), isTrue);
    });
  });

  // =========================================================================
  // 8. /me Refresh, App Lifecycle & Concurrency (Requirements 6 & 10)
  // =========================================================================
  group('8. /me Lifecycle Refresh & Failure Handling', () {
    test('Concurrent fetchMe calls are deduplicated into single request', () async {
      final mockMe = MeResponseModel(
        user: const MeUser(id: '01jb', name: 'User 1', email: 'u@a.pk', twoFactorEnabled: false),
        company: const MeCompany(id: '01jc', name: 'Acme', code: 'ACME'),
        permissions: {},
        modules: ['core'],
        menu: [],
        badges: {},
      );
      final repo = MockIndexRepoForAuth(mockMeResponse: mockMe);
      repo.delay = const Duration(milliseconds: 50);

      final controller = IndexController(repo: repo);

      // Dispatch 3 concurrent fetchMe requests
      final f1 = controller.fetchMe();
      final f2 = controller.fetchMe();
      final f3 = controller.fetchMe();

      await Future.wait([f1, f2, f3]);

      // Deduplication ensures only 1 HTTP request executed
      expect(repo.fetchMeCallCount, equals(1));
      expect(controller.isPermissionsFresh.value, isTrue);
    });

    test('didChangeAppLifecycleState(resumed) triggers /me refresh', () async {
      final mockMe = MeResponseModel(
        user: const MeUser(id: '01jb', name: 'User 1', email: 'u@a.pk', twoFactorEnabled: false),
        company: const MeCompany(id: '01jc', name: 'Acme', code: 'ACME'),
        permissions: {},
        modules: ['core'],
        menu: [],
        badges: {},
      );
      final repo = MockIndexRepoForAuth(mockMeResponse: mockMe);
      final controller = IndexController(repo: repo);
      await controller.fetchMe();

      final initialCalls = repo.fetchMeCallCount;

      controller.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await Future.delayed(const Duration(milliseconds: 10));

      expect(repo.fetchMeCallCount, equals(initialCalls + 1));
    });

    test('Handles /me network error with stale cache indicator without crash', () async {
      await AppPreferences.setToken('stored_token');
      await AppPreferences.setIsLoggedIn(true);

      final repo = MockIndexRepoForAuth(mockMeResponse: null);
      final controller = IndexController(repo: repo);

      await controller.fetchMe();

      expect(controller.isPermissionsFresh.value, isFalse);
      expect(controller.isOfflineMode.value, isTrue);
      expect(controller.sessionErrorMessage.value, contains('Offline'));
    });
  });

  // =========================================================================
  // 9. Server-Driven Dynamic Navigation (Requirement 7)
  // =========================================================================
  group('9. Server-Driven Navigation', () {
    test('Dynamic tabs select exactly home, attendance, requests, profile in standard order', () async {
      await AppPreferences.setPermissions({'attendance.view': ['own']});

      final repo = MockIndexRepoForAuth();
      final controller = IndexController(repo: repo);

      // Server sends menu containing requests, home, etc.
      controller.dynamicMenu.assignAll([
        const MeMenuItem(key: 'requests', label: 'My Requests', icon: 'inbox', module: 'core'),
        const MeMenuItem(key: 'home', label: 'Dashboard', icon: 'home', module: 'core'),
        const MeMenuItem(key: 'attendance', label: 'Attendance', icon: 'calendar', module: 'core'),
      ]);

      controller.refreshDynamicTabs();

      // Exactly home, attendance, requests, profile
      expect(controller.navTabs.length, equals(4));
      expect(controller.navTabs[0].id, equals('home'));
      expect(controller.navTabs[1].id, equals('attendance'));
      expect(controller.navTabs[2].id, equals('requests'));
      expect(controller.navTabs[3].id, equals('profile'));
    });

    test('Empty menu produces empty navTabs with zero default items', () {
      final repo = MockIndexRepoForAuth();
      final controller = IndexController(repo: repo);

      controller.dynamicMenu.clear();
      controller.refreshDynamicTabs();

      expect(controller.navTabs, isEmpty);
    });

    test('Dynamic tabs pick best 4 options: home, attendance, requests, profile (schedule excluded)', () async {
      await AppPreferences.setPermissions({'attendance.view': ['own']});

      final repo = MockIndexRepoForAuth();
      final controller = IndexController(repo: repo);

      // Server sends 7 menu items (including schedule, but no profile)
      controller.dynamicMenu.assignAll([
        const MeMenuItem(key: 'home', label: 'Dashboard', icon: 'home', module: 'core'),
        const MeMenuItem(key: 'requests', label: 'My Requests', icon: 'inbox', module: 'core'),
        const MeMenuItem(key: 'news', label: 'News', icon: 'campaign', module: 'core'),
        const MeMenuItem(key: 'attendance', label: 'Attendance', icon: 'calendar', module: 'core'),
        const MeMenuItem(key: 'schedule', label: 'Schedule', icon: 'schedule', module: 'core'),
        const MeMenuItem(key: 'assets', label: 'Assets', icon: 'inventory', module: 'core'),
        const MeMenuItem(key: 'training', label: 'Training', icon: 'school', module: 'core'),
      ]);

      controller.refreshDynamicTabs();

      // Exactly 4 tabs selected in standard order:
      // 1. home (Dashboard)
      // 2. attendance (Punch logs & timesheets)
      // 3. requests (Approvals & requests inbox)
      // 4. profile (Employee Profile - schedule excluded!)
      expect(controller.navTabs.length, equals(4));
      expect(controller.navTabs[0].id, equals('home'));
      expect(controller.navTabs[1].id, equals('attendance'));
      expect(controller.navTabs[2].id, equals('requests'));
      expect(controller.navTabs[3].id, equals('profile'));

      // Test openTabByKey helper
      expect(controller.openTabByKey('attendance'), isTrue);
      expect(controller.currentIndex.value, equals(1));
      expect(controller.openTabByKey('news'), isFalse); // not in bottom nav
    });

    test('Dynamic tabs prefer profile over schedule and place profile at last index', () async {
      await AppPreferences.setPermissions({'attendance.view': ['own']});

      final repo = MockIndexRepoForAuth();
      final controller = IndexController(repo: repo);

      // Server sends menu containing schedule and profile
      controller.dynamicMenu.assignAll([
        const MeMenuItem(key: 'home', label: 'Dashboard', icon: 'home', module: 'core'),
        const MeMenuItem(key: 'requests', label: 'My Requests', icon: 'inbox', module: 'core'),
        const MeMenuItem(key: 'attendance', label: 'Attendance', icon: 'calendar', module: 'core'),
        const MeMenuItem(key: 'schedule', label: 'Schedule', icon: 'schedule', module: 'core'),
        const MeMenuItem(key: 'profile', label: 'Profile', icon: 'person', module: 'core'),
        const MeMenuItem(key: 'payroll', label: 'Payroll', icon: 'payments', module: 'core'),
      ]);

      controller.refreshDynamicTabs();

      // Exactly 4 tabs selected
      expect(controller.navTabs.length, equals(4));
      expect(controller.navTabs[0].id, equals('home'));
      expect(controller.navTabs[1].id, equals('attendance'));
      expect(controller.navTabs[2].id, equals('requests'));
      expect(controller.navTabs[3].id, equals('profile'));
    });

    test('Unknown menu key is handled safely with placeholder view without crashing', () {
      final repo = MockIndexRepoForAuth();
      final controller = IndexController(repo: repo);

      controller.dynamicMenu.assignAll([
        const MeMenuItem(key: 'future_beta_tool', label: 'AI Suite', icon: 'sparkles', module: 'core'),
      ]);

      controller.refreshDynamicTabs();

      expect(controller.navTabs.any((t) => t.id == 'future_beta_tool'), isTrue);
      final unknownTab = controller.navTabs.firstWhere((t) => t.id == 'future_beta_tool');
      expect(unknownTab.buildWidget(), isA<Widget>());
    });
  });

  // =========================================================================
  // 10. Route Access Security & Unauthorized Direct Navigation
  // =========================================================================
  group('10. Route Access Guard Middleware', () {
    test('Unauthenticated user is redirected to LOGIN', () {
      final guard = AuthGuardMiddleware();
      final redirect = guard.redirect(Routes.INDEX);
      expect(redirect?.name, equals(Routes.LOGIN));
    });

    test('Authenticated user with valid session passes through', () async {
      await AppPreferences.setToken('valid_token');
      await AppPreferences.setIsLoggedIn(true);

      final guard = AuthGuardMiddleware();
      final redirect = guard.redirect(Routes.INDEX);
      expect(redirect, isNull);
    });

    test('Direct navigation to unsubscribed module is blocked and redirected to INDEX', () async {
      await AppPreferences.setToken('valid_token');
      await AppPreferences.setIsLoggedIn(true);
      await AppPreferences.setModules(['core']); // 'payroll' missing

      final guard = AuthGuardMiddleware(requiredModule: 'payroll');
      final redirect = guard.redirect(Routes.PAYROLL);
      expect(redirect?.name, equals(Routes.INDEX));
    });

    test('Direct navigation without required permission is blocked and redirected to INDEX', () async {
      await AppPreferences.setToken('valid_token');
      await AppPreferences.setIsLoggedIn(true);
      await AppPreferences.setModules(['core', 'payroll']);
      await AppPreferences.setPermissions({}); // 'pay.view' missing

      final guard = AuthGuardMiddleware(
        requiredModule: 'payroll',
        requiredPermission: 'pay.view',
      );
      final redirect = guard.redirect(Routes.PAYROLL);
      expect(redirect?.name, equals(Routes.INDEX));
    });

    test('Direct navigation with valid permission and module is permitted', () async {
      await AppPreferences.setToken('valid_token');
      await AppPreferences.setIsLoggedIn(true);
      await AppPreferences.setModules(['core', 'payroll']);
      await AppPreferences.setPermissions({'pay.view': ['own']});

      final guard = AuthGuardMiddleware(
        requiredModule: 'payroll',
        requiredPermission: 'pay.view',
      );
      final redirect = guard.redirect(Routes.PAYROLL);
      expect(redirect, isNull);
    });
  });
}
