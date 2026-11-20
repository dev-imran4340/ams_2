import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_spaces.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../model/job_description_model.dart';

class JobDescriptionContentCard extends StatelessWidget {
  final JobDescriptionModel data;
  final VoidCallback? onDownloadPdf;

  const JobDescriptionContentCard({
    super.key,
    required this.data,
    this.onDownloadPdf,
  });

  /// Strips HTML tags and preserves line breaks
  String _formatHtmlBody(String raw) {
    return raw
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n')
        .replaceAll(RegExp(r'</li>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<li[^>]*>', caseSensitive: false), '• ')
        .replaceAll(RegExp(r'<h[1-6][^>]*>', caseSensitive: false), '\n\n')
        .replaceAll(RegExp(r'</h[1-6]>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'&nbsp;', caseSensitive: false), ' ')
        .replaceAll(RegExp(r'&amp;', caseSensitive: false), '&')
        .replaceAll(RegExp(r'&lt;', caseSensitive: false), '<')
        .replaceAll(RegExp(r'&gt;', caseSensitive: false), '>')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    final designation = data.designation ?? 'Official Designation';
    final version = data.version != null ? 'v${data.version}' : null;
    final updatedAt = data.updatedAt != null ? 'Updated: ${data.updatedAt}' : null;
    final bodyText = data.body != null ? _formatHtmlBody(data.body!) : '';
    final hasFile = data.fileUrl != null && data.fileUrl!.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Signature Header Floating Card
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(15.r),
            border: Border(
              bottom: BorderSide(color: AppColors.secondary, width: 3.w),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44.r,
                    height: 44.r,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.work_outline_rounded,
                        color: Colors.white,
                        size: 22.sp,
                      ),
                    ),
                  ),
                  AppSpaces.hSpace12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          designation,
                          style: AppTextStyles.text16.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                        AppSpaces.vSpace4,
                        Row(
                          children: [
                            if (version != null) ...[
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Text(
                                  version,
                                  style: AppTextStyles.text10.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ),
                              AppSpaces.hSpace8,
                            ],
                            if (updatedAt != null)
                              Expanded(
                                child: Text(
                                  updatedAt,
                                  style: AppTextStyles.text10.copyWith(
                                    color: AppColors.subTextColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        AppSpaces.vSpace14,

        // 2. Role Overview & Responsibilities Card
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(15.r),
            border: Border(
              bottom: BorderSide(color: AppColors.secondary, width: 3.w),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.description_outlined,
                    color: AppColors.secondary,
                    size: 18.sp,
                  ),
                  AppSpaces.hSpace8,
                  Text(
                    'Responsibilities & Scope',
                    style: AppTextStyles.text14.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                ],
              ),
              AppSpaces.vSpace12,
              Divider(
                color: AppColors.borderColor.withValues(alpha: 0.6),
                height: 1.h,
              ),
              AppSpaces.vSpace12,
              if (bodyText.isNotEmpty)
                SelectableText(
                  bodyText,
                  style: AppTextStyles.text12.copyWith(
                    color: AppColors.textColor,
                    height: 1.6,
                  ),
                )
              else
                Text(
                  'No formatted description text attached to this designation.',
                  style: AppTextStyles.text12.copyWith(
                    color: AppColors.subTextColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ),

        // 3. Official Document PDF Attachment Card (If file_url exists)
        if (hasFile) ...[
          AppSpaces.vSpace14,
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(15.r),
              border: Border(
                bottom: BorderSide(color: AppColors.secondary, width: 3.w),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10.r,
                  offset: Offset(0, 4.h),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.attach_file_rounded,
                      color: AppColors.secondary,
                      size: 18.sp,
                    ),
                    AppSpaces.hSpace8,
                    Text(
                      'Official Document File',
                      style: AppTextStyles.text14.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                  ],
                ),
                AppSpaces.vSpace12,
                Text(
                  'View or download the official signed job description PDF document from company records.',
                  style: AppTextStyles.text12.copyWith(
                    color: AppColors.subTextColor,
                  ),
                ),
                AppSpaces.vSpace14,
                CustomButton(
                  text: 'Download Official PDF',
                  isGradient: true,
                  icon: Icon(
                    Icons.picture_as_pdf_rounded,
                    color: Colors.white,
                    size: 18.sp,
                  ),
                  onPressed: onDownloadPdf,
                ),
              ],
            ),
          ),
        ],

        AppSpaces.vSpace24,
      ],
    );
  }
}
