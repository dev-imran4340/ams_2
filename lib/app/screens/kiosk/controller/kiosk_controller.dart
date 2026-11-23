import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../api/app_preferences.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../model/kiosk_model.dart';
import '../repo/kiosk_repo.dart';

class KioskController extends GetxController {
  final KioskRepo repo;

  KioskController({required this.repo});

  // Loading & State Observables
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isPinConfigured = false.obs;
  final RxBool isKioskProvisioned = false.obs;
  final Rxn<KioskConfigModel> activeKioskConfig = Rxn<KioskConfigModel>();
  final RxString selectedTab = 'pin'.obs; // 'pin' or 'terminal'

  final ScrollController scrollController = ScrollController();

  // Permission Check: only admins have kiosks.manage
  bool get canManageKiosks => AppPreferences.hasPermission('kiosks.manage');

  // PIN Setup Form Controllers
  final GlobalKey<FormState> pinFormKey = GlobalKey<FormState>();
  final TextEditingController pinController = TextEditingController();
  final TextEditingController confirmPinController = TextEditingController();
  final FocusNode pinFocusNode = FocusNode();
  final FocusNode confirmPinFocusNode = FocusNode();
  final RxBool isPinObscured = true.obs;
  final RxBool isConfirmPinObscured = true.obs;

  // Provisioning Form Controllers
  final GlobalKey<FormState> provisionFormKey = GlobalKey<FormState>();
  final TextEditingController kioskNameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final FocusNode kioskNameFocusNode = FocusNode();
  final FocusNode locationFocusNode = FocusNode();
  final RxBool replaceExisting = false.obs;

  // Kiosk Terminal Clock-In Session
  final GlobalKey<FormState> clockInFormKey = GlobalKey<FormState>();
  final TextEditingController empNumController = TextEditingController();
  final TextEditingController terminalPinController = TextEditingController();
  final FocusNode empNumFocusNode = FocusNode();
  final FocusNode terminalPinFocusNode = FocusNode();
  final Rxn<KioskIdentifyResponseModel> identifiedSession = Rxn<KioskIdentifyResponseModel>();

  @override
  void onInit() {
    super.onInit();
    isPinConfigured.value = AppPreferences.isKioskPinConfigured;
    isKioskProvisioned.value = AppPreferences.isKioskProvisioned;
    loadKioskState();
  }

  @override
  void onClose() {
    pinController.dispose();
    confirmPinController.dispose();
    pinFocusNode.dispose();
    confirmPinFocusNode.dispose();

    kioskNameController.dispose();
    locationController.dispose();
    kioskNameFocusNode.dispose();
    locationFocusNode.dispose();

    empNumController.dispose();
    terminalPinController.dispose();
    empNumFocusNode.dispose();
    terminalPinFocusNode.dispose();
    scrollController.dispose();

    super.onClose();
  }

  /// Initial load of active kiosk config (only if already provisioned with a token)
  Future<void> loadKioskState() async {
    try {
      isLoading.value = true;
      if (AppPreferences.isKioskProvisioned) {
        final config = await repo.fetchKioskConfig();
        if (config != null) {
          activeKioskConfig.value = config;
          isKioskProvisioned.value = true;
        } else {
          isKioskProvisioned.value = AppPreferences.isKioskProvisioned;
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  // -------------------------------------------------------------
  // 1. PIN CONFIGURATION (PUT /me/kiosk-pin)
  // -------------------------------------------------------------

  String? validatePin(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter 4-6 digit numeric PIN';
    }
    final clean = value.trim();
    if (clean.length < 4 || clean.length > 6) {
      return 'PIN must be between 4 and 6 digits';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(clean)) {
      return 'PIN must contain only numbers';
    }
    // Prohibit identical digits (e.g. 1111)
    if (RegExp(r'^(\d)\1+$').hasMatch(clean)) {
      return 'PIN cannot be all identical digits';
    }
    // Prohibit sequential digits (e.g. 1234, 4321)
    const seqAsc = '0123456789';
    const seqDesc = '9876543210';
    if (seqAsc.contains(clean) || seqDesc.contains(clean)) {
      return 'PIN cannot be sequential digits (e.g. 1234)';
    }
    return null;
  }

  String? validateConfirmPin(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please confirm your kiosk PIN';
    }
    if (value.trim() != pinController.text.trim()) {
      return 'PIN confirmation does not match';
    }
    return null;
  }

  Future<void> submitKioskPin() async {
    HapticFeedback.lightImpact();

    if (!pinFormKey.currentState!.validate()) {
      final pinErr = validatePin(pinController.text);
      if (pinErr != null) {
        pinFocusNode.requestFocus();
      } else {
        confirmPinFocusNode.requestFocus();
      }
      return;
    }

    try {
      isSubmitting.value = true;
      final success = await repo.setKioskPin(
        pin: pinController.text.trim(),
        pinConfirmation: confirmPinController.text.trim(),
      );

      if (success) {
        isPinConfigured.value = true;
        pinController.clear();
        confirmPinController.clear();
        CustomSnackbar.showSuccess(
          title: 'PIN Configured',
          message: 'Your self-service kiosk backup PIN has been updated successfully.',
        );
      }
    } finally {
      isSubmitting.value = false;
    }
  }

  // -------------------------------------------------------------
  // 2. KIOSK PROVISIONING (POST /kiosks)
  // -------------------------------------------------------------

  Future<void> provisionTabletKiosk() async {
    HapticFeedback.lightImpact();

    if (!provisionFormKey.currentState!.validate()) {
      if (kioskNameController.text.trim().isEmpty) {
        kioskNameFocusNode.requestFocus();
      } else {
        locationFocusNode.requestFocus();
      }
      return;
    }

    try {
      isSubmitting.value = true;
      final config = await repo.provisionKiosk(
        name: kioskNameController.text.trim(),
        location: locationController.text.trim(),
        replace: replaceExisting.value,
      );

      if (config != null) {
        activeKioskConfig.value = config;
        isKioskProvisioned.value = true;
        kioskNameController.clear();
        locationController.clear();
        CustomSnackbar.showSuccess(
          title: 'Tablet Provisioned',
          message: 'This device is now active as an enterprise kiosk terminal.',
        );
      }
    } finally {
      isSubmitting.value = false;
    }
  }

  // -------------------------------------------------------------
  // 3. IDENTIFY & CLOCK IN (POST /kiosk/identify & /kiosk/punches)
  // -------------------------------------------------------------

  Future<void> identifyEmployeeAtKiosk() async {
    HapticFeedback.lightImpact();

    if (!clockInFormKey.currentState!.validate()) {
      if (empNumController.text.trim().isEmpty) {
        empNumFocusNode.requestFocus();
      } else {
        terminalPinFocusNode.requestFocus();
      }
      return;
    }

    try {
      isSubmitting.value = true;
      final session = await repo.identifyEmployee(
        employeeNumber: empNumController.text.trim(),
        pin: terminalPinController.text.trim(),
      );

      if (session != null) {
        identifiedSession.value = session;
        if (session.requiresFace == 'match' && session.faceSaved) {
          await repo.fetchKioskFace(ticket: session.ticket);
        }
      }
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Identifies employee by scanning RFID / QR badge
  Future<void> identifyViaBadge(String badge) async {
    HapticFeedback.lightImpact();
    try {
      isSubmitting.value = true;
      final session = await repo.identifyEmployee(badge: badge);
      if (session != null) {
        identifiedSession.value = session;
        if (session.requiresFace == 'match' && session.faceSaved) {
          await repo.fetchKioskFace(ticket: session.ticket);
        }
      }
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> punchAttendanceAction(String kind) async {
    final session = identifiedSession.value;
    if (session == null) return;

    try {
      isSubmitting.value = true;
      final idempotencyKey =
          'kiosk_${DateTime.now().millisecondsSinceEpoch}_${session.person.id.substring(0, 8)}';
      final result = await repo.submitKioskPunch(
        ticket: session.ticket,
        kind: kind,
        idempotencyKey: idempotencyKey,
      );

      if (result != null) {
        identifiedSession.value = null;
        empNumController.clear();
        terminalPinController.clear();
        CustomSnackbar.showSuccess(
          title: 'Punch Recorded',
          message: 'Attendance punch successfully logged for ${session.person.name}.',
        );
      }
    } finally {
      isSubmitting.value = false;
    }
  }

  /// De-provisions the tablet kiosk
  Future<void> deProvisionKiosk() async {
    await AppPreferences.clearKioskToken();
    isKioskProvisioned.value = false;
    activeKioskConfig.value = null;
    identifiedSession.value = null;
    CustomSnackbar.showWarning(
      title: 'Kiosk Reset',
      message: 'Tablet terminal credentials have been cleared.',
    );
  }
}
