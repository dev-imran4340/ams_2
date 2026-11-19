import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../model/document_model.dart';

class IssuedLetterCard extends StatelessWidget {
  final IssuedLetterItemModel letter;
  final bool isDownloading;
  final VoidCallback onDownloadPdf;
  final VoidCallback? onTap;

  const IssuedLetterCard({
    super.key,
    required this.letter,
    required this.isDownloading,
    required this.onDownloadPdf,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      margin: EdgeInsets.only(bottom: 12.h),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Letter Icon
              Container(
                width: 38.r,
                height: 38.r,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Center(
                  child: Icon(
                    Icons.mark_email_read_outlined,
                    size: 20.w,
                    color: AppColors.primary,
                  ),
                ),
              ),
              AppSpaces.hSpace10,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      letter.subject,
                      style: AppTextStyles.text14.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textColor,
                      ),
                    ),
                    AppSpaces.vSpace4,
                    Row(
                      children: [
                        Text(
                          'Ref: ${letter.reference}',
                          style: AppTextStyles.text10.copyWith(
                            color: AppColors.subTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        AppSpaces.hSpace6,
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 1.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            letter.kindLabel,
                            style: AppTextStyles.text10.copyWith(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              AppSpaces.hSpace8,
              // Download PDF Button
              InkWell(
                onTap: isDownloading ? null : onDownloadPdf,
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
                              Icons.picture_as_pdf_rounded,
                              size: 14.w,
                              color: AppColors.secondary,
                            ),
                            AppSpaces.hSpace4,
                            Text(
                              'PDF',
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

          if (letter.issuedOn != null) ...[
            AppSpaces.vSpace10,
            Row(
              children: [
                Icon(
                  Icons.verified_outlined,
                  size: 12.w,
                  color: AppColors.secondary,
                ),
                AppSpaces.hSpace6,
                Expanded(
                  child: Text(
                    'Issued: ${letter.issuedOn}${letter.issuedBy != null ? ' by ${letter.issuedBy}' : ''}',
                    style: AppTextStyles.text10.copyWith(
                      color: AppColors.subTextColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 11.w,
                  color: AppColors.subTextColor.withValues(alpha: 0.6),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class LetterRequestCard extends StatelessWidget {
  final LetterRequestItemModel request;

  const LetterRequestCard({
    super.key,
    required this.request,
  });

  Color _resolveStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'issued':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      case 'cancelled':
        return AppColors.subTextColor;
      case 'pending':
      default:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _resolveStatusColor(request.status);

    return CustomCard(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  request.letter,
                  style: AppTextStyles.text14.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textColor,
                  ),
                ),
              ),
              AppSpaces.hSpace8,
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.4),
                    width: 1.w,
                  ),
                ),
                child: Text(
                  request.statusLabel,
                  style: AppTextStyles.text10.copyWith(
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),

          AppSpaces.vSpace6,
          Text(
            'Purpose: ${request.purpose}',
            style: AppTextStyles.text12.copyWith(
              color: AppColors.subTextColor,
            ),
          ),

          if (request.requestedOn != null) ...[
            AppSpaces.vSpace8,
            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 12.w,
                  color: AppColors.subTextColor,
                ),
                AppSpaces.hSpace6,
                Text(
                  'Requested: ${request.requestedOn}',
                  style: AppTextStyles.text10.copyWith(
                    color: AppColors.subTextColor,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
