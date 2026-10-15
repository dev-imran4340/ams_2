import '../../../../api/exception_handler.dart';
import '../model/visitor_model.dart';

class VisitorRepo {
  final String _tag = 'VisitorRepo / VisitorManagementScreen';

  /// In-memory cache for prototyping phase so state changes persist during runtime
  final List<VisitorModel> _cachedActiveVisitors = [
    VisitorModel(
      id: 'VIS-9021',
      fullName: 'Muhammad Bilal Khan',
      cnic: '42101-3829102-1',
      phone: '+92 300 2345678',
      purpose: 'Meeting',
      hostEmployee: 'Hamza Sheikh • Engineering',
      photoPath: null,
      checkInTime: DateTime.now().subtract(const Duration(hours: 1, minutes: 25)),
      isActive: true,
    ),
    VisitorModel(
      id: 'VIS-9022',
      fullName: 'Syeda Maryam Zahra',
      cnic: '35202-9182736-2',
      phone: '+92 321 8765432',
      purpose: 'Interview',
      hostEmployee: 'Ayesha Siddiqui • Human Resources',
      photoPath: null,
      checkInTime: DateTime.now().subtract(const Duration(minutes: 54)),
      isActive: true,
    ),
    VisitorModel(
      id: 'VIS-9023',
      fullName: 'Tariq Mehmood',
      cnic: '37405-1827364-5',
      phone: '+92 333 4567890',
      purpose: 'Delivery',
      hostEmployee: 'Usman Farooq • Supply Chain',
      photoPath: null,
      checkInTime: DateTime.now().subtract(const Duration(minutes: 32)),
      isActive: true,
    ),
    VisitorModel(
      id: 'VIS-9024',
      fullName: 'Kamran Ahmed',
      cnic: '42201-8374625-3',
      phone: '+92 345 6789012',
      purpose: 'Maintenance',
      hostEmployee: 'Ali Raza • IT Operations',
      photoPath: null,
      checkInTime: DateTime.now().subtract(const Duration(hours: 2, minutes: 10)),
      isActive: true,
    ),
  ];

  final List<HostEmployeeOption> _cachedHostEmployees = const [
    HostEmployeeOption(
      id: 'EMP-101',
      name: 'Hamza Sheikh',
      department: 'Engineering',
    ),
    HostEmployeeOption(
      id: 'EMP-102',
      name: 'Ayesha Siddiqui',
      department: 'Human Resources',
    ),
    HostEmployeeOption(
      id: 'EMP-103',
      name: 'Usman Farooq',
      department: 'Supply Chain',
    ),
    HostEmployeeOption(
      id: 'EMP-104',
      name: 'Ali Raza',
      department: 'IT Operations',
    ),
    HostEmployeeOption(
      id: 'EMP-105',
      name: 'Zainab Fatima',
      department: 'Corporate Finance',
    ),
    HostEmployeeOption(
      id: 'EMP-106',
      name: 'Bilal Tariq',
      department: 'Client Relations',
    ),
  ];

  /// Fetches active on-site visitors with 500ms simulated latency
  Future<List<VisitorModel>> fetchActiveVisitors() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      return List<VisitorModel>.from(_cachedActiveVisitors);
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to fetch active visitors: $e'),
        tag:
            '$_tag -> fetchActiveVisitors() [${stackTrace.toString().split('\n').first}]',
      );
      return [];
    }
  }

  /// Fetches company host employee list for reception selection
  Future<List<HostEmployeeOption>> fetchHostEmployees() async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      return List<HostEmployeeOption>.from(_cachedHostEmployees);
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to fetch host employees: $e'),
        tag:
            '$_tag -> fetchHostEmployees() [${stackTrace.toString().split('\n').first}]',
      );
      return [];
    }
  }

  /// Submits visitor check-in intake and creates digital pass
  Future<VisitorModel?> submitVisitorEntry(Map<String, dynamic> data) async {
    try {
      await Future.delayed(const Duration(milliseconds: 550));

      final int nextSequence = 9025 + _cachedActiveVisitors.length;
      final newVisitor = VisitorModel(
        id: 'VIS-$nextSequence',
        fullName: data['full_name']?.toString() ?? 'Guest Visitor',
        cnic: data['cnic']?.toString() ?? '',
        phone: data['phone']?.toString() ?? '',
        purpose: data['purpose']?.toString() ?? 'Meeting',
        hostEmployee: data['host_employee']?.toString() ?? 'Front Desk Reception',
        photoPath: data['photo_path']?.toString(),
        checkInTime: DateTime.now(),
        isActive: true,
      );

      _cachedActiveVisitors.insert(0, newVisitor);
      return newVisitor;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to register visitor check-in: $e'),
        tag:
            '$_tag -> submitVisitorEntry() [${stackTrace.toString().split('\n').first}]',
      );
      return null;
    }
  }

  /// Closes visitor on-site session and marks checkout
  Future<bool> markVisitorExit(String visitorId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 450));
      final index =
          _cachedActiveVisitors.indexWhere((element) => element.id == visitorId);
      if (index != -1) {
        _cachedActiveVisitors.removeAt(index);
        return true;
      }
      return false;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to process visitor checkout: $e'),
        tag:
            '$_tag -> markVisitorExit() [${stackTrace.toString().split('\n').first}]',
      );
      return false;
    }
  }
}
