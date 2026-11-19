import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../controller/asset_controller.dart';
import '../../model/asset_model.dart';

class AssetDetailsBottomSheet extends GetView<AssetController> {
  final AssetAssignmentModel assignment;

  const AssetDetailsBottomSheet({
    super.key,
    required this.assignment,
  });

  static void show(BuildContext context,
      {required AssetAssignmentModel assignment}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AssetDetailsBottomSheet(assignment: assignment),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final current = controller.selectedAsset.value ?? assignment;
      final asset = current.asset;
      final isAcknowledging = controller.isAcknowledging.value;

      return Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          children: [
            // 1. Drag Handle
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 10.h, bottom: 8.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.borderColor,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),

            // 2. Header: Title 'Asset Details' & Close Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                children: [
                  Container(
                    width: 32.r,
                    height: 32.r,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.devices_other_rounded,
                        size: 18.sp,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                  AppSpaces.hSpace10,
                  Text(
                    'Asset Details',
                    style: AppTextStyles.text16.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Get.back();
                    },
                    icon: Icon(
                      Icons.close_rounded,
                      color: AppColors.subTextColor,
                      size: 20.sp,
                    ),
                  ),
                ],
              ),
            ),

            Divider(
              color: AppColors.borderColor.withValues(alpha: 0.6),
              height: 1.h,
            ),

            // 3. Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: 14.w,
                  vertical: 14.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Asset Name
                    Text(
                      asset.name,
                      style: AppTextStyles.text18.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),

                    AppSpaces.vSpace8,

                    // Badges Row: Asset Code, Category, Status
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
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
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            asset.category,
                            style: AppTextStyles.text10.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                        AppSpaces.hSpace6,
                        _buildStatusBadge(current),
                      ],
                    ),

                    AppSpaces.vSpace14,

                    // Overview Card with Metadata (Signature 3.w Teal Accent)
                    CustomCard(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 14.h,
                      ),
                      child: Column(
                        children: [
                          if (asset.serialNumber != null &&
                              asset.serialNumber!.isNotEmpty) ...[
                            _buildMetaRow(
                              icon: Icons.tag_rounded,
                              label: 'Serial Number',
                              value: asset.serialNumber!,
                            ),
                            AppSpaces.vSpace10,
                          ],
                          if (current.assignedOn != null) ...[
                            _buildMetaRow(
                              icon: Icons.event_available_rounded,
                              label: 'Assigned Date',
                              value: current.assignedOn!,
                            ),
                            AppSpaces.vSpace10,
                          ],
                          if (current.expectedReturnOn != null) ...[
                            _buildMetaRow(
                              icon: Icons.event_rounded,
                              label: 'Expected Return',
                              value: current.expectedReturnOn!,
                            ),
                            AppSpaces.vSpace10,
                          ],
                          if (current.conditionOut != null &&
                              current.conditionOut!.isNotEmpty) ...[
                            _buildMetaRow(
                              icon: Icons.verified_outlined,
                              label: 'Condition at Issue',
                              value: current.conditionOut!,
                            ),
                            AppSpaces.vSpace10,
                          ],
                          _buildMetaRow(
                            icon: Icons.draw_outlined,
                            label: 'Digital Acknowledgment',
                            value: current.isAcknowledged
                                ? 'Confirmed (${_formatDate(current.acknowledgedAt!)})'
                                : 'Pending Receipt Signature',
                          ),
                          if (current.isReturned) ...[
                            AppSpaces.vSpace10,
                            _buildMetaRow(
                              icon: Icons.assignment_return_outlined,
                              label: 'Returned On',
                              value: current.returnedOn ?? 'Completed',
                            ),
                            if (current.conditionIn != null) ...[
                              AppSpaces.vSpace10,
                              _buildMetaRow(
                                icon: Icons.rule_folder_outlined,
                                label: 'Condition on Return',
                                value: current.conditionIn!,
                              ),
                            ],
                          ],
                          if (current.charged) ...[
                            AppSpaces.vSpace10,
                            _buildMetaRow(
                              icon: Icons.payments_outlined,
                              label: 'Financial Status',
                              value: 'Company Charged / Deducted',
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Additional Notes Section (if any)
                    if (current.note != null && current.note!.isNotEmpty) ...[
                      AppSpaces.vSpace14,
                      Text(
                        'Assignment Note',
                        style: AppTextStyles.text14.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textColor,
                        ),
                      ),
                      AppSpaces.vSpace8,
                      CustomCard(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 14.h,
                        ),
                        child: Text(
                          current.note!,
                          style: AppTextStyles.text12.copyWith(
                            color: AppColors.textColor,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],

                    AppSpaces.vSpace16,
                  ],
                ),
              ),
            ),

            // 4. Action Buttons Footer
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                border: Border(
                  top: BorderSide(
                    color: AppColors.borderColor,
                    width: 0.8.w,
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Close',
                        isOutlined: true,
                        borderColor: AppColors.borderColor,
                        textColor: AppColors.subTextColor,
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Get.back();
                        },
                      ),
                    ),
                    if (current.canAcknowledge) ...[
                      AppSpaces.hSpace12,
                      Expanded(
                        child: CustomButton(
                          text: 'Acknowledge Receipt',
                          isGradient: true,
                          isLoading: isAcknowledging,
                          onPressed: () async {
                            await controller.acknowledgeAsset(current);
                            Get.back();
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatusBadge(AssetAssignmentModel item) {
    Color color;
    String label;

    if (item.isReturned) {
      color = AppColors.subTextColor;
      label = 'Returned';
    } else if (item.canAcknowledge) {
      color = AppColors.warning;
      label = 'Needs Acknowledgment';
    } else {
      color = AppColors.success;
      label = 'Active (In Custody)';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6.r),
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

  Widget _buildMetaRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14.w, color: AppColors.secondary),
        AppSpaces.hSpace8,
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.text10.copyWith(
              color: AppColors.subTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: AppTextStyles.text12.copyWith(
              color: AppColors.textColor,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatDate(String isoString) {
    try {
      final dt = DateTime.parse(isoString).toLocal();
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return isoString;
    }
  }
}
