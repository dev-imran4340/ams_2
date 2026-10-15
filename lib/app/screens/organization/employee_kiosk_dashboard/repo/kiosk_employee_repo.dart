import '../../../../api/exception_handler.dart';
import '../model/kiosk_employee_model.dart';

class KioskEmployeeRepo {
  final String _tag = 'KioskEmployeeRepo / EmployeeKioskDashboard';

  /// Fetches identified employee profile and shift punch state
  Future<KioskEmployeeProfileModel?> fetchKioskProfile() async {
    try {
      // 250ms simulated network latency for UI prototyping phase
      await Future.delayed(const Duration(milliseconds: 250));
      return KioskEmployeeProfileModel.mock();
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to load kiosk employee profile: $e'),
        tag: '$_tag -> fetchKioskProfile() [${stackTrace.toString().split('\n').first}]',
      );
      return null;
    }
  }

  /// Toggles punch action on the kiosk terminal
  Future<bool> punchAttendance(String actionType) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      return true;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Kiosk punch action failed: $e'),
        tag: '$_tag -> punchAttendance() [${stackTrace.toString().split('\n').first}]',
      );
      return false;
    }
  }
}
