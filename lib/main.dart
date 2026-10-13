import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'app/api/app_preferences.dart';
import 'app/routes/app_pages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetStorage persistence
  await AppPreferences.init();

  // Initialize ThemeController permanently for dynamic theme switching
  // Get.put(ThemeController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // final themeController = Get.find<ThemeController>();

    return ScreenUtilInit(
      designSize: const Size(375, 812), // Standard mobile reference frame
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        // return Obx(() {
          return GetMaterialApp(
            title: 'AMS 2',
            debugShowCheckedModeBanner: false,
            // theme: AppTheme.lightTheme,
            // darkTheme: AppTheme.darkTheme,
            // themeMode: themeController.isDarkMode.value
            //     ? ThemeMode.light
            //     : ThemeMode.light,
            initialRoute: AppPages.INITIAL,
            getPages: AppPages.routes,
          );
        // });
      },
    );
  }
}
