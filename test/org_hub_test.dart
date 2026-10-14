import 'package:ams_2/app/screens/organization/org_hub/controller/org_hub_controller.dart';
import 'package:ams_2/app/screens/organization/org_hub/model/org_hub_model.dart';
import 'package:ams_2/app/screens/organization/org_hub/repo/org_hub_repo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OrgPortalSummaryModel Tests', () {
    test('serializes and deserializes correctly', () {
      final model = const OrgPortalSummaryModel(
        organizationName: 'SoftGenie Global Technologies',
        branchLocation: 'HQ Campus • Islamabad',
        activeVisitorsCount: 12,
        todayEmployeesPresent: 150,
        totalStaff: 160,
        isGateTerminalActive: true,
      );

      final json = model.toJson();
      final fromJsonModel = OrgPortalSummaryModel.fromJson(json);

      expect(fromJsonModel.organizationName, 'SoftGenie Global Technologies');
      expect(fromJsonModel.branchLocation, 'HQ Campus • Islamabad');
      expect(fromJsonModel.activeVisitorsCount, 12);
      expect(fromJsonModel.todayEmployeesPresent, 150);
      expect(fromJsonModel.totalStaff, 160);
      expect(fromJsonModel.isGateTerminalActive, true);
    });

    test('computed metrics calculate correctly', () {
      const model = OrgPortalSummaryModel(
        organizationName: 'Acme Corp',
        branchLocation: 'Main Tower',
        activeVisitorsCount: 5,
        todayEmployeesPresent: 80,
        totalStaff: 100,
        isGateTerminalActive: true,
      );

      expect(model.attendancePercentage, '80.0');
      expect(model.attendanceRatio, 0.8);
      expect(model.absentEmployeesCount, 20);
    });

    test('computed metrics handle zero staff safely', () {
      const model = OrgPortalSummaryModel(
        organizationName: 'Empty Branch',
        branchLocation: 'Remote',
        activeVisitorsCount: 0,
        todayEmployeesPresent: 0,
        totalStaff: 0,
        isGateTerminalActive: false,
      );

      expect(model.attendancePercentage, '0.0');
      expect(model.attendanceRatio, 0.0);
      expect(model.absentEmployeesCount, 0);
    });
  });

  group('OrgHubRepo Tests', () {
    test('fetchOrgSummary returns valid organization telemetry', () async {
      final repo = OrgHubRepo();
      final result = await repo.fetchOrgSummary();

      expect(result, isNotNull);
      expect(result!.organizationName, 'SoftGenie Global Technologies');
      expect(result.activeVisitorsCount, 8);
      expect(result.todayEmployeesPresent, 142);
      expect(result.totalStaff, 160);
      expect(result.isGateTerminalActive, true);
    });
  });

  group('OrgHubController Logic Tests', () {
    test('loadOrgSummary updates summary observable', () async {
      final repo = OrgHubRepo();
      final controller = OrgHubController(repo: repo);

      await controller.loadOrgSummary();

      expect(controller.summary.value, isNotNull);
      expect(controller.summary.value?.organizationName,
          'SoftGenie Global Technologies');
      expect(controller.isLoading.value, false);

      controller.onClose();
    });

    test('navigation methods execute safely without exceptions', () {
      final repo = OrgHubRepo();
      final controller = OrgHubController(repo: repo);

      expect(() => controller.navigateToVisitorManagement(), returnsNormally);
      expect(() => controller.navigateToEmployeeTerminal(), returnsNormally);
      expect(() => controller.navigateToAddEmployee(), returnsNormally);

      controller.onClose();
    });
  });
}
