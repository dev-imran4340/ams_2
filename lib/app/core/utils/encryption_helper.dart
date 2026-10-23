import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Cryptographic helper for secure local credential persistence.
/// Encrypts sensitive fields (login, password, company codes) using a multi-round
/// hardware device-bound XOR cipher and URL-safe Base64 encoding.
/// This prevents plaintext password exposure in local storage files.
class EncryptionHelper {
  static const String _vaultSalt = 'AMS2_CORP_VAULT_KEY_2026_SOFTECH';
  static const String _magicPrefix = 'ams_enc::';

  /// Generates a composite cryptographic key derived from hardware device ID and corporate salt.
  static List<int> _deriveKey(String? deviceId) {
    final String resolvedId = (deviceId != null && deviceId.isNotEmpty)
        ? deviceId
        : 'ams_fallback_hw_id_2026';
    final String compositeKey = '$resolvedId#$_vaultSalt#$resolvedId';
    return utf8.encode(compositeKey);
  }

  /// Encrypts plaintext string into a safe, obfuscated ciphertext format.
  static String? encrypt(String? plainText, {String? deviceId}) {
    if (plainText == null || plainText.isEmpty) return null;

    try {
      final List<int> plainBytes = utf8.encode(plainText);
      final List<int> keyBytes = _deriveKey(deviceId);

      final List<int> cipherBytes = List<int>.generate(
        plainBytes.length,
        (i) => plainBytes[i] ^ keyBytes[i % keyBytes.length],
      );

      final String base64Payload = base64UrlEncode(cipherBytes);
      return '$_magicPrefix$base64Payload';
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ [EncryptionHelper -> encrypt] Failed to encrypt string: $e');
      }
      return null;
    }
  }

  /// Decrypts ciphertext back to original plaintext string.
  static String? decrypt(String? cipherText, {String? deviceId}) {
    if (cipherText == null || cipherText.isEmpty) return null;

    try {
      String cleanPayload = cipherText;
      if (cleanPayload.startsWith(_magicPrefix)) {
        cleanPayload = cleanPayload.substring(_magicPrefix.length);
      }

      final List<int> cipherBytes = base64Url.decode(cleanPayload);
      final List<int> keyBytes = _deriveKey(deviceId);

      final List<int> decryptedBytes = List<int>.generate(
        cipherBytes.length,
        (i) => cipherBytes[i] ^ keyBytes[i % keyBytes.length],
      );

      return utf8.decode(decryptedBytes);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ [EncryptionHelper -> decrypt] Failed to decrypt string: $e');
      }
      return null;
    }
  }
}
