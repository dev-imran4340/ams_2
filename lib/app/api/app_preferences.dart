import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get_core/get_core.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';

import '../core/utils/encryption_helper.dart';
import '../screens/auth/model/auth_model.dart';

/// Centralized local storage wrapper powered by GetStorage.
/// Strictly isolates persistence logic so no controller or view directly accesses storage.
class AppPreferences {
  static final GetStorage _box = GetStorage();

  // Storage Keys
  static const String _keyToken = 'auth_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUser = 'user_data';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyThemeMode = 'is_dark_mode';
  static const String _keyRememberMe = 'remember_me';
  static const String _keySavedEmail = 'saved_email';
  static const String _keyEncryptedLogin = 'enc_saved_login';
  static const String _keyEncryptedPassword = 'enc_saved_password';
  static const String _keyEncryptedCompanyCode = 'enc_saved_company_code';
  static const String _keySavedIsEmployeeMode = 'saved_is_emp_mode';
  static const String _keyDeviceName = 'cached_device_name';
  static const String _keyDeviceId = 'cached_device_id';
  static const String _keyProfile = 'employee_profile_data';
  static const String _keyPermissions = 'server_permissions_map';
  static const String _keyMenu = 'server_dynamic_menu';
  static const String _keyModules = 'server_paid_modules';
  static const String _keyBadges = 'server_menu_badges';
  static const String _keyCompany = 'server_company_data';
  static const String _keyCard = 'employee_card_data';
  static const String _key2FAChallenge = 'pending_2fa_challenge';
  static const String _keyMeData = 'server_me_full_payload';
  static const String _keyTodayAttendance = 'today_attendance_state';
  static const String _keyFcmToken = 'firebase_fcm_token';
  static const String _keyEnrolledFacePath = 'enrolled_face_image_path';
  static const String _keyEnrolledFaceEmbedding = 'enrolled_face_192_vector';
  static const String _keyEnrolledFaceTimestamp = 'enrolled_face_timestamp';
  static const String _keyEnrolledFaceVerified = 'enrolled_face_verified';

  /// Initialize local storage container (Must be invoked before runApp in main.dart)
  static Future<void> init() async {
    await GetStorage.init();
    // Ensure persistent device ID exists
    if (deviceId == null || deviceId!.isEmpty) {
      final generated =
          'ams_dev_${DateTime.now().millisecondsSinceEpoch.toRadixString(36)}';
      await _box.write(_keyDeviceId, generated);
    }
  }

  // --- Auth Session Methods ---

  /// Persists authentication session token and user profile
  static Future<void> saveAuthData({
    required String token,
    String? refreshToken,
    UserModel? user,
    Map<String, dynamic>? userData,
  }) async {
    await setToken(token);
    if (refreshToken != null) {
      await setRefreshToken(refreshToken);
    }
    if (user != null) {
      await _box.write(_keyUser, user.toJson());
    } else if (userData != null) {
      await setUser(userData);
    }
    await setIsLoggedIn(true);
  }

  /// Returns active auth token
  static String? getToken() => token;

  /// Returns typed UserModel instance or null
  static UserModel? getUser() {
    final data = _box.read<Map<String, dynamic>>(_keyUser);
    if (data == null) return null;
    return UserModel.fromJson(Map<String, dynamic>.from(data));
  }

  /// Clears active authentication session (Leaves device ID, theme, and saved email intact)
  static Future<void> clearSession() async {
    await _box.remove(_keyToken);
    await _box.remove(_keyRefreshToken);
    await _box.remove(_keyUser);
    await _box.remove(_keyProfile);
    await _box.remove(_keyPermissions);
    await _box.remove(_keyMenu);
    await _box.remove(_keyModules);
    await _box.remove(_keyBadges);
    await _box.remove(_keyCompany);
    await _box.remove(_keyCard);
    await _box.remove(_key2FAChallenge);
    await _box.remove(_keyMeData);
    await _box.remove(_keyTodayAttendance);
    await clearEnrolledFace();
    await _box.write(_keyIsLoggedIn, false);
    await _box.erase();
    if (kDebugMode) {
      Get.log('User logged out successfully : Clean All from local');
    }
  }

  // --- Auth Token Getters / Setters ---

  static String? get token => _box.read<String>(_keyToken);

  static Future<void> setToken(String? token) async {
    if (token == null) {
      await _box.remove(_keyToken);
    } else {
      await _box.write(_keyToken, token);
    }
  }

  static String? get refreshToken => _box.read<String>(_keyRefreshToken);

  static Future<void> setRefreshToken(String? refreshToken) async {
    if (refreshToken == null) {
      await _box.remove(_keyRefreshToken);
    } else {
      await _box.write(_keyRefreshToken, refreshToken);
    }
  }

  static bool get isLoggedIn =>
      _box.read<bool>(_keyIsLoggedIn) ?? (token != null && token!.isNotEmpty);

  static Future<void> setIsLoggedIn(bool value) async {
    await _box.write(_keyIsLoggedIn, value);
  }

  // --- User Profile Data ---

  static Map<String, dynamic>? get user =>
      _box.read<Map<String, dynamic>>(_keyUser);

  static Future<void> setUser(Map<String, dynamic>? userData) async {
    if (userData == null) {
      await _box.remove(_keyUser);
    } else {
      await _box.write(_keyUser, userData);
    }
  }

  static String? get userId => user?['id']?.toString();
  static String? get userName => user?['name']?.toString();
  static String? get userEmail => user?['email']?.toString();
  static String? get employeeNumber =>
      user?['employee_number']?.toString() ??
      getProfileData()?['employee_number']?.toString();
  static String? get selfEmployeeId =>
      getProfileData()?['id']?.toString() ?? userId;
  static String? get selfEmployeeNumber =>
      getProfileData()?['employee_number']?.toString() ?? employeeNumber;
  static bool get isTwoFactorEnabled => user?['two_factor_enabled'] == true;

  // --- Employee Profile Data ---

  static Map<String, dynamic>? getProfileData() =>
      _box.read<Map<String, dynamic>>(_keyProfile);

  static Future<void> setProfileData(Map<String, dynamic>? data) async {
    if (data == null) {
      await _box.remove(_keyProfile);
    } else {
      await _box.write(_keyProfile, data);
    }
  }

  // --- Digital Employee ID Card Data (from GET /me/card) ---

  static Map<String, dynamic>? getCardData() =>
      _box.read<Map<String, dynamic>>(_keyCard);

  static Future<void> setCardData(Map<String, dynamic>? data) async {
    if (data == null) {
      await _box.remove(_keyCard);
    } else {
      await _box.write(_keyCard, data);
    }
  }

  // --- Server-Driven Menu, Permissions & Scopes (from GET /me) ---

  static Map<String, dynamic>? get permissions =>
      _box.read<Map<String, dynamic>>(_keyPermissions);

  static Future<void> setPermissions(Map<String, dynamic>? perm) async {
    if (perm == null) {
      await _box.remove(_keyPermissions);
    } else {
      await _box.write(_keyPermissions, perm);
    }
  }

  /// Checks if employee possesses a specific permission and optional scope
  /// (e.g. hasPermission('employees.view', 'department'))
  /// Supports strict hierarchical scope inheritance: company > location > department > own.
  static bool hasPermission(String key, [String? scope]) {
    final perms = permissions;
    if (perms == null || !perms.containsKey(key)) return false;
    final value = perms[key];
    if (value == null) {
      // Permission without scopes (binary allowed, e.g. support.raise: null)
      return true;
    }
    if (value is List) {
      if (scope == null) return value.isNotEmpty;
      final scopes = value
          .map((e) => e.toString().toLowerCase().trim())
          .toSet();
      final req = scope.toLowerCase().trim();

      // Exact match
      if (scopes.contains(req)) return true;

      // Hierarchical scope inheritance:
      // company scope grants location, department, and own access
      if (scopes.contains('company')) return true;
      // location scope grants department and own access
      if (req == 'own' &&
          (scopes.contains('department') || scopes.contains('location'))) {
        return true;
      }
      if (req == 'department' && scopes.contains('location')) return true;

      return false;
    }
    return false;
  }

  static List<dynamic>? get menu => _box.read<List<dynamic>>(_keyMenu);

  static Future<void> setMenu(List<dynamic>? menuItems) async {
    if (menuItems == null) {
      await _box.remove(_keyMenu);
    } else {
      await _box.write(_keyMenu, menuItems);
    }
  }

  static List<dynamic>? get modules => _box.read<List<dynamic>>(_keyModules);

  static Future<void> setModules(List<dynamic>? modList) async {
    if (modList == null) {
      await _box.remove(_keyModules);
    } else {
      await _box.write(_keyModules, modList);
    }
  }

  /// Verifies if a paid company module is enabled (e.g. 'attendance', 'payroll', 'leave').
  /// Note: 'core' module is always enabled.
  static bool hasModule(String moduleKey) {
    if (moduleKey == 'core') return true;
    final modList = modules;
    if (modList == null) return false;
    return modList.contains(moduleKey);
  }

  static Map<String, dynamic>? get badges =>
      _box.read<Map<String, dynamic>>(_keyBadges);

  static Future<void> setBadges(Map<String, dynamic>? badgesMap) async {
    if (badgesMap == null) {
      await _box.remove(_keyBadges);
    } else {
      await _box.write(_keyBadges, badgesMap);
    }
  }

  static Map<String, dynamic>? get company =>
      _box.read<Map<String, dynamic>>(_keyCompany);

  static Future<void> setCompany(Map<String, dynamic>? companyData) async {
    if (companyData == null) {
      await _box.remove(_keyCompany);
    } else {
      await _box.write(_keyCompany, companyData);
    }
  }

  static String? get companyId => company?['id']?.toString();
  static String? get companyCode => company?['code']?.toString();
  static String? get companyName => company?['name']?.toString();

  // --- Full Identity Session Hydration (from GET /me) ---

  static Map<String, dynamic>? get meData =>
      _box.read<Map<String, dynamic>>(_keyMeData);

  /// Saves the complete /me session payload. Persists full raw payload and
  /// separately isolates user, company, permissions, modules, dynamic menu, and badges.
  static Future<void> saveMeData(dynamic rawPayload) async {
    if (rawPayload == null || rawPayload is! Map) return;

    final Map<String, dynamic> rawMap = Map<String, dynamic>.from(rawPayload);
    final Map<String, dynamic> data = (rawMap['data'] is Map)
        ? Map<String, dynamic>.from(rawMap['data'] as Map)
        : rawMap;

    // 1. Persist full session payload
    await _box.write(_keyMeData, data);

    // 2. Persist user information separately
    if (data['user'] is Map) {
      final userMap = Map<String, dynamic>.from(data['user'] as Map);
      await setUser(userMap);
    }

    // 3. Persist company information separately
    if (data['company'] is Map) {
      final compMap = Map<String, dynamic>.from(data['company'] as Map);
      await setCompany(compMap);
    }

    // 4. Persist permissions map
    if (data['permissions'] is Map) {
      await setPermissions(
        Map<String, dynamic>.from(data['permissions'] as Map),
      );
    }

    // 5. Persist modules list
    if (data['modules'] is List) {
      await setModules(List<dynamic>.from(data['modules'] as List));
    }

    // 6. Persist dynamic menu list
    if (data['menu'] is List) {
      await setMenu(List<dynamic>.from(data['menu'] as List));
    }

    // 7. Persist badges map
    if (data['badges'] is Map) {
      await setBadges(Map<String, dynamic>.from(data['badges'] as Map));
    }
  }

  // --- Two-Factor Authentication Challenge ---

  static String? get twoFactorChallenge => _box.read<String>(_key2FAChallenge);

  static Future<void> setTwoFactorChallenge(String? challenge) async {
    if (challenge == null) {
      await _box.remove(_key2FAChallenge);
    } else {
      await _box.write(_key2FAChallenge, challenge);
    }
  }

  // --- Today Live Attendance State ---

  static Map<String, dynamic>? get todayAttendance =>
      _box.read<Map<String, dynamic>>(_keyTodayAttendance);

  static Future<void> setTodayAttendance(Map<String, dynamic>? data) async {
    if (data == null) {
      await _box.remove(_keyTodayAttendance);
    } else {
      await _box.write(_keyTodayAttendance, data);
    }
  }

  // --- Remember Me & Encrypted Credentials ---

  static bool get rememberMe => _box.read<bool>(_keyRememberMe) ?? false;

  static Future<void> setRememberMe(bool value) async {
    await _box.write(_keyRememberMe, value);
  }

  static String? get savedEmail => _box.read<String>(_keySavedEmail);

  static Future<void> setSavedEmail(String? email) async {
    if (email == null) {
      await _box.remove(_keySavedEmail);
    } else {
      await _box.write(_keySavedEmail, email);
    }
  }

  /// Persists encrypted login credentials when "Remember Me" is enabled
  static Future<void> saveRememberedCredentials({
    required String login,
    required String password,
    String? companyCode,
    required bool isEmployeeNumberMode,
  }) async {
    final devId = deviceId;
    final encLogin = EncryptionHelper.encrypt(login, deviceId: devId);
    final encPass = EncryptionHelper.encrypt(password, deviceId: devId);
    final encCode = (companyCode != null && companyCode.trim().isNotEmpty)
        ? EncryptionHelper.encrypt(companyCode.trim(), deviceId: devId)
        : null;

    if (encLogin != null && encPass != null) {
      await _box.write(_keyEncryptedLogin, encLogin);
      await _box.write(_keyEncryptedPassword, encPass);
      if (encCode != null) {
        await _box.write(_keyEncryptedCompanyCode, encCode);
      } else {
        await _box.remove(_keyEncryptedCompanyCode);
      }
      await _box.write(_keySavedIsEmployeeMode, isEmployeeNumberMode);
      await setRememberMe(true);
      if (!isEmployeeNumberMode) {
        await setSavedEmail(login);
      }
    }
  }

  /// Clears stored remembered credentials and resets "Remember Me"
  static Future<void> clearRememberedCredentials() async {
    await _box.remove(_keyEncryptedLogin);
    await _box.remove(_keyEncryptedPassword);
    await _box.remove(_keyEncryptedCompanyCode);
    await _box.remove(_keySavedIsEmployeeMode);
    await setRememberMe(false);
    await setSavedEmail(null);
  }

  /// Verifies if valid remembered credentials exist in local storage
  static bool hasRememberedCredentials() {
    return rememberMe &&
        _box.hasData(_keyEncryptedLogin) &&
        _box.hasData(_keyEncryptedPassword);
  }

  /// Retrieves the decrypted display identifier of the remembered account (email or employee ID)
  static String? getSavedLoginIdentifier() {
    if (!hasRememberedCredentials()) return null;
    final encLogin = _box.read<String>(_keyEncryptedLogin);
    return EncryptionHelper.decrypt(encLogin, deviceId: deviceId);
  }

  /// Decrypts and retrieves stored credentials map
  static Map<String, dynamic>? getDecryptedCredentials() {
    if (!hasRememberedCredentials()) return null;

    final encLogin = _box.read<String>(_keyEncryptedLogin);
    final encPass = _box.read<String>(_keyEncryptedPassword);
    final encCode = _box.read<String>(_keyEncryptedCompanyCode);
    final isEmpMode = _box.read<bool>(_keySavedIsEmployeeMode) ?? false;

    final decLogin = EncryptionHelper.decrypt(encLogin, deviceId: deviceId);
    final decPass = EncryptionHelper.decrypt(encPass, deviceId: deviceId);
    final decCode = (encCode != null)
        ? EncryptionHelper.decrypt(encCode, deviceId: deviceId)
        : null;

    if (decLogin == null || decPass == null) return null;

    return {
      'login': decLogin,
      'password': decPass,
      'companyCode': decCode,
      'isEmployeeNumberMode': isEmpMode,
    };
  }

  // --- Theme Mode ---

  static bool? get isDarkMode => _box.read<bool>(_keyThemeMode);

  static Future<void> setDarkMode(bool isDark) async {
    await _box.write(_keyThemeMode, isDark);
  }

  // --- Device Info ---

  static String? get deviceName => _box.read<String>(_keyDeviceName);

  static Future<void> setDeviceName(String? name) async {
    if (name == null) {
      await _box.remove(_keyDeviceName);
    } else {
      await _box.write(_keyDeviceName, name);
    }
  }

  static String? get deviceId => _box.read<String>(_keyDeviceId);

  static Future<void> setDeviceId(String? id) async {
    if (id == null) {
      await _box.remove(_keyDeviceId);
    } else {
      await _box.write(_keyDeviceId, id);
    }
  }

  // --- Firebase Cloud Messaging (FCM) Token ---

  static String? get fcmToken => _box.read<String>(_keyFcmToken);

  static Future<void> setFcmToken(String? token) async {
    if (token == null) {
      await _box.remove(_keyFcmToken);
    } else {
      await _box.write(_keyFcmToken, token);
    }
  }

  // --- AI Biometric Face Enrollment (Phase 10) ---

  /// Verifies if an enrolled reference face exists in local storage
  static bool get hasEnrolledFace {
    final path = enrolledFacePath;
    if (path == null || path.isEmpty) return false;
    final file = File(path);
    return file.existsSync() && file.lengthSync() > 0;
  }

  /// Retrieves the enrolled face image file path
  static String? get enrolledFacePath => _box.read<String>(_keyEnrolledFacePath);

  /// Retrieves the complete enrolled face bundle
  static Map<String, dynamic>? getEnrolledFace() {
    final path = enrolledFacePath;
    final embedding = enrolledFaceEmbedding;
    if (path == null || embedding == null) return null;
    return {
      'imagePath': path,
      'embedding': embedding,
      'timestamp': enrolledFaceTimestamp,
    };
  }

  /// Retrieves the enrolled 192-dimensional biometric embedding vector
  static List<double>? get enrolledFaceEmbedding {
    final raw = _box.read<List<dynamic>>(_keyEnrolledFaceEmbedding);
    if (raw == null || raw.isEmpty) return null;
    return raw.map((e) => (e as num).toDouble()).toList();
  }

  /// Retrieves the enrollment timestamp
  static DateTime? get enrolledFaceTimestamp {
    final raw = _box.read<String>(_keyEnrolledFaceTimestamp);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  /// Persists enrolled face image path and 192-dimensional vector in AppPreferences
  static Future<void> saveEnrolledFace({
    required String imagePath,
    required List<double> embedding,
  }) async {
    await _box.write(_keyEnrolledFacePath, imagePath);
    await _box.write(_keyEnrolledFaceEmbedding, embedding);
    await _box.write(_keyEnrolledFaceTimestamp, DateTime.now().toIso8601String());
    await _box.write(_keyEnrolledFaceVerified, true);
  }

  /// Purges enrolled face: deletes image file and embedding file from disk and clears storage keys
  static Future<void> clearEnrolledFace() async {
    try {
      final savedPath = _box.read<String>(_keyEnrolledFacePath);
      if (savedPath != null && savedPath.isNotEmpty) {
        final f = File(savedPath);
        if (f.existsSync()) {
          await f.delete();
        }
      }

      // Also clean default document directory enrolled files
      final docsDir = await getApplicationDocumentsDirectory();
      final defaultImg = File('${docsDir.path}/enrolled_reference_face.jpg');
      if (defaultImg.existsSync()) {
        await defaultImg.delete();
      }
      final defaultEmbed = File('${docsDir.path}/enrolled_face_embedding.json');
      if (defaultEmbed.existsSync()) {
        await defaultEmbed.delete();
      }
    } catch (_) {}

    await _box.remove(_keyEnrolledFacePath);
    await _box.remove(_keyEnrolledFaceEmbedding);
    await _box.remove(_keyEnrolledFaceTimestamp);
    await _box.remove(_keyEnrolledFaceVerified);
  }

  // --- Clear / Reset ---

  static Future<void> clearAuth() async {
    await clearSession();
  }

  static Future<void> clearAll() async {
    await clearEnrolledFace();
    await _box.erase();
  }
}
