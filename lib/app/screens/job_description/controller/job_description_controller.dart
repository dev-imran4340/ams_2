import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/widgets/custom_snackbar.dart';
import '../model/job_description_model.dart';
import '../repo/job_description_repo.dart';

class JobDescriptionController extends GetxController {
  final JobDescriptionRepo repo;
  JobDescriptionController({required this.repo});

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<JobDescriptionModel?> jobDescription = Rx<JobDescriptionModel?>(null);

  @override
  void onInit() {
    super.onInit();
    loadJobDescription();
  }

  Future<void> loadJobDescription() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final result = await repo.fetchJobDescription();
      jobDescription.value = result;
    } catch (e) {
      errorMessage.value = 'Failed to load job description. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> openAttachedFile(String? url) async {
    if (url == null || url.trim().isEmpty) {
      CustomSnackbar.showWarning(
        title: 'Unavailable',
        message: 'No official attachment file is linked to this job description.',
      );
      return;
    }

    try {
      final uri = Uri.parse(url.trim());
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        CustomSnackbar.showError(
          title: 'Error',
          message: 'Could not open the document URL.',
        );
      }
    } catch (e) {
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Invalid document URL.',
      );
    }
  }
}
