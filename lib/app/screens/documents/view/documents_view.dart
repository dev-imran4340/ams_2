import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_spaces.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/widgets/custom_screen_header.dart';
import '../../../core/widgets/custom_state_view.dart';
import '../../../core/widgets/employee_ambient_header.dart';
import '../../../core/widgets/network_boundary_wrapper.dart';
import '../controller/document_controller.dart';
import 'components/document_file_card.dart';
import 'components/letter_card.dart';
import 'components/policy_card.dart';
import 'components/request_letter_bottom_sheet.dart';

class DocumentsView extends GetView<DocumentController> {
  const DocumentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkBoundaryWrapper(
      onRetry: () => controller.loadAllDocuments(isRefresh: true),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Stack(
          children: [
            // 1. Curved Ambient Gradient Header
            EmployeeAmbientHeader(height: 240.h),

            // 2. Main Scrollable Content Overlapping Header
            SafeArea(
              bottom: false,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return RefreshIndicator(
                    onRefresh: () => controller.loadAllDocuments(isRefresh: true),
                    color: AppColors.secondary,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 8.h,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight - 16.h,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top Bar: Back Pill, Title and Action Button
                              Obx(() {
                                final isLettersTab =
                                    controller.selectedTabIndex.value == 2;
                                final canRequest = controller.meDocuments.value
                                        ?.requestableLetters.isNotEmpty ==
                                    true;
                                final String headerSubtitle = controller
                                            .selectedTabIndex.value ==
                                        0
                                    ? 'Company policies & official guidelines'
                                    : controller.selectedTabIndex.value == 1
                                        ? 'Personal employee files & records'
                                        : 'Official issued letters & requests';

                                return CustomScreenHeader(
                                  title: 'Documents',
                                  subtitle: headerSubtitle,
                                  actions: (isLettersTab && canRequest)
                                      ? [
                                          CustomScreenHeader.actionButton(
                                            icon: Icons.add_rounded,
                                            iconColor: AppColors.secondary,
                                            onTap: () {
                                              Get.bottomSheet(
                                                const RequestLetterBottomSheet(),
                                                isScrollControlled: true,
                                              );
                                            },
                                          ),
                                        ]
                                      : null,
                                );
                              }),

                              AppSpaces.vSpace14,

                              // 3-Tab Capsule Switcher
                              _buildTabSwitcher(),

                              AppSpaces.vSpace14,

                              // Tab Content (Expands to vertically center empty & loading states)
                              Expanded(
                                child: Obx(() {
                                  if (controller.isAccessRestricted.value) {
                                    return Center(
                                      child: CustomStateView.error(
                                        title: 'Access Restricted',
                                        message: controller.accessRestrictedMessage.value.isNotEmpty
                                            ? controller.accessRestrictedMessage.value
                                            : 'You do not have permission to view documents and policies.',
                                      ),
                                    );
                                  }

                                  if (controller.isLoading.value) {
                                    return Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.secondary,
                                        strokeWidth: 2.5.w,
                                      ),
                                    );
                                  }

                                  final tabIndex =
                                      controller.selectedTabIndex.value;
                                  if (tabIndex == 0) {
                                    return _buildPoliciesTab();
                                  } else if (tabIndex == 1) {
                                    return _buildMyFilesTab();
                                  } else {
                                    return _buildLettersTab();
                                  }
                                }),
                              ),

                              SizedBox(height: 30.h),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 3-Way Switcher: Policies, My Files, Letters
  Widget _buildTabSwitcher() {
    return Container(
      width: double.infinity,
      height: 46.h,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: AppColors.borderColor,
          width: 1.w,
        ),
      ),
      child: Obx(() {
        final currentTab = controller.selectedTabIndex.value;
        final me = controller.meDocuments.value;
        final unackCount = me?.policiesToAccept
                .where((p) => p.acknowledged == false)
                .length ??
            0;

        return Row(
          children: [
            Expanded(
              child: _buildSwitcherItem(
                title: 'Policies',
                isSelected: currentTab == 0,
                icon: Icons.menu_book_outlined,
                badgeCount: unackCount > 0 ? unackCount : null,
                onTap: () => controller.switchTab(0),
              ),
            ),
            AppSpaces.hSpace4,
            Expanded(
              child: _buildSwitcherItem(
                title: 'My Files',
                isSelected: currentTab == 1,
                icon: Icons.folder_open_rounded,
                onTap: () => controller.switchTab(1),
              ),
            ),
            AppSpaces.hSpace4,
            Expanded(
              child: _buildSwitcherItem(
                title: 'Letters',
                isSelected: currentTab == 2,
                icon: Icons.mark_email_read_outlined,
                onTap: () => controller.switchTab(2),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSwitcherItem({
    required String title,
    required bool isSelected,
    required IconData icon,
    int? badgeCount,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(20.r),
          ),
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 7.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14.w,
                color: isSelected ? AppColors.secondary : AppColors.subTextColor,
              ),
              AppSpaces.hSpace4,
              Flexible(
                child: Text(
                  title,
                  style: AppTextStyles.text12.copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (badgeCount != null) ...[
                AppSpaces.hSpace4,
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: AppColors.warning,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: AppTextStyles.text10.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Tab 0: Company Policies & Handbooks
  Widget _buildPoliciesTab() {
    final policies = controller.companyDocuments;
    if (policies.isEmpty) {
      return Center(
        child: CustomStateView.empty(
          icon: Icons.menu_book_outlined,
          title: 'No Policies Found',
          message: 'There are currently no published company policies or handbooks.',
          buttonText: 'Refresh',
          onAction: () => controller.loadAllDocuments(isRefresh: true),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: policies.map((policy) {
        return PolicyCard(
          policy: policy,
          onTap: () => controller.openPolicyDetails(policy.id),
        );
      }).toList(),
    );
  }

  /// Tab 1: Personal Uploaded Files & Expiring Documents
  Widget _buildMyFilesTab() {
    final me = controller.meDocuments.value;
    final files = me?.files ?? [];
    final expiring = me?.expiring ?? [];

    if (files.isEmpty && expiring.isEmpty) {
      return Center(
        child: CustomStateView.empty(
          icon: Icons.folder_open_rounded,
          title: 'No Documents Found',
          message: 'You do not have any personal documents or identity files uploaded yet.',
          buttonText: 'Refresh',
          onAction: () => controller.loadAllDocuments(isRefresh: true),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Expiring Warning Notice
        if (expiring.isNotEmpty) ...[
          Container(
            margin: EdgeInsets.only(bottom: 14.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.35),
                width: 1.w,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 16.w,
                      color: AppColors.warning,
                    ),
                    AppSpaces.hSpace8,
                    Text(
                      'Documents Expiring Soon',
                      style: AppTextStyles.text12.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
                AppSpaces.vSpace6,
                ...expiring.map((exp) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    child: Text(
                      '• ${exp.title}: expires ${exp.when} (${exp.expiresOn})',
                      style: AppTextStyles.text10.copyWith(
                        color: AppColors.textColor,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],

        // Document Files Listing
        ...files.map((file) {
          final isDl = controller.downloadingFileIds.contains(file.id);
          return DocumentFileCard(
            file: file,
            isDownloading: isDl,
            onDownload: () => controller.downloadAndOpenDocumentFile(
              file.id,
              file.fileName,
            ),
          );
        }),
      ],
    );
  }

  /// Tab 2: Issued Letters & Letter Requests
  Widget _buildLettersTab() {
    final me = controller.meDocuments.value;
    final letters = me?.letters ?? [];
    final requests = me?.letterRequests ?? [];

    if (letters.isEmpty && requests.isEmpty) {
      return Center(
        child: CustomStateView.empty(
          icon: Icons.mark_email_read_outlined,
          title: 'No Letters Found',
          message: 'You have no issued letters or active letter requests.',
          buttonText: me?.requestableLetters.isNotEmpty == true
              ? 'Request a Letter'
              : 'Refresh',
          onAction: () {
            if (me?.requestableLetters.isNotEmpty == true) {
              Get.bottomSheet(
                const RequestLetterBottomSheet(),
                isScrollControlled: true,
              );
            } else {
              controller.loadAllDocuments(isRefresh: true);
            }
          },
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (requests.isNotEmpty) ...[
          Text(
            'Letter Requests',
            style: AppTextStyles.text14.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textColor,
            ),
          ),
          AppSpaces.vSpace8,
          ...requests.map((req) => LetterRequestCard(request: req)),
          AppSpaces.vSpace14,
        ],
        if (letters.isNotEmpty) ...[
          Text(
            'Issued Letters',
            style: AppTextStyles.text14.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textColor,
            ),
          ),
          AppSpaces.vSpace8,
          ...letters.map((letter) {
            final isDl = controller.downloadingFileIds.contains(letter.id);
            return IssuedLetterCard(
              letter: letter,
              isDownloading: isDl,
              onTap: () => controller.openLetterDetails(letter),
              onDownloadPdf: () => controller.downloadAndOpenLetter(
                letter.id,
                letter.reference,
              ),
            );
          }),
        ],
      ],
    );
  }
}
