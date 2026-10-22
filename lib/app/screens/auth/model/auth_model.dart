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

class LoginRequestModel {
  final String login;
  final String password;
  final String? companyCode;
  final String? deviceName;

  LoginRequestModel({
    required this.login,
    required this.password,
    this.companyCode,
    this.deviceName,
  });

  Map<String, dynamic> toJson() {
    return {
      'login': login.trim(),
      if (companyCode != null && companyCode!.trim().isNotEmpty)
        'company_code': companyCode!.trim(),
      'password': password,
      'device_name': deviceName ?? 'AMS Mobile',
    };
  }
}

class LoginResponseModel {
  final bool twoFactorRequired;
  final String? token;
  final String? challenge;
  final String? refreshToken;
  final UserModel? user;
  final String? message;

  LoginResponseModel({
    this.twoFactorRequired = false,
    this.token,
    this.challenge,
    this.refreshToken,
    this.user,
    this.message,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    // Check if wrapped in data envelope
    final Map<String, dynamic> data = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;

    final userData = data['user'] is Map<String, dynamic>
        ? data['user'] as Map<String, dynamic>
        : (json['user'] is Map<String, dynamic> ? json['user'] as Map<String, dynamic> : null);

    return LoginResponseModel(
      twoFactorRequired: data['two_factor_required'] == true,
      token: data['token']?.toString() ?? data['access_token']?.toString() ?? json['token']?.toString(),
      challenge: data['challenge']?.toString(),
      refreshToken: data['refresh_token']?.toString() ?? json['refresh_token']?.toString(),
      user: userData != null ? UserModel.fromJson(userData) : null,
      message: data['message']?.toString() ?? json['message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'two_factor_required': twoFactorRequired,
      'token': token,
      'challenge': challenge,
      'refresh_token': refreshToken,
      'user': user?.toJson(),
      'message': message,
    };
  }
}

class TwoFactorRequestModel {
  final String challenge;
  final String? code;
  final String? recoveryCode;

  TwoFactorRequestModel({
    required this.challenge,
    this.code,
    this.recoveryCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'challenge': challenge,
      if (code != null && code!.trim().isNotEmpty) 'code': code!.trim(),
      if (recoveryCode != null && recoveryCode!.trim().isNotEmpty)
        'recovery_code': recoveryCode!.trim(),
    };
  }
}

class TwoFactorResponseModel {
  final String? token;

  TwoFactorResponseModel({this.token});

  factory TwoFactorResponseModel.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;
    return TwoFactorResponseModel(
      token: data['token']?.toString() ?? json['token']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
    };
  }
}

class ForgotPasswordRequestModel {
  final String email;

  ForgotPasswordRequestModel({required this.email});

  Map<String, dynamic> toJson() {
    return {
      'email': email.trim(),
    };
  }
}

class ForgotPasswordResponseModel {
  final String? message;

  ForgotPasswordResponseModel({this.message});

  factory ForgotPasswordResponseModel.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;
    return ForgotPasswordResponseModel(
      message: data['message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
    };
  }
}

