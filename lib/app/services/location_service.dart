import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

enum LocationResultStatus {
  success,
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
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
  Future<LocationResult> getCurrentLocation() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const LocationResult.failure(
          'Location services (GPS) are turned off on your device.',
          status: LocationResultStatus.serviceDisabled,
        );
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
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

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );

      // Check mock location (Server rule: mocked position is refused)
      if (position.isMocked) {
        return const LocationResult.failure(
          'Mock / Fake location detected. Please disable fake GPS apps to punch.',
          status: LocationResultStatus.mocked,
        );
      }

      // Check accuracy (Server rule per api.md: worse than 150m is refused when position required)
      if (position.accuracy > 150) {
        return LocationResult.failure(
          'GPS accuracy (${position.accuracy.round()}m) is too weak (required <= 150m). Please move closer to an open area or window.',
          status: LocationResultStatus.accuracyTooLow,
        );
      }

      // Truncate to max 6 decimal places per api.md spec
      final double lat = double.parse(position.latitude.toStringAsFixed(6));
      final double lng = double.parse(position.longitude.toStringAsFixed(6));

      debugPrint(
        '>>> [LocationService] Acquired GPS: ($lat, $lng), accuracy: ${position.accuracy.round()}m, isMocked: ${position.isMocked}',
      );

      return LocationResult.success(
        latitude: lat,
        longitude: lng,
        accuracyMeters: position.accuracy.round(),
        isMocked: position.isMocked,
      );
    } on TimeoutException {
      // Fallback: try last known position if current position timed out
      try {
        final lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null &&
            !lastKnown.isMocked &&
            lastKnown.accuracy <= 150) {
          final lat = double.parse(lastKnown.latitude.toStringAsFixed(6));
          final lng = double.parse(lastKnown.longitude.toStringAsFixed(6));
          return LocationResult.success(
            latitude: lat,
            longitude: lng,
            accuracyMeters: lastKnown.accuracy.round(),
            isMocked: lastKnown.isMocked,
          );
        }
      } catch (_) {}
      return const LocationResult.failure(
        'GPS location timed out. Please ensure GPS has a clear view of the sky.',
        status: LocationResultStatus.timeout,
      );
    } catch (e) {
      debugPrint('>>> [LocationService] Position error: $e');
      return LocationResult.failure(
        'Failed to obtain location: $e',
        status: LocationResultStatus.error,
      );
    }
  }
}
