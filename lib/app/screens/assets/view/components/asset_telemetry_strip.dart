import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/custom_telemetry_strip.dart';
import '../../controller/asset_controller.dart';

class AssetTelemetryStrip extends GetView<AssetController> {
  const AssetTelemetryStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final total = controller.totalCount;
      final active = controller.activeCount;
      final pending = controller.pendingAcknowledgeCount;
      final returned = controller.returnedCount;

      final items = [
        CustomTelemetryItem(
          id: 'All',
          label: 'Total',
          count: total,
          icon: Icons.inventory_2_outlined,
          accentColor: AppColors.primary,
        ),
        CustomTelemetryItem(
          id: 'Active',
          label: 'In Custody',
          count: active,
          icon: Icons.check_circle_outline_rounded,
          accentColor: AppColors.secondary,
        ),
        CustomTelemetryItem(
          id: 'Pending',
          label: 'Pending',
          count: pending,
          icon: Icons.pending_actions_rounded,
          accentColor: AppColors.warning,
        ),
        CustomTelemetryItem(
          id: 'Returned',
          label: 'Returned',
          count: returned,
          icon: Icons.assignment_return_outlined,
          accentColor: AppColors.subTextColor,
        ),
      ];

      return CustomTelemetryStrip(
        items: items,
        selectedId: controller.selectedFilter.value,
        onSelect: controller.setFilter,
      );
    });
  }
}
