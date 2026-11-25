/// Work location item returned by GET /kiosks/locations
class KioskLocationModel {
  final String id;
  final String name;

  const KioskLocationModel({
    required this.id,
    required this.name,
  });

  factory KioskLocationModel.fromJson(Map<String, dynamic> json) {
    return KioskLocationModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KioskLocationModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Kiosk configuration returned by POST /kiosks and GET /kiosk
class KioskConfigModel {
  final String id;
  final String name;
  final String? locationId;
  final String? locationName;
  final String? timezone;
  final bool pinAllowed;
  final String? token;

  const KioskConfigModel({
    required this.id,
    required this.name,
    this.locationId,
    this.locationName,
    this.timezone,
    this.pinAllowed = true,
    this.token,
  });

  factory KioskConfigModel.fromJson(Map<String, dynamic> json) {
    final kioskJson = json['kiosk'] is Map<String, dynamic>
        ? json['kiosk'] as Map<String, dynamic>
        : json;

    String? locId;
    String? locName;
    String? tz;

    final locData = kioskJson['location'];
    if (locData is Map<String, dynamic>) {
      locId = locData['id']?.toString();
      locName = locData['name']?.toString();
      tz = locData['timezone']?.toString();
    } else if (locData is String) {
      locId = locData;
    }

    return KioskConfigModel(
      id: kioskJson['id']?.toString() ?? '',
      name: kioskJson['name']?.toString() ?? '',
      locationId: locId,
      locationName: locName,
      timezone: tz ?? 'Asia/Karachi',
      pinAllowed: kioskJson['pin_allowed'] == true,
      token: json['token']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': {
        'id': locationId,
        'name': locationName,
        'timezone': timezone,
      },
      'pin_allowed': pinAllowed,
      if (token != null) 'token': token,
    };
  }
}

/// Person identity payload returned from POST /kiosk/identify
class KioskPersonModel {
  final String id;
  final String name;
  final String employeeNumber;
  final String? department;
  final String? designation;

  const KioskPersonModel({
    required this.id,
    required this.name,
    required this.employeeNumber,
    this.department,
    this.designation,
  });

  factory KioskPersonModel.fromJson(Map<String, dynamic> json) {
    return KioskPersonModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      employeeNumber: json['employee_number']?.toString() ?? '',
      department: json['department']?.toString(),
      designation: json['designation']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'employee_number': employeeNumber,
      if (department != null) 'department': department,
      if (designation != null) 'designation': designation,
    };
  }
}

/// Identify session response returned from POST /kiosk/identify
class KioskIdentifyResponseModel {
  final KioskPersonModel person;
  final String ticket;
  final int expiresIn;
  final bool checkedIn;
  final bool onBreak;
  final String? since;
  final String? sinceAt;
  final String? stateDate;
  final bool usesBreaks;
  final List<String> allowedActions;
  final Map<String, dynamic> refusals;
  final bool requiresPosition;
  final bool requiresPhoto;
  final String requiresFace;
  final bool faceSaved;
  final String? consentText;

  const KioskIdentifyResponseModel({
    required this.person,
    required this.ticket,
    this.expiresIn = 120,
    this.checkedIn = false,
    this.onBreak = false,
    this.since,
    this.sinceAt,
    this.stateDate,
    this.usesBreaks = false,
    this.allowedActions = const [],
    this.refusals = const {},
    this.requiresPosition = false,
    this.requiresPhoto = false,
    this.requiresFace = 'off',
    this.faceSaved = false,
    this.consentText,
  });

  bool get canCheckIn => allowedActions.contains('in');
  bool get canCheckOut => allowedActions.contains('out');
  bool get canStartBreak => allowedActions.contains('break_start');
  bool get canEndBreak => allowedActions.contains('break_end');

  String? refusalMessageFor(String kind) {
    final entry = refusals[kind];
    if (entry is Map) {
      return entry['message']?.toString();
    }
    return null;
  }

  factory KioskIdentifyResponseModel.fromJson(Map<String, dynamic> json) {
    final personData = json['person'] is Map<String, dynamic>
        ? json['person'] as Map<String, dynamic>
        : <String, dynamic>{};

    final stateData = json['state'] is Map<String, dynamic>
        ? json['state'] as Map<String, dynamic>
        : <String, dynamic>{};

    final requiresData = json['requires'] is Map<String, dynamic>
        ? json['requires'] as Map<String, dynamic>
        : <String, dynamic>{};

    final List<String> allowed = [];
    if (stateData['allowed'] is List) {
      allowed.addAll((stateData['allowed'] as List).map((e) => e.toString()));
    }

    final Map<String, dynamic> refusalsMap = {};
    if (stateData['refusals'] is Map<String, dynamic>) {
      refusalsMap.addAll(stateData['refusals'] as Map<String, dynamic>);
    }

    return KioskIdentifyResponseModel(
      person: KioskPersonModel.fromJson(personData),
      ticket: json['ticket']?.toString() ?? '',
      expiresIn: (json['expires_in'] as num?)?.toInt() ?? 120,
      checkedIn: stateData['checked_in'] == true,
      onBreak: stateData['on_break'] == true,
      since: stateData['since']?.toString(),
      sinceAt: stateData['since_at']?.toString(),
      stateDate: stateData['date']?.toString(),
      usesBreaks: stateData['uses_breaks'] == true,
      allowedActions: allowed,
      refusals: refusalsMap,
      requiresPosition: requiresData['position'] == true,
      requiresPhoto: requiresData['photo'] == true,
      requiresFace: requiresData['face']?.toString() ?? 'off',
      faceSaved: requiresData['face_saved'] == true,
      consentText: requiresData['consent_text']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'person': person.toJson(),
      'ticket': ticket,
      'expires_in': expiresIn,
      'state': {
        'checked_in': checkedIn,
        'on_break': onBreak,
        'since': since,
        'since_at': sinceAt,
        'date': stateDate,
        'uses_breaks': usesBreaks,
        'allowed': allowedActions,
        'refusals': refusals,
      },
      'requires': {
        'position': requiresPosition,
        'photo': requiresPhoto,
        'face': requiresFace,
        'face_saved': faceSaved,
        if (consentText != null) 'consent_text': consentText,
      },
    };
  }
}

/// Punch response returned from POST /kiosk/punches
class KioskPunchResultModel {
  final String punchId;
  final String time;
  final String role;
  final String source;
  final String? personId;
  final String? personName;

  const KioskPunchResultModel({
    required this.punchId,
    required this.time,
    required this.role,
    required this.source,
    this.personId,
    this.personName,
  });

  factory KioskPunchResultModel.fromJson(Map<String, dynamic> json) {
    final punchData = json['punch'] is Map<String, dynamic>
        ? json['punch'] as Map<String, dynamic>
        : json;

    final personData = json['person'] is Map<String, dynamic>
        ? json['person'] as Map<String, dynamic>
        : null;

    return KioskPunchResultModel(
      punchId: punchData['id']?.toString() ?? '',
      time: punchData['time']?.toString() ?? '',
      role: punchData['role']?.toString() ?? 'check_in',
      source: punchData['source']?.toString() ?? 'kiosk',
      personId: personData?['id']?.toString(),
      personName: personData?['name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'punch': {
        'id': punchId,
        'time': time,
        'role': role,
        'source': source,
      },
      if (personId != null || personName != null)
        'person': {
          if (personId != null) 'id': personId,
          if (personName != null) 'name': personName,
        },
    };
  }
}
