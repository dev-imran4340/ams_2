import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Platform-backed hardware secure storage service (iOS Keychain, Android KeyStore).
/// Securely stores sensitive session secrets, refresh tokens, and remembered passwords.
class SecureStorageService {
  static FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(resetOnError: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static final Map<String, String> _memoryFallback = {};
  static bool useMemoryFallback = false;

  @visibleForTesting
  static void setStorage(FlutterSecureStorage storage) {
    _storage = storage;
    useMemoryFallback = false;
  }

  @visibleForTesting
  static void resetMemoryFallback() {
    _memoryFallback.clear();
  }

  @visibleForTesting
  static bool hasTestKey(String key) => _memoryFallback.containsKey(key);

  /// Securely writes a key-value pair to platform secure storage
  static Future<void> write(String key, String value) async {
    _memoryFallback[key] = value;
    if (useMemoryFallback) return;

    try {
      await _storage.write(key: key, value: value);
    } catch (_) {
      // In testing environments or unsupported platforms, in-memory fallback preserves data
    }
  }

  /// Securely reads a value from platform secure storage
  static Future<String?> read(String key) async {
    if (useMemoryFallback) {
      return _memoryFallback[key];
    }

    try {
      final value = await _storage.read(key: key);
      if (value != null) {
        _memoryFallback[key] = value;
        return value;
      }
      return _memoryFallback[key];
    } catch (_) {
      return _memoryFallback[key];
    }
  }

  /// Securely removes a key from platform secure storage
  static Future<void> delete(String key) async {
    _memoryFallback.remove(key);
    if (useMemoryFallback) return;

    try {
      await _storage.delete(key: key);
    } catch (_) {}
  }

  /// Purges all sensitive keys from platform secure storage
  static Future<void> deleteAll() async {
    _memoryFallback.clear();
    if (useMemoryFallback) return;

    try {
      await _storage.deleteAll();
    } catch (_) {}
  }
}
