import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/custom_snackbar.dart';
import '../model/visitor_model.dart';
import '../repo/visitor_repo.dart';
import '../view/components/visitor_pass_dialog.dart';

class VisitorController extends GetxController {
  final VisitorRepo repo;

  VisitorController({required this.repo});

  // =========================================================================
  // Observables & State
  // =========================================================================

  // General Loading & Tab State
  final RxBool isLoading = false.obs;
  final RxInt selectedTab = 0.obs; // 0 = Entry, 1 = Exit
  final RxInt entryStep = 0.obs; // 0 = Camera, 1 = Details, 2 = Submit

  // --- Entry Flow Observables ---
  final RxBool isCameraActive = false.obs;
  final RxBool isCameraInitialized = false.obs;
  final RxBool isInitializingCamera = false.obs;
  final Rxn<String> capturedSelfie = Rxn<String>();
  final RxBool isSubmitting = false.obs;
  final RxList<HostEmployeeOption> hostEmployees = <HostEmployeeOption>[].obs;
  final Rxn<HostEmployeeOption> selectedHost = Rxn<HostEmployeeOption>();
  final Rxn<DateTime> selectedEntryDateTime = Rxn<DateTime>();
  final RxString selectedPurpose = 'Meeting'.obs;

  // --- Exit Flow Observables ---
  final RxList<VisitorModel> activeVisitors = <VisitorModel>[].obs;
  final Rxn<VisitorModel> selectedVisitor = Rxn<VisitorModel>();
  final RxnString preparingVisitorId = RxnString();
  final RxBool isLoadingVisitors = false.obs;
  final RxBool isSubmittingExit = false.obs;
  final Rxn<DateTime> selectedExitDateTime = Rxn<DateTime>();

  // --- Search & Purpose Choices ---
  final RxString searchQuery = ''.obs;
  final List<String> purposes = const [
    'Meeting',
    'Interview',
    'Delivery',
    'Guest',
    'Maintenance',
  ];

  // =========================================================================
  // Form Controllers & Focus Nodes
  // =========================================================================

  // Entry Form Controllers
  final GlobalKey<FormState> entryFormKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController cnicController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();

  // Exit Form Controllers
  final TextEditingController exitTimeController = TextEditingController();
  final TextEditingController exitRemarksController = TextEditingController();

  // Search Controller
  final TextEditingController searchController = TextEditingController();

  // Focus Nodes
  final FocusNode nameFocusNode = FocusNode();
  final FocusNode cnicFocusNode = FocusNode();
  final FocusNode phoneFocusNode = FocusNode();
  final FocusNode searchFocusNode = FocusNode();

  // Backward compatibility alias
  GlobalKey<FormState> get formKey => entryFormKey;
  bool get hasCapturedPhoto => capturedSelfie.value != null;

  // =========================================================================
  // Lifecycle
  // =========================================================================

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      searchQuery.value = searchController.text.trim().toLowerCase();
    });
    _initializeDefaultTimes();
    loadData();
  }

  void _initializeDefaultTimes() {
    final now = DateTime.now();
    selectedEntryDateTime.value = now;
    startTimeController.text = formatDateTimeForDisplay(now);

    selectedExitDateTime.value = now;
    exitTimeController.text = formatDateTimeForDisplay(now);
  }

  /// Initial load for active visitors & company staff
  Future<void> loadData() async {
    try {
      isLoading.value = true;
      isLoadingVisitors.value = true;
      final results = await Future.wait([
        repo.fetchActiveVisitors(),
        repo.fetchHostEmployees(),
      ]);

      activeVisitors.assignAll(results[0] as List<VisitorModel>);
      final hosts = results[1] as List<HostEmployeeOption>;
      hostEmployees.assignAll(hosts);

      if (hosts.isNotEmpty && selectedHost.value == null) {
        selectedHost.value = hosts.first;
      }
    } finally {
      isLoading.value = false;
      isLoadingVisitors.value = false;
    }
  }

  /// Refreshes active visitors list for the Exit screen
  Future<void> loadActiveVisitors() async {
    try {
      isLoadingVisitors.value = true;
      final list = await repo.fetchActiveVisitors();
      activeVisitors.assignAll(list);
    } finally {
      isLoadingVisitors.value = false;
    }
  }

  // =========================================================================
  // Entry Flow Methods
  // =========================================================================

  /// Starts simulated biometric camera viewfinder
  Future<void> startCamera() async {
    try {
      isInitializingCamera.value = true;
      await Future.delayed(const Duration(milliseconds: 350));
      isCameraActive.value = true;
      isCameraInitialized.value = true;
    } finally {
      isInitializingCamera.value = false;
    }
  }

  /// Stops camera preview
  void stopCamera() {
    isCameraActive.value = false;
    isCameraInitialized.value = false;
  }

  /// Simulates biometric camera selfie capture for kiosk pass
  void capturePhoto() {
    HapticFeedback.mediumImpact();
    capturedSelfie.value =
        'captured_visitor_selfie_${DateTime.now().millisecondsSinceEpoch}';
    isCameraActive.value = false;
    isCameraInitialized.value = false;
    entryStep.value = 1;

    CustomSnackbar.showSuccess(
      title: 'Biometric Intake Completed',
      message: 'Photo captured successfully. Please complete guest details.',
    );
  }

  /// Clears photo and restarts camera capture step
  Future<void> retakePhoto() async {
    HapticFeedback.lightImpact();
    capturedSelfie.value = null;
    entryStep.value = 0;
    await startCamera();
  }

  /// Date & time picker for visitor entry check-in time
  Future<void> selectEntryDateTime() async {
    final context = Get.context;
    if (context == null) return;

    final DateTime currentLocal = DateTime.now();
    final DateTime initialDate = selectedEntryDateTime.value ?? currentLocal;

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: currentLocal.subtract(const Duration(days: 30)),
      lastDate: currentLocal.add(const Duration(days: 30)),
    );

    if (pickedDate == null || !context.mounted) return;

    final TimeOfDay initialTime = TimeOfDay.fromDateTime(
      selectedEntryDateTime.value ?? currentLocal,
    );

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime == null) return;

    final DateTime selected = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    selectedEntryDateTime.value = selected;
    startTimeController.text = formatDateTimeForDisplay(selected);
  }

  /// Submits visitor check-in intake and displays official badge pass
  Future<void> submitEntry() async {
    if (isSubmitting.value) return;

    if (capturedSelfie.value == null) {
      CustomSnackbar.showWarning(
        title: 'Photo Required',
        message: 'Please capture guest photo before generating check-in pass.',
      );
      entryStep.value = 0;
      return;
    }

    try {
      isSubmitting.value = true;
      HapticFeedback.lightImpact();

      final data = {
        'full_name': nameController.text.trim().isNotEmpty
            ? nameController.text.trim()
            : 'Guest Visitor',
        'cnic': cnicController.text.trim(),
        'phone': phoneController.text.trim(),
        'purpose': selectedPurpose.value,
        'host_employee':
            selectedHost.value?.displayName ?? 'Front Desk Reception',
        'photo_path': capturedSelfie.value,
        'check_in_time':
            selectedEntryDateTime.value?.toIso8601String() ??
            DateTime.now().toIso8601String(),
        'remarks': remarksController.text.trim(),
      };

      final newVisitor = await repo.submitVisitorEntry(data);
      if (newVisitor != null) {
        activeVisitors.insert(0, newVisitor);

        // Show Official Badge Pass Dialog
        Get.dialog(
          VisitorPassDialog(visitor: newVisitor),
          barrierDismissible: false,
        );

        // Reset Entry Form
        _resetEntryForm();
      }
    } finally {
      isSubmitting.value = false;
    }
  }

  void _resetEntryForm() {
    nameController.clear();
    cnicController.clear();
    phoneController.clear();
    remarksController.clear();
    capturedSelfie.value = null;
    selectedPurpose.value = 'Meeting';
    entryStep.value = 0;
    _initializeDefaultTimes();
  }

  // =========================================================================
  // Exit Flow Methods
  // =========================================================================

  /// Selects a visitor and triggers face verification simulation
  Future<void> startVisitorFaceVerification(VisitorModel visitor) async {
    if (preparingVisitorId.value != null) return;

    try {
      preparingVisitorId.value = visitor.id;
      HapticFeedback.selectionClick();

      // Simulate AI facial verification match latency
      await Future.delayed(const Duration(milliseconds: 1000));

      selectedVisitor.value = visitor;
      final now = DateTime.now();
      selectedExitDateTime.value = now;
      exitTimeController.text = formatDateTimeForDisplay(now);

      HapticFeedback.mediumImpact();
      CustomSnackbar.showSuccess(
        title: 'Face Verified',
        message: 'Identity confirmed for ${visitor.fullName}.',
      );
    } finally {
      preparingVisitorId.value = null;
    }
  }

  /// Date & time picker for visitor departure exit time
  Future<void> selectExitDateTime() async {
    final context = Get.context;
    if (context == null) return;

    final DateTime currentLocal = DateTime.now();
    final DateTime initialDate = selectedExitDateTime.value ?? currentLocal;

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: currentLocal.subtract(const Duration(days: 30)),
      lastDate: currentLocal.add(const Duration(days: 30)),
    );

    if (pickedDate == null || !context.mounted) return;

    final TimeOfDay initialTime = TimeOfDay.fromDateTime(
      selectedExitDateTime.value ?? currentLocal,
    );

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime == null) return;

    final DateTime selected = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    selectedExitDateTime.value = selected;
    exitTimeController.text = formatDateTimeForDisplay(selected);
  }

  /// Processes visitor checkout departure
  Future<void> submitExit() async {
    final visitor = selectedVisitor.value;
    if (visitor == null || isSubmittingExit.value) return;

    try {
      isSubmittingExit.value = true;
      HapticFeedback.mediumImpact();

      final success = await repo.markVisitorExit(visitor.id);
      if (success) {
        activeVisitors.removeWhere((element) => element.id == visitor.id);
        CustomSnackbar.showSuccess(
          title: 'Departure Recorded',
          message:
              '${visitor.fullName} (${visitor.id}) checked out successfully.',
        );
        selectedVisitor.value = null;
        exitRemarksController.clear();
      }
    } finally {
      isSubmittingExit.value = false;
    }
  }

  // =========================================================================
  // Helpers & Search Filter
  // =========================================================================

  /// Real-time search filter for active on-site visitors
  List<VisitorModel> get filteredVisitors {
    final query = searchQuery.value;
    if (query.isEmpty) {
      return activeVisitors;
    }
    return activeVisitors.where((visitor) {
      final nameMatch = visitor.fullName.toLowerCase().contains(query);
      final idMatch = visitor.id.toLowerCase().contains(query);
      final cnicMatch = visitor.cnic.toLowerCase().contains(query);
      final phoneMatch = visitor.phone.toLowerCase().contains(query);
      final hostMatch = visitor.hostEmployee.toLowerCase().contains(query);
      return nameMatch || idMatch || cnicMatch || phoneMatch || hostMatch;
    }).toList();
  }

  /// Formats date and time into corporate readable string e.g. "15 Oct 2026, 02:45 PM"
  String formatDateTimeForDisplay(DateTime dt) {
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
      'Dec',
    ];
    final day = dt.day.toString().padLeft(2, '0');
    final month = months[dt.month - 1];
    final year = dt.year;
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$day $month $year, $hour:$minute $period';
  }

  /// Formats time only e.g. "02:45 PM"
  String formatTimeOnly(DateTime dt) {
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  // Backward compatibility alias for modal checkout
  void markExit(VisitorModel visitor) {
    startVisitorFaceVerification(visitor);
  }

  void switchTab(int index) {
    selectedTab.value = index;
  }

  @override
  void onClose() {
    nameController.dispose();
    cnicController.dispose();
    phoneController.dispose();
    startTimeController.dispose();
    remarksController.dispose();
    exitTimeController.dispose();
    exitRemarksController.dispose();
    searchController.dispose();

    nameFocusNode.dispose();
    cnicFocusNode.dispose();
    phoneFocusNode.dispose();
    searchFocusNode.dispose();

    super.onClose();
  }
}
