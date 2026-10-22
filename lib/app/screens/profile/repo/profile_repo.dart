import 'dart:async';

import '../../../api/app_preferences.dart';
import '../../../api/exception_handler.dart';
import '../model/profile_model.dart';

class ProfileRepo {
  static const String _tag = 'ProfileRepo / ProfileScreen';

  /// Fetches executive employee profile and work shift details
  Future<EmployeeProfileModel?> fetchProfile() async {
    try {
      // Realistic simulation delay for smooth UX transition
      await Future.delayed(const Duration(milliseconds: 350));

      // 1. Check local persisted profile in AppPreferences
      final savedData = AppPreferences.getProfileData();
      if (savedData != null) {
        return EmployeeProfileModel.fromJson(savedData);
      }

      // 2. Fallback to cached user credentials & default profile
      final cachedUser = AppPreferences.getUser();
      final userName = cachedUser?.name ?? 'Malik Muhammad Imran';
      final userEmail =
          cachedUser?.email ?? 'imran@Softech Business Services.com';

      final initialProfile = EmployeeProfileModel(
        name: userName,
        email: userEmail,
        phone: '+92 300 1234567',
        cnic: '37405-1234567-1',
        dob: '14 May 1996',
        gender: 'Male',
        bloodGroup: 'O+',
        employeeId: 'EMP-1024',
        designation: 'Senior Software Engineer & Tech Lead',
        department: 'Engineering & Mobility',
        joiningDate: '15 Jan 2024',
        reportingManager: 'Hamza Sheikh (Lead Architect)',
        shiftName: 'General Corporate Shift',
        shiftTime: '09:00 AM - 06:00 PM',
        graceMinutes: 15,
        workLocation: 'Softech Business Services HQ • 4th Floor',
        address: 'House #42, Street 8, Sector G-11/1',
        city: 'Islamabad',
        postalCode: '44000',
        emergencyContactName: 'Tariq Mehmood',
        emergencyContactPhone: '+92 321 7654321',
        emergencyContactRelation: 'Brother',
        biometricEnabled: true,
        remindersEnabled: true,
        geofenceAutoCheck: true,
        tenureYears: '2.8 Yrs',
        attendanceScore: 98.4,
      );

      // Cache initial profile
      await AppPreferences.setProfileData(initialProfile.toJson());
      return initialProfile;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to fetch employee profile: $e'),
        tag:
            '$_tag -> fetchProfile() [${stackTrace.toString().split('\n').first}]',
      );
      return null;
    }
  }

  /// Updates workplace profile credentials
  Future<bool> updateProfile(EmployeeProfileModel profile) async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      await AppPreferences.setProfileData(profile.toJson());

      // Sync active user cached credentials in AppPreferences
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
}
