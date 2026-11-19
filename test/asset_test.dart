import 'package:ams_2/app/screens/assets/controller/asset_controller.dart';
import 'package:ams_2/app/screens/assets/model/asset_model.dart';
import 'package:ams_2/app/screens/assets/repo/asset_repo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class MockAssetRepo extends AssetRepo {
  final List<AssetAssignmentModel> mockAssignments = [
    const AssetAssignmentModel(
      id: '01jb2x9k4m7q8r3t5v6w8y0z1a',
      asset: AssetItemModel(
        id: '01ja1',
        code: 'AST-0007',
        name: 'Dell Latitude 5440',
        category: 'Laptop',
        serialNumber: '5CD1234XYZ',
      ),
      assignedOn: '2026-11-02',
      conditionOut: 'Good',
      acknowledgedAt: null,
      returnedOn: null,
      isOpen: true,
      charged: false,
    ),
    const AssetAssignmentModel(
      id: '01jb2x9k4m7q8r3t5v6w8y0z1b',
      asset: AssetItemModel(
        id: '01ja2',
        code: 'AST-0012',
        name: 'Samsung Galaxy A54',
        category: 'Mobile Phone',
        serialNumber: 'R58M1234567',
      ),
      assignedOn: '2026-10-15',
      conditionOut: 'Excellent',
      acknowledgedAt: '2026-10-15T10:00:00Z',
      returnedOn: null,
      isOpen: true,
      charged: false,
    ),
    const AssetAssignmentModel(
      id: '01jb2x9k4m7q8r3t5v6w8y0z1c',
      asset: AssetItemModel(
        id: '01ja3',
        code: 'AST-0003',
        name: 'Dell 24-inch Monitor P2419H',
        category: 'Display Monitor',
        serialNumber: 'CN-0987654',
      ),
      assignedOn: '2026-06-01',
      conditionOut: 'Good',
      acknowledgedAt: '2026-06-01T12:00:00Z',
      returnedOn: '2026-09-30',
      conditionIn: 'Good',
      isOpen: false,
      charged: false,
    ),
  ];

  @override
  Future<List<AssetAssignmentModel>?> fetchAssets() async {
    return mockAssignments;
  }

  @override
  Future<bool> acknowledgeAsset(String assignmentId) async {
    return true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 18 (Part 2) Asset Model & Schema Tests', () {
    test('AssetAssignmentModel parses live API JSON correctly', () {
      final json = {
        'id': '01jb2x9k4m7q8r3t5v6w8y0z1a',
        'asset': {
          'id': '01ja1',
          'code': 'AST-0007',
          'name': 'Dell Latitude 5440',
          'category': 'Laptop',
          'serial_number': '5CD1234XYZ',
        },
        'assigned_on': '2026-11-02',
        'expected_return_on': null,
        'condition_out': 'Good',
        'acknowledged_at': null,
        'returned_on': null,
        'condition_in': null,
        'note': null,
        'is_open': true,
        'charged': false,
      };

      final item = AssetAssignmentModel.fromJson(json);

      expect(item.id, '01jb2x9k4m7q8r3t5v6w8y0z1a');
      expect(item.asset.code, 'AST-0007');
      expect(item.asset.name, 'Dell Latitude 5440');
      expect(item.asset.category, 'Laptop');
      expect(item.asset.serialNumber, '5CD1234XYZ');
      expect(item.assignedOn, '2026-11-02');
      expect(item.conditionOut, 'Good');
      expect(item.isOpen, true);
      expect(item.isCurrentlyHeld, true);
      expect(item.isReturned, false);
      expect(item.isAcknowledged, false);
      expect(item.canAcknowledge, true);
    });

    test('AssetAssignmentModel state flags evaluate correctly for returned asset', () {
      const returnedAsset = AssetAssignmentModel(
        id: '01ret',
        asset: AssetItemModel(
          id: '01a',
          code: 'AST-01',
          name: 'Access Card',
          category: 'Keycard',
        ),
        returnedOn: '2026-11-01',
        isOpen: false,
      );

      expect(returnedAsset.isReturned, true);
      expect(returnedAsset.isCurrentlyHeld, false);
      expect(returnedAsset.canAcknowledge, false);
    });
  });

  group('AssetController Lifecycle & Telemetry Tests', () {
    late MockAssetRepo mockRepo;
    late AssetController controller;

    setUp(() {
      Get.testMode = true;
      mockRepo = MockAssetRepo();
      controller = AssetController(repo: mockRepo);
    });

    tearDown(() {
      controller.onClose();
      Get.reset();
    });

    test('Loads assets and computes operational telemetry correctly', () async {
      await controller.loadAssets();

      expect(controller.assets.length, 3);
      expect(controller.totalCount, 3);
      expect(controller.activeCount, 2); // 2 currently held
      expect(controller.pendingAcknowledgeCount, 1); // 1 needs ack
      expect(controller.returnedCount, 1); // 1 returned
      expect(controller.isLoading.value, false);
    });

    test('Filters asset list by Active, Pending, and Returned tabs', () async {
      await controller.loadAssets();

      // All tab
      controller.setFilter('All');
      expect(controller.filteredAssets.length, 3);

      // Active tab
      controller.setFilter('Active');
      expect(controller.filteredAssets.length, 2);
      expect(controller.filteredAssets.every((a) => a.isCurrentlyHeld), true);

      // Pending tab
      controller.setFilter('Pending');
      expect(controller.filteredAssets.length, 1);
      expect(controller.filteredAssets.first.asset.code, 'AST-0007');

      // Returned tab
      controller.setFilter('Returned');
      expect(controller.filteredAssets.length, 1);
      expect(controller.filteredAssets.first.asset.code, 'AST-0003');
    });

    test('Acknowledge asset updates status to acknowledged', () async {
      await controller.loadAssets();
      final pendingItem = controller.assets.firstWhere((a) => a.canAcknowledge);

      await controller.acknowledgeAsset(pendingItem);

      final updated = controller.assets.firstWhere((a) => a.id == pendingItem.id);
      expect(updated.isAcknowledged, true);
      expect(updated.canAcknowledge, false);
      expect(controller.pendingAcknowledgeCount, 0);
    });
  });
}
