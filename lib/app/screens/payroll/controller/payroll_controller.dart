import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';

import '../../../api/exception_handler.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../main_shell/controller/session_me_controller.dart';
import '../model/payroll_model.dart';
import '../repo/payroll_repo.dart';

class PayrollController extends GetxController {
  final PayrollRepo repo;

  PayrollController({required this.repo});

  // Module & Permission State
  final RxBool isPayrollModuleActive = true.obs;
  final RxBool isAccessRestricted = false.obs;
  final RxString accessRestrictedMessage = ''.obs;

  // View States
  final RxBool isLoading = false.obs;
  final RxBool isDetailsLoading = false.obs;
  final RxBool isDownloadingPdf = false.obs;
  final RxInt selectedTabIndex = 0.obs; // 0 = Payslips, 1 = Salary Structure

  // Data Observables
  final RxList<PayslipSummaryModel> payslips = <PayslipSummaryModel>[].obs;
  final Rxn<PayslipDetailsModel> selectedPayslip = Rxn<PayslipDetailsModel>();
  final Rxn<SalaryStructureModel> salaryStructure = Rxn<SalaryStructureModel>();

  // Scroll controllers for clean resource management
  final ScrollController payslipsScrollController = ScrollController();
  final ScrollController salaryScrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    _checkModuleGate();
    loadPayrollData();
  }

  @override
  void onClose() {
    payslipsScrollController.dispose();
    salaryScrollController.dispose();
    super.onClose();
  }

  /// Verifies active payroll subscription module and pay.view permission before triggering requests
  void _checkModuleGate() {
    if (Get.isRegistered<SessionMeController>()) {
      final session = Get.find<SessionMeController>();
      final hasModule = session.hasModule('payroll');
      final hasPermission = session.hasPermission('pay.view');
      isPayrollModuleActive.value = hasModule && hasPermission;
      if (!isPayrollModuleActive.value) {
        isAccessRestricted.value = true;
        accessRestrictedMessage.value = !hasModule
            ? 'Payroll module is not included in your company subscription.'
            : 'You do not have permission to access Payroll & Payslips.';
      }
    }
  }

  /// Refreshes all payroll records (Payslips list + Active salary structure)
  Future<void> loadPayrollData() async {
    _checkModuleGate();
    if (!isPayrollModuleActive.value) {
      return;
    }

    try {
      isLoading.value = true;
      isAccessRestricted.value = false;
      accessRestrictedMessage.value = '';

      // Concurrent fetch for optimum response latency
      final results = await Future.wait([
        repo.fetchPayslips(),
        repo.fetchActiveSalary(),
      ]);

      payslips.assignAll(results[0] as List<PayslipSummaryModel>);
      salaryStructure.value = results[1] as SalaryStructureModel?;
    } on ApiException catch (e) {
      if (e.statusCode == 403) {
        isAccessRestricted.value = true;
        accessRestrictedMessage.value = e.message.isNotEmpty
            ? e.message
            : 'You do not have permission to access Payroll & Payslips.';
      }
    } catch (_) {
      // Handled cleanly via empty or error state view without crashing
    } finally {
      isLoading.value = false;
    }
  }

  /// Tab switcher for the segmented view
  void switchTab(int index) {
    if (selectedTabIndex.value == index) return;
    selectedTabIndex.value = index;
  }

  /// Fetches itemized audit breakdown for a given payslip ULID
  Future<PayslipDetailsModel?> fetchDetails(String id) async {
    try {
      isDetailsLoading.value = true;
      final details = await repo.fetchPayslipDetails(id);
      selectedPayslip.value = details;
      return details;
    } finally {
      isDetailsLoading.value = false;
    }
  }

  /// Downloads and immediately opens the official payslip PDF
  Future<void> downloadAndOpenPdf(String id, {String? periodLabel}) async {
    try {
      isDownloadingPdf.value = true;
      final file = await repo.downloadPayslipPdf(id, periodLabel: periodLabel);
      if (file != null && await file.exists()) {
        final result = await OpenFilex.open(file.path);
        if (result.type != ResultType.done) {
          CustomSnackbar.showInfo(
            message: 'Payslip saved to ${file.path.split('/').last}',
          );
        }
      } else {
        CustomSnackbar.showError(
          message: 'Unable to download payslip PDF. Please try again.',
        );
      }
    } catch (e) {
      CustomSnackbar.showError(
        message: 'Could not open payslip PDF.',
      );
    } finally {
      isDownloadingPdf.value = false;
    }
  }
}
