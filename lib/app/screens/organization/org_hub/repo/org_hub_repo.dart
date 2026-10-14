import 'dart:async';

import '../../../../api/exception_handler.dart';
import '../model/org_hub_model.dart';

class OrgHubRepo {
  final String _tag = 'OrgHubRepo / OrgHubScreen';

  static const OrgPortalSummaryModel _defaultMockSummary =
      OrgPortalSummaryModel(
    organizationName: 'SoftGenie Global Technologies',
    branchLocation: 'HQ Campus • Islamabad',
    activeVisitorsCount: 8,
    todayEmployeesPresent: 142,
    totalStaff: 160,
    isGateTerminalActive: true,
  );

  /// Fetches enterprise organization operational metrics and gate telemetry
  Future<OrgPortalSummaryModel?> fetchOrgSummary() async {
    try {
      // Simulate realistic organizational server latency
      await Future.delayed(const Duration(milliseconds: 400));

      return _defaultMockSummary;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to fetch organization portal telemetry: $e'),
        tag:
            '$_tag -> fetchOrgSummary() [${stackTrace.toString().split('\n').first}]',
      );
      return null;
    }
  }
}
