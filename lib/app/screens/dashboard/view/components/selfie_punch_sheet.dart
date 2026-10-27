import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';

class SelfiePunchSheet extends StatefulWidget {
  final String punchKind;

  const SelfiePunchSheet({
    super.key,
    required this.punchKind,
  });

  @override
  State<SelfiePunchSheet> createState() => _SelfiePunchSheetState();
}

class _SelfiePunchSheetState extends State<SelfiePunchSheet> {
  CameraController? _cameraController;
  bool _isCameraReady = false;
  bool _isCapturing = false;
  File? _capturedFile;
  String _statusMessage = 'Align your face in the front camera frame';

  @override
  void initState() {
    super.initState();
    _initFrontCamera();
  }

  Future<void> _initFrontCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _isCameraReady = false;
          _statusMessage = 'No camera found. Use file picker below.';
        });
        return;
      }

      final frontCam = cameras.firstWhereOrNull(
            (c) => c.lensDirection == CameraLensDirection.front,
          ) ??
          cameras.first;

      final controller = CameraController(
        frontCam,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await controller.initialize();

      if (!mounted) return;

      setState(() {
        _cameraController = controller;
        _isCameraReady = true;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCameraReady = false;
          _statusMessage = 'Camera unavailable. Tap fallback below.';
        });
      }
    }
  }

  Future<void> _takeSelfie() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      await _pickFromPicker();
      return;
    }

    try {
      setState(() => _isCapturing = true);
      await HapticFeedback.mediumImpact();

      final XFile xFile = await _cameraController!.takePicture();
      if (!mounted) return;

      setState(() {
        _capturedFile = File(xFile.path);
        _isCapturing = false;
        _statusMessage = 'Selfie captured! Confirm to submit attendance.';
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isCapturing = false);
      }
      await _pickFromPicker();
    }
  }

  Future<void> _pickFromPicker() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 85,
      );

      if (picked != null && mounted) {
        setState(() {
          _capturedFile = File(picked.path);
          _statusMessage = 'Photo selected! Confirm to submit attendance.';
        });
      }
    } catch (_) {}
  }

  void _retakeSelfie() {
    HapticFeedback.lightImpact();
    setState(() {
      _capturedFile = null;
      _statusMessage = 'Align your face in the front camera frame';
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  String _getActionTitle() {
    switch (widget.punchKind) {
      case 'in':
        return 'Check-In Selfie Verification';
      case 'out':
        return 'Check-Out Selfie Verification';
      case 'break_start':
        return 'Break Start Verification';
      case 'break_end':
        return 'Break End Verification';
      default:
        return 'Attendance Selfie Verification';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        border: Border.all(color: AppColors.borderColor, width: 1.w),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 30.r,
            offset: Offset(0, -6.h),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Drag Pill
              Container(
                width: 44.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.subTextColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),

              AppSpaces.vSpace12,

              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getActionTitle(),
                          style: AppTextStyles.text16.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                        AppSpaces.vSpace2,
                        Text(
                          'Company policy requires a live front-camera photo.',
                          style: AppTextStyles.text10.copyWith(
                            color: AppColors.subTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(result: null),
                    icon: Icon(
                      Icons.close_rounded,
                      color: AppColors.subTextColor,
                      size: 22.sp,
                    ),
                  ),
                ],
              ),

              AppSpaces.vSpace14,

              // Camera Viewfinder / Preview Container
              Container(
                width: 220.w,
                height: 270.h,
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: _capturedFile != null
                        ? AppColors.secondary
                        : AppColors.borderColor,
                    width: 2.w,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.15),
                      blurRadius: 16.r,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18.r),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (_capturedFile != null)
                        Image.file(
                          _capturedFile!,
                          fit: BoxFit.cover,
                        )
                      else if (_isCameraReady && _cameraController != null)
                        CameraPreview(_cameraController!)
                      else
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.camera_front_rounded,
                                size: 48.sp,
                                color: AppColors.secondary,
                              ),
                              AppSpaces.vSpace8,
                              Text(
                                _statusMessage,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.text10.copyWith(
                                  color: AppColors.subTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Oval Viewfinder Overlay Guide
                      if (_capturedFile == null)
                        IgnorePointer(
                          child: Center(
                            child: Container(
                              width: 170.w,
                              height: 220.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100.r),
                                border: Border.all(
                                  color: AppColors.secondary.withValues(
                                    alpha: 0.6,
                                  ),
                                  width: 2.w,
                                ),
                              ),
                            ),
                          ),
                        ),

                      if (_isCapturing)
                        Container(
                          color: Colors.black45,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              AppSpaces.vSpace12,

              // Status message pill
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.25),
                    width: 0.8.w,
                  ),
                ),
                child: Text(
                  _statusMessage,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.text10.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              AppSpaces.vSpace16,

              // Action Buttons
              if (_capturedFile != null) ...[
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: OutlinedButton.icon(
                        onPressed: _retakeSelfie,
                        icon: Icon(Icons.refresh_rounded, size: 16.sp),
                        label: const Text('Retake'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textColor,
                          side: BorderSide(
                            color: AppColors.borderColor,
                            width: 1.w,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                      ),
                    ),
                    AppSpaces.hSpace10,
                    Expanded(
                      flex: 2,
                      child: CustomButton(
                        text: 'Confirm & Punch',
                        isGradient: true,
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          Get.back(result: _capturedFile);
                        },
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Shutter button
                    InkWell(
                      onTap: _isCapturing ? null : _takeSelfie,
                      borderRadius: BorderRadius.circular(35.r),
                      child: Container(
                        width: 64.r,
                        height: 64.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondary.withValues(alpha: 0.4),
                              blurRadius: 16.r,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 28.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpaces.vSpace8,
                TextButton.icon(
                  onPressed: _pickFromPicker,
                  icon: Icon(
                    Icons.photo_library_rounded,
                    size: 14.sp,
                    color: AppColors.subTextColor,
                  ),
                  label: Text(
                    'Use Gallery / Camera Fallback',
                    style: AppTextStyles.text10.copyWith(
                      color: AppColors.subTextColor,
                    ),
                  ),
                ),
              ],

              AppSpaces.vSpace8,
            ],
          ),
        ),
      ),
    );
  }
}
