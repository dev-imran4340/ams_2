class TrainingCourseModel {
  final String id;
  final String name;
  final String provider;
  final String? description;
  final int validityMonths;
  final bool isRequired;
  final bool isActive;

  const TrainingCourseModel({
    required this.id,
    required this.name,
    required this.provider,
    this.description,
    this.validityMonths = 12,
    this.isRequired = false,
    this.isActive = true,
  });

  factory TrainingCourseModel.fromJson(Map<String, dynamic> json) {
    return TrainingCourseModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Training Course',
      provider: json['provider']?.toString() ?? 'Corporate Learning',
      description: json['description']?.toString(),
      validityMonths: (json['validity_months'] as num?)?.toInt() ?? 12,
      isRequired: json['is_required'] == true,
      isActive: json['is_active'] != false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'provider': provider,
      if (description != null) 'description': description,
      'validity_months': validityMonths,
      'is_required': isRequired,
      'is_active': isActive,
    };
  }
}

class TrainingRequiredModel {
  final TrainingCourseModel course;
  final bool valid;

  const TrainingRequiredModel({
    required this.course,
    this.valid = false,
  });

  factory TrainingRequiredModel.fromJson(Map<String, dynamic> json) {
    final courseJson = json['course'] is Map<String, dynamic>
        ? json['course'] as Map<String, dynamic>
        : <String, dynamic>{};

    return TrainingRequiredModel(
      course: TrainingCourseModel.fromJson(courseJson),
      valid: json['valid'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'course': course.toJson(),
      'valid': valid,
    };
  }
}

class TrainingRecordModel {
  final String id;
  final String? employeeId;
  final String? employeeName;
  final TrainingCourseModel course;
  final String? trainer;
  final String? startedOn;
  final String? completedOn;
  final int? durationMinutes;
  final String result; // 'attended', 'passed', 'failed'
  final String resultLabel;
  final String? expiresOn;
  final bool isValid;
  final String? note;
  final String? certificateUrl;

  const TrainingRecordModel({
    required this.id,
    this.employeeId,
    this.employeeName,
    required this.course,
    this.trainer,
    this.startedOn,
    this.completedOn,
    this.durationMinutes,
    this.result = 'attended',
    this.resultLabel = 'Attended',
    this.expiresOn,
    this.isValid = true,
    this.note,
    this.certificateUrl,
  });

  factory TrainingRecordModel.fromJson(Map<String, dynamic> json) {
    final courseJson = json['course'] is Map<String, dynamic>
        ? json['course'] as Map<String, dynamic>
        : <String, dynamic>{};

    String? empId;
    String? empName;
    if (json['employee'] is Map<String, dynamic>) {
      empId = json['employee']['id']?.toString();
      empName = json['employee']['name']?.toString();
    } else if (json['employee'] != null) {
      empId = json['employee'].toString();
    }

    return TrainingRecordModel(
      id: json['id']?.toString() ?? '',
      employeeId: empId,
      employeeName: empName,
      course: TrainingCourseModel.fromJson(courseJson),
      trainer: json['trainer']?.toString(),
      startedOn: json['started_on']?.toString(),
      completedOn: json['completed_on']?.toString(),
      durationMinutes: (json['duration_minutes'] as num?)?.toInt(),
      result: json['result']?.toString() ?? 'attended',
      resultLabel: json['result_label']?.toString() ??
          (json['result']?.toString().toUpperCase() ?? 'ATTENDED'),
      expiresOn: json['expires_on']?.toString(),
      isValid: json['is_valid'] == true,
      note: json['note']?.toString(),
      certificateUrl: json['certificate_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (employeeId != null)
        'employee': {
          'id': employeeId,
          if (employeeName != null) 'name': employeeName,
        },
      'course': course.toJson(),
      if (trainer != null) 'trainer': trainer,
      if (startedOn != null) 'started_on': startedOn,
      if (completedOn != null) 'completed_on': completedOn,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      'result': result,
      'result_label': resultLabel,
      if (expiresOn != null) 'expires_on': expiresOn,
      'is_valid': isValid,
      if (note != null) 'note': note,
      if (certificateUrl != null) 'certificate_url': certificateUrl,
    };
  }

  bool get isPassed => result.toLowerCase() == 'passed';
  bool get isFailed => result.toLowerCase() == 'failed';
  bool get hasCertificate =>
      certificateUrl != null && certificateUrl!.trim().isNotEmpty;
}

class TrainingDataModel {
  final List<TrainingRequiredModel> required;
  final List<TrainingRecordModel> records;

  const TrainingDataModel({
    this.required = const [],
    this.records = const [],
  });

  factory TrainingDataModel.fromJson(Map<String, dynamic> json) {
    List<TrainingRequiredModel> requiredList = [];
    if (json['required'] is List) {
      requiredList = (json['required'] as List)
          .whereType<Map<String, dynamic>>()
          .map((item) => TrainingRequiredModel.fromJson(item))
          .toList();
    }

    List<TrainingRecordModel> recordsList = [];
    if (json['records'] is List) {
      recordsList = (json['records'] as List)
          .whereType<Map<String, dynamic>>()
          .map((item) => TrainingRecordModel.fromJson(item))
          .toList();
    }

    return TrainingDataModel(
      required: requiredList,
      records: recordsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'required': required.map((e) => e.toJson()).toList(),
      'records': records.map((e) => e.toJson()).toList(),
    };
  }
}
