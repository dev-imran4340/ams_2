import 'dart:async';
import '../model/auth_model.dart';

class AuthRepo {
  /// Authenticates user credentials locally for UI prototyping without remote API
  Future<LoginResponseModel?> login({
    required String email,
    required String password,
  }) async {
    // Brief local delay
    await Future.delayed(const Duration(milliseconds: 300));

    final mockUser = UserModel(
      id: 'usr_ams_9082',
      name: 'Muhammad',
      email: email.isNotEmpty ? email : 'muhammad@company.org',
      employeeId: 'EMP-0428',
      designation: 'Senior Software Engineer',
      department: 'Technology & Development',
      avatarUrl: null,
      accountType: 'organization',
    );

    return LoginResponseModel(
      token: 'ams_jwt_mock_token',
      refreshToken: 'ams_ref_mock_token',
      user: mockUser,
      message: 'Authentication successful',
    );
  }

  /// Biometric authentication mock
  Future<LoginResponseModel?> authenticateWithBiometrics() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final mockUser = UserModel(
      id: 'usr_ams_9082',
      name: 'Muhammad',
      email: 'muhammad@company.org',
      employeeId: 'EMP-0428',
      designation: 'Senior Software Engineer',
      department: 'Technology & Development',
      avatarUrl: null,
      accountType: 'organization',
    );

    return LoginResponseModel(
      token: 'ams_bio_mock_token',
      refreshToken: 'ams_bio_ref_mock_token',
      user: mockUser,
      message: 'Biometric verification successful',
    );
  }
}
