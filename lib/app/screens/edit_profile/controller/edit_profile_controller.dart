import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../api/exception_handler.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_spaces.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../routes/app_routes.dart';
import '../../approvals/controller/approval_controller.dart';
import '../../profile/controller/profile_controller.dart';
import '../../profile/model/profile_model.dart';
import '../model/edit_profile_model.dart';
import '../repo/edit_profile_repo.dart';

class EditProfileController extends GetxController {
  final EditProfileRepo repo;

  EditProfileController({required this.repo});

  // Form Key for In-Place Reactive Validation
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // State Observables
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final Rxn<EmployeeProfileModel> currentProfile = Rxn<EmployeeProfileModel>();

  // Pending Conflict Observables
  final RxBool hasPendingRequestConflict = false.obs;
  final RxString conflictWarningMessage = ''.obs;

  // --- 1. Personal & Contact Details Observables & Controllers ---
  final TextEditingController preferredNameController = TextEditingController();
  final TextEditingController personalPhoneController = TextEditingController();
  final TextEditingController personalEmailController = TextEditingController();
  final TextEditingController addressLine1Controller = TextEditingController();
  final TextEditingController addressLine2Controller = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController postcodeController = TextEditingController();
  final TextEditingController countryCodeController = TextEditingController();

  final RxString selectedMaritalStatus = ''.obs;
  final List<String> maritalStatusOptions = const [
    'single',
    'married',
    'divorced',
    'widowed',
    'separated',
  ];

  final FocusNode preferredNameFocusNode = FocusNode();
  final FocusNode personalPhoneFocusNode = FocusNode();
  final FocusNode personalEmailFocusNode = FocusNode();
  final FocusNode addressLine1FocusNode = FocusNode();
  final FocusNode addressLine2FocusNode = FocusNode();
  final FocusNode cityFocusNode = FocusNode();
  final FocusNode postcodeFocusNode = FocusNode();
  final FocusNode countryCodeFocusNode = FocusNode();

  // Reactive Inline Errors (Personal)
  final RxnString preferredNameError = RxnString();
  final RxnString personalPhoneError = RxnString();
  final RxnString personalEmailError = RxnString();
  final RxnString addressLine1Error = RxnString();
  final RxnString cityError = RxnString();
  final RxnString postcodeError = RxnString();
  final RxnString countryCodeError = RxnString();

  // Initial snapshots to identify touched fields
  String _initialPreferredName = '';
  String _initialPhone = '';
  String _initialEmail = '';
  String _initialMaritalStatus = '';
  String _initialAddress1 = '';
  String _initialAddress2 = '';
  String _initialCity = '';
  String _initialPostcode = '';
  String _initialCountryCode = '';

  // --- 2. Emergency Contact Observables & Controllers ---
  final RxnString existingEmergencyContactId = RxnString();
  final TextEditingController emergencyNameController = TextEditingController();
  final TextEditingController emergencyRelationController = TextEditingController();
  final TextEditingController emergencyPhoneController = TextEditingController();
  final TextEditingController emergencyAltPhoneController = TextEditingController();
  final TextEditingController emergencyAddressController = TextEditingController();
  final RxBool isPrimaryEmergencyContact = true.obs;

  final FocusNode emergencyNameFocusNode = FocusNode();
  final FocusNode emergencyRelationFocusNode = FocusNode();
  final FocusNode emergencyPhoneFocusNode = FocusNode();
  final FocusNode emergencyAltPhoneFocusNode = FocusNode();
  final FocusNode emergencyAddressFocusNode = FocusNode();

  // Reactive Inline Errors (Emergency)
  final RxnString emergencyNameError = RxnString();
  final RxnString emergencyRelationError = RxnString();
  final RxnString emergencyPhoneError = RxnString();
  final RxnString emergencyAltPhoneError = RxnString();

  String _initialEmergencyName = '';
  String _initialEmergencyRelation = '';
  String _initialEmergencyPhone = '';
  String _initialEmergencyAltPhone = '';
  String _initialEmergencyAddress = '';
  bool _initialIsPrimary = true;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is EmployeeProfileModel) {
      _populateForm(args);
      checkPendingRequestConflict();
    } else {
      loadInitialProfile();
    }
  }

  /// Checks whether an approval request for details change is already waiting in mine box
  Future<void> checkPendingRequestConflict() async {
    try {
      final hasPending = await repo.hasPendingDetailsChangeRequest();
      if (hasPending) {
        hasPendingRequestConflict.value = true;
        conflictWarningMessage.value =
            'There is already a request waiting for approval. Wait for its answer or withdraw it first.';
      } else {
        hasPendingRequestConflict.value = false;
        conflictWarningMessage.value = '';
      }
    } catch (_) {}
  }

  /// Loads profile from repository and populates fields
  Future<void> loadInitialProfile() async {
    try {
      isLoading.value = true;
      final profile = await repo.fetchCurrentProfile();
      if (profile != null) {
        _populateForm(profile);
      }
      await checkPendingRequestConflict();
    } finally {
      isLoading.value = false;
    }
  }

  /// Populates all form fields with initial employee data
  void _populateForm(EmployeeProfileModel profile) {
    currentProfile.value = profile;

    // Contact & Personal Fields
    _initialPreferredName = profile.preferredName ?? '';
    preferredNameController.text = _initialPreferredName;

    _initialPhone = profile.personal?.personalPhone ?? profile.phone;
    personalPhoneController.text = _initialPhone;

    _initialEmail = profile.personal?.personalEmail ?? '';
    personalEmailController.text = _initialEmail;

    _initialMaritalStatus = (profile.personal?.maritalStatus ?? '').toLowerCase();
    selectedMaritalStatus.value = _initialMaritalStatus;

    final addr = profile.personal?.address;
    _initialAddress1 = addr?.line1 ?? profile.address;
    addressLine1Controller.text = _initialAddress1;

    _initialAddress2 = addr?.line2 ?? '';
    addressLine2Controller.text = _initialAddress2;

    _initialCity = addr?.city ?? profile.city;
    cityController.text = _initialCity;

    _initialPostcode = addr?.postcode ?? profile.postalCode;
    postcodeController.text = _initialPostcode;

    _initialCountryCode = (addr?.country ?? 'PK').toUpperCase();
    countryCodeController.text = _initialCountryCode;

    // Emergency Contact Fields
    if (profile.emergencyContacts.isNotEmpty) {
      final primary = profile.emergencyContacts.firstWhere(
        (c) => c.isPrimary,
        orElse: () => profile.emergencyContacts.first,
      );
      existingEmergencyContactId.value = primary.id;
      emergencyNameController.text = primary.name ?? '';
      emergencyRelationController.text = primary.relationship ?? '';
      emergencyPhoneController.text = primary.phone ?? '';
      emergencyAltPhoneController.text = primary.alternativePhone ?? '';
      isPrimaryEmergencyContact.value = primary.isPrimary;
    } else if (profile.emergencyContactName.isNotEmpty) {
      emergencyNameController.text = profile.emergencyContactName;
      emergencyRelationController.text = profile.emergencyContactRelation;
      emergencyPhoneController.text = profile.emergencyContactPhone;
      isPrimaryEmergencyContact.value = true;
    }

    _initialEmergencyName = emergencyNameController.text.trim();
    _initialEmergencyRelation = emergencyRelationController.text.trim();
    _initialEmergencyPhone = emergencyPhoneController.text.trim();
    _initialEmergencyAltPhone = emergencyAltPhoneController.text.trim();
    _initialEmergencyAddress = emergencyAddressController.text.trim();
    _initialIsPrimary = isPrimaryEmergencyContact.value;
  }

  void setMaritalStatus(String? value) {
    HapticFeedback.selectionClick();
    selectedMaritalStatus.value = (value ?? '').toLowerCase();
  }

  void togglePrimaryEmergencyContact(bool value) {
    HapticFeedback.selectionClick();
    isPrimaryEmergencyContact.value = value;
  }

  // --- Change Detection ---

  bool hasContactChanges() {
    return preferredNameController.text.trim() != _initialPreferredName ||
        personalPhoneController.text.trim() != _initialPhone ||
        personalEmailController.text.trim() != _initialEmail ||
        selectedMaritalStatus.value.trim() != _initialMaritalStatus ||
        addressLine1Controller.text.trim() != _initialAddress1 ||
        addressLine2Controller.text.trim() != _initialAddress2 ||
        cityController.text.trim() != _initialCity ||
        postcodeController.text.trim() != _initialPostcode ||
        countryCodeController.text.trim().toUpperCase() != _initialCountryCode;
  }

  bool hasEmergencyChanges() {
    final name = emergencyNameController.text.trim();
    final relation = emergencyRelationController.text.trim();
    final phone = emergencyPhoneController.text.trim();
    final altPhone = emergencyAltPhoneController.text.trim();
    final address = emergencyAddressController.text.trim();
    final isPrimary = isPrimaryEmergencyContact.value;

    return name != _initialEmergencyName ||
        relation != _initialEmergencyRelation ||
        phone != _initialEmergencyPhone ||
        altPhone != _initialEmergencyAltPhone ||
        address != _initialEmergencyAddress ||
        isPrimary != _initialIsPrimary;
  }

  PersonalDetailsChangeRequest buildPersonalDetailsRequest() {
    final changed = <String>{};
    final newPreferred = preferredNameController.text.trim();
    if (newPreferred != _initialPreferredName) changed.add('preferred_name');

    final newPhone = personalPhoneController.text.trim();
    if (newPhone != _initialPhone) changed.add('personal_phone');

    final newEmail = personalEmailController.text.trim();
    if (newEmail != _initialEmail) changed.add('personal_email');

    final newMarital = selectedMaritalStatus.value.trim();
    if (newMarital != _initialMaritalStatus) changed.add('marital_status');

    final newAddr1 = addressLine1Controller.text.trim();
    if (newAddr1 != _initialAddress1) changed.add('address_line1');

    final newAddr2 = addressLine2Controller.text.trim();
    if (newAddr2 != _initialAddress2) changed.add('address_line2');

    final newCity = cityController.text.trim();
    if (newCity != _initialCity) changed.add('city_name');

    final newPostcode = postcodeController.text.trim();
    if (newPostcode != _initialPostcode) changed.add('postcode');

    final newCountry = countryCodeController.text.trim().toUpperCase();
    if (newCountry != _initialCountryCode) changed.add('country_code');

    return PersonalDetailsChangeRequest(
      preferredName: newPreferred,
      personalPhone: newPhone,
      personalEmail: newEmail,
      maritalStatus: newMarital.isNotEmpty ? newMarital : null,
      addressLine1: newAddr1,
      addressLine2: newAddr2,
      cityName: newCity,
      postcode: newPostcode,
      countryCode: newCountry.isNotEmpty ? newCountry : null,
      changedFields: changed,
    );
  }

  void _syncInitialPersonalDetails() {
    _initialPreferredName = preferredNameController.text.trim();
    _initialPhone = personalPhoneController.text.trim();
    _initialEmail = personalEmailController.text.trim();
    _initialMaritalStatus = selectedMaritalStatus.value.trim();
    _initialAddress1 = addressLine1Controller.text.trim();
    _initialAddress2 = addressLine2Controller.text.trim();
    _initialCity = cityController.text.trim();
    _initialPostcode = postcodeController.text.trim();
    _initialCountryCode = countryCodeController.text.trim().toUpperCase();
  }

  void _syncInitialEmergencyContact() {
    _initialEmergencyName = emergencyNameController.text.trim();
    _initialEmergencyRelation = emergencyRelationController.text.trim();
    _initialEmergencyPhone = emergencyPhoneController.text.trim();
    _initialEmergencyAltPhone = emergencyAltPhoneController.text.trim();
    _initialEmergencyAddress = emergencyAddressController.text.trim();
    _initialIsPrimary = isPrimaryEmergencyContact.value;
  }

  // --- Form Field Validators (Empty fields are valid; format validated when typing) ---

  String? validatePersonalEmail(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final trimmed = value.trim();
    if (trimmed.length > 255) {
      return 'Email cannot exceed 255 characters.';
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(trimmed)) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  String? validatePersonalPhone(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final trimmed = value.trim();
    final digitsOnly = trimmed.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length < 10) {
      return 'Phone number must have at least 10 digits.';
    }
    if (trimmed.length > 20) {
      return 'Phone number cannot exceed 20 characters.';
    }
    final phoneRegex = RegExp(r'^\+?[0-9\s\-()]{10,20}$');
    if (!phoneRegex.hasMatch(trimmed)) {
      return 'Please enter a valid phone format.';
    }
    return null;
  }

  String? validatePreferredName(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final trimmed = value.trim();
    if (trimmed.length > 80) {
      return 'Preferred name cannot exceed 80 characters.';
    }
    final nameRegex = RegExp(r"^[a-zA-Z\s'.\-]+$");
    if (!nameRegex.hasMatch(trimmed)) {
      return 'Only letters and spaces are allowed.';
    }
    return null;
  }

  String? validateAddressLine1(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.trim().length > 255) {
      return 'Address line 1 cannot exceed 255 characters.';
    }
    return null;
  }

  String? validateAddressLine2(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.trim().length > 255) {
      return 'Address line 2 cannot exceed 255 characters.';
    }
    return null;
  }

  String? validateCity(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.trim().length > 100) {
      return 'City name cannot exceed 100 characters.';
    }
    return null;
  }

  String? validatePostcode(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final trimmed = value.trim();
    if (trimmed.length > 12) {
      return 'Postcode cannot exceed 12 characters.';
    }
    final postcodeRegex = RegExp(r'^[a-zA-Z0-9\s\-]+$');
    if (!postcodeRegex.hasMatch(trimmed)) {
      return 'Please enter a valid postcode format.';
    }
    return null;
  }

  String? validateCountryCode(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final trimmed = value.trim();
    if (trimmed.length != 2 || !RegExp(r'^[a-zA-Z]{2}$').hasMatch(trimmed)) {
      return 'Enter a 2-letter ISO country code (e.g. PK, GB).';
    }
    return null;
  }

  bool get hasAnyEmergencyFieldFilled =>
      emergencyNameController.text.trim().isNotEmpty ||
      emergencyRelationController.text.trim().isNotEmpty ||
      emergencyPhoneController.text.trim().isNotEmpty ||
      emergencyAltPhoneController.text.trim().isNotEmpty ||
      emergencyAddressController.text.trim().isNotEmpty;

  String? validateEmergencyName(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      if (hasEmergencyChanges() && hasAnyEmergencyFieldFilled) {
        return 'Emergency contact person name is required.';
      }
      return null;
    }
    if (trimmed.length > 80) {
      return 'Name cannot exceed 80 characters.';
    }
    if (!RegExp(r"^[a-zA-Z\s'.\-]+$").hasMatch(trimmed)) {
      return 'Only letters and spaces are allowed.';
    }
    return null;
  }

  String? validateEmergencyRelation(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      if (hasEmergencyChanges() && hasAnyEmergencyFieldFilled) {
        return 'Relationship is required (e.g. Brother, Spouse).';
      }
      return null;
    }
    if (trimmed.length > 40) {
      return 'Relationship cannot exceed 40 characters.';
    }
    return null;
  }

  String? validateEmergencyPhone(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      if (hasEmergencyChanges() && hasAnyEmergencyFieldFilled) {
        return 'Emergency phone number is required.';
      }
      return null;
    }
    final digitsOnly = trimmed.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length < 10) {
      return 'Phone number must have at least 10 digits.';
    }
    if (trimmed.length > 20) {
      return 'Phone number cannot exceed 20 characters.';
    }
    final phoneRegex = RegExp(r'^\+?[0-9\s\-()]{10,20}$');
    if (!phoneRegex.hasMatch(trimmed)) {
      return 'Please enter a valid phone format.';
    }
    return null;
  }

  String? validateEmergencyAltPhone(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final trimmed = value.trim();
    final digitsOnly = trimmed.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length < 10) {
      return 'Phone number must have at least 10 digits.';
    }
    if (trimmed.length > 20) {
      return 'Alternative phone cannot exceed 20 characters.';
    }
    final phoneRegex = RegExp(r'^\+?[0-9\s\-()]{10,20}$');
    if (!phoneRegex.hasMatch(trimmed)) {
      return 'Please enter a valid phone format.';
    }
    return null;
  }

  // --- Form Validation Methods ---

  bool _validatePersonalDetails() {
    bool isValid = true;
    preferredNameError.value = validatePreferredName(preferredNameController.text);
    if (preferredNameError.value != null) isValid = false;

    personalPhoneError.value = validatePersonalPhone(personalPhoneController.text);
    if (personalPhoneError.value != null) isValid = false;

    personalEmailError.value = validatePersonalEmail(personalEmailController.text);
    if (personalEmailError.value != null) isValid = false;

    addressLine1Error.value = validateAddressLine1(addressLine1Controller.text);
    if (addressLine1Error.value != null) isValid = false;

    cityError.value = validateCity(cityController.text);
    if (cityError.value != null) isValid = false;

    postcodeError.value = validatePostcode(postcodeController.text);
    if (postcodeError.value != null) isValid = false;

    countryCodeError.value = validateCountryCode(countryCodeController.text);
    if (countryCodeError.value != null) isValid = false;

    return isValid;
  }

  bool _validateEmergencyContact() {
    bool isValid = true;
    emergencyNameError.value = validateEmergencyName(emergencyNameController.text);
    if (emergencyNameError.value != null) isValid = false;

    emergencyRelationError.value = validateEmergencyRelation(emergencyRelationController.text);
    if (emergencyRelationError.value != null) isValid = false;

    emergencyPhoneError.value = validateEmergencyPhone(emergencyPhoneController.text);
    if (emergencyPhoneError.value != null) isValid = false;

    emergencyAltPhoneError.value = validateEmergencyAltPhone(emergencyAltPhoneController.text);
    if (emergencyAltPhoneError.value != null) isValid = false;

    return isValid;
  }

  /// Unified submit: Checks what changed and submits details or emergency contact seamlessly
  Future<void> saveAllChanges() async {
    if (isSaving.value) return;

    final contactChanged = hasContactChanges();
    final emergencyChanged = hasEmergencyChanges();

    if (hasPendingRequestConflict.value) {
      HapticFeedback.heavyImpact();
      showConflictDialog(message: conflictWarningMessage.value);
      return;
    }

    if (!contactChanged && !emergencyChanged) {
      HapticFeedback.lightImpact();
      CustomSnackbar.showInfo(
        message: 'No changes detected to update.',
      );
      return;
    }

    // Form Key In-Place Validation
    if (formKey.currentState != null && !formKey.currentState!.validate()) {
      HapticFeedback.heavyImpact();
      CustomSnackbar.showError(
        title: 'Validation Error',
        message: 'Please resolve errors in the highlighted fields.',
      );
      return;
    }

    if (contactChanged && !_validatePersonalDetails()) {
      HapticFeedback.heavyImpact();
      CustomSnackbar.showError(
        title: 'Validation Error',
        message: 'Please resolve errors in personal contact fields.',
      );
      return;
    }

    if (emergencyChanged && !_validateEmergencyContact()) {
      HapticFeedback.heavyImpact();
      CustomSnackbar.showError(
        title: 'Validation Error',
        message: 'Please resolve required emergency contact fields.',
      );
      return;
    }

    try {
      isSaving.value = true;
      HapticFeedback.mediumImpact();

      final List<String> responses = [];
      bool anyPending = false;

      // 1. Submit personal details if changed
      if (contactChanged) {
        final request = buildPersonalDetailsRequest();
        final response = await repo.submitPersonalDetailsChange(request);
        if (response.isPending) anyPending = true;
        responses.add(response.userMessage);
        _syncInitialPersonalDetails();
      }

      // 2. Submit emergency contact if changed
      if (emergencyChanged) {
        final request = EmergencyContactChangeRequest(
          contactId: existingEmergencyContactId.value,
          name: emergencyNameController.text.trim(),
          relationship: emergencyRelationController.text.trim(),
          phone: emergencyPhoneController.text.trim(),
          alternativePhone: emergencyAltPhoneController.text.trim(),
          address: emergencyAddressController.text.trim(),
          isPrimary: isPrimaryEmergencyContact.value,
        );
        final response = await repo.submitEmergencyContactChange(request);
        if (response.isPending) anyPending = true;
        responses.add(response.userMessage);
        _syncInitialEmergencyContact();
      }

      // Show comprehensive user outcome
      CustomSnackbar.showSuccess(
        title: anyPending ? 'Sent for approval' : 'Saved',
        message: responses.isNotEmpty
            ? responses.join(' ')
            : 'Your changes have been processed successfully.',
      );

      // Refresh parent profile controller
      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().loadProfile();
      }
    } on ApiException catch (e) {
      HapticFeedback.heavyImpact();
      if (e.isConflict) {
        hasPendingRequestConflict.value = true;
        final msg = e.message.isNotEmpty
            ? e.message
            : 'There is already a request waiting for approval. Wait for its answer or withdraw it first.';
        conflictWarningMessage.value = msg;
        showConflictDialog(message: msg);
      } else if (e.isValidationFailed && e.fields != null) {
        _applyServerValidationErrors(e.fields!);
        CustomSnackbar.showError(
          title: 'Validation Failed',
          message: e.message.isNotEmpty ? e.message : 'Please check highlighted fields.',
        );
      } else {
        CustomSnackbar.showError(
          title: 'Update Failed',
          message: e.message,
        );
      }
    } catch (e) {
      CustomSnackbar.showError(
        title: 'Connection Error',
        message: 'Unable to reach the server. Please try again.',
      );
    } finally {
      isSaving.value = false;
    }
  }

  /// Displays an executive AMS 2 modal dialog explaining the 409 conflict
  /// with a direct action to jump into Requests Inbox to review/withdraw it.
  void showConflictDialog({String? message}) {
    HapticFeedback.heavyImpact();
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 20.h),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AppColors.deepNavyBase,
                AppColors.primary,
                AppColors.accentNavy,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppColors.warning.withValues(alpha: 0.65),
              width: 1.2.w,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.deepNavyBase.withValues(alpha: 0.45),
                blurRadius: 18.r,
                offset: Offset(0, 8.h),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52.r,
                height: 52.r,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.5),
                    width: 1.w,
                  ),
                ),
                child: Icon(
                  Icons.hourglass_top_rounded,
                  size: 26.sp,
                  color: AppColors.warning,
                ),
              ),
              AppSpaces.vSpace14,
              Text(
                'Request Waiting for Approval',
                textAlign: TextAlign.center,
                style: AppTextStyles.text16.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
              AppSpaces.vSpace8,
              Text(
                message != null && message.trim().isNotEmpty
                    ? message
                    : 'There is already a request waiting for approval. Wait for its answer or withdraw it first.',
                textAlign: TextAlign.center,
                style: AppTextStyles.text12.copyWith(
                  color: AppColors.white.withValues(alpha: 0.88),
                  height: 1.45,
                ),
              ),
              AppSpaces.vSpace18,
              CustomButton(
                text: 'View in Requests Inbox',
                isGradient: true,
                height: 44.h,
                borderRadius: 12.r,
                icon: Icon(
                  Icons.inbox_rounded,
                  size: 16.sp,
                  color: AppColors.white,
                ),
                onPressed: () {
                  Get.back();
                  openMyRequestsInbox();
                },
              ),
              AppSpaces.vSpace10,
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'Dismiss',
                  style: AppTextStyles.text12.copyWith(
                    color: AppColors.liteSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  /// Navigates directly to the user's personal requests inbox (/approvals?box=mine)
  void openMyRequestsInbox() {
    HapticFeedback.lightImpact();
    Get.toNamed(Routes.APPROVALS, arguments: {'box': 'mine'});
    if (Get.isRegistered<ApprovalController>()) {
      Get.find<ApprovalController>().changeBox('mine');
    }
  }

  void _applyServerValidationErrors(Map<String, dynamic> fields) {
    if (fields.containsKey('preferred_name')) {
      preferredNameError.value = fields['preferred_name']?.toString();
    }
    if (fields.containsKey('personal_phone')) {
      personalPhoneError.value = fields['personal_phone']?.toString();
    }
    if (fields.containsKey('personal_email')) {
      personalEmailError.value = fields['personal_email']?.toString();
    }
    if (fields.containsKey('address_line1')) {
      addressLine1Error.value = fields['address_line1']?.toString();
    }
    if (fields.containsKey('city_name')) {
      cityError.value = fields['city_name']?.toString();
    }
    if (fields.containsKey('postcode')) {
      postcodeError.value = fields['postcode']?.toString();
    }
    if (fields.containsKey('country_code')) {
      countryCodeError.value = fields['country_code']?.toString();
    }
    if (fields.containsKey('name')) {
      emergencyNameError.value = fields['name']?.toString();
    }
    if (fields.containsKey('relationship')) {
      emergencyRelationError.value = fields['relationship']?.toString();
    }
    if (fields.containsKey('phone')) {
      emergencyPhoneError.value = fields['phone']?.toString();
    }
  }

  @override
  void onClose() {
    preferredNameController.dispose();
    personalPhoneController.dispose();
    personalEmailController.dispose();
    addressLine1Controller.dispose();
    addressLine2Controller.dispose();
    cityController.dispose();
    postcodeController.dispose();
    countryCodeController.dispose();

    preferredNameFocusNode.dispose();
    personalPhoneFocusNode.dispose();
    personalEmailFocusNode.dispose();
    addressLine1FocusNode.dispose();
    addressLine2FocusNode.dispose();
    cityFocusNode.dispose();
    postcodeFocusNode.dispose();
    countryCodeFocusNode.dispose();

    emergencyNameController.dispose();
    emergencyRelationController.dispose();
    emergencyPhoneController.dispose();
    emergencyAltPhoneController.dispose();
    emergencyAddressController.dispose();

    emergencyNameFocusNode.dispose();
    emergencyRelationFocusNode.dispose();
    emergencyPhoneFocusNode.dispose();
    emergencyAltPhoneFocusNode.dispose();
    emergencyAddressFocusNode.dispose();

    super.onClose();
  }
}
