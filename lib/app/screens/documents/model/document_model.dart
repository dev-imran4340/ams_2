// Phase 17 Documents, Company Policies & Official Letters Models
// Matches production schemas from doc/api.md

class CompanyDocumentListItemModel {
  final String id;
  final String kind;
  final String kindLabel;
  final String title;
  final String? description;
  final int version;
  final String? publishedOn;
  final String? expiresOn;
  final bool requiresAcknowledgement;
  final bool? acknowledged;
  final bool isActive;

  const CompanyDocumentListItemModel({
    required this.id,
    required this.kind,
    required this.kindLabel,
    required this.title,
    this.description,
    required this.version,
    this.publishedOn,
    this.expiresOn,
    required this.requiresAcknowledgement,
    this.acknowledged,
    required this.isActive,
  });

  factory CompanyDocumentListItemModel.fromJson(Map<String, dynamic> json) {
    return CompanyDocumentListItemModel(
      id: json['id']?.toString() ?? '',
      kind: json['kind']?.toString() ?? 'policy',
      kindLabel: json['kind_label']?.toString() ?? 'Policy',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      version: (json['version'] as num?)?.toInt() ?? 1,
      publishedOn: json['published_on']?.toString(),
      expiresOn: json['expires_on']?.toString(),
      requiresAcknowledgement: json['requires_acknowledgement'] == true,
      acknowledged: json['acknowledged'] as bool?,
      isActive: json['is_active'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kind': kind,
      'kind_label': kindLabel,
      'title': title,
      'description': description,
      'version': version,
      'published_on': publishedOn,
      'expires_on': expiresOn,
      'requires_acknowledgement': requiresAcknowledgement,
      'acknowledged': acknowledged,
      'is_active': isActive,
    };
  }

  CompanyDocumentListItemModel copyWith({
    bool? acknowledged,
  }) {
    return CompanyDocumentListItemModel(
      id: id,
      kind: kind,
      kindLabel: kindLabel,
      title: title,
      description: description,
      version: version,
      publishedOn: publishedOn,
      expiresOn: expiresOn,
      requiresAcknowledgement: requiresAcknowledgement,
      acknowledged: acknowledged ?? this.acknowledged,
      isActive: isActive,
    );
  }
}

class DocumentVersionModel {
  final String id;
  final int version;
  final String publishedAt;
  final String? publishedBy;
  final String? changeNote;
  final bool asksAgain;
  final String? body;
  final String? fileName;

  const DocumentVersionModel({
    required this.id,
    required this.version,
    required this.publishedAt,
    this.publishedBy,
    this.changeNote,
    required this.asksAgain,
    this.body,
    this.fileName,
  });

  factory DocumentVersionModel.fromJson(Map<String, dynamic> json) {
    return DocumentVersionModel(
      id: json['id']?.toString() ?? '',
      version: (json['version'] as num?)?.toInt() ?? 1,
      publishedAt: json['published_at']?.toString() ?? '',
      publishedBy: json['published_by']?.toString(),
      changeNote: json['change_note']?.toString(),
      asksAgain: json['asks_again'] == true,
      body: json['body']?.toString(),
      fileName: json['file_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'version': version,
      'published_at': publishedAt,
      'published_by': publishedBy,
      'change_note': changeNote,
      'asks_again': asksAgain,
      'body': body,
      'file_name': fileName,
    };
  }
}

class CompanyDocumentDetailsModel {
  final String id;
  final String kind;
  final String kindLabel;
  final String title;
  final String? description;
  final int version;
  final String? publishedOn;
  final String? expiresOn;
  final bool requiresAcknowledgement;
  final bool? acknowledged;
  final bool isActive;
  final DocumentVersionModel? currentVersion;
  final List<DocumentVersionModel> versions;

  const CompanyDocumentDetailsModel({
    required this.id,
    required this.kind,
    required this.kindLabel,
    required this.title,
    this.description,
    required this.version,
    this.publishedOn,
    this.expiresOn,
    required this.requiresAcknowledgement,
    this.acknowledged,
    required this.isActive,
    this.currentVersion,
    this.versions = const [],
  });

  factory CompanyDocumentDetailsModel.fromJson(Map<String, dynamic> json) {
    final curVerRaw = json['current_version'];
    final versionsRaw = json['versions'];

    return CompanyDocumentDetailsModel(
      id: json['id']?.toString() ?? '',
      kind: json['kind']?.toString() ?? 'policy',
      kindLabel: json['kind_label']?.toString() ?? 'Policy',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      version: (json['version'] as num?)?.toInt() ?? 1,
      publishedOn: json['published_on']?.toString(),
      expiresOn: json['expires_on']?.toString(),
      requiresAcknowledgement: json['requires_acknowledgement'] == true,
      acknowledged: json['acknowledged'] as bool?,
      isActive: json['is_active'] == true,
      currentVersion: curVerRaw is Map<String, dynamic>
          ? DocumentVersionModel.fromJson(curVerRaw)
          : null,
      versions: versionsRaw is List
          ? versionsRaw
              .whereType<Map<String, dynamic>>()
              .map((v) => DocumentVersionModel.fromJson(v))
              .toList()
          : const [],
    );
  }

  CompanyDocumentDetailsModel copyWith({
    bool? acknowledged,
  }) {
    return CompanyDocumentDetailsModel(
      id: id,
      kind: kind,
      kindLabel: kindLabel,
      title: title,
      description: description,
      version: version,
      publishedOn: publishedOn,
      expiresOn: expiresOn,
      requiresAcknowledgement: requiresAcknowledgement,
      acknowledged: acknowledged ?? this.acknowledged,
      isActive: isActive,
      currentVersion: currentVersion,
      versions: versions,
    );
  }
}

class DocumentCategoryModel {
  final String id;
  final String name;
  final String? visibility;
  final String? visibilityLabel;

  const DocumentCategoryModel({
    required this.id,
    required this.name,
    this.visibility,
    this.visibilityLabel,
  });

  factory DocumentCategoryModel.fromJson(Map<String, dynamic> json) {
    return DocumentCategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      visibility: json['visibility']?.toString(),
      visibilityLabel: json['visibility_label']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'visibility': visibility,
      'visibility_label': visibilityLabel,
    };
  }
}

class DocumentEmployeeRef {
  final String id;
  final String name;
  final String? number;

  const DocumentEmployeeRef({
    required this.id,
    required this.name,
    this.number,
  });

  factory DocumentEmployeeRef.fromJson(Map<String, dynamic> json) {
    return DocumentEmployeeRef(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      number: json['number']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'number': number,
    };
  }
}

class DocumentFileItemModel {
  final String id;
  final String title;
  final DocumentCategoryModel? category;
  final String? expiresOn;
  final String? expiryTone;
  final String? note;
  final String fileName;
  final String size;
  final String? uploadedOn;
  final String? uploadedBy;

  const DocumentFileItemModel({
    required this.id,
    required this.title,
    this.category,
    this.expiresOn,
    this.expiryTone,
    this.note,
    required this.fileName,
    required this.size,
    this.uploadedOn,
    this.uploadedBy,
  });

  factory DocumentFileItemModel.fromJson(Map<String, dynamic> json) {
    final catRaw = json['category'];
    return DocumentFileItemModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      category: catRaw is Map<String, dynamic>
          ? DocumentCategoryModel.fromJson(catRaw)
          : null,
      expiresOn: json['expires_on']?.toString(),
      expiryTone: json['expiry_tone']?.toString(),
      note: json['note']?.toString(),
      fileName: json['file_name']?.toString() ?? '',
      size: json['size']?.toString() ?? '',
      uploadedOn: json['uploaded_on']?.toString(),
      uploadedBy: json['uploaded_by']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category?.toJson(),
      'expires_on': expiresOn,
      'expiry_tone': expiryTone,
      'note': note,
      'file_name': fileName,
      'size': size,
      'uploaded_on': uploadedOn,
      'uploaded_by': uploadedBy,
    };
  }
}

class ExpiringDocumentItemModel {
  final String source;
  final String sourceLabel;
  final String title;
  final String expiresOn;
  final int daysLeft;
  final String when;
  final String? tone;
  final DocumentEmployeeRef? employee;
  final String? documentId;
  final String? profileTab;

  const ExpiringDocumentItemModel({
    required this.source,
    required this.sourceLabel,
    required this.title,
    required this.expiresOn,
    required this.daysLeft,
    required this.when,
    this.tone,
    this.employee,
    this.documentId,
    this.profileTab,
  });

  factory ExpiringDocumentItemModel.fromJson(Map<String, dynamic> json) {
    final empRaw = json['employee'];
    return ExpiringDocumentItemModel(
      source: json['source']?.toString() ?? '',
      sourceLabel: json['source_label']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      expiresOn: json['expires_on']?.toString() ?? '',
      daysLeft: (json['days_left'] as num?)?.toInt() ?? 0,
      when: json['when']?.toString() ?? '',
      tone: json['tone']?.toString(),
      employee: empRaw is Map<String, dynamic>
          ? DocumentEmployeeRef.fromJson(empRaw)
          : null,
      documentId: json['document_id']?.toString(),
      profileTab: json['profile_tab']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'source': source,
      'source_label': sourceLabel,
      'title': title,
      'expires_on': expiresOn,
      'days_left': daysLeft,
      'when': when,
      'tone': tone,
      'employee': employee?.toJson(),
      'document_id': documentId,
      'profile_tab': profileTab,
    };
  }
}

class IssuedLetterItemModel {
  final String id;
  final String reference;
  final String kind;
  final String kindLabel;
  final String subject;
  final String? issuedOn;
  final String? issuedBy;
  final bool shared;
  final bool isVoid;
  final String? voidReason;
  final DocumentEmployeeRef? employee;
  final String? body;

  const IssuedLetterItemModel({
    required this.id,
    required this.reference,
    required this.kind,
    required this.kindLabel,
    required this.subject,
    this.issuedOn,
    this.issuedBy,
    required this.shared,
    required this.isVoid,
    this.voidReason,
    this.employee,
    this.body,
  });

  factory IssuedLetterItemModel.fromJson(Map<String, dynamic> json) {
    final empRaw = json['employee'];
    return IssuedLetterItemModel(
      id: json['id']?.toString() ?? '',
      reference: json['reference']?.toString() ?? '',
      kind: json['kind']?.toString() ?? 'letter',
      kindLabel: json['kind_label']?.toString() ?? 'Letter',
      subject: json['subject']?.toString() ?? '',
      issuedOn: json['issued_on']?.toString(),
      issuedBy: json['issued_by']?.toString(),
      shared: json['shared'] == true,
      isVoid: json['void'] == true,
      voidReason: json['void_reason']?.toString(),
      employee: empRaw is Map<String, dynamic>
          ? DocumentEmployeeRef.fromJson(empRaw)
          : null,
      body: json['body']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reference': reference,
      'kind': kind,
      'kind_label': kindLabel,
      'subject': subject,
      'issued_on': issuedOn,
      'issued_by': issuedBy,
      'shared': shared,
      'void': isVoid,
      'void_reason': voidReason,
      'employee': employee?.toJson(),
      'body': body,
    };
  }

  IssuedLetterItemModel copyWith({
    String? id,
    String? reference,
    String? kind,
    String? kindLabel,
    String? subject,
    String? issuedOn,
    String? issuedBy,
    bool? shared,
    bool? isVoid,
    String? voidReason,
    DocumentEmployeeRef? employee,
    String? body,
  }) {
    return IssuedLetterItemModel(
      id: id ?? this.id,
      reference: reference ?? this.reference,
      kind: kind ?? this.kind,
      kindLabel: kindLabel ?? this.kindLabel,
      subject: subject ?? this.subject,
      issuedOn: issuedOn ?? this.issuedOn,
      issuedBy: issuedBy ?? this.issuedBy,
      shared: shared ?? this.shared,
      isVoid: isVoid ?? this.isVoid,
      voidReason: voidReason ?? this.voidReason,
      employee: employee ?? this.employee,
      body: body ?? this.body,
    );
  }
}

class LetterRequestItemModel {
  final String id;
  final String letter;
  final String purpose;
  final String status;
  final String statusLabel;
  final String? requestedOn;
  final String? letterId;

  const LetterRequestItemModel({
    required this.id,
    required this.letter,
    required this.purpose,
    required this.status,
    required this.statusLabel,
    this.requestedOn,
    this.letterId,
  });

  factory LetterRequestItemModel.fromJson(Map<String, dynamic> json) {
    return LetterRequestItemModel(
      id: json['id']?.toString() ?? '',
      letter: json['letter']?.toString() ?? '',
      purpose: json['purpose']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      statusLabel: json['status_label']?.toString() ?? 'Pending',
      requestedOn: json['requested_on']?.toString(),
      letterId: json['letter_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'letter': letter,
      'purpose': purpose,
      'status': status,
      'status_label': statusLabel,
      'requested_on': requestedOn,
      'letter_id': letterId,
    };
  }
}

class RequestableLetterItemModel {
  final String id;
  final String name;

  const RequestableLetterItemModel({
    required this.id,
    required this.name,
  });

  factory RequestableLetterItemModel.fromJson(Map<String, dynamic> json) {
    return RequestableLetterItemModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class MeDocumentsModel {
  final List<DocumentFileItemModel> files;
  final List<ExpiringDocumentItemModel> expiring;
  final List<CompanyDocumentListItemModel> policiesToAccept;
  final List<IssuedLetterItemModel> letters;
  final List<LetterRequestItemModel> letterRequests;
  final List<RequestableLetterItemModel> requestableLetters;

  const MeDocumentsModel({
    this.files = const [],
    this.expiring = const [],
    this.policiesToAccept = const [],
    this.letters = const [],
    this.letterRequests = const [],
    this.requestableLetters = const [],
  });

  factory MeDocumentsModel.fromJson(Map<String, dynamic> json) {
    final filesRaw = json['files'];
    final expiringRaw = json['expiring'];
    final policiesRaw = json['policies_to_accept'];
    final lettersRaw = json['letters'];
    final requestsRaw = json['letter_requests'];
    final requestableRaw = json['requestable_letters'];

    return MeDocumentsModel(
      files: filesRaw is List
          ? filesRaw
              .whereType<Map<String, dynamic>>()
              .map((f) => DocumentFileItemModel.fromJson(f))
              .toList()
          : const [],
      expiring: expiringRaw is List
          ? expiringRaw
              .whereType<Map<String, dynamic>>()
              .map((e) => ExpiringDocumentItemModel.fromJson(e))
              .toList()
          : const [],
      policiesToAccept: policiesRaw is List
          ? policiesRaw
              .whereType<Map<String, dynamic>>()
              .map((p) => CompanyDocumentListItemModel.fromJson(p))
              .toList()
          : const [],
      letters: lettersRaw is List
          ? lettersRaw
              .whereType<Map<String, dynamic>>()
              .map((l) => IssuedLetterItemModel.fromJson(l))
              .toList()
          : const [],
      letterRequests: requestsRaw is List
          ? requestsRaw
              .whereType<Map<String, dynamic>>()
              .map((r) => LetterRequestItemModel.fromJson(r))
              .toList()
          : const [],
      requestableLetters: requestableRaw is List
          ? requestableRaw
              .whereType<Map<String, dynamic>>()
              .map((rl) => RequestableLetterItemModel.fromJson(rl))
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'files': files.map((f) => f.toJson()).toList(),
      'expiring': expiring.map((e) => e.toJson()).toList(),
      'policies_to_accept': policiesToAccept.map((p) => p.toJson()).toList(),
      'letters': letters.map((l) => l.toJson()).toList(),
      'letter_requests': letterRequests.map((r) => r.toJson()).toList(),
      'requestable_letters': requestableLetters.map((rl) => rl.toJson()).toList(),
    };
  }
}
