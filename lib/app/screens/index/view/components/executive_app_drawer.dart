import 'package:ams_2/app/screens/main_shell/view/components/app_drawer.dart';
import 'package:flutter/material.dart';



/// Legacy alias for the executive navigation drawer delegating to AppDrawer
class ExecutiveAppDrawer extends StatelessWidget {
  const ExecutiveAppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppDrawer();
  }
}
