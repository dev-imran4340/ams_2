import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:ams_2/app/api/app_preferences.dart';
import 'package:ams_2/app/core/theme/app_theme.dart';
import 'package:ams_2/app/routes/app_routes.dart';
import 'package:ams_2/app/routes/auth_guard_middleware.dart';
import 'package:ams_2/app/screens/index/controller/index_controller.dart';
import 'package:ams_2/app/screens/index/repo/index_repo.dart';
import 'package:ams_2/app/screens/index/view/index_view.dart';
import 'package:ams_2/app/screens/main_shell/controller/session_me_controller.dart';

class MockIndexRepo extends IndexRepo {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    const MethodChannel channel =
        MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return '.';
    });
    await GetStorage.init();
  });

  setUp(() async {
    Get.testMode = true;
    await AppPreferences.clearAll();
  });

  tearDown(() {
    Get.reset();
  });

  group('IndexView GlobalKey Collision Prevention & Scaffold Drawer Tests', () {
    testWidgets('Mounting multiple IndexView instances simultaneously does not throw duplicate GlobalKey assertion', (tester) async {
      final mockRepo = MockIndexRepo();
      Get.put(IndexController(repo: mockRepo));
      Get.put(SessionMeController());

      // Simulate the exact condition from the error report:
      // Two IndexView widgets are active during a page transition or duplicate route
      await tester.pumpWidget(
        GetMaterialApp(
          home: Column(
            children: const [
              Expanded(child: IndexView()),
              Expanded(child: IndexView()),
            ],
          ),
        ),
      );

      // Verify widget tree finalized cleanly with zero exceptions
      expect(tester.takeException(), isNull);
      expect(find.byType(IndexView), findsNWidgets(2));
    });

    test('IndexController scaffoldKey dynamically registers active key', () {
      final mockRepo = MockIndexRepo();
      final controller = IndexController(repo: mockRepo);

      final key1 = GlobalKey<ScaffoldState>();
      final key2 = GlobalKey<ScaffoldState>();

      controller.registerScaffoldKey(key1);
      expect(controller.scaffoldKey, equals(key1));

      controller.registerScaffoldKey(key2);
      expect(controller.scaffoldKey, equals(key2));

      controller.unregisterScaffoldKey(key2);
      expect(controller.scaffoldKey, isNot(equals(key2)));
    });
  });

  group('Status Bar White Icon Overlay Consistency Tests', () {
    testWidgets('AppTheme lightTheme and darkTheme enforce white status bar icons', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) {
            final light = AppTheme.lightTheme;
            final dark = AppTheme.darkTheme;

            // On Android: Brightness.light means WHITE icons
            // On iOS: Brightness.dark means WHITE icons
            final lightOverlay = light.appBarTheme.systemOverlayStyle;
            expect(lightOverlay?.statusBarIconBrightness, Brightness.light);
            expect(lightOverlay?.statusBarBrightness, Brightness.dark);

            final darkOverlay = dark.appBarTheme.systemOverlayStyle;
            expect(darkOverlay?.statusBarIconBrightness, Brightness.light);
            expect(darkOverlay?.statusBarBrightness, Brightness.dark);

            return const SizedBox.shrink();
          },
        ),
      );
    });
  });

  group('AuthGuardMiddleware Redirect Loop Prevention Tests', () {
    test('When destination is already the fallbackRoute, returns null instead of redundant redirect', () async {
      await AppPreferences.saveAuthData(token: 'token123', isCompany: false);

      final guard = AuthGuardMiddleware();
      final result = guard.redirect(Routes.INDEX);

      // Should return null (proceed to index cleanly without issuing another redirect)
      expect(result, isNull);
    });
  });
}
