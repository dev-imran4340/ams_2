import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../controller/asset_controller.dart';
import '../../model/asset_model.dart';

class AssetCardTile extends GetView<AssetController> {
  final AssetAssignmentModel assignment;

  const AssetCardTile({
    super.key,
    required this.assignment,
  });

  IconData _getCategoryIcon(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('laptop') || cat.contains('notebook') || cat.contains('macbook')) {
      return Icons.laptop_mac_rounded;
    } else if (cat.contains('phone') || cat.contains('mobile')) {
      return Icons.phone_android_rounded;
    } else if (cat.contains('monitor') || cat.contains('screen') || cat.contains('display')) {
      return Icons.desktop_windows_rounded;
    } else if (cat.contains('sim')) {
      return Icons.sim_card_rounded;
    } else if (cat.contains('tablet') || cat.contains('ipad')) {
      return Icons.tablet_mac_rounded;
    } else if (cat.contains('vehicle') || cat.contains('car')) {
      return Icons.directions_car_rounded;
    } else {
      return Icons.devices_other_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final asset = assignment.asset;
    final catIcon = _getCategoryIcon(asset.category);
    final accentColor = assignment.isReturned
        ? AppColors.subTextColor.withValues(alpha: 0.5)
        : AppColors.secondary;

    return CustomCard(
      accentColor: accentColor,
      accentWidth: 3.w,
      onTap: () => controller.openAssetDetails(context, assignment),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
              // 1. Header: Icon, Asset Name, Code & Status Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42.r,
                    height: 42.r,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.secondary.withValues(alpha: 0.25),
                        width: 1.w,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        catIcon,
                        size: 22.sp,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),

                  AppSpaces.hSpace12,

                  // Asset Name & Category
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          asset.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.text14.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                        AppSpaces.vSpace4,
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                asset.code,
                                style: AppTextStyles.text10.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            AppSpaces.hSpace6,
                            Text(
                              asset.category,
                              style: AppTextStyles.text10.copyWith(
                                color: AppColors.subTextColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  AppSpaces.hSpace8,

                  // Status Pill
                  _buildStatusPill(),
                ],
              ),

              // 2. Serial Number & Assigned Date Row
              AppSpaces.vSpace12,
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    if (asset.serialNumber != null &&
                        asset.serialNumber!.isNotEmpty) ...[
                      Icon(
                        Icons.tag_rounded,
                        size: 13.sp,
                        color: AppColors.subTextColor,
                      ),
                      AppSpaces.hSpace4,
                      Expanded(
                        child: Text(
                          'S/N: ${asset.serialNumber}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.text10.copyWith(
                            color: AppColors.textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    if (assignment.assignedOn != null) ...[
                      Icon(
                        Icons.event_available_rounded,
                        size: 13.sp,
                        color: AppColors.subTextColor,
                      ),
                      AppSpaces.hSpace4,
                      Text(
                        'Assigned: ${assignment.assignedOn}',
                        style: AppTextStyles.text10.copyWith(
                          color: AppColors.subTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // 3. Condition Out Note (if any)
              if (assignment.conditionOut != null &&
                  assignment.conditionOut!.isNotEmpty) ...[
                AppSpaces.vSpace8,
                Row(
                  children: [
                    Text(
                      'Condition Out: ',
                      style: AppTextStyles.text10.copyWith(
                        color: AppColors.subTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      assignment.conditionOut!,
                      style: AppTextStyles.text10.copyWith(
                        color: AppColors.textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (assignment.charged) ...[
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          'Paid / Charged',
                          style: AppTextStyles.text10.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],

              // 4. Action Button for Pending Acknowledgment
              if (assignment.canAcknowledge) ...[
                AppSpaces.vSpace12,
                Divider(
                  color: AppColors.borderColor.withValues(alpha: 0.6),
                  height: 1.h,
                ),
                AppSpaces.vSpace10,
                Obx(
                  () => CustomButton(
                    text: 'Acknowledge Receipt',
                    height: 36.h,
                    fontSize: 12.sp,
                    isGradient: true,
                    isLoading: controller.isAcknowledging.value &&
                        controller.selectedAsset.value?.id == assignment.id,
                    onPressed: () => controller.acknowledgeAsset(assignment),
                  ),
                ),
              ],
            ],
          ),
    );
  }

  Widget _buildStatusPill() {
    Color color;
    String label;

    if (assignment.isReturned) {
      color = AppColors.subTextColor;
      label = 'Returned';
    } else if (assignment.canAcknowledge) {
      color = AppColors.warning;
      label = 'Pending Sign';
    } else {
      color = AppColors.success;
      label = 'In Custody';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 0.8.w,
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.text10.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
