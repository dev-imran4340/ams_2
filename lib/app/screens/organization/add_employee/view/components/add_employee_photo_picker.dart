import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_spaces.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../controller/add_employee_controller.dart';

class AddEmployeePhotoPicker extends GetView<AddEmployeeController> {
  const AddEmployeePhotoPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photo',
          style: AppTextStyles.text14.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textColor,
          ),
        ),
        AppSpaces.vSpace8,
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            border: Border.all(
              color: AppColors.borderColor,
              width: 1.w,
            ),
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Column(
            children: [
              // Photo Preview or Tap Area
              GestureDetector(
                onTap: () => _showPhotoPickerDialog(context),
                child: Container(
                  height: 140.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(13.r),
                      topRight: Radius.circular(13.r),
                    ),
                  ),
                  child: Obx(() {
                    final photo = controller.selectedPhoto.value;
                    if (photo != null) {
                      return ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(13.r),
                          topRight: Radius.circular(13.r),
                        ),
                        child: Image.file(
                          photo,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      );
                    }

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 50.r,
                          height: 50.r,
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.camera_alt_outlined,
                              size: 26.sp,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                        AppSpaces.vSpace8,
                        Text(
                          'Tap to add employee photo',
                          style: AppTextStyles.text12.copyWith(
                            color: AppColors.subTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),

              // Action buttons row
              Container(
                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(13.r),
                    bottomRight: Radius.circular(13.r),
                  ),
                ),
                child: Obx(() {
                  final hasPhoto = controller.selectedPhoto.value != null;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: () => _showPhotoPickerDialog(context),
                        icon: Icon(
                          hasPhoto ? Icons.change_circle_outlined : Icons.add_photo_alternate_outlined,
                          size: 18.sp,
                          color: AppColors.secondary,
                        ),
                        label: Text(
                          hasPhoto ? 'Change Photo' : 'Add Photo',
                          style: AppTextStyles.text12.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (hasPhoto) ...[
                        AppSpaces.hSpace16,
                        TextButton.icon(
                          onPressed: controller.removePhoto,
                          icon: Icon(
                            Icons.delete_outline_rounded,
                            size: 18.sp,
                            color: AppColors.error,
                          ),
                          label: Text(
                            'Remove',
                            style: AppTextStyles.text12.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showPhotoPickerDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 44.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.borderColor,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                AppSpaces.vSpace16,
                Text(
                  'Select Profile Photo',
                  style: AppTextStyles.text16.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                AppSpaces.vSpace4,
                Text(
                  'Choose source to capture or select employee photo',
                  style: AppTextStyles.text12.copyWith(
                    color: AppColors.subTextColor,
                  ),
                ),
                AppSpaces.vSpace20,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _photoOptionTile(
                      icon: Icons.camera_alt_rounded,
                      label: 'Camera',
                      onTap: () {
                        Navigator.pop(ctx);
                        controller.pickPhoto(ImageSource.camera);
                      },
                    ),
                    _photoOptionTile(
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                      onTap: () {
                        Navigator.pop(ctx);
                        controller.pickPhoto(ImageSource.gallery);
                      },
                    ),
                  ],
                ),
                AppSpaces.vSpace12,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _photoOptionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        width: 130.w,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.borderColor, width: 1.w),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 46.r,
              height: 46.r,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 22.sp,
                color: AppColors.secondary,
              ),
            ),
            AppSpaces.vSpace8,
            Text(
              label,
              style: AppTextStyles.text14.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
