import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_spaces.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/widgets/custom_screen_header.dart';
import '../../../core/widgets/custom_state_view.dart';
import '../../../core/widgets/employee_ambient_header.dart';
import '../../../core/widgets/network_boundary_wrapper.dart';
import '../controller/asset_controller.dart';
import 'components/asset_card_tile.dart';
import 'components/asset_telemetry_strip.dart';

class AssetsView extends GetView<AssetController> {
  const AssetsView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkBoundaryWrapper(
      onRetry: controller.loadAssets,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Stack(
          children: [
            // 1. Signature Curved Ambient Gradient Header (240.h)
            EmployeeAmbientHeader(height: 240.h),

            // 2. Sticky Header + Scrollable Body
            SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 0),
                    child: const CustomScreenHeader(
                      title: 'Company Assets',
                      subtitle: 'Hardware, equipment & digital inventory',
                    ),
                  ),
                  AppSpaces.vSpace14,
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => controller.loadAssets(isRefresh: true),
                      color: AppColors.secondary,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 4.h,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Component 1: Asset Telemetry Strip
                            const AssetTelemetryStrip(),

                      AppSpaces.vSpace14,

                      // Component 2: Filter Tabs Row
                      _buildFilterTabs(),

                      AppSpaces.vSpace16,

                      // Section Header: Active Count
                      _buildSectionHeader(),

                      AppSpaces.vSpace10,

                      // Component 3: Assets List / States
                      _buildAssetsList(context),

                      // Bottom clearance for navigation
                      SizedBox(height: 80.h),
                    ],
                  ),
                ),
              ),
            ),
                  ],
                ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return SizedBox(
      height: 38.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: controller.filterTabs.length,
        separatorBuilder: (_, _) => AppSpaces.hSpace8,
        itemBuilder: (context, index) {
          final tab = controller.filterTabs[index];

          return Obx(() {
            final isSelected = controller.selectedFilter.value == tab;

            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => controller.setFilter(tab),
                borderRadius: BorderRadius.circular(20.r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.borderColor,
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
                  child: Center(
                    child: Text(
                      tab,
                      style: AppTextStyles.text12.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected
                            ? AppColors.white
                            : AppColors.subTextColor,
                      ),
                    ),
                  ),
                ),
              ),
            );
          });
        },
      ),
    );  
  }

  Widget _buildSectionHeader() {
    return Obx(() {
      final count = controller.filteredAssets.length;
      final filter = controller.selectedFilter.value;

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            filter == 'All' ? 'Assigned Assets' : '$filter Assets',
            style: AppTextStyles.text14.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              '$count ${count == 1 ? 'item' : 'items'}',
              style: AppTextStyles.text10.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildAssetsList(BuildContext context) {
    return Obx(() {
      if (controller.isAccessRestricted.value) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: Center(
            child: CustomStateView.error(
              title: 'Access Restricted',
              message: controller.accessRestrictedMessage.value.isNotEmpty
                  ? controller.accessRestrictedMessage.value
                  : 'You do not have permission to view company assets.',
            ),
          ),
        );
      }

      if (controller.isLoading.value) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.secondary,
              strokeWidth: 2.5.w,
            ),
          ),
        );
      }

      final items = controller.filteredAssets;

      if (items.isEmpty) {
        return Center(
          child: CustomStateView.empty(
            icon: Icons.devices_other_rounded,
            title: 'No Assets Found',
            message:
                'There are no hardware assets or company equipment matching "${controller.selectedFilter.value}".',
            padding: EdgeInsets.symmetric(vertical: 36.h),
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, _) => AppSpaces.vSpace12,
        itemBuilder: (context, index) {
          final item = items[index];
          return AssetCardTile(
            key: ValueKey(item.id),
            assignment: item,
          );
        },
      );
    });
  }
}
