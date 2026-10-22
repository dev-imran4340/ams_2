import 'dart:async';

import '../../../api/app_preferences.dart';
import '../../../api/exception_handler.dart';
import '../../profile/model/profile_model.dart';
import '../model/edit_profile_model.dart';

class EditProfileRepo {
  static const String _tag = 'EditProfileRepo / EditProfileScreen';

  /// Fetches current employee profile credentials from storage/mock
  Future<EmployeeProfileModel?> fetchCurrentProfile() async {
    try {
      await Future.delayed(const Duration(milliseconds: 250));

      final savedData = AppPreferences.getProfileData();
      if (savedData != null) {
        return EmployeeProfileModel.fromJson(savedData);
      }

      final cachedUser = AppPreferences.getUser();
      return EmployeeProfileModel(
        name: cachedUser?.name ?? 'Malik Muhammad Imran',
        email: cachedUser?.email ?? 'imran@Softech Business Services.com',
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
      );
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to fetch current profile: $e'),
        tag:
            '$_tag -> fetchCurrentProfile() [${stackTrace.toString().split('\n').first}]',
      );
      return null;
    }
  }

  /// Updates and persists employee profile modifications
  Future<EmployeeProfileModel?> saveProfile({
    required EmployeeProfileModel current,
    required EditProfileRequestModel request,
  }) async {
    try {
      // Realistic simulation delay for API prototyping
      await Future.delayed(const Duration(milliseconds: 600));

      final updatedProfile = request.applyTo(current);

      // Persist to isolated AppPreferences storage
      await AppPreferences.setProfileData(updatedProfile.toJson());

      // Synchronize cached user session
      final currentUser = AppPreferences.getUser();
      if (currentUser != null) {
        final userMap = currentUser.toJson();
        userMap['name'] = updatedProfile.name;
        userMap['email'] = updatedProfile.email;
        if (updatedProfile.avatarPath != null) {
          userMap['avatar_url'] = updatedProfile.avatarPath;
        }
        await AppPreferences.setUser(userMap);
      }

      return updatedProfile;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Profile update failed: $e'),
        tag:
            '$_tag -> saveProfile() [${stackTrace.toString().split('\n').first}]',
      );
      return null;
    }
  }
}
