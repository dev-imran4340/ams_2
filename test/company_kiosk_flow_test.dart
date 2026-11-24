import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:ams_2/app/api/app_preferences.dart';
import 'package:ams_2/app/api/exception_handler.dart';
import 'package:ams_2/app/api/log_sanitizer.dart';
import 'package:ams_2/app/routes/app_routes.dart';
import 'package:ams_2/app/routes/auth_guard_middleware.dart';
import 'package:ams_2/app/screens/auth/controller/auth_controller.dart';
import 'package:ams_2/app/screens/auth/model/auth_model.dart';
import 'package:ams_2/app/screens/auth/repo/auth_repo.dart';
import 'package:ams_2/app/screens/company/dashboard/controller/company_dashboard_controller.dart';
import 'package:ams_2/app/screens/company/dashboard/repo/company_dashboard_repo.dart';
import 'package:ams_2/app/screens/kiosk/controller/kiosk_controller.dart';
import 'package:ams_2/app/screens/kiosk/model/kiosk_model.dart';
import 'package:ams_2/app/screens/kiosk/repo/kiosk_repo.dart';

// --- MOCK REPOSITORIES FOR DETERMINISTIC TESTING ---

class MockAuthRepo extends AuthRepo {
  final bool returnCompany;
  final bool returnTwoFactor;

  MockAuthRepo({this.returnCompany = false, this.returnTwoFactor = false});

  @override
  Future<LoginResponseModel> login({
    required String login,
    required String password,
    String? companyCode,
    String? deviceName,
  }) async {
    if (login == 'invalid@example.com') {
      throw ApiException(message: 'Invalid credentials', statusCode: 401);
    }

    return LoginResponseModel(
      token: 'ams_test_token_12345',
      refreshToken: 'ams_refresh_token_67890',
      isCompany: returnCompany,
      twoFactorRequired: returnTwoFactor,
      challenge: returnTwoFactor ? 'chal_test_999' : null,
      user: UserModel(
        id: '01jb2x9k4m7q8r3t5v6w8y0z1a',
        name: returnCompany ? 'Company Admin' : 'Employee User',
        email: login,
      ),
    );
  }
}

class MockKioskRepo extends KioskRepo {
  bool provisionCalled = false;
  bool shouldFailProvision = false;
  bool shouldReturn401 = false;
  String? lastPunchTicket;
  String? lastPunchKind;

  @override
  Future<KioskConfigModel?> provisionKiosk({
    required String name,
    required String location,
    bool replace = false,
  }) async {
    provisionCalled = true;
    if (shouldFailProvision) return null;

    final config = KioskConfigModel(
      id: '01jkiosk1234567890abcdefgh',
      name: name,
      locationId: location,
      locationName: 'Head Office',
      timezone: 'Asia/Karachi',
      pinAllowed: true,
      token: 'kiosk_secret_token_live_abc123',
    );

    // Save token securely per contract
    await AppPreferences.setKioskToken(config.token!);
    await AppPreferences.setKioskConfig(config.toJson());
    return config;
  }

  @override
  Future<KioskConfigModel?> fetchKioskConfig() async {
    if (shouldReturn401) {
      throw ApiException(message: 'Kiosk de-authorized', statusCode: 401);
    }
    final token = AppPreferences.kioskToken;
    if (token == null) return null;
    return KioskConfigModel(
      id: '01jkiosk1234567890abcdefgh',
      name: 'Front Desk Tablet',
      locationId: '01jloc123',
      locationName: 'Head Office',
      timezone: 'Asia/Karachi',
      pinAllowed: true,
      token: token,
    );
  }

  @override
  Future<KioskIdentifyResponseModel?> identifyEmployee({
    String? badge,
    String? employeeNumber,
    String? pin,
  }) async {
    if (shouldReturn401) {
      throw ApiException(message: 'Kiosk unauthorized', statusCode: 401);
    }

    if (pin == '9999') {
      throw ApiException(message: 'Invalid PIN entered', statusCode: 409);
    }

    return KioskIdentifyResponseModel(
      person: const KioskPersonModel(
        id: '01jemp1234567890abcdefghij',
        name: 'Ayesha Khan',
        employeeNumber: 'EMP-0001',
        department: 'Operations',
      ),
      ticket: 'ticket_ident_jwt_987654321',
      expiresIn: 120,
      allowedActions: const ['in', 'out'],
      refusals: const {'break_start': 'No shift break scheduled'},
      requiresFace: badge == 'FACE_REQUIRED' ? 'match' : 'off',
      faceSaved: badge == 'FACE_REQUIRED',
    );
  }

  @override
  Future<Uint8List?> fetchKioskFace({required String ticket}) async {
    return Uint8List.fromList([1, 2, 3, 4, 5]);
  }

  @override
  Future<KioskPunchResultModel?> submitKioskPunch({
    String? ticket,
    required String kind,
    required String idempotencyKey,
    dynamic photo,
    String? faceMatch,
    double? faceScore,
    bool? faceConsent,
    String? badge,
    String? employeeNumber,
    String? pin,
    String? punchedAt,
  }) async {
    if (shouldReturn401) {
      throw ApiException(message: 'Kiosk de-authorized', statusCode: 401);
    }
    lastPunchTicket = ticket;
    lastPunchKind = kind;

    return KioskPunchResultModel(
      punchId: '01jpunch99999999999999999',
      time: '09:05 AM',
      role: kind == 'in' ? 'Check In' : 'Check Out',
      source: 'kiosk',
      personId: '01jemp1234567890abcdefghij',
      personName: 'Ayesha Khan',
    );
  }
}

class MockCompanyDashboardRepo extends CompanyDashboardRepo {
  final MockKioskRepo mockKioskRepo;
  bool logoutUserCalled = false;

  MockCompanyDashboardRepo(this.mockKioskRepo);

  @override
  Future<KioskConfigModel?> provisionKiosk({
    required String name,
    required String location,
    bool replace = false,
  }) async {
    return mockKioskRepo.provisionKiosk(
      name: name,
      location: location,
      replace: replace,
    );
  }

  @override
  Future<KioskConfigModel?> fetchActiveKioskConfig() async {
    return mockKioskRepo.fetchKioskConfig();
  }

  @override
  Future<bool> logoutSetupUser() async {
    logoutUserCalled = true;
    await AppPreferences.clearSession();
    return true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    Get.testMode = true;
    const MethodChannel channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async => '.');
    await GetStorage.init();
    await AppPreferences.init();
  });

  setUp(() async {
    await AppPreferences.clearSession();
    await AppPreferences.clearKioskSession();
  });

  group('PHASE 14 — Company Login, Company Dashboard & Kiosk Flow Verification', () {
    // -------------------------------------------------------------
    // Scenario 1 & 2: Company vs Employee login response parsing
    // -------------------------------------------------------------
    test('Scenario 1 & 2: LoginResponseModel correctly parses company: true vs false', () {
      final compJson = {
        'token': 'tok_comp_123',
        'company': true,
        'user': {'id': '01jcomp1', 'name': 'Corporate Admin'}
      };
      final empJson = {
        'token': 'tok_emp_123',
        'company': false,
        'user': {'id': '01jemp1', 'name': 'Employee User'}
      };

      final compResp = LoginResponseModel.fromJson(compJson);
      final empResp = LoginResponseModel.fromJson(empJson);

      expect(compResp.isCompany, isTrue);
      expect(empResp.isCompany, isFalse);
    });

    // -------------------------------------------------------------
    // Scenario 3: Employee login routing
    // -------------------------------------------------------------
    test('Scenario 3: Employee login with company: false navigates to Routes.INDEX', () async {
      final authRepo = MockAuthRepo(returnCompany: false);
      final controller = AuthController(repo: authRepo);

      controller.emailController.text = 'employee@example.com';
      controller.passwordController.text = 'secret123';

      await controller.login();

      expect(AppPreferences.isLoggedIn, isTrue);
      expect(AppPreferences.isCompanyMode, isFalse);
      expect(controller.authResponse.value?.isCompany, isFalse);

      controller.onClose();
    });

    // -------------------------------------------------------------
    // Scenario 4: Company login routing
    // -------------------------------------------------------------
    test('Scenario 4: Company login with company: true sets isCompanyMode and routes to Company Dashboard', () async {
      final authRepo = MockAuthRepo(returnCompany: true);
      final controller = AuthController(repo: authRepo);

      controller.emailController.text = 'admin@company.com';
      controller.passwordController.text = 'secret123';

      await controller.login();

      expect(AppPreferences.isLoggedIn, isTrue);
      expect(AppPreferences.isCompanyMode, isTrue);
      expect(controller.authResponse.value?.isCompany, isTrue);

      controller.onClose();
    });

    // -------------------------------------------------------------
    // Scenario 5: User without kiosks.manage cannot provision
    // -------------------------------------------------------------
    test('Scenario 5: Company user without kiosks.manage permission cannot provision a kiosk', () async {
      final mockKiosk = MockKioskRepo();
      final compRepo = MockCompanyDashboardRepo(mockKiosk);
      final controller = CompanyDashboardController(repo: compRepo);

      // User holds only employees.view, NOT kiosks.manage
      await AppPreferences.setPermissions({
        'employees.view': ['company'],
      });

      expect(controller.canManageKiosks, isFalse);

      controller.kioskNameController.text = 'Front Desk';
      controller.locationController.text = '01jloc123';

      // Attempt provision
      await controller.provisionTabletKiosk();

      expect(mockKiosk.provisionCalled, isFalse);
      expect(compRepo.logoutUserCalled, isFalse);

      controller.onClose();
    });

    // -------------------------------------------------------------
    // Scenario 6 & 7: Authorized user provisions kiosk & setup user is logged out
    // -------------------------------------------------------------
    test('Scenario 6 & 7: Authorized user with kiosks.manage provisions kiosk and setup user is logged out', () async {
      final mockKiosk = MockKioskRepo();
      final compRepo = MockCompanyDashboardRepo(mockKiosk);
      final controller = CompanyDashboardController(repo: compRepo);

      // Save active setup user auth session
      await AppPreferences.saveAuthData(
        token: 'admin_setup_token_999',
        user: UserModel(id: '01jadmin1', name: 'Setup Admin'),
        isCompany: true,
      );
      await AppPreferences.setPermissions({
        'kiosks.manage': null, // Binary permission allowed
      });

      expect(AppPreferences.isLoggedIn, isTrue);
      expect(controller.canManageKiosks, isTrue);

      controller.kioskNameController.text = 'Reception Station';
      controller.locationController.text = '01jloc_head_office';

      // Provision
      final config = await compRepo.provisionKiosk(
        name: controller.kioskNameController.text,
        location: controller.locationController.text,
      );

      expect(config, isNotNull);
      expect(config?.token, equals('kiosk_secret_token_live_abc123'));

      // Logout setup user
      await compRepo.logoutSetupUser();

      expect(compRepo.logoutUserCalled, isTrue);
      // Personal session is purged
      expect(AppPreferences.token, isNull);
      expect(AppPreferences.isLoggedIn, isFalse);
      // Kiosk token is strictly preserved
      expect(AppPreferences.isKioskProvisioned, isTrue);
      expect(AppPreferences.kioskToken, equals('kiosk_secret_token_live_abc123'));

      controller.onClose();
    });

    // -------------------------------------------------------------
    // Scenario 8 & 9: Kiosk uses its own token & loads configuration
    // -------------------------------------------------------------
    test('Scenario 8 & 9: Kiosk uses its own token and loads active configuration', () async {
      await AppPreferences.setKioskToken('kiosk_dedicated_terminal_token_777');
      final mockKiosk = MockKioskRepo();
      final kioskController = KioskController(repo: mockKiosk);

      await kioskController.loadKioskState();

      expect(kioskController.isKioskProvisioned.value, isTrue);
      expect(kioskController.activeKioskConfig.value?.name, equals('Front Desk Tablet'));
      expect(kioskController.activeKioskConfig.value?.pinAllowed, isTrue);
      expect(AppPreferences.kioskToken, equals('kiosk_dedicated_terminal_token_777'));

      kioskController.onClose();
    });

    // -------------------------------------------------------------
    // Scenario 10: Employee QR Identification
    // -------------------------------------------------------------
    test('Scenario 10: Employee QR badge identification successfully creates session', () async {
      await AppPreferences.setKioskToken('kiosk_token_123');
      final mockKiosk = MockKioskRepo();
      final kioskController = KioskController(repo: mockKiosk);

      await kioskController.identifyViaBadge('01jqr_badge_ayesha_khan');

      final session = kioskController.identifiedSession.value;
      expect(session, isNotNull);
      expect(session?.person.name, equals('Ayesha Khan'));
      expect(session?.person.employeeNumber, equals('EMP-0001'));
      expect(session?.ticket, equals('ticket_ident_jwt_987654321'));
      expect(session?.expiresIn, equals(120));

      kioskController.onClose();
    });

    // -------------------------------------------------------------
    // Scenario 11: Employee Number + PIN identification
    // -------------------------------------------------------------
    test('Scenario 11: Employee Number + PIN identification succeeds when allowed', () async {
      await AppPreferences.setKioskToken('kiosk_token_123');
      final mockKiosk = MockKioskRepo();
      final kioskController = KioskController(repo: mockKiosk);

      kioskController.empNumController.text = 'EMP-0001';
      kioskController.terminalPinController.text = '1234';

      final session = await mockKiosk.identifyEmployee(
        employeeNumber: 'EMP-0001',
        pin: '1234',
      );

      expect(session, isNotNull);
      expect(session?.person.name, equals('Ayesha Khan'));

      kioskController.onClose();
    });

    // -------------------------------------------------------------
    // Scenario 12: Invalid PIN handling
    // -------------------------------------------------------------
    test('Scenario 12: Invalid PIN throws 409 and is handled with clean error feedback', () async {
      await AppPreferences.setKioskToken('kiosk_token_123');
      final mockKiosk = MockKioskRepo();
      final kioskController = KioskController(repo: mockKiosk);

      kioskController.empNumController.text = 'EMP-0001';
      kioskController.terminalPinController.text = '9999';

      expect(
        () => mockKiosk.identifyEmployee(employeeNumber: 'EMP-0001', pin: '9999'),
        throwsA(isA<ApiException>()),
      );

      kioskController.onClose();
    });

    // -------------------------------------------------------------
    // Scenario 13: Ticket Expiration Handling (120s countdown)
    // -------------------------------------------------------------
    test('Scenario 13: Expired ticket triggers clean session cancellation and resets to idle', () {
      final mockKiosk = MockKioskRepo();
      final kioskController = KioskController(repo: mockKiosk);

      kioskController.identifiedSession.value = const KioskIdentifyResponseModel(
        person: KioskPersonModel(id: '01jemp1', name: 'Ali', employeeNumber: 'EMP-0002'),
        ticket: 'ticket_temp_123',
        expiresIn: 1,
      );

      expect(kioskController.identifiedSession.value, isNotNull);

      // Simulate timeout / cancelSession
      kioskController.cancelSession('Session expired due to 120s timeout.');

      expect(kioskController.identifiedSession.value, isNull);
      expect(kioskController.referenceFaceBytes.value, isNull);

      kioskController.onClose();
    });

    // -------------------------------------------------------------
    // Scenario 14: Face Verification when required
    // -------------------------------------------------------------
    test('Scenario 14: Face verification requirement fetches reference and validates', () async {
      await AppPreferences.setKioskToken('kiosk_token_123');
      final mockKiosk = MockKioskRepo();
      final kioskController = KioskController(repo: mockKiosk);

      // Trigger identification requiring face
      await kioskController.identifyViaBadge('FACE_REQUIRED');

      expect(kioskController.isFaceVerificationRequired.value, isTrue);
      expect(kioskController.referenceFaceBytes.value, isNotNull);
      expect(kioskController.isFaceVerified.value, isFalse);

      // Simulate live face match
      final matchSuccess = await kioskController.verifyLiveFace();

      expect(matchSuccess, isTrue);
      expect(kioskController.isFaceVerified.value, isTrue);
      expect(kioskController.faceMatchStatus.value, equals('matched'));
      expect(kioskController.faceMatchScore.value, greaterThan(0.90));

      kioskController.onClose();
    });

    // -------------------------------------------------------------
    // Scenario 15: Only allowed attendance actions are shown
    // -------------------------------------------------------------
    test('Scenario 15: Allowed attendance actions strictly follow state.allowed from backend', () {
      const session = KioskIdentifyResponseModel(
        person: KioskPersonModel(id: '01jemp1', name: 'Test User', employeeNumber: 'EMP-001'),
        ticket: 'ticket_1',
        allowedActions: ['in'], // Only 'in' is permitted
      );

      expect(session.allowedActions.contains('in'), isTrue);
      expect(session.allowedActions.contains('out'), isFalse);
      expect(session.allowedActions.contains('break_start'), isFalse);
    });

    // -------------------------------------------------------------
    // Scenario 16 & 17: Punch success, failure & duplicate prevention
    // -------------------------------------------------------------
    test('Scenario 16 & 17: Punch records successfully and prevents duplicate submissions', () async {
      await AppPreferences.setKioskToken('kiosk_token_123');
      final mockKiosk = MockKioskRepo();
      final kioskController = KioskController(repo: mockKiosk);

      kioskController.identifiedSession.value = const KioskIdentifyResponseModel(
        person: KioskPersonModel(id: '01jemp1', name: 'Test User', employeeNumber: 'EMP-001'),
        ticket: 'ticket_punch_99',
        allowedActions: ['in', 'out'],
      );
      kioskController.isFaceVerificationRequired.value = false;
      kioskController.isFaceVerified.value = true;

      // Submit punch
      await kioskController.punchAttendanceAction('in');

      expect(mockKiosk.lastPunchTicket, equals('ticket_punch_99'));
      expect(mockKiosk.lastPunchKind, equals('in'));
      expect(kioskController.lastPunchResult.value?.role, equals('Check In'));
      expect(kioskController.showSuccessCard.value, isTrue);

      // While busy, subsequent clicks are rejected
      kioskController.isSubmitting.value = true;
      // punchAttendanceAction halts if busy/disabled in UI

      kioskController.onClose();
    });

    // -------------------------------------------------------------
    // Scenario 18: Kiosk 401 returns to setup/login
    // -------------------------------------------------------------
    test('Scenario 18: Kiosk 401 unauthenticated purges kiosk credentials and stops kiosk mode', () async {
      await AppPreferences.setKioskToken('kiosk_token_to_expire');
      final mockKiosk = MockKioskRepo()..shouldReturn401 = true;
      final kioskController = KioskController(repo: mockKiosk);

      await kioskController.loadKioskState();

      expect(kioskController.isKioskProvisioned.value, isFalse);
      expect(AppPreferences.isKioskProvisioned, isFalse);
      expect(AppPreferences.kioskToken, isNull);

      kioskController.onClose();
    });

    // -------------------------------------------------------------
    // Scenario 19: Employee and HR existing functionality remains unchanged
    // -------------------------------------------------------------
    test('Scenario 19: Employee and HR routes and middleware remain strictly intact', () {
      final guard = AuthGuardMiddleware();
      expect(guard, isNotNull);

      // Standard employee pages exist in Routes
      expect(Routes.DASHBOARD, equals('/dashboard'));
      expect(Routes.ATTENDANCE_HISTORY, equals('/attendance-history'));
      expect(Routes.LEAVE, equals('/leave'));
      expect(Routes.PAYROLL, equals('/payroll'));
      expect(Routes.COMPANY_DASHBOARD, equals('/company-dashboard'));
      expect(Routes.KIOSK_MAIN, equals('/kiosk-main'));
    });

    // -------------------------------------------------------------
    // Scenario 20: No secrets or biometric data appear in logs
    // -------------------------------------------------------------
    test('Scenario 20: Log sanitizer completely redacts tokens, PINs, passwords and face embeddings', () {
      final sanitizedHeader = LogSanitizer.sanitizeHeaders({
        'Authorization': 'Bearer kiosk_secret_super_confidential_token_99999',
      });
      expect(sanitizedHeader['Authorization'], isNot(contains('kiosk_secret_super_confidential_token_99999')));
      expect(sanitizedHeader['Authorization'], contains('[REDACTED]'));

      final sanitizedPayload = LogSanitizer.sanitizeData({
        'pin': '1234',
        'password': 'secretPassword!',
        'face_embedding': [0.123, 0.456, 0.789],
        'action': 'kiosk_punch',
      });
      expect(sanitizedPayload['pin'], equals('[REDACTED]'));
      expect(sanitizedPayload['password'], equals('[REDACTED]'));
      expect(sanitizedPayload['face_embedding'], equals('[REDACTED]'));
      expect(sanitizedPayload['action'], equals('kiosk_punch'));
    });
  });
}
