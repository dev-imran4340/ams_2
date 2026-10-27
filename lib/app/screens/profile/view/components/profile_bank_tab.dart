import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/custom_state_view.dart';
import '../../controller/profile_controller.dart';

class ProfileBankTab extends GetView<ProfileController> {
  const ProfileBankTab({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomStateView.empty(
      title: 'No Bank Details',
      message: 'Bank disbursal details have not been provided for this profile.',
    );
  }
}
