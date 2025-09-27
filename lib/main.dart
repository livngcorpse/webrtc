// Updated lib/main.dart
import 'package:flutter/material.dart';
import 'package:get_boilerplate/src/lang/translation_service.dart';
import 'package:get_boilerplate/src/routes/app_pages.dart';
import 'package:get_boilerplate/src/shared/logger/logger_utils.dart';
import 'package:get_boilerplate/src/theme/theme_service.dart';
import 'package:get_boilerplate/src/theme/themes.dart';
import 'package:get_boilerplate/src/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetStorage
  await GetStorage.init();

  // Initialize controllers
  Get.put(AuthController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'VideoConference',
      debugShowCheckedModeBanner: false,
      enableLog: true,
      logWriterCallback: Logger.write,

      // Routing
      initialRoute: _getInitialRoute(),
      getPages: AppPages.routes,
      unknownRoute: GetPage(
        name: '/404',
        page: () => const Scaffold(
          body: Center(
            child: Text('Page not found'),
          ),
        ),
      ),

      // Localization
      locale: TranslationService.locale,
      fallbackLocale: TranslationService.fallbackLocale,
      translations: TranslationService(),

      // Theming
      theme: Themes().lightTheme,
      darkTheme: Themes().darkTheme,
      themeMode: ThemeService().getThemeMode(),

      // App lifecycle
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child ?? const SizedBox(),
        );
      },
    );
  }

  String _getInitialRoute() {
    final authController = Get.find<AuthController>();

    // Check if user is already authenticated
    if (authController.isAuthenticated.value) {
      return Routes.DASHBOARD;
    }

    return Routes.LOGIN;
  }
}
