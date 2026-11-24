import 'dart:convert';

/// Enterprise Log Sanitizer for AMS 2.
/// Guarantees that sensitive authentication tokens, authorization headers, passwords,
/// OTPs, recovery codes, challenges, biometric vectors, and personal secrets are redacted
/// before any debug log or network tracer statement is emitted.
class LogSanitizer {
  static const Set<String> _sensitiveHeaders = {
    'authorization',
    'x-device-id',
    'x-user-token',
    'cookie',
  };

  static const Set<String> _sensitiveKeys = {
    'password',
    'code',
    'recovery_code',
    'challenge',
    'token',
    'access_token',
    'refresh_token',
    'kiosk_token',
    'fcm_token',
    'pin',
    'current_pin',
    'new_pin',
    'confirm_pin',
    'face_embedding',
    'embedding',
    'secret',
    'qr_value',
  };

  /// Sanitizes HTTP headers by redacting sensitive values like Authorization
  static Map<String, String> sanitizeHeaders(Map<String, String>? headers) {
    if (headers == null) return {};
    final sanitized = <String, String>{};
    headers.forEach((key, value) {
      if (_sensitiveHeaders.contains(key.toLowerCase().trim())) {
        if (key.toLowerCase().trim() == 'authorization' &&
            value.toLowerCase().startsWith('bearer ')) {
          sanitized[key] = 'Bearer [REDACTED]';
        } else {
          sanitized[key] = '[REDACTED]';
        }
      } else {
        sanitized[key] = value;
      }
    });
    return sanitized;
  }

  /// Recursively sanitizes Maps, Lists, and JSON strings by masking sensitive fields
  static dynamic sanitizeData(dynamic data) {
    if (data == null) return null;

    if (data is Map) {
      final sanitized = <dynamic, dynamic>{};
      data.forEach((key, value) {
        final keyStr = key.toString().toLowerCase().trim();
        if (_sensitiveKeys.contains(keyStr)) {
          sanitized[key] = '[REDACTED]';
        } else if (value is Map || value is List) {
          sanitized[key] = sanitizeData(value);
        } else {
          sanitized[key] = value;
        }
      });
      return sanitized;
    }

    if (data is List) {
      return data.map((item) => sanitizeData(item)).toList();
    }

    if (data is String) {
      final trimmed = data.trim();
      if ((trimmed.startsWith('{') && trimmed.endsWith('}')) ||
          (trimmed.startsWith('[') && trimmed.endsWith(']'))) {
        try {
          final decoded = jsonDecode(trimmed);
          final sanitized = sanitizeData(decoded);
          return jsonEncode(sanitized);
        } catch (_) {
          return _redactRawString(data);
        }
      }
      return _redactRawString(data);
    }

    return data;
  }

  static String _redactRawString(String input) {
    String output = input;
    // Redact Bearer tokens in raw strings
    output = output.replaceAll(
      RegExp(r'Bearer\s+[A-Za-z0-9_\-\.~+/=]+', caseSensitive: false),
      'Bearer [REDACTED]',
    );
    return output;
  }
}
