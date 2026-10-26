import 'dart:async';

import '../../../api/api_client.dart';
import '../../../api/api_endpoints.dart';
import '../../../api/app_preferences.dart';
import '../../../api/exception_handler.dart';
import '../../profile/model/profile_model.dart';
import '../model/edit_profile_model.dart';

class EditProfileRepo {
  static const String _tag = 'EditProfileRepo / EditProfileScreen';

  /// Fetches executive employee profile from GET /api/v1/me/profile
  Future<EmployeeProfileModel?> fetchCurrentProfile() async {
    try {
      final response = await ApiClient.request(
        endpoint: ApiEndpoints.meProfile,
        method: HttpMethod.get,
        tag: '$_tag -> fetchCurrentProfile()',
        showToastOnError: false,
      );

      if (response != null && response is Map) {
        final Map<String, dynamic> responseMap =
            Map<String, dynamic>.from(response);

        // Cache live profile payload locally in AppPreferences
        await AppPreferences.setProfileData(responseMap);

        return EmployeeProfileModel.fromJson(responseMap);
      }
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Remote profile fetch failed: $e'),
        tag:
            '$_tag -> fetchCurrentProfile() [${stackTrace.toString().split('\n').first}]',
      );
    }

    // Offline cache fallback
    try {
      final savedData = AppPreferences.getProfileData();
      if (savedData != null) {
        return EmployeeProfileModel.fromJson(savedData);
      }
    } catch (_) {}

    return null;
  }

  /// Submits contact & personal details change request via POST /me/details-change
  /// Contract: kind: "details"
  Future<DetailsChangeResponse> submitPersonalDetailsChange(
    PersonalDetailsChangeRequest request,
  ) async {
    final response = await ApiClient.request(
      endpoint: ApiEndpoints.meDetailsChange,
      method: HttpMethod.post,
      body: request.toJson(),
      tag: '$_tag -> submitPersonalDetailsChange()',
      showToastOnError: false,
    );

    if (response != null && response is Map && response['data'] is Map) {
      return DetailsChangeResponse.fromJson(
        Map<String, dynamic>.from(response['data'] as Map),
      );
    }

    throw ApiException(
      message: 'Unexpected server response for details change request.',
      errorCode: 'INVALID_RESPONSE',
    );
  }

  /// Submits emergency contact addition or modification via POST /me/details-change
  /// Contract: kind: "emergency_contact"
  Future<DetailsChangeResponse> submitEmergencyContactChange(
    EmergencyContactChangeRequest request,
  ) async {
    final response = await ApiClient.request(
      endpoint: ApiEndpoints.meDetailsChange,
      method: HttpMethod.post,
      body: request.toJson(),
      tag: '$_tag -> submitEmergencyContactChange()',
      showToastOnError: false,
    );

    if (response != null && response is Map && response['data'] is Map) {
      return DetailsChangeResponse.fromJson(
        Map<String, dynamic>.from(response['data'] as Map),
      );
    }

    throw ApiException(
      message: 'Unexpected server response for emergency contact request.',
      errorCode: 'INVALID_RESPONSE',
    );
  }

  /// Checks whether employee already has a details-change request waiting for approval in /approvals?box=mine
  Future<bool> hasPendingDetailsChangeRequest() async {
    try {
      final response = await ApiClient.request(
        endpoint: ApiEndpoints.approvals,
        method: HttpMethod.get,
        queryParameters: {
          'box': 'mine',
          'type': 'employee_details_change',
          'per_page': '5',
        },
        tag: '$_tag -> hasPendingDetailsChangeRequest()',
        showToastOnError: false,
      );

      if (response != null && response is Map && response['data'] is List) {
        final list = response['data'] as List;
        for (final item in list) {
          if (item is Map) {
            final status = item['status']?.toString().toLowerCase();
            if (status == 'pending' || status == 'waiting') {
              return true;
            }
          }
        }
      }
    } catch (_) {}
    return false;
  }
}
