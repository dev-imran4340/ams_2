// Phase 17 Pillar 2: News, Announcements, Events & Milestones Models
// Matching production backend contracts from doc/api.md

class AnnouncementItemModel {
  final String id;
  final String title;
  final String? body;
  final String? excerpt;
  final String? publishedAt;
  final String? publishedOn;
  final bool isScheduled;
  final String? endsOn;
  final bool isPinned;
  final bool read;

  const AnnouncementItemModel({
    required this.id,
    required this.title,
    this.body,
    this.excerpt,
    this.publishedAt,
    this.publishedOn,
    this.isScheduled = false,
    this.endsOn,
    this.isPinned = false,
    this.read = false,
  });

  factory AnnouncementItemModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementItemModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled Announcement',
      body: json['body']?.toString(),
      excerpt: json['excerpt']?.toString(),
      publishedAt: json['published_at']?.toString(),
      publishedOn: json['published_on']?.toString(),
      isScheduled: json['is_scheduled'] == true,
      endsOn: json['ends_on']?.toString(),
      isPinned: json['is_pinned'] == true,
      read: json['read'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      if (body != null) 'body': body,
      if (excerpt != null) 'excerpt': excerpt,
      if (publishedAt != null) 'published_at': publishedAt,
      if (publishedOn != null) 'published_on': publishedOn,
      'is_scheduled': isScheduled,
      if (endsOn != null) 'ends_on': endsOn,
      'is_pinned': isPinned,
      'read': read,
    };
  }

  AnnouncementItemModel copyWith({
    String? body,
    bool? read,
  }) {
    return AnnouncementItemModel(
      id: id,
      title: title,
      body: body ?? this.body,
      excerpt: excerpt,
      publishedAt: publishedAt,
      publishedOn: publishedOn,
      isScheduled: isScheduled,
      endsOn: endsOn,
      isPinned: isPinned,
      read: read ?? this.read,
    );
  }
}

class AnnouncementsResponseModel {
  final List<AnnouncementItemModel> announcements;
  final int unreadCount;

  const AnnouncementsResponseModel({
    required this.announcements,
    required this.unreadCount,
  });

  factory AnnouncementsResponseModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final list = (rawData is List)
        ? rawData
            .whereType<Map<String, dynamic>>()
            .map((e) => AnnouncementItemModel.fromJson(e))
            .toList()
        : <AnnouncementItemModel>[];

    final meta = json['meta'];
    final unread = (meta is Map && meta['unread'] is num)
        ? (meta['unread'] as num).toInt()
        : list.where((a) => !a.read).length;

    return AnnouncementsResponseModel(
      announcements: list,
      unreadCount: unread,
    );
  }
}

class CompanyEventItemModel {
  final String id;
  final String title;
  final String? description;
  final String startsOn;
  final String? endsOn;
  final String? startsAt;
  final String? endsAt;
  final bool allDay;
  final String when;
  final String? place;

  const CompanyEventItemModel({
    required this.id,
    required this.title,
    this.description,
    required this.startsOn,
    this.endsOn,
    this.startsAt,
    this.endsAt,
    this.allDay = false,
    required this.when,
    this.place,
  });

  factory CompanyEventItemModel.fromJson(Map<String, dynamic> json) {
    return CompanyEventItemModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Event',
      description: json['description']?.toString(),
      startsOn: json['starts_on']?.toString() ?? '',
      endsOn: json['ends_on']?.toString(),
      startsAt: json['starts_at']?.toString(),
      endsAt: json['ends_at']?.toString(),
      allDay: json['all_day'] == true,
      when: json['when']?.toString() ?? '',
      place: json['place']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      if (description != null) 'description': description,
      'starts_on': startsOn,
      if (endsOn != null) 'ends_on': endsOn,
      if (startsAt != null) 'starts_at': startsAt,
      if (endsAt != null) 'ends_at': endsAt,
      'all_day': allDay,
      'when': when,
      if (place != null) 'place': place,
    };
  }
}

class MilestoneEmployeeModel {
  final String id;
  final String name;
  final String? designation;

  const MilestoneEmployeeModel({
    required this.id,
    required this.name,
    this.designation,
  });

  factory MilestoneEmployeeModel.fromJson(Map<String, dynamic> json) {
    return MilestoneEmployeeModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Colleague',
      designation: json['designation']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (designation != null) 'designation': designation,
    };
  }
}

class ColleagueMilestoneItemModel {
  final String kind;
  final String on;
  final String when;
  final int? years;
  final String text;
  final MilestoneEmployeeModel employee;

  const ColleagueMilestoneItemModel({
    required this.kind,
    required this.on,
    required this.when,
    this.years,
    required this.text,
    required this.employee,
  });

  bool get isBirthday => kind.toLowerCase() == 'birthday';
  bool get isAnniversary => kind.toLowerCase() == 'anniversary';

  factory ColleagueMilestoneItemModel.fromJson(Map<String, dynamic> json) {
    final empJson = json['employee'];
    final emp = (empJson is Map<String, dynamic>)
        ? MilestoneEmployeeModel.fromJson(empJson)
        : const MilestoneEmployeeModel(id: '', name: 'Colleague');

    return ColleagueMilestoneItemModel(
      kind: json['kind']?.toString() ?? 'birthday',
      on: json['on']?.toString() ?? '',
      when: json['when']?.toString() ?? '',
      years: json['years'] is num ? (json['years'] as num).toInt() : null,
      text: json['text']?.toString() ?? '',
      employee: emp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kind': kind,
      'on': on,
      'when': when,
      if (years != null) 'years': years,
      'text': text,
      'employee': employee.toJson(),
    };
  }
}

class BirthdaySharingResponseModel {
  final bool shares;

  const BirthdaySharingResponseModel({required this.shares});

  factory BirthdaySharingResponseModel.fromJson(Map<String, dynamic> json) {
    return BirthdaySharingResponseModel(
      shares: json['shares'] == true,
    );
  }
}
