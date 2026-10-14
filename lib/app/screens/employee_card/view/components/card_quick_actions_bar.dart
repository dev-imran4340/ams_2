import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../controller/employee_card_controller.dart';

class CardQuickActionsBar extends GetView<EmployeeCardController> {
  const CardQuickActionsBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 1. Flip Card
        Expanded(
          child: _buildActionTile(
            icon: Icons.sync_rounded,
            title: 'Flip\nBadge',
            accentColor: AppColors.primary,
            onTap: controller.flipCard,
          ),
        ),
        AppSpaces.hSpace10,

        // 2. View PDF
        Expanded(
          child: _buildActionTile(
            icon: Icons.picture_as_pdf_rounded,
            title: 'View\nPDF',
            accentColor: AppColors.secondary,
            onTap: () => controller.openPdfViewer(context),
          ),
        ),
        AppSpaces.hSpace10,

        // 3. Share Card
        Expanded(
          child: _buildActionTile(
            icon: Icons.share_rounded,
            title: 'Share\nToken',
            accentColor: AppColors.info,
            onTap: controller.shareCard,
          ),
        ),
        AppSpaces.hSpace10,

        // 4. NFC Ready
        Expanded(
          child: _buildActionTile(
            icon: Icons.nfc_rounded,
            title: 'NFC\nPunch',
            accentColor: AppColors.success,
            onTap: controller.simulateNfcTap,
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: AppColors.borderColor,
              width: 1.w,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.04),
                blurRadius: 10.r,
                offset: Offset(0, 3.h),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 18.sp,
                    color: accentColor,
                  ),
                ),
              ),
              AppSpaces.vSpace8,
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.text10.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
