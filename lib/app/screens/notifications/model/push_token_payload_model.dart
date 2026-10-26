/// Payload for registering phone FCM token via POST /push-tokens
class PushTokenPayloadModel {
  final String token;
  final String platform; // "android" or "ios"
  final String? appVersion;

  const PushTokenPayloadModel({
    required this.token,
    required this.platform,
    this.appVersion,
  });

  factory PushTokenPayloadModel.fromJson(Map<String, dynamic> json) {
    return PushTokenPayloadModel(
      token: json['token']?.toString() ?? '',
      platform: json['platform']?.toString() ?? 'android',
      appVersion: json['app_version']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'token': token,
        'platform': platform,
        if (appVersion != null) 'app_version': appVersion,
      };
}
