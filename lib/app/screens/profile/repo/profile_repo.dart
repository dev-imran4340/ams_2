import 'dart:async';

import '../../../api/api_client.dart';
import '../../../api/api_endpoints.dart';
import '../../../api/app_preferences.dart';
import '../../../api/exception_handler.dart';
import '../model/profile_model.dart';

class ProfileRepo {
  static const String _tag = 'ProfileRepo / ProfileScreen';

  /// Fetches executive employee profile from GET /api/v1/me/profile.
  /// Strictly follows the Layer Flow: View -> Controller -> Repository -> ApiClient.
  Future<EmployeeProfileModel?> fetchProfile() async {
    try {
      // 1. Attempt live API request
      final response = await ApiClient.request(
        endpoint: ApiEndpoints.meProfile,
        method: HttpMethod.get,
        tag: '$_tag -> fetchProfile()',
        showToastOnError: false, // Non-intrusive fallback handling
      );

      if (response != null && response is Map) {
        final Map<String, dynamic> responseMap =
            Map<String, dynamic>.from(response);

        // Cache live profile payload locally in AppPreferences
        await AppPreferences.setProfileData(responseMap);

        // Parse and return strongly typed model
        return EmployeeProfileModel.fromJson(responseMap);
      }
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Remote profile fetch failed: $e'),
        tag:
            '$_tag -> fetchProfile() [${stackTrace.toString().split('\n').first}]',
      );
    }

    // 2. Check local persisted profile in AppPreferences
    try {
      final savedData = AppPreferences.getProfileData();
      if (savedData != null) {
        return EmployeeProfileModel.fromJson(savedData);
      }
    } catch (_) {}

    // 3. No dummy data: return null
    return null;
  }

  /// Fetches employee profile by ID from GET /api/v1/employees/{id}.
  /// Strictly adheres to doc/api.md and uses identical response format as /me/profile.
  Future<EmployeeProfileModel?> fetchEmployeeProfile(
    String employeeId, {
    String? nameHint,
    String? codeHint,
    String? deptHint,
    String? desigHint,
  }) async {
    try {
      final response = await ApiClient.request(
        endpoint: ApiEndpoints.employeeDetails(employeeId),
        method: HttpMethod.get,
        tag: '$_tag -> fetchEmployeeProfile($employeeId)',
        showToastOnError: false,
      );

      if (response != null && response is Map) {
        final Map<String, dynamic> responseMap =
            Map<String, dynamic>.from(response);
        return EmployeeProfileModel.fromJson(responseMap);
      }
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Remote employee profile fetch failed: $e'),
        tag:
            '$_tag -> fetchEmployeeProfile() [${stackTrace.toString().split('\n').first}]',
      );
    }

    // Zero dummy data: return null on failure
    return null;
  }

  /// Updates workplace profile credentials
  Future<bool> updateProfile(EmployeeProfileModel profile) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      await AppPreferences.setProfileData(profile.toJson());

      // Sync active user credentials in AppPreferences
      final currentUser = AppPreferences.getUser();
      if (currentUser != null) {
        final updatedUserData = currentUser.toJson();
        updatedUserData['name'] = profile.name;
        updatedUserData['email'] = profile.email;
        await AppPreferences.setUser(updatedUserData);
      }
      return true;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to update employee profile: $e'),
        tag:
            '$_tag -> updateProfile() [${stackTrace.toString().split('\n').first}]',
      );
      return false;
    }
  }

  /// Updates workplace notification or biometric preferences
  Future<bool> updatePreferences({
    bool? biometric,
    bool? reminders,
    bool? geofence,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));

      final current = await fetchProfile();
      if (current != null) {
        final updated = current.copyWith(
          biometricEnabled: biometric ?? current.biometricEnabled,
          remindersEnabled: reminders ?? current.remindersEnabled,
          geofenceAutoCheck: geofence ?? current.geofenceAutoCheck,
        );
        await AppPreferences.setProfileData(updated.toJson());
      }
      return true;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to update preferences: $e'),
        tag:
            '$_tag -> updatePreferences() [${stackTrace.toString().split('\n').first}]',
      );
      return false;
    }
  }

  /// Terminates the active session on the server via POST /api/v1/auth/logout.
  /// Server responds with 204 No Content.
  Future<bool> logout() async {
    try {
      await ApiClient.request(
        endpoint: ApiEndpoints.logout,
        method: HttpMethod.post,
        tag: '$_tag -> logout()',
        showToastOnError: false,
      );
      return true;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Remote logout failed: $e'),
        tag: '$_tag -> logout() [${stackTrace.toString().split('\n').first}]',
        showToast: false,
      );
      return false;
    }
  }
}
