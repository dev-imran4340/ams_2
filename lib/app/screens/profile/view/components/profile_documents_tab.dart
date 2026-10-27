import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/custom_state_view.dart';
import '../../controller/profile_controller.dart';

class ProfileDocumentsTab extends GetView<ProfileController> {
  const ProfileDocumentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final p = controller.profile.value;
      final docs = p?.documents ?? [];

      if (docs.isEmpty) {
        return CustomStateView.empty(
          title: 'No Documents',
          message: 'No documents have been uploaded for this profile.',
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32.r,
                      height: 32.r,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.folder_shared_outlined,
                        size: 16.sp,
                        color: AppColors.secondary,
                      ),
                    ),
                    AppSpaces.hSpace8,
                    Text(
                      'Compliance & Documents',
                      style: AppTextStyles.text14.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                  ],
                ),
                AppSpaces.vSpace14,
                ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: docs.length,
                    separatorBuilder: (context, index) => AppSpaces.vSpace10,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final kind = (doc.kind ?? 'Document').capitalizeFirst;
                      final expiresOn = doc.expiresOn ?? 'No expiry';
                      final daysLeft = doc.daysLeft;

                      return Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: AppColors.inputFill,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.description_outlined,
                              size: 20.sp,
                              color: AppColors.primary,
                            ),
                            AppSpaces.hSpace10,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    kind ?? 'Document',
                                    style: AppTextStyles.text12.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textColor,
                                    ),
                                  ),
                                  Text(
                                    'Expires: $expiresOn',
                                    style: AppTextStyles.text10.copyWith(
                                      color: AppColors.subTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (daysLeft != null)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: daysLeft < 30
                                      ? AppColors.error.withValues(alpha: 0.12)
                                      : AppColors.secondary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  '$daysLeft days left',
                                  style: AppTextStyles.text10.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: daysLeft < 30
                                        ? AppColors.error
                                        : AppColors.secondary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
