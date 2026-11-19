import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../controller/document_controller.dart';
import '../../model/document_model.dart';

/// Modal bottom sheet presenting full audit & text details of an issued official letter.
/// Connected to GET /letters/{id} (Phase 17 Group 2).
/// Adheres strictly to .agents/rules/ams.md & corporate design system.
class LetterDetailsBottomSheet extends GetView<DocumentController> {
  final IssuedLetterItemModel? letter;

  const LetterDetailsBottomSheet({
    super.key,
    this.letter,
  });

  /// Factory helper to open modal bottom sheet cleanly
  static void show(
    BuildContext context, {
    IssuedLetterItemModel? letter,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LetterDetailsBottomSheet(letter: letter),
    );
  }

  /// Clean basic HTML tags to render formatted plain typography
  String _stripHtmlTags(String htmlString) {
    return htmlString
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentLetter = controller.selectedLetter.value ?? letter;
      final bool isDetailsLoading = controller.isLetterDetailsLoading.value;
      final bool isDownloading = currentLetter != null &&
          controller.downloadingFileIds.contains(currentLetter.id);

      return PopScope(
        canPop: !isDownloading,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.90,
          ),
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Top Drag Handle
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

              // 2. Navigation Header (Title, Ref Pill & Close Button)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 3.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6.r),
                                  border: Border.all(
                                    color: AppColors.secondary.withValues(alpha: 0.35),
                                    width: 0.8.w,
                                  ),
                                ),
                                child: Text(
                                  currentLetter?.kindLabel ?? 'Official Letter',
                                  style: AppTextStyles.text10.copyWith(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              AppSpaces.hSpace8,
                              if (currentLetter != null)
                                Flexible(
                                  child: Text(
                                    currentLetter.reference,
                                    style: AppTextStyles.text10.copyWith(
                                      color: AppColors.subTextColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                          ),
                          AppSpaces.vSpace4,
                          Text(
                            currentLetter?.subject ?? 'Letter Details',
                            style: AppTextStyles.text16.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    AppSpaces.hSpace8,
                    InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Get.back();
                      },
                      borderRadius: BorderRadius.circular(12.r),
                      child: Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.borderColor,
                            width: 0.8.w,
                          ),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18.w,
                          color: AppColors.subTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Divider(
                color: AppColors.borderColor.withValues(alpha: 0.6),
                height: 1.h,
              ),

              // 3. Scrollable Letter Audit & Content
              Expanded(
                child: currentLetter == null && isDetailsLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: AppColors.secondary,
                          strokeWidth: 2.5.w,
                        ),
                      )
                    : currentLetter == null
                        ? Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24.w),
                              child: Text(
                                'Letter information is currently unavailable.',
                                style: AppTextStyles.text12.copyWith(
                                  color: AppColors.subTextColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 12.h,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Void Status Warning Banner (if letter is revoked)
                                if (currentLetter.isVoid) ...[
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 10.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.error.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color: AppColors.error.withValues(alpha: 0.35),
                                        width: 1.w,
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.cancel_outlined,
                                          size: 16.w,
                                          color: AppColors.error,
                                        ),
                                        AppSpaces.hSpace8,
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Letter Void / Revoked',
                                                style: AppTextStyles.text12.copyWith(
                                                  color: AppColors.error,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              if (currentLetter.voidReason != null &&
                                                  currentLetter
                                                      .voidReason!.isNotEmpty) ...[
                                                AppSpaces.vSpace2,
                                                Text(
                                                  currentLetter.voidReason!,
                                                  style: AppTextStyles.text10.copyWith(
                                                    color: AppColors.textColor,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  AppSpaces.vSpace12,
                                ],

                                // Metadata Card (Signature 3.w Teal Accent Floating Card)
                                CustomCard(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 14.h,
                                  ),
                                  child: Column(
                                    children: [
                                      _buildInfoRow(
                                        icon: Icons.tag_rounded,
                                        label: 'Reference Code',
                                        value: currentLetter.reference,
                                      ),
                                      if (currentLetter.issuedOn != null) ...[
                                        AppSpaces.vSpace10,
                                        _buildInfoRow(
                                          icon: Icons.calendar_today_outlined,
                                          label: 'Issued Date',
                                          value: currentLetter.issuedOn!,
                                        ),
                                      ],
                                      if (currentLetter.issuedBy != null) ...[
                                        AppSpaces.vSpace10,
                                        _buildInfoRow(
                                          icon: Icons.person_outline_rounded,
                                          label: 'Issued By',
                                          value: currentLetter.issuedBy!,
                                        ),
                                      ],
                                      if (currentLetter.employee != null) ...[
                                        AppSpaces.vSpace10,
                                        _buildInfoRow(
                                          icon: Icons.badge_outlined,
                                          label: 'Recipient',
                                          value:
                                              '${currentLetter.employee!.name}${currentLetter.employee!.number != null ? ' (${currentLetter.employee!.number})' : ''}',
                                        ),
                                      ],
                                    ],
                                  ),
                                ),

                                AppSpaces.vSpace14,

                                // Official Body Section Header
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Letter Content',
                                      style: AppTextStyles.text14.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textColor,
                                      ),
                                    ),
                                    if (isDetailsLoading)
                                      SizedBox(
                                        width: 14.w,
                                        height: 14.w,
                                        child: CircularProgressIndicator(
                                          color: AppColors.secondary,
                                          strokeWidth: 2.w,
                                        ),
                                      ),
                                  ],
                                ),

                                AppSpaces.vSpace8,

                                // Letter Body Card
                                CustomCard(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 14.w,
                                    vertical: 16.h,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (currentLetter.body != null &&
                                          currentLetter.body!.trim().isNotEmpty) ...[
                                        SelectableText(
                                          _stripHtmlTags(currentLetter.body!),
                                          style: AppTextStyles.text12.copyWith(
                                            color: AppColors.textColor,
                                            height: 1.6,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                      ] else if (isDetailsLoading) ...[
                                        Center(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 24.h,
                                            ),
                                            child: Column(
                                              children: [
                                                CircularProgressIndicator(
                                                  color: AppColors.secondary,
                                                  strokeWidth: 2.5.w,
                                                ),
                                                AppSpaces.vSpace10,
                                                Text(
                                                  'Retrieving letter text...',
                                                  style: AppTextStyles.text10.copyWith(
                                                    color: AppColors.subTextColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ] else ...[
                                        Center(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 16.h,
                                              horizontal: 8.w,
                                            ),
                                            child: Column(
                                              children: [
                                                Icon(
                                                  Icons.picture_as_pdf_outlined,
                                                  size: 32.w,
                                                  color: AppColors.secondary,
                                                ),
                                                AppSpaces.vSpace8,
                                                Text(
                                                  'Official Signed Document',
                                                  style: AppTextStyles.text12.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColors.textColor,
                                                  ),
                                                ),
                                                AppSpaces.vSpace4,
                                                Text(
                                                  'This letter was generated on official company letterhead. You can download and inspect the original PDF below.',
                                                  style: AppTextStyles.text10.copyWith(
                                                    color: AppColors.subTextColor,
                                                    height: 1.4,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),

                                SizedBox(height: 20.h),
                              ],
                            ),
                          ),
              ),

              // 4. Fixed Bottom CTA Bar (Corporate Navy to Teal Gradient Button)
              if (currentLetter != null) ...[
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
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
                    child: CustomButton(
                      text: isDownloading
                          ? 'Downloading Official PDF...'
                          : 'Download Official PDF',
                      isGradient: true,
                      isLoading: isDownloading,
                      icon: Icon(
                        Icons.picture_as_pdf_rounded,
                        size: 16.w,
                        color: AppColors.white,
                      ),
                      onPressed: isDownloading
                          ? null
                          : () => controller.downloadAndOpenLetter(
                                currentLetter.id,
                                currentLetter.reference,
                              ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14.w,
          color: AppColors.secondary,
        ),
        AppSpaces.hSpace8,
        Text(
          label,
          style: AppTextStyles.text10.copyWith(
            color: AppColors.subTextColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
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
}
