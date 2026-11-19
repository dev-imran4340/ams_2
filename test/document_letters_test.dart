import 'package:flutter_test/flutter_test.dart';
import 'package:ams_2/app/screens/documents/model/document_model.dart';

void main() {
  group('IssuedLetterItemModel Tests', () {
    test('serializes and deserializes correctly with body', () {
      final json = {
        'id': '01jl2x9k4m7q8r3t5v6w8y0z1a',
        'reference': 'LTR-2026-0042',
        'kind': 'experience',
        'kind_label': 'Experience Certificate',
        'subject': 'Experience and Relieving Letter',
        'issued_on': '2026-10-28',
        'issued_by': 'Hina Ali',
        'shared': true,
        'void': false,
        'void_reason': null,
        'employee': {
          'id': '01ja2x9k4m7q8r3t5v6w8y0z1b',
          'name': 'Ayesha Khan',
          'number': 'EMP-0012',
        },
        'body': '<p>This is to certify that Ayesha Khan worked as Senior Engineer.</p>',
      };

      final letter = IssuedLetterItemModel.fromJson(json);

      expect(letter.id, '01jl2x9k4m7q8r3t5v6w8y0z1a');
      expect(letter.reference, 'LTR-2026-0042');
      expect(letter.kind, 'experience');
      expect(letter.kindLabel, 'Experience Certificate');
      expect(letter.subject, 'Experience and Relieving Letter');
      expect(letter.issuedOn, '2026-10-28');
      expect(letter.issuedBy, 'Hina Ali');
      expect(letter.shared, true);
      expect(letter.isVoid, false);
      expect(letter.voidReason, isNull);
      expect(letter.employee?.name, 'Ayesha Khan');
      expect(letter.employee?.number, 'EMP-0012');
      expect(
        letter.body,
        '<p>This is to certify that Ayesha Khan worked as Senior Engineer.</p>',
      );

      final serialized = letter.toJson();
      expect(serialized['id'], letter.id);
      expect(serialized['body'], letter.body);
    });

    test('copyWith properly modifies body and preserves other properties', () {
      const letter = IssuedLetterItemModel(
        id: '01jl2x9k4m7q8r3t5v6w8y0z1a',
        reference: 'LTR-2026-0042',
        kind: 'experience',
        kindLabel: 'Experience',
        subject: 'Certificate',
        shared: true,
        isVoid: false,
      );

      final updated = letter.copyWith(
        body: '<p>Updated Body</p>',
      );

      expect(updated.id, letter.id);
      expect(updated.reference, letter.reference);
      expect(updated.body, '<p>Updated Body</p>');
    });
  });
}
