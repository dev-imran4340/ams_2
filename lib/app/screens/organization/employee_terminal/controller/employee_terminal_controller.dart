import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../api/app_preferences.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../model/employee_terminal_model.dart';
import '../model/kiosk_model.dart';
import '../repo/employee_terminal_repo.dart';

class EmployeeTerminalController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final EmployeeTerminalRepo repo;

  EmployeeTerminalController({required this.repo});

  // Mode & State Observables
  final RxInt activeScannerMode = 0.obs; // 0 = Face Biometric, 1 = Card QR Scanner
  final RxBool isLoading = false.obs;
  final RxBool isPunchProcessing = false.obs;
  final RxBool showSuccessBadge = false.obs;
  final RxString kioskStatusMessage = 'Center face within the oval guide...'.obs;

  // Active Kiosk Configuration Observable
  final Rxn<KioskConfigModel> kioskConfig = Rxn<KioskConfigModel>();
  final RxBool isKioskConfigured = false.obs;

  // Data Observables
  final Rxn<PunchRecordItem> lastPunchedEmployee = Rxn<PunchRecordItem>();
  final Rxn<TerminalTelemetryModel> telemetry = Rxn<TerminalTelemetryModel>();
  final RxList<PunchRecordItem> recentPunches = <PunchRecordItem>[].obs;

  // Animation controller for continuous radar rings & laser sweep
  late AnimationController pulseController;
  late Animation<double> pulseAnimation;

  Timer? _autoResetTimer;

  @override
  void onInit() {
    super.onInit();
    _initAnimations();
    loadInitialData();
  }

  void _initAnimations() {
    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    pulseAnimation = Tween<double>(begin: 0.96, end: 1.08).animate(
      CurvedAnimation(parent: pulseController, curve: Curves.easeInOut),
    );
  }

  /// Initial load of active kiosk configuration, terminal telemetry counters, and recent activity log
  Future<void> loadInitialData() async {
    try {
      isLoading.value = true;

      // 1. Fetch active kiosk configuration
      final config = await repo.fetchKioskConfig();
      if (config != null) {
        kioskConfig.value = config;
        isKioskConfigured.value = true;
      } else {
        isKioskConfigured.value = AppPreferences.isKioskProvisioned;
      }

      // 2. Load telemetry & recent punch history
      final results = await Future.wait([
        repo.fetchTerminalTelemetry(),
        repo.fetchRecentPunches(),
      ]);

      telemetry.value = results[0] as TerminalTelemetryModel;
      recentPunches.assignAll(results[1] as List<PunchRecordItem>);
    } finally {
      isLoading.value = false;
    }
  }

  /// Toggles between AI Face Biometric and Card QR Scanner mode
  void switchScannerMode(int mode) {
    if (activeScannerMode.value == mode) return;
    HapticFeedback.lightImpact();
    activeScannerMode.value = mode;

    if (mode == 0) {
      kioskStatusMessage.value = 'Center face within the oval guide...';
    } else {
      kioskStatusMessage.value = 'Present Employee ID Card QR to camera...';
    }
  }

  /// Provisions this tablet as a kiosk terminal (POST /kiosks)
  Future<bool> provisionKioskTerminal({
    required String name,
    required String location,
    bool replace = false,
  }) async {
    try {
      isLoading.value = true;
      final config = await repo.provisionKiosk(
        name: name,
        location: location,
        replace: replace,
      );

      if (config != null) {
        kioskConfig.value = config;
        isKioskConfigured.value = true;
        CustomSnackbar.showSuccess(
          message: 'Kiosk "${config.name}" successfully provisioned.',
        );
        return true;
      }
    } finally {
      isLoading.value = false;
    }
    return false;
  }

  /// Handles hardware/camera QR barcode decoding and executes attendance punch
  Future<void> handleQrScanned(String rawQr) async {
    if (isPunchProcessing.value || showSuccessBadge.value) return;

    try {
      isPunchProcessing.value = true;
      kioskStatusMessage.value = 'Identifying employee via QR card...';
      HapticFeedback.selectionClick();

      // Step 1: POST /kiosk/identify
      final identifyResult = await repo.identifyEmployee(badge: rawQr);

      if (identifyResult != null) {
        kioskStatusMessage.value = 'Employee identified: ${identifyResult.person.name}. Logging punch...';

        // Step 2: Determine allowed punch kind
        final kind = identifyResult.allowedActions.isNotEmpty
            ? identifyResult.allowedActions.first
            : 'in';

        // Step 3: POST /kiosk/punches
        final idempotencyKey = 'kiosk_${DateTime.now().millisecondsSinceEpoch}_${identifyResult.person.id.substring(0, 8)}';
        final punchResult = await repo.submitKioskPunch(
          ticket: identifyResult.ticket,
          kind: kind,
          idempotencyKey: idempotencyKey,
        );

        if (punchResult != null) {
          final punchRecord = PunchRecordItem(
            id: punchResult.punchId,
            employeeId: identifyResult.person.employeeNumber,
            employeeName: identifyResult.person.name,
            department: identifyResult.person.department ?? 'Operations',
            punchType: kind == 'in' ? 'Check-In' : (kind == 'out' ? 'Check-Out' : kind),
            punchTime: DateTime.now(),
            matchConfidence: 99.8,
          );
          _triggerSuccessPunch(punchRecord);
        }
      } else {
        // Fallback for simulation / testing when offline or mocked
        final punch = await repo.processBiometricMatch(mockVectorOrQr: rawQr);
        if (punch != null) {
          _triggerSuccessPunch(punch);
        }
      }
    } finally {
      isPunchProcessing.value = false;
    }
  }

  /// Fallback clock-in using Employee Number and Kiosk Backup PIN
  Future<bool> clockInWithPin({
    required String employeeNumber,
    required String pin,
  }) async {
    if (isPunchProcessing.value || showSuccessBadge.value) return false;

    try {
      isPunchProcessing.value = true;
      kioskStatusMessage.value = 'Verifying employee credentials & PIN...';
      HapticFeedback.selectionClick();

      // Step 1: Identify via PIN fallback
      final identifyResult = await repo.identifyEmployee(
        employeeNumber: employeeNumber,
        pin: pin,
      );

      if (identifyResult != null) {
        final kind = identifyResult.allowedActions.isNotEmpty
            ? identifyResult.allowedActions.first
            : 'in';

        final idempotencyKey = 'kiosk_pin_${DateTime.now().millisecondsSinceEpoch}';

        // Step 2: Submit punch
        final punchResult = await repo.submitKioskPunch(
          ticket: identifyResult.ticket,
          kind: kind,
          idempotencyKey: idempotencyKey,
        );

        if (punchResult != null) {
          final punchRecord = PunchRecordItem(
            id: punchResult.punchId,
            employeeId: identifyResult.person.employeeNumber,
            employeeName: identifyResult.person.name,
            department: identifyResult.person.department ?? 'Operations',
            punchType: kind == 'in' ? 'Check-In' : (kind == 'out' ? 'Check-Out' : kind),
            punchTime: DateTime.now(),
            matchConfidence: 100.0,
          );
          _triggerSuccessPunch(punchRecord);
          return true;
        }
      } else {
        CustomSnackbar.showError(
          message: 'PIN clock-in failed. Please verify your Employee ID and PIN.',
        );
      }
    } finally {
      isPunchProcessing.value = false;
    }
    return false;
  }

  /// Simulates continuous 1:N AI facial recognition stream matching
  Future<void> simulateBiometricDetection() async {
    if (isPunchProcessing.value || showSuccessBadge.value) return;

    try {
      isPunchProcessing.value = true;
      kioskStatusMessage.value = 'Verifying face vector (1:N Match)...';
      HapticFeedback.selectionClick();

      final punch = await repo.processBiometricMatch(
        mockVectorOrQr: 'AI_FACE_VECTOR_TOKEN_MOCK',
      );

      if (punch != null) {
        _triggerSuccessPunch(punch);
      }
    } finally {
      isPunchProcessing.value = false;
    }
  }

  /// Displays animated success confirmation overlay and schedules automatic reset
  void _triggerSuccessPunch(PunchRecordItem punch) {
    HapticFeedback.heavyImpact();
    lastPunchedEmployee.value = punch;
    showSuccessBadge.value = true;
    recentPunches.insert(0, punch);

    // Update real-time telemetry counters
    if (telemetry.value != null) {
      final current = telemetry.value!;
      if (punch.isCheckIn) {
        telemetry.value = TerminalTelemetryModel(
          totalStaff: current.totalStaff,
          presentToday: current.presentToday + 1,
          absentToday: (current.absentToday - 1).clamp(0, 999),
          unmarked: (current.unmarked - 1).clamp(0, 999),
        );
      }
    }

    // Auto-reset kiosk after 2.5s for the next employee
    _autoResetTimer?.cancel();
    _autoResetTimer = Timer(const Duration(milliseconds: 2500), () {
      showSuccessBadge.value = false;
      lastPunchedEmployee.value = null;
      if (activeScannerMode.value == 0) {
        kioskStatusMessage.value = 'Center face within the oval guide...';
      } else {
        kioskStatusMessage.value = 'Present Employee ID Card QR to camera...';
      }
    });
  }

  @override
  void onClose() {
    _autoResetTimer?.cancel();
    pulseController.dispose();
    super.onClose();
  }
}
