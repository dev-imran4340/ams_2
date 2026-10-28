import 'package:flutter_test/flutter_test.dart';
import 'package:ams_2/app/screens/attendance_history/model/attendance_history_model.dart';

void main() {
  group('AttendanceHistory Model & Typedef Tests', () {
    test('AttendanceHistoryResponse parses live API JSON structure correctly', () {
      final sampleJson = {
        'data': [
          {
            'id': '01jb2x9k4m7q8r3t5v6w8y0z1a',
            'date': '2026-10-28',
            'date_label': 'Wednesday, Oct 28',
            'status': 'present',
            'status_label': 'Present',
            'status_code': 'P',
            'tone': 'emerald',
            'day_type': 'working',
            'first_in': '09:05',
            'last_out': '17:30',
            'worked_minutes': 505,
            'counted_minutes': 480,
            'late_minutes': 5,
            'breaks': [
              {
                'starts': '13:00',
                'ends': '13:45',
                'minutes': 45,
                'paid': false,
              }
            ],
          }
        ],
        'meta': {
          'from': '2026-10-01',
          'to': '2026-10-31',
        }
      };

      final response = AttendanceHistoryResponse.fromJson(sampleJson);
      expect(response.data.length, equals(1));

      final day = response.data.first;
      expect(day.id, equals('01jb2x9k4m7q8r3t5v6w8y0z1a'));
      expect(day.isPresent, isTrue);
      expect(day.hasLate, isTrue);
      expect(day.checkInDisplay, equals('09:05'));
      expect(day.breaks.length, equals(1));
      expect(day.breaks.first.minutes, equals(45));

      // Backward compatibility verification
      final AttendanceTimesheetResponse aliasedResponse = response;
      final AttendanceTimesheetDayModel aliasedDay = day;
      expect(aliasedResponse.data.first.id, equals(aliasedDay.id));
      expect(day.totalBreakMinutes, equals(45));
      expect(day.totalBreakFormatted, equals('45m'));
    });

    test('Break duration is automatically calculated from starts and ends when minutes is missing', () {
      final breakModel = AttendanceHistoryBreakModel.fromJson({
        'starts': '13:00',
        'ends': '14:15',
        'paid': false,
      });

      expect(breakModel.minutes, equals(75));
      expect(breakModel.durationDisplay, equals('1h 15m'));
    });

    test('allBreaks extracts and calculates duration from segments when breaks array is omitted', () {
      final json = {
        'id': '01jb2x9k4m7q8r3t5v6w8y0z1b',
        'date': '2026-10-29',
        'date_label': 'Thursday, Oct 29',
        'status': 'present',
        'status_label': 'Present',
        'status_code': 'P',
        'tone': 'emerald',
        'day_type': 'working',
        'segments': [
          {
            'kind': 'work',
            'starts': '09:00',
            'ends': '13:00',
            'paid': true,
          },
          {
            'kind': 'break',
            'starts': '13:00',
            'ends': '13:30',
            'paid': false,
          },
          {
            'kind': 'break',
            'starts': '16:00',
            'ends': '16:15',
            'paid': false,
          }
        ],
      };

      final day = AttendanceHistoryDayModel.fromJson(json);
      expect(day.allBreaks.length, equals(2));
      expect(day.allBreaks[0].minutes, equals(30));
      expect(day.allBreaks[1].minutes, equals(15));
      expect(day.totalBreakMinutes, equals(45));
      expect(day.totalBreakFormatted, equals('45m'));
    });
  });
}
