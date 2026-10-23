import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../controller/profile_controller.dart';

class ProfileDocumentsTab extends GetView<ProfileController> {
  const ProfileDocumentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final p = controller.profile.value;
      final docs = p?.documents ?? [];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        'Verified',
                        style: AppTextStyles.text10.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpaces.vSpace14,
                if (docs.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 20.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.inputFill,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: AppColors.borderColor,
                        width: 0.8.w,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 48.r,
                          height: 48.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.secondary.withValues(alpha: 0.12),
                          ),
                          child: Icon(
                            Icons.verified_outlined,
                            size: 26.sp,
                            color: AppColors.secondary,
                          ),
                        ),
                        AppSpaces.vSpace10,
                        Text(
                          'No Expiring Documents',
                          style: AppTextStyles.text14.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                        AppSpaces.vSpace4,
                        Text(
                          'All required identity cards, passports, and certifications are up to date and approved by HR.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.text12.copyWith(
                            color: AppColors.subTextColor,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  )
                else
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
