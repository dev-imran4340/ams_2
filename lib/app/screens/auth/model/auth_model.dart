class UserModel {
  final String? id;
  final String? name;
  final String? email;
  final String? employeeId;
  final String? designation;
  final String? department;
  final String? avatarUrl;
  final String? accountType; // 'organization' or 'individual'

  UserModel({
    this.id,
    this.name,
    this.email,
    this.employeeId,
    this.designation,
    this.department,
    this.avatarUrl,
    this.accountType,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? json['user_id']?.toString(),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      employeeId: json['employee_id']?.toString(),
      designation: json['designation']?.toString(),
      department: json['department']?.toString(),
      avatarUrl: json['avatar_url']?.toString(),
      accountType: json['account_type']?.toString() ?? 'organization',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'employee_id': employeeId,
      'designation': designation,
      'department': department,
      'avatar_url': avatarUrl,
      'account_type': accountType,
    };
  }
}

class LoginResponseModel {
  final String? token;
  final String? refreshToken;
  final UserModel? user;
  final String? message;

  LoginResponseModel({
    this.token,
    this.refreshToken,
    this.user,
    this.message,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : (json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : null);

    return LoginResponseModel(
      token: json['token']?.toString() ?? json['access_token']?.toString(),
      refreshToken: json['refresh_token']?.toString(),
      user: userData != null ? UserModel.fromJson(userData) : null,
      message: json['message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refresh_token': refreshToken,
      'user': user?.toJson(),
      'message': message,
    };
  }
}
