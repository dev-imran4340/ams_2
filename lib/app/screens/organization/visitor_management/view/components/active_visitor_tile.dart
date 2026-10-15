import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_spaces.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../model/visitor_model.dart';

class ActiveVisitorTile extends StatelessWidget {
  final VisitorModel visitor;
  final VoidCallback onCheckOut;

  const ActiveVisitorTile({
    super.key,
    required this.visitor,
    required this.onCheckOut,
  });

  Color _getPurposeColor(String purpose) {
    switch (purpose.toLowerCase()) {
      case 'meeting':
        return AppColors.blue;
      case 'interview':
        return AppColors.warning;
      case 'delivery':
        return AppColors.secondary;
      case 'maintenance':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final purposeColor = _getPurposeColor(visitor.purpose);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 18.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.r),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            border: Border(
              bottom: BorderSide(
                color: AppColors.secondary,
                width: 3.w,
              ),
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Avatar, Guest Info, and ID Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Circular Avatar
                  Container(
                    width: 44.r,
                    height: 44.r,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.secondary,
                        width: 1.5.w,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          blurRadius: 6.r,
                          offset: Offset(0, 2.h),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.person_rounded,
                        size: 24.sp,
                        color: AppColors.white,
                      ),
                    ),
                  ),

                  AppSpaces.hSpace12,

                  // Name & Contact
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          visitor.fullName,
                          style: AppTextStyles.text14.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        AppSpaces.vSpace2,
                        Text(
                          'CNIC: ${visitor.cnic}',
                          style: AppTextStyles.text10.copyWith(
                            color: AppColors.subTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        AppSpaces.vSpace2,
                        Text(
                          'Phone: ${visitor.phone}',
                          style: AppTextStyles.text10.copyWith(
                            color: AppColors.subTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ID Badge & Status
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          visitor.id,
                          style: AppTextStyles.text10.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      AppSpaces.vSpace4,
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5.r,
                              height: 5.r,
                              decoration: const BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                              ),
                            ),
                            AppSpaces.hSpace4,
                            Text(
                              'On-Site',
                              style: AppTextStyles.text10.copyWith(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              AppSpaces.vSpace12,

              // Middle Row: Purpose Pill & Host Employee
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: purposeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      visitor.purpose,
                      style: AppTextStyles.text10.copyWith(
                        fontWeight: FontWeight.bold,
                        color: purposeColor,
                      ),
                    ),
                  ),
                  AppSpaces.hSpace8,
                  Expanded(
                    child: Text(
                      'Host: ${visitor.hostEmployee}',
                      style: AppTextStyles.text10.copyWith(
                        color: AppColors.subTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              AppSpaces.vSpace10,

              // Divider
              Divider(
                color: AppColors.borderColor,
                height: 1.h,
                thickness: 0.8.h,
              ),

              AppSpaces.vSpace10,

              // Bottom Row: Elapsed Time & Check-Out Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 13.sp,
                          color: AppColors.subTextColor,
                        ),
                        AppSpaces.hSpace4,
                        Flexible(
                          child: Text(
                            visitor.elapsedTimeString,
                            style: AppTextStyles.text10.copyWith(
                              color: AppColors.subTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSpaces.hSpace8,
                  CustomButton(
                    text: 'Verify & Check-Out',
                    width: 145.w,
                    height: 32.h,
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    fontSize: 10.5.sp,
                    backgroundColor: AppColors.error,
                    textColor: AppColors.white,
                    icon: Icon(
                      Icons.logout_rounded,
                      size: 13.sp,
                      color: AppColors.white,
                    ),
                    onPressed: onCheckOut,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
