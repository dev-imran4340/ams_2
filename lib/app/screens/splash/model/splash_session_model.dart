class SplashSessionModel {
  final String? userId;
  final String? email;
  final String? token;
  final bool isValid;

  SplashSessionModel({
    this.userId,
    this.email,
    this.token,
    this.isValid = false,
  });

  factory SplashSessionModel.fromJson(Map<String, dynamic> json) {
    return SplashSessionModel(
      userId: json['user_id']?.toString() ?? json['id']?.toString(),
      email: json['email']?.toString(),
      token: json['token']?.toString(),
      isValid: json['is_valid'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      'token': token,
      'is_valid': isValid,
    };
  }
}
