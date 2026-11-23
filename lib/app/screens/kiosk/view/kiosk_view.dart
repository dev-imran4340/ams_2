import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:ams_2/app/core/utils/app_colors.dart';
import 'package:ams_2/app/core/utils/app_spaces.dart';
import 'package:ams_2/app/core/utils/app_text_styles.dart';
import 'package:ams_2/app/core/widgets/custom_screen_header.dart';
import 'package:ams_2/app/core/widgets/custom_state_view.dart';
import 'package:ams_2/app/core/widgets/custom_telemetry_strip.dart';
import 'package:ams_2/app/core/widgets/employee_ambient_header.dart';
import 'package:ams_2/app/core/widgets/network_boundary_wrapper.dart';
import '../controller/kiosk_controller.dart';
import 'components/kiosk_pin_card.dart';
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
                        title: 'Kiosk & Terminal PIN',
                        subtitle: 'Self-service PIN & reception tablet station',
                        showBackButton: true,
                        onBack: () => Get.back(),
                      ),

                      AppSpaces.vSpace14,

                      // Component 1: Telemetry Metrics Strip
                      _buildTelemetryStrip(),

                      AppSpaces.vSpace14,

                      // Component 2: Filter Tabs Row (Self-Service PIN vs Tablet Terminal)
                      _buildFilterTabs(),

                      AppSpaces.vSpace16,

                      // Component 3: Dynamic Tab Body
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
      final isPinSet = controller.isPinConfigured.value;
      final isProvisioned = controller.isKioskProvisioned.value;
      final hasAdminRights = controller.canManageKiosks;

      final items = [
        CustomTelemetryItem(
          id: 'pin',
          label: 'PIN Status',
          count: isPinSet ? 1 : 0,
          icon: Icons.password_rounded,
          accentColor: AppColors.secondary,
        ),
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
          accentColor: hasAdminRights ? const Color(0xFF10B981) : Colors.amber.shade700,
        ),
      ];

      return CustomTelemetryStrip(
        items: items,
        selectedId: controller.selectedTab.value,
        onSelect: (selectedId) {
          if (selectedId != 'rights') {
            controller.selectedTab.value = selectedId;
          }
        },
      );
    });
  }

  /// Animated filter tabs pill selector
  Widget _buildFilterTabs() {
    final tabs = [
      {'id': 'pin', 'label': 'Self-Service PIN', 'icon': Icons.password_rounded},
      {'id': 'terminal', 'label': 'Tablet Terminal', 'icon': Icons.tablet_mac_rounded},
    ];

    return SizedBox(
      height: 38.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (_, _) => AppSpaces.hSpace8,
        itemBuilder: (context, index) {
          final tab = tabs[index];
          final tabId = tab['id'] as String;
          final tabLabel = tab['label'] as String;
          final tabIcon = tab['icon'] as IconData;

          return Obx(() {
            final isSelected = controller.selectedTab.value == tabId;

            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => controller.selectedTab.value = tabId,
                borderRadius: BorderRadius.circular(20.r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.borderColor,
                      width: 1.w,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              blurRadius: 8.r,
                              offset: Offset(0, 2.h),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        tabIcon,
                        size: 16.sp,
                        color: isSelected ? Colors.white : AppColors.secondary,
                      ),
                      AppSpaces.hSpace6,
                      Text(
                        tabLabel,
                        style: AppTextStyles.text12.copyWith(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  /// Dynamic content based on selected tab with proper permission handling
  Widget _buildActiveTabContent() {
    return Obx(() {
      final tab = controller.selectedTab.value;

      if (tab == 'pin') {
        return KioskPinCard(controller: controller);
      }

      // Terminal Tab
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
                  'Setting up enterprise kiosk tablet stations requires kiosks.manage administrator rights. You can configure your personal backup PIN from the Self-Service PIN tab.',
              buttonText: 'Switch to PIN Setup',
              onAction: () => controller.selectedTab.value = 'pin',
            ),
          ),
        );
      }

      return KioskProvisionCard(controller: controller);
    });
  }
}
