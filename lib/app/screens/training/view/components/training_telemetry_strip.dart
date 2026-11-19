import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/custom_telemetry_strip.dart';
import '../../controller/training_controller.dart';

class TrainingTelemetryStrip extends GetView<TrainingController> {
  const TrainingTelemetryStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final totalReq = controller.totalRequired;
      final validCompliant = controller.validCompliantCount;
      final pendingReq = controller.pendingRequiredCount;
      final totalRec = controller.totalRecordsCount;

      final items = [
        CustomTelemetryItem(
          id: 'required',
          label: 'Required',
          count: totalReq,
          icon: Icons.checklist_rounded,
          accentColor: AppColors.primary,
        ),
        CustomTelemetryItem(
          id: 'compliant',
          label: 'Compliant',
          count: validCompliant,
          icon: Icons.verified_outlined,
          accentColor: AppColors.success,
        ),
        CustomTelemetryItem(
          id: 'pending',
          label: 'Pending',
          count: pendingReq,
          icon: Icons.warning_amber_rounded,
          accentColor: AppColors.warning,
        ),
        CustomTelemetryItem(
          id: 'records',
          label: 'Records',
          count: totalRec,
          icon: Icons.history_edu_rounded,
          accentColor: AppColors.secondary,
        ),
      ];

      return CustomTelemetryStrip(
        items: items,
        selectedId: controller.selectedTelemetryId.value,
        onSelect: controller.selectTelemetry,
      );
    });
  }
}
