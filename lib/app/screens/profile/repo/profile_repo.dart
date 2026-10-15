import 'dart:async';

import '../../../api/app_preferences.dart';
import '../../../api/exception_handler.dart';
import '../model/profile_model.dart';

class ProfileRepo {
  static const String _tag = 'ProfileRepo';

  /// Fetches executive employee profile and work shift details
  Future<EmployeeProfileModel?> fetchProfile() async {
    try {
      // Realistic simulation delay for smooth UX transition
      await Future.delayed(const Duration(milliseconds: 500));

      final cachedUser = AppPreferences.getUser();
      final userName = cachedUser?.name ?? 'Malik Muhammad Imran';
      final userEmail =
          cachedUser?.email ?? 'imran@Softech Business Services.com';

      return EmployeeProfileModel(
        name: userName,
        email: userEmail,
        employeeId: 'EMP-1024',
        designation: 'Senior Software Engineer & Tech Lead',
        department: 'Engineering & Mobility',
        joiningDate: '15 Jan 2024',
        reportingManager: 'Hamza Sheikh (Lead Architect)',
        shiftName: 'General Corporate Shift',
        shiftTime: '09:00 AM - 06:00 PM',
        graceMinutes: 15,
        workLocation: 'Softech Business Services HQ • 4th Floor',
        biometricEnabled: true,
        remindersEnabled: true,
        geofenceAutoCheck: true,
        tenureYears: '2.8 Yrs',
        attendanceScore: 98.4,
      );
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to fetch employee profile: $e'),
        tag:
            '$_tag -> fetchProfile() [${stackTrace.toString().split('\n').first}]',
      );
      return null;
    }
  }

  /// Updates workplace notification or biometric preferences
  Future<bool> updatePreferences({
    bool? biometric,
    bool? reminders,
    bool? geofence,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
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
