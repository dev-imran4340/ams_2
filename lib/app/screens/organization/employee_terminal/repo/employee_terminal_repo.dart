import '../../../../api/exception_handler.dart';
import '../model/employee_terminal_model.dart';

class EmployeeTerminalRepo {
  final String _tag = 'EmployeeTerminalRepo / EmployeeTerminalScreen';

  final TerminalTelemetryModel _cachedTelemetry = const TerminalTelemetryModel(
    totalStaff: 160,
    presentToday: 142,
    absentToday: 14,
    unmarked: 4,
  );

  final List<PunchRecordItem> _cachedRecentPunches = [
    PunchRecordItem(
      id: 'PCH-882',
      employeeId: 'SFT-104',
      employeeName: 'Muhammad Imran',
      department: 'Mobile & AI Solutions',
      punchType: 'Check-In',
      punchTime: DateTime.now().subtract(const Duration(minutes: 2)),
      matchConfidence: 99.4,
    ),
    PunchRecordItem(
      id: 'PCH-881',
      employeeId: 'SFT-042',
      employeeName: 'Ayesha Siddiqui',
      department: 'Human Resources',
      punchType: 'Check-In',
      punchTime: DateTime.now().subtract(const Duration(minutes: 8)),
      matchConfidence: 98.9,
    ),
    PunchRecordItem(
      id: 'PCH-880',
      employeeId: 'SFT-088',
      employeeName: 'Bilal Tariq',
      department: 'Product Design',
      punchType: 'Check-Out',
      punchTime: DateTime.now().subtract(const Duration(minutes: 19)),
      matchConfidence: 99.1,
    ),
    PunchRecordItem(
      id: 'PCH-879',
      employeeId: 'SFT-019',
      employeeName: 'Hamza Sheikh',
      department: 'Engineering Architecture',
      punchType: 'Check-In',
      punchTime: DateTime.now().subtract(const Duration(minutes: 34)),
      matchConfidence: 99.8,
    ),
    PunchRecordItem(
      id: 'PCH-878',
      employeeId: 'SFT-112',
      employeeName: 'Fatima Zahra',
      department: 'Quality Assurance',
      punchType: 'Check-In',
      punchTime: DateTime.now().subtract(const Duration(minutes: 42)),
      matchConfidence: 99.0,
    ),
  ];

  final List<Map<String, String>> _mockEmployeePool = const [
    {
      'id': 'SFT-104',
      'name': 'Muhammad Imran',
      'dept': 'Mobile & AI Solutions',
    },
    {
      'id': 'SFT-019',
      'name': 'Hamza Sheikh',
      'dept': 'Engineering Architecture',
    },
    {
      'id': 'SFT-077',
      'name': 'Zainab Malik',
      'dept': 'Cloud Operations',
    },
    {
      'id': 'SFT-031',
      'name': 'Usman Farooq',
      'dept': 'DevOps Engineering',
    },
    {
      'id': 'SFT-065',
      'name': 'Ali Raza',
      'dept': 'Core Platform Services',
    },
    {
      'id': 'SFT-098',
      'name': 'Sara Khan',
      'dept': 'Product Management',
    },
  ];

  int _poolIndex = 0;

  /// Fetches terminal live telemetry counts
  Future<TerminalTelemetryModel> fetchTerminalTelemetry() async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      return _cachedTelemetry;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to fetch terminal telemetry: $e'),
        tag:
            '$_tag -> fetchTerminalTelemetry() [${stackTrace.toString().split('\n').first}]',
      );
      return _cachedTelemetry;
    }
  }

  /// Fetches latest attendance punch events on the terminal
  Future<List<PunchRecordItem>> fetchRecentPunches() async {
    try {
      await Future.delayed(const Duration(milliseconds: 450));
      return List<PunchRecordItem>.from(_cachedRecentPunches);
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to fetch recent punches: $e'),
        tag:
            '$_tag -> fetchRecentPunches() [${stackTrace.toString().split('\n').first}]',
      );
      return [];
    }
  }

  /// Processes continuous facial vector or QR payload and logs punch
  Future<PunchRecordItem?> processBiometricMatch({
    required String mockVectorOrQr,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 550));

      final employee = _mockEmployeePool[_poolIndex % _mockEmployeePool.length];
      _poolIndex++;

      final int nextId = 883 + _cachedRecentPunches.length;
      final punchType = (_poolIndex % 3 == 0) ? 'Check-Out' : 'Check-In';

      final newPunch = PunchRecordItem(
        id: 'PCH-$nextId',
        employeeId: employee['id']!,
        employeeName: employee['name']!,
        department: employee['dept']!,
        punchType: punchType,
        punchTime: DateTime.now(),
        matchConfidence: 99.4,
      );

      _cachedRecentPunches.insert(0, newPunch);
      return newPunch;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Biometric verification match failed: $e'),
        tag:
            '$_tag -> processBiometricMatch() [${stackTrace.toString().split('\n').first}]',
      );
      return null;
    }
  }
}
