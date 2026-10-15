import '../../../../api/exception_handler.dart';
import '../model/add_employee_model.dart';

class AddEmployeeRepo {
  final String _tag = 'AddEmployeeRepo / AddEmployeeScreen';

  /// Fetches form lookups (departments, shifts, cities)
  Future<AddEmployeeLookupModel> fetchLookupData() async {
    try {
      // 250ms simulated latency for UI prototyping phase
      await Future.delayed(const Duration(milliseconds: 250));
      return AddEmployeeLookupModel.fallback();
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to retrieve registration lookups: $e'),
        tag: '$_tag -> fetchLookupData() [${stackTrace.toString().split('\n').first}]',
      );
      return AddEmployeeLookupModel.fallback();
    }
  }

  /// Submits newly enrolled employee details to the organization roster
  Future<AddEmployeeResponseModel?> registerEmployee(AddEmployeeRequestModel request) async {
    try {
      // 500ms simulated network latency for UI & Prototyping phase
      await Future.delayed(const Duration(milliseconds: 500));

      final response = {
        'success': true,
        'message': 'Employee ${request.fullName} successfully enrolled to the organization roster.',
        'employee_id': 'EMP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      };

      return AddEmployeeResponseModel.fromJson(response);
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Employee enrollment failed: $e'),
        tag: '$_tag -> registerEmployee() [${stackTrace.toString().split('\n').first}]',
      );
      return null;
    }
  }
}
