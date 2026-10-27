import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/custom_state_view.dart';
import '../../controller/profile_controller.dart';

class ProfileHistoryTab extends GetView<ProfileController> {
  const ProfileHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomStateView.empty(
      title: 'No History Records',
      message: 'No employment history records are available for this profile.',
    );
  }
}
