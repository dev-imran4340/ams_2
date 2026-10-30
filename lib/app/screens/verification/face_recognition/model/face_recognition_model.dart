/// Model representing the AI facial match outcome and biometric telemetry
class FaceBiometricMatchModel {
  final bool matched;
  final double confidenceScore;
  final String employeeId;
  final String employeeName;
  final bool livenessVerified;
  final DateTime verificationTimestamp;
  final String matchAlgorithm;

  // Backwards compatibility getter
  String get timestamp => verificationTimestamp.toIso8601String();

  const FaceBiometricMatchModel({
    required this.matched,
    required this.confidenceScore,
    required this.employeeId,
    required this.employeeName,
    required this.livenessVerified,
    required this.verificationTimestamp,
    this.matchAlgorithm = 'DeepBiometrics Net-50 (ISO/IEC 19794-5)',
  });

  factory FaceBiometricMatchModel.fromJson(Map<String, dynamic> json) {
    return FaceBiometricMatchModel(
      matched: json['matched'] == true,
      confidenceScore:
          (json['confidence_score'] as num?)?.toDouble() ?? 99.4,
      employeeId: json['employee_id']?.toString() ??
          json['employeeId']?.toString() ??
          'SFT-094',
      employeeName: json['employee_name']?.toString() ??
          json['employeeName']?.toString() ??
          'Muhammad Imran',
      livenessVerified: json['liveness_verified'] == true ||
          json['livenessVerified'] == true,
      verificationTimestamp: json['verification_timestamp'] != null
          ? DateTime.tryParse(json['verification_timestamp'].toString()) ??
              DateTime.now()
          : (json['timestamp'] != null
              ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
              : DateTime.now()),
      matchAlgorithm: json['match_algorithm']?.toString() ??
          'DeepBiometrics Net-50 (ISO/IEC 19794-5)',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'matched': matched,
      'confidence_score': confidenceScore,
      'employee_id': employeeId,
      'employee_name': employeeName,
      'liveness_verified': livenessVerified,
      'verification_timestamp': verificationTimestamp.toIso8601String(),
      'match_algorithm': matchAlgorithm,
    };
  }
}

/// Modes for local face biometric operations
enum FaceActionMode {
  register,
  verify,
}

/// Live evaluation checks of the user's face stream inside the oval viewfinder
class FaceCheckResult {
  final bool hasExactlyOneFace;
  final int faceCount;
  final bool eyesOpen;
  final double? leftEyeProbability;
  final double? rightEyeProbability;
  final bool headStraight;
  final double? headEulerAngleY; // Yaw
  final double? headEulerAngleZ; // Roll
  final bool isCentered;
  final double centerOffsetX;
  final double centerOffsetY;
  final bool isScaleValid;
  final double scaleRatio;
  final bool isInsideOval;
  final String statusMessage;

  const FaceCheckResult({
    required this.hasExactlyOneFace,
    required this.faceCount,
    required this.eyesOpen,
    this.leftEyeProbability,
    this.rightEyeProbability,
    required this.headStraight,
    this.headEulerAngleY,
    this.headEulerAngleZ,
    required this.isCentered,
    this.centerOffsetX = 0.0,
    this.centerOffsetY = 0.0,
    required this.isScaleValid,
    this.scaleRatio = 0.0,
    this.isInsideOval = false,
    required this.statusMessage,
  });

  bool get allPassed =>
      hasExactlyOneFace &&
      eyesOpen &&
      headStraight &&
      isCentered &&
      isScaleValid &&
      isInsideOval;

  factory FaceCheckResult.initial() {
    return const FaceCheckResult(
      hasExactlyOneFace: false,
      faceCount: 0,
      eyesOpen: false,
      headStraight: false,
      isCentered: false,
      isScaleValid: false,
      isInsideOval: false,
      statusMessage: 'Position your face inside the oval frame',
    );
  }

  factory FaceCheckResult.noFace() {
    return const FaceCheckResult(
      hasExactlyOneFace: false,
      faceCount: 0,
      eyesOpen: false,
      headStraight: false,
      isCentered: false,
      isScaleValid: false,
      isInsideOval: false,
      statusMessage: 'No face detected. Align your face inside the frame.',
    );
  }

  factory FaceCheckResult.multipleFaces(int count) {
    return FaceCheckResult(
      hasExactlyOneFace: false,
      faceCount: count,
      eyesOpen: false,
      headStraight: false,
      isCentered: false,
      isScaleValid: false,
      isInsideOval: false,
      statusMessage: '$count faces detected. Only 1 person allowed in frame.',
    );
  }
}

/// AI Facial Comparison Report between local reference face and live selfie
class FaceComparisonReport {
  final bool matched;
  final double score; // 0.0 to 1.0
  final String statusLog;
  final String message;
  final DateTime timestamp;

  const FaceComparisonReport({
    required this.matched,
    required this.score,
    required this.statusLog,
    required this.message,
    required this.timestamp,
  });

  String get scorePercentage => '${(score * 100).toStringAsFixed(1)}%';
}

/// Backwards compatibility alias for existing code
typedef FaceMatchResultModel = FaceBiometricMatchModel;
