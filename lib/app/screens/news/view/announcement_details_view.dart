import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_spaces.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/custom_screen_header.dart';
import '../../../core/widgets/custom_state_view.dart';
import '../../../core/widgets/employee_ambient_header.dart';
import '../../../core/widgets/network_boundary_wrapper.dart';
import '../controller/news_controller.dart';

class AnnouncementDetailsView extends GetView<NewsController> {
  final String? announcementId;

  const AnnouncementDetailsView({
    super.key,
    this.announcementId,
  });

  @override
  Widget build(BuildContext context) {
    final String targetId = announcementId ??
        (Get.arguments is Map
            ? Get.arguments['announcementId'] as String?
            : null) ??
        (Get.arguments is String ? Get.arguments as String : '');

    return NetworkBoundaryWrapper(
      onRetry: () => controller.loadAnnouncementDetails(targetId),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Stack(
          children: [
            // 1. Signature Ambient Curved Gradient Header
            EmployeeAmbientHeader(height: 220.h),

            // 2. Safe Area Content
            SafeArea(
              child: Column(
                children: [
                  // Top Navigation Header
                  Padding(
                    padding: AppSpaces.horizontalPadding,
                    child: CustomScreenHeader(
                      title: 'Announcement',
                      subtitle: 'Official company notice',
                      showBackButton: true,
                      onBack: () => Get.back(),
                    ),
                  ),

                  AppSpaces.vSpace10,

                  // Body Content
                  Expanded(
                    child: Obx(() {
                      if (controller.isDetailsLoading.value) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppColors.secondary,
                            strokeWidth: 2.5.w,
                          ),
                        );
                      }

                      final item = controller.selectedAnnouncement.value;
                      if (item == null) {
                        return Center(
                          child: CustomStateView.empty(
                            icon: Icons.campaign_outlined,
                            title: 'Notice Unavailable',
                            message:
                                'Announcement details could not be loaded at this time.',
                            buttonText: 'Retry',
                            onAction: () =>
                                controller.loadAnnouncementDetails(targetId),
                          ),
                        );
                      }

                      return RefreshIndicator(
                        color: AppColors.secondary,
                        onRefresh: () =>
                            controller.loadAnnouncementDetails(targetId),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: EdgeInsets.fromLTRB(14.w, 4.h, 14.w, 24.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Announcement Content Card
                              CustomCard(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 16.h,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Pinned & Date Header
                                    Row(
                                      children: [
                                        if (item.isPinned) ...[
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8.w,
                                              vertical: 3.h,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12.r),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.push_pin_rounded,
                                                  size: 12.w,
                                                  color: AppColors.primary,
                                                ),
                                                AppSpaces.hSpace4,
                                                Text(
                                                  'Pinned Notice',
                                                  style: AppTextStyles.text10
                                                      .copyWith(
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          AppSpaces.hSpace8,
                                        ],
                                        const Spacer(),
                                        if (item.publishedOn != null) ...[
                                          Icon(
                                            Icons.schedule_rounded,
                                            size: 13.w,
                                            color: AppColors.subTextColor,
                                          ),
                                          AppSpaces.hSpace4,
                                          Text(
                                            item.publishedOn!,
                                            style:
                                                AppTextStyles.text10.copyWith(
                                              color: AppColors.subTextColor,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),

                                    AppSpaces.vSpace12,

                                    // Title
                                    Text(
                                      item.title,
                                      style: AppTextStyles.text18.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textColor,
                                      ),
                                    ),

                                    AppSpaces.vSpace12,

                                    // Divider Line
                                    Container(
                                      height: 0.8.h,
                                      color: AppColors.borderColor,
                                    ),

                                    AppSpaces.vSpace14,

                                    // Body Text / HTML Content
                                    Text(
                                      (item.body != null &&
                                              item.body!.isNotEmpty)
                                          ? _stripHtmlTags(item.body!)
                                          : (item.excerpt ?? 'No content'),
                                      style: AppTextStyles.text12.copyWith(
                                        color: AppColors.textColor,
                                        height: 1.6,
                                      ),
                                    ),

                                    // Expiry Note (if any)
                                    if (item.endsOn != null) ...[
                                      AppSpaces.vSpace20,
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10.w,
                                          vertical: 6.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.backgroundColor,
                                          borderRadius:
                                              BorderRadius.circular(8.r),
                                          border: Border.all(
                                            color: AppColors.borderColor,
                                            width: 0.8.w,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.event_busy_rounded,
                                              size: 13.w,
                                              color: AppColors.subTextColor,
                                            ),
                                            AppSpaces.hSpace6,
                                            Text(
                                              'Expires on: ${item.endsOn}',
                                              style:
                                                  AppTextStyles.text10.copyWith(
                                                color: AppColors.subTextColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Clean basic HTML tags if API sends pre-cleaned HTML strings
  String _stripHtmlTags(String htmlString) {
    return htmlString
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .trim();
  }
}
