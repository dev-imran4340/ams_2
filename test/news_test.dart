import 'package:flutter_test/flutter_test.dart';
import 'package:ams_2/app/screens/news/model/news_model.dart';

void main() {
  group('Phase 17 Pillar 2: News, Announcements, Events & Milestones Tests', () {
    test('AnnouncementItemModel serializes and deserializes accurately', () {
      final json = {
        'id': '01jn8q1234567890abcdefghij',
        'title': 'Office closed on Friday',
        'body': '<p>Enjoy the long weekend.</p>',
        'excerpt': 'Enjoy the long weekend.',
        'published_at': '2026-10-30T09:00:00+05:00',
        'published_on': '30 Oct 2026 09:00',
        'is_scheduled': false,
        'ends_on': '2026-11-02',
        'is_pinned': true,
        'read': false,
      };

      final model = AnnouncementItemModel.fromJson(json);

      expect(model.id, equals('01jn8q1234567890abcdefghij'));
      expect(model.title, equals('Office closed on Friday'));
      expect(model.isPinned, isTrue);
      expect(model.read, isFalse);
      expect(model.endsOn, equals('2026-11-02'));

      final updated = model.copyWith(read: true, body: 'Updated body');
      expect(updated.read, isTrue);
      expect(updated.body, equals('Updated body'));
      expect(updated.isPinned, isTrue);
    });

    test('AnnouncementsResponseModel correctly counts unread from meta or items', () {
      final json = {
        'data': [
          {
            'id': '01jn1',
            'title': 'Town hall notice',
            'is_pinned': true,
            'read': true,
          },
          {
            'id': '01jn2',
            'title': 'System upgrade',
            'is_pinned': false,
            'read': false,
          },
        ],
        'meta': {
          'unread': 1,
        },
      };

      final response = AnnouncementsResponseModel.fromJson(json);
      expect(response.announcements.length, equals(2));
      expect(response.unreadCount, equals(1));
    });

    test('CompanyEventItemModel parses event dates, time and place', () {
      final json = {
        'id': '01je1234567890abcdefghij12',
        'title': 'Annual Strategy Meeting',
        'description': 'Discussion on quarterly roadmap and KPIs',
        'starts_on': '2026-11-10',
        'ends_on': '2026-11-10',
        'starts_at': '10:00',
        'ends_at': '11:30',
        'all_day': false,
        'when': 'Tue 10 Nov 2026, 10:00–11:30',
        'place': 'Main Auditorium',
      };

      final event = CompanyEventItemModel.fromJson(json);

      expect(event.id, equals('01je1234567890abcdefghij12'));
      expect(event.title, equals('Annual Strategy Meeting'));
      expect(event.allDay, isFalse);
      expect(event.place, equals('Main Auditorium'));
      expect(event.when, equals('Tue 10 Nov 2026, 10:00–11:30'));
    });

    test('ColleagueMilestoneItemModel handles birthday and anniversary kinds', () {
      final birthdayJson = {
        'kind': 'birthday',
        'on': '2026-11-07',
        'when': 'Tomorrow',
        'years': null,
        'text': 'Birthday',
        'employee': {
          'id': '01ja1234567890abcdefghij34',
          'name': 'Ayesha Khan',
          'designation': 'HR Officer',
        },
      };

      final anniversaryJson = {
        'kind': 'anniversary',
        'on': '2026-11-15',
        'when': 'In 8 days',
        'years': 3,
        'text': '3rd Work Anniversary',
        'employee': {
          'id': '01jb1234567890abcdefghij56',
          'name': 'Bilal Ahmed',
          'designation': 'Software Engineer',
        },
      };

      final bday = ColleagueMilestoneItemModel.fromJson(birthdayJson);
      expect(bday.isBirthday, isTrue);
      expect(bday.isAnniversary, isFalse);
      expect(bday.employee.name, equals('Ayesha Khan'));
      expect(bday.when, equals('Tomorrow'));

      final anniv = ColleagueMilestoneItemModel.fromJson(anniversaryJson);
      expect(anniv.isBirthday, isFalse);
      expect(anniv.isAnniversary, isTrue);
      expect(anniv.years, equals(3));
      expect(anniv.text, equals('3rd Work Anniversary'));
    });

    test('BirthdaySharingResponseModel deserializes shares boolean', () {
      final json = {
        'shares': false,
      };

      final model = BirthdaySharingResponseModel.fromJson(json);
      expect(model.shares, isFalse);
    });
  });
}
