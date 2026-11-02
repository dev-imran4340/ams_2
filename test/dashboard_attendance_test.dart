import 'package:flutter_test/flutter_test.dart';
import 'package:ams_2/app/screens/dashboard/model/dashboard_model.dart';
import 'package:ams_2/app/screens/dashboard/controller/dashboard_controller.dart';
import 'package:ams_2/app/screens/dashboard/repo/dashboard_repo.dart';

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

    group("Dashboard Shift Timer Deep Calculation Tests", () {
      late DashboardController controller;

      setUp(() {
        controller = DashboardController(repo: DashboardRepo());
      });

      tearDown(() {
        controller.onClose();
      });

      test('Scenario 1: Not checked in yet shows clean zeros', () {
        controller.dashboardData.value = DashboardDataModel(
          todayAttendance: const TodayAttendanceModel(
            checkInTime: '--:--',
            checkOutTime: '--:--',
            workingHours: '0:00',
            shiftRemaining: '07h 00m',
            overtime: '0:00',
            isCheckedIn: false,
            status: 'Not Checked In',
            officeRadiusStatus: 'Standby',
            shiftTiming: '09:00 - 17:00',
            shiftName: 'Day shift',
          ),
          monthlySummary: const MonthlySummaryModel(
            totalDays: 20,
            presentDays: 10,
            lateDays: 0,
            absentDays: 0,
            attendanceRate: 100,
            monthName: 'Nov',
          ),
        );

        expect(controller.elapsedHoursMinutes.value, equals('00:00'));
        expect(controller.elapsedSeconds.value, equals('00'));
        expect(controller.elapsedShiftTimer.value, equals('00:00:00'));
      });

      test('Scenario 2: Active Check-In calculates exact elapsed time from start timestamp', () {
        final now = DateTime.now();
        // 25 minutes ago
        final startTime = now.subtract(const Duration(minutes: 25, seconds: 14));

        controller.dashboardData.value = DashboardDataModel(
          todayAttendance: TodayAttendanceModel(
            checkInTime: '10:00',
            checkOutTime: '--:--',
            workingHours: '0h 25m',
            shiftRemaining: '06h 35m',
            overtime: '0:00',
            isCheckedIn: true,
            isOnBreak: false,
            status: 'At work',
            officeRadiusStatus: 'Verified',
            shiftTiming: '09:00 - 17:00',
            shiftName: 'Day shift',
            checkInDateTime: startTime,
            segments: [
              AttendanceSegmentModel(
                kind: 'work',
                starts: '10:00',
                startsAt: startTime,
                endsAt: null,
                paid: false,
              ),
            ],
          ),
          monthlySummary: const MonthlySummaryModel(
            totalDays: 20,
            presentDays: 10,
            lateDays: 0,
            absentDays: 0,
            attendanceRate: 100,
            monthName: 'Nov',
          ),
        );

        // Should calculate ~25 minutes
        expect(controller.elapsedHoursMinutes.value, equals('00:25'));
        expect(controller.elapsedSeconds.value, equals('14'));
      });

      test('Scenario 3: User is ON BREAK -> Work timer pauses and Break timer starts ticking live', () {
        final now = DateTime.now();
        final workStart = now.subtract(const Duration(hours: 2, minutes: 30));
        final workEnd = now.subtract(const Duration(minutes: 30)); // 2 hours of work
        final breakStart = workEnd; // 30 minutes of break so far

        controller.dashboardData.value = DashboardDataModel(
          todayAttendance: TodayAttendanceModel(
            checkInTime: '09:00',
            checkOutTime: '--:--',
            workingHours: '2h 00m',
            shiftRemaining: '05h 00m',
            overtime: '0:00',
            isCheckedIn: true,
            isOnBreak: true,
            status: 'On break',
            officeRadiusStatus: 'Verified',
            shiftTiming: '09:00 - 17:00',
            shiftName: 'Day shift',
            checkInDateTime: breakStart,
            segments: [
              AttendanceSegmentModel(
                kind: 'work',
                starts: '09:00',
                ends: '11:00',
                startsAt: workStart,
                endsAt: workEnd,
                paid: false,
              ),
              AttendanceSegmentModel(
                kind: 'break',
                starts: '11:00',
                startsAt: breakStart,
                endsAt: null,
                paid: false,
              ),
            ],
          ),
          monthlySummary: const MonthlySummaryModel(
            totalDays: 20,
            presentDays: 10,
            lateDays: 0,
            absentDays: 0,
            attendanceRate: 100,
            monthName: 'Nov',
          ),
        );

        // 1. Work timer is paused at exactly 2 hours (02:00) with (Paused) indicator
        expect(controller.elapsedShiftTimer.value, equals('02h 00m (Paused)'));
        expect(controller.pausedWorkDuration.value, equals('2h 00m'));

        // 2. Foreground display and break timer tick live break duration (30 minutes so far)
        expect(controller.elapsedHoursMinutes.value, equals('00:30'));
        expect(controller.elapsedBreakHoursMinutes.value, equals('00:30'));
      });

      test('Scenario 3B: Multiple breaks in a day -> Break timer resumes cumulative time', () {
        final now = DateTime.now();
        // Break 1: 15 mins (Closed)
        final b1Start = now.subtract(const Duration(hours: 3));
        final b1End = now.subtract(const Duration(hours: 2, minutes: 45));
        // Break 2: 10 mins into current active break
        final b2Start = now.subtract(const Duration(minutes: 10));

        controller.dashboardData.value = DashboardDataModel(
          todayAttendance: TodayAttendanceModel(
            checkInTime: '09:00',
            checkOutTime: '--:--',
            workingHours: '3h 00m',
            shiftRemaining: '04h 00m',
            overtime: '0:00',
            isCheckedIn: true,
            isOnBreak: true,
            status: 'On break',
            officeRadiusStatus: 'Verified',
            shiftTiming: '09:00 - 17:00',
            shiftName: 'Day shift',
            checkInDateTime: b2Start,
            segments: [
              AttendanceSegmentModel(
                kind: 'break',
                starts: '11:00',
                ends: '11:15',
                startsAt: b1Start,
                endsAt: b1End,
                paid: false,
              ),
              AttendanceSegmentModel(
                kind: 'break',
                starts: '13:00',
                startsAt: b2Start,
                endsAt: null,
                paid: false,
              ),
            ],
          ),
          monthlySummary: const MonthlySummaryModel(
            totalDays: 20,
            presentDays: 10,
            lateDays: 0,
            absentDays: 0,
            attendanceRate: 100,
            monthName: 'Nov',
          ),
        );

        // Break 1 (15m) + Break 2 (10m) = 25m total break time
        expect(controller.elapsedHoursMinutes.value, equals('00:25'));
        expect(controller.elapsedBreakHoursMinutes.value, equals('00:25'));
      });

      test('Scenario 4: User checks out directly during break (without ending break) -> Timer freezes as Done', () {
        final now = DateTime.now();
        final workStart = now.subtract(const Duration(hours: 3));
        final workEnd = now.subtract(const Duration(hours: 1)); // 2 hours worked
        final breakStart = workEnd;
        final breakEnd = now;

        controller.dashboardData.value = DashboardDataModel(
          todayAttendance: TodayAttendanceModel(
            checkInTime: '09:00',
            checkOutTime: '12:00',
            workingHours: '2h 00m',
            shiftRemaining: '05h 00m',
            overtime: '0:00',
            isCheckedIn: false,
            isOnBreak: false,
            status: 'Checked Out',
            officeRadiusStatus: 'Verified',
            shiftTiming: '09:00 - 17:00',
            shiftName: 'Day shift',
            segments: [
              AttendanceSegmentModel(
                kind: 'work',
                starts: '09:00',
                ends: '11:00',
                startsAt: workStart,
                endsAt: workEnd,
                paid: false,
              ),
              AttendanceSegmentModel(
                kind: 'break',
                starts: '11:00',
                ends: '12:00',
                startsAt: breakStart,
                endsAt: breakEnd,
                paid: false,
              ),
            ],
          ),
          monthlySummary: const MonthlySummaryModel(
            totalDays: 20,
            presentDays: 10,
            lateDays: 0,
            absentDays: 0,
            attendanceRate: 100,
            monthName: 'Nov',
          ),
        );

        expect(controller.elapsedHoursMinutes.value, equals('02:00'));
        expect(controller.elapsedShiftTimer.value, equals('2h 00m (Done)'));
      });

      test('Scenario 5: Multiple check-ins & check-outs in a single day -> Accumulates all sessions accurately', () {
        final now = DateTime.now();
        // Session 1: 3 hours worked
        final s1Start = now.subtract(const Duration(hours: 5));
        final s1End = now.subtract(const Duration(hours: 2));
        // Session 2 (Active): 30 minutes into work
        final s2Start = now.subtract(const Duration(minutes: 30));

        controller.dashboardData.value = DashboardDataModel(
          todayAttendance: TodayAttendanceModel(
            checkInTime: '09:00',
            checkOutTime: '--:--',
            workingHours: '3h 30m',
            shiftRemaining: '03h 30m',
            overtime: '0:00',
            isCheckedIn: true,
            isOnBreak: false,
            status: 'At work',
            officeRadiusStatus: 'Verified',
            shiftTiming: '09:00 - 17:00',
            shiftName: 'Day shift',
            checkInDateTime: s2Start,
            segments: [
              AttendanceSegmentModel(
                kind: 'work',
                starts: '09:00',
                ends: '12:00',
                startsAt: s1Start,
                endsAt: s1End,
                paid: false,
              ),
              AttendanceSegmentModel(
                kind: 'work',
                starts: '13:30',
                ends: null,
                startsAt: s2Start,
                endsAt: null,
                paid: false,
              ),
            ],
          ),
          monthlySummary: const MonthlySummaryModel(
            totalDays: 20,
            presentDays: 10,
            lateDays: 0,
            absentDays: 0,
            attendanceRate: 100,
            monthName: 'Nov',
          ),
        );

        // Session 1 (3h) + Session 2 (30m) = 3h 30m (03:30)
        expect(controller.elapsedHoursMinutes.value, equals('03:30'));
      });

      test('Scenario 6: Shift finalized and ended -> Timer freezes at total completed time with (Done)', () {
        final now = DateTime.now();
        final s1Start = now.subtract(const Duration(hours: 8));
        final s1End = now.subtract(const Duration(hours: 1)); // 7 hours total

        controller.dashboardData.value = DashboardDataModel(
          todayAttendance: TodayAttendanceModel(
            checkInTime: '09:00',
            checkOutTime: '16:00',
            workingHours: '7h 00m',
            shiftRemaining: '00h 00m',
            overtime: '0:00',
            isCheckedIn: false,
            isOnBreak: false,
            status: 'Present',
            officeRadiusStatus: 'Verified',
            shiftTiming: '09:00 - 17:00',
            shiftName: 'Day shift',
            segments: [
              AttendanceSegmentModel(
                kind: 'work',
                starts: '09:00',
                ends: '16:00',
                startsAt: s1Start,
                endsAt: s1End,
                paid: false,
              ),
            ],
          ),
          monthlySummary: const MonthlySummaryModel(
            totalDays: 20,
            presentDays: 10,
            lateDays: 0,
            absentDays: 0,
            attendanceRate: 100,
            monthName: 'Nov',
          ),
        );

        expect(controller.elapsedHoursMinutes.value, equals('07:00'));
        expect(controller.elapsedShiftTimer.value, equals('7h 00m (Done)'));
      });
    });
  });
}
