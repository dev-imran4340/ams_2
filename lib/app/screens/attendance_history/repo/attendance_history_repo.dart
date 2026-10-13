import '../../../api/exception_handler.dart';
import '../model/attendance_history_model.dart';

class AttendanceHistoryRepo {
  final String _tag = 'AttendanceHistoryRepo / AttendanceHistoryScreen';

  /// Fetches monthly attendance history records and telemetry summary
  Future<AttendanceHistoryResponse?> fetchMonthlyHistory(DateTime month) async {
    try {
      // Simulate realistic loader delay for UI state demonstration
      await Future.delayed(const Duration(milliseconds: 600));

      final int year = month.year;
      final int monthNum = month.month;
      // Days in this month
      final int daysInMonth = DateTime(year, monthNum + 1, 0).day;

      final List<AttendanceDayLog> generatedLogs = [];
      int presentCount = 0;
      int lateCount = 0;
      int absentCount = 0;
      int leaveCount = 0;

      const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      final monthName = months[monthNum - 1];

      for (int day = 1; day <= daysInMonth; day++) {
        final date = DateTime(year, monthNum, day);
        final dayName = weekdays[date.weekday - 1];
        final formattedDate = '$monthName ${day.toString().padLeft(2, '0')}, $year';
        final isWeekend = date.weekday == DateTime.saturday ||
            date.weekday == DateTime.sunday;

        String status;
        String checkIn;
        String checkOut;
        String workingHours;
        String breakDuration;

        if (isWeekend) {
          status = 'Holiday';
          checkIn = '--:--';
          checkOut = '--:--';
          workingHours = '00h 00m';
          breakDuration = '00m';
        } else if (day == 8) {
          status = 'Late';
          checkIn = '09:34 AM';
          checkOut = '06:45 PM';
          workingHours = '08h 40m';
          breakDuration = '45m';
          lateCount++;
        } else if (day == 14) {
          status = 'Leave';
          checkIn = '--:--';
          checkOut = '--:--';
          workingHours = '00h 00m';
          breakDuration = '00m';
          leaveCount++;
        } else if (day > 13) {
          // Future scheduled working days in current month
          status = 'Upcoming';
          checkIn = '--:--';
          checkOut = '--:--';
          workingHours = '00h 00m';
          breakDuration = '00m';
        } else {
          status = 'On-Time';
          checkIn = '09:${(10 + (day % 6)).toString().padLeft(2, '0')} AM';
          checkOut = '06:${(12 + (day % 15)).toString().padLeft(2, '0')} PM';
          workingHours = '08h 55m';
          breakDuration = '45m';
          presentCount++;
        }

        generatedLogs.add(
          AttendanceDayLog(
            date: date,
            formattedDate: formattedDate,
            dayName: dayName,
            checkInTime: checkIn,
            checkOutTime: checkOut,
            workingHours: workingHours,
            breakDuration: breakDuration,
            status: status,
            workLocation: day % 4 == 0 ? 'Remote' : 'HQ Office',
            isSynced: true,
          ),
        );
      }

      final summary = MonthlyTelemetrySummary(
        totalDays: daysInMonth,
        presentCount: presentCount,
        lateCount: lateCount,
        absentCount: absentCount,
        leaveCount: leaveCount,
        attendanceRate: 94.5,
      );

      return AttendanceHistoryResponse(
        logs: generatedLogs,
        summary: summary,
      );
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to fetch attendance history: $e'),
        tag: '$_tag -> fetchMonthlyHistory() [${stackTrace.toString().split('\n').first}]',
      );
      return null;
    }
  }

  /// Simulates export of monthly attendance report to PDF
  Future<bool> exportMonthlyReport(DateTime month) async {
    try {
      await Future.delayed(const Duration(milliseconds: 1000));
      return true;
    } catch (e) {
      ExceptionHandler.handle(
        ApiException(message: 'Report export failed: $e'),
        tag: '$_tag -> exportMonthlyReport()',
      );
      return false;
    }
  }
}
