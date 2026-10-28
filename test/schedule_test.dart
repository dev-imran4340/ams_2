import 'package:flutter_test/flutter_test.dart';
import 'package:ams_2/app/screens/schedule/model/schedule_model.dart';

void main() {
  group('Schedule Model Tests', () {
    test('ScheduleResponseModel deserializes live API JSON correctly', () {
      final sampleJson = {
        'data': [
          {
            'date': '2026-11-02',
            'type': 'working',
            'label': 'Monday, Nov 2',
            'source': 'pattern',
            'planned_minutes': 480,
            'planned': '8:00',
            'holiday_worked': false,
            'shift': {
              'id': '01m5c8583bkd1qjdr18a4nbr3g',
              'name': 'Day shift',
              'code': 'DAY',
              'colour': 'sky',
              'kind': 'fixed',
              'starts': '09:00',
              'ends': '17:00',
              'overnight': false,
              'break_minutes': 60,
            },
          },
          {
            'date': '2026-11-03',
            'type': 'rest',
            'label': 'Tuesday, Nov 3',
            'source': 'pattern',
            'planned_minutes': 0,
            'planned': '0:00',
            'holiday_worked': false,
            'shift': null,
          }
        ],
        'meta': {
          'employee': '01m5kmp9fmnb75vnt7z1k2pagv',
          'from': '2026-11-01',
          'to': '2026-11-14',
        }
      };

      final response = ScheduleResponseModel.fromJson(sampleJson);
      expect(response.data.length, equals(2));
      expect(response.data[0].isWorkingDay, isTrue);
      expect(response.data[0].shift?.name, equals('Day shift'));
      expect(response.data[1].isRestDay, isTrue);
      expect(response.meta.employee, equals('01m5kmp9fmnb75vnt7z1k2pagv'));
    });

    test('HolidaysResponseModel deserializes public holidays correctly', () {
      final holidayJson = {
        'data': [
          {
            'id': '01j9xyz987654321',
            'name': 'Iqbal Day',
            'kind': 'public',
            'starts_on': '2026-11-09',
            'ends_on': '2026-11-09',
            'is_paid': true,
          }
        ],
        'meta': {
          'year': 2026,
        },
      };

      final holidayResponse = HolidaysResponseModel.fromJson(holidayJson);
      expect(holidayResponse.year, equals(2026));
      expect(holidayResponse.data.length, equals(1));
      expect(holidayResponse.data[0].name, equals('Iqbal Day'));
      expect(holidayResponse.data[0].isPaid, isTrue);
    });
  });
}
