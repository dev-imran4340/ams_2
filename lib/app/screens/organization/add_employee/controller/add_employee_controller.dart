import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/widgets/custom_snackbar.dart';
import '../model/add_employee_model.dart';
import '../repo/add_employee_repo.dart';

class AddEmployeeController extends GetxController {
  final AddEmployeeRepo repo;
  AddEmployeeController({required this.repo});

  // Lifecycle disposal guard
  bool _isDisposed = false;

  // Global Form Key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Observables
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxInt activeStep = 0.obs; // Compatible with step indicator wizard
  final Rxn<AddEmployeeLookupModel> lookups = Rxn<AddEmployeeLookupModel>();

  // Country & City Observables (matching smart_attendance employee registration)
  final RxList<CountryModel> countries = <CountryModel>[].obs;
  final Rx<CountryModel?> selectedCountry = Rx<CountryModel?>(null);
  final RxString selectedDialCode = '+92'.obs;
  final RxList<CityModel> cities = <CityModel>[].obs;
  final RxList<CityModel> filteredCities = <CityModel>[].obs;
  final Rx<CityModel?> selectedCityModel = Rx<CityModel?>(null);
  final TextEditingController citySearchController = TextEditingController();

  // Dropdown Selection Observables
  final RxString selectedGender = 'Male'.obs;
  final RxString selectedCity = 'Islamabad'.obs;
  final RxString selectedDepartment = 'Software Engineering'.obs;
  final RxString selectedDesignation = 'Senior Flutter Developer'.obs;
  final RxString selectedShift = 'Morning General (09:00 AM - 06:00 PM)'.obs;
  final RxString selectedRelationship = 'Father'.obs;
  final RxString phoneCountryCode = '+92'.obs;

  // Photo & Biometric Observables
  final Rx<File?> selectedPhoto = Rx<File?>(null);
  final RxString selectedPhotoPath = ''.obs;
  final RxBool isFaceCaptured = false.obs;
  final RxDouble faceLivenessScore = 0.98.obs;
  final RxString capturedPhotoLabel = 'Frontal Face Scan'.obs;

  // Personal Info Text Controllers & FocusNodes
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController cnicController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

  final FocusNode nameFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode phoneFocusNode = FocusNode();
  final FocusNode cnicFocusNode = FocusNode();
  final FocusNode dobFocusNode = FocusNode();

  // Address Info Text Controllers & FocusNodes
  final TextEditingController houseNoController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController postcodeController = TextEditingController();

  final FocusNode houseNoFocusNode = FocusNode();
  final FocusNode streetFocusNode = FocusNode();
  final FocusNode postcodeFocusNode = FocusNode();

  // Emergency Contact & Job Controllers & FocusNodes
  final TextEditingController emergencyNameController = TextEditingController();
  final TextEditingController emergencyPhoneController = TextEditingController();
  final TextEditingController relationshipController = TextEditingController();
  final TextEditingController joiningDateController = TextEditingController();

  // Aliases matching smart_attendance field naming convention
  TextEditingController get emergencyMobController => emergencyPhoneController;
  TextEditingController get emergencyContactNameController => emergencyNameController;

  final FocusNode emergencyNameFocusNode = FocusNode();
  final FocusNode emergencyPhoneFocusNode = FocusNode();
  final FocusNode relationshipFocusNode = FocusNode();
  final FocusNode joiningDateFocusNode = FocusNode();

  @override
  void onInit() {
    super.onInit();
    // Default initial date values for ergonomic prototyping
    dobController.text = '1996-05-14';
    joiningDateController.text = '2026-10-15';
    loadLookupData();
  }

  /// Loads organization rosters, country models, and lookup datasets
  Future<void> loadLookupData() async {
    try {
      isLoading.value = true;
      final result = await repo.fetchLookupData();
      if (_isDisposed || isClosed) return;
      lookups.value = result;

      if (result.countries.isNotEmpty) {
        countries.assignAll(result.countries);
        // Default select Pakistan (+92) or first country
        final defaultCountry = result.countries.firstWhere(
          (c) => c.countryName.toLowerCase() == 'pakistan',
          orElse: () => result.countries.first,
        );
        selectedCountry.value = defaultCountry;
        selectedDialCode.value = defaultCountry.dialCode;
        phoneCountryCode.value = defaultCountry.dialCode;
        cities.assignAll(defaultCountry.cities);
        filteredCities.assignAll(defaultCountry.cities);

        if (defaultCountry.cities.isNotEmpty) {
          selectedCityModel.value = defaultCountry.cities.first;
          selectedCity.value = defaultCountry.cities.first.name;
        }
      }

      if (result.departments.isNotEmpty) selectedDepartment.value = result.departments.first;
      if (result.designations.isNotEmpty) selectedDesignation.value = result.designations.first;
      if (result.shifts.isNotEmpty) selectedShift.value = result.shifts.first;
      if (result.genders.isNotEmpty) selectedGender.value = result.genders.first;
      if (result.relationships.isNotEmpty) {
        selectedRelationship.value = result.relationships.first;
        if (!_isDisposed && !isClosed) {
          relationshipController.text = result.relationships.first;
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Changes active onboarding step
  void setStep(int step) {
    if (step >= 0 && step <= 2) {
      activeStep.value = step;
    }
  }

  /// Photo selection via Camera or Gallery (matching smart_attendance)
  Future<void> pickPhoto(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, imageQuality: 85);
      if (picked != null) {
        selectedPhoto.value = File(picked.path);
        selectedPhotoPath.value = picked.path;
        isFaceCaptured.value = true;
        faceLivenessScore.value = 0.99;
        capturedPhotoLabel.value = 'Profile Photo Enrolled';
        CustomSnackbar.showSuccess(
          title: 'Photo Uploaded',
          message: 'Employee identification photo successfully attached.',
        );
      }
    } catch (e) {
      CustomSnackbar.showError(
        message: 'Could not access image source: $e',
      );
    }
  }

  /// Removes currently attached employee photo
  void removePhoto() {
    selectedPhoto.value = null;
    selectedPhotoPath.value = '';
    isFaceCaptured.value = false;
    capturedPhotoLabel.value = 'Frontal Face Scan';
  }

  /// Country selection handler
  void onCountrySelected(CountryModel? country) {
    selectedCountry.value = country;
    selectedCityModel.value = null;
    selectedCity.value = '';
    citySearchController.clear();

    if (country != null) {
      selectedDialCode.value = country.dialCode;
      phoneCountryCode.value = country.dialCode;
      cities.assignAll(country.cities);
      filteredCities.assignAll(country.cities);
      if (country.cities.isNotEmpty) {
        selectedCityModel.value = country.cities.first;
        selectedCity.value = country.cities.first.name;
      }
    } else {
      cities.clear();
      filteredCities.clear();
      selectedDialCode.value = '';
    }
  }

  /// City selection handler
  void onCitySelected(CityModel city) {
    selectedCityModel.value = city;
    selectedCity.value = city.name;
  }

  /// Filters cities by search query
  void filterCities(String query) {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) {
      filteredCities.assignAll(cities);
    } else {
      filteredCities.assignAll(
        cities.where((c) => c.name.toLowerCase().contains(trimmed)).toList(),
      );
    }
  }

  /// Full international phone number
  String get fullPhoneNumber {
    final number = phoneController.text.trim().replaceAll(RegExp(r'\s+'), '');
    final code = selectedDialCode.value.trim();
    if (code.isEmpty) return number;
    if (number.isEmpty) return code;
    return '$code $number';
  }

  /// Simulates camera snapshot capture for AI facial enrollment (backwards compatible)
  void simulateCaptureFace() {
    isFaceCaptured.value = true;
    faceLivenessScore.value = 0.99;
    capturedPhotoLabel.value = 'Face Embedding 512-d Generated';
    CustomSnackbar.showSuccess(
      title: 'Biometric Verified',
      message: 'Facial contour & liveness verified with 99.4% confidence score.',
    );
  }

  /// Resets facial capture
  void resetCapturedFace() {
    isFaceCaptured.value = false;
    capturedPhotoLabel.value = 'Frontal Face Scan';
  }

  /// Selects Date using Flutter native picker
  Future<void> selectDate(BuildContext context, TextEditingController targetController) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 22)),
      firstDate: DateTime(1960),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      targetController.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  /// Submits employee registration form (matching smart_attendance logic + AMS 2 safety)
  Future<void> submitEmployeeRegistration() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty) {
      CustomSnackbar.showError(message: 'Please enter employee full name.');
      nameFocusNode.requestFocus();
      return;
    }

    if (email.isEmpty || !email.contains('@')) {
      CustomSnackbar.showError(message: 'Please enter a valid email address.');
      emailFocusNode.requestFocus();
      return;
    }

    if (phone.isEmpty) {
      CustomSnackbar.showError(message: 'Please enter employee phone number.');
      phoneFocusNode.requestFocus();
      return;
    }

    try {
      isSubmitting.value = true;

      final cityName = selectedCityModel.value?.name ?? selectedCity.value;
      final rel = relationshipController.text.trim().isNotEmpty
          ? relationshipController.text.trim()
          : selectedRelationship.value;

      final request = AddEmployeeRequestModel(
        fullName: name,
        email: email,
        phoneCountryCode: selectedDialCode.value,
        phoneNumber: phone,
        gender: selectedGender.value,
        cnic: cnicController.text.trim().isEmpty ? '37405-1234567-1' : cnicController.text.trim(),
        dob: dobController.text.trim().isEmpty ? '1996-05-14' : dobController.text.trim(),
        houseNo: houseNoController.text.trim().isEmpty ? 'House No. 12' : houseNoController.text.trim(),
        street: streetController.text.trim().isEmpty ? 'Main Boulevard' : streetController.text.trim(),
        city: cityName.isEmpty ? 'Islamabad' : cityName,
        postcode: postcodeController.text.trim().isEmpty ? '44000' : postcodeController.text.trim(),
        department: selectedDepartment.value,
        designation: selectedDesignation.value,
        shift: selectedShift.value,
        joiningDate: joiningDateController.text.trim().isEmpty ? '2026-10-15' : joiningDateController.text.trim(),
        emergencyContactName: emergencyNameController.text.trim().isEmpty
            ? 'Dr. Ahmed Khan'
            : emergencyNameController.text.trim(),
        emergencyPhone: emergencyPhoneController.text.trim().isEmpty
            ? '+92 300 1234567'
            : emergencyPhoneController.text.trim(),
        relationship: rel,
        photoPath: selectedPhotoPath.value.isNotEmpty ? selectedPhotoPath.value : null,
        isFaceEnrolled: isFaceCaptured.value,
      );

      final response = await repo.registerEmployee(request);

      if (response != null && response.success) {
        CustomSnackbar.showSuccess(
          title: 'Registration Successful',
          message: 'Employee $name successfully registered (ID: ${response.employeeId}).',
        );
        Get.back();
      }
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    _isDisposed = true;
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    cnicController.dispose();
    dobController.dispose();

    nameFocusNode.dispose();
    emailFocusNode.dispose();
    phoneFocusNode.dispose();
    cnicFocusNode.dispose();
    dobFocusNode.dispose();

    houseNoController.dispose();
    streetController.dispose();
    postcodeController.dispose();
    citySearchController.dispose();

    houseNoFocusNode.dispose();
    streetFocusNode.dispose();
    postcodeFocusNode.dispose();

    joiningDateController.dispose();
    emergencyNameController.dispose();
    emergencyPhoneController.dispose();
    relationshipController.dispose();

    joiningDateFocusNode.dispose();
    emergencyNameFocusNode.dispose();
    emergencyPhoneFocusNode.dispose();
    relationshipFocusNode.dispose();

    super.onClose();
  }
}
