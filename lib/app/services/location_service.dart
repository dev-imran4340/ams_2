import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

enum LocationResultStatus {
  success,
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  preciseRequired,
  accuracyTooLow,
  mocked,
  timeout,
  error,
}

class LocationResult {
  final double latitude;
  final double longitude;
  final int accuracyMeters;
  final bool isMocked;
  final String? errorMessage;
  final LocationResultStatus status;

  bool get isSuccess => status == LocationResultStatus.success;

  const LocationResult.success({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    required this.isMocked,
  })  : status = LocationResultStatus.success,
        errorMessage = null;

  const LocationResult.failure(
    this.errorMessage, {
    this.status = LocationResultStatus.error,
  })  : latitude = 0.0,
        longitude = 0.0,
        accuracyMeters = 0,
        isMocked = false;
}

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// Opens the device OS Location settings page (Android / iOS)
  Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (e) {
      debugPrint('>>> [LocationService] Failed to open location settings: $e');
      return false;
    }
  }

  /// Opens AMS 2 application permission settings page
  Future<bool> openAppSettings() async {
    try {
      return await Geolocator.openAppSettings();
    } catch (e) {
      debugPrint('>>> [LocationService] Failed to open app settings: $e');
      return false;
    }
  }

  /// Checks if location services are enabled and permissions are granted
  Future<LocationResultStatus> checkStatus() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationResultStatus.serviceDisabled;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationResultStatus.permissionDenied;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationResultStatus.permissionDeniedForever;
      }

      // Check for Precise vs Approximate location on Android 12+ / iOS 14+
      try {
        var accuracyStatus = await Geolocator.getLocationAccuracy();
        if (accuracyStatus == LocationAccuracyStatus.reduced) {
          // Re-trigger system prompt to allow user to upgrade to Precise location
          await Geolocator.requestPermission();
          accuracyStatus = await Geolocator.getLocationAccuracy();
        }
        if (accuracyStatus == LocationAccuracyStatus.reduced) {
          return LocationResultStatus.preciseRequired;
        }
      } catch (_) {}

      return LocationResultStatus.success;
    } catch (e) {
      debugPrint('>>> [LocationService] Status check error: $e');
      return LocationResultStatus.error;
    }
  }

  /// Fetches high-accuracy current GPS position
  /// Validates:
  /// 1. Location service & permissions
  /// 2. Accuracy <= 150m (Server rule: worse than 150m is refused)
  /// 3. Mocked / Fake location rejection
  /// Fetches high-accuracy current GPS position
  /// Validates:
  /// 1. Location service & permissions
  /// 2. Accuracy <= 150m (Server rule: worse than 150m is refused)
  /// 3. Mocked / Fake location rejection
  Future<LocationResult> getCurrentLocation() async {
    try {
      if (kDebugMode) {
        debugPrint('>>> [LocationService -> getCurrentLocation()] Pipeline started.');
      }

      // Step 1: Device GPS Toggle Check
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (kDebugMode) {
        debugPrint('>>> [LocationService] Step 1: GPS Service Enabled: $serviceEnabled');
      }
      if (!serviceEnabled) {
        return const LocationResult.failure(
          'Location services (GPS) are turned off on your device. Please turn on Location in Quick Settings.',
          status: LocationResultStatus.serviceDisabled,
        );
      }

      // Step 2: Runtime Permission Check
      LocationPermission permission = await Geolocator.checkPermission();
      if (kDebugMode) {
        debugPrint('>>> [LocationService] Step 2: Current Permission: $permission');
      }
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (kDebugMode) {
          debugPrint('>>> [LocationService] Step 2b: Requested Permission result: $permission');
        }
        if (permission == LocationPermission.denied) {
          return const LocationResult.failure(
            'Location permission is required to verify your attendance within office geofence.',
            status: LocationResultStatus.permissionDenied,
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return const LocationResult.failure(
          'Location access is permanently disabled for AMS 2. Please enable it in App Settings.',
          status: LocationResultStatus.permissionDeniedForever,
        );
      }

      // Step 3: Precise vs Approximate Location Verification (Android 12+ / iOS 14+)
      try {
        var accuracyStatus = await Geolocator.getLocationAccuracy();
        if (kDebugMode) {
          debugPrint('>>> [LocationService] Step 3: Accuracy Status: $accuracyStatus');
        }
        if (accuracyStatus == LocationAccuracyStatus.reduced) {
          if (kDebugMode) {
            debugPrint('>>> [LocationService] Step 3b: Approximate detected. Prompting OS upgrade to Precise...');
          }
          await Geolocator.requestPermission();
          accuracyStatus = await Geolocator.getLocationAccuracy();
        }
        if (accuracyStatus == LocationAccuracyStatus.reduced) {
          return const LocationResult.failure(
            'Precise location is required for attendance verification. Please turn on "Use precise location" in App Settings.',
            status: LocationResultStatus.preciseRequired,
          );
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('>>> [LocationService] Step 3 note: $e');
        }
      }

      Position? position;

      // Tier 1: Instant Cache Fix (Any recent known position with accuracy <= 150m)
      try {
        final lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null && !lastKnown.isMocked && lastKnown.accuracy <= 150) {
          final ageMinutes = DateTime.now().difference(lastKnown.timestamp).inMinutes.abs();
          if (kDebugMode) {
            debugPrint(
              '>>> [LocationService] Tier 1: Cache candidate found (${lastKnown.latitude}, ${lastKnown.longitude}), acc: ${lastKnown.accuracy.round()}m, age: $ageMinutes mins',
            );
          }
          position = lastKnown;
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('>>> [LocationService] Tier 1 note: $e');
        }
      }

      // Tier 2: Stream & Direct Concurrent Live Acquisition (12s timeout, Google Play Fused Provider)
      if (position == null) {
        try {
          if (kDebugMode) {
            debugPrint(
              '>>> [LocationService] Tier 2: Starting concurrent live stream & direct acquisition (12s)...',
            );
          }

          final completer = Completer<Position?>();
          StreamSubscription<Position>? streamSub;

          late final LocationSettings locationSettings;
          if (defaultTargetPlatform == TargetPlatform.android) {
            locationSettings = AndroidSettings(
              accuracy: LocationAccuracy.high,
              forceLocationManager: false,
              intervalDuration: const Duration(milliseconds: 500),
              timeLimit: const Duration(seconds: 12),
            );
          } else if (defaultTargetPlatform == TargetPlatform.iOS) {
            locationSettings = AppleSettings(
              accuracy: LocationAccuracy.high,
              activityType: ActivityType.other,
              pauseLocationUpdatesAutomatically: false,
              timeLimit: const Duration(seconds: 12),
            );
          } else {
            locationSettings = const LocationSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: Duration(seconds: 12),
            );
          }

          streamSub = Geolocator.getPositionStream(
            locationSettings: locationSettings,
          ).listen(
            (pos) {
              if (!completer.isCompleted && !pos.isMocked && pos.accuracy <= 150) {
                if (kDebugMode) {
                  debugPrint(
                    '>>> [LocationService] Stream delivered fix: (${pos.latitude}, ${pos.longitude}), acc: ${pos.accuracy.round()}m',
                  );
                }
                completer.complete(pos);
              }
            },
            onError: (err) {
              if (kDebugMode) {
                debugPrint('>>> [LocationService] Stream error notice: $err');
              }
            },
          );

          Geolocator.getCurrentPosition(locationSettings: locationSettings).then((pos) {
            if (!completer.isCompleted && !pos.isMocked && pos.accuracy <= 150) {
              if (kDebugMode) {
                debugPrint(
                  '>>> [LocationService] Direct getCurrentPosition delivered fix: (${pos.latitude}, ${pos.longitude}), acc: ${pos.accuracy.round()}m',
                );
              }
              completer.complete(pos);
            }
          }).catchError((err) {
            if (kDebugMode) {
              debugPrint('>>> [LocationService] Direct getCurrentPosition notice: $err');
            }
          });

          position = await completer.future.timeout(
            const Duration(seconds: 12),
            onTimeout: () => null,
          );

          await streamSub.cancel();
        } catch (e) {
          if (kDebugMode) {
            debugPrint('>>> [LocationService] Tier 2 exception: $e');
          }
        }
      }

      // Tier 3: Native Android LocationManager fallback (6s timeout)
      if (position == null && defaultTargetPlatform == TargetPlatform.android) {
        try {
          if (kDebugMode) {
            debugPrint(
              '>>> [LocationService] Tier 3: Attempting native Android LocationManager fallback (6s)...',
            );
          }
          final legacySettings = AndroidSettings(
            accuracy: LocationAccuracy.medium,
            forceLocationManager: true, // Native Android LocationManager
            timeLimit: const Duration(seconds: 6),
          );
          final legacyPos = await Geolocator.getCurrentPosition(
            locationSettings: legacySettings,
          );
          if (kDebugMode) {
            debugPrint(
              '>>> [LocationService] Tier 3: Acquired (${legacyPos.latitude}, ${legacyPos.longitude}), acc: ${legacyPos.accuracy.round()}m',
            );
          }
          if (!legacyPos.isMocked && legacyPos.accuracy <= 150) {
            position = legacyPos;
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('>>> [LocationService] Tier 3 notice: $e');
          }
        }
      }

      // Tier 4: Ultimate Fallback to any valid last known position on device
      if (position == null) {
        try {
          final lastKnown = await Geolocator.getLastKnownPosition();
          if (lastKnown != null && !lastKnown.isMocked) {
            if (kDebugMode) {
              debugPrint(
                '>>> [LocationService] Tier 4: Fallback to last known position (${lastKnown.latitude}, ${lastKnown.longitude}), acc: ${lastKnown.accuracy.round()}m',
              );
            }
            position = lastKnown;
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('>>> [LocationService] Tier 4 note: $e');
          }
        }
      }

      // If position could not be acquired by any tier
      if (position == null) {
        if (kDebugMode) {
          debugPrint('>>> [LocationService] All tiers exhausted. Position is null.');
        }
        return const LocationResult.failure(
          'Could not acquire device location. If a security or privacy scanner (e.g. Phone Master) is blocking location, please whitelist AMS 2.',
          status: LocationResultStatus.timeout,
        );
      }

      // Check mock location (Server rule: mocked position is refused)
      if (position.isMocked) {
        if (kDebugMode) {
          debugPrint('>>> [LocationService] Rejection: Position is mocked!');
        }
        return const LocationResult.failure(
          'Mock / Fake location detected. Please disable fake GPS apps to punch.',
          status: LocationResultStatus.mocked,
        );
      }

      // Check accuracy (Server rule per api.md: worse than 150m is refused when position required)
      if (position.accuracy > 150) {
        if (kDebugMode) {
          debugPrint('>>> [LocationService] Rejection: Accuracy ${position.accuracy.round()}m > 150m');
        }
        return LocationResult.failure(
          'GPS accuracy (${position.accuracy.round()}m) is too weak (required <= 150m). Please move closer to an open area or window.',
          status: LocationResultStatus.accuracyTooLow,
        );
      }

      // Truncate to max 6 decimal places per api.md spec
      final double lat = double.parse(position.latitude.toStringAsFixed(6));
      final double lng = double.parse(position.longitude.toStringAsFixed(6));

      if (kDebugMode) {
        debugPrint(
          '>>> [LocationService] SUCCESS! Acquired GPS: ($lat, $lng), accuracy: ${position.accuracy.round()}m, isMocked: ${position.isMocked}',
        );
      }

      return LocationResult.success(
        latitude: lat,
        longitude: lng,
        accuracyMeters: position.accuracy.round(),
        isMocked: position.isMocked,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('>>> [LocationService] Unexpected exception: $e');
      }
      return LocationResult.failure(
        'Failed to obtain location: $e',
        status: LocationResultStatus.error,
      );
    }
  }
}
