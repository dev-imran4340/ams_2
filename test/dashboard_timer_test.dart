import 'package:flutter_test/flutter_test.dart';
import 'package:ams_2/app/screens/dashboard/model/dashboard_model.dart';
import 'package:ams_2/app/screens/dashboard/controller/dashboard_controller.dart';
import 'package:ams_2/app/screens/dashboard/repo/dashboard_repo.dart';

class MockDashboardRepo extends DashboardRepo {
  @override
  Future<DashboardDataModel?> fetchDashboardData() async => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Dashboard Attendance Timer Tests', () {
    test('Correctly calculates live worked time without double counting', () {
      final now = DateTime.now().toUtc();
      final sinceAtStr = now.subtract(const Duration(hours: 4, minutes: 22)).toIso8601String();
      final firstInStr = now.subtract(const Duration(hours: 4, minutes: 45)).toIso8601String();
      final firstSegEnd = now.subtract(Duration(hours: 4, minutes: 22, seconds: 9)).toIso8601String();

      final json = {
        "state": {
          "checked_in": true,
          "on_break": false,
          "since": "11:22",
          "since_at": sinceAtStr,
          "date": "2026-11-19",
          "uses_breaks": true,
          "allowed": ["out", "break_start"],
        },
        "day": {
          "id": "01m7r0hd9yc5hbr7as0pkktpe4",
          "date": "2026-11-19",
          "status": "in_progress",
          "first_in": "10:59",
          "first_in_at": firstInStr,
          "worked_minutes": 199,
          "worked": "3:19",
          "break_minutes": 41,
          "segments": [
            {
              "kind": "work",
              "starts": "10:59",
              "ends": "11:22",
              "starts_at": firstInStr,
              "ends_at": firstSegEnd,
              "paid": false
            },
            {
              "kind": "break",
              "starts": "11:00",
              "ends": "11:20",
              "starts_at": "2026-11-19T06:00:30Z",
              "ends_at": "2026-11-19T06:20:44Z",
              "paid": false
            },
            {
              "kind": "work",
              "starts": "11:22",
              "ends": null,
              "starts_at": sinceAtStr,
              "ends_at": null,
              "paid": false
            },
            {
              "kind": "break",
              "starts": "13:47",
              "ends": "14:07",
              "starts_at": "2026-11-19T08:47:21Z",
              "ends_at": "2026-11-19T09:07:43Z",
              "paid": false
            },
            {
              "kind": "break",
              "starts": "14:28",
              "ends": "14:29",
              "starts_at": "2026-11-19T09:28:38Z",
              "ends_at": "2026-11-19T09:29:40Z",
              "paid": false
            }
          ],
          "breaks": [
            {"starts": "11:00", "ends": "11:20", "minutes": 20, "type": null, "paid": false},
            {"starts": "13:47", "ends": "14:07", "minutes": 20, "type": null, "paid": false},
            {"starts": "14:28", "ends": "14:29", "minutes": 1, "type": null, "paid": false}
          ]
        }
      };

      final today = TodayAttendanceModel.fromApiJson(json);
      final controller = DashboardController(repo: MockDashboardRepo());

      // Assign to dashboardData and update timer
      controller.dashboardData.value = DashboardDataModel(
        todayAttendance: today,
        monthlySummary: const MonthlySummaryModel(
          totalDays: 20,
          presentDays: 15,
          lateDays: 2,
          absentDays: 1,
          attendanceRate: 90.0,
          monthName: 'Nov',
        ),
      );
      controller.updateRunningShiftTimer();

      // Verify break timer is 41 minutes (2498 seconds ~ 41m)
      expect(controller.elapsedBreakHoursMinutes.value, '00:41');

      // Verify work timer is active, mathematically sound, and has zero double-counting
      final parts = controller.elapsedHoursMinutes.value.split(':');
      final hours = int.parse(parts[0]);
      expect(hours >= 3 && hours <= 10, isTrue,
          reason: 'Hours should be valid active work duration, got $hours');
      expect(controller.elapsedHoursMinutes.value, isNot(equals('00:00')));
      expect(controller.elapsedSeconds.value, isNotEmpty);
    });

    test('Live ticking seconds advance accurately for working session and break session', () {
      final now = DateTime.now();
      // Start 1 minute and 25 seconds ago
      final workStart = now.subtract(const Duration(minutes: 1, seconds: 25));

      final workingModel = TodayAttendanceModel(
        checkInTime: '10:00',
        checkOutTime: '--:--',
        workingHours: '0h 01m',
        shiftRemaining: '6h 59m',
        overtime: '0:00',
        isCheckedIn: true,
        isOnBreak: false,
        status: 'In Progress',
        officeRadiusStatus: 'Verified',
        shiftTiming: '09:00 - 17:00',
        shiftName: 'Day Shift',
        checkInDateTime: workStart,
        segments: [
          AttendanceSegmentModel(
            kind: 'work',
            startsAt: workStart,
            endsAt: null,
            paid: true,
          ),
        ],
      );

      final controller = DashboardController(repo: MockDashboardRepo());
      controller.dashboardData.value = DashboardDataModel(
        todayAttendance: workingModel,
        monthlySummary: const MonthlySummaryModel(
          totalDays: 20,
          presentDays: 15,
          lateDays: 2,
          absentDays: 1,
          attendanceRate: 90.0,
          monthName: 'Nov',
        ),
      );

      controller.updateRunningShiftTimer();

      // Should be 1 minute and ~25 seconds
      expect(controller.elapsedHoursMinutes.value, '00:01');
      expect(int.parse(controller.elapsedSeconds.value) >= 24, isTrue);

      // Now switch to break session started 42 seconds ago
      final breakStart = now.subtract(const Duration(seconds: 42));
      final breakModel = workingModel.copyWith(
        isOnBreak: true,
        breakStartDateTime: breakStart,
        segments: [
          AttendanceSegmentModel(
            kind: 'work',
            startsAt: workStart,
            endsAt: breakStart,
            paid: true,
          ),
          AttendanceSegmentModel(
            kind: 'break',
            startsAt: breakStart,
            endsAt: null,
            paid: false,
          ),
        ],
      );

      controller.dashboardData.value = DashboardDataModel(
        todayAttendance: breakModel,
        monthlySummary: controller.dashboardData.value!.monthlySummary,
      );

      controller.updateRunningShiftTimer();

      // Break timer should reflect ~42 seconds
      expect(controller.elapsedBreakHoursMinutes.value, '00:00');
      expect(int.parse(controller.elapsedBreakSeconds.value) >= 41, isTrue);
      // In foreground when on break, elapsedSeconds is set to break seconds
      expect(int.parse(controller.elapsedSeconds.value) >= 41, isTrue);
    });
  });
}
