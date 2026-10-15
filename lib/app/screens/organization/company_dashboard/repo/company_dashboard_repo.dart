import '../../../../api/exception_handler.dart';
import '../model/company_dashboard_model.dart';

class CompanyDashboardRepo {
  final String _tag = 'CompanyDashboardRepo / CompanyDashboardScreen';

  /// Fetches corporate organization dashboard telemetry, donut stats, and recent punch feed
  Future<CompanyDashboardModel?> fetchCompanyDashboard() async {
    try {
      // 300ms simulated network latency for UI & Prototyping phase
      await Future.delayed(const Duration(milliseconds: 300));
      return CompanyDashboardModel.mock();
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to load company dashboard telemetry: $e'),
        tag: '$_tag -> fetchCompanyDashboard() [${stackTrace.toString().split('\n').first}]',
      );
      return null;
    }
  }
}
