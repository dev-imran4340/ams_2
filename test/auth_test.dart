import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ams_2/app/screens/auth/model/auth_model.dart';
import 'package:ams_2/app/screens/auth/controller/auth_controller.dart';
import 'package:ams_2/app/screens/auth/repo/auth_repo.dart';
import 'package:ams_2/app/api/app_preferences.dart';

import 'package:flutter/services.dart';

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

  group('Authentication Models Tests (Phase 7 Specs)', () {
    test('LoginRequestModel serializes correctly for Email mode', () {
      final request = LoginRequestModel(
        login: 'ayesha@acme.pk',
        password: 'SecurePassword123!',
        deviceName: 'Pixel 8 – Android 15',
      );

      final json = request.toJson();
      expect(json['login'], 'ayesha@acme.pk');
      expect(json['password'], 'SecurePassword123!');
      expect(json['device_name'], 'Pixel 8 – Android 15');
      expect(json.containsKey('company_code'), isFalse);
    });

    test('LoginRequestModel serializes correctly for Employee ID mode', () {
      final request = LoginRequestModel(
        login: 'EMP-0001',
        password: 'SecurePassword123!',
        companyCode: 'K7MP2Q',
        deviceName: 'iPhone 15 Pro – iOS 18',
      );

      final json = request.toJson();
      expect(json['login'], 'EMP-0001');
      expect(json['password'], 'SecurePassword123!');
      expect(json['company_code'], 'K7MP2Q');
      expect(json['device_name'], 'iPhone 15 Pro – iOS 18');
    });

    test('LoginResponseModel parses direct login (2FA disabled)', () {
      final json = {
        'data': {
          'two_factor_required': false,
          'token': '01jb2x9k4m7q8r3t5v6w8y0z1a_jwt_token',
        }
      };

      final response = LoginResponseModel.fromJson(json);
      expect(response.twoFactorRequired, isFalse);
      expect(response.token, '01jb2x9k4m7q8r3t5v6w8y0z1a_jwt_token');
      expect(response.challenge, isNull);
    });

    test('LoginResponseModel parses 2FA Challenge requirement', () {
      final json = {
        'data': {
          'two_factor_required': true,
          'challenge':
              'a1b2c3d4e5f67890123456789abcdef0123456789abcdef0123456789abcdef0',
        }
      };

      final response = LoginResponseModel.fromJson(json);
      expect(response.twoFactorRequired, isTrue);
      expect(response.token, isNull);
      expect(
        response.challenge,
        'a1b2c3d4e5f67890123456789abcdef0123456789abcdef0123456789abcdef0',
      );
    });

    test('TwoFactorRequestModel serializes TOTP code correctly', () {
      final request = TwoFactorRequestModel(
        challenge: 'mock_challenge_hash_64_chars',
        code: '481920',
      );

      final json = request.toJson();
      expect(json['challenge'], 'mock_challenge_hash_64_chars');
      expect(json['code'], '481920');
      expect(json.containsKey('recovery_code'), isFalse);
    });

    test('TwoFactorRequestModel serializes Recovery Code correctly', () {
      final request = TwoFactorRequestModel(
        challenge: 'mock_challenge_hash_64_chars',
        recoveryCode: 'A89F-22B1',
      );

      final json = request.toJson();
      expect(json['challenge'], 'mock_challenge_hash_64_chars');
      expect(json['recovery_code'], 'A89F-22B1');
      expect(json.containsKey('code'), isFalse);
    });

    test('TwoFactorResponseModel deserializes token correctly', () {
      final json = {
        'data': {
          'token': '01jb2x9k4m7q8r3t5v6w8y0z1a_verified_jwt',
        }
      };

      final response = TwoFactorResponseModel.fromJson(json);
      expect(response.token, '01jb2x9k4m7q8r3t5v6w8y0z1a_verified_jwt');
    });

    test('ForgotPasswordRequest & Response models handle probing-proof contract',
        () {
      final request = ForgotPasswordRequestModel(email: 'ayesha@acme.pk');
      expect(request.toJson()['email'], 'ayesha@acme.pk');

      final response = ForgotPasswordResponseModel.fromJson({
        'data': {
          'message':
              'If the address has an account, a reset link has been sent.',
        }
      });
      expect(
        response.message,
        'If the address has an account, a reset link has been sent.',
      );
    });
  });

  group('AuthController Logic & Validation Tests', () {
    late AuthController controller;

    setUp(() {
      Get.reset();
      controller = AuthController(repo: AuthRepo());
      Get.put(controller);
    });

    tearDown(() {
      Get.delete<AuthController>();
    });

    test('Toggling login mode updates observable and clears errors', () {
      expect(controller.isEmployeeNumberMode.value, isFalse);

      controller.loginError.value = 'Existing error';
      controller.toggleLoginMode();

      expect(controller.isEmployeeNumberMode.value, isTrue);
      expect(controller.loginError.value, isNull);
    });

    test('Toggling password visibility switches boolean state', () {
      expect(controller.isPasswordVisible.value, isFalse);
      controller.togglePasswordVisibility();
      expect(controller.isPasswordVisible.value, isTrue);
    });

    test('Toggling remember me switches boolean state', () {
      expect(controller.rememberMe.value, isFalse);
      controller.toggleRememberMe(true);
      expect(controller.rememberMe.value, isTrue);
    });

    test('Client-side email pre-validation flags empty and malformed emails',
        () async {
      controller.isEmployeeNumberMode.value = false;
      controller.emailController.text = '';
      controller.passwordController.text = 'ValidPassword123';

      await controller.login();
      expect(controller.loginError.value,
          'Please enter your corporate email address');

      controller.emailController.text = 'invalid_email_format';
      await controller.login();
      expect(controller.loginError.value,
          'Please enter a valid corporate email address');
    });

    test('Client-side Employee ID pre-validation flags missing company code',
        () async {
      controller.isEmployeeNumberMode.value = true;
      controller.companyCodeController.text = '';
      controller.emailController.text = 'EMP-0001';
      controller.passwordController.text = 'ValidPassword123';

      await controller.login();
      expect(controller.companyCodeError.value,
          'Please enter 6-character company code');
    });

    test('Client-side Employee ID pre-validation flags missing employee ID',
        () async {
      controller.isEmployeeNumberMode.value = true;
      controller.companyCodeController.text = 'K7MP2Q';
      controller.emailController.text = '';
      controller.passwordController.text = 'ValidPassword123';

      await controller.login();
      expect(controller.loginError.value,
          'Please enter your employee ID (e.g. EMP-0001)');
    });

    test('Client-side password pre-validation flags empty password', () async {
      controller.isEmployeeNumberMode.value = false;
      controller.emailController.text = 'valid@company.com';
      controller.passwordController.text = '';

      await controller.login();
      expect(controller.passwordError.value, 'Please enter your password');
    });

    test('Device name and device ID persistence in AppPreferences works properly', () async {
      await AppPreferences.setDeviceName('Pixel 8 – Android 15');
      await AppPreferences.setDeviceId('test_device_uuid_123');

      expect(AppPreferences.deviceName, 'Pixel 8 – Android 15');
      expect(AppPreferences.deviceId, 'test_device_uuid_123');
    });
  });
}
