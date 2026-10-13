/// Model representing the AI facial match outcome and biometric telemetry
class FaceMatchResultModel {
  final bool matched;
  final double confidenceScore;
  final String employeeName;
  final String employeeId;
  final bool livenessVerified;
  final String timestamp;
  final String matchAlgorithm;

  const FaceMatchResultModel({
    required this.matched,
    required this.confidenceScore,
    required this.employeeName,
    required this.employeeId,
    required this.livenessVerified,
    required this.timestamp,
    this.matchAlgorithm = 'DeepBiometrics Net-50 (ISO/IEC 19794-5)',
  });

  factory FaceMatchResultModel.fromJson(Map<String, dynamic> json) {
    return FaceMatchResultModel(
      matched: json['matched'] == true,
      confidenceScore:
          (json['confidence_score'] as num?)?.toDouble() ?? 99.4,
      employeeName: json['employee_name']?.toString() ?? 'Muhammad Imran',
      employeeId: json['employee_id']?.toString() ?? 'EMP-0428',
      livenessVerified: json['liveness_verified'] == true,
      timestamp: json['timestamp']?.toString() ??
          DateTime.now().toIso8601String(),
      matchAlgorithm: json['match_algorithm']?.toString() ??
          'DeepBiometrics Net-50 (ISO/IEC 19794-5)',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'matched': matched,
      'confidence_score': confidenceScore,
      'employee_name': employeeName,
      'employee_id': employeeId,
      'liveness_verified': livenessVerified,
      'timestamp': timestamp,
      'match_algorithm': matchAlgorithm,
    };
  }
}
