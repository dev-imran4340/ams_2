import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../api/app_preferences.dart';
import '../../../core/services/permission_service.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../model/asset_model.dart';
import '../repo/asset_repo.dart';
import '../view/components/asset_details_bottom_sheet.dart';

class AssetController extends GetxController {
  final AssetRepo repo;

  AssetController({required this.repo});

  // State Observables
  final RxBool isLoading = false.obs;
  final RxBool isAcknowledging = false.obs;
  final RxBool isAccessRestricted = false.obs;
  final RxString accessRestrictedMessage = ''.obs;

  bool get canViewAssets =>
      AppPreferences.hasPermission(AppPermissions.assetsView);
  bool get canManageAssets =>
      AppPreferences.hasPermission(AppPermissions.assetsManage);

  /// Filter tabs: 'All', 'Active' (Currently Held), 'Pending' (Needs Acknowledgment), 'Returned'
  final RxString selectedFilter = 'All'.obs;

  final RxList<AssetAssignmentModel> assets = <AssetAssignmentModel>[].obs;
  final Rxn<AssetAssignmentModel> selectedAsset = Rxn<AssetAssignmentModel>();

  final List<String> filterTabs = [
    'All',
    'Active',
    'Pending',
    'Returned',
  ];

  // Telemetry counts
  int get totalCount => assets.length;
  int get activeCount => assets.where((a) => a.isCurrentlyHeld).length;
  int get pendingAcknowledgeCount => assets.where((a) => a.canAcknowledge).length;
  int get returnedCount => assets.where((a) => a.isReturned).length;

  /// Filtered asset assignments list
  List<AssetAssignmentModel> get filteredAssets {
    switch (selectedFilter.value) {
      case 'Active':
        return assets.where((a) => a.isCurrentlyHeld).toList();
      case 'Pending':
        return assets.where((a) => a.canAcknowledge).toList();
      case 'Returned':
        return assets.where((a) => a.isReturned).toList();
      case 'All':
      default:
        return assets;
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadAssets();
  }

  /// Loads equipment inventory from live backend
  Future<void> loadAssets({bool isRefresh = false}) async {
    if (!canViewAssets) {
      isAccessRestricted.value = true;
      accessRestrictedMessage.value =
          'You do not have permission to view company assets.';
      return;
    }
    isAccessRestricted.value = false;
    try {
      isLoading.value = true;
      final result = await repo.fetchAssets();
      if (result != null) {
        assets.assignAll(result);
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Selects filter tab
  void setFilter(String filter) {
    if (selectedFilter.value == filter) return;
    HapticFeedback.selectionClick();
    selectedFilter.value = filter;
  }

  /// Opens asset audit details bottom sheet
  void openAssetDetails(BuildContext context, AssetAssignmentModel item) {
    HapticFeedback.lightImpact();
    selectedAsset.value = item;
    AssetDetailsBottomSheet.show(context, assignment: item);
  }

  /// Acknowledges receipt of equipment
  Future<void> acknowledgeAsset(AssetAssignmentModel item) async {
    if (isAcknowledging.value) return;

    if (!PermissionService.verifyAction(
      AppPermissions.assetsView,
      actionName: 'acknowledge asset receipt',
    )) {
      return;
    }

    try {
      isAcknowledging.value = true;
      HapticFeedback.mediumImpact();

      final success = await repo.acknowledgeAsset(item.id);
      if (success) {
        final nowIso = DateTime.now().toIso8601String();
        final updated = item.copyWith(acknowledgedAt: nowIso);

        // Update in list
        final index = assets.indexWhere((a) => a.id == item.id);
        if (index != -1) {
          assets[index] = updated;
        }

        // Update selected asset
        if (selectedAsset.value?.id == item.id) {
          selectedAsset.value = updated;
        }

        HapticFeedback.heavyImpact();
        CustomSnackbar.showSuccess(
          title: 'Asset Acknowledged',
          message:
              'Receipt for "${item.asset.name}" (${item.asset.code}) confirmed.',
        );
      }
    } finally {
      isAcknowledging.value = false;
    }
  }
}
