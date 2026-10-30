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

    test('break_minutes represents allowed break quota and breaks list calculates total break used', () {
      final json = {
        'id': '01m5zbsgk84t5jp8nqbafhsxj1',
        'date': '2026-10-28',
        'date_label': 'Wed 28/10/2026',
        'status': 'present',
        'status_label': 'Present',
        'status_code': 'P',
        'tone': 'emerald',
        'day_type': 'working',
        'break_minutes': 60,
        'breaks': [
          {'starts': '10:58', 'ends': '10:58', 'minutes': 0, 'type': null, 'paid': false},
          {'starts': '12:06', 'ends': '12:18', 'minutes': 12, 'type': null, 'paid': false},
          {'starts': '16:19', 'ends': '16:38', 'minutes': 18, 'type': null, 'paid': false},
        ],
      };

      final day = AttendanceHistoryDayModel.fromJson(json);

      // Allowed Quota
      expect(day.allowedBreakMinutes, equals(60));
      expect(day.allowedBreakFormatted, equals('1h'));

      // Total Break Used (0 + 12 + 18)
      expect(day.totalBreakUsedMinutes, equals(30));
      expect(day.totalBreakUsedFormatted, equals('30m'));
      expect(day.totalBreakMinutes, equals(30));
      expect(day.totalBreakFormatted, equals('30m'));

      // Remaining Break (60 - 30)
      expect(day.remainingBreakMinutes, equals(30));
      expect(day.remainingBreakFormatted, equals('30m'));
      expect(day.isBreakExceeded, isFalse);

      // Verify Empty breaks day (allowed 60m, used 0m)
      final emptyDayJson = {
        'id': '01m61y67kxnebesrh3mxtrh0n1',
        'date': '2026-10-29',
        'date_label': 'Thu 29/10/2026',
        'status': 'present',
        'status_label': 'Present',
        'status_code': 'P',
        'tone': 'emerald',
        'day_type': 'working',
        'break_minutes': 60,
        'breaks': [],
      };

      final emptyDay = AttendanceHistoryDayModel.fromJson(emptyDayJson);
      expect(emptyDay.allowedBreakMinutes, equals(60));
      expect(emptyDay.allowedBreakFormatted, equals('1h'));
      expect(emptyDay.totalBreakUsedMinutes, equals(0));
      expect(emptyDay.totalBreakUsedFormatted, equals('0m'));
      expect(emptyDay.remainingBreakMinutes, equals(60));
      expect(emptyDay.remainingBreakFormatted, equals('1h'));
    });
  });
}
