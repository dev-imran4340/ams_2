import 'package:get/get.dart';
import '../model/dashboard_model.dart';
import '../repo/dashboard_repo.dart';

class DashboardController extends GetxController {
  final DashboardRepo repo;

  DashboardController({required this.repo});

  final RxBool isLoading = false.obs;
  final Rxn<DashboardModel> dashboardData = Rxn<DashboardModel>();

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      isLoading.value = true;
      final result = await repo.fetchDashboard();
      if (result != null) {
        dashboardData.value = result;
      }
    } finally {
      isLoading.value = false;
    }
  }
}
