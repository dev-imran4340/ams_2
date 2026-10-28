import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_state_view.dart';
import '../../controller/schedule_controller.dart';
import '../../model/schedule_model.dart';

class HolidaysBottomSheet extends StatelessWidget {
  final ScheduleController controller;

  const HolidaysBottomSheet({super.key, required this.controller});

  static void show(BuildContext context, ScheduleController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HolidaysBottomSheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: 0.85.sh),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        border: Border.all(color: AppColors.borderColor, width: 1.w),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Drag Handle
            Center(
              child: Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.borderColor,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),

            AppSpaces.vSpace16,

            // Sheet Header with Year Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40.r,
                      height: 40.r,
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.celebration_rounded,
                        color: AppColors.success,
                        size: 22.sp,
                      ),
                    ),
                    AppSpaces.hSpace12,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Company Holidays',
                          style: AppTextStyles.text18.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                        AppSpaces.vSpace2,
                        Obx(() => Text(
                              'Gazetted calendar for ${controller.activeYear.value}',
                              style: AppTextStyles.text12.copyWith(
                                color: AppColors.subTextColor,
                              ),
                            )),
                      ],
                    ),
                  ],
                ),
                Obx(() => Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: AppColors.borderColor, width: 1.w),
                      ),
                      child: Text(
                        '${controller.holidays.length} Holidays',
                        style: AppTextStyles.text12.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    )),
              ],
            ),

            AppSpaces.vSpace16,
            Container(height: 1.h, color: AppColors.borderColor),
            AppSpaces.vSpace12,

            // Holidays List Content
            Expanded(
              child: Obx(() {
                if (controller.isLoadingHolidays.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.holidays.isEmpty) {
                  return CustomStateView.empty(
                    title: 'No Holidays Found',
                    message: 'No official holidays recorded for ${controller.activeYear.value}.',
                    buttonText: 'Refresh',
                    onAction: () => controller.loadHolidays(),
                  );
                }

                return ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: controller.holidays.length,
                  separatorBuilder: (_, _) => AppSpaces.vSpace10,
                  itemBuilder: (context, index) {
                    final item = controller.holidays[index];
                    return _buildHolidayTile(item);
                  },
                );
              }),
            ),

            AppSpaces.vSpace12,

            // Close Action
            CustomButton(
              isGradient: true,
              text: 'Close Holidays',
              onPressed: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHolidayTile(HolidayModel item) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderColor, width: 1.w),
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            padding: EdgeInsets.symmetric(vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              children: [
                Text(
                  _parseDayNumber(item.startsOn),
                  style: AppTextStyles.text16.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
                Text(
                  _parseMonth(item.startsOn),
                  style: AppTextStyles.text10.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
          AppSpaces.hSpace12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.text14.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                AppSpaces.vSpace2,
                Text(
                  item.startsOn == item.endsOn
                      ? item.startsOn
                      : '${item.startsOn} — ${item.endsOn}',
                  style: AppTextStyles.text12.copyWith(
                    color: AppColors.subTextColor,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  item.isPaid ? 'PAID' : 'UNPAID',
                  style: AppTextStyles.text10.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ),
              AppSpaces.vSpace4,
              Text(
                item.isPublicHoliday ? 'Public' : 'Company',
                style: AppTextStyles.text10.copyWith(
                  color: AppColors.subTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _parseDayNumber(String dateStr) {
    final dt = DateTime.tryParse(dateStr);
    return dt != null ? dt.day.toString().padLeft(2, '0') : '';
  }

  String _parseMonth(String dateStr) {
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return '';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[dt.month - 1];
  }
}
