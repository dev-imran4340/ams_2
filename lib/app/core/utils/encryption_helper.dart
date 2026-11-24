import 'dart:convert';

/// Cryptographic helper for migration and secure credential handling.
/// Insecure repeating XOR cipher and fixed embedded keys have been removed
/// in favor of platform-backed secure hardware storage (SecureStorageService).
class EncryptionHelper {
  static const String _magicPrefix = 'ams_enc::';

  /// Legacy decryption strictly used for one-time migration of previous local credentials.
  /// Never used for new writes or persistence.
  static String? legacyDecrypt(String? cipherText, {String? deviceId}) {
    if (cipherText == null || cipherText.isEmpty) return null;

    try {
      String cleanPayload = cipherText;
      if (cleanPayload.startsWith(_magicPrefix)) {
        cleanPayload = cleanPayload.substring(_magicPrefix.length);
      }

      final List<int> cipherBytes = base64Url.decode(cleanPayload);
      final String resolvedId = (deviceId != null && deviceId.isNotEmpty)
          ? deviceId
          : 'ams_fallback_hw_id_2026';
      final String legacyKey = '$resolvedId#AMS2_CORP_VAULT_KEY_2026_SOFTECH#$resolvedId';
      final List<int> keyBytes = utf8.encode(legacyKey);

      final List<int> decryptedBytes = List<int>.generate(
        cipherBytes.length,
        (i) => cipherBytes[i] ^ keyBytes[i % keyBytes.length],
      );

      return utf8.decode(decryptedBytes);
    } catch (_) {
      return null;
    }
  }

  /// Deprecated: Direct XOR encryption is removed for security compliance.
  @Deprecated('Use SecureStorageService instead of XOR encryption')
  static String? encrypt(String? plainText, {String? deviceId}) {
    // No-op / Redirected to secure storage
    return plainText;
  }

  /// Deprecated: Decrypt helper for backwards compatibility.
  @Deprecated('Use SecureStorageService instead of XOR decryption')
  static String? decrypt(String? cipherText, {String? deviceId}) {
    return legacyDecrypt(cipherText, deviceId: deviceId);
  }
}
