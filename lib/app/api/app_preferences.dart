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

  /// Initialize local storage container (Must be invoked before runApp in main.dart)
  static Future<void> init() async {
    await GetStorage.init();
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

  /// Clears active authentication session
  static Future<void> clearSession() async {
    await _box.remove(_keyToken);
    await _box.remove(_keyRefreshToken);
    await _box.remove(_keyUser);
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

  // --- Clear / Reset ---

  static Future<void> clearAuth() async {
    await clearSession();
  }

  static Future<void> clearAll() async {
    await _box.erase();
  }
}
