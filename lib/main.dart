import 'package:ams_2/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'app/api/app_preferences.dart';
import 'app/services/push_notification_service.dart';
import 'app/routes/app_pages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetStorage persistence
  await AppPreferences.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);

  // Initialize Firebase Cloud Messaging & Push Notification Service
  await PushNotificationService.instance.initialize();

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
 fontSizeResolver: (fontSize, instance) {
            final screenWidth = instance.screenWidth;
            // Mobile (< 650px): exact default behavior of flutter_screenutil (scaleText)
            if (screenWidth < 650.0) {
              return (fontSize * instance.scaleText).toDouble();
            }
            // Tablet (650px - 1024px): slightly compact font scale for tablet mobile view
            else if (screenWidth < 1024.0) {
              return (fontSize * 0.92).toDouble();
            }
            // Desktop / Web (>= 1024px): standard desktop typography (1.0x)
            else {
              return fontSize.toDouble();
            }
          },
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
