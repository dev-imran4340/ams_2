import 'package:ams_2/app/api/api_client.dart';
import 'package:ams_2/app/api/api_endpoints.dart';
import 'package:ams_2/app/api/app_preferences.dart';
import 'package:ams_2/app/api/exception_handler.dart';
import 'package:ams_2/app/screens/employees/model/department_employee_model.dart';
import 'package:ams_2/app/screens/kiosk/model/kiosk_model.dart';
import 'package:ams_2/app/screens/kiosk/repo/kiosk_repo.dart';

class CompanyDashboardRepo {
  final String _tag = 'CompanyDashboardRepo / CompanyDashboardScreen';
  final KioskRepo _kioskRepo = KioskRepo();

  /// Hydrates current company session, effective permissions, and dynamic menus from GET /me
  Future<Map<String, dynamic>?> fetchMe() async {
    try {
      final response = await ApiClient.request(
        endpoint: ApiEndpoints.me,
        method: HttpMethod.get,
        tag: '$_tag -> fetchMe()',
        showToastOnError: false,
      );

      if (response != null && response is Map<String, dynamic>) {
        await AppPreferences.saveMeData(response);
        return response;
      }
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to refresh company profile: $e'),
        tag: '$_tag -> fetchMe() [${stackTrace.toString().split('\n').first}]',
      );
    }
    return null;
  }

  /// Fetches employees for company dashboard directory (GET /employees)
  /// Strict Invariant: Returns live data or empty list []; NO dummy / mock fallback.
  Future<List<DepartmentEmployeeModel>> fetchEmployees({String? search}) async {
    try {
      final queryParams = <String, String>{
        'per_page': '50',
      };
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      final response = await ApiClient.request(
        endpoint: ApiEndpoints.employees,
        method: HttpMethod.get,
        queryParameters: queryParams,
        tag: '$_tag -> fetchEmployees()',
        showToastOnError: false,
      );

      if (response != null && response is Map) {
        final rawData = response['data'];
        if (rawData is List) {
          final list = rawData
              .whereType<Map>()
              .map((e) => DepartmentEmployeeModel.fromJson(
                    Map<String, dynamic>.from(e),
                  ))
              .toList();
          return list;
        }
      }
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Remote employees fetch failed: $e'),
        tag: '$_tag -> fetchEmployees() [${stackTrace.toString().split('\n').first}]',
      );
    }
    return <DepartmentEmployeeModel>[];
  }

  /// Fetches active kiosk station configuration using tablet's kiosk token
  Future<KioskConfigModel?> fetchActiveKioskConfig() async {
    return _kioskRepo.fetchKioskConfig();
  }

  /// Fetches work locations available for kiosk provisioning (GET /kiosks/locations)
  Future<List<KioskLocationModel>> fetchKioskLocations() async {
    return _kioskRepo.fetchKioskLocations();
  }

  /// Provisions this tablet device as a dedicated company kiosk (POST /kiosks)
  /// Checks kiosks.manage permission on caller
  Future<KioskConfigModel?> provisionKiosk({
    required String name,
    required String location,
    bool replace = false,
  }) async {
    return _kioskRepo.provisionKiosk(
      name: name,
      location: location,
      replace: replace,
    );
  }

  /// Logs out setup administrator after provisioning (POST /auth/logout)
  /// Preserves the newly saved kiosk token while purging personal credentials
  Future<bool> logoutSetupUser() async {
    try {
      await ApiClient.request(
        endpoint: ApiEndpoints.logout,
        method: HttpMethod.post,
        tag: '$_tag -> logoutSetupUser()',
        showToastOnError: false,
      );
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Logout notice: $e'),
        tag: '$_tag -> logoutSetupUser() [${stackTrace.toString().split('\n').first}]',
      );
    } finally {
      // Clear personal user session while strictly preserving kiosk credentials
      await AppPreferences.clearSession();
    }
    return true;
  }

  /// Clears stored kiosk tablet credentials and active configuration
  Future<void> clearKioskStation() async {
    await AppPreferences.clearKioskSession();
  }
}
