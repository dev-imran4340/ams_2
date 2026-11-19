import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Enterprise-grade network probe service.
///
/// Fixes the common flaw with `connectivity_plus` where devices on Mobile Data
/// (with 0 balance / expired package) or Wi-Fi (connected to router with no internet / captive portal)
/// are falsely reported as "connected".
///
/// Verifies true packet flow using:
/// 1. Hardware connectivity check (`connectivity_plus`).
/// 2. DNS resolution (`google.com`).
/// 3. True HTTPS packet transmission (Google 204 & Apple captive probe).
class NetworkConnectivityService {
  NetworkConnectivityService._();

  static DateTime? _lastSuccessAt;
  static const Duration _cacheDuration = Duration(seconds: 30);

  /// Clears any cached positive result (e.g. immediately after an API failure/timeout).
  static void invalidateCache() {
    _lastSuccessAt = null;
  }

  /// Returns true only if the device has actual, working packet-flow internet access.
  static Future<bool> hasConnection() async {
    // 1. Check cached true if verified very recently to prevent duplicate overhead
    if (_lastSuccessAt != null &&
        DateTime.now().difference(_lastSuccessAt!) < _cacheDuration) {
      return true;
    }

    final isConnected = await _checkRealConnectivity();
    if (isConnected) {
      _lastSuccessAt = DateTime.now();
    } else {
      _lastSuccessAt = null;
    }
    return isConnected;
  }

  static Future<bool> _checkRealConnectivity() async {
    // Step 0: Fast hardware check with connectivity_plus
    try {
      final connectivityResults = await Connectivity().checkConnectivity();
      if (connectivityResults.contains(ConnectivityResult.none) ||
          connectivityResults.isEmpty) {
        return false;
      }
    } catch (_) {
      // Continue to socket probe on platform error
    }

    // Step 1: Quick DNS lookup.
    // If Wi-Fi and mobile data are toggled off or radio is dead, this fails immediately (< 25ms).
    try {
      final lookup = await InternetAddress.lookup('google.com')
          .timeout(const Duration(milliseconds: 2000));
      if (lookup.isEmpty || lookup.first.rawAddress.isEmpty) {
        return false;
      }
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    } catch (_) {
      return false;
    }

    // Step 2: Probe actual HTTP/HTTPS data transmission.
    // Raw port 53 (DNS) socket is intentionally NOT used here because mobile telcos
    // with 0 data package allow port 53 DNS queries to resolve captive/recharge portals,
    // which causes false-positive "online" detections.
    // HTTP 204 (Android OS captive-portal probe) and Apple HTTPS require active data packets.
    try {
      final probeResults = await Future.wait<bool>([
        _probeHttp204(),
        _probeHttps(),
      ]);

      return probeResults.any((success) => success);
    } catch (_) {
      return false;
    }
  }

  static Future<bool> _probeHttp204() async {
    HttpClient? client;
    try {
      client = HttpClient()
        ..connectionTimeout = const Duration(milliseconds: 2000);
      final request = await client
          .getUrl(Uri.parse('https://clients3.google.com/generate_204'))
          .timeout(const Duration(milliseconds: 2000));
      final response =
          await request.close().timeout(const Duration(milliseconds: 2000));
      // Standard Android/Google probe: returns 204 No Content when internet is live.
      return response.statusCode == 204;
    } catch (_) {
      return false;
    } finally {
      client?.close(force: true);
    }
  }

  static Future<bool> _probeHttps() async {
    HttpClient? client;
    try {
      client = HttpClient()
        ..connectionTimeout = const Duration(milliseconds: 2000);
      // Apple's official captive portal & internet check endpoint (fully iOS ATS compliant).
      final request = await client
          .getUrl(Uri.parse('https://captive.apple.com/hotspot-detect.html'))
          .timeout(const Duration(milliseconds: 2000));
      final response =
          await request.close().timeout(const Duration(milliseconds: 2000));
      return response.statusCode >= 200 && response.statusCode < 400;
    } catch (_) {
      return false;
    } finally {
      client?.close(force: true);
    }
  }
}
