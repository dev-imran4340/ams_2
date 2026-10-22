import 'package:get_storage/get_storage.dart';
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
  static const String _keyDeviceName = 'cached_device_name';
  static const String _keyDeviceId = 'cached_device_id';
  static const String _keyProfile = 'employee_profile_data';
  static const String _keyPermissions = 'server_permissions_map';
  static const String _keyMenu = 'server_dynamic_menu';
  static const String _keyModules = 'server_paid_modules';
  static const String _keyBadges = 'server_menu_badges';
  static const String _keyCompany = 'server_company_data';
  static const String _key2FAChallenge = 'pending_2fa_challenge';

  /// Initialize local storage container (Must be invoked before runApp in main.dart)
  static Future<void> init() async {
    await GetStorage.init();
    // Ensure persistent device ID exists
    if (deviceId == null || deviceId!.isEmpty) {
      final generated = 'ams_dev_${DateTime.now().millisecondsSinceEpoch.toRadixString(36)}';
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
    await _box.remove(_key2FAChallenge);
    await _box.write(_keyIsLoggedIn, false);
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
  static bool hasPermission(String key, [String? scope]) {
    final perms = permissions;
    if (perms == null || !perms.containsKey(key)) return false;
    final value = perms[key];
    if (value == null) {
      // Permission without scopes (binary allowed)
      return true;
    }
    if (value is List) {
      if (scope == null) return value.isNotEmpty;
      return value.contains(scope);
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

  static String? get companyCode => company?['code']?.toString();
  static String? get companyName => company?['name']?.toString();

  // --- Two-Factor Authentication Challenge ---

  static String? get twoFactorChallenge =>
      _box.read<String>(_key2FAChallenge);

  static Future<void> setTwoFactorChallenge(String? challenge) async {
    if (challenge == null) {
      await _box.remove(_key2FAChallenge);
    } else {
      await _box.write(_key2FAChallenge, challenge);
    }
  }

  // --- Remember Me & Saved Email ---

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

  // --- Clear / Reset ---

  static Future<void> clearAuth() async {
    await clearSession();
  }

  static Future<void> clearAll() async {
    await _box.erase();
  }
}
