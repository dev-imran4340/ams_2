import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:ams_2/app/core/utils/app_colors.dart';
import 'package:ams_2/app/core/utils/app_spaces.dart';
import 'package:ams_2/app/core/widgets/custom_screen_header.dart';
import 'package:ams_2/app/core/widgets/custom_state_view.dart';
import 'package:ams_2/app/core/widgets/custom_telemetry_strip.dart';
import 'package:ams_2/app/core/widgets/employee_ambient_header.dart';
import 'package:ams_2/app/core/widgets/network_boundary_wrapper.dart';
import '../controller/kiosk_controller.dart';
import 'components/kiosk_provision_card.dart';

class KioskView extends GetView<KioskController> {
  const KioskView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkBoundaryWrapper(
      onRetry: controller.loadKioskState,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Stack(
          children: [
            // 1. Signature Curved Ambient Gradient Header (230.h)
            EmployeeAmbientHeader(height: 230.h),

            // 2. Main Scrollable Content Overlapping the Header
            SafeArea(
              bottom: false,
              child: RefreshIndicator(
                onRefresh: controller.loadKioskState,
                color: AppColors.secondary,
                child: SingleChildScrollView(
                  controller: controller.scrollController,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 8.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Bar: Back Pill & Screen Title Capsule
                      CustomScreenHeader(
                        title: 'Kiosk Terminal',
                        subtitle: 'Reception tablet station setup',
                        showBackButton: true,
                        onBack: () => Get.back(),
                      ),

                      AppSpaces.vSpace14,

                      // Component 1: Telemetry Metrics Strip
                      _buildTelemetryStrip(),

                      AppSpaces.vSpace16,

                      // Component 2: Tablet Terminal Content
                      _buildActiveTabContent(),

                      // Safe bottom clearance
                      SizedBox(height: 80.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Telemetry metrics strip adhering strictly to AMS 2.0 design rules
  Widget _buildTelemetryStrip() {
    return Obx(() {
      final isProvisioned = controller.isKioskProvisioned.value;
      final hasAdminRights = controller.canManageKiosks;

      final items = [
        CustomTelemetryItem(
          id: 'terminal',
          label: 'Tablet Station',
          count: isProvisioned ? 1 : 0,
          icon: Icons.tablet_mac_rounded,
          accentColor: AppColors.primary,
        ),
        CustomTelemetryItem(
          id: 'rights',
          label: 'Setup Rights',
          count: hasAdminRights ? 1 : 0,
          icon: Icons.admin_panel_settings_outlined,
          accentColor: hasAdminRights ? AppColors.success : AppColors.amberDark,
        ),
      ];

      return CustomTelemetryStrip(
        items: items,
        selectedId: 'terminal',
        onSelect: (_) {},
      );
    });
  }

  /// Dynamic content based on permission handling
  Widget _buildActiveTabContent() {
    return Obx(() {
      if (!controller.canManageKiosks) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 24.h),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(15.r),
            border: Border(
              bottom: BorderSide(color: AppColors.secondary, width: 3.w),
            ),
          ),
          child: Center(
            child: CustomStateView.empty(
              title: 'Administrator Access Required',
              message:
                  'Setting up enterprise kiosk tablet stations requires kiosks.manage administrator rights.',
              buttonText: 'Go Back',
              onAction: () => Get.back(),
            ),
          ),
        );
      }

      return KioskProvisionCard(controller: controller);
    });
  }
}
