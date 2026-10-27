import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import '../../api/app_preferences.dart';

/// Helper utility for extracting hardware-accurate telemetry and device name,
/// persisting it into AppPreferences, and logging it during app startup.
class DeviceInfoHelper {
  static final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  /// Captures device specifications, stores them in local storage,
  /// and outputs clear telemetry logs to the console.
  static Future<Map<String, String>> initDeviceInfo() async {
    String resolvedName = 'AMS Mobile Device';
    String? resolvedId;

    try {
      if (kIsWeb) {
        final webInfo = await _deviceInfoPlugin.webBrowserInfo;
        resolvedName = '${webInfo.browserName.name} – Web';
        resolvedId = 'web_${webInfo.userAgent.hashCode.abs()}';
      } else if (Platform.isAndroid) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        final String model = androidInfo.model;
        final String release = androidInfo.version.release;
        resolvedName = '$model – Android $release';
        resolvedId = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        final String name = iosInfo.name.isNotEmpty
            ? iosInfo.name
            : (iosInfo.model.isNotEmpty ? iosInfo.model : 'iPhone');
        final String sysVersion = iosInfo.systemVersion;
        resolvedName = '$name – iOS $sysVersion';
        resolvedId = iosInfo.identifierForVendor;
      } else if (Platform.isMacOS) {
        final macInfo = await _deviceInfoPlugin.macOsInfo;
        resolvedName = '${macInfo.model} – macOS';
        resolvedId = macInfo.systemGUID;
      } else if (Platform.isWindows) {
        final winInfo = await _deviceInfoPlugin.windowsInfo;
        resolvedName = '${winInfo.computerName} – Windows';
        resolvedId = winInfo.deviceId;
      } else if (Platform.isLinux) {
        final linuxInfo = await _deviceInfoPlugin.linuxInfo;
        resolvedName = '${linuxInfo.name} – Linux';
        resolvedId = linuxInfo.machineId;
      }
    } catch (e) {
      debugPrint('⚠️ [DeviceInfoHelper] Hardware resolution fallback: $e');
      resolvedName = Platform.isAndroid
          ? 'Android Device'
          : Platform.isIOS
              ? 'iOS Device'
              : 'AMS Mobile';
    }

    // Persist into AppPreferences
    await AppPreferences.setDeviceName(resolvedName);
    if (resolvedId != null && resolvedId.isNotEmpty) {
      await AppPreferences.setDeviceId(resolvedId);
    }

    // Print to console clearly as requested by user
    final cachedFcm = AppPreferences.fcmToken;
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('📱 [AMS DEVICE TELEMETRY CAPTURED]');
    debugPrint('   • Device Name (Sent on Login) : "$resolvedName"');
    debugPrint('   • Device UUID (X-Device-Id)   : "${AppPreferences.deviceId}"');
    debugPrint('   • Platform                    : ${defaultTargetPlatform.name}');
    if (cachedFcm != null && cachedFcm.isNotEmpty) {
      debugPrint('   • FCM Device Token            : "$cachedFcm"');
    }
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    return {
      'deviceName': resolvedName,
      'deviceId': AppPreferences.deviceId ?? '',
    };
  }
}
