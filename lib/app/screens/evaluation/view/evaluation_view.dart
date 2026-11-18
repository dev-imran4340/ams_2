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
import '../controller/evaluation_controller.dart';
import 'components/evaluation_card.dart';

class EvaluationView extends GetView<EvaluationController> {
  const EvaluationView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkBoundaryWrapper(
      onRetry: () => controller.loadReviews(isRefresh: true),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Stack(
          children: [
            // 1. Curved Ambient Gradient Header (240.h)
            EmployeeAmbientHeader(height: 240.h),

            // 2. Main Scrollable Content Overlapping the Header
            SafeArea(
              bottom: false,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return RefreshIndicator(
                    onRefresh: () => controller.loadReviews(isRefresh: true),
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
                              // Top Bar: Back Pill, Title only
                              const CustomScreenHeader(
                                title: 'Evaluation',
                                subtitle: "Performance cycle",
                              ),

                              AppSpaces.vSpace14,

                              // Top Box Switcher: "My Evaluation" vs "To Review"
                              _buildBoxSwitcher(),

                              AppSpaces.vSpace14,

                              // Evaluation List Content (Expands to vertically center empty & loading states)
                              Expanded(
                                child: Obx(() {
                                  if (controller.isLoading.value) {
                                    return Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.secondary,
                                        strokeWidth: 2.5.w,
                                      ),
                                    );
                                  }

                                  final reviews = controller.reviews;
                                  if (reviews.isEmpty) {
                                    final isMine =
                                        controller.selectedBox.value == 'mine';
                                    return Center(
                                      child: CustomStateView.empty(
                                        icon: Icons.assignment_outlined,
                                        title: 'No Evaluation Found',
                                        message: isMine
                                            ? 'You have no assigned evaluation in this cycle yet.'
                                            : 'There is no evaluation awaiting your feedback.',
                                        buttonText: 'Refresh',
                                        onAction: () => controller.loadReviews(
                                          isRefresh: true,
                                        ),
                                      ),
                                    );
                                  }

                                  return Column(
                                    children: reviews.map((rev) {
                                      return EvaluationCard(
                                        evaluation: rev,
                                        onTap: () => controller.openReviewDetails(rev.id),
                                      );
                                    }).toList(),
                                  );
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

  /// Flat capsule switcher: "My Evaluations" vs "To Review"
  Widget _buildBoxSwitcher() {
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
        final currentBox = controller.selectedBox.value;

        return Row(
          children: [
            Expanded(
              child: _buildSwitcherTab(
                title: 'My Evaluation',
                isSelected: currentBox == 'mine',
                icon: Icons.person_outline_rounded,
                onTap: () => controller.switchBox('mine'),
              ),
            ),
            AppSpaces.hSpace6,
            Expanded(
              child: _buildSwitcherTab(
                title: 'To Review',
                isSelected: currentBox == 'to_review',
                icon: Icons.fact_check_outlined,
                onTap: () => controller.switchBox('to_review'),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSwitcherTab({
    required String title,
    required bool isSelected,
    required IconData icon,
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
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15.w,
                color: isSelected ? AppColors.secondary : AppColors.subTextColor,
              ),
              AppSpaces.hSpace6,
              Text(
                title,
                style: AppTextStyles.text12.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
