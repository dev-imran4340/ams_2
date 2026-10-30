import 'package:flutter_test/flutter_test.dart';
import 'package:ams_2/app/screens/dashboard/model/dashboard_model.dart';

void main() {
  group("TodayAttendanceModel & Multi-Session Segments Tests", () {
    final livePayload = {
      "state": {
        "checked_in": true,
        "on_break": false,
        "since": "11:20",
        "since_at": "2026-10-30T06:20:49Z",
        "date": "2026-10-30",
        "uses_breaks": true,
        "allowed": ["out", "break_start"],
        "refusals": {
          "in": {
            "code": "already_checked_in",
            "message": "You are already checked in."
          },
          "break_end": {
            "code": "no_open_break",
            "message": "You are not on a break."
          }
        }
      },
      "requires": {
        "position": false,
        "photo": false,
        "face": "off",
        "face_saved": false,
        "consent_text": null
      },
      "day": {
        "id": "01m64gjy6pqwx37s15fwdxd1g3",
        "date": "2026-10-30",
        "date_label": "Fri 30/10/2026",
        "status": "in_progress",
        "status_label": "At work",
        "status_code": "W",
        "tone": "brand",
        "day_type": "working",
        "timezone": "Asia/Karachi",
        "shift": {
          "name": "Day shift",
          "code": "DAY",
          "starts": "09:00",
          "ends": "17:00",
          "overnight": false
        },
        "holiday": null,
        "planned_minutes": 420,
        "first_in": "10:54",
        "first_in_at": "2026-10-30T05:54:54Z",
        "last_out": null,
        "last_out_at": null,
        "worked_minutes": 25,
        "worked": "0:25",
        "counted_minutes": 25,
        "counted": "0:25",
        "break_minutes": 0,
        "late_minutes": 114,
        "early_out_minutes": 0,
        "short_minutes": 0,
        "overtime_minutes": 0,
        "overtime": "0:00",
        "overtime_status": null,
        "flags": ["late"],
        "locked": false,
        "segments": [
          {
            "kind": "work",
            "starts": "10:54",
            "ends": "11:20",
            "starts_at": "2026-10-30T05:54:54Z",
            "ends_at": "2026-10-30T06:20:22Z",
            "paid": false
          },
          {
            "kind": "work",
            "starts": "11:20",
            "ends": "11:20",
            "starts_at": "2026-10-30T06:20:26Z",
            "ends_at": "2026-10-30T06:20:44Z",
            "paid": false
          },
          {
            "kind": "work",
            "starts": "11:20",
            "ends": null,
            "starts_at": "2026-10-30T06:20:49Z",
            "ends_at": null,
            "paid": false
          }
        ],
        "breaks": []
      }
    };

    test('Parses multi-session live response accurately without data loss', () {
      final model = TodayAttendanceModel.fromApiJson(livePayload);

      expect(model.isCheckedIn, isTrue);
      expect(model.isOnBreak, isFalse);
      expect(model.checkInTime, equals('10:54'));
      expect(model.latestCheckInTime, equals('11:20'));
      expect(model.latestCheckOutTime, equals('11:20'));
      expect(model.workingHours, equals('0h 25m'));
      expect(model.workedMinutes, equals(25));
      expect(model.countedMinutes, equals(25));
      expect(model.totalWorkSessions, equals(3));
      expect(model.segments.length, equals(3));
      expect(model.lateMinutes, equals(114));
      expect(model.status, equals('At work'));
      expect(model.canCheckOut, isTrue);
      expect(model.canStartBreak, isTrue);
      expect(model.canCheckIn, isFalse);
      expect(model.canEndBreak, isFalse);
    });

    test('latestCheckOutTime returns ended work segment when day.last_out is null', () {
      final model = TodayAttendanceModel.fromApiJson(livePayload);
      expect(model.checkOutTime, equals('--:--'));
      expect(model.latestCheckOutTime, equals('11:20'));
    });

    test('Single session check out returns checkOutTime correctly', () {
      final singleSessionJson = {
        "state": {
          "checked_in": false,
          "on_break": false,
          "allowed": ["in"],
        },
        "day": {
          "first_in": "09:00",
          "last_out": "17:00",
          "worked_minutes": 480,
          "segments": [
            {
              "kind": "work",
              "starts": "09:00",
              "ends": "17:00",
              "paid": false,
            }
          ]
        }
      };

      final model = TodayAttendanceModel.fromApiJson(singleSessionJson);
      expect(model.isCheckedIn, isFalse);
      expect(model.checkInTime, equals('09:00'));
      expect(model.checkOutTime, equals('17:00'));
      expect(model.latestCheckOutTime, equals('17:00'));
      expect(model.workingHours, equals('8h 00m'));
    });

    test('Parses break list from day.breaks accurately', () {
      final breakPayload = {
        "state": {
          "checked_in": true,
          "on_break": false,
          "allowed": ["out", "break_start"],
        },
        "day": {
          "first_in": "09:00",
          "last_out": null,
          "breaks": [
            {
              "starts": "13:00",
              "ends": "13:45",
              "starts_at": "2026-10-30T08:00:00Z",
              "ends_at": "2026-10-30T08:45:00Z",
              "minutes": 45,
              "paid": false,
            }
          ],
          "segments": [
            {
              "kind": "work",
              "starts": "09:00",
              "ends": "13:00",
              "paid": false,
            },
            {
              "kind": "work",
              "starts": "13:45",
              "ends": null,
              "paid": false,
            }
          ]
        }
      };

      final model = TodayAttendanceModel.fromApiJson(breakPayload);
      expect(model.breaks.length, equals(1));
      expect((model.breaks.first as Map)['starts'], equals('13:00'));
      expect((model.breaks.first as Map)['ends'], equals('13:45'));
      expect((model.breaks.first as Map)['minutes'], equals(45));
      expect(model.totalWorkSessions, equals(2));
    });
  });
}
