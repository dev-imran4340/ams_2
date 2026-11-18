import 'package:flutter_test/flutter_test.dart';
import 'package:ams_2/app/screens/documents/model/document_model.dart';

void main() {
  group('Phase 17 Documents, Policies & Letters Models Tests', () {
    test('CompanyDocumentListItemModel serializes and deserializes accurately', () {
      final json = {
        'id': '01m6ymc6v1hnhps27gx57hy8p7',
        'kind': 'policy',
        'kind_label': 'Policy',
        'title': 'Employee Handbook',
        'description': 'General staff conduct and culture guidelines',
        'version': 1,
        'published_on': '2026-11-08',
        'expires_on': null,
        'requires_acknowledgement': true,
        'acknowledged': false,
        'is_active': true,
      };

      final model = CompanyDocumentListItemModel.fromJson(json);

      expect(model.id, equals('01m6ymc6v1hnhps27gx57hy8p7'));
      expect(model.kind, equals('policy'));
      expect(model.kindLabel, equals('Policy'));
      expect(model.title, equals('Employee Handbook'));
      expect(model.description, equals('General staff conduct and culture guidelines'));
      expect(model.version, equals(1));
      expect(model.publishedOn, equals('2026-11-08'));
      expect(model.expiresOn, isNull);
      expect(model.requiresAcknowledgement, isTrue);
      expect(model.acknowledged, isFalse);
      expect(model.isActive, isTrue);

      final copy = model.copyWith(acknowledged: true);
      expect(copy.acknowledged, isTrue);
      expect(copy.id, equals(model.id));

      final serialized = model.toJson();
      expect(serialized['id'], equals('01m6ymc6v1hnhps27gx57hy8p7'));
      expect(serialized['requires_acknowledgement'], isTrue);
    });

    test('CompanyDocumentDetailsModel parses current_version and versions list', () {
      final json = {
        'id': '01m6ymc6v1hnhps27gx57hy8p7',
        'kind': 'policy',
        'kind_label': 'Policy',
        'title': 'Employee Handbook',
        'description': null,
        'version': 2,
        'published_on': '2026-11-08',
        'expires_on': null,
        'requires_acknowledgement': true,
        'acknowledged': false,
        'is_active': true,
        'current_version': {
          'id': '01m6ymc6v9z5484rm08jk9d1qx',
          'version': 2,
          'published_at': '2026-11-08T22:27:30+00:00',
          'published_by': 'Imran Shah',
          'change_note': 'Updated section 4.2',
          'asks_again': true,
          'body': '<p>Policy content</p>',
          'file_name': 'policy_v2.pdf',
        },
        'versions': [
          {
            'id': '01m6ymc6v9z5484rm08jk9d1qx',
            'version': 2,
            'published_at': '2026-11-08T22:27:30+00:00',
            'published_by': 'Imran Shah',
            'change_note': 'Updated section 4.2',
            'asks_again': true,
            'body': null,
            'file_name': 'policy_v2.pdf',
          },
          {
            'id': '01m6ymc6v9z5484rm08jk9d1v1',
            'version': 1,
            'published_at': '2025-11-08T22:27:30+00:00',
            'published_by': 'Admin',
            'change_note': 'Initial release',
            'asks_again': false,
            'body': null,
            'file_name': 'policy_v1.pdf',
          }
        ]
      };

      final details = CompanyDocumentDetailsModel.fromJson(json);

      expect(details.id, equals('01m6ymc6v1hnhps27gx57hy8p7'));
      expect(details.version, equals(2));
      expect(details.currentVersion, isNotNull);
      expect(details.currentVersion?.version, equals(2));
      expect(details.currentVersion?.fileName, equals('policy_v2.pdf'));
      expect(details.versions.length, equals(2));
      expect(details.versions[1].version, equals(1));
    });

    test('MeDocumentsModel parses files, expiring, letters and requestables properly', () {
      final json = {
        'files': [
          {
            'id': '01jk1234567890abcdefghijkl',
            'title': 'Signed Contract',
            'category': {
              'id': '01jc1234567890abcdefghijkl',
              'name': 'Contract and Offer',
              'visibility': 'employee',
              'visibility_label': 'HR and the employee'
            },
            'expires_on': '2027-01-31',
            'expiry_tone': null,
            'note': 'Standard employment contract',
            'file_name': 'contract.pdf',
            'size': '120 KB',
            'uploaded_on': '2026-10-01',
            'uploaded_by': 'Hina Ali'
          }
        ],
        'expiring': [
          {
            'source': 'identity_document',
            'source_label': 'ID document',
            'title': 'Passport',
            'expires_on': '2026-11-20',
            'days_left': 21,
            'when': 'in 21 days',
            'tone': 'amber',
            'employee': {
              'id': '01ja1234567890abcdefghijkl',
              'name': 'Ayesha Khan',
              'number': 'E-0012'
            },
            'document_id': null,
            'profile_tab': 'documents'
          }
        ],
        'policies_to_accept': [
          {
            'id': '01m6ymc6v1hnhps27gx57hy8p7',
            'kind': 'policy',
            'kind_label': 'Policy',
            'title': 'Employee Handbook',
            'description': null,
            'version': 1,
            'published_on': '2026-11-08',
            'expires_on': null,
            'requires_acknowledgement': true,
            'acknowledged': false,
            'is_active': true
          }
        ],
        'letters': [
          {
            'id': '01jl1234567890abcdefghijkl',
            'reference': 'LTR-2026-0042',
            'kind': 'experience',
            'kind_label': 'Experience',
            'subject': 'Experience certificate',
            'issued_on': '2026-10-28',
            'issued_by': 'Hina Ali',
            'shared': true,
            'void': false,
            'void_reason': null,
            'employee': {
              'id': '01ja1234567890abcdefghijkl',
              'name': 'Ayesha',
              'number': 'E-0012'
            }
          }
        ],
        'letter_requests': [
          {
            'id': '01jr1234567890abcdefghijkl',
            'letter': 'Salary certificate',
            'purpose': 'Bank loan',
            'status': 'pending',
            'status_label': 'Waiting for approval',
            'requested_on': '2026-10-29',
            'letter_id': null
          }
        ],
        'requestable_letters': [
          {
            'id': '01m6jjteb7f99gvybnww65c6v7',
            'name': 'Experience letter'
          },
          {
            'id': '01m6jjteb8r4ykajxz7qfe6a3r',
            'name': 'Salary certificate'
          }
        ]
      };

      final me = MeDocumentsModel.fromJson(json);

      expect(me.files.length, equals(1));
      expect(me.files.first.title, equals('Signed Contract'));
      expect(me.files.first.category?.name, equals('Contract and Offer'));

      expect(me.expiring.length, equals(1));
      expect(me.expiring.first.title, equals('Passport'));
      expect(me.expiring.first.daysLeft, equals(21));
      expect(me.expiring.first.tone, equals('amber'));

      expect(me.policiesToAccept.length, equals(1));
      expect(me.policiesToAccept.first.title, equals('Employee Handbook'));
      expect(me.policiesToAccept.first.requiresAcknowledgement, isTrue);

      expect(me.letters.length, equals(1));
      expect(me.letters.first.reference, equals('LTR-2026-0042'));

      expect(me.letterRequests.length, equals(1));
      expect(me.letterRequests.first.status, equals('pending'));

      expect(me.requestableLetters.length, equals(2));
      expect(me.requestableLetters.first.name, equals('Experience letter'));
    });
  });
}
