import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../profile/controller/profile_controller.dart';
import '../../profile/model/profile_model.dart';
import '../model/edit_profile_model.dart';
import '../repo/edit_profile_repo.dart';

class EditProfileController extends GetxController {
  final EditProfileRepo repo;
  final ImagePicker _imagePicker = ImagePicker();

  EditProfileController({required this.repo});

  // Global Form Key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // State Observables
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final Rxn<EmployeeProfileModel> currentProfile = Rxn<EmployeeProfileModel>();

  // Dropdown / Selection Observables
  final RxString selectedGender = 'Male'.obs;
  final RxString selectedBloodGroup = 'O+'.obs;
  final List<String> genderOptions = const ['Male', 'Female', 'Other'];
  final List<String> bloodGroupOptions = const [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  // Photo Observables
  final Rx<File?> selectedPhoto = Rx<File?>(null);
  final RxString selectedPhotoPath = ''.obs;

  // Text Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController cnicController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();

  final TextEditingController emergencyNameController = TextEditingController();
  final TextEditingController emergencyPhoneController = TextEditingController();
  final TextEditingController emergencyRelationController =
      TextEditingController();

  // Focus Nodes
  final FocusNode nameFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode phoneFocusNode = FocusNode();
  final FocusNode cnicFocusNode = FocusNode();

  final FocusNode addressFocusNode = FocusNode();
  final FocusNode cityFocusNode = FocusNode();
  final FocusNode postalCodeFocusNode = FocusNode();

  final FocusNode emergencyNameFocusNode = FocusNode();
  final FocusNode emergencyPhoneFocusNode = FocusNode();
  final FocusNode emergencyRelationFocusNode = FocusNode();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is EmployeeProfileModel) {
      _populateForm(args);
    } else {
      loadInitialProfile();
    }
  }

  /// Loads current profile from repository and populates fields
  Future<void> loadInitialProfile() async {
    try {
      isLoading.value = true;
      final profile = await repo.fetchCurrentProfile();
      if (profile != null) {
        _populateForm(profile);
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Populates all form fields and observables with existing profile data
  void _populateForm(EmployeeProfileModel profile) {
    currentProfile.value = profile;

    nameController.text = profile.name;
    emailController.text = profile.email;
    phoneController.text = profile.phone;
    cnicController.text = profile.cnic;
    dobController.text = profile.dob;

    selectedGender.value = profile.gender;
    selectedBloodGroup.value = profile.bloodGroup;

    addressController.text = profile.address;
    cityController.text = profile.city;
    postalCodeController.text = profile.postalCode;

    emergencyNameController.text = profile.emergencyContactName;
    emergencyPhoneController.text = profile.emergencyContactPhone;
    emergencyRelationController.text = profile.emergencyContactRelation;

    if (profile.avatarPath != null && profile.avatarPath!.isNotEmpty) {
      selectedPhotoPath.value = profile.avatarPath!;
      final file = File(profile.avatarPath!);
      if (file.existsSync()) {
        selectedPhoto.value = file;
      }
    }
  }

  /// Updates selected gender
  void setGender(String value) {
    HapticFeedback.selectionClick();
    selectedGender.value = value;
  }

  /// Updates selected blood group
  void setBloodGroup(String value) {
    HapticFeedback.selectionClick();
    selectedBloodGroup.value = value;
  }

  /// Interactive Date Picker for Date of Birth
  Future<void> selectDateOfBirth(BuildContext context) async {
    HapticFeedback.lightImpact();
    final now = DateTime.now();
    final initialDate = DateTime(1996, 5, 14);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              onSurface: AppColors.textColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      final formatted =
          '${picked.day.toString().padLeft(2, '0')} ${months[picked.month - 1]} ${picked.year}';
      dobController.text = formatted;
    }
  }

  /// Captures or picks profile avatar image
  Future<void> pickPhoto(ImageSource source) async {
    try {
      HapticFeedback.selectionClick();
      final XFile? file = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 720,
        maxHeight: 720,
      );

      if (file != null) {
        selectedPhoto.value = File(file.path);
        selectedPhotoPath.value = file.path;
        CustomSnackbar.showSuccess(
          title: 'Photo Selected',
          message: 'Profile image updated successfully.',
        );
      }
    } catch (e) {
      CustomSnackbar.showError(
        title: 'Image Picker',
        message: 'Could not access device photos: $e',
      );
    }
  }

  /// Removes currently selected photo
  void removePhoto() {
    HapticFeedback.selectionClick();
    selectedPhoto.value = null;
    selectedPhotoPath.value = '';
    CustomSnackbar.showSuccess(
      title: 'Photo Removed',
      message: 'Reverted to executive initials avatar.',
    );
  }

  /// Validates and saves updated profile credentials
  Future<void> saveProfile() async {
    if (isSaving.value) return;

    if (formKey.currentState?.validate() != true) {
      HapticFeedback.heavyImpact();
      CustomSnackbar.showError(
        title: 'Validation Failed',
        message: 'Please review and fill in all mandatory fields.',
      );
      return;
    }

    final current = currentProfile.value;
    if (current == null) {
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Current profile data is unavailable.',
      );
      return;
    }

    try {
      isSaving.value = true;
      HapticFeedback.mediumImpact();

      final request = EditProfileRequestModel(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        cnic: cnicController.text.trim(),
        dob: dobController.text.trim(),
        gender: selectedGender.value,
        bloodGroup: selectedBloodGroup.value,
        address: addressController.text.trim(),
        city: cityController.text.trim(),
        postalCode: postalCodeController.text.trim(),
        emergencyContactName: emergencyNameController.text.trim(),
        emergencyContactPhone: emergencyPhoneController.text.trim(),
        emergencyContactRelation: emergencyRelationController.text.trim(),
        avatarPath: selectedPhotoPath.value.isNotEmpty
            ? selectedPhotoPath.value
            : null,
      );

      final updated = await repo.saveProfile(
        current: current,
        request: request,
      );

      if (updated != null) {
        currentProfile.value = updated;

        // Update ProfileController instance if active in memory
        if (Get.isRegistered<ProfileController>()) {
          Get.find<ProfileController>().updateProfileLocally(updated);
        }

        CustomSnackbar.showSuccess(
          title: 'Profile Updated',
          message: 'Your personal information was saved successfully.',
        );

        // Pop back to ProfileView with success indicator
        Get.back(result: true);
      } else {
        CustomSnackbar.showError(
          title: 'Update Failed',
          message: 'Unable to save profile changes. Please try again.',
        );
      }
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    cnicController.dispose();
    dobController.dispose();

    addressController.dispose();
    cityController.dispose();
    postalCodeController.dispose();

    emergencyNameController.dispose();
    emergencyPhoneController.dispose();
    emergencyRelationController.dispose();

    nameFocusNode.dispose();
    emailFocusNode.dispose();
    phoneFocusNode.dispose();
    cnicFocusNode.dispose();

    addressFocusNode.dispose();
    cityFocusNode.dispose();
    postalCodeFocusNode.dispose();

    emergencyNameFocusNode.dispose();
    emergencyPhoneFocusNode.dispose();
    emergencyRelationFocusNode.dispose();

    super.onClose();
  }
}
