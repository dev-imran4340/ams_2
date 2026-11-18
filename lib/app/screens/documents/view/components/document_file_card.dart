import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../model/document_model.dart';

class DocumentFileCard extends StatelessWidget {
  final DocumentFileItemModel file;
  final bool isDownloading;
  final VoidCallback onDownload;

  const DocumentFileCard({
    super.key,
    required this.file,
    required this.isDownloading,
    required this.onDownload,
  });

  Color _resolveToneColor(String? tone) {
    switch (tone?.toLowerCase()) {
      case 'rose':
        return AppColors.error;
      case 'amber':
        return AppColors.warning;
      case 'emerald':
        return AppColors.success;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasExpiry = file.expiresOn != null && file.expiresOn!.isNotEmpty;
    final toneColor = _resolveToneColor(file.expiryTone);

    return CustomCard(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Document Icon Bubble
              Container(
                width: 38.r,
                height: 38.r,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Center(
                  child: Icon(
                    Icons.description_outlined,
                    size: 20.w,
                    color: AppColors.secondary,
                  ),
                ),
              ),
              AppSpaces.hSpace10,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.title,
                      style: AppTextStyles.text14.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textColor,
                      ),
                    ),
                    if (file.category != null) ...[
                      AppSpaces.vSpace4,
                      Text(
                        file.category!.name,
                        style: AppTextStyles.text10.copyWith(
                          color: AppColors.subTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              AppSpaces.hSpace8,
              // Download Button
              InkWell(
                onTap: isDownloading ? null : onDownload,
                borderRadius: BorderRadius.circular(20.r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: AppColors.secondary.withValues(alpha: 0.4),
                      width: 1.w,
                    ),
                  ),
                  child: isDownloading
                      ? SizedBox(
                          width: 14.w,
                          height: 14.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.w,
                            color: AppColors.secondary,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.download_rounded,
                              size: 14.w,
                              color: AppColors.secondary,
                            ),
                            AppSpaces.hSpace4,
                            Text(
                              file.size,
                              style: AppTextStyles.text10.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),

          if (hasExpiry) ...[
            AppSpaces.vSpace10,
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: toneColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: toneColor.withValues(alpha: 0.3),
                  width: 1.w,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 12.w,
                    color: toneColor,
                  ),
                  AppSpaces.hSpace6,
                  Text(
                    'Expires: ${file.expiresOn}',
                    style: AppTextStyles.text10.copyWith(
                      color: toneColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
